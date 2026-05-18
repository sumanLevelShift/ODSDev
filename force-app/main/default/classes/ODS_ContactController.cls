/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       ODS_ContactController
* @description      This class is Controller for ContactListPage VF page
*********************************************************************************************
Version     Date            Team            Comments
*********************************************************************************************
* 1         11-MAR-2021     DemandBlue      Initial Development
*********************************************************************************************/
global class ODS_ContactController {
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string AccountServiceID {get;set;} 
    public List<Contact> contactList {get;set;}
    public string CurrentContactId {get;set;}
    public ODS_ContactController(){
    }
    Public void GetContacts()
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
            contactList = Database.query(fieldQuery);
        }
        catch(Exception e)
        {
            system.debug('Error Occured::: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured on fetching Contacts::: <font color="red" size = "4">' + e.getMessage() + '</font>'));
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
        ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);
        GetAccountServices();
        GetContacts();
        return null;
    } 
    public PageReference AddContact()
    {
        PageReference pgRef = new PageReference('/apex/ViewContact?CurrentAccountId='+AccountID);
        pgRef.setRedirect(true);
        return pgRef;
    } 
    public PageReference ViewContact()
    {
        System.debug('CurrentContactId@@@@@@@@'+CurrentContactId);
        PageReference pgRef = new PageReference('/apex/ViewContact?CurrentContactId=' +CurrentContactId);      
        pgRef.setRedirect(true);
        return pgRef;
    }
}