global class ODS_SendReminderOnStatusReportBatchSch implements Schedulable
{
    public void execute(System.SchedulableContext sc)
    {
        ODS_SendReminderOnStatusReportBatch sendReminder = new ODS_SendReminderOnStatusReportBatch();
        Database.executeBatch(sendReminder);
    }
}