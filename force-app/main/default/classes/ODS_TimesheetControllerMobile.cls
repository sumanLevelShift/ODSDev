/**
* @author           Gnana Prakash
* @version          1.0 
* @date             03-OCT-2016
* @Status           Developed
* @description      This is the controller class for View Timesheet Page
*
*/

global class ODS_TimesheetControllerMobile
{
    public boolean AllowFutureTimesheets {get;set;}
    public string CurrenTimesheetId {get;set;}
    public string PassedTimesheetJSON {get;set;}
    public string currentUserName {get;set;}
    public string AccountName {get;set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string ServiceName{get;set;}
    public string CurrentAccServiceId {get;set;}
    public string TimesheetComments {get;set;}
    public boolean IsPortalApprover {get;set;}
    public string PortalUserRole {get;set;}
    public string TimeshtJSONtoBind {get;set;}
    public string CurrentTimeSheetStatus {get;set;}
    public string PassedWeekFromDate{get;set;}
    public string PassedWeekToDate{get;set;}
    public boolean isMyAccShow {get;set;}
    public boolean isCustomer {get;set;}
    public Time_Sheet_Cost__c objTimesheetCost;
    public Date dtStartDate;
    public Date dtEndDate;
    public String CurrentDate {get; set;}
    public  Time_Sheet_Cost__c  objTimesheetCostforNextMonth;   
    public List<AggregateResult> resourceNameLst{get;set;}
    public List<AggregateResult> InitiativeLst{get;set;}
    public Boolean ShowPDFButton {get;set;} 
    public string resourceNameJSONtoBind {get;set;}
    public string initiativeJSONtoBind {get;set;}
    //Added by Indhu on 04/09/2019
    public string initiativeJSONtoBindWithStatus {get;set;}
    public List<Contact_Account_Service__c> ContctAccService {get;set;}
    public Boolean IsTimesheetInsert {get; set;}
    public string hdnActionValue {get; set;}
    public string invalidInitiativeName {get; set;}
    public decimal invalidInitiateEstimtdHrs {get; set;}
    public decimal inavlidInitiateRemHrs {get; set;}
    Map<string, Initiatives__c> GenericRemaining {get; set;}
    public string getMobileredirectUrl = label.ODS_MobileRedirectURL;
    
    public Boolean SaveTimesheetError {get; set;}
    public Boolean GetWeeklyTimesheetError {get; set;}
    public Boolean GetTimesheetByAccountServiceIDError {get; set;}
    public Boolean RejectTimesheetError {get; set;}
    public Boolean ApproveTimesheetError {get; set;}
    public List<selectOption> optionsClientCustomer {get; set;}
    public string ClientContact {get;set;}
    public Boolean NoApprover {get; set;}
    public String ApproverName {get; set;}
    public string tpmJSONtoBind {get;set;}
    public string TechnicalProjectManager {get; set;}    
    public List<AggregateResult> TpmLst{get;set;}
    public string TechnicalProjectManagerName {get; set;} 
    public string InitId {get; set;} 
    public string SelectedInitiativeBillingType {get; set;} 
    public static boolean NonABCType {get;set;}
    public static boolean deliveryTeam {get;set;}
    public static string workOrderListJson  {get;set;}
    
    public string invoiceFreqAccSer {get;set;}
    public boolean biWeeklyValidFailed {get;set;}
    public string biWeeklyConfirmationMessage {get;set;}
	public boolean monthlyValidFailed {get;set;}
    public string monthlyConfirmationMessage {get;set;}
    public boolean semiMonthlyValidFailed {get;set;}
    public string semiMonthlyConfirmationMessage {get;set;}
    
    Public boolean noActiveWorkOrderNext30Days {get;set;}
    Public String noActiveWorkOrderNext30DaysMsg {get;set;}
    public boolean noActiveWorkOrderDuration {get;set;}
    public ODS_TimesheetControllerMobile()
    {
        workOrderListJson ='';        
        GenericRemaining= new Map<string, Initiatives__c>();
        optionsClientCustomer=new List<selectOption>();
        TechnicalProjectManagerName='';
        NonABCType=false;
        invoiceFreqAccSer='';
        biWeeklyValidFailed=false;
        biWeeklyConfirmationMessage='';
        monthlyValidFailed=false;
        monthlyConfirmationMessage='';
        semiMonthlyValidFailed=false;
        semiMonthlyConfirmationMessage='';
        
        noActiveWorkOrderNext30Days=false;
        noActiveWorkOrderNext30DaysMsg ='';
        noActiveWorkOrderDuration=false;
        System.debug('@@@@hdnActionValue'+hdnActionValue);
        system.debug('@@@ Inside ODS_TimesheetController');
        Datetime currentDateTime = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        CurrentDate  = currentDateTime.format('MM/dd/yyyy'); // formats the date
        deliveryTeam=false;
        objTimesheetCost = new Time_Sheet_Cost__c();
        CurrentAccServiceId = ApexPages.CurrentPage().getParameters().get('AccServiceId');
        CurrenTimesheetId = ApexPages.CurrentPage().getParameters().get('Id');
        CurrentTimeSheetStatus = ApexPages.CurrentPage().getParameters().get('Status');        
        PassedWeekFromDate = ApexPages.CurrentPage().getParameters().get('WeekStart');
        currentUserName = UserInfo.getName();       
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId()); 
        system.debug('@@@@@@objUser.ContactId:'+objUser.Contact.Id );
        if(objUser.Profile.Name==System.Label.DeliveryRoleProfile){
            deliveryTeam=true; 
        }
        PortalUserRole = objUser.PortalUserRole__c;
        IsPortalApprover = False;
        if(CurrentAccServiceId != null){
            List<Account_Services__c > accServiceExist = new List<Account_Services__c >();
            accServiceExist = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
            if(accServiceExist.size() >0){
                AllowFutureTimesheets=accServiceExist[0].Allow_Future_Timesheets__c;
                invoiceFreqAccSer=accServiceExist[0].Invoice_Frequency__c;
                if(accServiceExist[0].Account__r.Customer_Type__c !='ABC Type'){
                    NonABCType=true;
                }
                /*list<Work_Order__c> workOrderList = new List<Work_Order__c>();
                workOrderList=[SELECT Client_Name__c,CreatedDate,Project_End_Date__c,Project_Start_Date__c FROM Work_Order__c WHERE Client_Name__c=:accServiceExist[0].Account__c AND SubCategory__c LIKE '%Subscription%' ORDER BY CreatedDate DESC NULLS FIRST];
                workOrderListJson =JSON.serialize(workOrderList);*/
                
            }
        }
        if(objUser.ContactId!= null)
        {        
            if(CurrentAccServiceId != null){
                List<Account_Services__c > accServiceById = new List<Account_Services__c >();
                accServiceById = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
                if(accServiceById.size() >0){
                    ContctAccService = new List<Contact_Account_Service__c>();
                    ContctAccService  = ODS_Data_Utility.fetchContactAccountService(objUser.ContactId, accServiceById[0].ODS_Services__c); 
                    system.debug('@@@@@@ContctAccService:'+ContctAccService);        
                    if(ContctAccService.size() >0){
                        IsPortalApprover = ContctAccService[0].Is_Approver__c;
                    }
                }
            }
        }
        if(CurrentAccServiceId == null){
            GetLoggedUserAccountService(); 
        }
        else{
            AssignPassedAccountService();
        }
        GetAccountServiceChanges();        
        List<Contact_Account_Service__c> Contacts = [SELECT Contact__r.Name From Contact_Account_Service__c 
                                                     WHERE Account__c IN (SELECT Account__c FROM Account_Services__c where id=:CurrentAccServiceId) 
                                                     AND Contact__c IN (Select ContactId FROM User Where ContactId != '' AND PortalUserRole__c=:'Customer' AND isActive=:true) 
                                                     AND Is_Approver__c =: true AND ODS_Service__c=:ServiceId];
        for(Contact_Account_Service__c Contact : Contacts ){
            String AllContacts = Contact.Contact__r.Name;
            String AllContactsId = Contact.Contact__c;
            optionsClientCustomer.add(new selectOption(AllContactsId , AllContacts ));
        }
        
        if(CurrenTimesheetId == null && CurrentAccServiceId != null){
            SetApproverForTimeSheet(CurrentAccServiceId);
        }
        //IsPortalApprover = objUser.Contact.Is_Approver__c;
        system.debug('###CurrenTimesheetId:'+CurrenTimesheetId);
        if(CurrenTimesheetId != null){
            GetTimesheetDetails(CurrenTimesheetId);
            
            TimeSheet__c timesheetobj = new TimeSheet__c();  
            timesheetobj = ODS_Data_Utility.FetchTimesheetById(CurrenTimesheetId); 
            getTimeSheetValidationInvoice(timesheetobj.Week_Start_Date__c,timesheetobj.Week_End_Date__c,CurrentAccServiceId);
            CurrentTimeSheetStatus  = timesheetobj.Status__c; 
            if(String.isBlank(timesheetobj.Approver_Name__r.ContactId) ){
                NoApprover=true;
            }else{
                system.debug('ClientContact---'+ClientContact);
                List<Contact_Account_Service__c> casExist = [SELECT Is_Approver__c,id From Contact_Account_Service__c 
                                                             WHERE Account__c IN (SELECT Account__c FROM Account_Services__c where id=:CurrentAccServiceId) 
                                                             AND Contact__c IN (Select ContactId FROM User Where ContactId != '' AND PortalUserRole__c=:'Customer' AND isActive=:true) 
                                                             AND Contact__c =:timesheetobj.Approver_Name__r.ContactId AND ODS_Service__c=:ServiceId];
                if(casExist.size() > 0 && casExist[0].Is_Approver__c !=true){
                    NoApprover=true;  
                }else{
                    NoApprover=false;  
                    ClientContact=timesheetobj.Approver_Name__r.ContactId; 
                }
            }
            if(CurrentTimeSheetStatus =='Approved' || CurrentTimeSheetStatus=='Submitted'){
                ApproverName=timesheetobj.Approver_Name__r.Contact.Name;
                if(timesheetobj.Approver_Name__r.Contact.Name == null){
                    ApproverName = 'N/A';
                }
            }
        }  
        
        if(objUser.PortalUserRole__c == 'Customer')
        { 
            isCustomer= true;
        }  
        getResourceNameByAccountServiceId(AccountId, ServiceId); 
        getInitiativeByAccountServiceId(AccountId, ServiceId);                
    }
    
    public void GetTimesheetDetails(string TimesheetId)
    {
        List<Time_Sheet_Details__c> timeShtDetailList = new List<Time_Sheet_Details__c>();
        system.debug('###PortalUserRole :' +PortalUserRole);
        if(PortalUserRole != 'Customer'){
            timeShtDetailList = ODS_Data_Utility.FetchTimesheetDetailsbyId(TimesheetId);
        }
        else{
            timeShtDetailList = ODS_Data_Utility.FetchCustomerTimesheetDetails(TimesheetId);
        }
        List<TimeSheet__c> timesheetobj = new List<TimeSheet__c>();
        timesheetobj = ODS_Data_Utility.FetchTimesheetRecById(CurrenTimesheetId);
        string cmmts = '';
        if(timesheetobj.size() >0){
            CurrentTimeSheetStatus  = timesheetobj[0].Status__c;
            if(timesheetobj[0].Comments__c != null && timesheetobj[0].Comments__c != '')
            {
                cmmts = timesheetobj[0].Comments__c;
            }
        }else{
            CurrentTimeSheetStatus  ='';
        }                        
        TimeshtJSONtoBind = JSON.serialize(timeShtDetailList)+'~'+CurrentTimeSheetStatus  +'~'+cmmts ;
        system.debug('###TimeshtJSON:' +TimeshtJSONtoBind);
        TimeshtJSONtoBind=TimeshtJSONtoBind.replace('\\', '/');  
        //TimeshtJSONtoBind  = TimeshtJSONtoBind.Replace('\'','$#$');
        TimeshtJSONtoBind = String.escapeSingleQuotes(TimeshtJSONtoBind);
        system.debug('###TimeshtJSONtoBind:' +TimeshtJSONtoBind);
    }
    public void SetApproverForTimeSheet(String accSerId){
        NoApprover=false;
        list<Contact_Account_Service__c> getCASForExistAccSer=[SELECT Account__c,Contact__c,Contact__r.Name FROM Contact_Account_Service__c 
                                                               WHERE Account__c IN (SELECT Account__c FROM Account_Services__c where id=:accSerId) 
                                                               AND Contact__c IN (Select ContactId FROM User Where ContactId != '' AND PortalUserRole__c=:'Customer' AND isActive=:true) 
                                                               AND Is_Approver__c =: true AND ODS_Service__c=:ServiceId];
        list<Timesheet__c> timeSheet=[SELECT Account_Services__r.Account__c, Account_Services__c,Approver_Name__r.ContactId ,Id,LastModifiedDate,Name,Status__c FROM Timesheet__c WHERE Account_Services__c =: accSerId 
                                      AND Approver_Name__r.ContactId !='' ORDER BY Week_End_Date__c DESC NULLS FIRST LIMIT 1];  
        if(!timeSheet.isEmpty()){
            //previous timesheets exist
            list<Contact_Account_Service__c> cas=[SELECT Account__c,Contact__c FROM Contact_Account_Service__c WHERE Contact__c =: timeSheet[0].Approver_Name__r.ContactId 
                                                  AND Account__c=:timeSheet[0].Account_Services__r.Account__c AND Is_Approver__c=true 
                                                  AND Contact__c IN (Select ContactId FROM User Where ContactId != '' AND PortalUserRole__c=:'Customer' AND isActive=:true) 
                                                  AND ODS_Service__c=:ServiceId];
            if(!cas.isEmpty()){
                //if that previous timesheet approver is an active approver on the contact services.
                ClientContact=cas[0].Contact__c; 
            }else if(!getCASForExistAccSer.isEmpty()){
                ClientContact=getCASForExistAccSer[0].Contact__c;
            }else if(getCASForExistAccSer.isEmpty()){
                //approver list should be empty
                NoApprover=true;
            }
        }
        else
        {
            //When no previous timesheets on the account service exist
            if(!getCASForExistAccSer.isEmpty()){
                ClientContact=getCASForExistAccSer[0].Contact__c;
            }else{
                NoApprover=true;
            }
        }             
    }
    public void GetWeeklyTimesheet()
    {
        try{
            system.debug('##PassedWeekFromDate:' +PassedWeekFromDate);
            system.debug('##PassedWeekToDate:' +PassedWeekToDate);
            system.debug('###CurrentAccServiceId :' +CurrentAccServiceId);
            getTimeSheetValidationInvoice(date.parse(PassedWeekFromDate),date.parse(PassedWeekToDate),CurrentAccServiceId);
            List<Timesheet__c> timesheetRelatedDate = new List<Timesheet__c>();
            timesheetRelatedDate = ODS_Data_Utility.FetchTimesheetByDate(CurrentAccServiceId,date.parse(PassedWeekFromDate),date.parse(PassedWeekToDate));
            system.debug('###timesheetRelatedDate :' +timesheetRelatedDate);
            if(timesheetRelatedDate.size() > 0){
                CurrenTimesheetId = timesheetRelatedDate[0].Id;
                GetTimesheetDetails(CurrenTimesheetId);    
                
                
            }
            else{
                CurrenTimesheetId = '';
                TimeshtJSONtoBind = '';
            }  
            GetWeeklyTimesheetError = false;
        }
        catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.')); 
            GetWeeklyTimesheetError = true; 
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName()); 
        }
    }
        public void getTimeSheetValidationInvoice(date startDate,date endDate, string accountServiceId){
        system.debug('invoiceFreqAccSer-'+invoiceFreqAccSer);            
        if(invoiceFreqAccSer=='Bi-Weekly' || invoiceFreqAccSer=='Semi-Monthly'){
            date previousStartDate=startDate-7;
            date previousEndDate=endDate-7;
            List<Timesheet__c> previousWeekTimesheet = new List<Timesheet__c>();
            previousWeekTimesheet = ODS_Data_Utility.FetchTimesheetByDate(accountServiceId,previousStartDate,previousEndDate);
            Set<String> validStatuses = new Set<String>{'Submitted', 'Approved'};
                if (!previousWeekTimesheet.isEmpty() && !validStatuses.contains(previousWeekTimesheet[0].Status__c)) {
                    biWeeklyValidFailed=true;
                    biWeeklyConfirmationMessage='Previous weeks timesheet in Saved/Rejected status. Do you want to make changes and submit the timesheet for bi-weekly invoicing?';
                }else if(previousWeekTimesheet.isEmpty()){
                    biWeeklyValidFailed=true;
                    biWeeklyConfirmationMessage='No timesheet available for previous week. Do you want to make changes and submit the timesheet for bi-weekly invoicing?';  
                }else{
                    biWeeklyValidFailed=false;
                    biWeeklyConfirmationMessage='';
                }
        }else if (invoiceFreqAccSer=='Monthly'){
            Date firstDayOfMonth = startDate.toStartOfMonth();
            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
            if (lastDayOfMonth >= startDate && lastDayOfMonth <= endDate) {
                integer weeks=getWeeksInMonth(firstDayOfMonth.month(),firstDayOfMonth.year())-1;
                system.debug('weeks-'+weeks);
                
                List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id FROM Timesheet__c WHERE Week_Start_Date__c!=:startDate and Week_End_Date__c>=:firstDayOfMonth AND Week_Start_Date__c<=:lastDayOfMonth AND Account_Services__c =:CurrentAccServiceId AND (Status__c=:'Submitted' OR Status__c='Approved') ORDER BY Week_End_Date__c DESC NULLS FIRST];
                system.debug('lastMonthEndWeekTimesheets-'+lastMonthEndWeekTimesheets);
                if (lastMonthEndWeekTimesheets.size() != weeks) {
                    monthlyValidFailed = true;
                    monthlyConfirmationMessage = 'One or more timesheets not available for the monthly invoicing. Do you want to make changes and submit this timesheet for monthly invoicing?';
                } else {
                    monthlyValidFailed = false;
                    monthlyConfirmationMessage = '';
                }
            }else{
                monthlyValidFailed=false;
                monthlyConfirmationMessage='';
            }
        }else if(invoiceFreqAccSer=='Semi-Monthly'){
            date currentWeekStart=startDate;
            date currentWeekEnd=endDate;
            Date firstDayOfMonth = startDate.toStartOfMonth();
            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
            Date semiMonth1EndDate = Date.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), 15);
            Date semiMonth2EndDate = lastDayOfMonth;
            Boolean isSemiMonthInRange = semiMonth1EndDate >= currentWeekStart && semiMonth1EndDate <= currentWeekEnd;
            Boolean isMonthEndInRange   = lastDayOfMonth >= currentWeekStart && lastDayOfMonth <= currentWeekEnd;
            if(isMonthEndInRange){
                firstDayOfMonth=Date.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), 16);
            }
            if(isSemiMonthInRange){
                semiMonth2EndDate=Date.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), 15);
            }
            if(isSemiMonthInRange || isMonthEndInRange){
                List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id FROM Timesheet__c WHERE 
                                                                 Week_End_Date__c>=:firstDayOfMonth AND Week_Start_Date__c<=:semiMonth2EndDate AND Account_Services__c =:CurrentAccServiceId AND (Status__c=:'Submitted' OR Status__c='Approved') ORDER BY Week_End_Date__c DESC NULLS FIRST];    
                if (lastMonthEndWeekTimesheets.size() != 3) {
                    semiMonthlyValidFailed = true;
                    semiMonthlyConfirmationMessage = 'One or more timesheets not available for the semi-monthly invoicing. Do you want to make changes and submit this timesheet for semi-monthly invoicing?';
                } else {
                    semiMonthlyValidFailed = false;
                    semiMonthlyConfirmationMessage = '';
                }
            }
        }
            system.debug('accountId-'+accountId);
            date endDate30Days=endDate.addDays(30);
            system.debug('endDate30Days-'+endDate30Days);
            List<Work_Order__c> WOList=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c FROM Work_Order__c
                                        WHERE Client_Name__c=:accountId AND Project_Start_Date__c <=: endDate30Days AND Project_End_Date__c >=: endDate30Days AND SubCategory__c LIKE '%Subscription%' ORDER BY Project_End_Date__c DESC LIMIT 1];
            noActiveWorkOrderNext30Days=false;
            noActiveWorkOrderNext30DaysMsg ='';
            system.debug('WOList-'+WOList);
            if(WOList.isEmpty()){
                noActiveWorkOrderNext30Days=true;
                noActiveWorkOrderNext30DaysMsg='Warning: The active work order will expire soon. Please renew the work order.';
            }
            noActiveWorkOrderDuration=false;
            List<Work_Order__c> WOList1=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c FROM Work_Order__c
                                         WHERE Client_Name__c=:accountId AND Project_Start_Date__c <=: endDate AND Project_End_Date__c >=: endDate ORDER BY Project_End_Date__c DESC LIMIT 1];
            if(WOList1.isEmpty()){
                noActiveWorkOrderDuration=true;  
            }
        system.debug('monthlyValidFailed-'+monthlyValidFailed);
        system.debug('monthlyConfirmationMessage-'+monthlyConfirmationMessage);  
    }
    public Integer getWeeksInMonth(Integer month, Integer year) {
        Date firstDayOfMonth = Date.newInstance(year, month, 1);
        Date lastDayOfMonth = firstDayOfMonth.addMonths(1).addDays(-1);
        Integer isoDayOfWeekOfFirstDay = Integer.valueOf(Datetime.newInstance(firstDayOfMonth, Time.newInstance(0, 0, 0, 0)).format('u'));
        Integer apexDayOfWeekOfFirstDay;
        
        if (isoDayOfWeekOfFirstDay == 7) {
            apexDayOfWeekOfFirstDay = 1;
        } else {
            apexDayOfWeekOfFirstDay = isoDayOfWeekOfFirstDay + 1;
        }
        
        Date startOfFirstWeek;
        if (apexDayOfWeekOfFirstDay == 2) { 
            startOfFirstWeek = firstDayOfMonth;
        } else if (apexDayOfWeekOfFirstDay == 1) { 
            startOfFirstWeek = firstDayOfMonth.addDays(-6);
        } else { 
            startOfFirstWeek = firstDayOfMonth.addDays(-(apexDayOfWeekOfFirstDay - 2));
        }
        
        Integer isoDayOfWeekOfLastDay = Integer.valueOf(Datetime.newInstance(lastDayOfMonth, Time.newInstance(0, 0, 0, 0)).format('u'));
        Integer apexDayOfWeekOfLastDay;
        
        if (isoDayOfWeekOfLastDay == 7) { 
            apexDayOfWeekOfLastDay = 1;
        } else { 
            apexDayOfWeekOfLastDay = isoDayOfWeekOfLastDay + 1;
        }
        
        Date endOfLastWeek;
        if (apexDayOfWeekOfLastDay == 1) { 
            endOfLastWeek = lastDayOfMonth;
        } else { 
            endOfLastWeek = lastDayOfMonth.addDays(7 - apexDayOfWeekOfLastDay + 1);
        }
        
        Integer totalDays = startOfFirstWeek.daysBetween(endOfLastWeek) + 1;
        
        return totalDays / 7;
    }
    public void AssignPassedAccountService()
    {
        List<Account_Services__c > accServiceLst = new List<Account_Services__c >();
        accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
        if(accServiceLst.size() > 0){
            AccountId = accServiceLst[0].Account__c;
            ServiceId = accServiceLst[0].ODS_Services__c;
        }
    }
    
    public void AddRow()
    {
    }
    
    public PageReference GetTimeSheetIdFromAction()
    {
        system.debug('##CurrenTimesheetId:' +CurrenTimesheetId);        
        return null;
    }
    
    public void GetLoggedUserAccountService()
    {
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId()); 
        if(objUser.PortalUserRole__c == 'Customer')
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
            List<Account_Services__c> accServices = new List<Account_Services__c>();
            accServices = ODS_Data_Utility.fetchAccServcesByAcc(AccountId);
            if(accServices.size() > 0)
            {
                ServiceId = accServices[0].ODS_Services__c;
            }
            else
            {
                ServiceId = 'All';
            }
        }
    }
    
    public static List<SelectOption> GetAccountPicklistValues()
    {
        
        List<SelectOption> lstSlctOptn = new list<SelectOption>(); 
        ODS_Common_Utility objUtility = new ODS_Common_Utility();
        //lstSlctOptn = objUtility.getCustomersByLoggedInUser();
        return lstSlctOptn;
    }
    
    
    
    public void GetTimesheetByAccountServiceID(string SelectedAccountId, string SelectedServiceID)
    {
        try{
            ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);
            GetAccountServiceChanges();  
            GetWeeklyTimesheet();
            GetTimesheetByAccountServiceIDError = false;
        }
        catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            GetTimesheetByAccountServiceIDError = true;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    } 
    
    public PageReference GetTimesheetByAccountServiceID() {
        
        GetTimesheetByAccountServiceID(AccountId,ServiceID);
        return null; 
    } 
    // This method will get the values based on AccountId and ServiceID and redirect to ViewTimesheet page when we 
    // change values in the Global fiters
    public PageReference ReDirectToViewTimesheet() {
        
        ODS_Common_Utility.upsertSessionData(AccountId,ServiceID);
        PageReference pr = new PageReference(''+getMobileredirectUrl+'/apex/ODS_viewTimesheet_Mobile?accntId='+AccountId+'&srvcId='+ServiceID);
        return pr;
    }
    
    public void GetAccountServiceChanges()
    {
        List<Account> acc = new List<Account>();
        acc = ODS_Data_Utility.GetAccountNameById(AccountId);
        if(acc.size() > 0){
            AccountName = acc[0].Name;
        }
        else{
            AccountName = 'All';
        }
        List<ODS_Services__c> ods = new List<ODS_Services__c>();
        ods = ODS_Data_Utility.GetServiceNameById(ServiceId);
        if(ods.size() > 0){
            ServiceName = ods[0].Name__c;
        }
        else{
            ServiceName = 'All';
        }
        
        List<Account_Services__c > accServList = new List<Account_Services__c >();
        accServList = ODS_Data_Utility.fetchAccServcesByServiceAccount(AccountId, ServiceId);
        if(accServList.size() > 0){
            CurrentAccServiceId = accServList[0].Id;
        }
        else{
            CurrentAccServiceId = '';
        } 
    }
    
    public void SaveTimesheet()
    {   
        try{
            system.debug('##Saved PassedTimesheetJSON:' + PassedTimesheetJSON);
            system.debug('##hdnActionValue:' + hdnActionValue);
            system.debug('bhuvan '+UserInfo.getUserId());
            
            Map<String, Object> timesheetJSONmap = (Map<String, Object>)JSON.deserializeUntyped(PassedTimesheetJSON);
            
            Timesheet__c timeSheet = new Timesheet__c();
            PassedWeekFromDate = string.valueOf(timesheetJSONmap.get('WeekStartDate'));
            PassedWeekToDate = string.valueOf(timesheetJSONmap.get('WeekEndDate'));
            
            Date dtWeekEndMonth = date.parse(PassedWeekToDate);
            dtStartDate = date.parse(PassedWeekFromDate); //Start Week date
            dtEndDate = date.parse(PassedWeekToDate); //End Week date
            date tEndDate=dtEndDate;

            Account_Services__c objAcntSrv = [SELECT ID,ODS_Hourly_Rate_Amount__c,Admin_Hourly_Rate__c,Consulting_Hourly_Rate__c,Account__r.Customer_Type__c, Account__c,Account__r.Name,Invoice_Frequency__c from Account_Services__c  WHERE ID =: CurrentAccServiceId];
            if (objAcntSrv.Invoice_Frequency__c == 'Monthly') {
                Date firstDayOfMonth = dtStartDate.toStartOfMonth();
                Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                if (lastDayOfMonth >= dtStartDate && lastDayOfMonth <= dtEndDate) {
                    tEndDate=lastDayOfMonth;
                }
            }
            List<Invoice__c> invoiceList=[SELECT Account_Services__c,Billing_End_Date__c,Billing_Start_Date__c,Id FROM Invoice__c WHERE 
                                          Account_Services__c=:objAcntSrv.Id AND Billing_Start_Date__c <=: tEndDate AND Billing_End_Date__c  >=: tEndDate AND Invoice_Type__c='ODS'
                                         AND Status__c !='Saved'];
            If(!invoiceList.isEmpty()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The invoice for the timesheet has already been submitted. Please contact the system administrator.'));
                SaveTimesheetError = true;
            }else{
                list<User_Account__c> userAcc = new list<User_Account__c> ();
                System.debug('%%%%%%%%objAcntSrv.Id'+objAcntSrv.Id);
                userAcc = [SELECT Account__c, User__c, User__r.Email, Role_in_Account__c FROM User_Account__c WHERE Account__c =: objAcntSrv.Account__c AND Role_in_Account__c = 'Account Manager' LIMIT 1];
                SaveTimesheetCost(dtStartDate,dtEndDate,CurrentAccServiceId,objAcntSrv.ODS_Hourly_Rate_Amount__c);
                system.debug('###objTimesheetCost.Id'+objTimesheetCost.Id);
                System.debug('%%%%%%%%userAcc'+userAcc);
                //Original Code
                timeSheet.Week_Start_Date__c = date.parse(PassedWeekFromDate);
                Integer month = timeSheet.Week_Start_Date__c.month();
                timeSheet.Week_End_Date__c = date.parse(PassedWeekToDate);
                if(userAcc.size()>0){
                    timeSheet.Account_Manager_Email__c = userAcc[0].User__r.Email;
                    System.debug('%%%%%%%%timeSheet.Account_Manager_Email__c'+ timeSheet.Account_Manager_Email__c);
                }
                timeSheet.Account_Name__c = objAcntSrv.Account__r.Name;
                if(string.valueOf(timesheetJSONmap.get('Status')) != 'Submitted')
                    timeSheet.Status__c = string.valueOf(timesheetJSONmap.get('Status'));
                if(string.valueOf(timesheetJSONmap.get('Comments')) != null){
                    timeSheet.Comments__c = string.valueOf(timesheetJSONmap.get('Comments')); }
                timeSheet.Time_Sheet_Cost__c = objTimesheetCost.Id;
                timeSheet.Cost_Per_Hour__c = objAcntSrv.ODS_Hourly_Rate_Amount__c ;
                if(objAcntSrv.Account__r.Customer_Type__c=='ABC Type'){
                    timeSheet.Admin_Cost_Per_Hour__c=objAcntSrv.Admin_Hourly_Rate__c;
                    timeSheet.Consulting_Cost_Per_Hour__c=objAcntSrv.Consulting_Hourly_Rate__c;
                }
                //Contact[] contactObj =  ODS_Data_Utility.GetApproverName(AccountId);
                // system.debug('@@@contactObj '+contactObj );
                ContctAccService  = new List<Contact_Account_Service__c>();
                ContctAccService = ODS_Data_Utility.getContactAccountService(AccountId, ServiceId);
                
                if(String.isNotBlank(ClientContact)){
                    user userobj = new user();
                    userobj = ODS_Data_Utility.getuser(ClientContact);
                    if(userobj != null)
                        timeSheet.Approver_Name__c  =userobj.id;  
                }else{
                    if(ContctAccService.size() >0){
                        system.debug('@@@ContctAccService[0].id'+ContctAccService[0].Contact__c);
                        user userobj = new user();
                        userobj = ODS_Data_Utility.getuser(ContctAccService[0].Contact__c);
                        if(userobj != null)
                            timeSheet.Approver_Name__c  =userobj.id;
                        
                    }
                }
                
                /*if(ContctAccService.size() >0){
system.debug('@@@ContctAccService[0].id'+ContctAccService[0].Contact__c);
user userobj = new user();
userobj = ODS_Data_Utility.getuser(ContctAccService[0].Contact__c);
if(userobj != null)
timeSheet.Approver_Name__c  =userobj.id;

}*/
                
                List<Object> timeSheetDetailJSON = (List<Object>)(timesheetJSONmap.get('TimesheetDtls'));    
                
                GetWeeklyTimesheet();
                system.debug('Kvvv1');
                if(CurrenTimesheetId == null || CurrenTimesheetId == '')
                {system.debug('Kvvv2');
                 IsTimesheetInsert = True;
                 timeSheet.Account_Services__c = CurrentAccServiceId;      
                 system.debug('###timeSheet to Insert:' +timeSheet);      
                 insert timeSheet;
                 CurrenTimesheetId = timeSheet.Id;
                }
                else
                {
                    system.debug('Kvvv3');
                    IsTimesheetInsert = False;
                    timeSheet.Account_Services__c = CurrentAccServiceId; 
                    timeSheet.Id = CurrenTimesheetId;    
                    system.debug('###timeSheet to Update:' +timeSheet);      
                    update timeSheet;            
                }
                system.debug('###CurrenTimesheetId :' +CurrenTimesheetId);
                system.debug('###timeSheetDetailJSON:' +timeSheetDetailJSON);
                system.debug('###timeSheet:' +timeSheet);
                
                InsertTimeSheetDetail(timeSheetDetailJSON, CurrenTimesheetId,timeSheet);           
                GetTimesheetDetails(CurrenTimesheetId);
                SaveTimesheetError = false;
            }
        }
        catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            SaveTimesheetError = true;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }
    
    
    public void InsertTimeSheetDetail(List<Object> DetailJSONObject, String TimeShtId, Timesheet__c objtimeSheet)
    {
        system.debug('Kvvv4');
        Map<string,Object> timeshtDtlMap = new Map<string, Object>();
        List<Time_Sheet_Details__c> timesheetDetailList = new List<Time_Sheet_Details__c>();
        Boolean IsValidationSuccess;
        if(IsTimesheetInsert){
            system.debug('Kvvv5');
            system.debug('##Timesheet Insert');
            if(validateTimesheetHours(DetailJSONObject)){
                system.debug('Kvvv7');
                if(hdnActionValue == 'Submitted'){
                    Timesheet__c timeSheet = new Timesheet__c(id=TimeShtId);
                    timeSheet.Status__c = 'Submitted';
                    update timeSheet;
                    
                    //Added by Indhu on 12-Jul-2019 to send submitted email
                    sendSubmittedTimesheetEmail(TimeShtId);
                    
                    //Mani and Team - calling invoice weekly email method when timehseet submitted
                    sendWeeklyEmail(TimeShtId);
                }
                system.debug('##Validate Success');
                //Do Nothing. Proceed with Timesheet detail insert
                IsValidationSuccess = True;
            }
            else{
                system.debug('Kvvv8');
                //Delete the inserted timesheet as validation failed
                Timesheet__c timeSheet = new Timesheet__c(id=TimeShtId);
                delete timeSheet;
                system.debug('##Validate Failed. So delete the timesheet');
                IsValidationSuccess = False;
            }
        }
        else{
            system.debug('Kvvv6');
            List<Time_Sheet_Details__c> existingTimesheetDetailList = new List<Time_Sheet_Details__c>();
            system.debug('##Timesheet Update');
            
            existingTimesheetDetailList = FetchExistingTimesheetDetails(TimeShtId);
            
            
            //Changes
            
            List<Initiatives__c> relatedInitiatives = new List<Initiatives__c>();
            Map<string, decimal> initiativeAddedHoursMap = new Map<string, decimal>();
            for(Object timeShtDtl: DetailJSONObject)
            {
                timeshtDtlMap = (Map<string,Object>)timeShtDtl;
                system.debug('##InitiativeValue:' +string.valueOf(timeshtDtlMap.get('IntiativeId')));
                if(string.valueOf(timeshtDtlMap.get('IntiativeId')) != '--Select--' && string.valueOf(timeshtDtlMap.get('IntiativeId')) != ' ' && string.valueOf(timeshtDtlMap.get('IntiativeId')) != null){
                    if(initiativeAddedHoursMap.containsKey(string.valueOf(timeshtDtlMap.get('IntiativeId'))))       
                    {
                        initiativeAddedHoursMap.put(string.valueOf(timeshtDtlMap.get('IntiativeId')), initiativeAddedHoursMap.get(string.valueOf(timeshtDtlMap.get('IntiativeId'))) + decimal.Valueof(timeshtDtlMap.get('Hrs')+''));
                    }
                    else
                    {
                        initiativeAddedHoursMap.put(string.valueOf(timeshtDtlMap.get('IntiativeId')),decimal.Valueof(timeshtDtlMap.get('Hrs')+''));
                    }
                }
                //Commented by Indhu on 12-Feb-2020 for issue fix on timesheet estimated hours more than submitted hours
                /*else{

break;
}*/            
            } 
            
            relatedInitiatives = ODS_Data_Utility.fetchRelatedInitiativeDetails(initiativeAddedHoursMap.keySet());
            for(Initiatives__c currentIntiative: relatedInitiatives)
            {
                GenericRemaining.put(currentIntiative.Id, currentIntiative);
            }
            //Changes end
            DeleteExistingTimesheetDetail(TimeShtId);
            
            
            system.debug('##existingTimesheetDetailList:' +existingTimesheetDetailList);
            if(validateTimesheetHours(DetailJSONObject)){
                
                system.debug('Kvvv9');
                if(hdnActionValue == 'Submitted'){
                    Timesheet__c timeSheet = new Timesheet__c(id=TimeShtId);
                    timeSheet.Status__c = 'Submitted';
                    update timeSheet;
                    
                    //Added by Indhu on 12-Jul-2019 to send submitted email
                    sendSubmittedTimesheetEmail(TimeShtId);
                    
                    //Mani and Team - calling invoice weekly email method when timehseet submitted
                    sendWeeklyEmail(TimeShtId);
                }
                system.debug('##Validate Success');
                //Do Nothing. Proceed with Timesheet detail insert
                IsValidationSuccess = True;
            }
            else{
                system.debug('Kvvv10');
                system.debug('##Kvvv');
                system.debug('##Kvvv '+existingTimesheetDetailList);
                
                insert existingTimesheetDetailList;
                
                
                system.debug('##Validate Failed. So inserting deleted timesheet details');
                IsValidationSuccess = False;
            }
        }
        
        system.debug('###DetailJSONObject:' +DetailJSONObject);
        system.debug('&&**'+string.valueOf(timeshtDtlMap.get('ResourceId')));
        system.debug('$$$TimeShtId:' +TimeShtId);
        if(IsValidationSuccess){
            system.debug('Kvvv11');
            List<Account_Services__c > accServiceExist = new List<Account_Services__c >();
            accServiceExist = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
            string customerType='';
            if(!accServiceExist.isEmpty()){
                customerType=accServiceExist[0].Account__r.Customer_Type__c;
            }
            for(Object timeShtDtl: DetailJSONObject)
            {
                timeshtDtlMap = (Map<string,Object>)timeShtDtl;
                system.debug('###InitiativeID:' + string.valueOf(timeshtDtlMap.get('IntiativeId')));
                Time_Sheet_Details__c timesheetDetail = new Time_Sheet_Details__c();
                timesheetDetail.Hours_Worked__c = decimal.Valueof(timeshtDtlMap.get('Hrs')+'');
                timesheetDetail.Row_No__c = integer.valueOf(timeshtDtlMap.get('RowNo'));  
                string taskName=string.valueOf(timeshtDtlMap.get('TaskName'));
                if(string.isNotBlank(taskName)){
                    taskName=taskName.replace('\\', '/');  
                }
                timesheetDetail.Task_Name__c = taskName;   
                timesheetDetail.Resource_Id__c = string.valueOf(timeshtDtlMap.get('ResourceId'));
                system.debug('###ResourceName:' +timeshtDtlMap.get('ResourceName'));
                timesheetDetail.Resource__c = string.valueOf(timeshtDtlMap.get('ResourceName'));
                if(string.valueOf(timeshtDtlMap.get('IntiativeId')) != '--Select--'){
                    timesheetDetail.Intiative__c = string.valueOf(timeshtDtlMap.get('IntiativeId'));
                }
                if(string.valueOf(timeshtDtlMap.get('IntiativeName')) != '--Select--'){
                    timesheetDetail.Initiative_Name__c = string.valueOf(timeshtDtlMap.get('IntiativeName'));
                }
                if(string.valueOf(timeshtDtlMap.get('TPMNames')) != '--Select--'){
                    timesheetDetail.Technical_Project_Manager__c = string.valueOf(timeshtDtlMap.get('TPMNames'));
                    
                }
                
                if(customerType=='ABC Type'){
                    timesheetDetail.Initiative_Billing_Type__c = string.valueOf(timeshtDtlMap.get('IntiativeBillingType'));
                }else{
                    timesheetDetail.Initiative_Billing_Type__c = 'Build';
                }
                timesheetDetail.Timesheet_Date__c = date.parse(string.valueOf(timeshtDtlMap.get('TDate'))); 
                timesheetDetail.Timesheet__c = TimeShtId;  
                timesheetDetailList.add(timesheetDetail);
            }   
            system.debug('$$$timesheetDetailList:' +timesheetDetailList);
            insert timesheetDetailList;   
            if(hdnActionValue == 'Saved'){
                hdnActionValue = 'Saved';
            }
            else if(hdnActionValue == 'Submitted'){
                hdnActionValue = 'Submitted';
            }
            UpdateODSHoursAndResCountInCost(objtimeSheet); 
            TimesheetTriggerHandler.sendTimesheet(TimeShtId); 
            if(hdnActionValue == 'Submitted'){
                sendMailWOExpired(objtimeSheet);
            }
        }   
        else{
            system.debug('Kvvv12');
            hdnActionValue = 'ValidateFailed';
            system.debug('###hdnActionValue post validation:' + hdnActionValue);
        }
    }
    public static void sendMailWOExpired(Timesheet__c objtimeSheet){
        Boolean isAnyWorkOrderActive=false;
        Account_Services__c accountSerRecord=[SELECT Id,Account__c,Account__r.Name,Account__r.Backup_CSM__r.Email,Account__r.User__r.Email FROM Account_Services__c WHERE Id=:ApexPages.CurrentPage().getParameters().get('AccServiceId') LIMIT 1];
        system.debug('accountSerRecord-'+accountSerRecord);
        if(accountSerRecord !=null){
            list<Work_Order__c> workOrderList = new List<Work_Order__c>();
            workOrderList=[SELECT Client_Name__c,CreatedDate,Project_End_Date__c,Project_Start_Date__c FROM Work_Order__c WHERE Client_Name__c=:accountSerRecord.Account__c AND SubCategory__c LIKE '%Subscription%' ORDER BY CreatedDate DESC NULLS FIRST];
            
            for(Work_Order__c wo:workOrderList){
                if (objtimeSheet.Week_End_Date__c >= wo.Project_Start_Date__c && objtimeSheet.Week_End_Date__c <= wo.Project_End_Date__c) {
                    isAnyWorkOrderActive = true;
                    break;
                }
            }
            if(!isAnyWorkOrderActive){
                List<Messaging.SingleEmailMessage> emails=new list<Messaging.SingleEmailMessage>();
                string strHtmlBody='';
                String startDate = DateTime.newInstance(objtimeSheet.Week_Start_Date__c.year(), objtimeSheet.Week_Start_Date__c.month(), objtimeSheet.Week_Start_Date__c.day()).format('MM/dd/YYYY');
                String endDate = DateTime.newInstance(objtimeSheet.Week_End_Date__c.year(), objtimeSheet.Week_End_Date__c.month(), objtimeSheet.Week_End_Date__c.day()).format('MM/dd/YYYY');
                List<string> toAddress=new List<string>();
                List<String> ccAddress=new List<string>();
                ccAddress.add(System.Label.Work_order_recipients);
                toAddress.add(accountSerRecord.Account__r.User__r.Email);
                toAddress.add(accountSerRecord.Account__r.Backup_CSM__r.Email);
                Messaging.SingleEmailMessage semailAccountOwner = new Messaging.SingleEmailMessage();
                semailAccountOwner.setToAddresses(toAddress);
                semailAccountOwner.setCcAddresses(ccAddress);
                semailAccountOwner.setSubject('Timesheet submitted for expired Work Order - '+accountSerRecord.Account__r.Name);
                strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>The timesheet is submitted for expired work order for the period from <b>'+ startDate +'</b> to <b>'+endDate+'</b>. Please renew the Work Order to avoid delays on sending out invoices to <b>'+accountSerRecord.Account__r.Name+'</b>.</br> ';
                strHtmlBody += '<br/><br/>Thanks,<br/><br/>Levelshift Admin<br/>';
                semailAccountOwner.setHtmlBody(strHtmlBody);
                emails.add(semailAccountOwner);
                Messaging.sendEmail(emails);
            }
        }
    }
    public void UpdateAdminAndConsultingHours(Timesheet__c objtimeSheet){
        if(CurrentAccServiceId != null && objtimeSheet !=null){
            List<Account_Services__c > accServiceExist = new List<Account_Services__c >();
            
            accServiceExist = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
            if(!accServiceExist.isEmpty() && accServiceExist[0].Account__r.Customer_Type__c=='ABC Type'){
                AggregateResult[] adminTimesheet = [SELECT SUM(Hours_Worked__c) ODSAdminTotalHrs from Time_Sheet_Details__c WHERE Timesheet__c =:objtimeSheet.id AND Timesheet__r.Account_Services__c =: CurrentAccServiceId AND Status__c =: 'Approved' AND Initiative_Billing_Type__c=:'Admin'];
                AggregateResult[] consultingTimesheet = [SELECT SUM(Hours_Worked__c) ODSConsTotalHrs from Time_Sheet_Details__c WHERE Timesheet__c =:objtimeSheet.id AND Timesheet__r.Account_Services__c =: CurrentAccServiceId AND Status__c =: 'Approved' AND Initiative_Billing_Type__c=:'Consulting'];
                
                objtimeSheet.Admin_Cost_Per_Hour__c=accServiceExist[0].Admin_Hourly_Rate__c;
                objtimeSheet.Consulting_Cost_Per_Hour__c=accServiceExist[0].Consulting_Hourly_Rate__c;
                objtimeSheet.ODS_Admin_Total_Hour__c=(Decimal)adminTimesheet[0].get('ODSAdminTotalHrs');
                objtimeSheet.ODS_Consulting_Total_Hour__c=(Decimal)consultingTimesheet[0].get('ODSConsTotalHrs');
                update objtimeSheet;
            }
        } 
    }
    public List<Time_Sheet_Details__c> FetchExistingTimesheetDetails(string TimeShtId)
    {
        List<Time_Sheet_Details__c> timesheetDetailList = new List<Time_Sheet_Details__c>();
        for(Time_Sheet_Details__c timeshtDtl: ODS_Data_Utility.FetchExistingTimesheetDetailsforInsert(TimeShtId)){
            Time_Sheet_Details__c timesheetDetail = new Time_Sheet_Details__c();
            timesheetDetail.Hours_Worked__c = timeshtDtl.Hours_Worked__c ;
            timesheetDetail.Row_No__c = timeshtDtl.Row_No__c ;                    
            timesheetDetail.Task_Name__c = timeshtDtl.Task_Name__c ;
            timesheetDetail.Resource_Id__c = timeshtDtl.Resource_Id__c ;
            timesheetDetail.Resource__c = timeshtDtl.Resource__c ;
            timesheetDetail.Intiative__c = timeshtDtl.Intiative__c ;
            timesheetDetail.Initiative_Name__c = timeshtDtl.Initiative_Name__c ;  
            timesheetDetail.Technical_Project_Manager__c = timeshtDtl.Technical_Project_Manager__c ;  
            
            timesheetDetail.Timesheet_Date__c = timeshtDtl.Timesheet_Date__c ; 
            timesheetDetail.Timesheet__c = TimeShtId;  
            timesheetDetailList.add(timesheetDetail);
        }
        return timesheetDetailList;
    }
    public  List<string> getInitiativeBillingType {
        get {
            List<string> options = new List<string>();
            for( Schema.PicklistEntry obj : Initiatives__c.Initiative_Billing_Type__c.getDescribe().getPicklistValues()) {
                options.add(obj.getValue());
            }
            system.debug('optionsoptions----'+options);
            return options;
            
        }  
        set;
    }
    /// <Objective>
    /// Method to check if the total timesheet hours added for an initiative isnot more than the estimated hours. 
    /// </Objective>
    public boolean validateTimesheetHours(List<Object> DetailJSONObject)
    {   
        System.debug('@@@@DetailJSONObject'+DetailJSONObject);
        Map<string,Object> timeshtDtlMap = new Map<string, Object>();
        Map<string, decimal> initiativeAddedHoursMap = new Map<string, decimal>();
        Map<string, Initiatives__c> initiativeRemainingHoursMap = new Map<string, Initiatives__c>();
        List<Initiatives__c> relatedInitiatives = new List<Initiatives__c>();
        boolean isValidHours;
        for(Object timeShtDtl: DetailJSONObject)
        {
            timeshtDtlMap = (Map<string,Object>)timeShtDtl;
            system.debug('##InitiativeValue:' +string.valueOf(timeshtDtlMap.get('IntiativeId')));
            if(string.valueOf(timeshtDtlMap.get('IntiativeId')) != '--Select--' && string.valueOf(timeshtDtlMap.get('IntiativeId')) != ' ' && string.valueOf(timeshtDtlMap.get('IntiativeId')) != null){
                if(initiativeAddedHoursMap.containsKey(string.valueOf(timeshtDtlMap.get('IntiativeId'))))       
                {
                    initiativeAddedHoursMap.put(string.valueOf(timeshtDtlMap.get('IntiativeId')), initiativeAddedHoursMap.get(string.valueOf(timeshtDtlMap.get('IntiativeId'))) + decimal.Valueof(timeshtDtlMap.get('Hrs')+''));
                }
                else
                {
                    initiativeAddedHoursMap.put(string.valueOf(timeshtDtlMap.get('IntiativeId')),decimal.Valueof(timeshtDtlMap.get('Hrs')+''));
                }
            }
            //Commented by Indhu on 12-Feb-2020 for issue fix on timesheet estimated hours more than submitted hours
            else{
                isValidHours = True;
                //break;
            }            
        } 
        
        
        system.debug('###initiativeAddedHoursMap:' +initiativeAddedHoursMap);       
        relatedInitiatives = ODS_Data_Utility.fetchRelatedInitiativeDetails(initiativeAddedHoursMap.keySet());
        for(Initiatives__c currentIntiative: relatedInitiatives)
        {
            initiativeRemainingHoursMap.put(currentIntiative.Id, currentIntiative);
        }
        system.debug('###initiativeRemainingHoursMap:' +initiativeRemainingHoursMap);
        if(initiativeRemainingHoursMap != null){
            for(string initiativeId: initiativeRemainingHoursMap.keyset())
            {
                system.debug('###KvvvvE:' +initiativeRemainingHoursMap.get(initiativeId).Estimated_hours__c);
                system.debug('###KvvvvR:' +initiativeRemainingHoursMap.get(initiativeId).Remaining_Hours__c);
                system.debug('###KvvvvA:' +initiativeAddedHoursMap.get(initiativeId));            
                if(initiativeAddedHoursMap.get(initiativeId) > initiativeRemainingHoursMap.get(initiativeId).Remaining_Hours__c){
                    system.debug('###InvalidHours');
                    isValidHours = False;
                    invalidInitiativeName = initiativeRemainingHoursMap.get(initiativeId).Name;
                    invalidInitiateEstimtdHrs =initiativeRemainingHoursMap.get(initiativeId).Estimated_hours__c;
                    if(GenericRemaining!=null && GenericRemaining.get(initiativeId)!=null)
                    { 
                        inavlidInitiateRemHrs =GenericRemaining.get(initiativeId).Remaining_Hours__c;
                    }
                    else
                    {
                        inavlidInitiateRemHrs =0;
                    }
                    break;
                }
                else{
                    isValidHours = true;
                }
            }
        }
        return isValidHours;
    }
    
    public void UpdateODSHoursAndResCountInCost(Timesheet__c objtimeSheet){
        system.debug('***Object'+objtimeSheet);
        Integer startWeekmonth = objtimeSheet.Week_Start_Date__c .month();
        Integer EndWeekmonth =  objtimeSheet.Week_End_Date__c .month();
        
        
        Integer YearOfWeekstartDate =  objtimeSheet.Week_Start_Date__c .year();
        Integer YearOfWeekEndDate =  objtimeSheet.Week_End_Date__c .year();
        if(startWeekmonth == EndWeekmonth)
        {
            
            ODS_TimeSheetCostController.populateODSHours(objTimesheetCost,objtimeSheet.Week_Start_Date__c,CurrentAccServiceId);
            ODS_TimeSheetCostController.populateResourceCount(objTimesheetCost,objtimeSheet.Week_Start_Date__c,CurrentAccServiceId);
            ODS_TimeSheetCostController.populateRegularHours(objTimesheetCost,objtimeSheet.Week_Start_Date__c,CurrentAccServiceId);
            
        }
        else{
            ODS_TimeSheetCostController.populateODSHours(objTimesheetCost,objtimeSheet.Week_Start_Date__c,CurrentAccServiceId);
            ODS_TimeSheetCostController.populateResourceCount(objTimesheetCost,objtimeSheet.Week_Start_Date__c,CurrentAccServiceId);
            ODS_TimeSheetCostController.populateRegularHours(objTimesheetCost,objtimeSheet.Week_Start_Date__c,CurrentAccServiceId);  
            
            ODS_TimeSheetCostController.populateODSHours(objTimesheetCostforNextMonth,objtimeSheet.Week_End_Date__c,CurrentAccServiceId);
            ODS_TimeSheetCostController.populateResourceCount(objTimesheetCostforNextMonth,objtimeSheet.Week_End_Date__c,CurrentAccServiceId);
            ODS_TimeSheetCostController.populateRegularHours(objTimesheetCostforNextMonth,objtimeSheet.Week_End_Date__c,CurrentAccServiceId);
        }
    }
    
    public boolean SaveTimesheetCost(Date WeekStartDate, Date WeekEndDate, string CurrentAccServiceId, Decimal HourlyRate ){
        
        boolean Result = false;
        Integer startWeekmonth =WeekStartDate.month();
        Integer EndWeekmonth = WeekEndDate.month();
        
        
        Integer YearOfWeekstartDate = WeekStartDate.year();
        Integer YearOfWeekEndDate = WeekEndDate.year();
        system.debug('#startWeekmonth'+startWeekmonth);
        system.debug('#EndWeekmonth'+EndWeekmonth );
        
        objTimesheetCostforNextMonth = new Time_Sheet_Cost__c();
        if(startWeekmonth == EndWeekmonth)
        {
            
            objTimesheetCost = ODS_TimeSheetCostController.CheckIfMonthExistInCostTable(startWeekmonth,YearOfWeekstartDate,CurrentAccServiceId,HourlyRate ,WeekStartDate);
        }
        else
        {
            
            objTimesheetCost = ODS_TimeSheetCostController.CheckIfMonthExistInCostTable(startWeekmonth,YearOfWeekstartDate,CurrentAccServiceId,HourlyRate ,WeekStartDate);
            objTimesheetCostforNextMonth = ODS_TimeSheetCostController.CheckIfMonthExistInCostTable(EndWeekmonth,YearOfWeekEndDate ,CurrentAccServiceId,HourlyRate,WeekEndDate);
        }
        return Result;
        
    }
    
    public void DeleteExistingTimesheetDetail(String TimeShtId)
    {
        List<Time_Sheet_Details__c> timesheetDetailList = new List<Time_Sheet_Details__c>();
        timesheetDetailList = ODS_Data_Utility.FetchExistingTimesheetDetail(TimeShtId);
        
        system.debug('KvvvCheck:' +timesheetDetailList );
        List<Initiatives__c> lstInitiatives = new List<Initiatives__c>();
        for(Time_Sheet_Details__c tdetail : timesheetDetailList){
            String InitiativeId = tdetail.Intiative__c;
            //   System.debug('@@@InitiativeId '+InitiativeId);
            if(tdetail.Intiative__c != null){ 
                Initiatives__c initiative = [select Submitted_Hours__c FROM Initiatives__c  WHERE ID=: InitiativeId];
                //           System.debug('@@@initiative.Submitted_Hours__c'+initiative.Submitted_Hours__c);
                if(initiative.Submitted_Hours__c != null || initiative.Submitted_Hours__c > 0){
                    initiative.Submitted_Hours__c = initiative.Submitted_Hours__c - tdetail.Hours_Worked__c;                   
                    update initiative;  
                }
            }           
        }
        
        
        Timesheet__c timesheet = new Timesheet__c();
        timesheet = [SELECT Time_Sheet_Cost__c FROM Timesheet__c WHERE ID =: TimeShtId];
        Id TmeShtCstId = timesheet.Time_Sheet_Cost__c;
        
        delete timesheetDetailList;
        
    }
    
    public PageReference ApproveTimesheet()
    {
        try{
            system.debug('@@@ApproveTimesheetId:' +CurrenTimesheetId);
            TimeSheet__c timeSht = new Timesheet__c(id=CurrenTimesheetId);
            system.debug('@@@');
            timeSht.Status__c = 'Approved';
            timeSht.Comments__c = TimesheetComments;
            timeSht.Approver_Name__c = UserInfo.GetUserID();
            timesht.Approved_Date__c = Date.Today();
            system.debug('***timeSht'+timeSht);
            Update timeSht;
            system.debug('***timeSht'+timeSht);
            system.debug('**ApproveTmSheet');        
            TimeSheet__c  timesheetobj =   ODS_Data_Utility.FetchTimesheetById(CurrenTimesheetId);
            Account_Services__c objAcntSrv = [SELECT ID,ODS_Hourly_Rate_Amount__c from Account_Services__c  WHERE ID =: CurrentAccServiceId];
            system.debug('^^^timesheetobj.Week_Start_Date__c'+timesheetobj.Week_Start_Date__c);
            SaveTimesheetCost(timesheetobj.Week_Start_Date__c,timesheetobj.Week_End_Date__c,CurrentAccServiceId,objAcntSrv.ODS_Hourly_Rate_Amount__c);
            UpdateODSHoursAndResCountInCost(timesheetobj);
            UpdateAdminAndConsultingHours(timesheetobj);
            
            sendEmail(CurrenTimesheetId);
            PageReference pgRef = new PageReference(''+getMobileredirectUrl+'/apex/Dashboard_Mobile');
            pgRef.setRedirect(True);
            ApproveTimesheetError = False;
            return pgRef;
        }
        catch(Exception e)  {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ApproveTimesheetError = True;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }
    
    public PageReference RejectTimesheet()
    {
        try{
            system.debug('###RejectTimesheetId:' +CurrenTimesheetId);
            TimeSheet__c timeSht = new Timesheet__c(id=CurrenTimesheetId);
            timeSht.Status__c = 'Rejected';
            timeSht.Comments__c = TimesheetComments;
            timeSht.Approver_Name__c = UserInfo.GetUserID();
            timesht.Approved_Date__c = Date.Today();
            Update timeSht;
            system.debug('**timeSht'+timeSht);
            TimeSheet__c  timesheetobj =   ODS_Data_Utility.FetchTimesheetById(CurrenTimesheetId);
            Account_Services__c objAcntSrv = [SELECT ID,ODS_Hourly_Rate_Amount__c from Account_Services__c  WHERE ID =: CurrentAccServiceId];
            system.debug('^^^timesheetobj.Week_Start_Date__c'+timesheetobj.Week_Start_Date__c);
            SaveTimesheetCost(timesheetobj.Week_Start_Date__c,timesheetobj.Week_End_Date__c,CurrentAccServiceId,objAcntSrv.ODS_Hourly_Rate_Amount__c);
            UpdateODSHoursAndResCountInCost(timesheetobj);
            
            sendEmail(CurrenTimesheetId);
            PageReference pgRef = new PageReference(''+getMobileredirectUrl+'/apex/Dashboard_Mobile');
            pgRef.setRedirect(True);
            RejectTimesheetError = false;
            return pgRef;
        }
        catch(Exception e)  {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            RejectTimesheetError = true;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }
    
    //Added by Indhu on 12-Jul-2019 for submitting timesheet
    @future(callout = true)
    public static void sendSubmittedTimesheetEmail(string timesheetId)
    {
        String AccountId,ServiceId;
        List<String> lstToAddress = new List<String>();
        List<String> lstCcAddress = new List<String>();
        string odsSiteURL = System.Label.ODS_SiteURL;
        string timesheetEmail = System.Label.ODS_TimesheetMail_Id;        
        Timesheet__c  tsTosendEmail = new Timesheet__c();
        system.debug('####@@timsheetid:' +timesheetId);
        
        tsTosendEmail = [Select Id, Name, Approver_Name__c, Approver_Name__r.FirstName, Approver_Name__r.LastName, 
                         Account_Manager_Email__c, Approver_Email__c, Comments__c,TAM_Name__c,TAM_Phone_No__c, 
                         Approver_Name__r.Name,Status_Date__c,Week_Start_Date__c,Week_End_Date__c, Account_Services__c,
                         Account_Services__r.Account__c, Account_Services__r.Account__r.name, Account_Services__r.ODS_Service_Name__c,
                         Account_Services__r.Technical_Account_manager__r.Name, Account_Services__r.Technical_Account_manager__r.Email, 
                         Account_Services__r.Technical_Account_manager__r.Phone,
                         Account_Services__r.Backup_CSM__r.Email, Account_Services__r.Backup_CSM__r.IsActive,
                         Account_Services__r.Technical_Account_manager__r.IsActive,/*Account_Services__r.Technical_Account_manager__r.Signature__c,*/
                         Status__c,Approver_Name__r.Email,Approver_Name__r.ContactId,Approver_Name__r.Contact.Email from Timesheet__c where Id=: timesheetId];
        
        System.debug('tsTosendEmail------------'+tsTosendEmail.Account_Services__c);
        
        List<Account_Services__c > accServiceLst = new List<Account_Services__c >();
        
        accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(tsTosendEmail.Account_Services__c);
        String signTitle='CSM';
        
        if(accServiceLst.size() > 0){
            AccountId = accServiceLst[0].Account__c;
            ServiceId = accServiceLst[0].ODS_Services__c;
            if(accServiceLst[0].Account__r.Small_Business__c){
                signTitle='Technical Lead';
            }
        }
        system.debug('###AccountId :' +AccountId +'###ServiceId :' +ServiceId);
        lstToAddress.add(tsTosendEmail.Approver_Name__r.Contact.Email);
        for(Contact_Account_Service__c Contact : [SELECT Email__c From Contact_Account_Service__c WHERE Account__c =: AccountId 
                                                  AND ODS_Service__c =: ServiceId AND Is_Approver__c  = true AND Contact__c !=:tsTosendEmail.Approver_Name__r.ContactId])
        {
            lstCcAddress.add(Contact.Email__c);
        }
        if(tsTosendEmail.Account_Services__r.Technical_Account_manager__r.Email != null &&
           tsTosendEmail.Account_Services__r.Technical_Account_manager__r.IsActive){
               lstCcAddress.add(tsTosendEmail.Account_Services__r.Technical_Account_manager__r.Email);
           }
        if(tsTosendEmail.Account_Services__r.Backup_CSM__r.Email != null &&
           tsTosendEmail.Account_Services__r.Backup_CSM__r.IsActive){
               lstCcAddress.add(tsTosendEmail.Account_Services__r.Backup_CSM__r.Email);
           }
        if(timesheetEmail != null){
            lstCcAddress.add(timesheetEmail);
        }
        string Finance_Team_CC_Email=system.label.Finance_Team_CC_Email;
        if(string.isNotBlank(Finance_Team_CC_Email)){
            List<String> ccEmails = new List<String>();
            for (String email : Finance_Team_CC_Email.split(',')) {
                ccEmails.add(email.trim());
            }
            lstCcAddress.addAll(ccEmails);
        }
        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
        
        if(lstToAddress.size() > 0){
            mail.setToAddresses(lstToAddress);
        }
        String currentUserName = UserInfo.getName(); 
        mail.setSenderDisplayName(currentUserName);
        if(lstCcAddress.size() > 0){
            mail.setCcAddresses(lstCcAddress);
        }
        
        String subject = 'Timesheet Approval for ' +tsTosendEmail.Account_Services__r.Account__r.name+ ' - '+tsTosendEmail.Account_Services__r.ODS_Service_Name__c+ ' from ' + (tsTosendEmail.Week_Start_Date__c).format() + ' to ' +(tsTosendEmail.Week_End_Date__c).format() ;
        mail.setSubject(subject);
        string htmlBody = '';
        string htmlbodyString='<table width="100%" cellpadding="0" cellspacing="0"><tr><td><font face="Calibri " size="3">Hi  ' + tsTosendEmail.Approver_Name__r.FirstName + ' ' + tsTosendEmail.Approver_Name__r.LastName + ', <br><p  >The Timesheet for ' + (tsTosendEmail.Week_Start_Date__c).format()+ ' through  ' + (tsTosendEmail.Week_End_Date__c).format();
        htmlbodyString +=' has been submitted.  Please click on the below link to view & approve. </p>   <br><a href =' + odsSiteURL + '/TimesheetPage?id=' +tsTosendEmail.Id+ '&AccServiceId=' + tsTosendEmail.Account_Services__c;
        htmlbodyString += '&Status=' +tsTosendEmail.Status__c+ '&WeekStart=' +tsTosendEmail.Week_Start_Date__c+ '>Click here to view timesheet </a><br><br>Feel free to contact me with questions.<br><br></font></td></tr></table>';
        string emailSignature=ODS_Common_Utility.getEmailSignature(tsTosendEmail.Account_Services__r.Technical_Account_manager__r.Name,signTitle,tsTosendEmail.Account_Services__r.Technical_Account_manager__r.Phone,tsTosendEmail.Account_Services__r.Technical_Account_manager__r.Email);
        htmlBody =ODS_Common_Utility.getEmailMessage(htmlbodyString,emailSignature);
        
        mail.setHtmlBody(htmlBody);        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /// <OBJECTIVE>
    /// Method to send email once the record is submitted.
    /// </OBJECTIVE>
    @Future(Callout = true)
    public Static void sendEmail(string timsheetid)
    {
        List<String> lstToAddress = new List<String>();
        List<String> lstCcAddress = new List<String>();
        Set<String> setToAddress = new Set<String>();
        string timesheetMailIdLabel = System.Label.ODS_TimesheetMail_Id;        
        Timesheet__c  tsTosendEmail = new Timesheet__c();
        system.debug('####@@timsheetid:' +timsheetid);
        
        tsTosendEmail = [Select Id, Name, Approver_Name__c,Approver_Email__c, Comments__c,Approver_Name__r.Name,Status_Date__c,
                         Week_Start_Date__c,Week_End_Date__c,Account_Services__c,Account_Services__r.Account__c, Account_Services__r.Account__r.name, 
                         Account_Services__r.ODS_Service_Name__c,Account_Services__r.Technical_Account_manager__r.Name, 
                         Account_Services__r.Technical_Account_manager__r.Email,/*Account_Services__r.Technical_Account_manager__r.Signature__c,*/
                         Account_Services__r.Backup_CSM__r.Email, 
                         Status__c from Timesheet__c where Id=: timsheetid];
        System.debug('tsTosendEmail------------'+tsTosendEmail.Account_Services__c);
        
        System.debug('lstCcAddress------------'+lstCcAddress);
        String accntId = tsTosendEmail.Account_Services__r.Account__c;
        
        Date StartDate = tsTosendEmail.Week_Start_Date__c; 
        String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');       
        
        Date EndDate = tsTosendEmail.Week_End_Date__c;
        String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
        
        String[] bccAddress = new List<String>();      
        String AccSerId= tsTosendEmail.Account_Services__c;
        string timshtCmts = '';
        
        System.debug('accntId------------'+accntId);
        
        //List of User Accounts associated
        List<User_Account__c> lstUsrAccnts = new List<User_Account__c>();
        String excludeRoles = Label.Account_Roles_To_Exclude;
        List<String> rolesToExclude = excludeRoles.replace(', ',',').split(',');
        lstUsrAccnts = [Select Id, name, User__c,User__r.Email, Account__c, Role_in_Account__c from User_Account__c where Account__c =: accntId AND Role_in_Account__c NOT IN: rolesToExclude AND User__r.IsActive = true];
        System.debug('lstUsrAccnts------------'+lstUsrAccnts);
        
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId()); 
        
        if(objUser.PortalUserRole__c == 'Customer'){
            if(tsTosendEmail.Approver_Email__c != null){
                lstCcAddress.add(tsTosendEmail.Approver_Email__c);
            }
            if(timesheetMailIdLabel != null){
                lstCcAddress.add(timesheetMailIdLabel);     
            }
            
            if(tsTosendEmail.Comments__c != null && tsTosendEmail.Comments__c != ''){
                timshtCmts = tsTosendEmail.Comments__c;
            }
            
            //get list of Cc address
            if(lstUsrAccnts.size() >0)
            {
                for(User_Account__c objUsrAccnt: lstUsrAccnts)
                {
                    if(objUsrAccnt.User__r.Email != null){
                        setToAddress.add(objUsrAccnt.User__r.Email);
                    }
                }   
                if(setToAddress.size() > 0){
                    lstToAddress.addAll(setToAddress);     
                }                           
            }
        }
        
        if(objUser.PortalUserRole__c == 'Technical Account Manager' || objUser.PortalUserRole__c == 'Practice Head'){
            if(lstUsrAccnts.size() >0)
            {
                for(User_Account__c objUsrAccnt: lstUsrAccnts)
                {
                    if(objUsrAccnt.User__r.Email != null){
                        setToAddress.add(objUsrAccnt.User__r.Email);
                    }
                }   
                if(setToAddress.size() > 0){
                    lstToAddress.addAll(setToAddress);      
                }                              
            }
            
        }
        
        String split_emailswithcomma = System.Label.ODS_InitiativeBCC;
        if(split_emailswithcomma != null){
            List<String> splitted_emails = split_emailswithcomma.split(',');                                        
            if(splitted_emails.size() > 0  ){   
                for(String  email : splitted_emails){
                    bccAddress.add(email);
                }
            }
            else { bccAddress.add(split_emailswithcomma); }
        }
        
        
        //generate email with the details
        //PageReference pdf = Page.Test_Page;
        PageReference pdf = Page.ODS_ExportTimesheet;
        
        pdf.getParameters().put('Weekfromdate',FromDate);
        System.debug('@@@@@@@@FromDate------------'+FromDate);
        pdf.getParameters().put('Weektodate',ToDate);
        System.debug('@@@ToDate------------'+ToDate);
        pdf.getParameters().put('Accountservice',AccSerId);
        System.debug('@@@@@@@@@AccSerId------------'+AccSerId);
        
        // the contents of the attachment from the pdf
        Blob body;
        
        try {
            
            // returns the output of the page as a PDF
            body = pdf.getContent();
            System.debug('@@@@@@@@@body ------------'+body );
            
            // need to pass unit test -- current bug  
        } catch (VisualforceException e) {
            body = Blob.valueOf('Weekly Timesheet');
        }        
        
        string formattedStartDate = (tsTosendEmail.Week_Start_Date__c).format().replace('/','-');
        string formattedEndDate = (tsTosendEmail.Week_End_Date__c).format().replace('/','-');
        Messaging.EmailFileAttachment attachement = new Messaging.EmailFileAttachment();
        attachement.setContentType('appliction/pdf');
        attachement.setFileName(tsTosendEmail.Account_Services__r.Account__r.name+ ' - '+tsTosendEmail.Account_Services__r.ODS_Service_Name__c+ ' from ' +formattedStartDate + ' to ' +formattedEndDate+'.pdf');
        attachement.setInline(false);
        pdf.setRedirect(true);
        attachement.Body = body;
        
        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
        
        if(lstToAddress.size() > 0){
            mail.setToAddresses(lstToAddress);
        }
        String currentUserName = UserInfo.getName(); 
       // mail.setSenderDisplayName(currentUserName);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: system.label.ODS_Customer_FromAddress];
        if(objUser.PortalUserRole__c == 'Customer' && ( owea.size() > 0 )){ 
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            mail.setSenderDisplayName(currentUserName);
        }
        if(lstCcAddress.size() > 0){
            mail.setCcAddresses(lstCcAddress);
        }
        if(bccAddress.size() > 0){
            mail.setBccAddresses(bccAddress);
        }
        String subject = 'Timesheet Report for: ' +tsTosendEmail.Account_Services__r.Account__r.name+ ' - '+tsTosendEmail.Account_Services__r.ODS_Service_Name__c+ ' from ' + (tsTosendEmail.Week_Start_Date__c).format() + ' to ' +(tsTosendEmail.Week_End_Date__c).format() + ' - ' +tsTosendEmail.Status__c;
        mail.setSubject(subject);
        
        String strHtmlBody = '' ;        
        strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi '+ tsTosendEmail.Account_Services__r.Technical_Account_manager__r.Name+', <br/><br/>The timesheet for '+ (tsTosendEmail.Week_Start_Date__c).format() + ' through ' +(tsTosendEmail.Week_End_Date__c).format() +' has been '+ tsTosendEmail.Status__c
            + '.<br/><br/>';
        if(timshtCmts!=''){
            strHtmlBody += 'Comments : '+timshtCmts +' <br/><br/>';
        }
        
        if(objUser.PortalUserRole__c == 'Technical Account Manager' || objUser.PortalUserRole__c == 'Practice Head')
        {
            /*if(String.isNotBlank(tsTosendEmail.Account_Services__r.Technical_Account_manager__r.Signature__c)){
strHtmlBody += ' <br/><br/>' + tsTosendEmail.Account_Services__r.Technical_Account_manager__r.Signature__c;
}
else{*/  
            strHtmlBody += '<table style="border:none; width:624px; border-collapse: collapse;"><tbody><tr><td style="border-top:2px solid #000; padding-bottom:15px;"></td></tr><tr><td><p style="margin:0px; color:#000;">Thanks,</p></td></tr><tr><td><p style="margin:0px; color:#000;">'+tsTosendEmail.Approver_Name__r.Name+'</p></td></tr><tr><td><table><tbody><tr><td valign="top" width="283" style="width:285px; margin:0; padding:25px;vertical-align:top; background-color:#07080A;"><a href="https://www.levelshift.com/" target="_blank"><img src="'+Label.ODS_Email_Signature_Logo_Url+'" alt="Levelshift" width="285" style="border:none;width:285px;display:block; margin:25px 0;"></a></td><td width="5" style="width:5px;min-width:5px;max-width:5px;margin:0;padding:0;">&nbsp;</td><td style="background-color:#4fc9f3; padding:26px; width:276px;"><table><tbody><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Name</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+tsTosendEmail.Approver_Name__r.Name+'</span></p></td></tr></tbody></table></td></tr><tr><td><p style="border-bottom:1px solid #FFF; width:267px; margin:5px 0;"></p></td></tr><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Email</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+tsTosendEmail.Approver_Email__c+'</span></p></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td style="border-bottom:2px solid #4fc9f3; padding-top:15px;"></td></tr><tr><td width="624" valign="top" style="width:283px;border:none;padding:10px 0"><p style="text-align:justify;"><span style="font-size:11px; font-family:calibri; color:#ff0000; font-weight: bold;">CONFIDENTIALITY STATEMENT:</span><span style="font-size:11px; font-family:Arial, Sans-Serif, Times New Roman; color:#a6a6a6;">The information contained in this communication is confidential and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p></td></tr></tbody></table>';
            /*}*/
        }
        else
        {
            strHtmlBody += 'Thanks,' + ' <br/><br/>' + tsTosendEmail.Approver_Name__r.Name;            
        }
        mail.setHtmlBody(strHtmlBody);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachement});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /// <OBJECTIVE>
    /// Method to send email once the record is SUBMITTED & Invoice frequency = Weekly - Mani & Team
    /// </OBJECTIVE>
    @Future(Callout = true)
    public Static void sendWeeklyEmail(string timsheetid)
    {
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        
        string timesheetMailIdLabel = System.Label.ODS_TimesheetMail_Id;        
        Timesheet__c  tsTosendEmail = new Timesheet__c();
        system.debug('####@@timsheetid:' +timsheetid);
        
        tsTosendEmail = [Select Id, Name, Approver_Name__c,Approver_Email__c, Comments__c,Approver_Name__r.Name,Status_Date__c,
                         Week_Start_Date__c,Week_End_Date__c,Account_Services__c,Account_Services__r.Account__c, Account_Services__r.Account__r.name,
                         Account_Services__r.ODS_Service_Name__c,Account_Services__r.Technical_Account_manager__r.Name, Status__c,Account_Services__r.ODS_Hourly_Rate_Amount__c,
                         Account_Services__r.Account__r.Invoice_Type__c,Account_Services__r.Invoice_Frequency__c,Account_Services__r.Subscription_Fee_Discount__c,
                         Account_Services__r.Account__r.Primary_Customer_Contact__r.Name,Account_Services__r.Account__r.Primary_Customer_Email_Id__c,
                         Account_Services__r.Contract_Term__c,Account_Services__r.Account__r.BillingStreet,Account_Services__r.Account__r.BillingCity,
                         Account_Services__r.Account__r.BillingState,Account_Services__r.Account__r.BillingCountry,Account_Services__r.Account__r.BillingPostalcode,
                         Account_Services__r.Account__r.ODS_Invoice_Contact_Email__c,Account_Services__r.Account__r.ODS_Invoice_Count__c,
                         Account_Services__r.Account__r.ODS_Invoice_Account_Number__c,Account_Services__r.Account__r.SOW__c,Account_Services__r.Purchase_Order__c,
                         Account_Services__r.Account__r.InvoiceContact__c,Account_Services__r.Account__r.InvoiceContact__r.Name,
                         Account_Services__r.Technical_Account_manager__r.Email,/*Account_Services__r.Technical_Account_manager__r.Signature__c, */
                         Account_Services__r.Backup_CSM__r.Email
                         from Timesheet__c 
                         where Id=: timsheetid];
        System.debug('tsTosendEmail------------'+tsTosendEmail.Account_Services__c);        
        String accntId = tsTosendEmail.Account_Services__r.Account__c;
        
        Date StartDate = tsTosendEmail.Week_Start_Date__c; 
        String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');       
        
        Date EndDate = tsTosendEmail.Week_End_Date__c;
        String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
        
        String AccSerId= tsTosendEmail.Account_Services__c;
        string timshtCmts = '';
        
        if(tsTosendEmail.Account_Services__r.Invoice_Frequency__c == 'Weekly'){
            //To avoid EZRE_ContactActivityDateUpdate trigger error
            ODS_FiredFromBatchClass.setFiredFromBatch();        
            
            //generate email with the details
            //PageReference pdf = Page.Test_Page;
            PageReference pdf = Page.ODS_ExportTimesheet;        
            pdf.getParameters().put('Weekfromdate',FromDate);
            pdf.getParameters().put('Weektodate',ToDate);
            pdf.getParameters().put('Accountservice',AccSerId);
            
            // the contents of the attachment from the pdf
            Blob body;
            
            try {        
                // returns the output of the page as a PDF
                body = pdf.getContentAsPdf();
                System.debug('@@@@@@@@@body ------------'+body );        
                // need to pass unit test -- current bug  
            } catch (VisualforceException e) {
                body = Blob.valueOf('Weekly Timesheet');
            }
            
            //Generate invoice pdf
            PageReference invPdf = Page.ODS_Invoice_TimeSheetFormat;
            invPdf.getParameters().put('term',tsTosendEmail.Account_Services__r.Contract_Term__c);
            invPdf.getParameters().put('billToStr',String.valueOf(tsTosendEmail.Account_Services__r.Account__r.BillingStreet));
            invPdf.getParameters().put('billToCty',String.valueOf(tsTosendEmail.Account_Services__r.Account__r.BillingCity));
            invPdf.getParameters().put('billToStat',String.valueOf(tsTosendEmail.Account_Services__r.Account__r.BillingState));
            invPdf.getParameters().put('billToCtry',String.valueOf(tsTosendEmail.Account_Services__r.Account__r.BillingCountry));
            invPdf.getParameters().put('billToPcod',String.valueOf(tsTosendEmail.Account_Services__r.Account__r.BillingPostalcode));
            String constructMth = '';
            if(System.today().month() < 10) constructMth = '0'+String.valueOf(System.today().month());
            else constructMth = String.valueOf(System.today().month());
            Integer invCnt = 0;
            if(tsTosendEmail.Account_Services__r.Account__r.ODS_Invoice_Count__c != null) invCnt = Integer.valueOf(tsTosendEmail.Account_Services__r.Account__r.ODS_Invoice_Count__c);
            else invCnt = (System.today().day()-1);
            String invCntPrint = invCnt<10 ? '0'+String.valueOf(invCnt+1) : String.valueOf(invCnt+1);
            String invNumber = String.valueOf(System.today().year())+constructMth+invCntPrint+String.valueOf(tsTosendEmail.Account_Services__r.Account__r.ODS_Invoice_Account_Number__c);
            invPdf.getParameters().put('invNumb',invNumber);
            invPdf.getParameters().put('accNumb',String.valueOf(tsTosendEmail.Account_Services__r.Account__r.ODS_Invoice_Account_Number__c));
            invPdf.getParameters().put('billPerd',FromDate+' - '+ToDate);
            invPdf.getParameters().put('timShtId',timsheetid);       
            invPdf.getParameters().put('startDt',String.valueOf(StartDate));
            invPdf.getParameters().put('endDt',String.valueOf(EndDate));
            invPdf.getParameters().put('AccServId',AccSerId);
            invPdf.getParameters().put('hrlyRate',String.valueOf(tsTosendEmail.Account_Services__r.ODS_Hourly_Rate_Amount__c));
            invPdf.getParameters().put('discFee','');
            invPdf.getParameters().put('ref',String.valueOf(tsTosendEmail.Account_Services__r.Purchase_Order__c));
            invPdf.getParameters().put('proj',String.valueOf(tsTosendEmail.Account_Services__r.ODS_Service_Name__c));
            
            // the contents of the attachment from the pdf
            Blob invBody;        
            try { 
                invBody = invPdf.getContentAsPdf();             
            }catch (VisualforceException e) {
                invBody = Blob.valueOf('Weekly Invoice');
            }
            
            string formattedStartDate = (tsTosendEmail.Week_Start_Date__c).format().replace('/','-');
            string formattedEndDate = (tsTosendEmail.Week_End_Date__c).format().replace('/','-');
            Messaging.EmailFileAttachment attachement = new Messaging.EmailFileAttachment();
            attachement.setContentType('appliction/pdf');
            attachement.setFileName('Timesheet - '+tsTosendEmail.Account_Services__r.Account__r.name+ ' - '+tsTosendEmail.Account_Services__r.ODS_Service_Name__c+ ' from ' +formattedStartDate + ' to ' +formattedEndDate+'.pdf');
            attachement.setInline(false);
            pdf.setRedirect(true);
            attachement.Body = body;
            
            Messaging.EmailFileAttachment invAtt = new Messaging.EmailFileAttachment();
            invAtt.setContentType('appliction/pdf');
            invAtt.setFileName('Invoice'+invNumber+'.pdf');
            invAtt.setInline(false);
            invPdf.setRedirect(true);
            invAtt.Body = invBody;
            
            Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
            
            //Beta or Live release
            if(System.Label.ODS_InvoiceReleaseType.equalsIgnoreCase('beta')) {
                toAddress.add(System.Label.ODS_InvoiceBetaEmailID);
            }else {
                if(tsTosendEmail.Account_Services__r.Account__r.Invoice_Type__c == 'Paper') { //Using existing field on account to check email option for customer
                    toAddress.add(System.Label.ODS_InvoiceTeam); 
                    mail.setToAddresses(toAddress);
                }else {
                    if(String.isNotBlank(tsTosendEmail.Account_Services__r.Account__r.ODS_Invoice_Contact_Email__c)) {
                        toAddress.add(tsTosendEmail.Account_Services__r.Account__r.ODS_Invoice_Contact_Email__c);
                        mail.setTargetObjectId(tsTosendEmail.Account_Services__r.Account__r.InvoiceContact__c);
                        mail.setSaveAsActivity(true);
                        mail.setBccSender(false);
                    }
                    else toAddress.add(System.Label.ODS_InvoiceTeam); //If invoice customer email is empty, we must notify invoice team
                    mail.setToAddresses(toAddress);
                }
            }
            //To do: Change OrgWideEmailAddress for Invoice team                
            for(OrgWideEmailAddress owa : ODS_EmailUtils.getInvoiceTeamEmail()) {   
                if(String.isNotBlank(owa.Address)) {
                    mail.setOrgWideEmailAddressId(owa.id);
                }
            }
            
            for(User u: ODS_EmailUtils.getPracticeHeadEmail()) {
                //Label to check whether ccing actual practice head allowed
                if (u != null && u.IsActive) { 
                    if(Boolean.valueOf(System.Label.ODS_Invoice_CcPracticeHead)){
                        ccAddress.add(u.Email);
                    }
                    else {
                        ccAddress.add(System.label.ODS_InvoiceTestEmail);
                    }
                }
            }
            
            //Adding approver email to CC        
            if(String.isNotBlank(String.valueOf(tsTosendEmail.Approver_Email__c))) {
                if(Boolean.valueOf(System.Label.ODS_Invoice_ccApprover)) {ccAddress.add(tsTosendEmail.Approver_Email__c);}
            }
            mail.setCcAddresses(ccAddress);
            
            String subject = 'Levelshift Invoice for '+tsTosendEmail.Account_Services__r.ODS_Service_Name__c+' on Demand Service'+' from ' + (tsTosendEmail.Week_Start_Date__c).format() + ' to ' +(tsTosendEmail.Week_End_Date__c).format();
            mail.setSubject(subject);
            String strHtmlBody = '' ;        
            strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3"><b>Hi '+tsTosendEmail.Account_Services__r.Account__r.InvoiceContact__r.Name+',</b>'+' <br/><br/><b>Please find the attached Invoice for '+tsTosendEmail.Account_Services__r.ODS_Service_Name__c+' on Demand Services from '+(tsTosendEmail.Week_Start_Date__c).format() + ' through ' +(tsTosendEmail.Week_End_Date__c).format()
                + '.<br/><br/>'+'Please confirm the receipt and reach us if you have any questions!</b><br/><br/>';
            
            strHtmlBody += '<table style="border:none; width:624px; border-collapse: collapse;"><tbody><tr><td style="border-top:2px solid #000; padding-bottom:15px;"></td></tr><tr><td><p style="margin:0px; color:#000;"><b>Thanks,</b></p></td></tr><tr><td><p style="margin:0px; color:#000;">'+'<b>LEVEL SHIFT</b>'+'</p></td></tr><tr><td><table><tbody><tr><td valign="top" width="283" style="width:285px; margin:0; padding:25px;vertical-align:top; background-color:#07080A;"><a href="https://www.levelshift.com/" target="_blank"><img src="'+Label.ODS_Email_Signature_Logo_Url+'" alt="Levelshift" width="285" style="border:none;width:285px;display:block; margin:25px 0;"></a></td><td width="5" style="width:5px;min-width:5px;max-width:5px;margin:0;padding:0;">&nbsp;</td><td style="background-color:#4fc9f3; padding:26px; width:276px;"><table><tbody><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Name</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+'Invoice Team'+'</span></p></td></tr></tbody></table></td></tr><tr><td><p style="border-bottom:1px solid #FFF; width:267px; margin:5px 0;"></p></td></tr><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Email</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+System.Label.ODS_InvoiceTeam+'</span></p></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td style="border-bottom:2px solid #4fc9f3; padding-top:15px;"></td></tr><tr><td width="624" valign="top" style="width:283px;border:none;padding:10px 0"><p style="text-align:justify;"><span style="font-size:11px; font-family:calibri; color:#ff0000; font-weight: bold;">CONFIDENTIALITY STATEMENT:</span><span style="font-size:11px; font-family:Arial, Sans-Serif, Times New Roman; color:#a6a6a6;">The information contained in this communication is confidential and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p></td></tr></tbody></table>';
            
            mail.setHtmlBody(strHtmlBody);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachement,invAtt});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            //Updated by Indhu on 07-Aug-2019 to avoid test invoice upload
            
            if(!System.Label.ODS_InvoiceReleaseType.equalsIgnoreCase('beta')) {
                //Upload the sent invoice to Invoice__c object
                Invoice__c inv = new Invoice__c();
                inv.Account_Services__c = tsTosendEmail.Account_Services__c;
                inv.Attachment_File__c = 'Invoice'+invNumber+'.pdf';
                inv.Comments__c = 'Invoice File - Weekly timesheet - '+String.valueOf(System.Today());
                //Custom setting to get month name             
                inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
                inv.Year__c = System.today().year();
                try {
                    insert inv;
                }catch(Exception er) {
                    System.debug('@@Error while inserting the invoice record: '+er.getMessage());
                }
                
                //Create Attachment
                Attachment att = new Attachment();
                att.Body = invBody;
                att.Name = 'Weekly Timesheet Invoice - '+invNumber+ ' - '+tsTosendEmail.Account_Services__r.ODS_Service_Name__c+ ' from ' +formattedStartDate + ' to ' +formattedEndDate+' sent on '+System.now()+'.pdf';
                att.ParentId = inv.Id;
                try {
                    insert att;
                }catch(Exception er) {
                    System.debug('@@Error while inserting the invoice attachment: '+er.getMessage());
                }
                
                //Link currently inserted Attachment with Invoice record
                Invoice__c invLink = new Invoice__c(Id=inv.Id,Attachment_Id__c=att.Id);
                try {
                    update invLink;
                }catch(Exception eLink) {
                    System.debug('@@Error while Linking the invoice with attachment: '+eLink.getMessage());
                }
                
                //Logging the activity into custom object
                Invoice_Logger__c log = new Invoice_Logger__c();
                log.Account__c = tsTosendEmail.Account_Services__r.Account__c;
                log.Account_Services__c = tsTosendEmail.Account_Services__c;
                log.Invoice_Sent_DateTime__c = System.now();
                log.SOW_Status__c = tsTosendEmail.Account_Services__r.Account__r.SOW__c;
                log.Invoice_Number__c = invNumber;
                log.Log_Type__c = 'Weekly Timesheet Invoice';
                try {
                    insert log;
                }catch(Exception errLog) {
                    System.debug('@@Error while inserting log: '+errLog.getMessage());
                }
            }
            
            ODS_FiredFromBatchClass.resetFiredFromBatch();   
        }//End of Weekly check IF
    }
    
    /// <OBJECTIVE>
    /// Method to redirect to Timesheet page
    /// </OBJECTIVE> 
    public pagereference redirectToTimeSheet()
    {
        try{
            String url = ''+getMobileredirectUrl+'/apex/ODS_ViewTimesheet_Mobile?accntId='+AccountId+'&srvcId='+serviceId;        
            Pagereference pgRef = new PageReference(url);
            return pgRef ;
        }
        catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
        
    }
    /// <OBJECTIVE>
    /// To get resource name for the selected account and service.
    /// </OBJECTIVE>
    public void getResourceNameByAccountServiceId(String AccountId, String ServiceId) 
    {  
        try {
            resourceNameLst = new  List<AggregateResult>();
            resourceNameLst = ODS_Data_Utility.getResourceNameByAccountServiceId(AccountId, ServiceId);
            resourceNameJSONtoBind = JSON.serialize(resourceNameLst);
            system.debug('##resourceNameJSONtoBind :' +resourceNameJSONtoBind);
        }
        catch(Exception e)  {
            system.debug('AddTimesheet-getResourceNameByAccountServiceId: '+e);
        }
    }
    
    public void getInitiativeByAccountServiceId(String AccountId, String ServiceId) 
    {  
        try {
            InitiativeLst = new  List<AggregateResult>();
            TpmLst = new  List<AggregateResult>();
            
            if(CurrentTimeSheetStatus == null || CurrentTimeSheetStatus == 'Saved'){
                InitiativeLst = ODS_Data_Utility.getInitiativeByAccountServiceId(AccountId, ServiceId);
                TpmLst = ODS_Data_Utility.getInitiativeByAccountServiceId(AccountId, ServiceId);
                
            }
            else{            
                InitiativeLst = ODS_Data_Utility.getAllInitiativeByAccountServiceId(AccountId, ServiceId);
                TpmLst = ODS_Data_Utility.getAllInitiativeByAccountServiceId(AccountId, ServiceId);
                
            }
            initiativeJSONtoBind = JSON.serialize(InitiativeLst);
            tpmJSONtoBind = JSON.serialize(TpmLst);
            
        }
        catch(Exception e)  {
            system.debug('AddTimesheet-getInitiativeByAccountServiceId: '+e);
        }
    }
    
    public List<string> getTechnicalProjectManager {
        get {
            List<string> options = new List<string>();
            for( Schema.PicklistEntry obj : Initiatives__c.Technical_Project_Manager__c.getDescribe().getPicklistValues()) {
                options.add(obj.getValue());
            } 
            system.debug('optionsoptions----'+options);
            return options;
            
        }  
        set;
    }  
    
    public void selectedInitiativeRecord(){
        
        List<Initiatives__c> iniRecord = [SELECT Initiative_Billing_Type__c,Account_Name__c,Id,Name,Technical_Project_Manager__c FROM Initiatives__c Where Id=:initId];
        If(!iniRecord.isEmpty()){
            TechnicalProjectManagerName=iniRecord[0].Technical_Project_Manager__c;
            SelectedInitiativeBillingType=iniRecord[0].Initiative_Billing_Type__c;
            
        }
        system.debug('technicalProjectManager---'+TechnicalProjectManagerName);
        //TechnicalProjectManager = technicalProjectManager;
    }
    
    
    Public pagereference exportAsPDF()
    {
        try{
            PageReference pdf = new PageReference(''+getMobileredirectUrl+'/apex/ODS_ExportTimesheet');
            Timesheet__c  exportTimesheet = new Timesheet__c();
            //system.debug('####@@timsheetid:' +timsheetid);
            exportTimesheet = [Select Id, Name, Approver_Name__c,Approver_Email__c, Comments__c,Approver_Name__r.Name,Status_Date__c,Week_Start_Date__c,Week_End_Date__c,Account_Services__c,Account_Services__r.Account__c, Account_Services__r.Account__r.name, Account_Services__r.ODS_Service_Name__c, Status__c from Timesheet__c where Id=: CurrenTimesheetId ];
            System.debug('exportTimesheet ------------'+exportTimesheet .Account_Services__c);
            
            Date StartDate = exportTimesheet.Week_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');       
            
            Date EndDate = exportTimesheet .Week_End_Date__c;
            String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            
            
            String AccSerId= exportTimesheet.Account_Services__c;
            pdf.getParameters().put('Weekfromdate',FromDate);
            System.debug('@@@@@@@@FromDate------------'+FromDate);
            pdf.getParameters().put('Weektodate',ToDate);
            System.debug('@@@ToDate------------'+ToDate);
            pdf.getParameters().put('Accountservice',AccSerId);
            System.debug('@@@@@@@@@AccSerId------------'+AccSerId);
            
            return pdf;
        }
        catch(Exception e)  {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }
    Public pagereference exportAsExcel()
    {
        try{
            PageReference pdf = Page.ODS_ExportTimesheetExcel;
            Timesheet__c  exportTimesheet = new Timesheet__c();
            //system.debug('####@@timsheetid:' +timsheetid);
            exportTimesheet = [Select Id, Name, Approver_Name__c,Approver_Email__c, Comments__c,Approver_Name__r.Name,Status_Date__c,Week_Start_Date__c,Week_End_Date__c,Account_Services__c,Account_Services__r.Account__c, Account_Services__r.Account__r.name, Account_Services__r.ODS_Service_Name__c, Status__c from Timesheet__c where Id=: CurrenTimesheetId ];
            System.debug('exportTimesheet ------------'+exportTimesheet .Account_Services__c);
            
            Date StartDate = exportTimesheet.Week_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');       
            
            Date EndDate = exportTimesheet .Week_End_Date__c;
            String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            
            
            String AccSerId= exportTimesheet.Account_Services__c;
            System.debug('@@@@@@@@AccSerId------------'+AccSerId);
            pdf.getParameters().put('Weekfromdate',FromDate);
            System.debug('@@@@@@@@FromDate------------'+FromDate);
            pdf.getParameters().put('Weektodate',ToDate);
            System.debug('@@@ToDate------------'+ToDate);
            pdf.getParameters().put('Accountservice',AccSerId);
            System.debug('@@@@@@@@@AccSerId------------'+AccSerId);
            pdf.setRedirect(false);
            return pdf;
        }
        catch(exception e)
        {
            system.debug('The attachment is not deleted '+ e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
        
    }
    
    
}