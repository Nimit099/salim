public without sharing class ProjectTriggerHandler { 
    List<buildertek__Project__c> recordNewList = new List<buildertek__Project__c>();
    List<buildertek__Project__c> recordOldList = new List<buildertek__Project__c>();
    Map<Id, buildertek__Project__c> recordNewMap = new Map<Id, buildertek__Project__c>();
    Map<Id, buildertek__Project__c> recordOldMap = new Map<Id, buildertek__Project__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = true;
    public static boolean flag = true;
    
    public ProjectTriggerHandler(List<buildertek__Project__c> newList, List<buildertek__Project__c> oldList, Map<Id, buildertek__Project__c> newMap, Map<Id, buildertek__Project__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent(){
        setFolderpathMethod();
    }
  
    public void BeforeUpdateEvent(){
        stageFolderMethod();
    }
    
    public void BeforeDeleteEvent(){}
        
    public void AfterInsertEvent(){
        createFolders();
    }
    
    public void AfterUpdateEvent(){
    }
    
    public void AfterDeleteEvent(){}
    
    public void AfterUndeleteEvent(){
        
    }

    public void createFolders(){
        Dropbox_Folder_Paths__mdt metadata1 = [SELECT ID, Path_URLs__c FROM Dropbox_Folder_Paths__mdt LIMIT 1];
        for(buildertek__Project__c c: recordNewList){
            String str = c.Dropbox_Path__c;
            Http http = new Http();
            String str2 = metadata1.Path_URLs__c;
            str2 = str2.replaceAll('"/','"'+str+'/');
            createFolderscallout(str2,DropboxToken__c.getInstance('Dropbox Token').AccessToken__c);
        }
    }

    @future(callout=true)
    public static void createFolderscallout(String str, String AccToken){
        System.debug(str);
        AccToken = DropBoxController.tokenExpired();
        System.debug(Acctoken);
        System.debug(str);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.dropboxapi.com/2/files/create_folder_batch');   
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+AccToken);
        String jsonString =  '{"autorename": false,"force_async": false,"paths":'+str+'}';
        req.setBody(jsonString);
        HttpResponse response;
        response =  http.send(req);
    }


    public void setFolderpathMethod(){
        for(buildertek__Project__c c: recordNewList){
            System.debug(c);
            if(c.buildertek__Stage__c == null){
                c.buildertek__Stage__c = 'Newly Purchased';
            }
            if(c.buildertek__Stage__c != null && c.Name != null){
                DropBoxMapping__c dr = DropBoxMapping__c.getInstance(c.buildertek__Stage__c);
                if (dr != null){
                    if(c.Dropbox_Folder__c != null){
                        c.Dropbox_Path__c = dr.Folder_Path__c+c.Dropbox_Folder__c;
                        System.debug(' *** DropBox path==>'+dr.Folder_Path__c+c.Dropbox_Folder__c);
                    }
                    else{
                        c.Dropbox_Path__c = dr.Folder_Path__c+c.Name;
                    }
                }
            }
        }
    }
    
    public void stageFolderMethod(){
        for(buildertek__Project__c c: recordNewList){
            DropBoxMapping__c dr = DropBoxMapping__c.getInstance(c.buildertek__Stage__c);
            if((recordNewMap.get(c.Id).Dropbox_Folder__c != recordOldMap.get(c.Id).Dropbox_Folder__c) && c.Dropbox_Folder__c != null){
                c.Dropbox_Path__c = dr.Folder_Path__C + c.Dropbox_Folder__c;
            }
            if((recordNewMap.get(c.Id).Dropbox_Folder__c != recordOldMap.get(c.Id).Dropbox_Folder__c) && c.Dropbox_Folder__c == null){
                c.Dropbox_Path__c = dr.Folder_Path__C + c.Name;
            }
            if((recordNewMap.get(c.Id).buildertek__Stage__c != recordOldMap.get(c.Id).buildertek__Stage__c) && c.buildertek__Stage__c != null){             
                if(c.Dropbox_Path__c != null){
                    if (dr != null){
                        List<String> ss = c.Dropbox_Path__c.split('/');
                        String toPath;
                        if(c.Dropbox_Folder__c != null){
                            toPath = dr.Folder_Path__c+c.Dropbox_Folder__c;
                        }else{
                            toPath = dr.Folder_Path__c+c.Name;
                        }
                        moveFolderGeneric(c.Dropbox_Path__c, topath);
                        c.Dropbox_Path__c = toPath;
                    }
                }//else{
                   // DropBoxController.createNewFolder(c.Name);
               // }
            }
        }
    }
    
    
    @future(callout=true)
    public static void moveFolderGeneric(String frompath,String topath){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.dropboxapi.com/2/files/move_v2');   
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+DropboxToken__c.getInstance('Dropbox Token').AccessToken__c);
        String jsonString =  '{"from_path":"'+frompath+'","to_path": "'+topath+'","allow_shared_folder": false,"autorename": false, "allow_ownership_transfer": false}';
        req.setBody(jsonString);
        HttpResponse response;
        response =  http.send(req);
        
    }
}