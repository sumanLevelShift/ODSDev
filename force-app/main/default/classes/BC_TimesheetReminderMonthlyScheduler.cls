global class BC_TimesheetReminderMonthlyScheduler implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BC_TimesheetReminderBatch('Monthly'));
    }
}