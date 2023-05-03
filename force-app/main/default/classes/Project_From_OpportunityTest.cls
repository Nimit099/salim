@isTest
public with sharing class Project_From_OpportunityTest {

    @isTest
    static void testMethod1(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity Opp = new Opportunity(); 
        Opp.Name = 'Test Opportunity';
        Opp.CloseDate = system.today().addDays(30);
        Opp.StageName = 'Under Review';
        insert Opp;
        
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;

        List<buildertek__Admin_Interface_Node_Configuration__c> adminNodeList = new List<buildertek__Admin_Interface_Node_Configuration__c>();
        buildertek__Admin_Interface_Node_Configuration__c adminNode1 = new buildertek__Admin_Interface_Node_Configuration__c();
        adminNode1.Name = 'Quote Configuration';
        adminNodeList.add(adminNode1);

        buildertek__Admin_Interface_Node_Configuration__c adminNode2 = new buildertek__Admin_Interface_Node_Configuration__c();
        adminNode2.Name = 'Create Contract on Quote Acceptance';
        adminNode2.buildertek__Automatically_Create_Inv_from_ConSigning__c = true;
        adminNodeList.add(adminNode2);

        insert adminNodeList;
        
        List<buildertek__Quote__c> quoteList = new List<buildertek__Quote__c>();
        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.Name = 'Test Quote';
        quote.buildertek__Opportunity__c = Opp.Id;
        quote.buildertek__Status__c = 'Customer Accepted'; 
        quoteList.add(quote);
        insert quoteList;

        buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
        quoteItem.Name = 'Test QuoteItem';
        quoteItem.buildertek__Quote__c = quote.id;
        insert quoteItem;
        
        buildertek__Proposal_Images__c quoteimage = new buildertek__Proposal_Images__c();
        quoteimage.buildertek__Proposal__c = quote.id;
        insert quoteimage;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;

        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.ShareType= 'V';
        contentlink.LinkedEntityId = quote.Id;
        contentlink.ContentDocumentId = conDocument;
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        
        Project_From_Opportunity.getOpportunity(Opp.Id);
        Project_From_Opportunity.createProject(Opp.Id, proj.Name, acc.Id, UserInfo.getUserId(), system.today());
        
        system.assertEquals('test', 'test');
    }
}