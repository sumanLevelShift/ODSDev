public with sharing class ODS_CustomerAccountController {
    
    //Properties for Customer List page
    public static string currentUserName {get;set;}
    public static string currentUserId {get;set;}
    public static string portalRole{get;set;}
    public static LIST<Account_Services__c> accServceLst{get;set;}
    public static LIST<User_Account__c > accLstByRole{get;set;}
    public static List<Account_Services__c> tamLst{get;set;}
    public static LIST<Account> allAccLst{get;set;}
    public set<Id> accId{get;set;}
    public static string AccountId {get;set;}
    public static string ServiceId {get;set;}
    public set<Id> userPhotoId{get;set;}
    public List<Attachment> attachedFiles{get;set;} 
    
    //Properties for Customer detail page 
    
    
    public static string slctdCustId{get;set;}
    public static string custSrvce{get;set;}
    public static string slctdCustService{get;set;}
    public static string contactId{get;set;}
    public static string billingAddress{get;set;}
   
    public static string AcntMngrName{get;set;}
    public static string AcntMngrEmail{get;set;}
    public static string AcntMngrPhone{get;set;} 
   
    //  public static string PeoplePhone {get;set;}
    //  public static string PeopleName {get;set;}
    
    
    
    public static Account objAcc{get;set;}
    public static List<Contact> objCon{get;set;}
    public static Account_Services__c objAccSrvc{get;set;}
    public static  Boolean isCustomer{get;set;}
    public static Boolean isCustomerGrid{get;set;}
    public static Boolean isHideService{get;set;}
    
    //Properties for pagination
    public Integer PageSize {get;set;}
    public Integer CurrentPage {get;set;}
    public Boolean ShowPrevious {get;set;}
    public Boolean ShowNext {get;set;}
    public String CurrentPageInfo {get;set;}
    public Integer TotalRecords;
    public Integer PageNumber;
    public Id currPartnerId = null;
    
    public ODS_CustomerAccountController()
    {
        currentUserName = UserInfo.getName();
        currentUserId = UserInfo.getUserId();
        accServceLst = new LIST<Account_Services__c>();
        isCustomer = false;
        //Added for Search page redirection
        slctdCustId = System.CurrentPageReference().getparameters().get('custId');
        if(slctdCustId != null){
            List<Account_Services__c> accountServicesList = new List<Account_Services__c >();
            accountServicesList = ODS_Data_Utility.fetchAccServcesByAcc(slctdCustId); 
            if(!accountServicesList.isEmpty() && accountServicesList.size() > 0){
                serviceId = accountServicesList[0].ODS_Services__c;
            }            
            // getTAMDetails(slctdCustId, serviceId);            
        }
        else{
            isCustomerGrid = false;
        }
        CurrentPage = 0; 
        PageSize = integer.valueof(System.Label.PageSize); // No. of rows per page
        PageNumber = 1; 
        ShowPrevious = false; 
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        portalRole = objUser.PortalUserRole__c;
        contactId = objUser.contactId;
        currPartnerId = objUser.Contact.AccountId;
        if(portalRole == 'Customer')
        { 
            isCustomer = true;
            isCustomerGrid = true;
        }
    }
    
    
    public void fetchSearchCustomersList()
    {
        accServceLst =  fetchCustomersByCriteria(AccountId, ServiceId);
        CurrentPage = 0; 
        PageNumber = 1; 
        ShowPrevious = false;
        if(accServceLst.size()>0)
        {
            TotalRecords = accServceLst.size();  // Total No of records need to display in Grid.      
            if(TotalRecords > PageSize)
                ShowNext = true;
            else
                ShowNext = false;       
            CurrentPageInfo = 'Showing Page ' + PageNumber + ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1); 
        }
    }
    
    public LIST<Account_Services__c> fetchCustomersByCriteria(string Account, string Service){
        
        Boolean isPortalAccess = true;
        integer count = 0;
        system.debug('AccountId:' +Account);
        string fetchAccQuery = 'SELECT Id, Name, Is_Portal_Access__c FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND '
            + 'Count_of_Services__c >: count ';
        string fetchCustQuery = 'SELECT Name, User__c, Account__c, Account__r.name, Account__r.Is_Portal_Access__c FROM User_Account__c '+
            ' WHERE Account__r.Is_Portal_Access__c =: isPortalAccess ';
        string fetchSrvceQuery = 'SELECT Account__c, Account__r.Name, Contract_End_Date__c, ODS_Services__c, ODS_Services__r.Name__c, '+
            ' Technical_Account_manager__r.Name, Technical_Account_manager__c FROM Account_Services__c  ';
        accServceLst = new LIST<Account_Services__c>(); 
        allAccLst = new LIST<Account>(); 
        accId = new set<Id>();
        LIST<Account> allPartnerAccLst = new LIST<Account>(); 
        user objuser = ODS_Data_Utility.fetchUserById(currentUserId);
        
        if(objuser.PortalUserRole__c == 'Practice Head')
            
        {
            if(Account== 'All')
            {
                allAccLst = new LIST<Account>();
                allAccLst = database.query(fetchAccQuery);
            }
            
            else
            {
                fetchAccQuery += 'AND Id =: Account'; 
                allAccLst = new LIST<Account>();
                allAccLst = database.query(fetchAccQuery);
            }
            if(allAccLst.size()>0)
            {
                for(Account objAccount: allAccLst )
                {
                    string acntId = objAccount.Id;
                    accId.add(acntId);
                }
            }
        }
        //Updated by Mani and Team
        else if(objuser.PortalUserRole__c == 'Partner') {
            if(Account== 'All')
            {
                fetchAccQuery += 'AND Channel_Partner__c =: currPartnerId AND Channel_Partner_Contact__c =:contactId'; 
                allPartnerAccLst = new LIST<Account>();
                allPartnerAccLst = database.query(fetchAccQuery);
            }           
            else
            {
                fetchAccQuery += 'AND Channel_Partner__c =: currPartnerId AND Channel_Partner_Contact__c =:contactId AND Id =: Account'; 
                allPartnerAccLst = new LIST<Account>();
                allPartnerAccLst = database.query(fetchAccQuery);
            }
            if(!allPartnerAccLst.isEmpty())
            {
                for(Account objPartAccount: allPartnerAccLst)
                {
                    string acntId = objPartAccount.Id;
                    accId.add(acntId);
                }
            }
        }
        else
        {
            string portalRole = objuser.PortalUserRole__c;           
            if(Account== 'All')
            {
                fetchCustQuery += ' AND User__c =: currentUserId '; 
                accLstByRole = new LIST<User_Account__c>();
                accLstByRole = database.query(fetchCustQuery);
            }
            
            else
            {
                fetchCustQuery += ' AND User__c =: currentUserId AND Account__c =: Account'; 
                accLstByRole = new LIST<User_Account__c>();
                accLstByRole = database.query(fetchCustQuery);
            }
            if(accLstByRole.size()>0)
            {
                for(User_Account__c  usrObj: accLstByRole )
                {
                    string acntId = usrObj.Account__c;
                    accId.add(acntId);
                }
            }
        }
        if(accId.size()>0)
        {  
            if(Service == 'All')
            {
                fetchSrvceQuery += ' WHERE Account__c IN: accId ';
                accServceLst = database.query(fetchSrvceQuery);
            }
            else
            {
                fetchSrvceQuery += ' WHERE Account__c IN: accId AND ODS_Services__c =: Service ';
                accServceLst = database.query(fetchSrvceQuery);
            }
        }
        return accServceLst; 
    }
    
    /// <OBJECTIVE>
    /// Fetch customer list.
    /// </OBJECTIVE>
    public void fetchCustomersList()
    {
        accServceLst =  fetchCustomersByCriteria('All', 'All');
        CurrentPage = 0; 
        PageNumber = 1; 
        ShowPrevious = false;
        if(accServceLst.size()>0){
            TotalRecords = accServceLst.size();  // Total No of records need to display in Grid.
            
            if(TotalRecords > PageSize)
                ShowNext = true;
            else
                ShowNext = false;       
            CurrentPageInfo = 'Showing Page ' + PageNumber + ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1); 
        }
    }
    /// <OBJECTIVE>
    /// Fetch customer details based on selected customer.
    /// </OBJECTIVE>
    /** public void passParamToContrler()
{
slctdCustId = System.currentPageReference().getParameters().get('custId');
custSrvce = System.currentPageReference().getParameters().get('custSrvce');
getTAMDetails(slctdCustId, custSrvce);
}*/
    
    @AuraEnabled(cacheable=true)
    public static map<string,string> getCustomerServices(string accountId)
    {
        map <string,string> accsermap = new map<string,string>(); 
        List<SelectOption> options = new List<SelectOption>();
        List<Account_Services__c> custSrvceLst = new List<Account_Services__c>();
        custSrvceLst = ODS_Data_Utility.fetchAccServcesByAcc(accountId);
        //accsermap.put('All', 'salesforce');
        if(!custSrvceLst.isEmpty())
        {     
            for( Account_Services__c custmrSrvce: custSrvceLst)
            {
                accsermap.put(custmrSrvce.ODS_Services__c, custmrSrvce.ODS_Services__r.Name__c);
                
            }   
        } 
        return accsermap;
    }
    /// <OBJECTIVE>
    /// Fetch services based on the selected service.
    /// </OBJECTIVE>
    /*public void fetchServiceById()
{
slctdCustService = ServiceID;
getTAMDetails(accountId, serviceId);
}*/
    /// <OBJECTIVE>
    ///  Enable disable showPrevious button.
    /// </OBJECTIVE>
    public void showPrevious()
    {
        CurrentPage = CurrentPage- PageSize;
        PageNumber--;
        enableDisablePaginationLinks();     
    }
    /// <OBJECTIVE>
    /// Enable disable showNext button
    /// </OBJECTIVE>
    public void showNext()
    {
        CurrentPage = CurrentPage + PageSize;
        PageNumber++;
        enableDisablePaginationLinks();
    }
    /// <OBJECTIVE>
    /// Enable disable showFirst button
    /// </OBJECTIVE>
    public void showFirst()
    {
        CurrentPage = 0;
        PageNumber = 1;
        enableDisablePaginationLinks();
    }
    /// <OBJECTIVE>
    /// Enable disable showLast button
    /// </OBJECTIVE>
    public void showLast()
    {
        CurrentPage = (Math.mod(TotalRecords, PageSize) == 0) ? TotalRecords - PageSize : (TotalRecords / PageSize) * PageSize;
        PageNumber = (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1);
        enableDisablePaginationLinks();
    }
    /// <OBJECTIVE>
    /// Enable disable pagination links
    /// </OBJECTIVE>
    public void enableDisablePaginationLinks()
    {
        if(CurrentPage == 0)
            ShowPrevious = false;
        else    
            ShowPrevious = true; 
        if((TotalRecords - PageSize) <= CurrentPage)
            ShowNext = false;
        else
            ShowNext = true;
        CurrentPageInfo = 'Showing Page ' + PageNumber +   ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1);
    }   
    @AuraEnabled(cacheable=true)
    public static List<Account_Services__c> getClientCustomer(string accountId, string serviceId){
        if(accountId !='All' && serviceId=='All'){
            List<Account_Services__c> lstfetchAccServcesByAcc = ODS_Data_Utility.fetchAccServcesByAccAndEngmtType(AccountId);
            serviceId = lstfetchAccServcesByAcc[0].ODS_Services__c;
        }
        tamLst = new List<Account_Services__c>();
        if(accountId != 'All' && serviceId !='All'){
            tamLst = ODS_Data_Utility.fetchTAMBySlctdId(accountId, serviceId);  
        }else{
            ODS_Common_Utility obj = new ODS_Common_Utility();
            String[] AccounIDs = obj.getAllAccountIDByLoggedInUser();
            tamLst=[SELECT Id,Account__c,Account__r.Name,ODS_Services__c,ODS_Services__r.Name__c,Customer_Success_Executive__r.Name,
                    Customer_Success_Executive__r.Email,
                    Customer_Success_Executive__r.Phone,
                    Technical_Account_manager__r.name, 
                    Technical_Account_manager__r.Email,
                    Technical_Account_manager__r.Phone,
                    Technical_Account_manager__r.Photo__c,
                    Backup_CSM__r.Name,
                    Backup_CSM__r.Email,
                    Backup_CSM__r.Phone,
                    Contract_End_Date__c
                    FROM 
                    Account_Services__c 
                    WHERE 
                    Account__c IN: AccounIDs];
        }
        return tamLst;
    }
    @AuraEnabled(cacheable=true)
    public static CustomerDetail getCustomerDetails(string accountId, string serviceId){
        
        if(accountId !='All' && serviceId=='All'){
            List<Account_Services__c> lstfetchAccServcesByAcc = ODS_Data_Utility.fetchAccServcesByAccAndEngmtType(AccountId);
            serviceId = lstfetchAccServcesByAcc[0].ODS_Services__c;
        }
        
        tamLst = new List<Account_Services__c>();
        tamLst = ODS_Data_Utility.fetchTAMBySlctdId(accountId, serviceId);
        system.debug('tam list : '+tamLst);
        
        try
        {
            User_Account__c  objUserAcc = new User_Account__c();
            objUserAcc = ODS_Data_Utility.fetchAMBySlctdId(accountId);
            if(!string.isEmpty(objUserAcc.id))
            {
                String userId =  objUserAcc.User__c;
                User objuser = ODS_Data_Utility.fetchUserDetailsById(userId);
                if(!string.isEmpty(objuser.id))
                {
                    AcntMngrName= objuser.Name;
                    AcntMngrEmail = objuser.Email;
                    AcntMngrPhone = objuser.Phone;
                } 
            }             
        }
        catch(exception e)
        {
            system.debug(e);
        }
        objAcc = ODS_Data_Utility.fetchAccountDetailsById(accountId);
        billingAddress ='';
        if(!string.IsEmpty(objAcc.BillingStreet))
            billingAddress += objAcc.BillingStreet+', '; 
        if(!string.IsEmpty(objAcc.BillingCity))
            billingAddress += objAcc.BillingCity+', ';
        if(!string.IsEmpty(objAcc.BillingState))
            billingAddress += objAcc.BillingState+', ';
        if(!string.IsEmpty(objAcc.BillingCountry))
            billingAddress += objAcc.BillingCountry+', ';
        if(!string.IsEmpty(objAcc.BillingPostalCode ))
            billingAddress += objAcc.BillingPostalCode;   
        set<string> conAccSrvcContactIds = new set<string>();
        for(Contact_Account_Service__c conAccServ: ODS_Data_Utility.fetchContactAccountServiceDetails(accountId)){            
            conAccSrvcContactIds.add(conAccServ.Contact__c);           
        }
        if(conAccSrvcContactIds.size() > 0){
            objCon = ODS_Data_Utility.fetchContactDetailsById(conAccSrvcContactIds);
        }
        system.debug('objCon111'+objCon);
        objAccSrvc = new Account_Services__c();
        
        if(!string.isEmpty(serviceId))
        {
            objAccSrvc = ODS_Data_Utility.fetchServiceDetailsById(accountId, serviceId);
        }
        isCustomerGrid = true;
        
        
        CustomerDetail custRec = new CustomerDetail();
        
        // CSM,BackUpCSM,CSE,AccManger
        if(string.isEmpty(tamLst[0].Technical_Account_manager__r.Name)){
            custRec.nameTam = 'Not available';
        }
        else{
            custRec.nameTam = tamLst[0].Technical_Account_manager__r.Name;
        }
        
        if(string.isEmpty(tamLst[0].Technical_Account_manager__r.Phone)){
            custRec.phoneTam = 'Not available';
        }
        else{
            custRec.phoneTam = tamLst[0].Technical_Account_manager__r.Phone;
        }
        
        if(string.isEmpty(tamLst[0].Technical_Account_manager__r.Email)){
            custRec.emailTam = 'Not available';
        }
        else{
            custRec.emailTam = tamLst[0].Technical_Account_manager__r.Email;
        }
        
        if(string.isEmpty(tamLst[0].Backup_CSM__r.Name)){
            custRec.backupcsmname = 'Not available';
        }
        else{
            custRec.backupcsmname = tamLst[0].Backup_CSM__r.Name;
        }
        if(string.isEmpty(tamLst[0].Backup_CSM__r.Phone)){
            custRec.backupcsmphone = 'Not available';
        }
        else{
            custRec.backupcsmphone = tamLst[0].Backup_CSM__r.Phone;
        }
        if(string.isEmpty(tamLst[0].Backup_CSM__r.Email)){
            custRec.backupcsmemail = 'Not available';
        }
        else{
            custRec.backupcsmemail = tamLst[0].Backup_CSM__r.Email;
        }
        if(string.isEmpty(tamLst[0].Customer_Success_Executive__r.Name)){
            custRec.CSENames = 'Not available';
        }
        else{
            custRec.CSENames = tamLst[0].Customer_Success_Executive__r.Name;
            system.debug('CSM'+tamLst[0].Customer_Success_Executive__r.Name);
        }   
        if(string.isEmpty(tamLst[0].Customer_Success_Executive__r.Email)){
            custRec.CSEmails = 'Not available';
        }
        else{
            custRec.CSEmails = tamLst[0].Customer_Success_Executive__r.Email;
        }   
        
        if(string.isEmpty(tamLst[0].Customer_Success_Executive__r.Phone)){
            custRec.CSEphos = 'Not available';
        }
        else{
            custRec.CSEphos = tamLst[0].Customer_Success_Executive__r.Phone;
        } 
        
        /* if(string.isEmpty(objuser.Name)){
tamRec.AccMname = 'Not available';
}
else{
tamRec.AccMname = objuser.Name;
} */
        
        // Company Information
        custRec.accname = tamLst[0].Account__r.Name;
        custRec.webs = objAcc.Website;
        custRec.billingadd = billingAddress;
        custRec.ServiceName = objAccSrvc.ODS_Service_Name__c;
        
        //ODS services
        if(objAccSrvc.Contract_Start_Date__c !=null){
            custRec.cssdate = objAccSrvc.Contract_Start_Date__c.format();
            
        }
        if(objAccSrvc.Contract_End_Date__c !=null){
            custRec.cendsdate = objAccSrvc.Contract_End_Date__c.format();
            
        }
        custRec.Retfeeamount = String.ValueOf(objAccSrvc.Retainer_Fee_Amount__c);
        custRec.ODSHoursrateAmount = String.ValueOf(objAccSrvc.ODS_Hourly_Rate_Amount__c);
        custRec.RetainerFFT = objAccSrvc.Retainer_Fee_Frequency_Type__c;
        custRec.CustomerPortalD  = objAccSrvc.Account__r.Customer_Portal_Demo__c;
        custRec.CustomerPortalAcc  = objAccSrvc.Account__r.Customer_Portal_Access__c;
        custRec.SetupWeekMonMeeting  = objAccSrvc.Account__r.Setup_Weekly_Monthly_Meeting__c;
        custRec.onboardingdoc  = objAccSrvc.Account__r.Onboarding_Document__c;
        custRec.Lightingreadcheck  =  objAccSrvc.Account__r.Lightning_Readiness_Check__c;
        
        
        
        if(string.isEmpty(AcntMngrName)){
            custRec.AccMname = 'Not available';
        }
        else{
            custRec.AccMname = AcntMngrName;
        }
        if(string.isEmpty(AcntMngrEmail)){
            custRec.AccMemail = 'Not available';
        }
        else{
            custRec.AccMemail = AcntMngrEmail;
        }
        if(string.isEmpty(AcntMngrPhone)){
            custRec.AccMphone = 'Not available';
        }
        else{
            custRec.AccMphone = AcntMngrPhone;
        }
        
        custRec.ContDetails = objCon;
        
        //tamRec.AccMname  =  objuser.Name;
        
        
        
        //Prople Info
        /*
tamRec.pelname  =  objCon[0].Name;
if(string.isEmpty(objCon[0].Email)){
tamRec.pelemail = 'Not available';
}
else{
tamRec.pelemail  =  objCon[0].Email;
} 
if(string.isEmpty(objCon[0].MobilePhone)){
tamRec.pelphone = 'Not available';
}
else{
tamRec.pelphone = objCon[0].MobilePhone;
} */
        
        
        
        system.debug('tam : '+custRec);
        return custRec;
        
    }
    
    
    
    @AuraEnabled(cacheable = true)
    public static List<Account_Services__c> getMatchList(String recId){
        System.debug('Account_Services__c: ' + [SELECT Account_Manager_Email__c,Account_Manager__c,Account_Owner_Email__c,Backup_CSM__c,Account__c,Contract_Start_Date__c,Id,Name,Technical_Account_Manager_Email__c,Technical_Account_manager__r.Name FROM Account_Services__c ]);
        
        Return [SELECT Account_Manager_Email__c,Account_Manager__c,Account_Owner_Email__c,Contract_End_Date__c,Backup_CSM__c,Account__r.Name,Contract_Start_Date__c,Id,Name,Technical_Account_Manager_Email__c,Technical_Account_manager__r.Name FROM Account_Services__c];
    }
    
    
    
    public class CustomerDetail{
        @AuraEnabled
        public string nameTam{get;set;}
        @AuraEnabled
        public string phoneTam{get;set;}
        @AuraEnabled
        public string emailTam{get;set;}
        @AuraEnabled
        public string backupcsmname{get;set;}
        @AuraEnabled
        public string backupcsmphone{get;set;}
        @AuraEnabled
        public string backupcsmemail{get;set;}
        @AuraEnabled
        public string accname{get;set;}
        @AuraEnabled
        public string webs{get;set;}
        @AuraEnabled
        public string billingadd{get;set;}
        @AuraEnabled
        public string cssdate{get;set;}
        @AuraEnabled
        public string cendsdate{get;set;}
        @AuraEnabled
        public string Retfeeamount{get;set;}
        @AuraEnabled
        public string ODSHoursrateAmount{get;set;}
        @AuraEnabled
        public string RetainerFFT{get;set;}
        @AuraEnabled
        public string CustomerPortalD{get;set;}
        @AuraEnabled
        public string CustomerPortalAcc{get;set;}
        @AuraEnabled
        public string SetupWeekMonMeeting{get;set;}
        @AuraEnabled
        public string onboardingdoc{get;set;}
        @AuraEnabled
        public string Lightingreadcheck{get;set;}
        @AuraEnabled
        public string conname{get;set;}
        @AuraEnabled
        public string CSENames{get;set;}
        @AuraEnabled
        public string CSEmails{get;set;}
        @AuraEnabled
        public string CSEphos{get;set;}
        
        @AuraEnabled
        public string AccMname{get;set;}
        @AuraEnabled
        public string AccMemail{get;set;}
        @AuraEnabled
        public string AccMphone{get;set;}
        @AuraEnabled
        public string ServiceName{get;set;}
        @AuraEnabled
        public list<contact> ContDetails{get;set;}
        
        
        
    }
    @AuraEnabled(Cacheable=false)
    public static void updateSessionData(string accountId,string serviceId){
        ODS_Common_Utility.upsertSessionData(accountId,serviceId);  
    }
    @AuraEnabled(Cacheable=false)
    public static boolean checkIsSmallBusiness(string accountId){
        List<Account> accountRecord=[Select Id, Small_Business__c From Account WHERE ID=:accountId];
        if(!accountRecord.isEmpty()){
            return accountRecord[0].Small_Business__c;
        }
        return false;
    }
}