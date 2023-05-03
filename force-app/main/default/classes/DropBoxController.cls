public class DropBoxController {

    public static String pathURL { get; set; }//New Global Variable for file path.
    public static String dpath {get; set;}//New Global Variable for download path.
    @future
    public static void UpdatePath(String id,String path){
        buildertek__Project__c pro = [SELECT id,name,Dropbox_Path__c FROM buildertek__Project__c where Id =: id];
        pro.Dropbox_Path__c = path;
        update pro;
    }
    
    @AuraEnabled
    public static folderdetails getFolderFromDropbox( String recordId,String accesstoken){
        if (pathURL == null) {
            pathURL=Getpathdata(recordId);
        }
        System.debug(pathURL);
        List<String> arr= pathURL.split('/');
        String fname = arr[arr.size()-1];
        buildertek__Project__c pro = [SELECT Id, Name, Dropbox_Path__c FROM buildertek__Project__c WHERE Id =: recordId];
        String tokenn;
        String rtn;
        Decimal minutes;
        String path = pro.Dropbox_Path__c;
        List<String> array1 = path.split('/');
        path = array1[array1.size()-1];
        path = path.replaceAll('\\s{2,}', ' ');
        System.debug('fname --> '+'/'+path+'/');
        List<DropboxInfo__c> DropboxinfoList = DropboxInfo__c.getall().values();  
        String FileSearchEndPoint = DropboxinfoList[0].FolderSearchUrl__c;
        System.debug(FileSearchEndPoint);
        List<DropboxToken__c> DToken = new List<DropboxToken__c>();
        DToken = DropboxToken__c.getAll().values();
        if(DToken.size() > 0 ){
            DateTime startDate = DateTime.now();
            DateTime endDate = DToken[0].LastModifiedDate;
            minutes = Integer.valueOf((startDate.getTime() - endDate.getTime())/(1000*60));
            if(accesstoken != '' && accesstoken != null){
                tokenn = accesstoken;
               
            }else{
                tokenn = DToken[0].AccessToken__c;
            }
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(FileSearchEndPoint);   
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer '+tokenn);
        String jsonString =  '{"query": "'+path+'","include_highlights": false}'; 
        // String jsonString =  '{"query": "/Test 001","include_highlights": false}'; 
        req.setBody(jsonString);
        folderdetails returnData = new folderdetails();
        HttpResponse response;
        response =  http.send(req);
        try {   
            System.debug('status code, '+response.getStatusCode());
            System.debug('status, '+response.getStatus());
            if(response.getStatuscode()==200){
                
                System.debug(response.getBody());
                Map < String,Object > results = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
                System.debug(results);
                List<Object> matches = (List<Object>)results.get('matches');
                if(matches.size() == 0){
                //List<String> splitList = createNewFolder(pro.Name).split(':::');
                    //returnData.folderId = splitList[0];
                    //returnData.path_display = splitList[1];
                    //returnData.folderName = pro.Name;
                }else{
                    Boolean flag = false;
                    for(Object o: matches){
                        Map<String,Object> matchesV = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(o));
                        Map<String,Object> matchesV1 =(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(matchesV.get('metadata')));
                        Map<String,Object> matchesV2 =(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(matchesV1.get('metadata')));
                        pathURL = pathURL.replaceAll('\\s{2,}', ' ');
                        System.debug(matchesV2.get('.tag') == 'folder');
                        System.debug((String.valueOf(matchesV2.get('path_lower')).replaceAll('\\s{2,}', ' ')));
                        System.debug(pathURL.toLowerCase().substring(0, pathURL.length()));
                        System.debug(((String.valueOf(matchesV2.get('path_lower')).replaceAll('\\s{2,}', ' ')).replaceAll('\\s{2,}', ' ')).contains(pathURL.toLowerCase().substring(0, pathURL.length())));
                        System.debug((String.valueOf(matchesV2.get('name'))).replaceAll('\\s{2,}', ' '));
                        System.debug(path);
                        System.debug((String.valueOf((String.valueOf(matchesV2.get('name'))).replaceAll('\\s{2,}', ' '))).replaceAll('\\s{2,}', ' ') == path);
                        dpath = String.valueOf(matchesV2.get('path_lower'));
                        System.debug(dpath);
                        if((matchesV2.get('.tag') == 'folder' && (String.valueOf(matchesV2.get('path_lower')).replaceAll('\\s{2,}', ' ')).contains(pathURL.toLowerCase().substring(0, pathURL.length()))) && (String.valueOf(matchesV2.get('name'))).replaceAll('\\s{2,}', ' ') == path){
                            System.debug('if condition');
                            returnData.folderFiles = getFolderDetails(String.valueOf(matchesV2.get('path_display')),accesstoken);
                            returnData.folderId = String.valueOf(matchesV2.get('id'));
                            returnData.folderName = String.valueOf((String.valueOf(matchesV2.get('name'))).replaceAll('\\s{2,}', ' '));
                            returnData.path_display = String.valueOf(matchesV2.get('path_display'));
                            flag = true;
                            UpdatePath(pro.id,String.valueOf(matchesV2.get('path_display')));
                        }
                    }
                    if(!flag){
                        //List<String> splitList = createNewFolder(pro.Name).split(':::');
                        //returnData.folderId = splitList[0];
                        //returnData.path_display = splitList[1];
                        //returnData.folderName = pro.Name;
                    }
                }

                if(accesstoken != '') DropBoxController.updateToken(tokenn);
            }else if(response.getStatuscode() == 401 && accesstoken == ''){
                returnData = DropBoxController.getFolderFromDropbox(recordId,tokenExpired());
            }
        }catch(Exception e) {
        }
        if(response.getStatuscode() == 200 & rtn == '200'){
            returnData.vferror = false;
        }else if(response.getStatuscode() == 200 & rtn != '200'){
            returnData.vferror = false;
        }
        System.debug(returnData);
        return returnData;
    }

    public static String tokenExpired(){
        List<DropboxInfo__c> DropboxinfoList = DropboxInfo__c.getall().values();
        String consumerKey = DropboxinfoList[0].ConsumerKey__c;
        String clientSecret = DropboxinfoList[0].ClientSecret__c;
        String redirect_uri = DropboxinfoList[0].Redirect_URL__c;
        String AuthUrl = DropboxinfoList[0].AuthorizationURL__c;
        String AccessTokenEndPoint = DropboxinfoList[0].AccessTokenEndPoint__c;

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

        String refreshTokenBody = 'client_id='+consumerKey+'&client_secret='+clientSecret+'&refresh_token='+refreshToken
                                        +'&grant_type=refresh_token';
        
        httpReq.setBody(refreshTokenBody);
        httpRes = http.send(httpReq);

        if(httpRes.getStatusCode() == 200){

            Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());
            return String.valueOf(TokenInfo.get('access_token'));

        }else{
            return null;
        }
    }

    @future
    public static void updateToken(String accTok){
        List<DropboxToken__c> googleSettingInfoList = new List<DropboxToken__c>();
        googleSettingInfoList = DropboxToken__c.getAll().values();
        DropboxToken__c googleSettingInfo = googleSettingInfoList[0];
        googleSettingInfo.AccessToken__c = accTok;
        update new List<DropboxToken__c>{googleSettingInfo};
        DropboxToken__c obj = DropboxToken__c.getInstance('Dropbox Token');
        obj.AccessToken__c = accTok;
        update obj;
    }

    @AuraEnabled
    public static String createNewFolder(String folderName){
        String tokenn;
        List<DropboxToken__c> DToken = new List<DropboxToken__c>();
        DToken = DropboxToken__c.getAll().values();
        if(DToken.size() > 0 ){
            tokenn = DToken[0].AccessToken__c;
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.dropboxapi.com/2/files/create_folder_v2');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer '+tokenn);
        String jsonString = '{"path": "'+pathURL+'","autorename": false}';
        req.setBody(jsonString);
        HttpResponse response;
        response =  http.send(req);
        if(response.getStatuscode()==200){
            try {
                Map < String,Object > results = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
                System.debug('results '+results);
                Map<String,Object> matchesV = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(results.get('metadata')));
                System.debug('matchesV '+matchesV);
                return String.valueOf(matchesV.get('id'))+':::'+String.valueOf(matchesV.get('path_lower'));
            }catch(System.CalloutException e) {
                return null;
            }
        }else{
            return null;
        }
    }

    // create sub folder
    @AuraEnabled
    public static Map <String,Object> createNewSubFolder(String folderName){
        String tokenn;
        Map<String,Object> nulldata = new Map<String,Object>(); 
        List<DropboxToken__c> DToken = new List<DropboxToken__c>();
        DToken = DropboxToken__c.getAll().values();
        if(DToken.size() > 0 ){
            tokenn = DToken[0].AccessToken__c;
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.dropboxapi.com/2/files/create_folder_v2');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer '+tokenn);
        // List<String> arr = folderName.split('/');
        // String Fpath = '';
        // for (Integer i = 2; i < arr.size(); i++) {
        //     Fpath = Fpath + '/' + arr[i];
        // }
        // folderName = Fpath;
        String jsonString = '{"path": "'+folderName+'","autorename": false}';
        req.setBody(jsonString);
        HttpResponse response;
        response =  http.send(req);
        if(response.getStatuscode()==200){
            try {
                Map < String,Object > results = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
                Map<String,Object> matchesV = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(results.get('metadata')));
                return matchesV;
            }catch(System.CalloutException e) {
                return nulldata;
            }
        }else{
            return nulldata;
        }
    }

    @AuraEnabled
    public static List<folderItems> getFolderDetails(String dropboxFolderName,String accTok){
        String tokenn;
        List<DropboxToken__c> DToken = new List<DropboxToken__c>();
        DToken = DropboxToken__c.getAll().values();
        if(DToken.size() > 0 ){
            tokenn = accTok != '' ? accTok : DToken[0].AccessToken__c;
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.dropboxapi.com/2/files/list_folder');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer '+tokenn);
        System.debug('path'+dropboxFolderName);
        List<String> arr = dropboxFolderName.split('/');
        String Fpath = '/';
        for (Integer i = 1; i < arr.size(); i++) {
            Fpath = Fpath + arr[i] + '/';
        }
        System.debug('newpath --> '+Fpath);
        String jsonString = '{"path": "'+Fpath+'","recursive": false,"include_media_info": false,"include_deleted": false,"include_has_explicit_shared_members": false,"include_mounted_folders": true,"include_non_downloadable_files": true}';
        // String jsonString = '{"path": "/BLUENEST OFFICE/PROJECTS IN PROGRESS/01. Newly Acquired","recursive": false,"include_media_info": false,"include_deleted": false,"include_has_explicit_shared_members": false,"include_mounted_folders": true,"include_non_downloadable_files": true}';
        req.setBody(jsonString);
        HttpResponse response;
        List<folderItems> returnData = new List<folderItems>();
        response =  http.send(req);
        System.debug(response.getStatusCode());
        System.debug('response:-'+response);
        if(response.getStatuscode()==200){
            try {
                Map < String,Object > results = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
    
                List<Object> entries = (List<Object>)results.get('entries');
                for(Object o: entries){
                    Map < String,Object > ores = (Map < String, Object > ) JSON.deserializeUntyped(JSON.serialize(o));
                    folderItems f = new folderItems();
                    f.type = String.valueOf(ores.get('.tag'));
                    f.name = String.valueOf(ores.get('name'));
                    f.path_display = String.valueOf(ores.get('path_display'));
                    f.id = String.valueOf(ores.get('id'));
                    if(String.valueOf(ores.get('.tag')) == 'folder'){
                        f.itemtype = false;
                    }else{
                        f.itemtype = true;
                    }
                    returnData.add(f);
                }
            }catch(System.CalloutException e) {
            }
        }
        System.debug(returnData);
        return returnData;
    }

    // For Download files
    @AuraEnabled
    public static String downloadFileFromDropBox_V1(String fileId){

        String tokenn;
        List<DropboxToken__c> DToken = new List<DropboxToken__c>();
        DToken = DropboxToken__c.getAll().values();
        if(DToken.size() > 0 ){
            tokenn = DToken[0].AccessToken__c;
        }
        System.debug(tokenn);
        System.debug(dpath+'/'+fileId);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.dropboxapi.com/2/files/get_temporary_link');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer '+tokenn);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // List<String> arr = fileId.split('/');
        // String Fpath = '';
        // for (Integer i = 2; i < arr.size(); i++) {
        //     Fpath = Fpath + '/' + arr[i];
        // }
        // fileId = Fpath;
        String jsonString = '{"path":"'+fileId+'"}';
        req.setBody(jsonString);
        HttpResponse res;
        try {
            res =  http.send(req);
            Map < String,Object > results = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
            System.debug(results.get('link'));
            return String.valueOf(results.get('link'));
        }catch(System.CalloutException e) {
            return null;
        }
    }

    // For file uploade
    @AuraEnabled
    public static String uploadFile( String folderPath,String baseVal){
        System.debug('in upload file apex'+folderPath);
        String tokenn;
        if (folderPath == null) {
            folderPath = pathURL;
        }
        List<DropboxToken__c> DToken = new List<DropboxToken__c>();
        DToken = DropboxToken__c.getAll().values();
        if(DToken.size() > 0 ){
            tokenn = DToken[0].AccessToken__c;
        }
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/octet-stream');
        req.setMethod('POST');
        req.setEndpoint('https://content.dropboxapi.com/2/files/upload');
        req.setBodyAsBlob(EncodingUtil.base64Decode(baseVal));
        string fileName='application.pdf';  
        // List<String> arr = folderPath.split('/');
        // String Fpath = '';
        // for (Integer i = 2; i < arr.size(); i++) {
        //     Fpath = Fpath + '/' + arr[i];
        // }
        // folderPath = Fpath; 
        System.debug('path '+folderPath);
        req.setHeader('Dropbox-API-Arg', '{"path": "'+folderPath+'","mode": "add","autorename": true,"mute": false,"strict_conflict": false}');
        req.setHeader('Authorization', 'Bearer '+tokenn);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        if(response.getStatuscode()==200){
            Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
            return String.valueOf(response.getBody());
        }else{
            return null;
        }
    }

    public class folderItems{
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String path_display {get;set;}
        @AuraEnabled public Boolean itemtype {get;set;}
    }

    public class folderdetails{
        @AuraEnabled public String folderId {get;set;}
        @AuraEnabled public List<folderItems> folderFiles {get;set;}
        @AuraEnabled public String folderName {get;set;}
        @AuraEnabled public String path_display {get;set;}
        @AuraEnabled public Boolean vferror {get;set;}
    }

    @AuraEnabled
    public static folderdetails getFolderFromDropbox_11(String recordId,String folderName,String parentFol, String accesstoken){
        recordId = recordId.replaceAll('\\s{2,}', ' ');
        folderName = folderName.replaceAll('\\s{2,}', ' ');
        String tokenn;
        String rtn;
        Decimal minutes;
        List<DropboxInfo__c> DropboxinfoList = DropboxInfo__c.getall().values();  
        String FileSearchEndPoint = DropboxinfoList[0].FolderSearchUrl__c;

        List<DropboxToken__c> DToken = new List<DropboxToken__c>();
        DToken = DropboxToken__c.getAll().values();
        if(DToken.size() > 0 ){
            DateTime startDate = DateTime.now();
            DateTime endDate = DToken[0].LastModifiedDate;
            minutes = Integer.valueOf((startDate.getTime() - endDate.getTime())/(1000*60));
            if(accesstoken != '' && accesstoken != null){
                tokenn = accesstoken;
               
            }else{
                tokenn = DToken[0].AccessToken__c;
            }
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(FileSearchEndPoint);   
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer '+tokenn);
        System.debug(folderName);
        String jsonString =  '{"query": "'+folderName+'","include_highlights": false}'; 
        req.setBody(jsonString);
        folderdetails returnData = new folderdetails();
        HttpResponse response;
        response =  http.send(req);

        
        try {   
            if(response.getStatuscode()==200){
                Map < String,Object > results = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
                List<Object> matches = (List<Object>)results.get('matches');
                if(matches.size() == 0){
                    returnData.folderName = folderName;
                }
                else{
                    Boolean flag = false;
                    for(Object o: matches){
                        Map<String,Object> matchesV = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(o));
                        Map<String,Object> matchesV1 =(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(matchesV.get('metadata')));
                        Map<String,Object> matchesV2 =(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(matchesV1.get('metadata')));
                        System.debug(matchesV2.get('.tag') == 'folder');
                        System.debug((String.valueOf(matchesV2.get('path_lower')).replaceAll('\\s{2,}', ' ')));
                        System.debug(recordId.toLowerCase());
                        System.debug(((String.valueOf(matchesV2.get('path_lower')).replaceAll('\\s{2,}', ' ')).replaceAll('\\s{2,}', ' ')).contains(recordId.toLowerCase().substring(0, recordId.length())));
                        System.debug((String.valueOf(matchesV2.get('name'))).replaceAll('\\s{2,}', ' '));
                        System.debug(folderName);
                        System.debug((String.valueOf((String.valueOf(matchesV2.get('name'))).replaceAll('\\s{2,}', ' '))).replaceAll('\\s{2,}', ' ') == folderName);
                        dpath = String.valueOf(matchesV2.get('path_lower'));
                        System.debug(dpath);
                        if(matchesV2.get('.tag') == 'folder' && (String.valueOf(matchesV2.get('path_lower')).replaceAll('\\s{2,}', ' ')).contains(recordId.toLowerCase()) && (String.valueOf(matchesV2.get('name'))).replaceAll('\\s{2,}', ' ') == folderName){
                            System.debug('in if');
                            returnData.folderFiles = getFolderDetails(String.valueOf(matchesV2.get('path_display')),tokenn);
                            returnData.folderId = String.valueOf(matchesV2.get('id'));
                            returnData.folderName = String.valueOf((String.valueOf(matchesV2.get('name'))).replaceAll('\\s{2,}', ' '));
                            returnData.path_display = String.valueOf(matchesV2.get('path_display'));
                            flag = true;
                        }
                    }
                    if(!flag){
                        returnData.folderName = folderName;
                    }
                }
            }else if(response.getStatuscode() == 401 && accesstoken == ''){
                returnData = DropBoxController.getFolderFromDropbox_11(recordId, folderName, parentFol, tokenExpired());
            }
        }catch(System.CalloutException e) {
        }
        if(response.getStatuscode() == 200 & rtn == '200'){
            returnData.vferror = false;
        }else if(response.getStatuscode() == 200 & rtn != '200'){
            returnData.vferror = false;
        }
        if(minutes > 410){
            // doRefreshToken();
            DropboxFutureToken.generatetoken();
            Integer sc = DropboxFutureToken.statuscode;
        }

        return returnData;
    }
    //Method to get current path.
    @AuraEnabled(cacheable=true)
    public static String Getpathdata(String Id){

        buildertek__Project__c lst = [SELECT Id, Name, Dropbox_Path__c, Dropbox_Folder__c, buildertek__Stage__c FROM buildertek__Project__c Where Id=:Id LIMIT 1];
        pathURL = lst.Dropbox_Path__c;
        return pathURL;
    }
}