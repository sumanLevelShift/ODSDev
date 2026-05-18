/**
* @author           Anil Kumar
* @version          1.0 
* @date             05-Dec-2017
* @Status           Developed
* @description      This is the controller class for Add Initiative Page
*
*/

global class ODS_InitiativeController
{
    
    public String WorkDayParam { get; set; }
    public string CurrenTimesheetId {get;set;}
    public string CurrenInitiativeId {get;set;}
    public string CurrenEmailInitiativeId;
    public string PassedInitiaitveJSON {get; set;}
    public string PassedInitiativeEstimateJSON{get;set;}
    public string PassedActiveStatus {get;set;}
    public string PassedTimesheetJSON {get;set;}
    public string currentUserName {get;set;}
    public string ClientContact {get;set;}
    public string PassAccountName {get;set;}
    public string PassServiceName {get;set;}
    public string AccountName {get;set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public static string Check_duplicate { get; set;} 
    public string ServiceName{get;set;}
    public string CurrentAccServiceId {get;set;}
    public string TimesheetComments {get;set;}
    public boolean IsPortalApprover {get;set;}
    public boolean IsInitiativeApprover {get;set;}
    public string PortalUserRole {get;set;}
    public string TimeshtJSONtoBind {get;set;}
    public string Initiative_JSONtoBind {get;set;}
    public string BriefDescriptionCK {get;set;}
    public string EstimateJSONtoBind {get;set;}
    public string CurrentTimeSheetStatus {get;set;}
    public string InitiativeStatus {get;set;}
    public string CurrentInitiativeStatus {get;set;}
    public string PassedWeekFromDate{get;set;}
    public string PassedWeekToDate{get;set;}
    public boolean isMyAccShow {get;set;}
    public string Initiative_Assumption { get;set;}
    public string Initiative_Description {get; set;}
    public boolean isCustomer {get;set;}
    public Time_Sheet_Cost__c objTimesheetCost;
    public string chartDivWidth {get;set;}
    public static string Initiative_JiraId {get; set;}
    
    //Added by Haish on 7-May-2021 for product list
    //public List<Technology_Group_Term__mdt> listProductSettings {get;set;}
    
    public string TestDescription { get;set;}
    public string  URL {get;set;}
    public Date dtStartDate;
    public Date dtEndDate;
    public Date dtUATExpectedDate;
    public String CurrentDate {get; set;}
    public Time_Sheet_Cost__c  objTimesheetCostforNextMonth;   
    public List<AggregateResult> resourceNameLst{get;set;}
    public List<AggregateResult> InitiativeLst{get;set;}
    public Boolean ShowPDFButton {get;set;} 
    public string resourceNameJSONtoBind {get;set;}
    public string initiativeJSONtoBind {get;set;}
    public List<Contact_Account_Service__c> ContctAccService {get;set;}
    public List<Contact_Account_Service__c> InitiativeContctAccService {get;set;}
    List<selectOption> options = new List<selectOption>();
    public List<Initiatives__c> statusList {get;set;}
    public string jsondata {get;set;}
    public List<Attachment> initiativeAttachment {get; set;}
    public string AttachmentToDelete {get;set;}
    public String filename{get;set;}
    public String body{get;set;}
    public  Set<String> targetValues {get;set;}
    
    
    public boolean showSaveCreateJira {get; set;}
    public boolean ReSendInitiativeEmailError {get;set;}
    public boolean ReCallInitiativeEmailError {get;set;}
    
    public boolean SaveActiveInitiativeStatusError {get;set;}
    public boolean ReDirectToViewIntitiativepageError {get;set;}
    public boolean ApproveInitiativeError {get;set;}
    public boolean RejectInitiativeError {get;set;}
    public boolean EscalateInitiativeError {get;set;}
    public boolean CloneInitiativeError {get;set;}
    
    //Added by Indhu on 15-Dec-2018 for CP-47
    public string InitiativeType {get; set;}
    
    //DL-159
    public string InitiativeBillingType {get; set;}
    
    //Added by Indhu on 10-Jan-2019 for portal changes requested by Abhishek
    public string InitiativeTrigger {get; set;}
    public List<string> InitiativeTags {get; set;}
    
    public string ArchitectOrEngineer {get; set;}
    public string TechnicalProjectManager {get; set;} // Added by harish for TPM
    
    //Added by Indhu on 22-May-2020 for Escalate Initiative enhancements
    public string EscalationComments {get; set;}
    
    public static boolean checkEstimationSummaryAvailable {get;set;}
    public static boolean  NonABCType{get;set;}
    
    public static boolean deliveryTeam {get;set;}
    
    public List<InitiativeEscalation__c> escalationList {get;set;}
    
    public static boolean inActiveApprover {get;set;}
    public String currentClientName { get; set; }

    public ODS_InitiativeController()
    {
        isCustomer=false;
        ArchitectOrEngineer = 'None';
        TechnicalProjectManager = 'None';
        InitiativeBillingType='Build';
        NonABCType=false;
        deliveryTeam=false;
        system.debug('@@@ Inside ODS_TimesheetController');
        Datetime currentDateTime = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        CurrentDate  = currentDateTime.format('MM/dd/yyyy'); // formats the date
        Account_Services__c  acc;      
        objTimesheetCost = new Time_Sheet_Cost__c();
        CurrentAccServiceId = ApexPages.CurrentPage().getParameters().get('AccServiceId');
        CurrenTimesheetId  = ApexPages.CurrentPage().getParameters().get('Id');
        CurrenInitiativeId  = ApexPages.CurrentPage().getParameters().get('CurrenInitiativeId');                                                                          
        system.debug('CurrenInitiativeId============'+CurrenInitiativeId);
        CurrentTimeSheetStatus = ApexPages.CurrentPage().getParameters().get('Status');  
        CurrentInitiativeStatus = ApexPages.CurrentPage().getParameters().get('Status');     
        PassedWeekFromDate = ApexPages.CurrentPage().getParameters().get('WeekStart');
        currentUserName = UserInfo.getName();     
        System.debug('@@@@UserInfo.getUserId()'+UserInfo.getUserId());  
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        if(objUser.Profile.Name==System.Label.DeliveryRoleProfile){
            deliveryTeam=true; 
        }
        system.debug('@@@@@@objUser.ContactId:'+objUser.ContactId);
        System.debug('@@@@@@CurrenInitiativeId  '+CurrenInitiativeId);   
        checkJiraId(CurrentAccServiceId);
        String InitiativeUrl = System.Label.ODS_SiteURL;          
        URL = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+CurrenInitiativeId+'&AccServiceId='+CurrentAccServiceId;        
        if(CurrentAccServiceId != null){
            acc = [SELECT ODS_Services__c,Account__c,Account__r.Customer_Type__c,Account__r.Name,ODS_Services__r.Name,ODS_Service_Name__c,Service_Workspace_Id__c,Technical_Account_Manager_Email__c,Agile__c,JIRA_Domain_Name__c FROM  Account_Services__c WHERE Id =: CurrentAccServiceId]; 
        }
        if(acc != null){
            PassAccountName = acc.Account__r.Name;
            PassServiceName = acc.ODS_Service_Name__c ;
            if(acc.Account__r.Customer_Type__c !='ABC Type'){
                NonABCType=true;
            }
        }
        else{
            PassAccountName = 'None';
            PassServiceName = 'None';
        }
        showSaveCreateJira = False;
        if(acc != null){         
            system.debug('Agile --> '+acc.Agile__c+'Jira Domain --> '+acc.JIRA_Domain_Name__c+'Service_Workspace_Id --> '+acc.Service_Workspace_Id__c);
            if((acc.Agile__c=='JIRA') && (acc.JIRA_Domain_Name__c==System.Label.ODS_Demandblue_JIRA_URL) && (String.isNotBlank(acc.Service_Workspace_Id__c))){
                showSaveCreateJira=True;      //for Save & Create Req 1.
            }        
        }
        
        PortalUserRole = objUser.PortalUserRole__c;
        IsPortalApprover = False;
        
        List<Initiatives__c> initiativeStatusCheck = [select id,Status__c from Initiatives__c  where id =: CurrenInitiativeId];
        if(!(initiativeStatusCheck.isEmpty())){
            InitiativeStatus = initiativeStatusCheck[0].Status__c;
        }
        system.debug('InitiativeStatus==========='+InitiativeStatus);
        
        IsInitiativeApprover = false;
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
                    InitiativeContctAccService  = new List<Contact_Account_Service__c>();
                    System.debug('@@@@objUser.ContactId'+objUser.ContactId);
                    System.debug('@@@@accServiceById[0].ODS_Services__c'+accServiceById[0].ODS_Services__c);
                    InitiativeContctAccService  = ODS_Data_Utility.fetchInitiativeContactAccountService(objUser.ContactId, accServiceById[0].ODS_Services__c);
                    System.debug('@@@@InitiativeContctAccService'+InitiativeContctAccService);
                    if(InitiativeContctAccService.size() > 0 ){
                        IsInitiativeApprover = InitiativeContctAccService[0].Is_initiate_approver__c;
                    }
                    else{
                        IsInitiativeApprover = false;
                    }                 
                }
            }        
        }                
        if(CurrenInitiativeId  != null){
            getEstimationDetails();
            generateBurnDownChart(CurrenInitiativeId);
            System.debug('@@@@@@@@@CurrenInitiativeId'+CurrenInitiativeId);
            GetInitiativeDetails(CurrenInitiativeId);
            GetCurrentAttachments();
            Initiatives__c initiativeobj = ODS_Data_Utility.FetchInitiativeByID(CurrenInitiativeId);
            CurrentInitiativeStatus  = initiativeobj.Status__c;
            
            if(objUser.PortalUserRole__c != 'Customer'  && (CurrentInitiativeStatus =='Saved' || CurrentInitiativeStatus=='Initiative Recalled' || CurrentInitiativeStatus=='Re-evaluate')){
                List<Contact_Account_Service__c> existsContact = [SELECT Is_initiate_approver__c,Contact__r.Name From Contact_Account_Service__c WHERE 
                                                                  Account__c =: acc.Account__c AND ODS_Service__c =: acc.ODS_Services__c
                                                                  AND Contact__c=:initiativeobj.Client_side_Contact__c];
                system.debug('existsContact-'+existsContact);
                if(!existsContact.isEmpty()){
                    if(!existsContact[0].Is_initiate_approver__c){
                        inActiveApprover=true;
                        currentClientName = existsContact[0].Contact__r.Name;
                    }
                }
            }
            
            productnames  = initiativeobj.Product__c; //added by harish
            if(CurrentAccServiceId == null){
                GetLoggedUserAccountService();
            }
            else{
                AssignPassedAccountService();
            }
            GetAccountServiceChanges();
            if(objUser.PortalUserRole__c == 'Customer')
            { 
                isCustomer= true;
            } 
        }
        else
        {
            if(CurrentAccServiceId == null){
                GetLoggedUserAccountService();
            }
            else{
                AssignPassedAccountService();
            }
        } 
        getEscalationDetails();            
    }
    
    public String getClientContact(){
        return ClientContact;
    }
    public string getEstimationDetails(){
        string estimationDetailsPathURL;
        checkEstimationSummaryAvailable=false;
        if(CurrenInitiativeId  != null){
            List<Estimation_Summary__c> estimationSummaryList=[SELECT Id,Customer__c,Project_ID__c FROM Estimation_Summary__c where Project_ID__c=:CurrenInitiativeId AND Status__c='Approved' limit 1];
            if(!estimationSummaryList.isEmpty()){
                estimationDetailsPathURL='/DetailsEstimationSummary?estimationId='+estimationSummaryList[0].id+'&accountId='+AccountID+'&serviceId='+ServiceID;
            }else{
                checkEstimationSummaryAvailable=true;
            }
            
        }
        return estimationDetailsPathURL;
    }
    public List<selectOption> getContactAccountServices()
    {    
        system.debug('****CurrentInitiativeStatus--->'+CurrentInitiativeStatus);
        system.debug('Line No:132==AccountID ==='+AccountID+'===='+ServiceID);
        List<Contact_Account_Service__c> Contacts=new List<Contact_Account_Service__c>();
        if(!isCustomer && (CurrentInitiativeStatus==null || CurrentInitiativeStatus =='Saved' || CurrentInitiativeStatus=='Initiative Recalled' || CurrentInitiativeStatus=='Re-evaluate')){
            Contacts = [SELECT Contact__r.Name From Contact_Account_Service__c WHERE Account__c =: AccountID AND ODS_Service__c =: ServiceID AND Is_initiate_approver__c   =: true AND Contact__c != null]; 
        }else{
            Contacts = [SELECT Contact__r.Name From Contact_Account_Service__c WHERE Account__c =: AccountID AND ODS_Service__c =: ServiceID AND Contact__c != null ]; 
        }
        system.debug('==Contacts==='+Contacts);
        for(Contact_Account_Service__c Contact : Contacts ){
            String AllContacts = Contact.Contact__r.Name;
            System.debug('Line No:137 Contact Acc Service '+Contact.Contact__r.Name);
            options.add(new selectOption(AllContacts , AllContacts ));
        }
        system.debug('==options==='+options);
        return options;    
    }
    
    //get the multi-select pick list values
    public List<SelectOption> getInitiativeTagPicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Initiatives__c.Tags_About_Initiative__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    //DL-159
    public List<SelectOption> getInitiativeBillingType {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Initiatives__c.Initiative_Billing_Type__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            }
            return options;
        }  
        set;
    }
    public List<SelectOption> getArchitectOrEngineer {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Initiatives__c.Solution_Architect_Engineer__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
        public List<SelectOption> getTriggerForInitiative {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Initiatives__c.Trigger_For_Initiative__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    public List<SelectOption> getInitiativeType {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Initiatives__c.Initiative_Type__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    //Added by Harish --TPM 04-06-21
    public List<SelectOption> getTechnicalProjectManager {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Initiatives__c.Technical_Project_Manager__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }       
    
    
    public void GetInitiativeDetails(String InitiativeId){
        List<Estimate__c> estimateList = new List<Estimate__c>();
        system.debug('###PortalUserRole :' +PortalUserRole);
        if(PortalUserRole != 'Customer'){
            estimateList = ODS_Data_Utility.FetchInitiativeDetailsbyId(InitiativeId);
        }
        else{
            estimateList = ODS_Data_Utility.FetchCustomerInitiativeDetails(InitiativeId);
        }
        Initiatives__c initiativeobj = ODS_Data_Utility.FetchInitiativeByID(InitiativeId);
        if(initiativeobj != null){
            CurrentInitiativeStatus =initiativeobj.Status__c;
        }
        else{
            CurrentInitiativeStatus ='';
        }
        
        Initiatives__c initiativeList= [select Brief_Description__c,Assumption__c from Initiatives__c  where ID =: InitiativeId];
        Initiative_Description =  initiativeList.Brief_Description__c;
        Initiative_Assumption = initiativeList.Assumption__c;
        
        EstimateJSONtoBind = JSON.serialize(estimateList)+'~'+CurrentInitiativeStatus;
        EstimateJSONtoBind = EstimateJSONtoBind.replace('\'','`').replace('"','\\"').replace('\\r\\n',' ').replace('\\r',' ').replace('\\n',' ').replace('\\t',' ');
        System.debug('@@@@@EstimateJSONtoBind'+EstimateJSONtoBind);
        
        Initiative_JSONtoBind = String.escapeSingleQuotes(JSON.serialize(initiativeobj)+'~'+CurrentInitiativeStatus);
        System.debug('@@@@@Initiative_JSONtoBind'+Initiative_JSONtoBind);
    }
    
    public void GetCurrentAttachments()
    {
        List<Attachment> initiativeAttachmentTemp = new List<Attachment>();
        if((CurrenInitiativeId != Null)&&(CurrenInitiativeId !=''))
        {
            initiativeAttachmentTemp = [Select Id, Name, CreatedDate, ParentId, body from Attachment where ParentId =:CurrenInitiativeId Order By CreatedDate DESC Limit 10];
        }
        if((initiativeAttachmentTemp.size() != 0)&&(!initiativeAttachmentTemp.isEmpty()) &&(initiativeAttachmentTemp != Null))
        {
            initiativeAttachment = initiativeAttachmentTemp;
        }
        else
        {
            initiativeAttachment = Null;
        }
        
    }
    
    public PageReference DeleteAttachment()
    {
        try{
            string attachmentId = AttachmentToDelete;
            Attachment attachmentdelete = new Attachment();
            string currentId;
            attachmentdelete  = [Select Id, ParentId From Attachment where Id=:attachmentId Limit 1];
            if(attachmentdelete != null){
                currentId = attachmentdelete.ParentId;
                delete attachmentdelete;
            } 
            //  GetCurrentAttachments();
            system.debug('currentId ================ '+currentId);
            Initiatives__c initiativeRecById = ODS_Data_Utility.FetchInitiativeByID(currentId);
            string AccntServiceID = initiativeRecById.Account_Service__c;
            String initiativeStats = initiativeRecById.Status__c;
            PageReference pgRef = new PageReference('/apex/InitiativePage?CurrenInitiativeId=' +initiativeRecById.id + '&AccServiceId='+AccntServiceID+ '&Status='+initiativeStats);        
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
    public PageReference saveAttachment(){
        try{
            string Name=Apexpages.currentPage().getParameters().get('attachmentName');
            string body=Apexpages.currentPage().getParameters().get('attachmentBody');
            string actualBodyString = body.substring(body.indexOf('base64,')+7);
            attachment uploadAttachment = new Attachment();
            uploadAttachment.name = Name;
            uploadAttachment.body = EncodingUtil.base64Decode(actualBodyString);
            uploadAttachment.ParentId = CurrenInitiativeId;
            insert uploadAttachment;  
            Initiatives__c initiativeRecById = ODS_Data_Utility.FetchInitiativeByID(CurrenInitiativeId);
            string AccntServiceID = initiativeRecById.Account_Service__c;
            String initiativeStats = initiativeRecById.Status__c;
            PageReference pgRef = new PageReference('/apex/InitiativePage?CurrenInitiativeId=' +initiativeRecById.id + '&AccServiceId='+AccntServiceID+ '&Status='+initiativeStats);        
            pgRef.setRedirect(true);
            return pgRef;
        }
        catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }   
    public void AssignPassedAccountService()
    {
        List<Account_Services__c > accServiceLst = new List<Account_Services__c >();
        System.debug('@@@@@@Line No:217 CurrentAccServiceId'+CurrentAccServiceId);
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
                System.debug('@@@@@@QAccountId'+AccountId);
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
    
    
    
    public class Estimate {
        public String Phase;
        public String TaskName;
        public String Assumption;
        public String Hours;
        public Estimate(string s1, string s2, string s3,string s4){
            Phase = s1;
            TaskName = s2;
            Assumption = s3;
            Hours = s4;
        }
    }
    
    public class JSONserialize {
        public List<Estimate> Estimate;
        public String InitiativeName;
        public String StartDate;
        public String EndDate;
        public String UATExpectedDate;
        public String ContactAccService;
        public String BriefDescription;
        public String Assumption;
        public String Status;
        public String stats;
        public String InitiativeType;
        public String BucketHoursType;
        public String InitiativeBillingType;
        public String InitiativeProgrammingReason;
        public String Initiativeproductnames;// Added harish 
        public String InitiativeTrigger;
        public String ArchitectOrEngineer;
        public String TechnicalProjectManager;// Added harish 
        public String ProbablePercent;
        public List<String> InitiativeTag;
        public string JiraId;
        public Decimal OffshoreEstimate;   
        public String BusinessChallenge;
        public String PersonasInvolved;
        public String TechnologyDetails;
        public String OutcomeOfOurSolution;
        
    }
    
    public static JSONserialize parse(String json) {
        return (JSONserialize) System.JSON.deserialize(json, JSONserialize.class);
    }
    
    public Boolean CheckInitiativeId(String InitiativeName){
        if(CurrentAccServiceId != null || CurrentAccServiceId != ''){          
            List<Initiatives__c> initiatives = [select id,Name from Initiatives__c where Name =: InitiativeName AND Account_Service__c =: CurrentAccServiceId];
            if(initiatives.size() == 0){
                return true;  
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
    } 
    
    public Pagereference SaveInitativeAndEstimate()
    {
        try{
            Check_duplicate  = 'false';
            System.debug('Line No:321 ===>PassedInitiativeEstimateJSON '+PassedInitiativeEstimateJSON );
            if(PassedInitiativeEstimateJSON != null){
                JSONserialize obj = parse(PassedInitiativeEstimateJSON);
                System.debug(obj);
                if(CurrenInitiativeId  == null || CurrenInitiativeId  == ''){
                    if(CheckInitiativeId(obj.InitiativeName)){  
                        Initiatives__c  initiativeobject = new Initiatives__c();
                        initiativeobject.Name = obj.InitiativeName;
                        initiativeobject.Probable_Start_Date__c = date.parse(obj.StartDate);
                        initiativeobject.Probable_End_Date__c = date.parse(obj.EndDate);
                        system.debug('obj.BucketHoursType---'+obj.BucketHoursType);
                        initiativeobject.Initiative_Billing_Type__c=obj.InitiativeBillingType;
                        if(obj.BucketHoursType != 'true')
                        {
                            initiativeobject.Is_a_bucket_of_hours_type__c = false;
                        }
                        else
                        {
                            initiativeobject.Is_a_bucket_of_hours_type__c = true;
                        }
                        if(obj.UATExpectedDate == null || obj.UATExpectedDate =='' ){
                            initiativeobject.UAT_Expected_Date__c = null;
                        }
                        else{
                            initiativeobject.UAT_Expected_Date__c = date.parse(obj.UATExpectedDate);
                        }
                        
                        // initiativeobject.Is_a_bucket_of_hours_type__c=obj.BucketHoursType;
                        initiativeobject.Initiative_Type__c = obj.InitiativeType;
                        //Harish 08-5-21 -  Product custom filed getting the values and display in the long text area
                        initiativeobject.Product__c =obj.Initiativeproductnames;
                        // ENd- 08-5-21
                        initiativeobject.JIRA_ID__c = obj.JiraId;
                        initiativeobject.Offshore_Estimate__c = obj.OffshoreEstimate;
                        initiativeobject.Technical_Project_Manager__c = obj.TechnicalProjectManager; // Added by Harish
                        if(obj.UATExpectedDate == null || obj.UATExpectedDate =='' ){
                            initiativeobject.UAT_Expected_Date__c = null;
                        }
                        else{
                            initiativeobject.UAT_Expected_Date__c    = date.parse(obj.UATExpectedDate);
                        }
                        initiativeobject.Initiative_Programming_Reason__c = obj.InitiativeProgrammingReason;
                        initiativeobject.Business_Challenge__c = obj.BusinessChallenge;
                        initiativeobject.Persona_s_Involved__c = obj.PersonasInvolved;
                        initiativeobject.Technology_Details__c = obj.TechnologyDetails;
                        initiativeobject.Outcome_of_our_solution__c = obj.OutcomeOfOurSolution;
                        
                        
                        /*if(obj.OffshoreEstimate != null){
system.debug('##OffshoreEstimate Value:' + obj.OffshoreEstimate);
initiativeobject.Offshore_Estimate__c = decimal.valueOf(obj.OffshoreEstimate);
}*/
                        if(obj.ProbablePercent != null){
                            system.debug('##Percentage Value:' + obj.ProbablePercent);
                            initiativeobject.Probability_Percentage__c = decimal.valueOf(obj.ProbablePercent);
                        }
                        system.debug('##Tags about Initiative: ' + obj.InitiativeTag);
                        if(obj.InitiativeTag != null && (obj.InitiativeTag).size() > 0){
                            string tags = '';
                            for(string tag: obj.InitiativeTag){
                                tags += tag + ';';
                            }
                            initiativeobject.Tags_About_Initiative__c = tags;
                        }
                        initiativeobject.Trigger_For_Initiative__c = obj.InitiativeTrigger;
                        initiativeobject.Solution_Architect_Engineer__c = obj.ArchitectOrEngineer;
                        initiativeobject.Technical_Project_Manager__c = obj.TechnicalProjectManager; //Added by Harish
                        List<Contact_Account_Service__c> Contacts = [SELECT Contact__r.Name,Contact__c,ID From Contact_Account_Service__c WHERE Account__c =: AccountID AND ODS_Service__c =: ServiceID  AND Contact__r.Name =: obj.ContactAccService AND Is_initiate_approver__c = true];
                        if(Contacts.size() > 0){
                            initiativeobject.Client_side_Contact__c = Contacts[0].Contact__c; 
                        }
                        initiativeobject.Brief_Description__c = saveBriefDescription(obj.BriefDescription);                    
                        System.debug('@@@@@@BriefDescription'+initiativeobject.Brief_Description__c);
                        TestDescription = obj.BriefDescription;                    
                        initiativeobject.Assumption__c = obj.Assumption;
                        if(obj.stats == 'Saved' || obj.stats == 'SaveCreateJira') { 
                            initiativeobject.Status__c = 'Saved'; 
                        }
                        if(obj.stats == 'Submitted') 
                        { 
                            initiativeobject.Status__c = 'Initiative Submitted';  
                            initiativeobject.Initiative_submitted_date__c = date.today(); 
                        }
                        //  initiativeobject.Status__c = obj.Status;
                        initiativeobject.Account_Service__c = CurrentAccServiceId;
                        insert initiativeobject;
                        System.debug('initiativeobject'+initiativeobject);
                        ID Initiativeid = initiativeobject.ID;
                        CurrenEmailInitiativeId = Initiativeid;
                        String InitiativeUrl = System.Label.ODS_SiteURL; 
                        String uiThemeDisplayed = UserInfo.getUiThemeDisplayed();
                        if(uiThemeDisplayed=='Theme3'){  // Classsic Theme Value          
                            
                            URL = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+Initiativeid+'&AccServiceId='+CurrentAccServiceId;
                            
                        }
                        if(uiThemeDisplayed=='Theme4t'){  // Mobile Theme Value          
                            
                            URL = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+Initiativeid+'&AccServiceId='+CurrentAccServiceId;
                            
                        }
                        
                        String Contact;
                        if(Contacts.size() == 0){
                            Contact = '';
                        }
                        else{
                            Contact = Contacts[0].Contact__r.Name;
                        }
                        
                        if(obj.stats == 'Submitted')
                        { 
                            sendEmailInitiative(Initiativeid,CurrentAccServiceId,obj.stats,Contact,URL); 
                        }
                        for(Estimate est: obj.Estimate){
                            Estimate__c estimateobject = new Estimate__c();
                            estimateobject.Phase__c =  est.Phase;
                            estimateobject.Hours__c = decimal.valueOf(est.Hours);
                            estimateobject.Task_Components__c = est.TaskName;
                            estimateobject.Assumptions__c = est.Assumption;
                            estimateobject.Initiative_Lookup__c = Initiativeid;
                            insert estimateobject;
                        }                        
                        
                        if(showSaveCreateJira && obj.stats=='SaveCreateJira'){
                            system.debug('%%%SaveCreateJira' + obj.stats);
                            Account_Services__c  acc;
                            acc = [SELECT Id,Service_Workspace_Id__c,Technical_Account_Manager_Email__c FROM Account_Services__c WHERE Id =: CurrentAccServiceId];
                            
                            String jiraUserEmailId = acc.Technical_Account_Manager_Email__c;
                            
                            List<Jira_Data_Mapping__mdt> jiraDataMapping=[SELECT ODS_User_Email_Id__c, Mapping_Type__c, Jira_User_Email_Id__c FROM Jira_Data_Mapping__mdt WHERE ODS_User_Email_Id__c =: acc.Technical_Account_Manager_Email__c AND Mapping_Type__c =: 'User'];
                            
                            if(jiraDataMapping.size() > 0){
                                if(String.isNotBlank(jiraDataMapping[0].Jira_User_Email_Id__c)){
                                    jiraUserEmailId = jiraDataMapping[0].Jira_User_Email_Id__c;
                                }
                            }
                            
                            String issueTypeId;
                            Jira_Data_Mapping__mdt jiraDataMdt = [SELECT Mapping_Type__c, DeveloperName, Issue_Type_Id__c FROM Jira_Data_Mapping__mdt WHERE Mapping_Type__c =: 'Issue Type' AND DeveloperName =: 'Story'];
                            if(String.isNotBlank(jiraDataMdt.Issue_Type_Id__c)){
                                issueTypeId = jiraDataMdt.Issue_Type_Id__c;
                            }
                            
                            ODS_JIRAIntegration.postCalloutToJira(jiraUserEmailId,acc.Service_Workspace_Id__c,Initiativeid,issueTypeId);    
                        }
                        
                        return redirectToInitiative();
                    }
                    else{
                        Check_duplicate  = 'true';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Initiative Name already exists'));
                        return null;
                    }
                }
                else{
                    Initiatives__c  initiativeobject = new Initiatives__c(id=CurrenInitiativeId);
                    initiativeobject.Name = obj.InitiativeName;
                    initiativeobject.Probable_Start_Date__c = date.parse(obj.StartDate);
                    initiativeobject.Probable_End_Date__c = date.parse(obj.EndDate);
                    if(obj.UATExpectedDate == null || obj.UATExpectedDate =='' || obj.UATExpectedDate =='undefined' || obj.UATExpectedDate =='Undefined'){
                        initiativeobject.UAT_Expected_Date__c = null;
                    }
                    else{
                        initiativeobject.UAT_Expected_Date__c = date.parse(obj.UATExpectedDate);
                    }
                    if(obj.BucketHoursType != 'true')
                    {
                        initiativeobject.Is_a_bucket_of_hours_type__c = false;
                    }
                    else
                    {
                        initiativeobject.Is_a_bucket_of_hours_type__c = true;
                    }
                    initiativeobject.Brief_Description__c = saveBriefDescription(obj.BriefDescription);
                    system.debug('***BriefDescription : '+ initiativeobject.Brief_Description__c);
                    initiativeobject.Assumption__c = obj.Assumption;
                    initiativeobject.Initiative_Type__c = obj.InitiativeType;
                    initiativeobject.JIRA_ID__c = obj.JiraId;
                    initiativeobject.Offshore_Estimate__c = obj.OffshoreEstimate;
                    initiativeobject.Technical_Project_Manager__c = obj.TechnicalProjectManager; // Added by Harish
                    initiativeobject.Initiative_Programming_Reason__c = obj.InitiativeProgrammingReason;
                    initiativeobject.Business_Challenge__c = obj.BusinessChallenge;
                    initiativeobject.Persona_s_Involved__c = obj.PersonasInvolved;
                    initiativeobject.Technology_Details__c = obj.TechnologyDetails;
                    initiativeobject.Outcome_of_our_solution__c = obj.OutcomeOfOurSolution;
                    initiativeobject.Product__c = obj.Initiativeproductnames;  // Added by Harish 
                    /*if(obj.OffshoreEstimate != null){
system.debug('##OffshoreEstimate Value:' + obj.OffshoreEstimate);
initiativeobject.Offshore_Estimate__c = decimal.valueOf(obj.OffshoreEstimate);
}*/
                    
                    if(obj.ProbablePercent != null){
                        initiativeobject.Probability_Percentage__c = decimal.valueOf(obj.ProbablePercent);
                    }
                    if(obj.InitiativeTag != null && (obj.InitiativeTag).size() > 0){
                        string tags = '';
                        for(string tag: obj.InitiativeTag){
                            tags += tag + ';';
                        }
                        initiativeobject.Tags_About_Initiative__c = tags;
                    }
                    initiativeobject.Trigger_For_Initiative__c = obj.InitiativeTrigger;
                    initiativeobject.Solution_Architect_Engineer__c = obj.ArchitectOrEngineer;
                    initiativeobject.Technical_Project_Manager__c = obj.TechnicalProjectManager; // Added by Harish
                    initiativeobject.Initiative_Billing_Type__c=obj.InitiativeBillingType;
                    List<Contact_Account_Service__c> Contacts = [SELECT Contact__r.Name,Contact__c,ID From Contact_Account_Service__c WHERE Account__c =: AccountID AND ODS_Service__c =: ServiceID  AND Contact__r.Name =: obj.ContactAccService AND Is_initiate_approver__c = true];
                    if(Contacts.size() > 0){
                        initiativeobject.Client_side_Contact__c = Contacts[0].Contact__c; 
                    }
                    list<Initiatives__c> initiativeList = [select Client_side_Contact__r.Name from Initiatives__c where id =: CurrenInitiativeId AND (Status__c = 'Active Initiative' or Status__c = 'Initiative Approved' or Status__c = 'Initiative Submitted')];
                    
                    if(obj.stats == 'Saved') 
                    { 
                        if(initiativeList.isEmpty()){
                            initiativeobject.Status__c = 'Saved';   
                        }
                    }
                    if(obj.stats == 'Submitted') 
                    {   
                        initiativeobject.Status__c = 'Initiative Submitted'; 
                        initiativeobject.Initiative_submitted_date__c = date.today(); 
                    }
                    
                    update initiativeobject;
                    Initiatives__c initiative = [select Client_side_Contact__r.Name from Initiatives__c where id =: CurrenInitiativeId];
                    if(obj.stats == 'Submitted') 
                    { 
                        sendEmailInitiative(CurrenInitiativeId,CurrentAccServiceId,obj.stats,initiative.Client_side_Contact__r.Name,URL); 
                    }
                    System.debug('@@@@@@@@@CurrenInitiativeId'+CurrenInitiativeId);
                    Deleteallestimates(CurrenInitiativeId);  
                    for(Estimate est: obj.Estimate)
                    {
                        Estimate__c estimateobject = new Estimate__c();
                        estimateobject.Phase__c =  est.Phase;
                        estimateobject.Hours__c = decimal.valueOf(est.Hours);
                        estimateobject.Task_Components__c = est.TaskName;
                        estimateobject.Assumptions__c = est.Assumption;
                        estimateobject.Initiative_Lookup__c = CurrenInitiativeId;
                        insert estimateobject;
                    }    
                    return redirectToInitiative();                      
                }
            }
            else {  
                Check_duplicate  = 'true'; 
                return null; 
            }
        }
        catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('error --> '+e.getMessage()+'---line no--'+e.getLineNumber());
            return null;
        }
        
    }
    //Added by Indhu on 30-May-2020 for resending the initiative email.
    public PageReference ReSendInitiativeEmail()
    {
        try{
            System.debug('##CurrenInitiativeId: ' +CurrenInitiativeId);
            String InitiativeUrl = System.Label.ODS_SiteURL; 
            
            URL = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+CurrenInitiativeId+'&AccServiceId='+CurrentAccServiceId;
            Initiatives__c initiative = [select Client_side_Contact__r.Name from Initiatives__c where id =:CurrenInitiativeId];
            system.debug('MyInitiative '+initiative);
            sendEmailInitiative(CurrenInitiativeId,CurrentAccServiceId,'Submitted',initiative.Client_side_Contact__r.Name,URL); 
            ReSendInitiativeEmailError = false;
            return null;
        }
        catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ReSendInitiativeEmailError = true;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }
    
    //Added by Indhu on 4-June -2020 for recall the initiative.
    public PageReference ReCallInitiativeEmail()
    {
        
        try{
            System.debug('##CurrenInitiativeId: ' +CurrenInitiativeId);
            Initiatives__c init = new Initiatives__c(Id = CurrenInitiativeId);
            init.Status__c = 'Initiative Recalled';
            update init;
            String InitiativeUrl = System.Label.ODS_SiteURL;  
            URL = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+CurrenInitiativeId+'&AccServiceId='+CurrentAccServiceId;
            
            Initiatives__c initiative = [select Client_side_Contact__r.Name from Initiatives__c where id =: CurrenInitiativeId];
            sendEmailInitiative(CurrenInitiativeId,CurrentAccServiceId,'Initiative Recalled',initiative.Client_side_Contact__r.Name,URL); 
            ReCallInitiativeEmailError = false;
            return null;
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ReCallInitiativeEmailError = true;
            return null;
        }
        
    }
    
    public void Deleteallestimates(String InitiativeID){
        List<Estimate__c> estimates = [SELECT ID from Estimate__c WHERE Initiative_Lookup__c =: InitiativeID ];
        delete estimates;
    }
    
    
    public void SaveActiveInitiativeStatus(){
        
        try{
            list<Initiatives__c>  deliveredEmailCount =[select Name,Id from Initiatives__c where Account_Service__r.id =: CurrentAccServiceId And Status__c = 'Initiative Delivered'];
            
            Initiatives__c initiative = new Initiatives__c(id=CurrenInitiativeId);
            initiative.Status__c  = PassedActiveStatus;
            initiative.Approver_Name__c = UserInfo.GetUserID();
            initiative.Approved_Date__c = Date.Today();
            Update initiative;
            if(deliveredEmailCount.Size() == 0 && initiative.Status__c == 'Initiative Delivered' ){
                
                
                sendEmailInitiativeDelivered(CurrenInitiativeId,CurrentAccServiceId); 
            }
            SaveActiveInitiativeStatusError = false;
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            SaveActiveInitiativeStatusError = true;
        }
    }
    
    public PageReference ApproveInitiative()
    {
        try{
            system.debug('=====ApproveInitiative====');
            Initiatives__c initiative = new Initiatives__c(id=CurrenInitiativeId);
            initiative.Status__c  = 'Initiative Approved';
            initiative.Comments__c = TimesheetComments;
            initiative.Approver_Name__c = UserInfo.GetUserID();
            //initiative.Approved_Date__c = Date.Today(); 
            initiative.Initiative_Approved_Date__c = Date.Today();             
            Update initiative;
            TimesheetComments = '';
            Initiatives__c init = [select Client_side_Contact__r.Name from Initiatives__c where id =: CurrenInitiativeId];
            sendEmailInitiative(CurrenInitiativeId,CurrentAccServiceId,'Initiative Approved',init.Client_side_Contact__r.Name,URL);  
            PageReference pgRef = new PageReference('/apex/Dashboard');
            pgRef.setRedirect(True);
            ApproveInitiativeError = false;
            return pgRef;
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ApproveInitiativeError = true;
            return null;
        }
        
    }
    
    public PageReference RejectInitiative()
    {
        try{
            Initiatives__c initiative = new Initiatives__c(id=CurrenInitiativeId);
            initiative.Status__c  = 'Re-evaluate';
            initiative.Approver_Name__c = UserInfo.GetUserID();
            initiative.Comments__c = TimesheetComments;
            initiative.Initiative_Re_Evaluation_Date__c = Date.Today();
            initiative.Revised_Approved__c = true;
            Update initiative;
            TimesheetComments = '';
            Initiatives__c init = [select Client_side_Contact__r.Name from Initiatives__c where id =: CurrenInitiativeId];
            sendEmailInitiative(CurrenInitiativeId,CurrentAccServiceId,'Re-evaluate',init.Client_side_Contact__r.Name,URL);   
            PageReference pgRef = new PageReference('/apex/Dashboard');
            pgRef.setRedirect(True);
            RejectInitiativeError = false;
            return pgRef;
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            RejectInitiativeError = true;
            return null;
        }
    }
    
    //Added by Indhu on 23-May-2020 for Escalate Initiative enhancements
    public List<InitiativeEscalation__c> getEscalationDetails()
    {
        escalationList = [SELECT Id, Name, EscalationDateTime__c, EscalationDetails__c, Initiative__c, InitiativeEscalationRecipients__c
                          FROM InitiativeEscalation__c WHERE Initiative__c =: CurrenInitiativeId];
        System.debug('##escalationList: ' +escalationList);
        return escalationList;
    }
    
    public PageReference EscalateInitiative()
    {
        try{
            InitiativeEscalation__c initiativeEscalation = new InitiativeEscalation__c();
            initiativeEscalation.Initiative__c = CurrenInitiativeId;
            initiativeEscalation.EscalationDateTime__c = DateTime.now(); 
            initiativeEscalation.EscalationDetails__c = EscalationComments;
            initiativeEscalation.InitiativeEscalationCopy__c = Label.ODS_Initiative_Escalation_CC_Email;
            initiativeEscalation.InitiativeEscalationRecipients__c = Label.ODS_Initiative_Escalation_Email;
            insert initiativeEscalation;
            System.debug('##initiativeEscalation:' +initiativeEscalation);
            sendEscalationEmail(CurrenInitiativeId, EscalationComments);
            EscalationComments = '';
            PageReference pgRef = new PageReference('/apex/ViewInitiative');
            pgRef.setRedirect(True);
            EscalateInitiativeError = false;
            return pgRef;
        }
        catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            EscalateInitiativeError = true;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
        
    }
    
    @Future(Callout = true)
    public static void sendEscalationEmail( string initiativeId, string escalationComments)
    {
        System.debug('##Send Email Triggered :' + initiativeId + '##Comments: ' + escalationComments);
        List<String> lstToAddress = new List<String>();
        List<String> lstCcAddress = new List<String>();
        
        /*Initiatives__c initiative = [select Id, Name, Account_Name__c, Account_Service__c, Account_Service__r.Technical_Account_manager__r.Name, Account_Service__r.Technical_Account_manager__r.Signature__c,
Account_Service__r.Technical_Account_Manager_Email__c, Account_Service__r.Backup_CSM__c, 
Account_Service__r.Backup_CSM__r.Email, JIRA_ID__c,Offshore_Estimate__c,UAT_Expected_Date__c,Probable_Start_Date__c, Probable_End_Date__c
from Initiatives__c where id =: initiativeId];*/
        
        Initiatives__c initiative = [select Id, Name, Account_Name__c, Account_Service__c, Account_Service__r.Technical_Account_manager__r.Name, 
                                     Account_Service__r.Technical_Account_Manager_Email__c, Account_Service__r.Backup_CSM__c, Account_Service__r.Technical_Account_manager__r.Phone,
                                     Account_Service__r.Backup_CSM__r.Email, JIRA_ID__c,Offshore_Estimate__c,UAT_Expected_Date__c,Probable_Start_Date__c, Probable_End_Date__c,
                                     Account_Service__r.Account__r.Small_Business__c
                                     from Initiatives__c where id =: initiativeId];
        string signTitle='CSM';
        if(initiative.Account_Service__r.Account__r.Small_Business__c){
            signTitle='Technical Lead';
        }
        
        System.debug('##initiative: ' +initiative);
        lstToAddress.addAll( Label.ODS_Initiative_Escalation_Email.split(';') );
        lstCcAddress.addAll( Label.ODS_Initiative_Escalation_CC_Email.split(';') );
        lstCcAddress.add(initiative.Account_Service__r.Technical_Account_Manager_Email__c);
        if(initiative.Account_Service__r.Backup_CSM__r.Email != null){
            lstCcAddress.add(initiative.Account_Service__r.Backup_CSM__r.Email);
        } 
        
        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
        if(lstToAddress.size() > 0){
            mail.setToAddresses(lstToAddress);
        }
        if(lstCcAddress.size() > 0){
            mail.setCcAddresses(lstCcAddress);
        }
        String strHtmlBody = ''; 
        
        String subject = 'Escalation for ' + initiative.Name + ' Initiative for ' + initiative.Account_Name__c; 
        mail.setSubject(subject);
        string htmlbody='<table width="100%" cellpadding="0" cellspacing="0"><tr><td><font face="Calibri " size="3">Hi '+ Label.ODS_Initiative_Escalation_Email_Recipient_Name +',';
        
        // strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi '+ Label.ODS_Initiative_Escalation_Email_Recipient_Name +',';
        htmlbody += '<br/><br/>'+ escalationComments + '<br/><br/> Your prompt action is greatly appreciated.';
        htmlbody += '<br/><br/><strong>Initiative details – </strong><br/>Initiative Name: ' + initiative.Name;
        htmlbody += '<br/>JIRA Id: ' + initiative.JIRA_ID__c;
        htmlbody += '<br/>Offshore Estimate:' + initiative.Offshore_Estimate__c;
        if(initiative.Probable_Start_Date__c != null){
            htmlbody += '<br/>Start Date: ' + (initiative.Probable_Start_Date__c).format();
        }
        if(initiative.Probable_End_Date__c != null){
            htmlbody += '<br/>End Date: ' + (initiative.Probable_End_Date__c).format();
        }
        if(initiative.UAT_Expected_Date__c != null){
            htmlbody += '<br/>UAT Expected Date:'+ (initiative.UAT_Expected_Date__c).format();
        }
        htmlbody += '<br/>Initiative URL: <a href="'+Label.ODS_SiteURL+'/apex/InitiativePage?AccServiceId='+initiative.Account_Service__c+ '&CurrenInitiativeId='+initiativeId+ '">'+initiative.Name + '</a><br/><br/></td></tr></table>';
        string emailSignature=ODS_Common_Utility.getEmailSignature(initiative.Account_Service__r.Technical_Account_manager__r.Name,signTitle,initiative.Account_Service__r.Technical_Account_manager__r.Phone,initiative.Account_Service__r.Technical_Account_Manager_Email__c);
        strHtmlBody =ODS_Common_Utility.getEmailMessage(htmlbody,emailSignature);     
        system.debug('Inside Escalate strHtmlBody : '+strHtmlBody);
        mail.setHtmlBody(strHtmlBody);
        mail.emailPriority = 'Highest';
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    
    
    /// <OBJECTIVE>
    /// Method to send email once the record is submitted.
    /// </OBJECTIVE>
    @Future(Callout = true)
    public static void sendEmailInitiative(String CurrentID,String AccountServiceID,String Status, String ClientContact,String url){
        system.debug('=====sendEmailInitiative====');
        String AccountId,ServiceId;
        String CurrentAccServiceId = AccountServiceID;
        String signTitle='CSM';
        System.debug('AccountServiceID'+CurrentAccServiceId);
        System.debug('CurrentID in emailinitiative'+CurrentID);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        String CurrenInitiativeId = CurrentID;
        List<Account_Services__c > accServiceLst = new List<Account_Services__c >();
        
        accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
        if(accServiceLst.size() > 0){
            AccountId = accServiceLst[0].Account__c;
            ServiceId = accServiceLst[0].ODS_Services__c;
            if(accServiceLst[0].Account__r.Small_Business__c){
                signTitle = 'Technical Lead';
            }
        }
        system.debug('###AccountId :' +AccountId +'###ServiceId :' +ServiceId);
        List<String> lstToAddress = new List<String>();
        List<String> lstCcAddress = new List<String>();
        
        String[] bccAddress = new List<String>();
        
        //List<Account_Services__c> objAcntSrv = [SELECT Technical_Account_manager__r.Name,Technical_Account_manager__r.Signature__c,Technical_Account_Manager_Email__c, Backup_CSM__c, Backup_CSM__r.Email from Account_Services__c  WHERE ID =: CurrentAccServiceId ];
        List<Account_Services__c> objAcntSrv = [SELECT Technical_Account_manager__r.Phone,Technical_Account_manager__r.Name,Technical_Account_manager__c,Technical_Account_Manager_Email__c,Account_Manager_Email__c , Backup_CSM__c, Backup_CSM__r.Email from Account_Services__c  WHERE ID =: CurrentAccServiceId ];
        
        //Initiatives__c initiative = [select Comments__c, Estimated_hours__c, Client_side_Contact__c, Client_side_Contact__r.Email from Initiatives__c where id =: CurrenInitiativeId];
        Initiatives__c getInitiaitive = [select id,Name,Status__c,Account_Name__c,Technology_Details__c,Persona_s_Involved__c,Outcome_of_our_solution__c,Business_Challenge__c,Account_Service__r.ODS_Account_Name__c , Account_Service__r.ODS_Service_Name__c, Comments__c, Estimated_hours__c, Client_side_Contact__c, Client_side_Contact__r.Email FROM Initiatives__c where id =: CurrenInitiativeId];
        List<Contact_Account_Service__c> Contacts = [SELECT Email__c From Contact_Account_Service__c WHERE Account__c =: AccountID AND ODS_Service__c =: ServiceID AND Is_initiate_approver__c  = true AND Contact__c != :getInitiaitive.Client_side_Contact__c];
        system.debug('###Contacts to send Email:' +Contacts);
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());  
        
        //Updated by Indhu on 30-Apr-2020 for the issue fix - Email to be sent to approver selected.
        if(objUser.PortalUserRole__c == 'Customer' || ((objUser.PortalUserRole__c == 'Technical Account Manager' || objUser.PortalUserRole__c == 'Practice Head') && (Status == 'Submitted' || Status == 'Initiative Recalled'))){
            System.debug('Loop1');
            if( getInitiaitive.Client_side_Contact__c != null )
            {
                lstToAddress.add(getInitiaitive.Client_side_Contact__r.Email);
                for(Contact_Account_Service__c Contact : Contacts ){
                    lstCcAddress.add(Contact.Email__c);
                }
            }
            else
            {
                for(Contact_Account_Service__c Contact : Contacts ){
                    lstToAddress.add(Contact.Email__c);
                }
            }
            
            for(Account_Services__c Account_contact : objAcntSrv){
                lstCcAddress.add(Account_contact.Technical_Account_Manager_Email__c);
                if(Account_contact.Backup_CSM__c != null){
                    lstCcAddress.add(Account_contact.Backup_CSM__r.Email);
                }
            } 
        }
        if(((objUser.PortalUserRole__c == 'Technical Account Manager' || objUser.PortalUserRole__c == 'Practice Head') && Status != 'Submitted')){
            System.debug('Loop2');
            for(Account_Services__c Account_contact : objAcntSrv){
                lstToAddress.add(Account_contact.Technical_Account_Manager_Email__c);
                if(Account_contact.Backup_CSM__r.Email != null){
                    lstCcAddress.add(Account_contact.Backup_CSM__r.Email);
                }
            } 
        }
        
        //bcc 
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
        
        PageReference pdf = Page.ODS_ExportInitiativeExcel;
        pdf.getParameters().put('InitiativeId',CurrenInitiativeId);  
        Blob body;
        try {        
            // returns the output of the page as a Excel
            body = pdf.getContent();
            System.debug('@@@@@@@@@body ------------'+body );
            
        } catch (VisualforceException e) {
            System.debug('====exception==='+e.getmessage());
            body = Blob.valueOf('Initiative');
        }
        
        List<Attachment> uploadedAttachment = new List<attachment>();      
        system.debug('##getInitiaitive in mail:' +getInitiaitive);
        Messaging.EmailFileAttachment attachement = new Messaging.EmailFileAttachment();
        List<Messaging.EmailFileAttachment> lstFileAttachments = new List<Messaging.EmailFileAttachment>();
        attachement.setContentType('application/vnd.ms-excel');
        attachement.setFileName(getInitiaitive.Name + '_' + getInitiaitive.Account_Service__r.ODS_Account_Name__c + '_' + getInitiaitive.Account_Service__r.ODS_Service_Name__c +'.xls');
        attachement.setInline(true);
        pdf.setRedirect(true);
        attachement.Body = body; 
        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
        
        if(lstToAddress.size() > 0){
            mail.setToAddresses(lstToAddress);
        }
        //mail.setSenderDisplayName('LevelShift - ODS');
          if(Status == 'Initiative Approved' || Status == 'Re-evaluate' ){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: system.label.ODS_Customer_FromAddress];
            if(objUser.PortalUserRole__c == 'Customer' && ( owea.size() > 0 )){ 
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }else{
                mail.setSenderDisplayName('LevelShift - ODS');
            }
        }else{
            mail.setSenderDisplayName('LevelShift - ODS');
        }
        if(lstCcAddress.size() > 0){
            mail.setCcAddresses(lstCcAddress);
        }
        if(bccAddress.size() > 0){
            mail.setBccAddresses(bccAddress);
        }
        String strHtmlBody = ''; 
        if(Status == 'Submitted'){           
            system.debug('Inside Submitted');
            String subject = getInitiaitive.Name+'– Initiative Submitted'; 
            mail.setSubject(subject);
            string htmlbody='<table width="100%" cellpadding="0" cellspacing="0"><tr><td><font face="Calibri " size="3">Hi '+ ClientContact +','+ '<br/><br/>Please find below the finalized estimates for '+ '<a href='+url+'>'+ getInitiaitive.Name+'.</a>'+ '<br/><br/>Please click '+'<a href="'+Label.ODS_SiteURL+'/apex/ODS_InitiativeApproveReject?Id='+CurrentID+ '&Type=Approve">Approve </a> or <a href="'+Label.ODS_SiteURL+'/apex/ODS_InitiativeApproveReject?Id='+CurrentID+'&Type=Reject">Re-Evaluate </a> to approve or to provide additional comments to the initiative.</br>'+body.toString()+'<br/><br/><br/></font></td></tr></table>';
            string emailSignature=ODS_Common_Utility.getEmailSignature(objAcntSrv[0].Technical_Account_manager__r.Name,signTitle,objAcntSrv[0].Technical_Account_manager__r.Phone,objAcntSrv[0].Technical_Account_Manager_Email__c);
            strHtmlBody =ODS_Common_Utility.getEmailMessage(htmlbody,emailSignature);
            system.debug('Inside Submitted strHtmlBody : '+strHtmlBody); 
        }
        
        
        if(Status == 'Initiative Recalled'){           
            system.debug('Inside recalled');
            String subject = 'Recall: ' + getInitiaitive.Name; 
            mail.setSubject(subject);
            string htmlbody='<table width="100%" cellpadding="0" cellspacing="0"><tr><td><font face="Calibri " size="3">Hi '+ ClientContact +','+ '<br/><br/>I would like to make additional changes to the initiative <b>"'+ getInitiaitive.Name+ '"</b> and will resubmit it again.</br><br/></font></td></tr></table>';
            string emailSignature=ODS_Common_Utility.getEmailSignature(objAcntSrv[0].Technical_Account_manager__r.Name,signTitle,objAcntSrv[0].Technical_Account_manager__r.Phone,objAcntSrv[0].Technical_Account_Manager_Email__c);
            strHtmlBody =ODS_Common_Utility.getEmailMessage(htmlbody,emailSignature);
            system.debug('Inside recalled strHtmlBody : '+strHtmlBody);
        }
        
        System.debug('@@@@@Status'+Status);
        if(Status == 'Initiative Approved' || Status == 'Approved after Re-evaluation'){
            system.debug('Inside Approved');
            String subject = getInitiaitive.Name +'– Initiative Approved';
            system.debug('Inside subject'+subject);
            mail.setSubject(subject);
            strHtmlBody += '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"><font face="Calibri " size="3"> Hi '+ objAcntSrv[0].Technical_Account_manager__r.Name +','
                + '<br/><br/>';
            strHtmlBody += 'We have approved the estimated efforts for '+ '<a href='+url+'>'+ getInitiaitive.Name  +'.</a>'
                + '<br/><br/>';
            strHtmlBody += 'Account Name: ' + getInitiaitive.Account_Service__r.ODS_Account_Name__c + '<br/><br/>';
            
            //Initiatives__c init = [select Comments__c from Initiatives__c where id =: CurrenInitiativeId];
            if(getInitiaitive.Comments__c  != null){
                strHtmlBody +=  'Comments : '+getInitiaitive.Comments__c+'<br/><br/>';
            }
            
            strHtmlBody += 'Thanks,'
                + '<br/><br/>';
            strHtmlBody += ClientContact+ '<br/><br/> </font></td></tr>'; 
            
            system.debug('Inside Approved strHtmlBody:'+ strHtmlBody );
        }
        
        if(Status == 'Re-evaluate'){
            system.debug('Inside Reevaluate');
            String subject = getInitiaitive.Name +'– Initiative Rejected ';
            mail.setSubject(subject);
            strHtmlBody += '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"><font face="Calibri " size="3"> <hr width="100%" color="#68c9ff" size="20" align="left"> Hi '+ objAcntSrv[0].Technical_Account_manager__r.Name +','
                + '<br/><br/>';
            strHtmlBody += 'Please re-evaluate the efforts required for the Initiative '+ '<a href='+url+'>'+getInitiaitive.Name+'.</a>'
                + '<br/><br/>';
            strHtmlBody += 'Account Name: ' + getInitiaitive.Account_Service__r.ODS_Account_Name__c + '<br/><br/>';
            
            //Initiatives__c init = [select Comments__c from Initiatives__c where id =: CurrenInitiativeId];
            if(getInitiaitive.Comments__c  != null){
                strHtmlBody += 'Comments : '+getInitiaitive.Comments__c+'<br/><br/>';
            }
            
            strHtmlBody += 'Thanks,'
                + '<br/><br/>';
            strHtmlBody += ClientContact+ '<br/><br/> </font></td></tr>'; 
            
            system.debug('Inside Reevaluate strHtmlBody:'+ strHtmlBody );
        }
        
        system.debug('##strHtmlBody:' +strHtmlBody);
        mail.setHtmlBody(strHtmlBody);
        if(Status != 'Submitted'){
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachement});
        }
        else
        {
            try{
                uploadedAttachment = [select Id, Name, Body, ParentId from Attachment where ParentId =: CurrenInitiativeId ORDER BY CreatedDate DESC Limit 3];
            }
            catch(exception e)
            {
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                system.debug('An error occurred '+e.getMessage());ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
                
            }
            if((uploadedAttachment.size() != 0)&&(!uploadedAttachment.isEmpty()) &&(uploadedAttachment != Null))
            {
                for(Attachment at: uploadedAttachment)
                {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(at.Name);
                    efa.setBody(at.Body);
                    lstFileAttachments.add(efa);
                }
                mail.setFileAttachments(lstFileAttachments);
            }
        }
        
        mails.add(mail);
        
        //DL-157 start
        if((getInitiaitive.Estimated_hours__c >= decimal.valueOf(System.Label.Estimated_Hr_Threshold)) && (Status == 'Initiative Approved') ){
            Messaging.singleEmailMessage mailEstimate = new Messaging.singleEmailMessage();
            String strHtmlBodyEstimate = '';  //mail Body Estimate
            List<String> lstToAddressEstimate = new List<String>();
            List<String> lstCcAddressEstimate = new List<String>();
            
            // CSMs manager
            string profileName = Label.ODS_ReportingManagerRoles;
            List<String> ReportingManagerNameList = profileName.split(',');
            list<string> reportingManagerRoleAfterTrim = new List<string>();
            for(string role : ReportingManagerNameList){
                reportingManagerRoleAfterTrim.add(role.trim());
            }
            
            Map<id,User> reportingManagerDetails = new Map<id,user>([SELECT Id,Name,ManagerId,UserRole.Name,Email FROM User where UserRole.Name IN :reportingManagerRoleAfterTrim]);
            
            //adding in CC CSM and Their managers 
            for(Account_Services__c Account_contact : objAcntSrv){
                //Adding CSMs
                lstCcAddressEstimate.add(Account_contact.Technical_Account_Manager_Email__c);
                if(Account_contact.Backup_CSM__c != null){
                    lstCcAddressEstimate.add(Account_contact.Backup_CSM__r.Email);
                }
                
                //Adding CSMs Managers
                User CSMUser=getReportingManagerDetails(Account_contact.Technical_Account_manager__c);
                User managersOfCSM=reportingManagerDetails.get(CSMUser.ManagerId);
                If(managersOfCSM !=null){
                    lstCcAddressEstimate.add(managersOfCSM.Email);
                    
                }
                
                lstCcAddressEstimate.add(Label.ODS_PracticeHeadEmail);
                
                if(String.isNotBlank(Label.ODS_Management_Team_Email)){
                    lstCcAddressEstimate.add(Label.ODS_Management_Team_Email);                    
                }                
                system.debug('lstCcAddressEstimate2: '+lstCcAddressEstimate);
            } 
            //Add To list - all the Sales Team Members (Everyone with a PreludeSys Sales Team Profile)
            String SalesTeamProfile = Label.Sales_Team_Profile;
            List<User> userList = [SELECT Id,Profile.name,name,email FROM User WHERE Profile.name =: SalesTeamProfile AND IsActive = true];
            system.debug('SalesTeam : ' + SalesTeamProfile);
            
            for(User u : userList){
                lstToAddressEstimate.add(u.email);
            }
            system.debug('lstToAddress in ApprovedEstimate : '+lstToAddressEstimate);
            system.debug('lstToAddressEstimate-'+lstToAddressEstimate);
            //Update mail message address
            if(lstToAddressEstimate.size() > 0){
                mailEstimate.setToAddresses(lstToAddressEstimate);
            }
            if(lstCcAddressEstimate.size() > 0){
                mailEstimate.setCcAddresses(lstCcAddressEstimate);
            }
            
            List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address =: objAcntSrv[0].Technical_Account_Manager_Email__c];
            if (owea.size() > 0) {
                mailEstimate.setOrgWideEmailAddressId(owea[0].Id);
            }
            else{
                mailEstimate.setSenderDisplayName('LevelShift Admin on behalf of '+ objAcntSrv[0].Technical_Account_manager__r.Name);
            }
            
            //Mail Body           
            String subjectEstimate = getInitiaitive.Account_Name__c + ' - ' + getInitiaitive.Name + ' - Initiative Approved';
            mailEstimate.setSubject(subjectEstimate);
            string htmlbody='<table width="100%" cellpadding="0" cellspacing="0"><tr><td><font face="Calibri " size="3">Dear Sales Team,' + '<br/><br/>The initiative ' + getInitiaitive.Name + ' for the customer ' + getInitiaitive.Account_Service__r.ODS_Account_Name__c + ' has been approved for an effort ' + getInitiaitive.Estimated_hours__c+'. The following are the details about the initiative:<br/><br/> Business Challenge: '+getInitiaitive.Business_Challenge__c+'<br/><br/>Persona’s Involved: '+getInitiaitive.Persona_s_Involved__c+'<br/><br/>Technology Details: '+ getInitiaitive.Technology_Details__c + '<br/><br/>Outcome of the solution: '+getInitiaitive.Outcome_of_our_solution__c+'</br><br/></font></td></tr></table>';
            string emailSignature=ODS_Common_Utility.getEmailSignature(objAcntSrv[0].Technical_Account_manager__r.Name,signTitle,objAcntSrv[0].Technical_Account_manager__r.Phone,objAcntSrv[0].Technical_Account_Manager_Email__c);
            strHtmlBodyEstimate =ODS_Common_Utility.getEmailMessage(htmlbody,emailSignature);
            //system.debug('##strHtmlBody:' +strHtmlBodyEstimate);
            mailEstimate.setHtmlBody(strHtmlBodyEstimate);
            mails.add(mailEstimate);
        }        
        
        system.debug('mails : '+mails);
        Messaging.sendEmail(mails);        
    }
    
    @Future(Callout = true)
    public static void sendEmailInitiativeDelivered(String CurrentID,String AccountServiceID){
        try{
            system.debug('=====sendEmailInitiative====');
            String AccountId,ServiceId;
            String CurrentAccServiceId = AccountServiceID;
            System.debug('AccountServiceID'+CurrentAccServiceId);
            System.debug('CurrentID in emailinitiative'+CurrentID);
            String PracticeHeadEmail = Label.ODS_PracticeHeadEmail;
            String CurrenInitiativeId = CurrentID;
            List<Account_Services__c > accServiceLst = new List<Account_Services__c >();
            
            accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
            String signTitle='CSM';
            if(accServiceLst.size() > 0){
                AccountId = accServiceLst[0].Account__c;
                ServiceId = accServiceLst[0].ODS_Services__c;
                if(accServiceLst[0].Account__r.Small_Business__c){
                    signTitle='Technical Lead';
                }
            }
            system.debug('###AccountId :' +AccountId +'###ServiceId :' +ServiceId);
            List<String> lstToAddress = new List<String>();
            List<String> lstCcAddress = new List<String>();
            String[] bccAddress = new List<String>();
            
            List<Account_Services__c> objAcntSrv = [SELECT Technical_Account_manager__r.Phone,Technical_Account_manager__r.Name,Technical_Account_Manager_Email__c,Technical_Account_manager__r.UserRole.name,Technical_Account_manager__r.Email, Backup_CSM__c, Backup_CSM__r.Email,Account__r.Name,Account__r.Salesforce_AE_Name__r.Name,Account__r.Industry,Account__r.Owner.Name,Account__r.Owner.Email,Account__r.User__r.Email from Account_Services__c  WHERE ID =: CurrentAccServiceId ];
            system.debug('###objAcntSrv:' +objAcntSrv);
            
            Initiatives__c initiative = [select Comments__c,Name, Client_side_Contact__c, Client_side_Contact__r.Email from Initiatives__c where id =: CurrenInitiativeId];
            system.debug('###initiative to send Email:' +initiative);
            
            user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId()); 
            
            
            ODS_Industry_Mapping__mdt[] CSSIndustryEmails = [Select MasterLabel, IndustryName__c, CSS_Industry_Email__c,Industry_Practice_Role_Id__c from ODS_Industry_Mapping__mdt];
            String split_emailswithcomma;
            string profileName=Label.ODS_ReportingManagerRoles;
            List<String> ReportingManagerNameList = profileName.split(',');
            list<string> reportingManagerRoleAfterTrim=new List<string>();
            for(string role:ReportingManagerNameList){
                reportingManagerRoleAfterTrim.add(role.trim());
            }
            
            Map<id,User> reportingManagerDetails=new Map<id,user>([SELECT Id,Name,ManagerId,UserRole.Name,Email FROM User where UserRole.Name IN :reportingManagerRoleAfterTrim]);
            
            if(((objUser.PortalUserRole__c == 'Technical Account Manager' || objUser.PortalUserRole__c == 'Practice Head'))){
                for(Account_Services__c Account_contact : objAcntSrv){
                    lstToAddress.add(Account_contact.Account__r.Owner.Email);
                    bccAddress.add(PracticeHeadEmail);
                    if(Account_contact.Technical_Account_manager__r.Email != null){
                        lstCcAddress.add(Account_contact.Technical_Account_manager__r.Email);
                    }
                    system.debug('objUser.UserRole.name'+objUser.UserRole.name);
                    
                    User CSMUser=getReportingManagerDetails(Account_contact.Technical_Account_manager__c);
                    User managersOfCSM=reportingManagerDetails.get(CSMUser.ManagerId);
                    If(managersOfCSM !=null){
                        lstCcAddress.add(managersOfCSM.Email);
                        
                    }
                    system.debug('lstCcAddress++++'+lstCcAddress);
                    for(ODS_Industry_Mapping__mdt record:CSSIndustryEmails) {
                        if(Account_contact.Account__r.Industry != null && Account_contact.Account__r.Industry == record.IndustryName__c){
                            if(String.IsNotBlank(record.CSS_Industry_Email__c)){                                
                                List<String> Industryemails = record.CSS_Industry_Email__c.split(',');
                                if(Industryemails.size() > 0){
                                    lstCcAddress.addAll(Industryemails);
                                }                                
                                else{     
                                    lstCcAddress.add(record.CSS_Industry_Email__c);
                                }                                
                            }
                        }
                    }
                } 
            }
            
            Initiatives__c getInitiaitive = [select id,Name,Status__c,Account_Service__r.ODS_Account_Name__c , Account_Service__r.ODS_Service_Name__c FROM Initiatives__c where id =: CurrenInitiativeId];
            
            system.debug('getInitiaitive'+getInitiaitive);
            
            Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
            if(lstToAddress.size() > 0){
                mail.setToAddresses(lstToAddress);
            }
            mail.setSenderDisplayName('LevelShift - ODS');
            if(lstCcAddress.size() > 0){
                mail.setCcAddresses(lstCcAddress);
            }
            if(bccAddress.size() > 0){
                mail.setBccAddresses(bccAddress);
            }
            
            String strHtmlBody = '';                     
            
            String subject = getInitiaitive.Name+'– Initiative Delivered'; 
            mail.setSubject(subject);
            string salesforceAE ='';
            if( objAcntSrv[0].Account__r.Salesforce_AE_Name__r.Name != null){
                salesforceAE= objAcntSrv[0].Account__r.Salesforce_AE_Name__r.Name;
            }
            string htmlbody='<table width="100%" cellpadding="0" cellspacing="0"><tr><td><font face="Calibri " size="3">Dear '+ objAcntSrv[0].Account__r.Owner.Name +','+ '<br/><br/>The first initiative <b>'+ getInitiaitive.Name+ '</b> has been delivered for <b>'+ objAcntSrv[0].Account__r.Name+'</b>. Please reach out to the Salesforce AE <b>'+salesforceAE+'</b> to discuss the account and next steps. Please let me know if you need any additional information.</br><br/></font></td></tr></table>';
            string emailSignature=ODS_Common_Utility.getEmailSignature(objAcntSrv[0].Technical_Account_manager__r.Name,signTitle,objAcntSrv[0].Technical_Account_manager__r.Phone,objAcntSrv[0].Technical_Account_Manager_Email__c);
            strHtmlBody =ODS_Common_Utility.getEmailMessage(htmlbody,emailSignature);
            system.debug('Inside recalled strHtmlBody : '+strHtmlBody);
            mail.setHtmlBody(strHtmlBody);
            
            system.debug('lstCcAddress'+lstCcAddress);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }
    
    
    /// <OBJECTIVE>
    /// Method to redirect to Initiative page
    /// </OBJECTIVE> 
    
    public pagereference redirectToInitiative()
    {
        //String url = '/apex/ViewInitiative';
        //String InitiativeUrl = System.Label.ODS_SiteURL; 
        try{   
            Pagereference pgRef = new PageReference('/apex/ViewInitiative');
            pgRef.setRedirect(true);
            return pgRef ;
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
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
        }
        catch(Exception e)  {
            system.debug('AddTimesheet-getResourceNameByAccountServiceId: '+e);
        }
    } 
    
    public void getInitiativeByAccountServiceId(String AccountId, String ServiceId) 
    {  
        try {
            InitiativeLst = new  List<AggregateResult>();
            InitiativeLst = ODS_Data_Utility.getInitiativeByAccountServiceId(AccountId, ServiceId);
            initiativeJSONtoBind = JSON.serialize(InitiativeLst);
        }
        catch(Exception e)  {
            system.debug('AddInitiative-getInitiativeByAccountServiceId: '+e);
        }
    }
    
    Public pagereference exportAsExcel()
    {
        try{
            PageReference pdf = Page.ODS_ExportInitiativeExcel;
            System.debug('CurrenInitiativeID:'+CurrenInitiativeId);
            pdf.getParameters().put('InitiativeId',CurrenInitiativeId);
            System.debug('@@@@@@@@@656CurrenInitiativeId------------'+CurrenInitiativeId);
            pdf.setRedirect(true);
            return pdf;
        }
        catch(Exception e)  {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            return null;
        }
    }
    
    @RemoteAction
    global static  decimal initiativeStatus(string curntId){
        decimal utilizedHrs;
        
        for(Initiatives__c i : [select Id, name, CreatedDate,Consumed_Hours__c,Utilization__c FROM Initiatives__c where id =: curntId]){
            utilizedHrs = i.Utilization__c;
        }
        system.debug('utilizedHrs========'+utilizedHrs);
        return utilizedHrs;
    }
    
    //Added by Indhu on 13-Dec-2018 for CP-46
    @RemoteAction
    global static string GetUtilizedHours(string curntId){
        decimal estimatedHrs = 0.0;
        decimal utilizedHrs = 0.0; /*submitted utilization not just approved utilization*/
        decimal consumedHrs = 0.0; /*submitted hours not just approved hours */
        decimal unUtilizedPercentage = 0.0;
        decimal remainingHrs = 0.0;
        
        for(Initiatives__c i : [select Id, name, CreatedDate,Submitted_Hours__c,Estimated_hours__c,Remaining_Hours__c,Submitted_Utilization__c FROM Initiatives__c where id =: curntId]){
            utilizedHrs = i.Submitted_Utilization__c; /*Utilization__c*/
            estimatedHrs = i.Estimated_hours__c;
            if(i.Submitted_Hours__c != null){ /*Consumed_Hours__c*/
                consumedHrs = i.Submitted_Hours__c.setscale(1); /*Consumed_Hours__c*/
            }
            if(i.Remaining_Hours__c != null && estimatedHrs > 0)
            {
                remainingHrs=i.Remaining_Hours__c;
                remainingHrs=remainingHrs.setscale(1);
                unUtilizedPercentage = (remainingHrs * 100).divide(estimatedHrs, 1, System.RoundingMode.CEILING);
            }
        }
        system.debug('utilizedHrs========'+utilizedHrs);
        return (utilizedHrs + '|' + consumedHrs + '|' + unUtilizedPercentage + '|' + remainingHrs);
    }
    
    //Added by Indhu on 14-Feb-2019 for Cancel Initiative User Story
    public PageReference CancelInitiative()
    {
        try{
            Initiatives__c initiative = new Initiatives__c(id=CurrenInitiativeId);
            initiative.Status__c  = 'Initiative Cancelled'; 
            initiative.Initiative_Cancelled_Date__c = Date.Today();           
            Update initiative;
            
            PageReference pgRef = new PageReference('/apex/ViewInitiative');
            pgRef.setRedirect(True);
            return pgRef; 
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            return null;
        }
        
    }
    
    public PageReference ReDirectToViewIntitiativepage() {
        try{
            ODS_Common_Utility.upsertSessionData(AccountId,ServiceID);
            PageReference pr = new PageReference('/apex/ViewInitiative?accntId='+AccountId+'&srvcId='+ServiceID);
            ReDirectToViewIntitiativepageError = false;
            return pr;
        }
        catch(exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ReDirectToViewIntitiativepageError = true;
            return null;
        }
    }
    
    public String saveBriefDescription(String objBrief){
        system.debug('objBrief: '+objBrief);
        String replacement = '';
        //ble border=&quot;0&quot; cellpadding=&quot;0&quot; cellspacing=&quot;0&quot; style=&quot;width:656px&quot;&gt; 
        //ble border="0" cellpadding="0" cellspacing="0" style="width:656px">; 
        String stringRegex1 = '^ble(\\s(\\w)+=(&quot;|\\w|\"|\\d|\\.)*)*(\\s(\\w)+=((&quot;|\")|(\\w)+:(\\d|\\.)*(pt|px|%))+)?(&gt;|>)(\\s)*';
        Pattern stringPattern1 = Pattern.compile(stringRegex1);
        
        Matcher matcher1 = stringPattern1.matcher(objBrief);
        String output = matcher1.replaceAll(replacement);
        
        system.debug('match1: '+matcher1.find());
        
        return output;
    }
    
    public PageReference CloneInitiative(){
        try{
            Initiatives__c initiative = [Select Name,id,Account_Name__c,AccountServiceId_formula__c,Account_Service__c,Business_Challenge__c,Outcome_of_our_solution__c,Persona_s_Involved__c,Technology_Details__c,Consumed_Hours__c,Assumption__c,Brief_Description__c,Client_side_Contact__c,Comments__c,Estimated_hours__c,Initiative_Programming_Reason__c,Product__c,Initiative_Submitted_Days__c,Is_a_bucket_of_hours_type__c,Initiative_Type__c,JIRA_ID__c,Offshore_Estimate__c,Probability_Percentage__c,Probable_Start_Date__c,Probable_End_Date__c,Remaining_Hours__c,Revised_Approved__c,Solution_Architect_Engineer__c,Technical_Project_Manager__c,Initiative_Billing_Type__c,Submitted_Utilization__c,Tags_About_Initiative__c,Trigger_For_Initiative__c FROM Initiatives__c WHERE id =: CurrenInitiativeId limit 1];
            
            List<Estimate__c> listEstimate = [Select Assumptions__c,Hours__c,Initiative_Lookup__c,Phase__c,Task_Components__c FROM Estimate__c WHERE Initiative_Lookup__c =: CurrenInitiativeId];
            
            initiative.Name='Copy of '+initiative.Name;
            initiative.Status__c='Saved';
            initiative.id=NULL;
            initiative.isFollowedInitEstimate__c=False;
            initiative.Submitted_Hours__c = 0.0;
            initiative.Consumed_Hours__c = 0;
            insert initiative;
            id initiativeId = initiative.id;
            List<Estimate__c> copyEstimate = new List<Estimate__c>();
            if(listEstimate!=NULL){
                for(Estimate__c e:listEstimate)
                {
                    Estimate__c estimateobject = new Estimate__c();
                    estimateobject.Phase__c =  e.Phase__c;
                    estimateobject.Hours__c = e.Hours__c;
                    estimateobject.Task_Components__c = e.Task_Components__c;
                    estimateobject.Assumptions__c = e.Assumptions__c;
                    estimateobject.Initiative_Lookup__c = initiativeId;
                    copyEstimate.add(estimateobject);
                }
                insert copyEstimate;
            }
            CloneInitiativeError = false;
            
            Initiatives__c initiativeRecById = ODS_Data_Utility.FetchInitiativeByID(initiativeId);
            Id AccountServiceID = initiativeRecById.Account_Service__c;
            String initiativeStats = initiativeRecById.Status__c;
            PageReference pr = new PageReference('/apex/InitiativePage?CurrenInitiativeId=' +initiativeRecById.id + '&AccServiceId='+AccountServiceID+ '&Status='+initiativeStats);
            pr.setRedirect(True);
            return pr; 
        }
        
        catch(Exception e){
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            CloneInitiativeError = true;
            return null;
        }
        
    } 
    // Added by -Harish ---07-05-21 ---Class creation for product list
    
    
    public class Productname{
        public String Pname {get; set;}
        public boolean ischecked {get; set;}  
        
    }
    //Added by Harish - 06-05-21 - popup date
    public boolean displayPopup {get; set;}     
    
    public void closePopup() {
        
        productnames= '';
        boolean nameexist = false;
        //First Coloumn---Harish 10-05-21
        for(String s:productmap.keyset() ){
            for(productname p:productmap.get(s) ){
                if(p.ischecked){
                    if(!nameexist){
                        productnames=p.pname;
                        nameexist=true;
                    }
                    else{
                        Productnames+= ', '+p.Pname;
                    }}}}
        
        //Thrid Coloumn---Harish 10-05-21
        displayPopup = false;    
    }
    public void closePopup1() {
        
        displayPopup = false;    
    }     
    public void showPopup() {        
        collapsedItems = true;
        getProductList();
        displayPopup = true; 
        
    }
    public boolean collapsedItems {get;set;}
    
    //added by Harish popup method declearation 
    public String Productnames {get;set;}
    public String Productnames1 {get;set;}
    //Added by harish Mapping product list
    Public Map<String,List<Productname>> productMap { get; set;}
    Public Map<String,List<Productname>> productMap1 { get; set;}
    Public Map<String,List<Productname>> productMap2 { get; set;}
    Public Map<String,List<Productname>> productMap3 { get; set;}
    
    public void getProductList(){
        if(productMap!=Null) return;
        productMap =new  Map<String,List<Productname>>();
        productMap1 =new  Map<String,List<Productname>>();
        productMap2 =new  Map<String,List<Productname>>();
        productMap3 =new  Map<String,List<Productname>>();
        
        boolean alternate = false;
        String groupName = '';
        
        List<Salesforce_Product_Group__mdt> spg = [SELECT Id,label FROM Salesforce_Product_Group__mdt order by Label ASC];
        
        
        For(Technology_Group_Term__mdt pg:[SELECT Id,label,Salesforce_Product_Group__c,Salesforce_Product_Group__r.Label
                                           FROM Technology_Group_Term__mdt 
                                           where Salesforce_Product_Group__c IN: spg]){
                                               
                                               String pgl = pg.Salesforce_Product_Group__r.Label;
                                               
                                               // check if map has product group label (pgl)
                                               
                                               
                                               If (productMap.get(pgl) != null) {
                                                   List<Productname> plist = productMap.get(pgl);
                                                   Productname p =new Productname();                       
                                                   p.Pname=pg.label;
                                                   plist.add(p);
                                                   productMap.put(pgl, plist);
                                               }     
                                               else {
                                                   List<Productname> plist = new List<Productname>();
                                                   Productname p =new Productname();                       
                                                   p.Pname=pg.label;
                                                   plist.add(p);
                                                   productMap.put(pgl, plist);
                                                   
                                               }
                                               
                                           }
        Integer groupsize = spg.size();
        Integer subgroupsize =groupsize/3;
        
        for(String key : productMap.keySet() ){
            
            if(productMap1.size()<= subgroupsize) {
                system.debug('1>>>'+ key);
                productMap1.put(key, productMap.get(key));
                continue;
            }
            
            if(productMap2.size()<= subgroupsize) {
                system.debug('2>>>'+ key);
                productMap2.put(key, productMap.get(key));
                continue;
            } 
            if(productMap3.size()<= subgroupsize) {
                system.debug('3>>>'+ key);
                productMap3.put(key, productMap.get(key));
                continue;
            } 
            
        } 
        //First Coloumn---Harish 10-05-21
        If(productnames!=null && productnames!=''){
            for(String s:productmap.keyset() ){
                for(productname p:productmap.get(s) ){
                    if(productnames.contains(p.pname)){
                        p.ischecked =true;    
                    }
                }}}
        
    }
    public list<string> chartLabelDate {get; set;}
    public list<string> xAxes {get; set;}
    public list<string> yAxes {get; set;}
    public string maxEstimateHour {get; set;}
    public void generateBurnDownChart(string CurrenInitiativeId){
        chartLabelDate=new list<string>();
        xAxes=new list<string>();
        yAxes=new list<string>();
        //list<Time_Sheet_Details__c> getTimeSheetList=[SELECT Hours_Worked__c,Id,Task_Name__c,Timesheet_Date__c,Timesheet__r.Week_Start_Date__c,Timesheet__r.Week_End_Date__c FROM Time_Sheet_Details__c WHERE Intiative__c =:CurrenInitiativeId  ORDER BY Timesheet_Date__c ASC NULLS FIRST];
        list<AggregateResult > getTimeSheet=[SELECT sum(Hours_Worked__c),Timesheet_Date__c FROM Time_Sheet_Details__c WHERE Intiative__c =:CurrenInitiativeId AND (Timesheet__r.Status__c='Approved' OR Timesheet__r.Status__c='Submitted') group by Timesheet_Date__c ORDER BY Timesheet_Date__c ASC NULLS FIRST];
        Initiatives__c getInitiative=[SELECT id,Estimated_hours__c FROM Initiatives__c where id=:CurrenInitiativeId];
        decimal totalHour=0;
        decimal estimateHour=getInitiative.Estimated_hours__c;
        maxEstimateHour=string.valueOf(estimateHour.setScale(0));
        if(!getTimeSheet.isEmpty()){
            date priorDate=(date)getTimeSheet[0].get('Timesheet_Date__c');
            string timesheetDatePrior=string.valueOf(priorDate.addDays(-1));
            chartLabelDate.add(string.valueOf(timesheetDatePrior.split(' ')[0]));
            xAxes.add(string.valueOf(0));
            yAxes.add(string.valueOf(getInitiative.Estimated_hours__c));   
        }
        
        for(AggregateResult ts:getTimeSheet){
            if((decimal)ts.get('expr0') !=0.0){
                string timesheetDate=string.valueOf(ts.get('Timesheet_Date__c'));
                //x-axis label name
                chartLabelDate.add(timesheetDate.split(' ')[0]);
                
                //x-axis bar chart value
                xAxes.add(string.valueOf((decimal)ts.get('expr0')));
                
                //y-axis line chart value
                totalHour +=(decimal)ts.get('expr0');
                yAxes.add(string.valueOf(getInitiative.Estimated_hours__c-totalHour));
            }
        }
        if(chartLabelDate.size()<20){
            chartDivWidth='width:100%';
        }else{
            chartDivWidth='width:'+string.valueOf(chartLabelDate.size()*50)+'px'; 
        }
    }
    private Static User getReportingManagerDetails(string userId){
        
        return [SELECT Id,ManagerId,UserRole.Name FROM User where Id=:userId Limit 1];
    }
    //DCO-110      
    public  void checkJiraId(String AccountServiceID){
        
        String AccountId,ServiceId;
        String CurrentAccServiceId = AccountServiceID;
        System.debug('AccountServiceID'+CurrentAccServiceId);
        // System.debug('CurrentID in emailinitiative'+CurrentID);
        
        //  String CurrenInitiativeId = CurrentID;
        List<Account_Services__c > accServiceLst = new List<Account_Services__c >();
        
        accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
        if(accServiceLst.size() > 0){
            AccountId = accServiceLst[0].Account__c;
            ServiceId = accServiceLst[0].ODS_Services__c;
        }
        targetValues = new Set<String>();
        List<Initiatives__c> myInitiativesList = [SELECT Account_Name__c,Account_Service__c,Id,JIRA_ID__c,Name FROM Initiatives__c WHERE JIRA_ID__c != null AND Account_Service__c =: CurrentAccServiceId AND Id !=: CurrenInitiativeId];
        
        String jiraIdText = '';
        String initiativeJiraId = '';
        Set<String> jiraIdPrefixes = new Set<String>();
        Set<String> tempTargetValues = new Set<String>();
        
        for(Initiatives__c myRec :myInitiativesList){
            jiraIdText = '';
            initiativeJiraId = myRec.Jira_Id__c.toLowerCase();
            //remove agile related keywords
            initiativeJiraId = initiativeJiraId.replaceAll('(sprint|task|epic|bug|user(\\s)*story)(\\W)*(\\d|,|\\W)+','').trim();
            jiraIdPrefixes.removeAll(new Set<String>(jiraIdPrefixes));
            tempTargetValues.removeAll(new Set<String>(tempTargetValues));
            //extract numbers only
            Pattern idP = Pattern.compile('(\\d{1,})');
            Matcher idPM = idP.matcher(initiativeJiraId);
            while (idPM.find()) {
                tempTargetValues.add(idPM.group(1));
            }
            //extract alphabets only
            idP = Pattern.compile('([a-zA-z]+)');
            idPM = idP.matcher(initiativeJiraId);
            while (idPM.find()) {
                jiraIdPrefixes.add(idPM.group(1));
                jiraIdText += idPM.group(1);
            }
            //no jira id numbers, only alphabets are available
            if(tempTargetValues.size() == 0){
                targetValues.add(jiraIdText);
            }
            
            //range of numbers 10-25, 23-29...
            idP = Pattern.compile('(\\d+[\\s]*\\-[\\s]*\\d+)');
            idPM = idP.matcher(initiativeJiraId);
            Integer rangeStart = 0;
            Integer rangeEnd = 0;
            String rangeText = '';
            List<String> rangeInfo = new List<String>();
            while (idPM.find()) {
                rangeText = idPM.group(1);
                rangeInfo = rangeText.replace(' ', '').split('-');
                rangeStart = Integer.valueOf(rangeInfo[0]);
                rangeEnd = Integer.valueOf(rangeInfo[1]);
                for(Integer idx=rangeStart;idx<=rangeEnd;idx++){
                    tempTargetValues.add(String.valueOf(idx));
                }
            }
            for(String tvl: tempTargetValues){
                String singleId = tvl;
                String singleJiraId = '';
                
                //add one value without prefix to validate 
                //if the user enters only number without prefix in the jira id field
                targetValues.add(singleId);
                
                for(String pfx: jiraIdPrefixes){
                    if(String.isNotBlank(pfx)){
                        singleJiraId = (pfx + '-' +  singleId);
                    }
                    targetValues.add(singleJiraId);
                }
            }
        }
        
    }
}