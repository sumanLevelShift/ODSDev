public abstract without sharing class ODS_NotificationProcessor{
    @TestVisible
    protected String recordId {get; private set;}

    @TestVisible 
    private List<ODS_Custom_Notification__mdt> customNotification;
    @TestVisible
    private String customNotificationName {get; private set;}
    @TestVisible
    private Set<String> recipientIds;    
    @TestVisible
    private String notificationMessage;
    @TestVisible
    private String notificationTitle;
    @TestVisible
    private ODS_NotificationService notificationService;

    @TestVisible
    protected ODS_NotificationProcessor(String recordId, String odsCustomNotificationName){
        this.recordId = recordId;
        this.customNotificationName = odsCustomNotificationName;
    }

    @TestVisible
    protected String getMessageTemplate(){
        if(customNotification != null && customNotification.size() >0){
            return customNotification[0].Message__c;
        }
        return '';
    }
 
    @TestVisible
    protected String getNotificationTitle(){
        if(customNotification != null && customNotification.size() >0){
            notificationTitle = customNotification[0].Title__c;
            return customNotification[0].Title__c;
        }
        return '';
    }
    
    @TestVisible
    protected void updateNotificationTitle(String title){
        notificationTitle = title;
    }    
 
    @TestVisible
    private void getNotificationTemplate(){
        if(Schema.sObjectType.ODS_Custom_Notification__mdt.isAccessible()){
            customNotification = [SELECT DeveloperName, Custom_Notification_Type__c, Custom_Notification_Type_Id__c, Message__c, Notification_Name__c, Title__c 
            FROM ODS_Custom_Notification__mdt WHERE DeveloperName =:customNotificationName];    
        }
    }
    
    @TestVisible
    protected abstract string processTemplate();
    
    @TestVisible
    protected abstract void getNotificationDataRecord();
    
    @TestVisible
    protected abstract Set<String> getRecipients();

    @TestVisible
    protected void processNotificationRequest(String accountServiceId){
        processNotification(accountServiceId);
    }

    @TestVisible
    protected void init(){
        getNotificationTemplate();
        getNotificationTitle();
        if(customNotification != null && customNotification.size() >0 && String.isNotBlank(customNotification[0].Notification_Name__c)){
            getNotificationDataRecord();
        }
    }
    
    @TestVisible
    private void processNotification(String accountServiceId){
        try {
            System.debug('NotificationProcessor::processNotification');
            if(customNotification != null && customNotification.size() >0 && String.isNotBlank(customNotification[0].Notification_Name__c)){
                notificationMessage = processTemplate();
                recipientIds = getRecipients();
                if(recipientIds !=null && recipientIds.size() > 0){
                    ODS_NotificationService.NotificationServiceRequest notificationServiceRequest = new ODS_NotificationService.NotificationServiceRequest();
                    notificationServiceRequest.notificationName = customNotification[0].Notification_Name__c;
                    notificationServiceRequest.title = notificationTitle;
                    notificationServiceRequest.message = notificationMessage;
                    notificationServiceRequest.accountServiceId = accountServiceId;
                    notificationService = new ODS_NotificationService(notificationServiceRequest);
                    notificationService.notifyUsers(customNotification[0].Custom_Notification_Type_Id__c, recipientIds);
                }
                else{
                    System.debug('NotificationProcessor::getRecipients() is empty');
                }
            }else {
                System.debug('NotificationProcessor::customNotification record is invalid for "' + customNotificationName + '"');
            }
        }
        catch (Exception e) {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }        
    }
}