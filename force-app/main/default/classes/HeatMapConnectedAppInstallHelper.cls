global without sharing class HeatMapConnectedAppInstallHelper {
    @AuraEnabled  
    public static void getHeatMap(string recId) {
        system.debug('recId---'+recId);
        
        //For record type is install
        list<Heat_Map_Install_Request__c> heatMapRecordListForInstall=[SELECT Organization_Id__c,Username__c,
                                                                       Customer_Org_URL__c,Id,Name,Request_Type__c,
                                                                       Status__c,Is_Sandbox__c 
                                                                       FROM Heat_Map_Install_Request__c 
                                                                       where Request_Type__c =:'Install' and 
                                                                       Status__c=:'New' And id=:recId];
        if(!heatMapRecordListForInstall.isEmpty()){
            HeatMapConnectedAppInstallHelper.getHeatMapInstallRequest(heatMapRecordListForInstall);
        }
        
        //For record type is uninstall
        list<Heat_Map_Install_Request__c> heatMapRecordListForUninstall=[SELECT Organization_Id__c,Username__c,
                                                                         Customer_Org_URL__c,Id,Name,Request_Type__c,
                                                                         Status__c,Is_Sandbox__c 
                                                                         FROM Heat_Map_Install_Request__c 
                                                                         where Request_Type__c =:'Uninstall' and 
                                                                         Status__c=:'New' And id=:recId];
        if(!heatMapRecordListForUninstall.isEmpty()){
            HeatMapConnectedAppUninstallHelper.getHeatMapUninstall(heatMapRecordListForUninstall);
        }
    }
    webservice static void getHeatMapForClassic(string recId) {
        getHeatMap(recId);
    }
    public static string accountDetails(string orgId){
        try{
            string organizationId=orgId.substring(0,15);
            Account acc=[Select Id From Account where Organization_ID__c=:organizationId OR Organization_ID__c=:orgId];
            return acc.id;
        }catch(exception e){
            return 'NOT_FOUND';
        }
        
    }
    public static void getHeatMapInstallRequest(list<Heat_Map_Install_Request__c> heatMapRecordListForInstall){
        
        for(Heat_Map_Install_Request__c hm:heatMapRecordListForInstall){
            string accid=accountDetails(hm.Organization_Id__c);
            list<ClientAndNamedCredMapping__mdt> clientandNameCredList=[SELECT Account_Id__c,Customer_Org_Url__c,
                                                                        DeveloperName,Id,Is_Active__c,Label,Language,
                                                                        Last_Run_Date_Time__c,MasterLabel,
                                                                        Named_Credentail__c,NamespacePrefix,
                                                                        Next_Run_Date_Time__c,QualifiedApiName,
                                                                        Schedule_Frequency__c,Username__c,
                                                                        Use_Connected_App__c,Connect_to_sandbox__c 
                                                                        FROM ClientAndNamedCredMapping__mdt 
                                                                        where Username__c=:hm.Username__c ];
            if(!clientandNameCredList.isEmpty()){
                updateCustomMetaData(hm.Username__c,hm.Customer_Org_URL__c,clientandNameCredList,hm,accid);  
            }else{
                createCustomMetaData(hm.Username__c,hm.Customer_Org_URL__c,hm,accid);                
            }
        }
        
    }
    @future
    private static void updateStatusToCompleted(id heatMapRecordId){
        list<Heat_Map_Install_Request__c> updateList=new list<Heat_Map_Install_Request__c>();
        list<Heat_Map_Install_Request__c> heatMapRecordListForInstall=[SELECT Customer_Org_URL__c,Id,Name,
                                                                       Request_Type__c,Status__c 
                                                                       FROM Heat_Map_Install_Request__c 
                                                                       where id=:heatMapRecordId];
        for(Heat_Map_Install_Request__c h:heatMapRecordListForInstall){
            Heat_Map_Install_Request__c hm=new Heat_Map_Install_Request__c();
            hm.id=h.id;
            hm.Status__c='Completed';
            updateList.add(hm);
        }
        update updateList;
    }
    public static void updateCustomMetaData(string username,string orgURL,list<ClientAndNamedCredMapping__mdt> clientandNameCredList,Heat_Map_Install_Request__c heatMapRecord,string accId){
        id jobId=null;          
        
        for(ClientAndNamedCredMapping__mdt clientandNameCred:clientandNameCredList){
            String nameSpacePrefix = '';
            
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = nameSpacePrefix + 'ClientAndNamedCredMapping.'+clientandNameCred.DeveloperName;
            customMetadata.label = clientandNameCred.Label;
            
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'Customer_Org_Url__c';
            customField.value = orgURL;
            customMetadata.values.add(customField);
            mdContainer.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
            customField1.field = 'Is_Active__c';
            customField1.value = true;
            customMetadata.values.add(customField1);
            mdContainer.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
            customField2.field = 'Account_Id__c';
            customField2.value = accId;
            customMetadata.values.add(customField2);
            mdContainer.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
            customField3.field = 'Use_Connected_App__c';
            customField3.value = true;
            customMetadata.values.add(customField3);
            mdContainer.addMetadata(customMetadata);
            
            if(!Test.isRunningTest()){
                jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            }
        }
        updateStatusToCompleted(heatMapRecord.id);
        
    }
    public static void createCustomMetaData(string username,string orgURL,Heat_Map_Install_Request__c heatMapRecord,string accId){
        
        String nameSpacePrefix = '';
        String regExp = '[^\\w\\s]';
        string devName=username.replaceAll(regExp,'_');
        system.debug('heatMapRecord-'+heatMapRecord);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = nameSpacePrefix + 'ClientAndNamedCredMapping.'+devName;
        customMetadata.label = username;  
        
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'Customer_Org_Url__c';
        customField.value = orgURL;
        customMetadata.values.add(customField);
        mdContainer.addMetadata(customMetadata);
        
        Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
        customField1.field = 'Is_Active__c';
        customField1.value = true;
        customMetadata.values.add(customField1);
        mdContainer.addMetadata(customMetadata);
        
        Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
        customField2.field = 'Username__c';
        customField2.value = username;
        customMetadata.values.add(customField2);
        mdContainer.addMetadata(customMetadata);
        
        Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
        customField3.field = 'Use_Connected_App__c';
        customField3.value = true;
        customMetadata.values.add(customField3);
        mdContainer.addMetadata(customMetadata);
        
        Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue();
        customField4.field = 'Account_Id__c';
        customField4.value = accId;
        customMetadata.values.add(customField4);
        mdContainer.addMetadata(customMetadata);
        
        Metadata.CustomMetadataValue customField5 = new Metadata.CustomMetadataValue();
        customField5.field = 'Connect_to_sandbox__c';
        customField5.value = heatMapRecord.Is_Sandbox__c;
        customMetadata.values.add(customField5);
        mdContainer.addMetadata(customMetadata);
        
        id jobId=null;          
        if(!Test.isRunningTest()){
            jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
        }
        updateStatusToCompleted(heatMapRecord.id);
        remoteSiteSetting(orgURL);
        if(accId !='NOT_FOUND'){
            /*HeatMapRecordsSchedular HM=new HeatMapRecordsSchedular(accId);
            HM.execute(null);*/
            SalesforceProductHelper.fetchSalesforceProductAfterAccountSelect(accId);
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 5); 
            String ss = String.valueOf(Datetime.now().second());
            
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            
            HeatMapRecordsSchedular HM=new HeatMapRecordsSchedular(accId); 
            System.schedule('HeatMap Request From ConApp For '+accId, nextFireTime, HM);
        }
    }
    @future(callout = true)
    public static void remoteSiteSetting(string orgBaseUrl){
        CreateRemoteSiteSettings.createRemoteSitess(orgBaseUrl, 'This remote site is created from apex rest api class', true, false);
    }
}