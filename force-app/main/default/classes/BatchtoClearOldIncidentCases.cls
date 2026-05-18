global class BatchtoClearOldIncidentCases implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        string old = Label.Incident_Case_Owner;
     system.debug('old'+old);
         Group grp =[SELECT Id,Name,DeveloperName  FROM Group WHERE Name  =:old];
        Id grpId = grp.Id ;
        String SOQL = 'SELECT CaseNumber,CreatedDate,Id,OwnerId,Status,Subject,Type,Owner.Name FROM Case Where OwnerId  =:grpId And CreatedDate < LAST_N_DAYS:180';
               return Database.getQueryLocator(SOQL);
        
    }
    global void execute(Database.BatchableContext bc, List <Case> listIncidentCase) {
        system.debug('listIncidentCase'+listIncidentCase);
        delete listIncidentCase;
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}