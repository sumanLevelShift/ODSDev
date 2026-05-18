public with sharing class StaffDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<MissedPickupReport__c> getReports() {
        return [SELECT Id, Name, Status__c, ReportDate__c, ResolutionNotes__c FROM MissedPickupReport__c ORDER BY CreatedDate DESC LIMIT 200];
    }

    @AuraEnabled
    public static void assignReport(Id reportId, String status) {
        if (reportId == null) return;
        MissedPickupReport__c m = [SELECT Id, Status__c FROM MissedPickupReport__c WHERE Id = :reportId LIMIT 1 FOR UPDATE];
        if (!String.isBlank(status)) m.Status__c = status; else if (m.Status__c == 'New') m.Status__c = 'InProgress';
        update m;
    }

    @AuraEnabled
    public static List<RouteOptimizer.RouteStop> optimizeSample() {
        List<String> sample = new List<String>{'10 Oak Ave','5 Pine St','25 Elm Rd','1 Maple Ct'};
        return RouteOptimizer.optimizeRoutes(sample);
    }
}