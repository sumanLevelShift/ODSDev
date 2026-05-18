public with sharing class ODS_ContactComponentController {
    public static string AccountId {get;set;}
    public static string ServiceId {get;set;}
    //public static string AccountServiceID {get;set;} 
    public static List<Contact> conlist {get;set;}
    //  public static string CurrentContactId {get;set;}
    
    // public Contact newContact {get; set;}
    
    //    public string CurrentAccountId {get;set;}
    //public Staging_Contact_Record__c stagingContactRecord {get;set;}
    //public ContactWrapper contactWraper {get;set;}
    public ODS_ContactComponentController(){
    }
    @AuraEnabled(cacheable=false)
    Public static  List<Contact> GetContacts(string AccountId, string ServiceId)
    {
        try
        { 
            system.debug('ContactAccount'+AccountId);
            String fieldQuery = '';
            if(String.IsNotBlank(AccountId) && AccountId == 'All'){
                fieldQuery = 'SELECT AccountId,Email,FirstName,Id,LastName,MobilePhone,Name,Phone,Account.Name FROM Contact ORDER BY Name,Account.Name';
            }
            else if(String.IsNotBlank(AccountId)){
                fieldQuery = 'SELECT AccountId,Email,FirstName,Id,LastName,MobilePhone,Name,Phone,Account.Name FROM Contact WHERE AccountId =\''+AccountId+'\' ORDER BY Name,Account.Name'; 
            }
            system.debug('@@@@ Query:' + fieldQuery);
            conlist = Database.query(fieldQuery);
            system.debug('@@@@contactList:' + conlist);
            
        }
        catch(Exception e)
        {
            system.debug('Error Occured::: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured on fetching Contacts::: <font color="red" size = "4">' + e.getMessage() + '</font>'));
        }
        return conlist;
    }
    @AuraEnabled(cacheable=true)
    public static map<string,string> GetAccountPicklistValues()
    {
        map <string,string> accmap = new map<string,string>(); 
        List<SelectOption> lstSlctOptn = new  list<SelectOption>();
        ODS_Common_Utility objUtility = new  ODS_Common_Utility();
        //string PageName = ApexPages.currentPage().GetURL().substringBefore('?').substringafter('/').substringafter('/');
        lstSlctOptn = objUtility.getCustomersByLoggedInUser();
        set<SelectOption> setSlctOptn = new  set<SelectOption>();
        setSlctOptn.addAll(lstSlctOptn);
        List<SelectOption> lstSlctOptn2 = new  list<SelectOption>();
        lstSlctOptn2.addAll(setSlctOptn);
        system.debug('lstSlctOptn2--'+lstSlctOptn2);
        
        for(SelectOption so : lstSlctOptn2 ){
            accmap.put(so.getValue(), so.getLabel());
        }
        return accmap;  
        
    }
    @AuraEnabled(cacheable=false)
    public static contact getCurrentContact(string contactId){
        contact conlist =  [SELECT AccountId,Email,FirstName,Id,OtherCity,OtherCountry,OtherState,OtherPostalCode,isPrimary__c,Is_Portal_Access__c,HasOptedOutOfEmail,LastName,ODS_DotNet_Status__c,MailingPostalCode,MailingCountry,MailingState,MailingCity,Status__c,MailingStreet,Role_Level__c,ReportsToId,Title,OtherStreet,MobilePhone,Name,Phone,Account.Name FROM Contact WHERE id =: contactId limit 1];
        return conlist;
    }
    @AuraEnabled(cacheable=false)
    Public static void updateSelectedContact(string contactId, string newReportsToId,String newMailingstateId,string newAccountId,string newOtherStateId,string newMailingPostalCodeId,string newOtherPostalCodeId,string newMobilePhone)
    {
        system.debug('contactId--'+contactId);
        contact conlist =  [SELECT AccountId,Email,FirstName,Id,OtherCity,OtherCountry,OtherState,OtherPostalCode,isPrimary__c,Is_Portal_Access__c,HasOptedOutOfEmail,LastName,ODS_DotNet_Status__c,MailingPostalCode,MailingCountry,MailingState,MailingCity,Status__c,MailingStreet,Role_Level__c,ReportsToId,Title,OtherStreet,MobilePhone,Name,Phone,Account.Name FROM Contact WHERE id =: contactId limit 1];
        system.debug('conlist--'+conlist);
        conlist.AccountId=newAccountId;
        conlist.ReportsToId=newReportsToId;
        conlist.MailingState=newMailingstateId;
        conlist.OtherState=newOtherStateId;
        conlist.MailingPostalCode=newMailingPostalCodeId;
         conlist.OtherPostalCode=newOtherPostalCodeId;
        conlist.MobilePhone=newMobilePhone;
        
        
        update conlist;
    }
    
    @AuraEnabled(Cacheable=false)
    public static void updateSessionData(string accountId,string serviceId){
        ODS_Common_Utility.upsertSessionData(accountId,serviceId);  
    }
    @AuraEnabled( cacheable = true )
    public static List<Contact> getReportId(String AccountId){
        return [SELECT Id,Name FROM Contact WHERE AccountId =: AccountId ORDER BY Name];
    }
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
    public static List<String> getODSDotNetStatusPickListValue(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Contact.ODS_DotNet_Status__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getValue());
		}     
		return pickListValuesList;
    }
    @AuraEnabled( cacheable = true )
    public static List<String> getStatusPickListValue(){
       List<String> pickListValuesForce= new List<String>();
		Schema.DescribeFieldResult fieldResult = Contact.Status__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVals : ple){
			pickListValuesForce.add(pickListVals.getValue());
		}     
		return pickListValuesForce;
    }
    
}