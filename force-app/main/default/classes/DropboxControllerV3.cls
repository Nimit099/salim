public class DropboxControllerV3 {
		
		// Info
        public static String consumerKey { get; set; }
        public static String clientSecret { get; set; }
		
		// Authorization Url
		public static String AuthUrl { get; set; }

		// Your redirect URI here that you entered while creating the App in Google API console
		public static String redirect_uri { get; set; }

		// Auth1 code
        public static String code { get; set; }

		// Access token end point
        public static String AccessTokenEndPoint { get; set; }

		/* Constructor */
		// public DropboxControllerV3(){  
        //     System.debug('<<<<<<<<<<<<<<<<<<<<<Page Refresh>>>>>>>>>>>>>>>>>>>>>>.');

		// 	List<DropboxInfo__c> DropboxinfoList = DropboxInfo__c.getall().values();  

		// 	System.debug('DropboxinfoList'+DropboxinfoList[0]);  

		// 	consumerKey = DropboxinfoList[0].ConsumerKey__c;
		// 	clientSecret = DropboxinfoList[0].ClientSecret__c;
		// 	redirect_uri = DropboxinfoList[0].Redirect_URL__c;
		// 	AuthUrl = DropboxinfoList[0].AuthorizationURL__c;
		// 	AccessTokenEndPoint = DropboxinfoList[0].AccessTokenEndPoint__c;

		// 	System.debug(AuthUrl);
		// 	System.debug(redirect_uri);
		// 	System.debug(consumerKey);

        //     String authCode = ApexPages.currentPage().getParameters().get('code');
        //     System.debug(authCode);
        //     if(authCode == null){
		// 		System.debug('auth code not null'+ authCode);
		// 		// authorization();
        //     }
		// }

		public PageReference authorization(){ 
			List<DropboxInfo__c> DropboxinfoList = DropboxInfo__c.getall().values();  

			System.debug('DropboxinfoList'+DropboxinfoList[0]);  

			consumerKey = DropboxinfoList[0].ConsumerKey__c;
			redirect_uri = DropboxinfoList[0].Redirect_URL__c;
			AuthUrl = DropboxinfoList[0].AuthorizationURL__c;
			
			//String request_Body = AuthUrl+'redirect_uri='+redirect_uri+'&response_type=code&client_id='+consumerKey+
				//				  '&token_access_type=online&grant_type=authorization_code';
			//String request_Body = 'https://www.dropbox.com/oauth2/authorize?client_id='+consumerKey+'&redirect_uri='+redirect_uri+'&response_type=code&token_access_type=online';
			String request_Body = 'https://api.dropboxapi.com/oauth2/token?client_id='+consumerKey+'&client_secret=26m1w9kxxityu3m&redirect_uri='+redirect_uri+'&token_access_type=offline&grant_type=authorization_code';
			
            SYstem.debug('request_Body==='+request_Body);
			PageReference pr = new PageReference(request_Body);
			return pr;
		}
		
		public static PageReference doFetchAccessToken(){ 

			List<DropboxInfo__c> DropboxinfoList = DropboxInfo__c.getall().values();  
			System.debug('DropboxinfoList'+DropboxinfoList[0]);  
			consumerKey = DropboxinfoList[0].ConsumerKey__c;
			clientSecret = DropboxinfoList[0].ClientSecret__c;
			redirect_uri = DropboxinfoList[0].Redirect_URL__c;
			AuthUrl = DropboxinfoList[0].AuthorizationURL__c;
			AccessTokenEndPoint = DropboxinfoList[0].AccessTokenEndPoint__c;
			
			String authCode = ApexPages.currentPage().getParameters().get('code');
            System.debug(authCode);
			String errorMessage = '';
			
			String requestTokenBody = 'code='+authCode+'&grant_type=authorization_code'+'&client_id='+consumerKey+'&client_secret='+
											clientSecret+'&redirect_uri='+redirect_uri;
			
			Http http = new Http();
			httpRequest httpReq = new httpRequest();
			HttpResponse response = new HttpResponse();
			httpReq.setEndPoint(AccessTokenEndPoint);
			httpReq.setBody(requestTokenBody);
			httpReq.setMethod('POST');
			try{
				response = http.send(httpReq);
                System.debug(response);
				if(response.getStatuscode()==200){
					PageReference pageRef = new PageReference('/apex/dropboxpage');
                    pageRef.setRedirect(true);
					Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
					System.debug('#### TokenInfo '+TokenInfo);
                    System.debug(TokenInfo.get('access_token'));
                    System.debug(TokenInfo.get('expires_in'));
                    System.debug(TokenInfo.get('refresh_token'));
                    System.debug(TokenInfo.get('id_token'));

					List<DropboxToken__c> DT = DropboxToken__c.getAll().values();

					if(DT.size() > 0){
						System.debug('if 1 or more');
						DropboxToken__c t = DropboxToken__c.getInstance('Dropbox Token');

						t.AccessToken__c = String.valueOf(TokenInfo.get('access_token'));
						t.ExpiresTime__c = String.valueOf(TokenInfo.get('expires_in'));
						t.RedirectCode__c = String.valueOf(authCode);
						t.RefreshToken__c = String.valueOf(TokenInfo.get('refresh_token'));

						update t;
					}
					else{
						System.debug('else 0');
						//Insert custom settings record
						insert new DropboxToken__c(
							Name = 'Dropbox Token',
							AccessToken__c = String.valueOf(TokenInfo.get('access_token')), 
							ExpiresTime__c= String.valueOf(TokenInfo.get('expires_in')),
							RefreshToken__c = String.valueOf(TokenInfo.get('refresh_token')),
							RedirectCode__c = String.valueOf(authCode)
						);
					}
                         
                    return pageRef;
				}else{
					errorMessage = 'Unexpected Error while communicating with Google  API. '
						+'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                    return null;
				}     
			}catch(System.Exception e){
				if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
					errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
						+' Remote Site Setting and add '+' '+ AccessTokenEndPoint +' Endpoint';
                    return null;
				}else{
					errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
						+'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                    return null;
				}
			}  
		}

		// public static void doRefreshToken(){

		// 	List<DropboxInfo__c> DropboxinfoList = DropboxInfo__c.getall().values();  

		// 	System.debug('DropboxinfoList'+DropboxinfoList[0]);  

		// 	consumerKey = DropboxinfoList[0].ConsumerKey__c;
		// 	clientSecret = DropboxinfoList[0].ClientSecret__c;
		// 	redirect_uri = DropboxinfoList[0].Redirect_URL__c;
		// 	AuthUrl = DropboxinfoList[0].AuthorizationURL__c;
		// 	AccessTokenEndPoint = DropboxinfoList[0].AccessTokenEndPoint__c;
			
		// 	String errorMessage ='';
			
		// 	Http http = new Http();
		// 	HttpRequest httpReq = new HttpRequest();
		// 	HttpResponse httpRes = new HttpResponse();
		// 	httpReq.setEndpoint(AccessTokenEndPoint);
		// 	httpReq.setMethod('POST');
		// 	httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
			
		// 	List<DropboxToken__c> googleSettingInfoList = new List<DropboxToken__c>();
		// 	googleSettingInfoList = DropboxToken__c.getAll().values();
		// 	String refreshToken;
		// 	if(googleSettingInfoList.size() > 0 )
		// 			refreshToken = googleSettingInfoList[0].RefreshToken__c;
			
		// 	System.debug('#### refreshToken '+refreshToken);

		// 	String refreshTokenBody = 'client_id='+consumerKey+'&client_secret='+clientSecret+'&refresh_token='+refreshToken
		// 									+'&grant_type=refresh_token';

		// 	System.debug('#### refreshTokenBody '+refreshTokenBody);
			
		// 	httpReq.setBody(refreshTokenBody);
					
		// 	try{
		// 	   httpRes = http.send(httpReq); 
		// 		if(httpRes.getStatusCode() == 200){

		// 			Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());
					
        //             DropboxToken__c googleSettingInfo = googleSettingInfoList[0];

        //             googleSettingInfo.AccessToken__c = String.valueOf(TokenInfo.get('access_token'));
        //             googleSettingInfo.ExpiresTime__c = String.valueOf(TokenInfo.get('expires_in'));

		// 			System.debug('do Refresh Token '+googleSettingInfo);

        //             update new List<DropboxToken__c>{googleSettingInfo};
		// 		}else{
		// 			errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
		// 				+'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
        //             System.debug('Error ' + errorMessage);
		// 		}
		// 	}catch(System.Exception e){
				
		// 		System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
		// 		if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
		// 			errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
		// 				+' Remote Site Setting and add '+' '+ 'https://www.googleapis.com/oauth2/v4/token' +' Endpoint';
		// 		}else{
		// 			errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
		// 				+'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
		// 		}
		// 	}
		// }
	}