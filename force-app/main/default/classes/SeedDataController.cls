public with sharing class SeedDataController {
    @AuraEnabled
    public static void seed() {
        // Contacts
        List<Contact> toUpsert = new List<Contact>();
        Map<String, Contact> emailToContact = new Map<String, Contact>();
        for (String email : new List<String>{ 'citizen.one@example.org', 'citizen.two@example.org' }) {
            emailToContact.put(email, new Contact(LastName=email.substringBefore('@'), Email=email));
        }
        upsert emailToContact.values() Contact.Fields.Email;

        // Routes by code
        Map<String, Id> codeToRouteId = new Map<String, Id>();
        for (Route__c r : [SELECT Id, RouteCode__c FROM Route__c WHERE RouteCode__c IN ('R-001','R-002')]) {
            codeToRouteId.put(r.RouteCode__c, r.Id);
        }

        // Schedules
        Contact c1 = [SELECT Id FROM Contact WHERE Email = 'citizen.one@example.org' LIMIT 1];
        Contact c2 = [SELECT Id FROM Contact WHERE Email = 'citizen.two@example.org' LIMIT 1];

        List<WasteCollectionSchedule__c> schedules = new List<WasteCollectionSchedule__c>{
            new WasteCollectionSchedule__c(
                Citizen__c = c1.Id,
                ScheduleDate__c = Date.today().addDays(2),
                CollectionType__c = 'Recycling',
                Frequency__c = 'Weekly',
                Status__c = 'Active',
                ServiceWindow__c = '07:00-09:00',
                Street__c = '100 Main St', City__c = 'Springfield', Zip_Code__c = '99999',
                Route__c = codeToRouteId.get('R-001')
            ),
            new WasteCollectionSchedule__c(
                Citizen__c = c2.Id,
                ScheduleDate__c = Date.today().addDays(3),
                CollectionType__c = 'Garbage',
                Frequency__c = 'Weekly',
                Status__c = 'Active',
                ServiceWindow__c = '09:00-11:00',
                Street__c = '200 Oak Ave', City__c = 'Springfield', Zip_Code__c = '99999',
                Route__c = codeToRouteId.get('R-002')
            )
        };
        insert schedules;

        insert new MissedPickupReport__c(
            Schedule__c = schedules[0].Id,
            Reason__c = 'Truck missed our street',
            Location__c = '100 Main St'
        );
    }
}