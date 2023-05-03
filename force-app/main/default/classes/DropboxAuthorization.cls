public class DropboxAuthorization {

    public final string DB_URL = 'https://www.dropbox.com/2/';
    public final String DB_API = 'https://api.dropboxapi.com/2/';
    public final String DB_CONTENT_API = 'https://content.dropboxapi.com/2/';
    public final String DB_CLIENT_ID = 'm9k8mhami8x92rm';
    public final String DB_CLIENT_SECRET = '26m1w9kxxityu3m';
    public string DOMAIN_URL = ApexPages.currentPage().getHeaders().get('Host');
    public String CURRENT_PAGE_URL = '/apex/dropboxauthentication';
    
    public final Map<String,String> DB_ENDPOINTS = new Map<String,String>{
      'AUTHORIZE' => 'oauth2/authorize',
      'TOKEN' => 'oauth2/token',
      'ACCOUNT' => 'account/info',
      'FILE_UPLOAD' => 'files_put/auto/'
    };
        
    public String AUTH_CODE = null;
    public String TOKEN = null;

    public void authorize(String url,String method,String postData){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(method);
        
        if(TOKEN != null){
            request.setHeader('Authorization',String.format('Bearer {0}',new String[]{TOKEN}));
        }
        if(method.equalsIgnoreCase('POST')){
            request.setBody(postData);
        }
        
        HttpResponse response = new Http().send(request);
        System.debug(response.getBody());
        
    }    
    
}