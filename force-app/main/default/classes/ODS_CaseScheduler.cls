global class ODS_CaseScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
        ODS_CaseSchedule casesScheduling = new ODS_CaseSchedule();
        Database.executeBatch(casesScheduling);
    }
}