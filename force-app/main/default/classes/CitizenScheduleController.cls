public with sharing class CitizenScheduleController {
    @AuraEnabled(cacheable=true)
    public static List<WasteCollectionSchedule__c> getMySchedules() {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        if (contactId == null) return new List<WasteCollectionSchedule__c>();
        return [
            SELECT Id, ScheduleDate__c, CollectionType__c, Frequency__c, ServiceWindow__c, Status__c, Route__c
            FROM WasteCollectionSchedule__c
            WHERE Citizen__c = :contactId AND Status__c = 'Active'
            ORDER BY ScheduleDate__c ASC
            LIMIT 200
        ];
    }
}