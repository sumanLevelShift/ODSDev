/**
 * @author           Indumathi    
 * @version          1.0 
 * @date             04-OCT-2016
 * @Status           Developed
 * @description      Controller class for View Status Update visualforce Page
 *
 */


global virtual class ODS_StatusReportController 
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
    public ODS_StatusReportController() 
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
    public PageReference GetStatusReportByAccountServiceID() {
        try{
            ODS_Common_Utility.upsertSessionData(AccountId,ServiceID);
            GetStatusReport();
            GetAccountServices();
            GetStatusReportByAccountServiceIDError = false;
            return null;
        }
        catch(exception e)
        {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
           GetStatusReportByAccountServiceIDError = true;
           ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
           return null;
        }
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
    Public void GetStatusReport()
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
    /// Method to get FromDate.
    ///</OBJECTIVE>
    public PageReference InvokeFromDateMethod()
    {
         system.debug('##From Date:' +FromDate);
         return null;
    }
        
    ///<OBJECTIVE>
    /// Method to get ToDate.
    ///</OBJECTIVE> 
    
    public PageReference InvokeToDateMethod()
    {
         system.debug('##ToDate:' +ToDate);
         return null;
    }
    
    
    
    ///<OBJECTIVE>
    /// Method to Enable disable showPrevious button.
    ///</OBJECTIVE> 
    
    public void showPrevious()
    {
        CurrentPage = CurrentPage- PageSize;
        PageNumber--;
        enableDisablePaginationLinks();     
    }
    
    ///<OBJECTIVE>
    /// Method to Enable disable showNext button.
    ///</OBJECTIVE> 
    
    public void showNext()
    {
        CurrentPage = CurrentPage + PageSize;
        PageNumber++;
        enableDisablePaginationLinks();
    }
    
    ///<OBJECTIVE>
    /// Method to Enable disable showFirst button.
    ///</OBJECTIVE> 
    public void showFirst()
    {
        CurrentPage = 0;
        PageNumber = 1;
        enableDisablePaginationLinks();
    }
    
    ///<OBJECTIVE>
    /// Method to Enable disable showLast button.
    ///</OBJECTIVE>
    
    public void showLast()
    {
        CurrentPage = (Math.mod(TotalRecords, PageSize) == 0) ? TotalRecords - PageSize : (TotalRecords / PageSize) * PageSize;
        PageNumber = (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1);
        enableDisablePaginationLinks();
    }
    
    ///<OBJECTIVE>
    /// Method to enable or disable pagination links
    ///</OBJECTIVE>
    public void enableDisablePaginationLinks()
    {
        if(CurrentPage == 0)
        {
            ShowPrevious = false;
        }
        else    
        {
            ShowPrevious = true;
        }   
        if((TotalRecords - PageSize) <= CurrentPage)
        {
            ShowNext = false;
        }
        else
        {
            ShowNext = true;
        }
        CurrentPageInfo = 'Showing Page ' + PageNumber +   ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1);
    }
    
    ///<OBJECTIVE>
    /// Method to delete Status report
    ///</OBJECTIVE>
    
    public pagereference deleteStatusReport()
    {
        try{
            
            String deleteSRtId = ApexPages.currentPage().getParameters().get('deleteSRId');
            System.debug('deleteSRtId --------------'+deleteSRtId );
            PageReference objPgRfrnce;
            Status_Report__c sr = new Status_Report__c();
            try
            {
                If(deleteSRtId  != null || deleteSRtId != '')
                {
                    sr = ODS_Data_Utility.fetchStatusReportbyID(deleteSRtId);
                    delete sr; 
                }
            }
            catch(Exception ex)
            {
                System.debug('Exception in deleteStatusReport method'+ex);
            }
            
            if(isMobile == true){
                objPgRfrnce = new PageReference(''+getMobileredirectUrl+'/apex/ODS_StatusReport_Mobile?accntId='+AccountId+'&srvcId='+serviceId);
            }
            else{
                
                objPgRfrnce = new PageReference('/apex/StatusReport?accntId='+AccountId+'&srvcId='+serviceId);
                
            }    
            objPgRfrnce.setRedirect(true);      
            return objPgRfrnce; 
         
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ ex.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(ex.getCause()), ex.getMessage(), ex.getStackTraceString(), ex.getTypeName());
            return null;
        }
    }
    
    ///<OBJECTIVE>
    /// Method to edit Status report
    ///</OBJECTIVE>
    
    public pagereference editStatusReport()
    {
        try{
            String editSRtId = ApexPages.currentPage().getParameters().get('editSRId');
            System.debug('editSRtId --------------'+editSRtId );
            Status_Report__c objSRforEdit = new Status_Report__c();
            objSRforEdit = ODS_Data_Utility.fetchStatusReportbyID(editSRtId);
            WorkDayParam = ApexPages.currentPage().getParameters().get('WorkDayParam');
            PageReference pr;
            System.debug('IsMobile: '+isMobile);
            if(isMobile == true){
                System.debug('In web');
                pr = new pagereference(''+getMobileredirectUrl+'/apex/ODS_AddStatusReport_Mobile?accntId='+objSRforEdit.Account_services__r.Account__c+'&srvcId='+objSRforEdit.Account_services__r.ODS_Services__c+'&srId='+editSRtId);                
            } 
            else{
                System.debug('In Mobile');
                pr = new pagereference('/apex/AddStatusReport?accntId='+objSRforEdit.Account_services__r.Account__c+'&srvcId='+objSRforEdit.Account_services__r.ODS_Services__c+'&srId='+editSRtId);
                
            } 
            pr.setRedirect(true);      
            return pr; 
            
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ ex.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(ex.getCause()), ex.getMessage(), ex.getStackTraceString(), ex.getTypeName());
            return null;
        }
    
    }
    
    ///<OBJECTIVE>
    /// Method to add Status report
    ///</OBJECTIVE>
    
     public PageReference AddStatusReport()
    {
        try{
            Status_report__c objSRToday = new Status_Report__c();
            System.debug('service id-----111----'+serviceId);
            System.debug('account id---1111------'+accountId);
            Account_Services__c objAccntSrvc = new Account_Services__c();
            PageReference objPgRfrnce;
            if(accountId != null && serviceId!= null)
            { 
                try
                {
                    objAccntSrvc = ODS_Data_Utility.fetchAccServcesByAccntAndSrvce(accountId,serviceId);
                    System.debug('objAccntSrvc id---1111------'+objAccntSrvc);              
                }
                catch(Exception ex)
                {
                    System.debug('Exception in  AddStatusReport method - 1'+ex);
                }
                
                if(objAccntSrvc.Id != null)
                {
                    try
                    {
                        Date SRDate = ODS_DateUtility.getSRDate(objAccntSrvc.Status_Report_Frequency__c, System.Today());
                        
                        objSRToday = [Select Id, name, Account_Services__c, Status__c, Status_Date__c,  Work_for_the_day__c, Work_for_the_next_day__c,Status_Report_Frequency__c, Issues_and_Concerns__c from Status_report__c 
                                      where Account_Services__c =: objAccntSrvc.Id and Status_Date__c =: SRDate ];
                        
                        System.debug('objSRToday id---1111------'+objSRToday);
                    }
                    catch(Exception ex)
                    {
                        System.debug('Exception in  AddStatusReport method - 2'+ex);
                    }
                }
                
                if(objAccntSrvc.Id != null && objSRToday.Id != null)
                {
                   	
                        if(isMobile == true){
 			    			objPgRfrnce = new PageReference(''+getMobileredirectUrl+'/apex/ODS_AddStatusReport_Mobile?accntId='+AccountId+'&srvcId='+serviceId+'&srId='+objSRToday.Id);
                        }
                        else{
                            objPgRfrnce = new PageReference('/apex/AddStatusReport?accntId='+AccountId+'&srvcId='+serviceId+'&srId='+objSRToday.Id);
                        }                        
		     	 objPgRfrnce.setRedirect(true);                     
                    

                }                
                else
                {
                    if(isMobile == true){
						objPgRfrnce = new PageReference(''+getMobileredirectUrl+'/apex/ODS_AddStatusReport_Mobile?accntId='+AccountId+'&srvcId='+serviceId);
                    }
                    else{
                    	objPgRfrnce = new PageReference('/apex/AddStatusReport?accntId='+AccountId+'&srvcId='+serviceId);
                    }

                 objPgRfrnce.setRedirect(true); 
                    
                }
                
            }
            
            return objPgRfrnce;
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error:Invalid Data. Unable to complete your request due to '+ ex.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(ex.getCause()), ex.getMessage(), ex.getStackTraceString(), ex.getTypeName());
            return null;
        } 
    }
    
    // LWC Wrapper Methods - @AuraEnabled versions for Lightning Web Components
    @AuraEnabled(cacheable=false)
    public static StatusReportWrapper getStatusReports(String accountId, String serviceId, String srStatus, String fromDate, String toDate) {
        StatusReportWrapper wrapper = new StatusReportWrapper();
        ODS_StatusReportController controller = new ODS_StatusReportController();
        
        // Set PageSize if not already set (default to 25 like DataTables)
        if (controller.PageSize == null || controller.PageSize == 0) {
            controller.PageSize = 25;
        }
        
        // Ensure objUser is set (it's set in constructor, but verify)
        if (controller.objUser == null) {
            controller.objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
            controller.PortalUserRole = String.valueOf(controller.objUser.PortalUserRole__c);
            controller.isCustomer = controller.objUser.PortalUserRole__c == 'Customer';
        }
        
        // Set filter parameters
        controller.AccountId = accountId != null ? accountId : 'All';
        controller.ServiceId = serviceId != null ? serviceId : 'All';
        controller.srStatus = srStatus != null ? srStatus : 'All';
        controller.FromDate = fromDate;
        controller.ToDate = toDate;
        
        // Call the main data retrieval method
        controller.GetStatusReport();
        
        // Populate wrapper with results
        wrapper.stRprtList = controller.stRprtList != null ? controller.stRprtList : new List<Status_Report__c>();
        wrapper.accountName = controller.AccountName;
        wrapper.serviceName = controller.ServiceName;
        wrapper.isDaily = controller.isDaily;
        wrapper.totalRecords = controller.TotalRecords != null ? controller.TotalRecords : 0;
        wrapper.pageSize = controller.PageSize != null ? controller.PageSize : 25;
        
        return wrapper;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSessionData() {
        // Get session data if available (matching VF behavior)
        Map<String, String> sessionData = new Map<String, String>();
        try {
            // Try to get session data from ODS_Common_Utility if method exists
            // This would need to be implemented in the utility class
            sessionData.put('accountId', 'All');
            sessionData.put('serviceId', 'All');
        } catch (Exception e) {
            // If no session data, return defaults
            sessionData.put('accountId', 'All');
            sessionData.put('serviceId', 'All');
        }
        return sessionData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SelectOptionWrapper> getAccountOptions() {
        ODS_StatusReportController controller = new ODS_StatusReportController();
        List<SelectOption> options = controller.GetAccountPicklistValues();
        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (SelectOption opt : options) {
            wrappers.add(new SelectOptionWrapper(opt.getLabel(), opt.getValue()));
        }
        return wrappers;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SelectOptionWrapper> getServiceOptions(String accountId) {
        ODS_StatusReportController controller = new ODS_StatusReportController();
        controller.AccountId = accountId;
        List<SelectOption> options = controller.GetServicePicklistValues();
        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (SelectOption opt : options) {
            wrappers.add(new SelectOptionWrapper(opt.getLabel(), opt.getValue()));
        }
        return wrappers;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SelectOptionWrapper> getStatusOptions() {
        List<SelectOption> options = GetStatusPicklistValues();
        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (SelectOption opt : options) {
            wrappers.add(new SelectOptionWrapper(opt.getLabel(), opt.getValue()));
        }
        return wrappers;
    }
    
    @AuraEnabled(cacheable=false)
    public static String deleteStatusReportLWC(String deleteSRId) {
        try {
            if (deleteSRId != null && deleteSRId != '') {
                Status_Report__c sr = ODS_Data_Utility.fetchStatusReportbyID(deleteSRId);
                if (sr != null) {
                    delete sr;
                    return 'Success';
                }
            }
            throw new AuraHandledException('Status Report ID is required');
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting status report: ' + e.getMessage());
        }
    }
    
    // Wrapper classes for LWC
    public class StatusReportWrapper {
        @AuraEnabled public List<Status_Report__c> stRprtList;
        @AuraEnabled public String accountName;
        @AuraEnabled public String serviceName;
        @AuraEnabled public Boolean isDaily;
        @AuraEnabled public Integer totalRecords;
        @AuraEnabled public Integer pageSize;
    }
    
    public class SelectOptionWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public SelectOptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
}