/**
* @author           Indumathi.V
* @version          1.0 
* @date             07-OCT-2016
* @Status           Developed
* @description      This is the controller class for Add Status report Page
*
*/

global virtual class ODS_AddStatusReportController
{
    
    public Boolean isCustomer { get; set; }
    
    public String CkEditorParam{get;set;}    
    public string AccountName {get;set;}
    public string StatusReportFrequency {get;set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string ServiceName{get;set;}
    public string AccountServiceID {get;set;} 
    public string currentUserName {get;set;}    
    public static Status_Report__c objStsRprt {get;set;}
    public string WorkDayParam{get;set;}
    public string WorkNextDayParam{get;set;}
    public string IssuesConcernsParam{get;set;}
    public string selectedAccountId{get;set;}
    public string selectedServiceId{get;set;}
    //public Date srDate{get;set;}
    public String srId {get;set;}
    public Account_Services__c objAccntSrvcs{get;set;}
    public Status_Report__c srToInsert{get;set;}
    public Status_Report__c srToUpdate{get;set;}
    public Date SRDate{get;set;}
    public string CurrentDate{get;set;}
    public String statusDate{get;set;}
    public Boolean isMyAccShow{get;set;}
    public User objUser{get;set;}
    public string Errormsg{get;set;}
    public boolean blShowCopyButton{get;set;}
    public boolean blPgErrorMsg{get;set;}
    public boolean blShowSaveBtn{get;set;}
    public boolean blShowSubmitBtn{get;set;}
    public String SRStatus{get;set;} 
    public String minDate{get;set;}
    //public Date SSDate{get;set;}
    public string WorkDayParam1{get;set;}
    public string WorkNextDayParam1{get;set;}
    public string IssuesConcernsParam1{get;set;}
    public Date srWeekStartDate{get;set;}
    public Date srWeekEndDate{get;set;}
    public string getMobileredirectUrl = label.ODS_MobileRedirectURL;
    @TestVisible protected boolean isMobile {get; set; }
    public static boolean deliveryTeam {get;set;}
    
    /// <OBJECTIVE>
    /// Constructor.
    /// </OBJECTIVE>
    public ODS_AddStatusReportController() 
    {
        
        SRDate = System.Today();
        deliveryTeam=false;
        Datetime currentDateTime = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        CurrentDate  = currentDateTime.format('MM/dd/yyyy'); // Updated the date from 'MM/dd/YYYY' to 'MM/dd/yyyy'
        DateTime minDateTime =currentDateTime.addDays(-7);
        minDate = minDateTime.format('MM/dd/yyyy') ; // Updated the date from 'MM/dd/YYYY' to 'MM/dd/yyyy'
        
        Date stDate = date.parse(CurrentDate);
        statusDate = SRDate.format();
        objUser = new User();
        objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId()); 
        if(objUser.Profile.Name==System.Label.DeliveryRoleProfile){
            deliveryTeam=true; 
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        objStsRprt = new Status_Report__c();
        currentUserName = UserInfo.getName();
        system.debug('***Constructor called');
        AccountId = ApexPages.currentPage().getParameters().get('accntId');
        ServiceId = ApexPages.currentPage().getParameters().get('srvcId');
        srId = ApexPages.currentPage().getParameters().get('srId');
        if(srId != null)
        {
            try
            {
                objStsRprt = ODS_Data_Utility.fetchStatusReportbyID(srId);
                system.debug('**1'+objStsRprt );
            }
            catch(Exception ex)
            {
                System.debug('ex in getting status report-------'+ex);
            }
            
            
        }
        
        if(objStsRprt.Id !=  null)
        {
            SRStatus = objStsRprt.Status__c;
            if(objStsRprt.Status__c == 'Submitted')
            {
                system.debug('***2'+objStsRprt.Status__c);
                blShowCopyButton = false;
                blShowSaveBtn = false;
                blShowSubmitBtn = false;
            }
            else
            {
                blShowCopyButton = true;
                blShowSaveBtn = true;
                blShowSubmitBtn = true;
            }
            WorkDayParam = objStsRprt.Work_for_the_Day__c;
            WorkNextDayParam = objStsRprt.Work_for_the_Next_Day__c;
            StatusReportFrequency = objStsRprt.Account_Services__r.Status_Report_Frequency__c;
            IssuesConcernsParam = objStsRprt.Issues_And_Concerns__c;
            //statusDate = objStsRprt.Status_Date__c.format();
            SRDate = objStsRprt.Status_Date__c;
            //srDate = FormatStringToDate(sDate);
        }
        else
        {
            //statusDate = System.today().format();
            if(objStsRprt.Status__c != 'Submitted')
            {
                SRStatus = 'None';
                system.debug('***1--Else');
                blShowCopyButton = true;
                blShowSaveBtn = true;
                blShowSubmitBtn = true;
            }
            statusDate = SRDate.format();
            system.debug('*Status'+statusDate);
        }
        
        
        
        if(AccountId != null && ServiceId != null)
        {
            
            try
            {
                objAccntSrvcs = ODS_Data_Utility.fetchAccServcesByAccntAndSrvce(AccountId,ServiceId);
                if(objAccntSrvcs.Id != null)
                {
                    AccountName = objAccntSrvcs.Account__r.Name;
                    ServiceName = objAccntSrvcs.ODS_Services__r.Name__c;
                    StatusReportFrequency = objAccntSrvcs.Status_Report_Frequency__c;
                    system.debug('StatusReportFrequency'+StatusReportFrequency);
                }
            }
            catch(Exception ex)
            {
                System.debug('ex in getting account service-------'+ex);
                
                
            } 
        }
        
        else
        {
            AccountName = 'All';
            ServiceName = 'All';
            
        }    
        
        if(objStsRprt.Id == null && StatusReportFrequency != null && StatusReportFrequency == 'Weekly'){
            SRDate = ODS_DateUtility.getSRDate(StatusReportFrequency, SRDate);
        }
        
        system.debug('**Sys2'+objAccntSrvcs);
        system.debug('**Sys3'+SRDate);
        //AcntSrvId = objAccntSrvcs.Id;
        //system.debug('+++'+AcntSrvId );
        //To hide or show copy button
        List<Status_Report__c> getPrevStatusRep = ODS_Data_Utility.getPrevStatusRep(objAccntSrvcs.Id,SRDate);
        system.debug('**-'+getPrevStatusRep); 
        if(getPrevStatusRep.size() == 0)
        {
            if(objStsRprt.Id !=  null)
            {
                SRStatus = objStsRprt.Status__c;
                blShowCopyButton = false;
                
            }
            else
            {
                blShowCopyButton = false;
            }
            
        }
    }
    
    
    /// <OBJECTIVE>
    /// Method to fetch related service.
    /// </OBJECTIVE>   
    
    public void SetRelatedService()
    {
        if(AccountId == 'All')
        {
            ServiceId = 'All';
        }
        else
        {
            //ServiceId = ODS_Data_Utility.fetchAccServcesByAcc(AccountId)[0].ODS_Services__c;
            ServiceId = 'All';
        }
    }
    
    /*   public PageReference GetStatusReportByAccountServiceID() {

ODS_Common_Utility.upsertSessionData(AccountId,ServiceID);
GetStatusReport();
GetAccountServices();

return null;
} */
    
    
    /// <OBJECTIVE>
    /// Method to fetch all accounts
    /// </OBJECTIVE>   
    public Set<string> GetAllAccounts()
    {
        Set<string> accountIdSet = new Set<string>();
        for(Account account: ODS_Data_Utility.GetAllAccounts())
        {
            accountIdSet.add(account.Id);
        }
        return accountIdSet;
    }
    
    /// <OBJECTIVE>
    /// Method to fetch all service.
    /// </OBJECTIVE>   
    public Set<string> GetAllServices()
    {
        Set<string> serviceIdSet = new Set<string>();
        for(ODS_Services__c odsService: ODS_Data_Utility.GetAllServices())
        {
            serviceIdSet.add(odsService.Id);
        }
        return serviceIdSet;
    }
    
    
    
    /// <OBJECTIVE>
    /// Method to format string to date.
    /// </OBJECTIVE>   
    public Date FormatStringToDate(string dateString)
    {
        string[] dateArr = dateString.split('-');
        return date.Parse(dateArr[1]+'/'+dateArr[0]+'/'+dateArr[2]);
    }
    
    /// <OBJECTIVE>
    /// Method to fetch all account picklist.
    /// </OBJECTIVE>   
    public static List<SelectOption> GetAccountPicklistValues()
    {
        List<SelectOption> lstSlctOptn = new list<SelectOption>(); 
        ODS_Common_Utility objUtility = new ODS_Common_Utility();
        lstSlctOptn = objUtility.getCustomersByLoggedInUser();
        return lstSlctOptn;
    }
    
    /// <OBJECTIVE>
    /// Method to fetch all service picklist.
    /// </OBJECTIVE>  
    /*public static List<SelectOption> GetServicePicklistValues()
{
List<SelectOption> lstSlctOptn = new list<SelectOption>();      
lstSlctOptn.add(new SelectOption('All', 'All')); 
for(ODS_Services__c odsService: ODS_Data_Utility.GetAllServices())
{ 
lstSlctOptn.add(new SelectOption(odsService.Id, odsService.Name)); 
}
return lstSlctOptn;
}*/
    
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
        Schema.sObjectType objType = Timesheet__c.getSObjectType();         
        Schema.DescribeSObjectResult objDscrb = objType.getDescribe(); 
        map<String, Schema.SObjectField> mapFld = objDscrb.fields.getMap(); 
        List<Schema.PicklistEntry> lstPckLstVls = mapFld.get('status__c').getDescribe().getPickListValues();        
        lstSlctOptn.add(new SelectOption('None', '--None--')); 
        for (Schema.PicklistEntry picklistVal : lstPckLstVls)
        { 
            lstSlctOptn.add(new SelectOption(picklistVal.getLabel(), picklistVal.getValue())); 
        }
        return lstSlctOptn;        
    }
    
    
    
    /// <OBJECTIVE>
    /// Method to save Status Report.
    /// </OBJECTIVE>  
    
    public pagereference saveStatusReport()
    {
        //system.debug('***SSDate'+SSDate);
        system.debug('***Save');
        PageReference pr;
        if(isMobile == true){
            pr = new PageReference(''+getMobileredirectUrl+'/apex/ODS_StatusReport_Mobile?accntId='+AccountId+'&srvcId='+serviceId);
        }
        else{
            pr = new PageReference('/apex/StatusReport?accntId='+AccountId+'&srvcId='+serviceId);
        }
        
        srToInsert = new Status_Report__c();
        srToUpdate = new Status_Report__c();
        
        List<Status_Report__c> lstObjStRprt = new List<Status_Report__c>();
        //lstObjStRprt = [SELECT Id,Status_Date__c from Status_Report__c WHERE Status_Date__c =: SRDate AND Account_Services__c =: objAccntSrvcs.Id];
        lstObjStRprt = ODS_Data_Utility.getSRBsdOnDate(SRDate,objAccntSrvcs.Id);
        system.debug('***SRDate'+SRDate);
        
        Account_Services__c  acc;
        if(objAccntSrvcs.Id!=Null){
            acc = [SELECT id, Service_Workspace_Id__c, Agile__c,Status_Report_Frequency__c,JIRA_Domain_Name__c FROM  Account_Services__c WHERE Id =: objAccntSrvcs.Id];
        }               
        /*string StatusRpDate = string.valueOf(SRDate);
system.debug('_*_'+StatusRpDate);
srId = StatusRpDate;
system.debug('_*_'+srId);
objStsRprt = ODS_Data_Utility.fetchStatusReportbyID(srId);*/
        
        if(lstObjStRprt.size() != 0)
        {
            
            system.debug('***lstObjStRprt[0].Id'+lstObjStRprt[0].Id);
            srToUpdate.Id = lstObjStRprt[0].Id;
            srToUpdate.Status__c = 'Saved';
            srToUpdate.Work_for_the_Day__c = WorkDayParam;
            system.debug('***Work_for_the_Day__c '+WorkDayParam);
            srToUpdate.Work_for_the_Next_Day__c = WorkNextDayParam;
            system.debug('***WorkNextDayParam'+WorkNextDayParam);
            srToUpdate.Issues_And_Concerns__c = IssuesConcernsParam;
            system.debug('***Issues_And_Concerns__c '+IssuesConcernsParam);
            // srToUpdate.Status_Date__c = lstObjStRprt[0].Status_Date__c;
            srToUpdate.Status_Date__c =SRDate;
            try
            {
                if(WorkDayParam != '')
                {
                    update srToUpdate;
                    //PageReference pr = new PageReference('/apex/StatusReport?accntId='+AccountId+'&srvcId='+serviceId);
                    pr.setRedirect(true);
                    return pr;
                }
                else
                {
                    blPgErrorMsg = true;
                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Work Performed Today is mandatory'));
                }
            }
            catch(Exception ex)
            {
                System.debug('exception while updating in save method------------'+ex);
            }
            
        }
        else
        {
            Date frmtdDate = Date.parse(statusDate);
            system.debug('*frmtdDate'+frmtdDate);
            system.debug('*WorkDayParam '+WorkDayParam );
            try
            {
                if(WorkDayParam != '')
                {
                    blPgErrorMsg = false;
                    srToInsert = ODS_Data_Utility.insertStatusReport(SRDate,WorkDayParam,WorkNextDayParam,IssuesConcernsParam,'Saved',objAccntSrvcs.Id, StatusReportFrequency);
                    //PageReference pr = new PageReference('/apex/StatusReport?accntId='+AccountId+'&srvcId='+serviceId);
                    pr.setRedirect(true);
                    if(ODS_AddStatusReportExternal.excludeJiraReport()==False){
                        if((acc.Agile__c=='JIRA') && (acc.JIRA_Domain_Name__c==System.Label.ODS_Demandblue_JIRA_URL) && (String.isNotBlank(acc.Service_Workspace_Id__c))){
                            ODS_AddStatusReportExternal.addOnStatus(objAccntSrvcs.Id, srToInsert.Id);    
                        }
                    }
                    return pr;
                }
                else
                {
                    blPgErrorMsg = true;
                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Work Performed Today is mandatory'));
                }
            }
            catch(Exception ex)
            {
                System.debug('exception while inserting in save method------------'+ex);
            }
        }
        return null;
    }
    /*public PageReference PgeRedirect()
{
system.debug('***PageRef');
PageReference pr = new PageReference('/apex/StatusReport?accntId='+AccountId+'&srvcId='+serviceId);
pr.setRedirect(true);
return pr;
}*/
    
    /// <OBJECTIVE>
    /// Method to submit Status Report
    /// </OBJECTIVE>  
    public pagereference submitStatusReport()
    {
        PageReference pr;
        if(isMobile == true){
            pr = new PageReference(''+getMobileredirectUrl+'/apex/ODS_StatusReport_Mobile?accntId='+AccountId+'&srvcId='+serviceId);
        }
        else{
            pr = new PageReference('/apex/StatusReport?accntId='+AccountId+'&srvcId='+serviceId);
        }
        
        srToInsert = new Status_Report__c();
        srToUpdate = new Status_Report__c();
        String sRprtName = '';
        boolean lstCntcsemail = true; 
        string issueConcerns;
        
        List<Status_Report__c> lstObjStRprt = new List<Status_Report__c>();
        
        lstObjStRprt = ODS_Data_Utility.getSRBsdOnDate(SRDate,objAccntSrvcs.Id);
        
        // Change 17-12-2020 - SD - Validation on contact Email address
        List<Contact_Account_Service__c > lstCntcs = new List<Contact_Account_Service__c >();
        lstCntcs =[SELECT ID,AccountId__c,Contact__r.AccountId,Email__c,Name,ODS_Service__c FROM Contact_Account_Service__c WHERE Contact__r.AccountId =: objAccntSrvcs.Account__c AND ODS_Service__c =:objAccntSrvcs.ODS_Services__c AND Status_Report_Required__c = True];
        system.debug('***lstCntcs******'+lstCntcs);
        if(lstCntcs.size() >0)
        {
            for(Contact_Account_Service__c objCntct: lstCntcs)
            {   
                if(objCntct.Email__c == null || objCntct.Email__c == ''){
                    lstCntcsemail = false;
                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Status Report cannot be submitted because one of the contacts doesnt have an email address'));
                }
                
            }
            
        }// Change 17-12-2020 - SD.
        
        if(lstObjStRprt.size() != 0)
        {
            if(lstCntcsemail == true)
                srToUpdate.Id = lstObjStRprt[0].Id;
            srToUpdate.Status__c = 'Submitted';
            srToUpdate.Work_for_the_Day__c = WorkDayParam;
            system.debug('##WorkNextDayParam:' +WorkNextDayParam);
            if(WorkNextDayParam != null && WorkNextDayParam != ''){
                srToUpdate.Work_for_the_Next_Day__c = WorkNextDayParam;
                
            }
            else{
                srToUpdate.Work_for_the_Next_Day__c = '<p>None</p>';
            }
            if(IssuesConcernsParam != null && IssuesConcernsParam != ''){
                srToUpdate.Issues_And_Concerns__c = IssuesConcernsParam;
                issueConcerns = IssuesConcernsParam;
            }
            else{
                srToUpdate.Issues_And_Concerns__c = '<p>None</p>';
                issueConcerns = '<p>None</p>';
            }
            srToUpdate.Status_Date__c = lstObjStRprt[0].Status_Date__c;
            try
            {
                if(WorkDayParam != '')
                {
                    update srToUpdate;
                    sendEmail(srToUpdate);
                    if(WorkNextDayParam != null && WorkNextDayParam != ''){
                        SaveNextDayReport(lstObjStRprt[0].Status_Date__c, WorkNextDayParam, issueConcerns, objAccntSrvcs.Id, StatusReportFrequency);
                    }
                    pr.setRedirect(true);
                    return pr;
                }
            }
            catch(Exception ex)
            {
                System.debug('exception while updating in submit method------------'+ex);
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(ex.getCause()), ex.getMessage(), ex.getStackTraceString(), ex.getTypeName());
            }
            
        }
        else
        {
            
            if(AccountId != null && ServiceId != null)
            {
                try
                {
                    objAccntSrvcs = ODS_Data_Utility.fetchAccServcesByAccntAndSrvce(AccountId,ServiceId);
                }
                catch(Exception ex)
                {
                    System.debug('ex----------'+ex);
                }
                
                
            }
            try
            {
                if(WorkDayParam != '')
                {
                    // Change 17-12-2020 - SD - Validation on contact Email address
                    if(lstCntcsemail == true){ 
                        blPgErrorMsg = false;
                        Date frmtdDate = Date.parse(statusDate);
                        //date.valueOf(statusDate)
                        if(WorkNextDayParam == ''){
                            WorkNextDayParam = '<p>None</p>';
                        }
                        if(IssuesConcernsParam == ''){
                            IssuesConcernsParam = '<p>None</p>';
                        }
                        issueConcerns = IssuesConcernsParam;
                        srToInsert = ODS_Data_Utility.insertStatusReport(SRDate ,WorkDayParam,WorkNextDayParam,IssuesConcernsParam,'Submitted',objAccntSrvcs.Id,StatusReportFrequency);
                        System.debug('srToInsert-------------'+srToInsert);
                        sendEmail(srToInsert);
                        if(WorkNextDayParam != null && WorkNextDayParam != '<p>None</p>'){
                            SaveNextDayReport(SRDate, WorkNextDayParam, issueConcerns, objAccntSrvcs.Id,StatusReportFrequency);
                        }    
                        pr.setRedirect(true);
                        return pr;
                    }
                }
                else{
                    
                    blPgErrorMsg = true;
                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Work Performed Today is mandatory'));
                }
                
            }
            catch(Exception ex)
            {
                System.debug('exception while inserting in submit method------------'+ex);
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(ex.getCause()), ex.getMessage(), ex.getStackTraceString(), ex.getTypeName());
            }
        }
        
        //PageReference pr = new PageReference('/apex/StatusReport?accntId='+AccountId+'&srvcId='+serviceId);
        //pr.setRedirect(true);
        return null;
        
        
    }
    
    
    /// <OBJECTIVE>
    /// Method to cancel Status Report.
    /// </OBJECTIVE>  
    public pagereference cancelStatusReport()
    {
        PageReference pr;
        if(isMobile == true){
            pr = new PageReference(''+getMobileredirectUrl+'/apex/ODS_StatusReport_Mobile');
        }
        else{
            pr = new PageReference('/apex/StatusReport');
        }
        
        pr.setRedirect(true);
        return pr;
        
    }
    
    ///<OBJECTIVE>
    /// Method to Copy status report
    ///</OBJECTIVE>
    
    public pagereference fetchStatusReportByDate()
    {
        //List<Status_Report__c> getPrevStatusRep = [SELECT Id,CreatedDate,Work_for_the_Day__c,Work_for_the_Next_Day__c,Issues_And_Concerns__c,Status_Date__c,Status__c FROM Status_Report__c WHERE Account_Services__c =: objAccntSrvcs.Id AND Status_date__c <: SRDate ORDER BY Status_Date__c DESC];
        List<Status_Report__c> getPrevStatusRep = ODS_Data_Utility.getPrevStatusRep(objAccntSrvcs.Id,SRDate);
        if(getPrevStatusRep.size() != 0)
        {
            
            WorkDayParam = getPrevStatusRep[0].Work_for_the_Day__c;
            WorkNextDayParam = getPrevStatusRep[0].Work_for_the_Next_Day__c;
            IssuesConcernsParam = getPrevStatusRep[0].Issues_And_Concerns__c;
        }
        return null;
    }
    
    ///<OBJECTIVE>
    /// Method to Fetch custom date Status Report
    /// </OBJECTIVE>
    public pageReference fetchCustomDateSR()
    {
        //List<Status_Report__c> getPrevStatusRep = [SELECT Id,CreatedDate,Work_for_the_Day__c,Work_for_the_Next_Day__c,Issues_And_Concerns__c,Status_Date__c FROM Status_Report__c WHERE Account_Services__c =: objAccntSrvcs.Id AND Status_date__c <: SRDate ORDER BY Status_Date__c DESC];
        List<Status_Report__c> getPrevStatusRep = ODS_Data_Utility.getPrevStatusRep(objAccntSrvcs.Id,SRDate);
        system.debug('***&'+getPrevStatusRep);
        if(getPrevStatusRep.size() == 0)
        {
            blShowCopyButton = false;
        }
        else
        {
            blShowCopyButton = true;
        }
        
        List<Status_Report__c> getCustomStatusRep = ODS_Data_Utility.fetchSR(objAccntSrvcs.Id,SRDate);
        if(getCustomStatusRep.size() != 0)
        {
            SRStatus = getCustomStatusRep[0].Status__c;
            system.debug('(**'+SRStatus);
            if(getCustomStatusRep[0].Status__c == 'Submitted')
            {
                blShowCopyButton = false;
                blShowSaveBtn = false;
                blShowSubmitBtn = false;
            }
            else
            {
                if(getPrevStatusRep.size() != 0)
                {
                    blShowCopyButton = true;
                    blShowSaveBtn = true;
                    blShowSubmitBtn = true;
                }
                else
                {
                    blShowCopyButton = false;
                    blShowSaveBtn = true;
                    blShowSubmitBtn = true;
                }
            }
            
            /*if(getCustomStatusRep[0].Work_for_the_Day__c != null)
{
getCustomStatusRep[0].Work_for_the_Day__c = getCustomStatusRep[0].Work_for_the_Day__c.replaceAll('\\<.*?\\>', '');
}

if(getCustomStatusRep[0].Work_for_the_Next_Day__c != null)
{
getCustomStatusRep[0].Work_for_the_Next_Day__c = getCustomStatusRep[0].Work_for_the_Next_Day__c.replaceAll('\\<.*?\\>', '');
}

if(getCustomStatusRep[0].Issues_And_Concerns__c != null)
{
getCustomStatusRep[0].Issues_And_Concerns__c = getCustomStatusRep[0].Issues_And_Concerns__c.replaceAll('\\<.*?\\>', '');
}*/
            
            WorkDayParam = getCustomStatusRep[0].Work_for_the_Day__c;
            WorkNextDayParam = getCustomStatusRep[0].Work_for_the_Next_Day__c;
            IssuesConcernsParam = getCustomStatusRep[0].Issues_And_Concerns__c;
        }
        else
        {
            SRStatus = 'None';
            blShowSaveBtn = true;
            blShowSubmitBtn = true;
            WorkDayParam = '';
            WorkNextDayParam = '';
            IssuesConcernsParam = '';
        }
        return null;
        
        
    }
    
    /// <OBJECTIVE>
    /// Method to send email once the record is submitted.
    /// </OBJECTIVE> 
    public void sendEmail(Status_Report__c objStatusRprt)
    {
        List<String> lstToAddress = new List<String>();
        List<String> lstCcAddress = new List<String>();
        Set<String> setToAddress = new Set<String>();
        Set<String> setCcAddress = new Set<String>();
        
        Status_Report__c srTosendEmail = new Status_Report__c();
        srTosendEmail = [Select Id, Name, Status_Date__c,Work_For_The_Day__c,Work_For_The_Next_Day__c,Account_Services__r.ODS_Services__C,Account_Services__r.Status_Report_Frequency__c,Issues_and_Concerns__c,Account_Services__c,Account_Services__r.Technical_Account_manager__r.Name,Account_Services__r.Account__c,Account_Services__r.ODS_Services__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,Account_Services__r.Account__r.Name, Owner.Name, Owner.phone from Status_Report__c where Id=:objStatusRprt.Id];
        //srTosendEmail = [Select Id, Name, Status_Date__c,Work_For_The_Day__c,Work_For_The_Next_Day__c,Account_Services__r.ODS_Services__C,Account_Services__r.Status_Report_Frequency__c,Issues_and_Concerns__c,Account_Services__c,Account_Services__r.Technical_Account_manager__r.Name,Account_Services__r.Technical_Account_manager__r.Signature__c,Account_Services__r.Account__c,Account_Services__r.ODS_Services__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,Account_Services__r.Account__r.Name, Owner.Name, Owner.phone from Status_Report__c where Id=:objStatusRprt.Id];
        System.debug('srTosendEmail------------'+srTosendEmail.Account_Services__c);
        User currentUser=[Select Id,Name,Email,Phone From User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        srWeekStartDate = srTosendEmail.Status_Date__c;
        srWeekEndDate = srTosendEmail.Status_Date__c.addDays(4);
        
        String accntId = srTosendEmail.Account_Services__r.Account__c;
        String srvcId = srTosendEmail.Account_Services__r.ODS_Services__C;
        System.debug('accntId------------'+accntId); 
        System.debug('srvcId------------'+srvcId);       
        //List of contact who opt for status report
        /*List<Contact> lstCntcs = new List<Contact>();
lstCntcs =[Select Id, Name, Status_Report_Required__c, email, AccountId from Contact where AccountId =: accntId and Status_Report_Required__c = True ];*/
        List<Contact_Account_Service__c > lstCntcs = new List<Contact_Account_Service__c >();
        lstCntcs =[SELECT ID,AccountId__c,Contact__r.AccountId,Email__c,Name,ODS_Service__c FROM Contact_Account_Service__c WHERE Contact__r.AccountId =: accntId AND ODS_Service__c =:srvcId AND Status_Report_Required__c = True];
        System.debug('lstCntcs------------'+lstCntcs);
        //List of User Accounts associated
        List<User_Account__c> lstUsrAccnts = new List<User_Account__c>();
        String excludeRoles = Label.Account_Roles_To_Exclude;
        List<String> rolesToExclude = excludeRoles.replace(', ',',').split(',');
        lstUsrAccnts = [Select Id, name, User__c,User__r.Email, Account__c, Role_in_Account__c,Account__r.Small_Business__c from User_Account__c where Account__c =: accntId AND Role_in_Account__c NOT IN: rolesToExclude];
        string signTitle='CSM';
        if(lstUsrAccnts[0].Account__r.Small_Business__c){
            signTitle='Technical Lead';
        }
        System.debug('lstUsrAccnts------------'+lstUsrAccnts);
        //get list of to address
        if(lstCntcs.size() >0)
        {
            for(Contact_Account_Service__c objCntct: lstCntcs)
            {               
                setToAddress.add(objCntct.Email__c);
                
            }
            lstToAddress.addAll(setToAddress);
            
        }
        System.debug('lstToAddress------------'+lstToAddress);
        
        //get list of Cc address
        if(lstUsrAccnts.size() >0)
        {
            for(User_Account__c objUsrAccnt: lstUsrAccnts)
            {
                setCcAddress.add(objUsrAccnt.User__r.Email);
                
            }   
            lstCcAddress.addAll(setCcAddress);          
            
        }
        System.debug('lstCcAddress------------'+lstCcAddress);
        
        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage(); 
        mail.setToAddresses(lstToAddress); 
        String sccntMngr = UserInfo.getName(); 
        //  String sccntMngr = srTosendEmail.Account_Services__r.Technical_Account_manager__r.Signature__c;
        System.debug('sccntMngr------------'+sccntMngr);
        mail.setSenderDisplayName(sccntMngr);
        mail.setCcAddresses(lstCcAddress);
        if(srTosendEmail.Account_Services__r.Status_Report_Frequency__c == 'Weekly'){
            String subject = srTosendEmail.Account_Services__r.Account__r.Name + '-'+ srTosendEmail.Account_Services__r.ODS_Service_Name__c +' : Weekly Status Report for the week - ' +srWeekStartDate.format() +'-'+srWeekEndDate.format();
            mail.setSubject(subject);
            string TAMPhoneNumber = '';
            if(!string.isEmpty(srTosendEmail.Owner.phone)) 
                TAMPhoneNumber = srTosendEmail.Owner.phone;
            String strHtmlBody = '' ;    
            string htmlbody='<table width="100%" cellpadding="0" cellspacing="0"><tr><td><font face="Calibri " size="3">  Hi Team, <br/><br/> Here is your Weekly ODS Status Report:    <br/><br/><ul><li><strong> Work Performed for the week </strong> '+ srTosendEmail.Work_for_the_Day__c +'';
            htmlbody +='</li></ul><ul> <li> <strong>Work To be Performed Next Week </strong> '+srTosendEmail.Work_for_the_Next_Day__c +'</li></ul><ul> <li><strong> Issues/Concerns/Road blocks/Questions </strong>'+srTosendEmail.Issues_And_Concerns__c +' </li></ul> <br/> Please contact me for any additional inputs. <br/>  <br/></font></td></tr></table>';
            
            string emailSignature=ODS_Common_Utility.getEmailSignature(UserInfo.getName(),signTitle,currentUser.Phone,currentUser.Email);
            strHtmlBody =ODS_Common_Utility.getEmailMessage(htmlbody,emailSignature);
            
            mail.setHtmlBody(strHtmlBody);
            if(lstToAddress.size() >0)
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }  
            
        }
        else{
            String subject = srTosendEmail.Account_Services__r.Account__r.Name + '-'+ srTosendEmail.Account_Services__r.ODS_Service_Name__c +' : Daily Status Report - ' +srTosendEmail.Status_Date__c.format();
            mail.setSubject(subject);
            string TAMPhoneNumber = '';
            if(!string.isEmpty(srTosendEmail.Owner.phone)) 
                TAMPhoneNumber = srTosendEmail.Owner.phone;
            String strHtmlBody = '' ;  
            string htmlbody='<table width="100%" cellpadding="0" cellspacing="0"><tr><td><font face="Calibri " size="3">  Hi Team, <br/><br/> Here is your Daily ODS Status Report:    <br/><br/><ul><li><strong> Work Performed Today </strong> '+ srTosendEmail.Work_for_the_Day__c +'';
            htmlbody += '</li></ul><ul> <li> <strong>Work To be Performed Next Working Day </strong> '+srTosendEmail.Work_for_the_Next_Day__c +'</li></ul><ul> <li><strong> Issues/Concerns/Road blocks/Questions </strong>'+srTosendEmail.Issues_And_Concerns__c +' </li></ul> <br/> Please contact me for any additional inputs. <br/>  <br/></font></td></tr></table>';
            string emailSignature=ODS_Common_Utility.getEmailSignature(UserInfo.getName(),signTitle,currentUser.Phone,currentUser.Email);
            strHtmlBody =ODS_Common_Utility.getEmailMessage(htmlbody,emailSignature);
            
            mail.setHtmlBody(strHtmlBody);
            //}
            if(lstToAddress.size() >0)
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }  
            
        }
    }
    
    
    public pagereference redirectToStatusPage()
    {
        String url;
        if(isMobile == true){
            url = '/apex/ODS_StatusReport_Mobile?accntId='+AccountId+'&srvcId='+serviceId;
        }
        
        else{
            url = '/apex/StatusReport?accntId='+AccountId+'&srvcId='+serviceId;
        }        
        Pagereference pgRef = new PageReference(url);
        return pgRef ;
    }
    
    public pagereference redirectToTimeSheet()
    {
        
        String url = '/apex/ViewTimesheet?accntId='+AccountId+'&srvcId='+serviceId;        
        Pagereference pgRef = new PageReference(url);
        return pgRef ;
        
    }
    public PageReference GetStatusReportByAccountServiceID() {
        
        ODS_Common_Utility.upsertSessionData(AccountId,ServiceID);
        PageReference pr = new PageReference('/apex/StatusReport?accntId='+AccountId+'&srvcId='+ServiceID);
        return pr;
    }
    
    public static void SaveNextDayReport(Date dateofSR, string srValue,string issuesConcernsValue, Id accntSrvice, string srFrequency)
    {
        
        
        date nextWorkingDay;
        List<Status_Report__c> lstNextStRprt = new List<Status_Report__c>();
        Status_Report__c insertNextDaySR = new Status_Report__c();
        string nextDaySRValue = srValue;
        if(srFrequency == 'Weekly'){
            nextWorkingDay = dateofSR.addDays(7);
        }else{
            nextWorkingDay = ODS_DateUtility.getNextBusinessDate(dateofSR);    
        }        
        Account_Services__c  acc; 
        if(accntSrvice != null){
            acc = [SELECT id, Service_Workspace_Id__c, Agile__c,JIRA_Domain_Name__c FROM  Account_Services__c WHERE Id =: accntSrvice]; 
        }
        try
        {
            lstNextStRprt = ODS_Data_Utility.getSRBsdOnDate(nextWorkingDay,accntSrvice);
            if(lstNextStRprt.size() == 0 )
            {
                insertNextDaySR = ODS_Data_Utility.insertStatusReport(nextWorkingDay ,srValue,nextDaySRValue,issuesConcernsValue,'Saved',accntSrvice,srFrequency);
                if((acc != null) && ODS_AddStatusReportExternal.excludeJiraReport() == False){
                    if((acc.Agile__c=='JIRA') && (acc.JIRA_Domain_Name__c==System.Label.ODS_Demandblue_JIRA_URL) && (String.isNotBlank(acc.Service_Workspace_Id__c))){
                        ODS_AddStatusReportExternal.addOnStatus(accntSrvice,insertNextDaySR.id);
                    }    
                }    
            }
        }
        catch(Exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }  
    }
    
}