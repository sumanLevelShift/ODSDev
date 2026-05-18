public without sharing class ODS_NotificationService{
    private String title;
    private String message;    
    private String targetId;
    private String accountServiceId;    
    private String notificationName;
    
    public ODS_NotificationService(NotificationServiceRequest notificationServiceRequest){
        this.title = notificationServiceRequest.title;
        this.message = notificationServiceRequest.message;
        this.notificationName = notificationServiceRequest.notificationName;
        this.accountServiceId = notificationServiceRequest.accountServiceId;
    }
    
    private Boolean createNotificationRecord(){
        if(Schema.sObjectType.App_Notification__c.isCreateable()){
            App_Notification__c appNotify = new App_Notification__c();
            appNotify.Name = notificationName;
            appNotify.Title__c = title;
            appNotify.Message__c = message;
            if(String.isNotBlank(accountServiceId)){
                appNotify.Account_Services__c = Id.valueOf(accountServiceId);        
            }
            insert appNotify;            
            targetId = appNotify.Id;
            return true;
        }
        else {
            return false;
        }
    }

    public void notifyUsers(String notificationTypeId, Set<String> recipientIds){        
        System.debug('ODS_NotificationService::notifyUsers');
        if(createNotificationRecord()){            
            /* passing notification type as notification title and title as notification body */
            ODS_CustomNotification.NotificationRequest notificationRequest = new ODS_CustomNotification.NotificationRequest();
            notificationRequest.notificationTypeId = notificationTypeId;
            notificationRequest.title = notificationName;
            notificationRequest.message = title;
            notificationRequest.targetId = targetId;
            notificationRequest.targetPageRef = null;
            ODS_CustomNotification.notifyUsers(notificationRequest, recipientIds);
            System.debug('ODS_NotificationService::ODS_CustomNotification.notifyUsers');
        }
    }

    public class NotificationServiceRequest{
        public String notificationName;
        public String title;
        public String message;
        public String accountServiceId;
    }
}