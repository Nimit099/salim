@isTest
public with sharing class Test_NewCheckInBtnController {
    // public Test_NewCheckInBtnController() {

    // }

    // @testSetup
    // static void setup() {

    // }

    @isTest
    static void testCreateCheckIn() {
        // Create a test Project record  & DropBox foldar

        // buildertek__Project__c Project = new buildertek__Project__c(
        //     Name = 'Test Project',
        //     buildertek__Stage__c = 'Design'
        // );
        String pathURL = '/BLUENEST OFFICE/';
        DropboxToken__c dtoken = new DropboxToken__c(Name='Dropbox Token',AccessToken__c='f6ti8n7fwty348');
        insert dtoken;
        DropboxInfo__c dinfo = new DropboxInfo__c(Name='test',FolderSearchURL__c = 'https://api.dropboxapi.com/2/files/search_v2',ConsumerKey__c='fkuyjregis8',ClientSecret__c='r5tf834638i765384h5',AuthorizationURL__c='tdrfubtretenruyrfyufyhgthf',AccessTokenEndPoint__c='fs7eibtfrcsgnfsdufsejyrfgbe');
        insert dinfo;
        DropBoxMapping__c dr = new DropBoxMapping__c(Name='Newly Purchased',Folder_Path__c = 'Homework/Test');
        insert dr;
        buildertek__Project__c Project = new buildertek__Project__c(Name='test',Dropbox_Path__c=pathURL, Dropbox_Folder__c='Test', buildertek__Stage__c='Newly Purchased');
        insert Project;

        Test.startTest();
        System.debug('Project Id : '+Project.Id);
        Test.setMock(HttpCalloutMock.class, new DropBoxCalloutMock());
        String tokenn = 'sl.fgsjfhdsuyfusyvter45hjkfebf7w34gbkfi82wegkiu7fib7ntciw7trfkg78ewrb';
        String res = DropBoxController.createNewFolder('Test');
        String expected = '{"entries": [{".tag": "folder", "name": "PROJECTS IN PROGRESS", "path_lower": "/bluenest office/projects in progress", "path_display": "/BLUENEST OFFICE/PROJECTS IN PROGRESS", "id": "id:jJ260QfSPK4AAAAAAAABOg"}], "cursor": "AAH86N0z42ukxHq5bdcyMQ4EFjqQKpji00QhovGoOSBsUT0vhc4X8fPV3lCSZSbkz8xd4yaWEmiT2APQVzWA1ltSFFmm3qOFTjA6usFlezi6P60LkYplojNEMBeBbGS2Iu3dz1wOJ1UcM-QhrZpEuhPnC_w7Wr_d03TnPKgATJ2ADwcVXXiJ07EJ2-sSPUxL8QT4ccY8nH1xcAjBnDkV0gGcjr3PQ1F-DZ3KcvKvc24zGw", "has_more": false}' ;
        // DropboxToken__C
        Test.setMock(HttpCalloutMock.class, new DropBoxCalloutMock());
        String recordId = Project.Id;
        String pid = Project.Id;
        String accTok = 'sl.fsgufekusrnbnffdhbjgjdvsbjyurdvfbkgbshvhjsdgfvkusdgfjlr';

        Dropboxcontroller.folderdetails res2 = DropBoxController.getFolderFromDropbox(pid, tokenn);
        String expected2 = '{"entries": [{".tag": "folder", "name": "PROJECTS IN PROGRESS", "path_lower": "/bluenest office/projects in progress", "path_display": "/BLUENEST OFFICE/PROJECTS IN PROGRESS", "id": "id:jJ260QfSPK4AAAAAAAABOg"}], "cursor": "AAHK2-lDJnhi4P0oAp5fNKI4AI7rexZCkr2_YhtP0HSgzidlhlRxcx6PtiFTm2u4bcGJ3GdrCAjJG6VWdCEbvVXCnC7DFY-vc2G55xtnbbfcGcx2u5KSBATwwAKXiXO-qAEnitYfa7qx_cj1L3BBsKKN1BnVnjGZeP9mmYD3aa5u18ySc9gUvqL3cx0TYX5N_N-BoazzZWM-VJWSU1oZsdL2uxf4HNK3MUA3GFsx4y1Vkw", "has_more": false}' ;
        
        String tokenresult = DropboxController.tokenExpired();

        Map<String,Object> subfolder = DropboxController.createNewSubFolder('Testsub');

        List<DropboxController.folderItems> getfolder = DropboxController.getFolderDetails('Test', 'dfuyt7bt3nwktfg7ikcr');

        String download = DropboxController.downloadFileFromDropBox_V1('/fd8enrgbkes78grn');

        String Upload = DropboxController.uploadFile(pathURL, 'dsk8eryns7cgf348tdgfeks');

        DropboxController.folderdetails getfolder2 = DropboxController.getFolderFromDropbox_11(Project.Id, 'Testsub', 'Test', 'dkfygfcbsrufnistref');

        ProjectTriggerHandler.moveFolderGeneric('/Homework/Test', '/Homework/Test2');
        
        DropboxFutureToken.generatetoken();
        Test.stopTest();
        // Insert the test Project record
        // insert Project;

        // Create a test Check-In record
        buildertek__Check_In__c checkIn = new buildertek__Check_In__c(
            Name = 'Test Check-In',
            buildertek__Notes__c = 'This is a test check-in',
            buildertek__Days_Lost__c = 0,
            buildertek__Project__c = Project.Id,
            buildertek__Reporting_Location__c = 'Onsite',
            buildertek__Weather__c = 'Sunny',
            buildertek__Date_Created__c = Date.today()
        );

        // Insert the test Check-In record
        insert checkIn;
        
        // Create a test ContentDocumentLink
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Tile';
        cv.VersionData = Blob.valueOf('Test Content');
        // cv.FirstPublishLocationId = checkIn.Id;
        cv.PathOnClient = 'test.png';
        insert cv;
        System.debug('cv Id : '+cv.Id);

        // ContentDocument contentDocument = [
        //     SELECT Id 
        //     FROM ContentDocument 
        //     WHERE Id = :cv.ContentDocumentId
        // ];
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        System.debug('CondocId : '+ConDocId);

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = conDocId,
            LinkedEntityId = checkIn.Id,
            ShareType = 'V'
        );
        // ContentDocumentLink cdl = New ContentDocumentLink();
        // cdl.LinkedEntityId = checkIn.Id;
        // cdl.ContentDocumentId = conDocId;
        // cdl.shareType = 'V';
        // Insert cdl;
        insert contentDocumentLink;
        
        // Call the createCheckIn method
        List<String> fileIds = new List<String>{ contentDocumentLink.ContentDocumentId };
        String checkInId = NewCheckInBtnController.createCheckIn(checkIn, fileIds);
        
        // Verify that the check-in was created
        System.assertNotEquals(null, checkInId);
        buildertek__Check_In__c checkInResult = [
            SELECT Id, Name, buildertek__Notes__c, buildertek__Days_Lost__c,
                   buildertek__Project__c, buildertek__Reporting_Location__c,
                   buildertek__Weather__c, buildertek__Date_Created__c
            FROM buildertek__Check_In__c
            WHERE Id = :checkInId
        ];
        System.assertEquals(checkIn.Name, checkInResult.Name);
        System.assertEquals(checkIn.buildertek__Notes__c, checkInResult.buildertek__Notes__c);
        System.assertEquals(checkIn.buildertek__Days_Lost__c, checkInResult.buildertek__Days_Lost__c);
        System.assertEquals(checkIn.buildertek__Project__c, checkInResult.buildertek__Project__c);
        System.assertEquals(checkIn.buildertek__Reporting_Location__c, checkInResult.buildertek__Reporting_Location__c);
        System.assertEquals(checkIn.buildertek__Weather__c, checkInResult.buildertek__Weather__c);
        System.assertEquals(checkIn.buildertek__Date_Created__c, checkInResult.buildertek__Date_Created__c);
        
        // Verify that the ContentDocumentLink was created
        System.debug('checkIN Id : '+checkIn.Id);
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId, LinkedEntityId, ShareType
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :checkIn.Id
        ];
        System.debug('Con Link Id :'+contentDocumentLinks.size());
        System.assertEquals(1, contentDocumentLinks.size());
        System.assertEquals(contentDocumentLink.ContentDocumentId, contentDocumentLinks[0].ContentDocumentId);
        System.assertEquals(contentDocumentLink.LinkedEntityId, contentDocumentLinks[0].LinkedEntityId);
        System.assertEquals(contentDocumentLink.ShareType, contentDocumentLinks[0].ShareType);
    }

    @isTest
    static void testdeleteContentVersion() {

        Account acc = new Account(name='Test Account');
        insert acc;
         // Create test data
        ContentVersion cv = new ContentVersion(
            Title = 'Test Content',
            PathOnClient = 'Test Content.txt',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv;
        System.debug('cv Id : '+cv.Id);

        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        System.debug('CondocId : '+ConDocId);

        // Share the test content version with a user
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = conDocId,
            // LinkedEntityId = UserInfo.getUserId(),
            LinkedEntityId = acc.Id,
            ShareType = 'V'
        );
        insert cdl;
        System.debug('cdl Id : '+cdl.Id);

        // ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id = :cdl.ContentDocumentId];

        // ContentDocumentLink cdl = new ContentDocumentLink(
        //     ContentDocumentId = conDocId,
        //     LinkedEntityId = UserInfo.getUserId(),
        //     ShareType = 'V'
        // );
        // insert cdl;
        // System.debug('Con doc Id : '+cdl.Id);

        Test.startTest();

        // Call the method with the test content version Id
        List<String> documentId = new List<String>{cdl.ContentDocumentId};
        System.debug('doc id list : '+documentId);
        NewCheckInBtnController.deleteContentVersion(documentId);

        Test.stopTest();

        // Verify that the content version is deleted
        List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id = :[SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId];
        System.debug('cdList : '+cdList);
        System.assertEquals(0, cdList.size(), 'Expected content document to be deleted');
    }
}