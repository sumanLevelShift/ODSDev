public class SendStatusNotification {
    
    @InvocableMethod
    public static void sendNotification(List<NotifyRequest> notifyRequest)
    {
        System.debug('SendStatusNotification::sendNotification');
        if(notifyRequest.size() > 0){
            switch on (notifyRequest[0].odsNotificationCategory){
                when 'Initiative'{
                    System.debug('SendStatusNotification::sendNotification::Initiative');
                    INotificationProcessor notification = new ODS_InitiativeNotificationProcessor(notifyRequest[0].recordId, notifyRequest[0].odsCustomNotificationName);
                    notification.processNotificationRequest();
                }
                when 'Timesheet'{
                    System.debug('SendStatusNotification::sendNotification::Timesheet');
                    INotificationProcessor notification = new ODS_TimesheetNotificationProcessor(notifyRequest[0].recordId, notifyRequest[0].odsCustomNotificationName);
                    notification.processNotificationRequest();
                }
                when 'DailyStatusReport'{
                    System.debug('SendStatusNotification::sendNotification::DailyStatusReport');
                    INotificationProcessor notification = new ODS_StatusReportNotificationProcessor(notifyRequest[0].recordId, notifyRequest[0].odsCustomNotificationName);
                    notification.processNotificationRequest();
                }
                when else{
                    return;
                }
            }
        }
    }
    
    public class NotifyRequest{    
        @InvocableVariable
        public String recordId;

        @InvocableVariable
        /* Initiative, Timesheet, StatusReport, Invoice */
        public String odsNotificationCategory;
        
        @InvocableVariable
        /* Defined in ODS Custom Notification Custom Metadata Type */
        public String odsCustomNotificationName;
    } 

}