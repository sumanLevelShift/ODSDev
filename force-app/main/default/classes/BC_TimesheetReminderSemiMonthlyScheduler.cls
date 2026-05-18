global class BC_TimesheetReminderSemiMonthlyScheduler implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BC_TimesheetReminderBatch('Semi-Monthly'));
    }
}