/*******************************************************
* Name          : createNewProjectBTNController
* Author        : Nitin (MV Clouds)
* Create Date   : 09/11/2022
* Description   : This Class Used in createNewProjectBTN Aura component 
* TestClass     : createNewProjectBTNController_Test
* Code Coverage : 100%

================================================================================
Change No.          Developer Name              Date                Description     


*******************************************************/

public without sharing class createNewProjectBTNController {
    
    @AuraEnabled
    public static String createProjectRecord (buildertek__Project__c projectRec) {
        try {
            System.debug('NEW RECORD DATA>>>>>> '+projectRec);
            insert projectRec;
            return projectRec.Id;

        } catch (Exception e) {
            System.debug(e);
            System.debug('Line Number ==>'+ e.getLineNumber());
            System.debug('Message ===>'+ e.getMessage() + ' <==>'+ e.getStackTraceString());
            return null;
        }
    }
}