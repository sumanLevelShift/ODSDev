public class InitiativeOpportunityBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query to fetch Initiatives based on status
        String query = 'SELECT Id, Name, Account_Name__c, Probable_End_Date__c, Brief_Description__c, Status__c FROM Initiatives__c WHERE Status__c IN (\'Initiative Submitted\', \'Initiative Approved\')';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Initiatives__c> scope) {
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();

        // Fetch the 'ODS Initiative' record type ID
        String recordTypeName = 'ODS Initiative';
        RecordType odsInitiativeRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = :recordTypeName LIMIT 1];
        
        for (Initiatives__c initiative : scope) {
            Opportunity opp = new Opportunity();
           // opp.AccountId = initiative.AccountId;
            opp.RecordTypeId = odsInitiativeRecordType.Id;
            opp.Name = initiative.Name;
            opp.CloseDate = initiative.Probable_End_Date__c;
            opp.Description = String.isBlank(initiative.Brief_Description__c) ? 'yet' : initiative.Brief_Description__c;
            if (initiative.Status__c == 'Initiative Submitted') {
                opp.StageName = 'Proposal/SOW';
            } else if (initiative.Status__c == 'Initiative Approved') {
                opp.StageName = 'Closed Won';
            }
            opportunitiesToInsert.add(opp);
        }

        // Insert the new opportunities
        if (!opportunitiesToInsert.isEmpty()) {
            try {
                insert opportunitiesToInsert;
            } catch (DmlException e) {
                // Handle DML exceptions
                System.debug('Error creating opportunities: ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Any post-processing logic goes here
    }
}