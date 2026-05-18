public class ODS_CustomerInfoController {
    
    public string AccountId {get;set;}
    public string AccountToSaveData {get;set;}
    public string DatatoSaveJSON {get;set;}
    public string ServiceId {get;set;}
    public list<Schema.emailmessage> incidentEmails {get; set;}
    public schema.emailmessage currentEmail {get; set;}
    public account currentAccount {get; set;}
    public Boolean displayPopUp { get; set; }
    public Boolean displayAEPopup { get; set; }
    public string PassAccountName {get;set;} 
    public string PassServiceName {get;set;} 
    public string SalesforceAEName {get;set;}
    public string SalesforceAEEmail {get;set;}
    public string SalesforceAEDailerPhone {get;set;}
    public string SalesforceAEMobilePhone {get;set;}
    public string OrganizationID {get;set;}
    public string InstanceName {get;set;}
    public string MarketingCloudInstanceName {get;set;}
    public boolean HasCommunities {get;set;}
    public boolean AllowFutureTimesheets {get;set;}
    public string SalesforceProducts {get;set;}
    public string BusinessOverview {get;set;}
    public string Customers {get;set;}
    public string  KeyCompetitors {get;set;}
    public string CollaboratorsPartners {get;set;}
    public string ComplianceRequirements {get;set;}
    public string CurrentPainpoints {get;set;}
    public string ProductBacklog {get;set;}
    public string ProductsServicesOffered {get;set;}
    public string SalesforceRoadmap {get;set;}
    public string AppexchangeApps {get;set;}
    public string CustomerService {get;set;}
    public string CPQProduct {get;set;}
    public string Marketing {get;set;}
    public string Middleware {get;set;}
    public string ERP {get;set;}
    public string DocumentGeneration {get;set;}
    public string ExternalStorage {get;set;}
    public string DigitalSignature {get;set;}
    public string Analytics {get;set;}
    public string Backup {get;set;}
    public string ProjectManagement {get;set;}
    public string DevelopmentTools {get;set;}
    public string CustomerPortalAccess {get;set;}
    public string CustomerEngagementScore {get;set;}
    public string StatusReportFrequency {get;set;}
    public string WeeklyMonthlyMeeting {get;set;}
    public string EnvironmentAccess {get;set;}
    public string OnboardingDocument {get;set;}
    public string LRC {get;set;}
    public string CustomerPortalAccessStatusDate {get;set;}
    public string WeeklyMonthlyMeetingDate {get;set;}
    public string EnvironmentAccessStatusDate {get;set;}
    public string OnboardingDocumentStatusDate {get;set;}
    public string LRCStatusDate {get;set;}
    public string updatedAccount {get;set;}  
    public string updatedService {get;set;} 
    public string updatedStatusreport {get;set;} 
    
    public List<SelectOption> getCustomerPortalAccessPicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Account.Customer_Portal_Access__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    public List<SelectOption> getCustomerEngagementScorePicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Account.Customer_Engagement_Score__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    public List<SelectOption> getStatusReportPickList {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Account_Services__c.Status_Report_Frequency__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    public List<SelectOption> getWeeklyMonthlyMeetingPicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Account.Setup_Weekly_Monthly_Meeting__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    public List<SelectOption> getEnvironmentAccessPicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Account.Environment_Access__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    public List<SelectOption> getOnboardingDocumentPicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Account.Onboarding_Document__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    public List<SelectOption> getLRCPicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Account.Lightning_Readiness_Check__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    
    public Account getAccount (){
        return [select Salesforce_AE_Name__c from Account limit 1];
    }
    public PageReference getAccountServiceId()
    {
        AccountId = Apexpages.currentPage().getParameters().get('SelectedAccountId');
        ServiceId = Apexpages.currentPage().getParameters().get('SelectedServiceID'); 
        if(AccountId != null && AccountId !='')
        {
            updatePage();
            getAccountIncidents();
        }
        return null;
        
    }
    public void updatePage ()
    {
        system.debug('ServiceId---'+ServiceId);
        Account_Services__c  accountService; 
       
        if(ServiceId == 'All' || string.isBlank(ServiceId)){
            accountService = [SELECT Allow_Future_Timesheets__c,Account__r.Name,ODS_Service_Name__c,Status_Report_Frequency__c FROM  Account_Services__c where Account__r.Id =: AccountId limit 1];   
        }else{
            accountService = [SELECT Allow_Future_Timesheets__c,Account__r.Name,ODS_Service_Name__c,Status_Report_Frequency__c FROM  Account_Services__c where Account__r.Id =: AccountId and ODS_Services__c =:ServiceId limit 1];   
        }
        
        system.debug('accountService'+accountService);
        if(accountService != null)
        {
            PassAccountName = accountService.Account__r.Name;
            PassServiceName = accountService.ODS_Service_Name__c ;
            StatusReportFrequency = accountService.Status_Report_Frequency__c;
            currentAccount = [Select Id, Name, Salesforce_AE_Name__r.Name, Salesforce_AE_Name__r.Email,Salesforce_AE_Name__r.Dailer_Phone__c,Salesforce_AE_Name__r.Phone,Salesforce_AE_Name__r.Cell__c,Has_Communities__c, Customer_Portal_Access__c,Customer_Engagement_Score__c, Setup_Weekly_Monthly_Meeting__c, Environment_Access__c, Onboarding_Document__c, Lightning_Readiness_Check__c, Instance_Name__c, Marketing_Cloud_Instance_Name__c, Organization_ID__c, Salesforce_Products__c,Business_Overview__c,Customers__c,Key_Competitors__c,Collaborators_Partners__c,Compliance_Requirements__c,Current_Painpoints__c,Product_Backlog__c,Products_Services_Offered__c,Salesforce_Roadmap__c, Appexchange_Apps__c, Customer_Service__c, CPQ_Product__c, Marketing__c, Middleware__c, ERP__c, Document_Generation__c, External_Storage__c, Digital_Signature__c, Analytics__c, Backup__c, Project_Management__c, Development_Tools__c, Customer_Portal_Access_Status_Date__c, Setup_Weekly_MonthlyMeeting_Date__c, Environment_Access_Status_Date__c, Onboarding_Document_Status_Date__c, Lightning_Readiness_Check_Status_Date__c From Account Where Name = :accountService.Account__r.Name  Limit 1];
            SalesforceAEName = currentAccount.Salesforce_AE_Name__r.Name;
            SalesforceAEEmail=currentAccount.Salesforce_AE_Name__r.Email;
            SalesforceAEDailerPhone=currentAccount.Salesforce_AE_Name__r.Dailer_Phone__c;
            SalesforceAEMobilePhone=currentAccount.Salesforce_AE_Name__r.Cell__c;
            OrganizationID = currentAccount.Organization_ID__c;
            InstanceName = currentAccount.Instance_Name__c;
            MarketingCloudInstanceName =currentAccount.Marketing_Cloud_Instance_Name__c;
            HasCommunities = currentAccount.Has_Communities__c;
            SalesforceProducts = currentAccount.Salesforce_Products__c;
            BusinessOverview = currentAccount.Business_Overview__c;
            Customers = currentAccount.Customers__c;
            KeyCompetitors = currentAccount.Key_Competitors__c;
            CollaboratorsPartners = currentAccount.Collaborators_Partners__c;
            ComplianceRequirements = currentAccount.Compliance_Requirements__c;
            CurrentPainpoints = currentAccount.Current_Painpoints__c;            
            ProductBacklog = currentAccount.Product_Backlog__c;
            ProductsServicesOffered = currentAccount.Products_Services_Offered__c;
            SalesforceRoadmap = currentAccount.Salesforce_Roadmap__c;
            AppexchangeApps = currentAccount.Appexchange_Apps__c;
            CustomerService = currentAccount.Customer_Service__c;
            CPQProduct = currentAccount.CPQ_Product__c;
            Marketing = currentAccount.Marketing__c;
            Middleware = currentAccount.Middleware__c;
            ERP = currentAccount.ERP__c;
            DocumentGeneration = currentAccount.Document_Generation__c;
            ExternalStorage = currentAccount.External_Storage__c;
            DigitalSignature = currentAccount.Digital_Signature__c;
            Analytics = currentAccount.Analytics__c;
            Backup = currentAccount.Backup__c;
            ProjectManagement = currentAccount.Project_Management__c;
            DevelopmentTools = currentAccount.Development_Tools__c;
            CustomerPortalAccess = currentAccount.Customer_Portal_Access__c;
            CustomerEngagementScore = currentAccount.Customer_Engagement_Score__c;
            StatusReportFrequency = accountService.Status_Report_Frequency__c;
            AllowFutureTimesheets=accountService.Allow_Future_Timesheets__c;
            system.debug('StatusReportFrequency'+StatusReportFrequency);
            WeeklyMonthlyMeeting = currentAccount.Setup_Weekly_Monthly_Meeting__c;
            EnvironmentAccess = currentAccount.Environment_Access__c;
            OnboardingDocument = currentAccount.Onboarding_Document__c;
            LRC = currentAccount.Lightning_Readiness_Check__c;
            date dateValueCustomerPortalAccessStatusDate =currentAccount.Customer_Portal_Access_Status_Date__c;
            CustomerPortalAccessStatusDate= string.valueOf(dateValueCustomerPortalAccessStatusDate);
            date dateValueWeeklyMonthlyMeetingDate = currentAccount.Setup_Weekly_MonthlyMeeting_Date__c;
            WeeklyMonthlyMeetingDate = string.valueOf(dateValueWeeklyMonthlyMeetingDate);
            date dateValueEnvironmentAccessStatusDate = currentAccount.Environment_Access_Status_Date__c;
            EnvironmentAccessStatusDate = string.valueOf(dateValueEnvironmentAccessStatusDate);   
            date dateValueOnboardingDocumentStatusDate = currentAccount.Onboarding_Document_Status_Date__c;
            OnboardingDocumentStatusDate = string.valueOf(dateValueOnboardingDocumentStatusDate);
            date dateValueLRCStatusDate = currentAccount.Lightning_Readiness_Check_Status_Date__c; 
            LRCStatusDate  = string.valueOf(dateValueLRCStatusDate);
            
        }
        else{
            PassAccountName = 'None';
            PassServiceName = 'None';
        }
        
        
    }
    public void getAccountIncidents()
    {
        set<Id> incidentCaseId = new set<Id>();
        Account_Services__c  accountService; 
        accountService = [SELECT Account__r.Name,ODS_Service_Name__c,Status_Report_Frequency__c FROM  Account_Services__c where Account__r.Id =: AccountId limit 1];   
        if(accountService != null)
        {
            Account currentAccount = [Select Id, Name, Instance_Name__c, Marketing_Cloud_Instance_Name__c from Account where Name = :accountService.Account__r.Name  Limit 1];
            string queueDeveloperName = system.label.SF_Incidents_Queue_Name;
            group Queue = [Select Id, Name from Group where Type = 'Queue' AND DeveloperName = :queueDeveloperName limit 1];
            List<Case> incidentCases = [Select Id, Instance_Names__c From Case Where OwnerId =:Queue.Id];
            If((incidentCases != Null) && ((currentAccount.Instance_Name__c != Null) || (currentAccount.Marketing_Cloud_Instance_Name__c != Null)))
            {
                for(Case c: incidentCases)
                {
                    if(c.Instance_Names__c != Null)
                    {
                        string[] instanceNames = c.Instance_Names__c.replace(' ', '').toUpperCase().split(',');
                        if(((currentAccount.Instance_Name__c != Null) && (instanceNames.contains(currentAccount.Instance_Name__c.toUpperCase()))) || ((currentAccount.Marketing_Cloud_Instance_Name__c != Null) && (instanceNames.contains(currentAccount.Marketing_Cloud_Instance_Name__c.toUpperCase()))))
                        {
                            incidentCaseId.add(c.Id);
                        }
                    }
                }
            }
            If(incidentCaseId != Null)
            {
                incidentEmails = [Select Id, subject, HTMLBody, CreatedDate, ParentId from emailmessage Where parentId IN:incidentCaseId ORDER BY CreatedDate DESC limit 10];
            }
        }
        
    }
    public PageReference showPopup() {
        string emailId=apexpages.currentpage().getparameters().get('emailId');
        currentEmail =[select Id ,HTMLBody, Subject from emailmessage  where id=:emailId limit 1];
        string messageBody = currentEmail.HTMLBody;
        string regex = '((\\s|;)(https?://([A-Za-z\\d._~:/?#@!$&\'()*+,;=-])+)+?)';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(messageBody);
        string replacedMessage = '';
        if(regexMatcher.find()) {
            replacedMessage = messageBody.replaceAll(regex, '<a target="_blank" href="$1">$1</a>');
            replacedMessage = replacedMessage.replaceAll('(\\s|;)(http://)', 'http://');
            replacedMessage = replacedMessage.replaceAll('(\\s|;)(https://)', 'https://');
            currentEmail.HTMLBody = replacedMessage;
        }
        currentEmail.HTMLBody = currentEmail.HTMLBody.replace('<a href="', '<a target="_blank" href="');
        displaypopup=true;
        return null;
    }
    public PageReference closePopup() {
        displaypopup=false;
        return null;
    }
    public class JSONserialize {
        public string Org_Id;
        public string Salesforce_AE_Name;
        public string Customer_Portal_Access;
        public string Customer_Engagement_Score;
        public string Status_Report_Frequency;
        public date Customer_Portal_Access_Status_Date;
        public string Weekly_Monthly_Meeting;
        public date Setup_Weekly_Monthly_Meeting_Date;
        public string Environment_Access;
        public date Environment_Access_Status_Date;
        public string Onboarding_Document;
        public date Onboarding_Document_Status_Date;
        public string LRC;
        public date LRC_Status_Date;
        public string Instance_Name;
        public string Marketing_Cloud_Instance_Name; 
        public string Has_Communities; 
        public string Future_Timesheet;
        public string Salesforce_Products;
        public string Business_Overview;
        public string Customers;
        public string Key_Competitors;
        public string Collaborators_Partners;
        public string Compliance_Requirements;
        public string Current_Painpoints;
        public string Product_Backlog;
        public string Products_Services_Offered;
        public string Salesforce_Roadmap;
        public string Appexchange_Apps;
        public string Customer_Service  ;
        public string CPQ_Product;
        public string Marketing;
        public string Middleware;
        public string ERP;
        public string Document_Generation;
        public string External_Storage;
        public string Digital_Signature;
        public string Analytics;
        public string Backup;
        public string Project_Management ;
        public string Development_Tools;
        
    }
    
    public static JSONserialize parse(String json) {
        return (JSONserialize) System.JSON.deserialize(json, JSONserialize.class);
    }
    public Pagereference SaveCustomerInfo()
    {
        if(DatatoSaveJSON != null && AccountToSaveData != null)
        {
            JSONserialize obj = parse(DatatoSaveJSON);
            system.debug('obj--'+obj);
            system.debug('ServiceId ###---'+ServiceId);
            Account_Services__c accountService;
          
            if(ServiceId == 'All' || string.isBlank(ServiceId)){
                accountService = [SELECT ODS_Services__c,Account__r.Name,ODS_Service_Name__c,Status_Report_Frequency__c FROM  Account_Services__c where Account__r.Id =: AccountToSaveData limit 1]; 
            }else{
                accountService = [SELECT ODS_Services__c,Account__r.Name,ODS_Service_Name__c,Status_Report_Frequency__c FROM  Account_Services__c where Account__r.Id =: AccountToSaveData and ODS_Services__c =:ServiceId limit 1]; 
            }
            system.debug('accountService'+accountService);  
            system.debug('DatatoSaveJSON'+DatatoSaveJSON);  
            Account accountToUpdate = [Select Name, Salesforce_AE_Name__c, Customer_Portal_Access__c,Customer_Engagement_Score__c, Setup_Weekly_Monthly_Meeting__c, Environment_Access__c, Marketing_Cloud_Instance_Name__c, Has_Communities__c, Onboarding_Document__c, Lightning_Readiness_Check__c, Instance_Name__c, Organization_ID__c,Business_Overview__c, Salesforce_Products__c,Customers__c,Key_Competitors__c,Collaborators_Partners__c,Compliance_Requirements__c,Current_Painpoints__c,Product_Backlog__c,Products_Services_Offered__c,Salesforce_Roadmap__c, Appexchange_Apps__c, Customer_Service__c, CPQ_Product__c, Marketing__c, Middleware__c, ERP__c, Document_Generation__c, External_Storage__c, Digital_Signature__c, Analytics__c, Backup__c, Project_Management__c, Development_Tools__c, Customer_Portal_Access_Status_Date__c, Setup_Weekly_MonthlyMeeting_Date__c, Environment_Access_Status_Date__c, Onboarding_Document_Status_Date__c, Lightning_Readiness_Check_Status_Date__c From Account Where Name = :accountService.Account__r.Name limit 1];
            updatedAccount = AccountToSaveData;
            updatedservice = accountService.ODS_Services__c ;
            updatedStatusreport = accountService.Status_Report_Frequency__c;
            accountToUpdate.Customer_Portal_Access__c  = obj.Customer_Portal_Access;
            accountToUpdate.Customer_Engagement_Score__c  = obj.Customer_Engagement_Score;
            accountService.Status_Report_Frequency__c  = obj.Status_Report_Frequency;
            system.debug('Status_Report_Frequency'+obj.Status_Report_Frequency);  
            accountToUpdate.Setup_Weekly_Monthly_Meeting__c = obj.Weekly_Monthly_Meeting;
            accountToUpdate.Environment_Access__c  = obj.Environment_Access;
            accountToUpdate.Onboarding_Document__c  =   obj.Onboarding_Document;
            accountToUpdate.Lightning_Readiness_Check__c  =  obj.LRC;
            accountToUpdate.Instance_Name__c  = obj.Instance_Name;
            accountToUpdate.Marketing_Cloud_Instance_Name__c = obj.Marketing_Cloud_Instance_Name;
            accountToUpdate.Organization_ID__c = obj.Org_Id;
            accountToUpdate.Salesforce_Products__c = obj.Salesforce_Products;
            accountToUpdate.Business_Overview__c = obj.Business_Overview;
            accountToUpdate.Customers__c = obj.Customers;
            accountToUpdate.Key_Competitors__c = obj.Key_Competitors;
            accountToUpdate.Collaborators_Partners__c = obj.Collaborators_Partners;
            accountToUpdate.Compliance_Requirements__c = obj.Compliance_Requirements;
            accountToUpdate.Current_Painpoints__c = obj.Current_Painpoints;
            accountToUpdate.Product_Backlog__c = obj.Product_Backlog;
            accountToUpdate.Products_Services_Offered__c = obj.Products_Services_Offered;
            accountToUpdate.Salesforce_Roadmap__c = obj.Salesforce_Roadmap;
            accountToUpdate.Appexchange_Apps__c = obj.Appexchange_Apps;
            accountToUpdate.Customer_Service__c =  obj.Customer_Service  ;
            accountToUpdate.CPQ_Product__c  = obj.CPQ_Product;
            accountToUpdate.Marketing__c  = obj.Marketing;
            accountToUpdate.Middleware__c  =   obj.Middleware;
            accountToUpdate.ERP__c  = obj.ERP;
            accountToUpdate.Document_Generation__c  = obj.Document_Generation;
            accountToUpdate.External_Storage__c  = obj.External_Storage;
            accountToUpdate.Digital_Signature__c  = obj.Digital_Signature;
            accountToUpdate.Analytics__c  = obj.Analytics;
            accountToUpdate.Backup__c  = obj.Backup;
            accountToUpdate.Project_Management__c  = obj.Project_Management ;
            accountToUpdate.Development_Tools__c = obj.Development_Tools;
            
            if(obj.Has_Communities == 'True')
            {
                accountToUpdate.Has_Communities__c = True;
            }
            else
            {
                accountToUpdate.Has_Communities__c = False;
            }
            
            If(obj.Customer_Portal_Access_Status_Date != null)
            {
                accountToUpdate.Customer_Portal_Access_Status_Date__c  = obj.Customer_Portal_Access_Status_Date;
            }
            else {
                accountToUpdate.Customer_Portal_Access_Status_Date__c = null;
            }
            If(obj.Setup_Weekly_Monthly_Meeting_Date != null)
            {
                accountToUpdate.Setup_Weekly_MonthlyMeeting_Date__c  = obj.Setup_Weekly_Monthly_Meeting_Date;
            }
            else {
                accountToUpdate.Setup_Weekly_MonthlyMeeting_Date__c = null;
            }
            If(obj.Environment_Access_Status_Date != null)
            {
                accountToUpdate.Environment_Access_Status_Date__c  =  obj.Environment_Access_Status_Date;
            }
            else {
                accountToUpdate.Environment_Access_Status_Date__c = null;
            }
            If(obj.Onboarding_Document_Status_Date != null)
            {
                accountToUpdate.Onboarding_Document_Status_Date__c = obj.Onboarding_Document_Status_Date;
            }
            else {
                accountToUpdate.Onboarding_Document_Status_Date__c = null;
            }
            If(obj.LRC_Status_Date != null)
            {
                accountToUpdate.Lightning_Readiness_Check_Status_Date__c = obj.LRC_Status_Date;
            }
            else {
                accountToUpdate.Lightning_Readiness_Check_Status_Date__c = null;
            }
            system.debug('obj.Future_Timesheet---'+obj.Future_Timesheet);
            if(obj.Future_Timesheet == 'True'|| obj.Future_Timesheet == 'true')
            {
                accountService.Allow_Future_Timesheets__c = True;
            }
            else
            {
                accountService.Allow_Future_Timesheets__c = False;
            }
            try{
                update accountToUpdate;
                update accountService;
            }
            catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }
            
        }
        return null;
    }
    public pagereference cancelChanges(){
        return null;
    } 
    public void showAEPopup(){
        displayAEPopup = true;    
    }
    public void closeAEPopup() {
        displayAEPopup=false;
    }
}