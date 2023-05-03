/*******************************************************
* Name          : createNewProjectBTNController_Test
* Author        : Nitin (MV Clouds)
* Create Date   : 09/11/2022
* UsedBy        : createNewProjectBTNController
*******************************************************/

@isTest
public class createNewProjectBTNController_Test {
    
    @isTest
    public static void test1(){
        
        buildertek__Project__c BtProject = new buildertek__Project__c(
            Name = 'Test Project',
            Folio_Number__c = '87888884'
        );

        Account acc = new Account(
        	Name = 'Test Acc'
        );
        insert acc;
        
        buildertek__Project__c BtProject2 = new buildertek__Project__c(
            Name = 'Test Project1',
            buildertek__Account__c = acc.Id
        );
        
        delete acc;

        createNewProjectBTNController.createProjectRecord(BtProject);
        createNewProjectBTNController.createProjectRecord(BtProject2);
        system.assertEquals('Test Project', BtProject.Name, 'Project Name Matched');
        
    }
}