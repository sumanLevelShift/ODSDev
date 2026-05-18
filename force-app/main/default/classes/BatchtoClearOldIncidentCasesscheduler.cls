global  class BatchtoClearOldIncidentCasesscheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchtoClearOldIncidentCases oldIncident = new BatchtoClearOldIncidentCases();
        Database.executeBatch(oldIncident);
    }
}