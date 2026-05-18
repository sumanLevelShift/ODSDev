public with sharing class ODS_InitiativeNotificationProcessor extends ODS_NotificationProcessor implements INotificationProcessor {
    private Initiatives__c initiativeRecord;
    
    public ODS_InitiativeNotificationProcessor(ID recordId, String notificationName){
        super(recordId, notificationName);
    }
    
    @TestVisible
    protected override string processTemplate(){
        string message = getMessageTemplate();
        message = message.replace('@@InitiativeName||', initiativeRecord.Name);
        String initiativeUrl = Label.ODS_SiteURL+'/apex/ODS_Initiative_Mobile?AccServiceId='+initiativeRecord.Account_Service__c+ '&CurrenInitiativeId='+initiativeRecord.Id;
        message = message.replace('@@URL||', initiativeUrl);
        system.debug('ODS_InitiativeNotificationProcesso::processTemplate::messsage - '+message);        
        return message;
    }
    
    @TestVisible
    protected override void getNotificationDataRecord(){
        System.debug('ODS_InitiativeNotificationProcessor::getNotificationDataRecord::RecordID::' + recordId);
        if(Schema.SObjectType.Initiatives__c.isAccessible()){
            initiativeRecord = [SELECT Id, Name, Account_Service__c, Client_side_Contact__c 
                                            FROM Initiatives__c WHERE Id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
        }else{
            initiativeRecord = new Initiatives__c();
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
        accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(initiativeRecord.Account_Service__c);
        if(accServiceLst.size() > 0){
           accountId = accServiceLst[0].Account__c;
           serviceId = accServiceLst[0].ODS_Services__c;
        }
        List<Contact_Account_Service__c> contacts = [SELECT Contact__c FROM Contact_Account_Service__c WHERE Account__c =: accountId 
                                                     AND ODS_Service__c =: serviceId AND Is_initiate_approver__c  = true 
                                                     AND Contact__c != :initiativeRecord.Client_side_Contact__c];       
        
        if(initiativeRecord.Client_side_Contact__c != null){
            contactSet.add(initiativeRecord.Client_side_Contact__c);
        }
        for(Contact_Account_Service__c initiativeContact : contacts){
            contactSet.add(initiativeContact.Contact__c);
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
            System.debug('ODS_InitiativeNotificationProcessor::processNotificationRequest::' + initiativeRecord);
            processNotificationRequest(initiativeRecord.Account_Service__c);            
        }
        catch (Exception e) {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }
}