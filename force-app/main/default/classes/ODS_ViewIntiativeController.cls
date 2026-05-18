global class ODS_ViewIntiativeController 
{
    global integer tableSize {get;set;}
    public Boolean isCustomer { get; set; }
    public string TimesheetStatus{get;set;}
    public string FromDate {get;set;}
    public string ToDate {get;set;}
    public string AccountName {get;set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string ServiceName{get;set;}
    public string AccountServiceID {get;set;} 
    public List<Initiatives__c> intiativesheetList {get;set;}
    public boolean IsApprover {get;set;}
    public boolean IsInitiativeApprover {get;set;}
    public string ApproverName {get;set;}
    public string CurrenInitiativeId {get;set;}
    public string CurrenTimesheetId {get;set;}
    public string TimesheetComments {get;set;}
    public string InitiativeComments {get;set;}
    public string DeleteTimeShtId {get;set;}
    public string DeleteInitiativeId {get;set;}
    public Boolean ShowAddTimesheet {get;set;}
    public Boolean ShowDisclaimer {get;set;}
    public string PortalUserRole {get;set;}
    public Boolean IsPortalApprover {get;set;}
    public string CurrentUserName {get;set;}
    public Boolean isMyAccShow{get;set;}
    public string SelectedAccountId{get;set;}
    public string SelectedServiceID{get;set;}
    public string HeaderData {get;set;}
    public string  UrlValue {get;set;}
    public string  URL {get;set;}

    public Time_Sheet_Cost__c objTimesheetCost;
    public  Time_Sheet_Cost__c  objTimesheetCostforNextMonth;
    public List<Contact_Account_Service__c> ContctAccService {get;set;}
    public List<Contact_Account_Service__c> InitiativeContctAccService {get;set;}
    public string ActionType{get;set;}
    
    public string WaitingforApprovalAccountId {get;set;}
    public string WaitingforApprovalServiceId {get;set;}
    public Id currPartnerId = null;
    public Id currPartnerCont = null;
     public Decimal totalEstimatedHours { get; set; }
    public Decimal totalConsumedHours { get; set; }
    public Decimal totalRemainingHours { get; set; }
    public String InitiativeSearchText { get; set; }
    
    public ODS_ViewIntiativeController() 
    {
         InitiativeSearchText = '';
        system.debug('InitiativeSearchText'+InitiativeSearchText);
        string URLStatus = System.CurrentPageReference().getparameters().get('TimesheetStatus'); 
        system.debug('===URLStatus==='+URLStatus);
        if(URLStatus != null){
            TimesheetStatus= 'submitted';
        }
        else{
            TimesheetStatus= 'All';
        }  
        currentUserName = UserInfo.getName(); 
        
        HeaderData = ApexPages.currentPage().getHeaders().get('Host');
        UrlValue =Apexpages.currentPage().getUrl();
        URL ='https://' + headerdata+ urlvalue;
                
        // GetTimesheet();
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        currPartnerId = objUser.Contact.AccountId;
        currPartnerCont =  objUser.ContactId;  
        PortalUserRole = objUser.PortalUserRole__c;
        IsPortalApprover = false;
        if(objUser.PortalUserRole__c == 'Customer')
        { 
            isCustomer= true;            
            ShowAddTimesheet = false;
            ShowDisclaimer = false;
        }else{
            isCustomer= false;
            ShowAddTimesheet = true;
            ShowDisclaimer = true;
            
        } 
        
        //currPartnerId = [SELECT Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].Contact.AccountId;
        System.debug('Current Partner AccountId: '+currPartnerId);
                   

    }
    public void calculateHours(Id accId) {
        System.debug('AccountId1: '+accId);
        // Aggregate the sum of Estimated, Consumed, and Remaining Hours for the Account's Initiatives
        AggregateResult[] results = [
            SELECT SUM(Estimated_Hours__c) totalEstimated,
                   SUM(Submitted_Hours__c) totalConsumed,
                   SUM(Remaining_Hours__c) totalRemaining
            FROM Initiatives__c WHERE Account_Service__r.Account__c = :accId
           
        ];
        
        // Assign the aggregated values to controller properties
        if (!results.isEmpty()) {
            totalEstimatedHours = (Decimal)results[0].get('totalEstimated');
            totalConsumedHours = (Decimal)results[0].get('totalConsumed');
            totalRemainingHours = (Decimal)results[0].get('totalRemaining');
        }
    }
    
    public void GetSearchResults()
    {
        system.debug('##From Date:' +FromDate);
        //CurrentPage = 0;
        //PageNumber=1;
        // enableDisablePaginationLinks();
        GetTimesheet();
        
    }
    
    public void GetLoggedUserAccountService()
    {
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId()); 
        PortalUserRole = objUser.PortalUserRole__c;
        //IsPortalApprover = objUser.Contact.Is_Approver__c;
        if(PortalUserRole == 'Customer')
        {   
            List<Contact> cnt = new List<Contact>();
            cnt = ODS_Data_Utility.FetchAccountIdByCustomer(objUser.ContactId);
            if(cnt.size() > 0){
                AccountId = cnt[0].AccountId;
            }
            else{
                AccountId = 'All';
            }
            List<Account_Services__c> accService = new List<Account_Services__c>();
            accService = ODS_Data_Utility.fetchAccServcesByAcc(AccountId);
            if(accService.size() > 0){
                ServiceId = accService[0].ODS_Services__c;
            }
            else{
                ServiceId = 'All';
            }
            
        }
        else
        {
            AccountId = 'All';
            ServiceId = 'All';
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
    
    public void GetAccountServices()
    {
        
        if(AccountId == 'All' || ServiceId == 'All')
        {
            ShowAddTimesheet = false;
            if(PortalUserRole == 'Customer')
            {
                ShowDisclaimer = false;
            }
            else{
                ShowDisclaimer = true;
            }
        }
        else
        {
            ShowDisclaimer = false;
            if(PortalUserRole == 'Customer')
            {
                ShowAddTimesheet = false;
            }
            else
            {
                ShowAddTimesheet = true;
            }
            List<Account_Services__c > accServList = new List<Account_Services__c >();
            accServList = ODS_Data_Utility.fetchAccServcesByServiceAccount(AccountId, ServiceId);
            if(accServList.size() > 0){
                AccountServiceID = accServList[0].Id;
                calculateHours(AccountId);
            }
            else{
                AccountServiceID = '';
            }
        }
         
    }
    public PageReference GetTimesheetByAccountServiceID() {
        ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);
        GetAccountServices();          
        GetTimesheet();
        
        
        return null;
    }
    Public void GetTimesheet()
    {
        system.debug('@@@ GetTimesheet');        
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());   
        PortalUserRole = objUser.PortalUserRole__c;
        
        IsPortalApprover = false;
        if(objUser.ContactId!= null)
        {        
            system.debug('###ServiceId for contact account inside get timesheet: ' +ServiceId);
            ContctAccService  = new List<Contact_Account_Service__c>();
            ContctAccService = ODS_Data_Utility.fetchContactAccountService(objUser.ContactId, ServiceId);
            system.debug('@@@@@@ContctAccService:'+ContctAccService );        
            if(ContctAccService.size() > 0){
                IsPortalApprover = ContctAccService[0].Is_Approver__c;
               
            }
            else{
                IsPortalApprover = False;
            }
            
            InitiativeContctAccService  = new List<Contact_Account_Service__c>();
            InitiativeContctAccService  = ODS_Data_Utility.fetchInitiativeContactAccountService(objUser.ContactId, ServiceId);
            if(InitiativeContctAccService.size() > 0 ){
                IsInitiativeApprover = InitiativeContctAccService[0].Is_initiate_approver__c;
            }
            else{
               IsInitiativeApprover = False;
            }
        }
        
        Set<String> allAccountIds = new Set<string>();
        Set<String> allServiceIds = new Set<string>();
        
        system.debug('timesheetaccount'+AccountId);

           String initiativeFilter = String.escapeSingleQuotes(InitiativeSearchText).toLowerCase();
        // String initiativeFilter = 'Sathish'; 
        system.debug('initiativeFilter1'+initiativeFilter);
        Set<Id> initIds = new Set<Id>();    
        if (String.isNotBlank(initiativeFilter) && initiativeFilter.length() > 2) {
            // Perform SOSL search
            List<List<SObject>> searchResults = [
                FIND :initiativeFilter
                IN ALL FIELDS
                RETURNING 
                Estimate__c (
                    Initiative_Lookup__c, Task_Components__c 
                    WHERE Initiative_Lookup__r.Account_Service__c = :AccountServiceID 
                    ORDER BY LastModifiedDate DESC LIMIT 1000
                ),
                Initiatives__c (
                    Id, Brief_Description__c, Business_Challenge__c, Technology_Details__c, 
                    Persona_s_Involved__c, Outcome_of_our_solution__c, Initiative_Programming_Reason__c 
                    WHERE Account_Service__c = :AccountServiceID 
                    ORDER BY LastModifiedDate DESC LIMIT 1000
                )
            ];
            // Process SOSL results
            List<Estimate__c> estimateResults = (List<Estimate__c>) searchResults[0];
                        system.debug('estimateResults'+estimateResults);

            for (Estimate__c estimate : estimateResults) {
                if (estimate.Initiative_Lookup__c != null) {
                    initIds.add(estimate.Initiative_Lookup__c);
                }
            }
            
            List<Initiatives__c> initiativeResults = (List<Initiatives__c>) searchResults[1];
            system.debug('initiativeResults'+initiativeResults);
            for (Initiatives__c initiative : initiativeResults) {
                initIds.add(initiative.Id);
            }
        }

        
        string Query;
        String fieldQuery = 'id,name,Account_Service__c,Account_Service__r.ODS_Service_Name__c,Account_Service__r.ODS_Account_Name__c,Estimated_hours__c,Submitted_Hours__c,JIRA_ID__c,Offshore_Estimate__c , LastModifiedDate,Status__c,Submitted_Utilization__c,Remaining_Hours__c,Utilization__c,Status_Order__c';
        string whereQuery = 'WHERE ';
        whereQuery = (whereQuery).removeEnd('AND');
            system.debug('@@@@ whereQuery: ' + whereQuery );
        
        system.debug('insidetimesheet'+AccountId);
        system.debug('insidetimesheet'+ServiceId );
        try
        {
             if (String.isNotBlank(initiativeFilter) && initiativeFilter.length() >2 ) {
                whereQuery += ' Id IN :initIds AND ';
            }           
            System.debug('Fromdate'+Fromdate+'Todate'+Todate);
            Date dt;
            System.debug('TimesheetStatus'+TimesheetStatus);
            String FromDt;
            String ToDt;
                        
            List<ID> AccountServiceID = new List<ID>();
            
            if( AccountId.startsWith('001') && ServiceId.startsWith('a2') )
            {
                   List<Account_Services__c> AccountService = [select id from Account_Services__c where Account__c =: AccountId and  ODS_Services__c =:ServiceId];
                   for(Account_Services__c ASId : [select id from Account_Services__c where Account__c =: AccountId and  ODS_Services__c =:ServiceId])
                   {
                             AccountServiceID.add(ASId.id);
                   }
                   //String AccountServiceID = string.valueOf( AccountService[0].id );
                   whereQuery += 'Account_Service__c in :AccountServiceID AND' ; 
                   System.debug('whereQuery'+whereQuery);     
                                                     
                   
                   
                           if(TimesheetStatus != 'All')
                           {
                                         whereQuery +=  ' Status__c =: TimesheetStatus' ;	//for individual status by PO
                           }else
                           {                      
                                         whereQuery += '  Status__c != : TimesheetStatus  '; 
                           }
                                   
            }
            
           
            else if(AccountId.startsWith('001') && !ServiceId.startsWith('a2'))
            {
                     for(Account_Services__c ASId : [select id from Account_Services__c where Account__c =: AccountId])
                     {
                                    AccountServiceID.add(ASId.id);
                     }
                     whereQuery += 'Account_Service__c in :AccountServiceID AND' ; 
                     
                    
                           if(TimesheetStatus != 'All')
                           {
                                         whereQuery +=  ' Status__c =: TimesheetStatus' ;
                           }else
                           {                       
                                         whereQuery += ' Status__c != : TimesheetStatus  '; 
                                         
                           }
                    
            }
            else if(!AccountId.startsWith('001') && ServiceId.startsWith('a2'))
            {
                  for(Account_Services__c ASId : [select id from Account_Services__c where  ODS_Services__c =:ServiceId])
                  {
                           AccountServiceID.add(ASId.id);
                  }
                  whereQuery += 'Account_Service__c in :AccountServiceID AND' ;   
                  
                  
                           if(TimesheetStatus != 'All')
                           {
                                         whereQuery +=  ' Status__c =: TimesheetStatus' ;
                           }else
                           {                       
                                         whereQuery += ' Status__c != : TimesheetStatus  '; 
                                        
                           }
                  
            }
            else 
            {
                
                           if(TimesheetStatus != 'All')
                           {
                                         whereQuery +=  ' Status__c =: TimesheetStatus' ;
                           }else
                           {                      
                                         whereQuery += ' Status__c != : TimesheetStatus  '; 
                                         
                           }
                 
                             
            }
            if(PortalUserRole == 'Customer')
            {
                 string Status1 = 'Saved';   
                   
                 Query = 'SELECT ' + fieldQuery + ' FROM Initiatives__c ' + whereQuery + ' and Status__c != : Status1 ORDER BY Status_Order__c ,LastModifiedDate DESC';
            }
            //Updated by Mani and Team
            else if(PortalUserRole == 'Partner') {
                if(currPartnerId != null && currPartnerCont != null)
                    Query = 'SELECT ' + fieldQuery + ' FROM Initiatives__c ' + whereQuery + ' and Account_Service__r.Account__r.Channel_Partner__c =: currPartnerId and Account_Service__r.Account__r.Channel_Partner_Contact__c =:currPartnerCont ' ;
                else
                    Query = 'SELECT ' + fieldQuery + ' FROM Initiatives__c ' + whereQuery + ' ORDER BY LastModifiedDate  DESC';
            }
            else{  
                  Query = 'SELECT ' + fieldQuery + ' FROM Initiatives__c ' + whereQuery + ' ORDER BY LastModifiedDate  DESC';
                  
            }
            system.debug('@@@@ Query:' + Query);
            intiativesheetList = Database.query(Query);  
            system.debug('@@@@@@@ intiativesheetList:' +intiativesheetList);  
                     
        }
        
        catch(Exception e)
        {
            System.debug('Invalid date!!');
        }
    }
    
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
    
    public Set<string> GetAllServices()
    {
        Set<string> serviceIdSet = new Set<string>();
        for(ODS_Services__c odsService: ODS_Data_Utility.GetAllServices())
        {
            serviceIdSet.add(odsService.Id);
        }
        return serviceIdSet;
    }
    
    public PageReference AddInitiative()
    {
        PageReference pgRef = new PageReference('/apex/InitiativePage?AccServiceId='+AccountServiceID);
        pgRef.setRedirect(true);
        return pgRef;
    }
        
    
    public PageReference ApproveInitiative()
    {
         Initiatives__c initiative = new Initiatives__c(id=CurrenInitiativeId);
         initiative.Status__c = 'Initiative Approved';
         if(InitiativeComments != null)
             initiative.Comments__c = InitiativeComments.trim();
         initiative.Approver_Name__c = UserInfo.GetUserID();
         //initiative.Approved_Date__c = Date.Today();
         initiative.Initiative_Approved_Date__c = Date.Today(); 
         system.debug('III initiative id :' + initiative.id);
         update initiative;
         
         String InitiativeUrl = System.Label.ODS_SalesforceURL;
         String url = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+CurrenInitiativeId+'&AccServiceId='+AccountServiceID;
         Initiatives__c init = [select Client_side_Contact__r.Name, Status__c  from Initiatives__c where id =: CurrenInitiativeId];
         ODS_InitiativeController.sendEmailInitiative(CurrenInitiativeId, AccountServiceID, init.Status__c, init.Client_side_Contact__r.Name,url); 
         return null;
    }
    
    public PageReference RejectInitiative()
    {
           Initiatives__c initiative = new Initiatives__c(id=CurrenInitiativeId);
           initiative.Status__c = 'Re-evaluate';
           if(InitiativeComments != null)
               initiative.Comments__c = InitiativeComments.trim();
           initiative.Approver_Name__c = UserInfo.GetUserID();
           initiative.Initiative_Re_Evaluation_Date__c = Date.Today();
           update initiative;
           String InitiativeUrl = System.Label.ODS_SalesforceURL;
           String url = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+CurrenInitiativeId+'&AccServiceId='+AccountServiceID;
           Initiatives__c init = [select Client_side_Contact__r.Name, Status__c  from Initiatives__c where id =: CurrenInitiativeId];
           ODS_InitiativeController.sendEmailInitiative(CurrenInitiativeId, AccountServiceID, init.Status__c, init.Client_side_Contact__r.Name,url); 
           return null;
    }
         
    public PageReference ViewInitiative()
    {
         Initiatives__c initiativeRecById = ODS_Data_Utility.FetchInitiativeByID(CurrenInitiativeId);
         
                
         AccountServiceID = initiativeRecById.Account_Service__c;
         String initiativeStats = initiativeRecById.Status__c;
         System.debug('@@@@@@@@CurrenInitiativeId in View Initiative Method'+CurrenInitiativeId);
         PageReference pgRef = new PageReference('/apex/InitiativePage?CurrenInitiativeId=' +initiativeRecById.id + '&AccServiceId='+AccountServiceID+ '&Status='+initiativeStats);

      
         pgRef.setRedirect(true);
         return pgRef;
    }
    
    
    
    public PageReference DeleteInitiative()
    {
        System.debug('##DeleteInitiativeId'+DeleteInitiativeId);
        Initiatives__c initiativedelete = new Initiatives__c(id=DeleteInitiativeId);
        if(initiativedelete != null){
             delete initiativedelete;
        }
        GetTimesheet();
        return null;
    }
    
    
    public Date FormatStringToDate(string dateString)
    {
        string[] dateArr = dateString.split('-');
        return date.Parse(dateArr[1]+'/'+dateArr[0]+'/'+dateArr[2]);
    }
    
    public List<SelectOption> GetAccountPicklistValues()
    {
        List<SelectOption> lstSlctOptn = new list<SelectOption>(); 
        ODS_Common_Utility objUtility = new ODS_Common_Utility();
        lstSlctOptn = objUtility.getCustomersByLoggedInUser();
        return lstSlctOptn;  
    }
    
    
    /// <OBJECTIVE>
    /// Fetch the Status values dynamically and returns.
    /// </OBJECTIVE>
    public List<SelectOption> GetStatusPicklistValues()
    {
        List<SelectOption> lstSlctOptn = new list<SelectOption>();        
        Schema.sObjectType objType = Initiatives__c.getSObjectType();       //Get the token of the SObject  
        Schema.DescribeSObjectResult objDscrb = objType.getDescribe(); 
        map<String, Schema.SObjectField> mapFld = objDscrb.fields.getMap(); 
        List<Schema.PicklistEntry> lstPckLstVls = mapFld.get('status__c').getDescribe().getPickListValues();        
        lstSlctOptn.add(new SelectOption('All', 'All'));            
        
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());         
        system.debug('$$$@@lstPckLstVls : ' + lstPckLstVls);
        if(objUser.PortalUserRole__c == 'Customer')
        {
         		 
            for (Schema.PicklistEntry picklistVal : lstPckLstVls)
            { 
                if(picklistVal.getLabel() != 'Saved'){
                    lstSlctOptn.add(new SelectOption(picklistVal.getLabel(), picklistVal.getValue())); 
                }
            }
        }
        else
        {
            for (Schema.PicklistEntry picklistVal : lstPckLstVls)
            { 
                lstSlctOptn.add(new SelectOption(picklistVal.getLabel(), picklistVal.getValue())); 
            }
        }
        return lstSlctOptn;        
    } 
    
    public PageReference InvokeFromDateMethod()
    {
        system.debug('##From Date:' +FromDate);
        return null;
    }
    
    public PageReference InvokeToDateMethod()
    {
        system.debug('##ToDate:' +ToDate);
        return null;
    }
    
    public PageReference GetTimeSheetIdFromAction()
    {
        system.debug('##CurrenInitiativeId:' +CurrenInitiativeId);    
        system.debug('##ActionType:'+ActionType);    
        system.debug('###AccountServiceID:' +AccountServiceID);
        
        /*Initiatives__c initiative = new Initiatives__c(id=CurrenInitiativeId);
        if(ActionType == 'Approve'){
            initiative.Status__c  = 'Initiative Approved';
        }
        else if(ActionType == 'Reject'){
            initiative.Status__c  = 'Re-evaluate';
            initiative.Revised_Approved__c = true;
        }
        initiative.Approver_Name__c = UserInfo.GetUserID();
        initiative.Approved_Date__c = Date.Today();        
        Update initiative;
                   
        
        if(ActionType == 'Approve'){
            ODS_InitiativeController.sendEmailInitiative(CurrenInitiativeId, AccountServiceID, init.Status__c, init.Client_side_Contact__r.Name,url); 
        }
        else if(ActionType == 'Reject'){
            
            ODS_InitiativeController.sendEmailInitiative(CurrenInitiativeId, AccountServiceID, init.Status__c, init.Client_side_Contact__r.Name,url); 
        }
        ODS_InitiativeController.sendEmailInitiative(CurrenInitiativeId, AccountServiceID, init.Status__c, init.Client_side_Contact__r.Name,URL); */
        return null;
    }
    
    // ============================================
    // LWC Wrapper Methods - @AuraEnabled versions
    // ============================================
    
    /**
     * @description Get initiatives based on filter criteria
     * @param accountId Selected account ID
     * @param serviceId Selected service ID
     * @param status Selected status filter
     * @param searchText Search text (minimum 3 characters)
     * @return InitiativeWrapper with list and metadata
     */
    @AuraEnabled(cacheable=false)
    public static InitiativeWrapper getInitiatives(
        String accountId, 
        String serviceId, 
        String status, 
        String searchText
    ) {
        InitiativeWrapper wrapper = new InitiativeWrapper();
        ODS_ViewIntiativeController controller = new ODS_ViewIntiativeController();
        
        // Ensure objUser is set (it's set in constructor, but verify)
        User objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        controller.PortalUserRole = objUser.PortalUserRole__c;
        controller.isCustomer = objUser.PortalUserRole__c == 'Customer';
        controller.currPartnerId = objUser.Contact != null ? objUser.Contact.AccountId : null;
        controller.currPartnerCont = objUser.ContactId;
        
        // Set filter parameters
        controller.AccountId = accountId != null ? accountId : 'All';
        controller.ServiceId = serviceId != null ? serviceId : 'All';
        controller.TimesheetStatus = status != null ? status : 'All';
        controller.InitiativeSearchText = searchText != null ? searchText : '';
        
        // Get account service ID if account and service are selected
        if (controller.AccountId != 'All' && controller.ServiceId != 'All') {
            controller.GetAccountServices();
        }
        
        // Set ServiceId for approver check (needed in GetTimesheet)
        if (controller.ServiceId != 'All') {
            // Get approver status
            if (objUser.ContactId != null) {
                List<Contact_Account_Service__c> initiativeContctAccService = 
                    ODS_Data_Utility.fetchInitiativeContactAccountService(
                        objUser.ContactId, 
                        controller.ServiceId
                    );
                if (initiativeContctAccService.size() > 0) {
                    controller.IsInitiativeApprover = initiativeContctAccService[0].Is_initiate_approver__c;
                } else {
                    controller.IsInitiativeApprover = false;
                }
            }
        }
        
        // Call the main data retrieval method
        controller.GetTimesheet();
        
        // Populate wrapper with results
        wrapper.initiativesList = controller.intiativesheetList != null ? controller.intiativesheetList : new List<Initiatives__c>();
        wrapper.totalEstimatedHours = controller.totalEstimatedHours != null ? controller.totalEstimatedHours : 0;
        wrapper.totalConsumedHours = controller.totalConsumedHours != null ? controller.totalConsumedHours : 0;
        wrapper.totalRemainingHours = controller.totalRemainingHours != null ? controller.totalRemainingHours : 0;
        wrapper.accountServiceID = controller.AccountServiceID;
        wrapper.isCustomer = controller.isCustomer;
        wrapper.portalUserRole = controller.PortalUserRole;
        wrapper.isInitiativeApprover = controller.IsInitiativeApprover;
        
        return wrapper;
    }
    
    /**
     * @description Get account options for dropdown
     * @return List of SelectOptionWrapper for accounts
     */
    @AuraEnabled(cacheable=true)
    public static List<SelectOptionWrapper> getAccountOptions() {
        ODS_ViewIntiativeController controller = new ODS_ViewIntiativeController();
        List<SelectOption> options = controller.GetAccountPicklistValues();
        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (SelectOption opt : options) {
            wrappers.add(new SelectOptionWrapper(opt.getLabel(), opt.getValue()));
        }
        return wrappers;
    }
    
    /**
     * @description Get service options for dropdown based on selected account
     * @param accountId Selected account ID
     * @return List of SelectOptionWrapper for services
     */
    @AuraEnabled(cacheable=true)
    public static List<SelectOptionWrapper> getServiceOptions(String accountId) {
        ODS_ViewIntiativeController controller = new ODS_ViewIntiativeController();
        controller.AccountId = accountId;
        List<Account_Services__c> accountServices = ODS_Data_Utility.fetchAccServcesByAcc(accountId);
        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        
        wrappers.add(new SelectOptionWrapper('All Services', 'All'));
        for (Account_Services__c accService : accountServices) {
            wrappers.add(new SelectOptionWrapper(
                accService.ODS_Services__r.Name__c, 
                accService.ODS_Services__c
            ));
        }
        return wrappers;
    }
    
    /**
     * @description Get status picklist options
     * @return List of SelectOptionWrapper for status values
     */
    @AuraEnabled(cacheable=true)
    public static List<SelectOptionWrapper> getStatusOptions() {
        ODS_ViewIntiativeController controller = new ODS_ViewIntiativeController();
        List<SelectOption> options = controller.GetStatusPicklistValues();
        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (SelectOption opt : options) {
            wrappers.add(new SelectOptionWrapper(opt.getLabel(), opt.getValue()));
        }
        return wrappers;
    }
    
    /**
     * @description Delete an initiative record
     * @param initiativeId ID of the initiative to delete
     * @return Success message
     */
    @AuraEnabled
    public static String deleteInitiative(String initiativeId) {
        try {
            if (initiativeId == null) {
                throw new IllegalArgumentException('Initiative ID cannot be null');
            }
            
            Initiatives__c initiative = new Initiatives__c(Id = initiativeId);
            delete initiative;
            
            return 'Initiative deleted successfully';
            
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting initiative: ' + e.getMessage());
        }
    }
    
    /**
     * @description Approve an initiative
     * @param initiativeId ID of the initiative to approve
     * @param comments Approval comments
     * @param accountServiceId Account Service ID
     * @return Success message
     */
    @AuraEnabled
    public static String approveInitiative(String initiativeId, String comments, String accountServiceId) {
        try {
            ODS_ViewIntiativeController controller = new ODS_ViewIntiativeController();
            controller.CurrenInitiativeId = initiativeId;
            controller.InitiativeComments = comments;
            controller.AccountServiceID = accountServiceId;
            controller.ApproveInitiative();
            
            return 'Initiative approved successfully';
            
        } catch (Exception e) {
            throw new AuraHandledException('Error approving initiative: ' + e.getMessage());
        }
    }
    
    /**
     * @description Reject an initiative
     * @param initiativeId ID of the initiative to reject
     * @param comments Rejection comments
     * @param accountServiceId Account Service ID
     * @return Success message
     */
    @AuraEnabled
    public static String rejectInitiative(String initiativeId, String comments, String accountServiceId) {
        try {
            ODS_ViewIntiativeController controller = new ODS_ViewIntiativeController();
            controller.CurrenInitiativeId = initiativeId;
            controller.InitiativeComments = comments;
            controller.AccountServiceID = accountServiceId;
            controller.RejectInitiative();
            
            return 'Initiative rejected successfully';
            
        } catch (Exception e) {
            throw new AuraHandledException('Error rejecting initiative: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get user context information
     * @return Map containing user role and permissions
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUserContext() {
        try {
            User currentUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
            ODS_ViewIntiativeController controller = new ODS_ViewIntiativeController();
            
            Boolean isInitiativeApprover = false;
            if (currentUser.ContactId != null) {
                List<Contact_Account_Service__c> initiativeContctAccService = 
                    ODS_Data_Utility.fetchInitiativeContactAccountService(currentUser.ContactId, null);
                if (initiativeContctAccService.size() > 0) {
                    isInitiativeApprover = initiativeContctAccService[0].Is_initiate_approver__c;
                }
            }
            
            return new Map<String, Object>{
                'portalUserRole' => currentUser.PortalUserRole__c,
                'isCustomer' => currentUser.PortalUserRole__c == 'Customer',
                'isInitiativeApprover' => isInitiativeApprover,
                'contactId' => currentUser.ContactId
            };
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving user context: ' + e.getMessage());
        }
    }
    
    /**
     * @description Validate if user can delete initiative
     * @param initiativeId ID of the initiative
     * @return Boolean indicating if deletion is allowed
     */
    @AuraEnabled
    public static Boolean canDeleteInitiative(String initiativeId) {
        try {
            User currentUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
            String portalUserRole = currentUser.PortalUserRole__c;
            
            // Customers and Partners cannot delete
            if (portalUserRole == 'Customer' || portalUserRole == 'Partner') {
                return false;
            }
            
            // Get initiative status
            Initiatives__c initiative = [
                SELECT Id, Status__c 
                FROM Initiatives__c 
                WHERE Id = :initiativeId 
                LIMIT 1
            ];
            
            // Cannot delete if status is in restricted list
            Set<String> restrictedStatuses = new Set<String>{
                'Initiative Approved',
                'Initiative Submitted',
                'Active Initiative',
                'Initiative Delivered',
                'On Hold',
                'Approved After Re-evaluation'
            };
            
            return !restrictedStatuses.contains(initiative.Status__c);
            
        } catch (Exception e) {
            System.debug('Error validating delete permission: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Validate if user can approve/reject initiative
     * @param initiativeId ID of the initiative
     * @return Boolean indicating if approve/reject is allowed
     */
    @AuraEnabled
    public static Boolean canApproveRejectInitiative(String initiativeId) {
        try {
            User currentUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
            String portalUserRole = currentUser.PortalUserRole__c;
            
            // Get initiative status
            Initiatives__c initiative = [
                SELECT Id, Status__c, Account_Service__c
                FROM Initiatives__c 
                WHERE Id = :initiativeId 
                LIMIT 1
            ];
            
            // Must be in "Initiative Submitted" status
            if (initiative.Status__c != 'Initiative Submitted') {
                return false;
            }
            
            // Check if customer approver
            if (portalUserRole == 'Customer') {
                if (currentUser.ContactId != null) {
                    List<Contact_Account_Service__c> initiativeContctAccService = 
                        ODS_Data_Utility.fetchInitiativeContactAccountService(
                            currentUser.ContactId, 
                            initiative.Account_Service__c
                        );
                    if (initiativeContctAccService.size() > 0) {
                        return initiativeContctAccService[0].Is_initiate_approver__c;
                    }
                }
                return false;
            }
            
            // Technical Account Manager or Practice Head can approve/reject
            return portalUserRole == 'Technical Account Manager' || portalUserRole == 'Practice Head';
            
        } catch (Exception e) {
            System.debug('Error validating approve/reject permission: ' + e.getMessage());
            return false;
        }
    }
    
    // Wrapper classes for LWC
    public class InitiativeWrapper {
        @AuraEnabled public List<Initiatives__c> initiativesList;
        @AuraEnabled public Decimal totalEstimatedHours;
        @AuraEnabled public Decimal totalConsumedHours;
        @AuraEnabled public Decimal totalRemainingHours;
        @AuraEnabled public String accountServiceID;
        @AuraEnabled public Boolean isCustomer;
        @AuraEnabled public String portalUserRole;
        @AuraEnabled public Boolean isInitiativeApprover;
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