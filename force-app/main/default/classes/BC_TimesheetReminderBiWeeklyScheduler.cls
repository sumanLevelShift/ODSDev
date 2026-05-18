global class BC_TimesheetReminderBiWeeklyScheduler implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BC_TimesheetReminderBatch('Bi-Weekly'));
    }
}