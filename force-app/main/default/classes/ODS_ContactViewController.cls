/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       ODS_ContactController
* @description      This class is Controller for ViewContact VF page
*********************************************************************************************
Version     Date            Team            Comments
*********************************************************************************************
* 1         16-MAR-2021     DemandBlue      Initial Development
*********************************************************************************************/
Public Without Sharing class ODS_ContactViewController
{
    
    //public string AccountName {get;set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string AccountServiceID {get;set;} 
    public Contact newContact {get; set;}
    public string CurrentContactId {get;set;}
    public string CurrentAccountId {get;set;}
    //public Staging_Contact_Record__c stagingContactRecord {get;set;}
    public ContactWrapper contactWraper {get;set;}
    public ODS_ContactViewController()
    {
        newContact = new Contact();
        //stagingContactRecord = new Staging_Contact_Record__c();
        //system.debug(stagingContactRecord);
        contactWraper = new ContactWrapper();
        CurrentContactId  = ApexPages.CurrentPage().getParameters().get('CurrentContactId');
        CurrentAccountId  = ApexPages.CurrentPage().getParameters().get('CurrentAccountId');
        if(String.IsNotBlank(CurrentAccountId)){
            //newContact.AccountId = CurrentAccountId;
            contactWraper.AccountId = CurrentAccountId;
        }
        if(String.IsNotBlank(CurrentContactId)){
            newContact = [SELECT Id, FirstName,LastName,Name,Title,ReportsToId,Role_Level__c,Status__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone,MobilePhone,Email,ODS_DotNet_Status__c,isPrimary__c,HasOptedOutOfEmail,Is_Portal_Access__c,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,AccountId FROM Contact WHERE Id =: CurrentContactId];
            bindContactWrapper(newContact);
        }
    }    
    public void GetAccountServices(){
        List<Account_Services__c > accServList = new List<Account_Services__c >();
        accServList = ODS_Data_Utility.fetchAccServcesByServiceAccount(AccountId, ServiceId);        
        if(accServList.size() > 0){
            AccountServiceID = accServList[0].Id;
        }
        else{
            AccountServiceID = '';
        }
    }    
    public PageReference GetTimesheetByAccountServiceID() {
        //system.debug('ConAccount:::::::'+AccountId);
        ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);
        PageReference pr = new PageReference('/apex/ContactListPage');
        return pr; 
    }    
    List<selectOption> allCustomers = new List<selectOption>();
    public List<selectOption> getAccounts()
    {     
        List<SelectOption> customersList = new  list<SelectOption>();
        ODS_Common_Utility objUtility = new  ODS_Common_Utility();
        customersList = objUtility.getCustomersByLoggedInUser('');        
        if(customersList != null && customersList.size() > 0){
            for(SelectOption accountService: customersList) {                 
                If(accountService.getValue() != 'All' && !listContains(allCustomers, new SelectOption(accountService.getValue(), accountService.getLabel()))){                   
                    allCustomers.add(new SelectOption(accountService.getValue(), accountService.getLabel()));
                }
            }
        }
        for(Account accSalesforce : database.query('SELECT Id,Name FROM Account WHERE Name IN (\'Salesforce.org\',\'Salesforce.com\') ORDER BY Name'))
        { 
            allCustomers.add(new SelectOption(accSalesforce.id, accSalesforce.Name)); 
        }
        //system.debug('==allCustomers==='+allCustomers);
        return allCustomers;    
    }
    public Boolean listContains(Object[] source, Object target){
        return (new Set<Object>(source)).contains(target);
    }
    public List<selectOption> getReportsToId()
    {     
        List<SelectOption> contactList = new  list<SelectOption>();
        contactList.add(new SelectOption('', '--None--')); 
        String newAccountId = contactWraper.AccountId;
        system.debug('newAccountId::: '+ newAccountId);
        if(String.IsNotBlank(newAccountId)){
            for(Contact con : database.query('SELECT Id,Name FROM Contact WHERE AccountId = \''+newAccountId +'\' ORDER BY Name'))
            { 
                contactList.add(new SelectOption(con.id, con.Name)); 
            } 
        }
        return contactList;    
    }
    public List<selectOption> getRoleLevels()
    {     
        List<SelectOption> roleLevelList = new  list<SelectOption>();
        roleLevelList.add(new SelectOption('', '--None--'));
        Schema.DescribeFieldResult field = Contact.Role_Level__c.getDescribe();
        for (Schema.PicklistEntry listEntry : field.getPicklistValues()){
            roleLevelList.add(new SelectOption(listEntry.getValue(), listEntry.getLabel()));            
        }
        return roleLevelList;    
    }
    public List<selectOption> getForceComStatus()
    {     
        List<SelectOption> forceComStatusList = new  list<SelectOption>();
        forceComStatusList.add(new SelectOption('', '--None--'));
        Schema.DescribeFieldResult field = Contact.Status__c.getDescribe();
        for (Schema.PicklistEntry listEntry : field.getPicklistValues()){
            forceComStatusList.add(new SelectOption(listEntry.getValue(), listEntry.getLabel()));            
        }
        return forceComStatusList;    
    }
    public List<selectOption> getODSDotNetStatus()
    {     
        List<SelectOption> oDSDotNetStatusList = new  list<SelectOption>();
        oDSDotNetStatusList.add(new SelectOption('', '--None--'));
        Schema.DescribeFieldResult field = Contact.ODS_DotNet_Status__c.getDescribe();
        for (Schema.PicklistEntry listEntry : field.getPicklistValues()){
            oDSDotNetStatusList.add(new SelectOption(listEntry.getValue(), listEntry.getLabel()));            
        }
        return oDSDotNetStatusList;    
    }
    public PageReference saveContact(){
        //system.debug('contactWraper::: '+ contactWraper);
        try{
            String contactJson = JSON.serialize(contactWraper);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Contact JSON:::' + contactJson));
            createContact(contactJson);            
        }
        catch(exception e){            
            system.debug('Error Occured::: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured on saving new Contact::: <font color="red" size = "4">' + e.getMessage() + '</font>'));
        }
        PageReference pgRef = new PageReference('/apex/ContactListPage');
        pgRef.setRedirect(true);
        return pgRef;
    } 
    public pagereference redirectToContact()
    {
        try{   
            Pagereference pgRef = new PageReference('/apex/ContactListPage');
            pgRef.setRedirect(true);
            return pgRef;
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            return null;
        }
    }
    public void bindContactWrapper(Contact contactObj)
    {
        contactWraper.AccountId = newContact.AccountId;
        contactWraper.FirstName = newContact.FirstName;
        contactWraper.LastName = newContact.LastName;
        contactWraper.Title = newContact.Title;
        contactWraper.ReportsToId = newContact.ReportsToId;
        contactWraper.RoleLevel = newContact.Role_Level__c != null ?newContact.Role_Level__c:'';
        contactWraper.Status = newContact.Status__c != null ?newContact.Status__c:'';
        contactWraper.MailingStreet = newContact.MailingStreet;
        contactWraper.MailingCity = newContact.MailingCity;
        contactWraper.MailingState = newContact.MailingState;
        contactWraper.MailingPostalCode = newContact.MailingPostalCode;
        contactWraper.MailingCountry = newContact.MailingCountry;
        contactWraper.Phone = newContact.Phone;
        contactWraper.MobilePhone = newContact.MobilePhone;
        contactWraper.Email = newContact.Email;
        contactWraper.ODSDotNetStatus = newContact.ODS_DotNet_Status__c != null ?newContact.ODS_DotNet_Status__c:'';
        contactWraper.isPrimary = newContact.isPrimary__c;
        contactWraper.HasOptedOutOfEmail = newContact.HasOptedOutOfEmail;
        contactWraper.IsPortalAccess = newContact.Is_Portal_Access__c;
        contactWraper.OtherStreet = newContact.OtherStreet;
        contactWraper.OtherCity = newContact.OtherCity;
        contactWraper.OtherState = newContact.OtherState;
        contactWraper.OtherPostalCode = newContact.OtherPostalCode; 
        contactWraper.OtherCountry = newContact.OtherCountry;       
        contactWraper.Id = newContact.Id;
    }
    @future (callout=true)
    public static void createContact(string contactObj)
    {     
        try{ 
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            String url = 'https://'+Label.ODS_SfdcUrl+'.salesforce.com/services/apexrest/createContact';
            //req.setEndpoint('callout:ContactsNamedCredential');
            req.setEndpoint(url);
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionID());
            req.setHeader('Content-Type','application/json');
            req.setMethod('POST');        
            System.debug('body:::' + contactObj);
            req.setBody(contactObj);       
            HTTPResponse res = http.send(req);
            //System.debug(res.getBody());
            //Label.ODS_SfdcUrl = demandblue--ezreodsqa.my  
        }
        catch(exception e){            
            system.debug('Error Occured::: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured on saving new Contact::: <font color="red" size = "4">' + e.getMessage() + '</font>'));
        }            
    }    
    public Class ContactWrapper
    {
        public string FirstName {get;set;}
        public string LastName {get;set;}
        public string Name {get;set;}
        public string Title {get;set;}
        public string ReportsToId {get;set;}
        public string RoleLevel {get;set;}
        public string Status {get;set;}
        public string MailingStreet {get;set;}
        public string MailingCity {get;set;}
        public string MailingState {get;set;}
        public string MailingPostalCode {get;set;}
        public string MailingCountry {get;set;}
        public string Phone {get;set;}
        public string MobilePhone {get;set;}
        public string Email {get;set;}
        public string ODSDotNetStatus {get;set;}
        public boolean isPrimary {get;set;}
        public boolean HasOptedOutOfEmail {get;set;}
        public boolean IsPortalAccess {get;set;}
        public string OtherStreet {get;set;}
        public string OtherCity {get;set;}
        public string OtherState {get;set;}
        public string OtherPostalCode {get;set;}
        public string OtherCountry {get;set;}
        public string AccountId {get;set;}
        public string Id {get;set;}        
    }
}