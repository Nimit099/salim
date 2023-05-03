global class DropboxFutureToken {

    public static Integer statuscode {get; set;}

    @future(callout=true)
    public static void generatetoken()
    {
        System.debug('future mathod call');
        List<DropboxInfo__c> DropboxinfoList = DropboxInfo__c.getall().values();  
        System.debug('DropboxinfoList'+DropboxinfoList[0]);  
        String consumerKey = DropboxinfoList[0].ConsumerKey__c;
        String clientSecret = DropboxinfoList[0].ClientSecret__c;
        String redirect_uri = DropboxinfoList[0].Redirect_URL__c;
        String AuthUrl = DropboxinfoList[0].AuthorizationURL__c;
        String AccessTokenEndPoint = DropboxinfoList[0].AccessTokenEndPoint__c;
        System.debug(AccessTokenEndPoint);
        
        String errorMessage ='';
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        httpReq.setEndpoint(AccessTokenEndPoint);
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        List<DropboxToken__c> googleSettingInfoList = new List<DropboxToken__c>();
        googleSettingInfoList = DropboxToken__c.getAll().values();
        String refreshToken;
        if(googleSettingInfoList.size() > 0 )
                refreshToken = googleSettingInfoList[0].RefreshToken__c;
        
        System.debug('#### refreshToken '+refreshToken);

        String refreshTokenBody = 'client_id='+consumerKey+'&client_secret='+clientSecret+'&refresh_token='+refreshToken
                                        +'&grant_type=refresh_token';

        System.debug('#### refreshTokenBody '+refreshTokenBody);
        
        httpReq.setBody(refreshTokenBody);
        httpRes = http.send(httpReq); 
        statuscode = 200;
        try{
            System.debug('httpreq>>>'+httpRes);
            if(httpRes.getStatusCode() == 200){

                Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());
                System.debug('336>>'+googleSettingInfoList[0].AccessToken__c);
                DropboxToken__c googleSettingInfo = googleSettingInfoList[0];
                googleSettingInfo.AccessToken__c = String.valueOf(TokenInfo.get('access_token'));
                googleSettingInfo.ExpiresTime__c = String.valueOf(TokenInfo.get('expires_in'));
                googleSettingInfo.tokenerror__c = false;
                System.debug('do Refresh Token '+googleSettingInfo);
                update new List<DropboxToken__c>{googleSettingInfo};
                // getFolderFromDropbox(recordId);
                // return String.valueOf(httpRes.getStatuscode());
            }else{
                DropboxToken__c googleSettingInfo = googleSettingInfoList[0];
                googleSettingInfo.tokenerror__c = true;
                update new List<DropboxToken__c>{googleSettingInfo};
                errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                System.debug('Error ' + errorMessage);

                // return String.valueOf(httpRes.getStatuscode());
            }
        }catch(System.Exception e){
            DropboxToken__c googleSettingInfo = googleSettingInfoList[0];
            googleSettingInfo.tokenerror__c = true;
            update new List<DropboxToken__c>{googleSettingInfo};
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
            errorMessage = 'Unexpected Error while communicating with Google Calendar API. '+'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
            // return String.valueOf(httpRes.getStatuscode());
        }
    }
}