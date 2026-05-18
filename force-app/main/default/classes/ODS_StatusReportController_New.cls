/**
 * @author           Indumathi    
 * @version          1.0 
 * @date             04-OCT-2016
 * @Status           Developed
 * @description      Controller class for View Status Update visualforce Page
 *
 */


global virtual class ODS_StatusReportController_New
{
    @TestVisible protected boolean isMobile {get; set; }
    public Boolean isCustomer { get; set; }   
    public string srStatus {get;set;}
    public string FromDate {get;set;}
    public string ToDate {get;set;}
    public string AccountName {get;set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string ServiceName{get;set;}
    public string AccountServiceID {get;set;} 
    public List<Status_Report__c> stRprtList {get;set;}    
    public string currentUserName {get;set;}
    public Integer PageSize {get;set;}
    public Integer CurrentPage {get;set;}
    public Boolean ShowPrevious {get;set;}
    public Boolean ShowNext {get;set;}
    public String CurrentPageInfo {get;set;}
    public Integer TotalRecords;
    public Integer PageNumber;    
    public Status_Report__c objStsRprt {get;set;}
    public string WorkDayParam{get;set;}
    public string WorkNextDayParam{get;set;}
    public string IssuesConcernsParam{get;set;}
    public string srDate{get;set;}
    public string srId {get;set;}
    public string CurrenSRId {get;set;}
    public Status_Report__c srToView {get;set;}
    public String srWorkDay{get;set;}
    public Boolean ShowAddSR {get;set;}
    public Boolean isSRAvailable{get;set;}
    public User objUser {get;set;}
    public Boolean ShowDisclaimer {get;set;}
    public string PortalUserRole {get;set;}
    public string getMobileredirectUrl = label.ODS_MobileRedirectURL;
    public string StatusReportFrequency {get;set;} 
    public Boolean GetStatusReportByAccountServiceIDError {get;set;}
    public Boolean GetSearchResultsError {get;set;}
    public string StatusReport {get;set;}
    public Boolean isDaily {get;set;} 


    ///<OBJECTIVE>
    /// Constructor
    ///</OBJECTIVE>   
    public ODS_StatusReportController_New() 
    {
        objStsRprt = new Status_Report__c();
      
        srStatus = 'All';
        CurrentPage = 0; 
       // PageSize = integer.valueof(System.Label.PageSize); 
        PageNumber = 1; 
        ShowPrevious = false; 
        currentUserName = UserInfo.getName();  
        ShowAddSR = False;     
         objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());   
         PortalUserRole = String.valueOf(objUser.PortalUserRole__c); 
        //GetStatusReport();
        isDaily = true;        
        if(objUser.PortalUserRole__c == 'Customer')
        { 
            isCustomer = true;      
            ShowDisclaimer = false;    
            ShowAddSR = false;
        }else
                {  isCustomer = false; } 
           
    }
  
    
 
    ///<OBJECTIVE>
    /// Method to get search results
    ///</OBJECTIVE>   
    public void GetSearchResults()
    {       
        //CurrentPage = 0;
       // PageNumber=1;
        //enableDisablePaginationLinks();
        try{
            GetStatusReport();
            GetSearchResultsError = false;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            GetSearchResultsError = true;
        }
    }
    
    ///<OBJECTIVE>
    /// Method to perform search
    ///</OBJECTIVE>
    public void SearchAppliedRecords()
    {
        GetStatusReport();
        GetAccountServices();
    }
    
    ///<OBJECTIVE>
    /// Method to get current account service
    ///</OBJECTIVE>
    public void GetAccountServices()
    {
        if(AccountId == 'All' || ServiceId == 'All')
        {
            if(objUser.PortalUserRole__c == 'Customer')
            {
                ShowDisclaimer = false;
            }
            else{
                ShowDisclaimer = true;
            }
            ShowAddSR = False;
        }
        else
        {
            ShowDisclaimer = false;
            if(objUser.PortalUserRole__c == 'Customer')
            {
                ShowAddSR = False;
            }
            else
            {
                ShowAddSR = True;
            }
            List<Account_Services__c > accServList = new List<Account_Services__c >();
            accServList = ODS_Data_Utility.fetchAccServcesByServiceAccount(AccountId, ServiceId);
            if(accServList.size() > 0)
            {
                AccountServiceID = accServList[0].Id;
            }
            else
            {
                AccountServiceID = '';
            }
        }
    }
    
   
    
    public void SetRelatedService()
    {
        if(AccountId == 'All')
        {
            ServiceId = 'All';
        }
        else
        {
            ServiceId = 'All';
        }
    }
    
    ///<OBJECTIVE>
    /// Method to get Status Report
    ///</OBJECTIVE>
    @AuraEnabled
    public static Map<String, Object> getStatusReport(String AccountId, String ServiceId, String srStatus, String FromDate, String ToDate, Integer pageNumber, Integer pageSize)
    {
        // Create a new instance of the controller for this method
        ODS_StatusReportController_New controller = new ODS_StatusReportController_New();
        
        // Set the parameters
        controller.AccountId = AccountId;
        controller.ServiceId = ServiceId;
        controller.srStatus = srStatus;
        controller.FromDate = FromDate;
        controller.ToDate = ToDate;
        controller.PageNumber = pageNumber;
        controller.PageSize = pageSize;
        
        // Call the original method
        controller.GetStatusReport();
        
        // Prepare the result map
        Map<String, Object> result = new Map<String, Object>();
        
        // Transform the data to include Account and Service names for the LWC
        List<Map<String, Object>> transformedReports = new List<Map<String, Object>>();
        for(Status_Report__c report : controller.stRprtList)
        {
            Map<String, Object> reportMap = new Map<String, Object>();
            reportMap.put('Id', report.Id);
            reportMap.put('Date__c', report.Status_Date__c);
            reportMap.put('Account__r', new Map<String, Object>{'Name' => report.Account_Services__r?.Account__r?.Name});
            reportMap.put('Service__r', new Map<String, Object>{'Name' => report.Account_Services__r?.ODS_Services__r?.Name__c});
            reportMap.put('Status__c', report.Status__c);
            reportMap.put('Work_For_The_Day__c', report.Work_For_The_Day__c);
            reportMap.put('Work_For_The_Next_Day__c', report.Work_For_The_Next_Day__c);
            reportMap.put('Issues_and_Concerns__c', report.Issues_and_Concerns__c);
            reportMap.put('Account_Services__c', report.Account_Services__c);
            transformedReports.add(reportMap);
        }
        
        result.put('statusReports', transformedReports);
        result.put('isDaily', controller.isDaily);
        result.put('totalRecords', controller.TotalRecords);
        result.put('showAddSR', controller.ShowAddSR);
        result.put('showDisclaimer', controller.ShowDisclaimer);
        result.put('isCustomer', controller.isCustomer);
        result.put('showAddSRButton', controller.ShowAddSR);
        
        return result;
    }
    
    ///<OBJECTIVE>
    /// Method to get Status Report (original implementation)
    ///</OBJECTIVE>
    public void GetStatusReport()
    {
        try{
        String sStatus = 'Submitted';
        stRprtList = new List<Status_Report__c>();
        Set<String> allAccountIds = new Set<string>();
        Set<String> allServiceIds = new Set<string>();
        date frmDate ;
        date ToDt ;
        CurrentPage = 0; 
        PageNumber = 1; 
        ShowPrevious = false; 
        string Query;
        String fieldQuery = 'id, Name, Account_Services__c,Account_Services__r.Account__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Services__r.Name__c, Account_Services__r.ODS_Services__c,LastModifiedDate'
                            + ',Status__c,Status_Date__c,Issues_and_Concerns__c,Status_Report_Frequency__c,Account_Services__r.Status_Report_Frequency__c,Work_For_The_Day__c,Work_For_The_Next_Day__c';
        string whereQuery = 'WHERE ';
        system.debug('###AccountId:' +AccountId);
        try
        {
            if(AccountId == 'All'){
                AccountName = 'All';
                allAccountIds = GetAllAccounts();            
                whereQuery += 'Account_Services__r.Account__c IN: allAccountIds AND '; 
            }
            else
            {   
                List<Account> acc = new List<Account>();
                acc = ODS_Data_Utility.GetAccountNameById(AccountId);
                if(acc.size() > 0){
                    AccountName = acc[0].Name;
                }
                else{
                    AccountName = '';
                }
                whereQuery += 'Account_Services__r.Account__c =: AccountId AND ';
            }
            if(ServiceId == 'All'){
                ServiceName = 'All';
                if(objUser.PortalUserRole__c == 'Customer')
                {
                    system.debug('####AccountId'+ AccountId);
                    system.debug('####objUser.ContactId'+ objUser.ContactId);
                    
                    allServiceIds = GetAllServicesForCustomer(AccountId,objUser.ContactId); 
                    system.debug('####allServiceIds '+ allServiceIds);    
                }
                else
                {
                    allServiceIds = GetAllServices();
                }
                whereQuery += 'Account_Services__r.ODS_Services__c IN: allServiceIds AND '; 
            }
            else
            {
                List<ODS_Services__c> ods = new List<ODS_Services__c>();
                ods = ODS_Data_Utility.GetServiceNameById(ServiceId);
                if(ods.size() > 0){
                    ServiceName = ods[0].Name__c;
                }
                else{
                    ServiceName = '';
                }
             whereQuery += 'Account_Services__r.ODS_Services__c =: ServiceId AND '; 
            }
            
            if(FromDate !=null && FromDate != '')
            {
                frmDate = Date.parse(FromDate);
                system.debug('###frmDate :'+frmDate); 
                whereQuery += 'Status_Date__c   >=: frmDate AND '; 
            }
         
           if(ToDate != null&& ToDate != '')
            {
                ToDt = Date.parse(ToDate);
                system.debug('###ToDt :'+ToDt);
                whereQuery += 'Status_Date__c   <=: ToDt AND '; 
                
            }
         
            if(objUser.PortalUserRole__c == 'Customer')
            {
                whereQuery += 'Status__c =: sStatus AND '; 
            }
            else
            {
                if(srStatus != 'All')
                {
                    whereQuery += 'Status__c =: srStatus AND ';                 
                }
            }
            
                date today = Date.today();
                date Currentdt = date.parse(string.valueOf(today.Month()) + '/' + string.valueOf(today.day()) + '/' + string.valueOf(today.Year()));
                //ToDt = Date.parse(ToDate);
                system.debug('###Currentdt :'+Currentdt);
                whereQuery += 'Status_Date__c <=: Currentdt AND ';
          
            
            whereQuery = (whereQuery.trim()).removeEnd('AND');
            Query = 'SELECT ' + fieldQuery + ' FROM Status_Report__c ' + whereQuery + ' ORDER BY Status_Date__c DESC' + ' Limit 500';
            system.debug('###Query:' + Query);
            System.debug('------------'+accountid+ ' ---- ' +serviceId + '----' + srStatus + '----------' +frmDate+ ' ---- ' +ToDt);
            stRprtList = Database.query(Query);                
            system.debug('##pavithrastRprtList'+stRprtList);
            TotalRecords = stRprtList.size();  // Total No of records need to display in Grid.
            for(Status_Report__c stlist :stRprtList ){
                if(stlist.Account_Services__r.Status_Report_Frequency__c == 'Weekly'){
                     isDaily = false;
                }
                else{
                     isDaily = true;
                }
            }
            if(TotalRecords > PageSize)
                ShowNext = true;
            else
                ShowNext = false;       
            CurrentPageInfo = 'Showing Page ' + PageNumber + ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1); 
        }
        catch(Exception e){
            system.debug('Invalid date!!');
        }
       }
        
        catch(Exception ex){
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(ex.getCause()), ex.getMessage(), ex.getStackTraceString(), ex.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error:Invalid Data. Unable to complete your request due to '+ ex.getMessage()+'.'));
        }
    }
        
    ///<OBJECTIVE>
    /// Method to get current user portal access
    ///</OBJECTIVE>
    Public boolean getLoggedUserPortalAccess()
    {
        User usr = ODS_Data_Utility.getLoggedUserdetail();
        return usr.Is_Portal_Access__c;
    }
    
    ///<OBJECTIVE>
    /// Method to get current user portal role
    ///</OBJECTIVE>
    Public string getLoggedUserPortalRole()
    {
        User usr = ODS_Data_Utility.getLoggedUserdetail();
        return usr.PortalUserRole__c;
    }
    
    ///<OBJECTIVE>
    /// Method to get All Accounts
    ///</OBJECTIVE>
    public Set<string> GetAllAccounts()
    {
        Set<string> accountIdSet = new Set<string>();
       ODS_Common_Utility obj = new ODS_Common_Utility();
        String[] AccounIDs = obj.getAllAccountIDByLoggedInUser();
        for( String AccID: AccounIDs )
        {
            accountIdSet.add(AccID);
        }
        return accountIdSet;
    }
    
    ///<OBJECTIVE>
    /// Method to get All Services
    ///</OBJECTIVE>
    public Set<string> GetAllServices()
    {
        Set<string> serviceIdSet = new Set<string>();
        for(ODS_Services__c odsService: ODS_Data_Utility.GetAllServices())
        {
            serviceIdSet.add(odsService.Id);
        }
        return serviceIdSet;
    }
     ///<OBJECTIVE>
    /// Method to get All Services for customer
    ///</OBJECTIVE>
    public Set<string> GetAllServicesForCustomer(string AccountId, string ContactId)
    {
        Set<string> serviceIdSet = new Set<string>();
        system.debug('####AccountId'+ AccountId);
        system.debug('####objUser.ContactId'+ objUser.ContactId);
        
        for(Contact_Account_Service__c CustomerAccService : ODS_Data_Utility.GetCustomerAccService(AccountId,ContactId))
        {
            serviceIdSet.add(CustomerAccService.ODS_Service__c);
        }
        system.debug('####serviceIdSet'+ serviceIdSet);
        return serviceIdSet;
        
    }
    
    ///<OBJECTIVE>
    /// Method to format String to Date
    ///</OBJECTIVE>
    public Date FormatStringToDate(string dateString)
    {
        string[] dateArr = dateString.split('-');
        return date.Parse(dateArr[1]+'/'+dateArr[0]+'/'+dateArr[2]);
    }
    
    ///<OBJECTIVE>
    /// Method to get Account Picklist Values.
    ///</OBJECTIVE>    
    
    @AuraEnabled
    public static List<Map<String, Object>> getAccountPicklistValuesRemote()
    {
        ODS_StatusReportController_New controller = new ODS_StatusReportController_New();
        List<SelectOption> selectOptions = controller.GetAccountPicklistValues();
        List<Map<String, Object>> serializedOptions = new List<Map<String, Object>>();
        for(SelectOption option : selectOptions) {
            Map<String, Object> optionMap = new Map<String, Object>();
            optionMap.put('label', option.getLabel());
            optionMap.put('value', option.getValue());
            serializedOptions.add(optionMap);
        }
        return serializedOptions;
    }
    
    ///<OBJECTIVE>
    /// Method to get Account Picklist Values (original implementation)
    ///</OBJECTIVE>    
    public List<SelectOption> GetAccountPicklistValues()
    {
        List<SelectOption> lstSlctOptn = new list<SelectOption>(); 
        ODS_Common_Utility objUtility = new ODS_Common_Utility();
        lstSlctOptn = objUtility.getCustomersByLoggedInUser();
        return lstSlctOptn;
    }
    
    ///<OBJECTIVE>
    /// Method to get FromDate.
    ///</OBJECTIVE>
    @AuraEnabled
    public static List<Map<String, Object>> getServicePicklistValues(String AccountId)
    {
        ODS_StatusReportController_New controller = new ODS_StatusReportController_New();
        controller.AccountId = AccountId;
        List<SelectOption> selectOptions = controller.GetServicePicklistValues();
        List<Map<String, Object>> serializedOptions = new List<Map<String, Object>>();
        for(SelectOption option : selectOptions) {
            Map<String, Object> optionMap = new Map<String, Object>();
            optionMap.put('label', option.getLabel());
            optionMap.put('value', option.getValue());
            serializedOptions.add(optionMap);
        }
        return serializedOptions;
    }
    
    ///<OBJECTIVE>
    /// Method to get FromDate (original implementation).
    ///</OBJECTIVE>
    public List<SelectOption> GetServicePicklistValues()
    {
        List<SelectOption> lstSlctOptn = new list<SelectOption>();      
        lstSlctOptn.add(new SelectOption('All', 'All Services'));
        if(ODS_Data_Utility.fetchAccServcesByAcc(AccountId).size() >= 0)
        {
            for(Account_Services__c odsAccService: ODS_Data_Utility.fetchAccServcesByAcc(AccountId))
            { 
                lstSlctOptn.add(new SelectOption(odsAccService.ODS_Services__c, odsAccService.ODS_Services__r.Name__c)); 
            }
        } 
        
        return lstSlctOptn;
    }
    
    /// <OBJECTIVE>
    /// Fetch the Status values dynamically and returns.
    /// </OBJECTIVE>
    @AuraEnabled
    public static List<Map<String, Object>> getStatusPicklistValuesRemote()
    {
        List<SelectOption> selectOptions = ODS_StatusReportController_New.GetStatusPicklistValues();
        List<Map<String, Object>> serializedOptions = new List<Map<String, Object>>();
        for(SelectOption option : selectOptions) {
            Map<String, Object> optionMap = new Map<String, Object>();
            optionMap.put('label', option.getLabel());
            optionMap.put('value', option.getValue());
            serializedOptions.add(optionMap);
        }
        return serializedOptions;
    }
    
    /// <OBJECTIVE>
    /// Fetch the Status values dynamically and returns (original implementation).
    /// </OBJECTIVE>
    public static List<SelectOption> GetStatusPicklistValues()
    {
        List<SelectOption> lstSlctOptn = new list<SelectOption>();        
        Schema.sObjectType objType = Status_report__c.getSObjectType();         
        Schema.DescribeSObjectResult objDscrb = objType.getDescribe(); 
        map<String, Schema.SObjectField> mapFld = objDscrb.fields.getMap(); 
        List<Schema.PicklistEntry> lstPckLstVls = mapFld.get('status__c').getDescribe().getPickListValues();        
        lstSlctOptn.add(new SelectOption('All', 'All')); 
        for (Schema.PicklistEntry picklistVal : lstPckLstVls)
        { 
            lstSlctOptn.add(new SelectOption(picklistVal.getLabel(), picklistVal.getValue())); 
        }
        
        return lstSlctOptn;        
    }
    
    ///<OBJECTIVE>
    /// Method to delete Status report
    ///</OBJECTIVE>
    
    @AuraEnabled
    public static void deleteStatusReport(String deleteSRId)
    {
        try{
            Status_Report__c sr = new Status_Report__c();
            if(deleteSRId  != null && deleteSRId != '')
            {
                sr = ODS_Data_Utility.fetchStatusReportbyID(deleteSRId);
                delete sr; 
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception in deleteStatusReport method'+ex);
            throw new AuraHandledException('Error deleting status report: ' + ex.getMessage());
        }
    }
    
    ///<OBJECTIVE>
    /// Method to edit Status report
    ///</OBJECTIVE>
    
    @AuraEnabled
    public static String editStatusReport(String editSRId)
    {
        try{
            Status_Report__c objSRforEdit = new Status_Report__c();
            objSRforEdit = ODS_Data_Utility.fetchStatusReportbyID(editSRId);
            
            // Return the edit URL or ID
            return '/apex/AddStatusReport?accntId=' + objSRforEdit.Account_services__r.Account__c + '&srvcId=' + objSRforEdit.Account_services__r.ODS_Services__c + '&srId=' + editSRId;
        }
        catch(Exception ex){
            System.debug('Exception in editStatusReport method'+ex);
            throw new AuraHandledException('Error editing status report: ' + ex.getMessage());
        }
    }
    
    ///<OBJECTIVE>
    /// Method to add Status report
    ///</OBJECTIVE>
    
    @AuraEnabled
    public static String addStatusReport()
    {
        try{
            // This method should return a URL or ID to navigate to the add page
            // For now, we'll return a placeholder URL
            return '/apex/AddStatusReport';
        }
        catch(Exception ex){
            System.debug('Exception in addStatusReport method'+ex);
            throw new AuraHandledException('Error adding status report: ' + ex.getMessage());
        }
    }
}