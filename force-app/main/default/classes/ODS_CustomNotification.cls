public without sharing class ODS_CustomNotification {
    public static void notifyUsers(NotificationRequest notificationRequest, Set<String> recipientIds) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        notification.setTitle(notificationRequest.title);
        notification.setBody(notificationRequest.message);
        notification.setNotificationTypeId(notificationRequest.notificationTypeId);

        if(String.isNotBlank(notificationRequest.targetId)){
            notification.setTargetId(notificationRequest.targetId);
        }

        /*String targetPageRef = '' +
            '{' +
            '       type: \'standard__recordPage\',' +
            '       attributes: {' +
            '           recordId: \'' + targetId + '\',' +
            '           objectApiName: \''+ Id.valueOf(targetId).getSobjectType() + '\',' +
            '           actionName: \'view\'' +
            '       }' +
            '}';*/

        if(String.isNotBlank(notificationRequest.targetPageRef)){
            notification.setTargetPageRef(notificationRequest.targetPageRef);
        }
        
        try {
            notification.send(recipientIds);
            System.debug('ODS_CustomNotification::notifyUsers - Sent.');
        }
        catch (Exception e) {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }     
    }

    public class NotificationRequest{
        public String notificationTypeId;
        public String title;
        public String message;
        public String targetId;
        public String targetPageRef;
    }
}