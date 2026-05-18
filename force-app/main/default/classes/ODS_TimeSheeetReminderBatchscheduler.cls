global class ODS_TimeSheeetReminderBatchscheduler implements Schedulable
{
    public void execute(System.SchedulableContext sc)
    {
        ODS_TimeSheeetReminderBatch TimesheetBatch = new ODS_TimeSheeetReminderBatch();
        Database.executeBatch(TimesheetBatch);
    }
}