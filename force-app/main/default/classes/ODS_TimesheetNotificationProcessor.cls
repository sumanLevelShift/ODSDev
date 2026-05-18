public with sharing class ODS_TimesheetNotificationProcessor extends ODS_NotificationProcessor implements INotificationProcessor {
    private Timesheet__c timesheetRecord;
    
    public ODS_TimesheetNotificationProcessor(ID recordId, String notificationName){
        super(recordId, notificationName);
    }
    
    @TestVisible
    protected override string processTemplate(){
        string message = getMessageTemplate();
        string timesheetUrl = Label.ODS_SiteURL + '/apex/ODS_Timesheet_Mobile?id=' +timesheetRecord.Id+ '&AccServiceId=' + timesheetRecord.Account_Services__c + '&Status='+ timesheetRecord.Status__c +'&WeekStart='+timesheetRecord.Week_Start_Date__c;
        /* replace the variables with data */
        DateTime startDateTime = datetime.newInstance(timesheetRecord.Week_Start_Date__c.year(), timesheetRecord.Week_Start_Date__c.month(), timesheetRecord.Week_Start_Date__c.day());
        DateTime endDateTime = datetime.newInstance(timesheetRecord.Week_End_Date__c.year(), timesheetRecord.Week_End_Date__c.month(), timesheetRecord.Week_End_Date__c.day());
        message = message.replace('@@StartDate||', startDateTime.format('MM/dd/yyyy'));
        message = message.replace('@@EndDate||', endDateTime.format('MM/dd/yyyy'));
        message = message.replace('@@URL||', timesheetUrl);
        return message;
    }
    
    @TestVisible
    protected override void getNotificationDataRecord(){
        System.debug('ODS_TimesheetNotificationProcessor::getNotificationDataRecord::RecordID::' + recordId);
        if(Schema.SObjectType.Timesheet__c.isAccessible()){
            /* get the timesheet record */
            timesheetRecord = [Select Id,  Account_Services__c, Week_Start_Date__c, Week_End_Date__c, Status__c FROM 
                               Timesheet__c WHERE Id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
        }else{
            timesheetRecord = new Timesheet__c ();
        }
    }

    @TestVisible
    protected override Set<String> getRecipients(){
        Set<String> recipientIds = new Set<String>();
        /* get recipients */
        Set<Id> contactSet = new Set<Id>();
        List<User> userList = new List<User>();
        string accountId; 
        string serviceId;
        List<Account_Services__c > accServiceLst = new List<Account_Services__c >();  
        accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(timesheetRecord.Account_Services__c);
        if(accServiceLst.size() > 0){
           accountId = accServiceLst[0].Account__c;
           serviceId = accServiceLst[0].ODS_Services__c;
        }
        List<Contact_Account_Service__c> contacts = [SELECT Contact__c From Contact_Account_Service__c WHERE Account__c =: accountId 
                                        AND ODS_Service__c =: serviceId AND Is_Approver__c  = true];
        for(Contact_Account_Service__c timesheetContact : contacts)
        {
            contactSet.add(timesheetContact.Contact__c);
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
   
    public void processNotificationRequest(){
        try{
            init();
            System.debug('ODS_TimesheetNotificationProcessor::processNotificationRequest::' + timesheetRecord);
            processNotificationRequest(timesheetRecord.Account_Services__c);            
        }
        catch (Exception e) {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }
}