public without sharing class NewCheckInController {
    @AuraEnabled
    public static String createCheckIn(buildertek__Check_In__c record) {
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
            return checkInRecord.Id;
        } catch (Exception e) {
            System.debug('In the catch block of createCheckIn ==>');
            System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
            System.debug(e);
            return null;
        }
    }
}