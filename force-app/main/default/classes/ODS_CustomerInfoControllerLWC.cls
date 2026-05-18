public without sharing class ODS_CustomerInfoControllerLWC {
    @AuraEnabled(cacheable=false)
    public static Account getCurrentAccount(String accountId){
        Account accountList=[Select Id, Name,Salesforce_AE_Name__r.Name, Salesforce_AE_Name__r.Email,Salesforce_AE_Name__r.Dailer_Phone__c,Salesforce_AE_Name__r.Phone,Salesforce_AE_Name__r.Cell__c,Has_Communities__c, Customer_Portal_Access__c,Customer_Engagement_Score__c, Setup_Weekly_Monthly_Meeting__c, Environment_Access__c, Onboarding_Document__c, Lightning_Readiness_Check__c, Instance_Name__c, Marketing_Cloud_Instance_Name__c, Organization_ID__c, Salesforce_Products__c,Business_Overview__c,Customers__c,Key_Competitors__c,Collaborators_Partners__c,Compliance_Requirements__c,Current_Painpoints__c,Product_Backlog__c,Products_Services_Offered__c,Salesforce_Roadmap__c, Appexchange_Apps__c, Customer_Service__c, CPQ_Product__c, Marketing__c, Middleware__c, ERP__c, Document_Generation__c, External_Storage__c, Digital_Signature__c, Analytics__c, Backup__c, Project_Management__c, Development_Tools__c, Customer_Portal_Access_Status_Date__c, Setup_Weekly_MonthlyMeeting_Date__c, Environment_Access_Status_Date__c, Onboarding_Document_Status_Date__c, Lightning_Readiness_Check_Status_Date__c,Kickoff__c, KickOff_Completed_Date__c From Account Where ID = :accountId Limit 1];
        return accountList;
    }
    
    @AuraEnabled(cacheable=false)
    public static void updateCustomerInfo(String draftResponse,string accountId,string picklistValue,string proStatuspicklistValue,string sWpicklistValue,string schedulepicklistValue,string budgetpicklistValue,boolean allowTimesheet){
        try{
            List<Account> accountList=New List<Account>();
            List<Object> obList = (List<object>) json.deserializeUntyped(draftResponse);
            for(object ob : obList) 
            {
                Map<String, object> obmap = (Map<String, object>)ob;
                Account a=new Account();
                a.Id=accountId;
                a.Organization_ID__c=(string)obmap.get('orgId');
                a.Salesforce_Products__c=(string)obmap.get('salesforceProduct');
                a.Appexchange_Apps__c=(string)obmap.get('appexchangeApps');
                a.Customer_Portal_Access__c=(string)obmap.get('CustomerProtalAccess');
                a.Customer_Service__c=(string)obmap.get('customerService');
                string CPASDate=(string)obmap.get('customerPortalAccessStatusDate');
                if(string.isNotBlank(CPASDate)){
                    a.Customer_Portal_Access_Status_Date__c=Date.valueOf(CPASDate);
                }else{
                    a.Customer_Portal_Access_Status_Date__c=null;
                }
                a.CPQ_Product__c=(string)obmap.get('CPQProduct');
                a.Setup_Weekly_Monthly_Meeting__c=(string)obmap.get('SetupWeeklyMonthlyMeeting');
                a.Marketing__c=(string)obmap.get('Marketing');
                string SWMMDate=(string)obmap.get('setupWeeklyMonthlyMeetingDate');
                if(string.isNotBlank(SWMMDate)){
                    a.Setup_Weekly_MonthlyMeeting_Date__c=Date.valueOf(SWMMDate);
                }else{
                    a.Setup_Weekly_MonthlyMeeting_Date__c=null;
                }
                a.Middleware__c=(string)obmap.get('Middleware');
                a.Environment_Access__c=(string)obmap.get('EnvironmentAccess');
                a.ERP__c=(string)obmap.get('ERP');
                string EASDate=(string)obmap.get('EnvironmentAccessStatusDate');
                if(string.isNotBlank(EASDate)){
                    a.Environment_Access_Status_Date__c=Date.valueOf(EASDate);
                }else{
                    a.Environment_Access_Status_Date__c=null;
                }
                a.Document_Generation__c=(string)obmap.get('DocumentGenration');
                a.Onboarding_Document__c=(string)obmap.get('OnboardingDocument');
                a.External_Storage__c=(string)obmap.get('ExternalStorage');
                string OBDSDate=(string)obmap.get('OnboardingDocumentStatusDate');
                if(string.isNotBlank(OBDSDate)){
                    a.Onboarding_Document_Status_Date__c=Date.valueOf(OBDSDate);
                }else{
                    a.Onboarding_Document_Status_Date__c=null;
                }
                a.Digital_Signature__c=(string)obmap.get('DigitalSignature');
                a.Lightning_Readiness_Check__c=(string)obmap.get('LightningReadinessCheck');
                a.Analytics__c=(string)obmap.get('Analytics');
                string LRCSDate=(string)obmap.get('LightningReadinessCheckStatusDate');
                if(string.isNotBlank(LRCSDate)){
                    a.Lightning_Readiness_Check_Status_Date__c=Date.valueOf(LRCSDate);
                }else{
                    a.Lightning_Readiness_Check_Status_Date__c=null;
                }
                a.Backup__c=(string)obmap.get('Backup');
                a.Instance_Name__c=(string)obmap.get('InstanceName');
                a.Project_Management__c=(string)obmap.get('ProjectManagement');
                a.Marketing_Cloud_Instance_Name__c=(string)obmap.get('MarketingCloudInstanceName');
                a.Development_Tools__c=(string)obmap.get('DevelopmentTools');
                a.Has_Communities__c=(Boolean)obmap.get('hasCommunities');
                a.Customer_Engagement_Score__c=(string)obmap.get('CustomerEnagementScore');
                a.Business_Overview__c=(string)obmap.get('BusinessOverview');
                a.Products_Services_Offered__c=(string)obmap.get('ProductServicesOffered');
                a.Customers__c=(string)obmap.get('Customers');
                a.Key_Competitors__c=(string)obmap.get('KeyCompetitors');
                a.Collaborators_Partners__c=(string)obmap.get('CollaboratorsPartners'); 
                a.Compliance_Requirements__c=(string)obmap.get('ComplianceRequirements');
                a.Salesforce_Roadmap__c=(string)obmap.get('SalesforceRoadMap');
                a.Product_Backlog__c=(string)obmap.get('ProductBacklog');
                a.Current_Painpoints__c=(string)obmap.get('CurrentPainpoints');
                a.Digital_Signature__c=(string)obmap.get('DigitalSignature');
                a.Customer_Service__c=(string)obmap.get('customerService');
                a.Document_Generation__c=(string)obmap.get('DocumentGenration');
                string KickOffCompletedDate=(string)obmap.get('kickOffCompletedDate');
                if(string.isNotBlank(KickOffCompletedDate)){
                    a.KickOff_Completed_Date__c=Date.valueOf(KickOffCompletedDate);
                }else{
                    a.KickOff_Completed_Date__c=null;
                }
                a.Kickoff__c=(string)obmap.get('kickOffStatus');
                accountList.add(a);
            }
            if(!accountList.isEmpty()){
                update accountList;
            }
            List<Account_Services__c>  accountService; 
            accountService = [SELECT Allow_Future_Timesheets__c,Account__r.Name,ODS_Service_Name__c,Status_Report_Frequency__c,Project_Status_LV__c,Scope_of_Work_LV__c,Schedule_LV__c,Budget_LV__c, id FROM  Account_Services__c where Account__r.Id =: accountId limit 1];   
            if(!accountService.isEmpty()){
                Account_Services__c aser=new Account_Services__c();
                aser.Status_Report_Frequency__c=picklistValue;
                aser.Project_Status_LV__c=proStatuspicklistValue;
                aser.Scope_of_Work_LV__c=sWpicklistValue;
                aser.Schedule_LV__c=schedulepicklistValue;
                aser.Budget_LV__c=budgetpicklistValue;
                aser.Allow_Future_Timesheets__c=allowTimesheet;
                aser.id=accountService[0].id;
                update aser;
            }
        }catch(exception e){
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());   
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Account_Services__c> getAccountService(string accountId) {
        system.debug('accountId---'+accountId);
        return [SELECT Allow_Future_Timesheets__c,Account__r.Name,ODS_Service_Name__c,Status_Report_Frequency__c,Project_Status_LV__c,Scope_of_Work_LV__c,Schedule_LV__c,Budget_LV__c FROM  Account_Services__c where Account__c =: accountId limit 1 ];
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Schema.emailmessage> getAccountIncidents(string accountId)
    {
        list<Schema.emailmessage> incidentEmails=new list<Schema.emailmessage>();
        set<Id> incidentCaseId = new set<Id>();
        Account_Services__c  accountService; 
        accountService = [SELECT Account__r.Name,ODS_Service_Name__c,Status_Report_Frequency__c,Project_Status_LV__c,Scope_of_Work_LV__c,Schedule_LV__c,Budget_LV__c FROM  Account_Services__c where Account__r.Id =: AccountId limit 1];   
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
        return incidentEmails; 
    }
    
    @AuraEnabled(cacheable=false)
    public static Schema.emailmessage getEmail(string emailId)
    {
        Schema.emailmessage currentEmail=[select Id ,HTMLBody, Subject from emailmessage  where id=:emailId limit 1];
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
        system.debug('currentEmail.HTMLBody ---'+currentEmail.HTMLBody );
        return currentEmail;
    }
    
    @AuraEnabled(Cacheable=false)
    public static void updateSessionData(string accountId,string serviceId){
        ODS_Common_Utility.upsertSessionData(accountId,serviceId);  
    }
    
    @AuraEnabled(Cacheable=false)
    public static list<contact> getSalesforceAFDetails(string accountID){
        list<contact> contactList=new list<contact>();
        List<account> accountList=[Select id,Salesforce_AE_Name__c from account where ID=:accountID limit 1];
        if(!accountList.isEmpty()){
            contactList=[Select ID,Email,Dailer_Phone__c,Cell__c,Name from contact where id=:accountList[0].Salesforce_AE_Name__c limit 1];
        }
        return contactList;
    }
    
    @AuraEnabled(Cacheable=false)
    public static list<Case> getCases(string accountId, string serviceId){
        List<Account_Services__c> accService= ODS_Data_Utility.fetchAccServcesByAccAndSrv(accountId,serviceId);
        system.debug('accService : '+ accService);
        List<Case> cases = [Select id,CreatedDate,Release__c,Release_Date__c,Status From Case Where Account_Services__r.id =: accService[0].id AND Reason = 'Release Updates and Impact Analysis' AND Type = 'Release Update' AND (Status = 'Closed' or Status = 'Not Started' or Status = 'In Progress' or Status = 'Pending Customer Review') ORDER BY CreatedDate DESC];
        system.debug('cases:'+cases);
        
        return cases;
    }
    
    @AuraEnabled
    public static string updateCases(Object data){
        system.debug('In updateCases');
        system.debug('caseData : '+data);
        List<Case> updateCase = (List<Case>) JSON.deserialize(JSON.serialize(data), List<Case>.class);
        system.debug('updateCase : '+updateCase);
        if(updateCase != null && !updateCase.isEmpty()){
            update updateCase;
        }
        return 'Successfully updated!!';
    }   
    @AuraEnabled(Cacheable=false)
    public static void updateKickoffStatus(Date completedDate,string accountId){
        try{        
            String kickoffStatus = 'Completed';
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('accountId', accountId);
            requestBody.put('kickoffStatus', kickoffStatus);
            requestBody.put('completedDate', completedDate);
            
            String requestBodyJson = JSON.serialize(requestBody);
            system.debug('requestBodyJson-'+requestBodyJson);
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ODS_Org/services/apexrest/kickoff');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBodyJson);
            system.debug(request.getEndpoint());
            HttpResponse response = new Http().send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug('API call successful');
            } else {
                System.debug('API call failed with status code: ' + response.getStatusCode());
            }
        } catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    }
}