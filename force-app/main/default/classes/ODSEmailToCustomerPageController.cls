public class ODSEmailToCustomerPageController {
    
    public static List<DraftEmail__c> draftEmailList {get; set;}
    public static List<Account_Services__c> accountServiceList {get;set;}
    public static SelectOption[] allCustomers { get; set;}
    public static string currentUserId {get;set;}
    public static DraftEmail__c draftEmail {get; set;}
    public static String savedCustomerIds {get;set;}
    public static Map<Id, Account_Services__c> customersMap {get;set;} 
    public static string draftMailId {get;set;}
    
    
    @AuraEnabled( cacheable = true )
    public static List<Account> getAccountList()
    {     
        set<id> accountId=new set<id>();
        List<SelectOption> customersList = new  list<SelectOption>();
        
        ODS_Common_Utility objUtility = new  ODS_Common_Utility();
        customersList = objUtility.getCustomersByLoggedInUser('');        
        if(customersList != null && customersList.size() > 0){
            for(SelectOption accountService: customersList) {      
                If(accountService.getValue() != 'All'){
                    accountId.add(accountService.getValue());
                }
            }
        }
        List<Account> accountList=[Select Id,Name From Account Where Id IN:accountId ORDER BY Name ASC NULLS FIRST ];
        return accountList;
    }
    
    @AuraEnabled( cacheable = true )
    public static List<DraftEmail__c> getDraftEmails(string currId){
        system.debug('here');
        currentUserId = currId;
        draftEmailList = new List<DraftEmail__c>();
        draftEmailList = [SELECT Id, Name, CustomerIds__c, EmailBody__c, EmailSubject__c, EmailStatus__c, OwnerId, DocumentIds__c,CreatedDate,LastModifiedDate FROM DraftEmail__c WHERE OwnerId =: currentUserId AND IsDeleted__c = false ORDER BY CreatedDate DESC];
        // draftEmailList = database.query(fetchEmailQuery); 
        
        return draftEmailList;
        
    } 
    
    @AuraEnabled
    public static Integer saveDraftEmail(string draftEmailSubject, string draftEmailBody, List<string> selectedCustomers){
        
        draftEmail = new DraftEmail__c();
        System.debug('Here : '+ draftEmailSubject + draftEmailBody+ selectedCustomers );
        try{  
                if(draftEmailSubject != null && draftEmailBody != null && !selectedCustomers.isEmpty() && selectedCustomers!= null){ 
                    
                    draftEmail.EmailSubject__c = draftEmailSubject;
                    draftEmail.EmailBody__c = draftEmailBody;
                    draftEmail.CustomerIds__c = selectedCustomers.toString();
                    System.debug('Here : '+ draftEmailSubject + draftEmailBody+ selectedCustomers );
                    draftEmail.EmailStatus__c = 'Draft';
                    system.debug('Value b4 : '+ draftEmail);
                    insert draftEmail;
                    system.debug('Inside SaveDraft : '+ draftEmail);
                   
                } 
             return 1;
        }
        Catch(Exception e)
        {
            System.debug('Error Occured::: ' + e);
           	return 0;
        } 
    }
    
    //Delete a record of Drafted Email
    @AuraEnabled
    public static void deleteDraftEmail(string draftEmailId){ 	
        system.debug('In delete: '+ draftEmailId);
        DraftEmail__c draftEmailObj = new DraftEmail__c();
        try{
            	if(draftEmailId != null && String.isNotBlank(draftEmailId)){
            		draftEmailObj  = [Select Id,IsDeleted__c From DraftEmail__c where Id=:draftEmailId Limit 1];
            		if(draftEmailObj != null){
                		delete draftEmailObj;                    
            		} 
       			}
        }
        Catch(Exception e)
        {
            System.debug('Error Occured::: ' + e);
           
        } 
        
        
    }
    
    
    public static Boolean listContains(Object[] source, Object target){
        return (new Set<Object>(source)).contains(target);
    }
    
    public static Map<Id, Account_Services__c> getCustomers(){   
        
        List<SelectOption> customersList = new list<SelectOption>();
        ODS_Common_Utility objUtility = new ODS_Common_Utility();
        accountServiceList = new LIST<Account_Services__c>(); 
        allCustomers = new List<SelectOption>();
        customersList = objUtility.getCustomersByLoggedInUser('');        
        if(customersList != null && customersList.size() > 0){
            for(SelectOption accountService: customersList) {                 
                If(accountService.getValue() != 'All' && !listContains(allCustomers, new SelectOption(accountService.getValue(), accountService.getLabel()))){                   
                    allCustomers.add(new SelectOption(accountService.getValue(), accountService.getLabel()));
                }
            }
        }
        string fetchSrvceQuery = 'SELECT Account__c, Account__r.Name, Contract_End_Date__c, ODS_Services__c, ODS_Services__r.Name__c, '+
            ' Technical_Account_manager__r.Email,Backup_CSM__r.Email,Customer_Success_Executive__r.Email, Account__r.Primary_Customer_Email_Id__c, Technical_Account_manager__c FROM Account_Services__c WHERE Account__r.Is_Portal_Access__c = true AND Account__r.Count_of_Services__c > 0 ORDER BY Account__r.Name ASC ';
        accountServiceList = database.query(fetchSrvceQuery);
        customersMap = new Map<Id, Account_Services__c>();
        for(Account_Services__c accountService : accountServiceList)
        {
            customersMap.put(accountService.Account__c, accountService);
        }       
        return customersMap;
    }
    
    
    @AuraEnabled( cacheable = true )
    public static void sendEmails(string draftEmailSubject, string draftEmailBody, List<string> selectedCustomers){
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();  
        system.debug('selectedCustomers : '+selectedCustomers);
        Set<Id> arraySavedCustomers = new Set<Id>(); 
        if(selectedCustomers != null && !selectedCustomers.isEmpty()){
            
            for(String str : selectedCustomers){
                arraySavedCustomers.add(Id.valueOf(str));
            }
            system.debug('arraySavedCustomers: '+arraySavedCustomers);
        }
        
        
        Map<Id, Account_Services__c> customersMap1 = new Map<Id, Account_Services__c>();
        customersMap1 = getCustomers();
        system.debug('Map key: '+ customersMap1.keySet());
        system.debug('Map Values : '+customersMap1.values());
        
        system.debug('customersMap1 : '+customersMap1 );
        for(Id strCustomerId : arraySavedCustomers){
            system.debug('strCustomerId : '+strCustomerId);
            if(customersMap1.containsKey(strCustomerId))
            {
                Account_Services__c accountServiceEmail = new Account_Services__c();
                accountServiceEmail = customersMap1.get(strCustomerId);
                system.debug('accountServiceEmail : '+accountServiceEmail );
                system.debug('accountServiceEmail.Account__r.Primary_Customer_Email_Id__c : '+accountServiceEmail.Account__r.Primary_Customer_Email_Id__c );
                system.debug('draftEmailSubject : '+ draftEmailSubject );
                system.debug('draftEmailBody : '+ draftEmailBody );
                if(accountServiceEmail.Account__r.Primary_Customer_Email_Id__c != null && String.IsNotBlank(draftEmailSubject) && String.IsNotBlank(draftEmailBody)){
                    List<String> toEmailAddress = new List<String>{accountServiceEmail.Account__r.Primary_Customer_Email_Id__c}; 
                        system.debug('accountServiceEmail.Technical_Account_manager__r.Email : '+ accountServiceEmail.Technical_Account_manager__r.Email );
                    if(accountServiceEmail.Technical_Account_manager__r.Email != null){
                        List<String> CsmAndBcsmEmailAddress = new List<String>();
                        CsmAndBcsmEmailAddress.add(accountServiceEmail.Technical_Account_manager__r.Email);  
                        system.debug('accountServiceEmail.Backup_CSM__r.Email '+ accountServiceEmail.Backup_CSM__r.Email );
                        if(accountServiceEmail.Backup_CSM__r.Email != null)
                            CsmAndBcsmEmailAddress.add(accountServiceEmail.Backup_CSM__r.Email);
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email = getSendEmail(toEmailAddress, CsmAndBcsmEmailAddress,draftEmailSubject,draftEmailBody,'a288G0000008SYFQA2');
                        system.debug('toEmailAddress '+ toEmailAddress);
                        system.debug('CsmAndBcsmEmailAddress '+ CsmAndBcsmEmailAddress);
                        
                        emailList.add(email);
                    }                     
                }
            }
        }
        if(!emailList.isEmpty()){
            system.debug('Here To send the mail');
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emailList);
            
        }                
    } 
    
    //To Send the Customer email
    public static Messaging.SingleEmailMessage getSendEmail(List<String> ToEmailAddress,List<String> CcEmailAddress, String EmailSubject,String EmailBody,String DocumentIds){
        System.debug('ToEmailAddress ===> '+ToEmailAddress);
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
            
            mail.setToAddresses(ToEmailAddress);
            mail.setCcAddresses(CcEmailAddress); 
            mail.setSenderDisplayName(UserInfo.getName());
            system.debug('UserInfo.getName()'+UserInfo.getName());
            
            Messaging.EmailFileAttachment attachmentOne = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment attachmentTwo = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment[] emailFileAttachments = new Messaging.EmailFileAttachment[]{};
                
                mail.setSubject(EmailSubject);
            mail.setHtmlBody(EmailBody);            
            
            return mail;
        }
        Catch(Exception mailException)
        {
            System.debug('Error Occured::: ' + mailException);
            return null;
        }      
    } 
    
    
    @AuraEnabled( cacheable = true )
    public static DraftData clickOnDraft(string draftEmailId){
        DraftEmail__c draftEmailToSend = new DraftEmail__c();
        draftEmailToSend = [SELECT Id, Name, CustomerIds__c, EmailBody__c, EmailSubject__c FROM DraftEmail__c WHERE Id =: draftEmailId limit 1];
        system.debug('in draft email return : '+ draftEmailToSend);
        string lstCustomer = getCustomerNames(draftEmailToSend.CustomerIds__c);
        system.debug('lstCustomer : '+lstCustomer);
        String[] customersArray = lstCustomer.split('#');
        system.debug('customersArray : '+customersArray);
        
        DraftData dataToSend = new DraftData();
        dataToSend.Id=draftEmailToSend.id;
        if(!customersArray.isEmpty()){
            dataToSend.customerNames = customersArray[0];
            List<String> savedCustomers1 = customersArray[1].split(',');
            system.debug('savedCustomers1 : '+savedCustomers1);
            dataToSend.savedCustomers = savedCustomers1;
        }else{
            dataToSend.customerNames = null;
            dataToSend.savedCustomers = null;
            
        }
        dataToSend.emailSub = draftEmailToSend.EmailSubject__c;
        dataToSend.emailBody = draftEmailToSend.EmailBody__c;
        system.debug('dataToSend : '+ dataToSend);
        return dataToSend;
    } 
    
    //To show the recipient names  
    public static string getCustomerNames(String SelectedCustomerIds){
        String strCustomerNames = '';
        String strCustomerIds = '';
        Boolean first = true;
        if(string.isNotBlank(SelectedCustomerIds)){
            string customerIds = SelectedCustomerIds.deleteWhitespace().replace('(', '').replace(')','');
            List<String> listCustomerIds = customerIds.split(',');
            system.debug('listCustomerIds : '+listCustomerIds);
            for(Account_Services__c account : [SELECT Account__c, Account__r.Name FROM Account_Services__c WHERE Account__c IN:listCustomerIds ORDER BY Account__r.Name ASC]){
                if (!first) {
                    strCustomerNames += ', ';
                    strCustomerIds += ',';
                    
                }
                strCustomerNames += account.Account__r.Name;
                strCustomerIds += account.Account__c;
                first = false;
                
            }
        }
        system.debug('strCustomerNames | strCustomerIds:'+ strCustomerNames + '#' + strCustomerIds);
        return strCustomerNames + '#' + strCustomerIds;
        
    }
    
    @AuraEnabled(Cacheable=false)
    public static void updateSessionData(string accountId,string serviceId){
        ODS_Common_Utility.upsertSessionData(accountId,serviceId);  
    }
    
    
    public class DraftData{ 
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string customerNames{get;set;}
        @AuraEnabled
        public List<string> savedCustomers{get;set;}
        @AuraEnabled
        public string emailSub{get;set;}
        @AuraEnabled
        public string emailBody{get;set;}
    }
    
    
}