global class onBoardingDocumentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public string accountId ='';
    public onBoardingDocumentBatch(string accId){
        this.accountId=accId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id,Account_Id__c FROM ClientAndNamedCredMapping__mdt WHERE Is_Active__c=true AND Account_Id__c=:accountId');
    }
    global void execute(Database.BatchableContext BC, List<ClientAndNamedCredMapping__mdt> scope) {
        onBoardingDocumentAPIHelper apiHelper=new onBoardingDocumentAPIHelper();
        List<OBD_External_Data__c> insertOBDExternalData=new List<OBD_External_Data__c>();
        Set<id> accountIdSet=new Set<id>();
        Set<id> updateAccountIdSet=new Set<id>();
        Map<string,string> responseMap=new Map<string,string>();
        Map<string,string> failedResponseMap=new Map<string,string>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        
        for(ClientAndNamedCredMapping__mdt client:scope){
            accountIdSet.add(client.Account_Id__c);
        }
        
        system.debug('accountIdSet-'+accountIdSet);
        List<OBD_External_Data__c> getExistingOBD=[SELECT ID From OBD_External_Data__c WHERE Account__c IN: accountIdSet];
        List<Account> accountList=[Select Id from Account WHERE Id IN:accountIdSet AND Onboarding_Document__c='Not Started'];
        try{
            for(Account acc:accountList){
                updateAccountIdSet.add(acc.id);
                failedResponseMap=new map<string,string>();
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('SELECT ApexClassOrTrigger.Name,  NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate ORDER BY ApexClassOrTrigger.Name',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Apex Class'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Apex Class', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Description,License.Name,Name FROM PermissionSet',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Permission Set'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Permission Set', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Name FROM UserRole',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Role Hierarchy'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Role Hierarchy', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('SELECT Name, TableEnumOrId FROM WorkflowRule',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id,apiHelper.subString(string.valueOf(responseMap.values())), 'Work Flow Rules'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Work Flow Rules', responseMap.get('Error'));
                }
                
                //String responseProcessBuilder=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT ApiName,IsActive,Label,ProcessType FROM FlowDefinitionView','IsActive=true AND ProcessType = \'' + 'Workflow' + '\''));
                //insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, responseProcessBuilder, 'Process Builder'));
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Name,TableEnumOrId FROM ApexTrigger','Status = \'' + 'Active' + '\''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Apex Trigger'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Apex Trigger', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Name,TableEnumOrId FROM ProcessDefinition','State = \'' + 'Active' + '\' AND Type=\'' + 'Approval' + '\''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Approval Process'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Approval Process', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Queue.Name,SobjectType FROM QueueSobject',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Queue'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Queue', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('SELECT DeveloperName,Description FROM CustomObject',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Custom Objects'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Custom Objects', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT FolderName FROM EmailTemplate',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Email Folder'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Email Folder', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Product2.Name, Pricebook2.Name FROM PricebookEntry',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Price Book'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Price Book', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT ApiName,ProcessType FROM FlowDefinitionView','IsActive=true'));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Flow'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Flow', responseMap.get('Error'));
                }
                
                //String responseRenamedTabs=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('SELECT Label FROM TabDefinition','IsCustom=true'));
                //insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, responseRenamedTabs, 'Renamed Tabs'));
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Name FROM ApexPage',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Apex Pages'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Apex Pages', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Name FROM ApexComponent',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Apex Component'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Apex Component', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('Select MasterLabel,RecordType.Name,SobjectType,SobjectProcessField From PathAssistant','IsActive=true'));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Path'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Path', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('Select Name from AssignmentRule','SobjectType =\'' + 'Lead'+ '\' AND Active = true'));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Lead Assignment Rules'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Lead Assignment Rules', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('Select Name from AssignmentRule','SobjectType =\'' + 'Case'+ '\' AND Active = true'));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Case Assignment Rules'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Case Assignment Rules', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('Select Name From AutoResponseRule','EntityDefinitionId =\'' + 'Lead'+ '\' AND Active = true'));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Lead Auto Response Rules'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Lead Auto Response Rules', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('Select Name From AutoResponseRule','EntityDefinitionId =\'' + 'Case'+ '\' AND Active = true'));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Case Auto Response Rules'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Case Auto Response Rules', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Name FROM Network','Status =\'' + 'Live'+ '\''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Communities'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Communities', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT CronJobDetail.Name,State FROM CronTrigger',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'ScheduledJob'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('ScheduledJob', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Domain.Domain,Site.MasterLabel FROM DomainSite','Site.Status=\'' + 'Active'+ '\''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Site'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Site', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Domain FROM Domain',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Domain'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Domain', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Domain.Domain FROM DomainSite','Site.Status=\'' + 'Active'+ '\''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'CustomURLs'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('CustomURLs', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT DeveloperName FROM AuraDefinitionBundle',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Aura'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Aura', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('SELECT SubscriberPackageId, SubscriberPackage.NamespacePrefix,SubscriberPackage.Name,SubscriberPackage.Description FROM InstalledSubscriberPackage',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'AppExchange'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('AppExchange', responseMap.get('Error'));
                }
                
                //String responseForecasts=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Id FROM ForecastingCategoryMapping',''));
                //insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, responseForecasts, 'Forecasts'));
                
                //String responseEmailToCase=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT FunctionName,Id,IsActive FROM EmailServicesFunction','IsActive=true AND FunctionName=\'' + 'EmailToCase'+ '\''));
                //insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, responseEmailToCase, 'EmailToCase'));
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('SELECT Label,Description From CustomApplication',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'CustomAPP'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('CustomAPP', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'tooling/query', apiHelper.getQueryString('SELECT DeveloperName From OmniSupervisorConfig',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'OmniChannel'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('OmniChannel', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Description,DeveloperName FROM Report',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Report'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Report', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Id FROM AsyncApexJob','JobType =\'' + 'ScheduledApex' + '\' AND Status=\'' +'Queued'+ '\''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'ImportExport'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('ImportExport', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Account.Name, User.Name, TeamMemberRole FROM AccountTeamMember',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'AccountTeams'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('AccountTeams', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Name,TotalLicenses,UsedLicenses FROM UserLicense','Status=\'' +'Active'+ '\''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'UserLicenses'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('UserLicenses', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT MasterLabel,TotalLicenses,UsedLicenses FROM PermissionSetLicense','Status=\'' +'Active'+ '\''));
                system.debug('responseMap--->>>>>'+responseMap);
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'PermissionSetLicenses'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('PermissionSetLicenses', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT ActiveUserCount,FeatureType,TotalLicenseCount FROM ActiveFeatureLicenseMetric',''));
                system.debug('FeatureLicenses-'+apiHelper.subString(string.valueOf(responseMap.values())));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'FeatureLicenses'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('FeatureLicenses', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT InstanceName, IsSandbox FROM Organization',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Organization'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Organization', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'limits', apiHelper.getQueryString('',''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'Limits'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('Limits', responseMap.get('Error'));
                }
                
                responseMap=apiHelper.callAPITocheckForRecords(acc.id, 'query', apiHelper.getQueryString('SELECT Name FROM BusinessProcess','IsActive=true AND TableEnumOrId=\'' +'Case'+ '\''));
                insertOBDExternalData.add(apiHelper.prepareOBDRecord(acc.id, apiHelper.subString(string.valueOf(responseMap.values())), 'SupportProcess'));
                if(responseMap.containsKey('Error')){
                    failedResponseMap.put('SupportProcess', responseMap.get('Error'));
                }
                if(!failedResponseMap.isEmpty()){
                    mails.add(apiHelper.sendMailForFailedAPI(failedResponseMap,acc.id));
                }
            }
            system.debug('mails-'+mails);
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
            system.debug('updateAccountIdSet-'+updateAccountIdSet);
            system.debug('insertOBDExternalData-'+insertOBDExternalData.size());
            if(!insertOBDExternalData.isEmpty()){
                Database.SaveResult[] srList = Database.insert(insertOBDExternalData, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        if(!getExistingOBD.isEmpty()){
                            Database.DeleteResult[] drList = Database.delete(getExistingOBD, false);
                        }
                        List<Account> updateAccountList=new List<Account>();
                        for(Id accId:updateAccountIdSet){
                            Account objAccount=new Account();
                            objAccount.id=accId;
                            objAccount.Onboarding_Document__c='In Progress';
                            updateAccountList.add(objAccount);
                            apiHelper.sendMailForBatchJobCompletion(accId);
                        }
                        system.debug('updateAccountList--'+updateAccountList);
                        if(!updateAccountList.isEmpty()){
                            update updateAccountList;
                        }
                        break;
                        
                    }
                }
            }
        }catch(Exception e){
            system.debug('e.getMessage()-'+e.getMessage()+' at '+e.getLineNumber());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }
    global void finish(Database.BatchableContext BC){
    }
}