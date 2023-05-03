public without sharing class NewCheckInController {
    @AuraEnabled
    public static String createCheckIn(buildertek__Check_In__c record, List<String> fileIds) {
        try {
            buildertek__Check_In__c checkInRecord = new buildertek__Check_In__c(
                Name = record.name,
                buildertek__Notes__c = record.buildertek__Notes__c,
                buildertek__Days_Lost__c = record.buildertek__Days_Lost__c,
                buildertek__Project__c = record.buildertek__Project__c,
                buildertek__Reporting_Location__c = record.buildertek__Reporting_Location__c,
                buildertek__Weather__c = record.buildertek__Weather__c
            );
            insert checkInRecord;

            List<ContentVersion> cvs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: fileIds];

            List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
            for (ContentVersion cv : cvs) {
                cdl.add(new ContentDocumentLink( ContentDocumentId = cv.ContentDocumentId , LinkedEntityId = checkInRecord.Id, ShareType = 'V' ) );
            }
            insert cdl;

            return checkInRecord.Id;
        } catch (Exception e) {
            System.debug('In the catch block of createCheckIn ==>');
            System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
            System.debug(e);
            return null;
        }
    }
    @AuraEnabled
    public static void deleteContentVersion(List<String> documentId){
        try {
            delete [SELECT Id FROM ContentDocument WHERE ID IN: documentId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}