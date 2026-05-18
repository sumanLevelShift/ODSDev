public with sharing class ODS_StatusReportNotificationProcessor extends ODS_NotificationProcessor implements INotificationProcessor{
    private Status_Report__c statusReportRecord;

    public ODS_StatusReportNotificationProcessor(ID recordId, String notificationName){
        super(recordId, notificationName);
    }

    @TestVisible
    protected override string processTemplate(){
        string message = getMessageTemplate();  
        string statusReportUrl = Label.ODS_SiteURL + '/apex/ODS_StatusReport_Mobile';
        message = message.replace('@@URL||', statusReportUrl);
        DateTime statusDateTime = datetime.newInstance(statusReportRecord.Status_Date__c.year(), statusReportRecord.Status_Date__c.month(), statusReportRecord.Status_Date__c.day());
        message = message.replace('@@ReportDate||', statusDateTime.format('MM/dd/yyyy'));
        return message;
    }
    
    @TestVisible
    protected override void getNotificationDataRecord(){
        if(Schema.SObjectType.Status_Report__c.isAccessible()){
            statusReportRecord = [Select Id, Account_Services__c, Status_Date__c From Status_Report__c 
                                  WHERE Id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
        }
        else
        {
            statusReportRecord = new Status_Report__c();
        }
    }
    
    @TestVisible
    protected override Set<String> getRecipients(){
        Set<String> recipientIds = new Set<String>();        
        Set<Id> contactSet = new Set<Id>();
        List<User> userList = new List<User>();
        string accountId; 
        string serviceId;
        List<Account_Services__c > accServiceLst = new List<Account_Services__c >();  
        accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(statusReportRecord.Account_Services__c);
        if(accServiceLst.size() > 0){
           accountId = accServiceLst[0].Account__c;
           serviceId = accServiceLst[0].ODS_Services__c;
        }
        List<Contact_Account_Service__c> contacts = [SELECT Contact__c From Contact_Account_Service__c WHERE Account__c =: accountId 
                                        AND ODS_Service__c =: serviceId AND Is_Approver__c  = true];
        for(Contact_Account_Service__c statusReportContact : contacts)
        {
            contactSet.add(statusReportContact.Contact__c);
        }
        
        userList = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactSet];
        if (userList.size() > 0)
        {
            for(User recipientUser : userList){
                recipientIds.add(recipientUser.Id);
            } 
        }
        return recipientIds;
    }
    
    private void processNotificationTitle(){
        string title = getNotificationTitle();
        /* update the date parameter to status report date */
        DateTime statusDateTime = datetime.newInstance(statusReportRecord.Status_Date__c.year(), statusReportRecord.Status_Date__c.month(), statusReportRecord.Status_Date__c.day());
        title = title.replace('@@ReportDate||', statusDateTime.format('MM/dd/yyyy'));
        updateNotificationTitle(title);
    }

    public void processNotificationRequest(){
        init();        
        processNotificationTitle();
        processNotificationRequest(statusReportRecord.Account_Services__c);
    }
}