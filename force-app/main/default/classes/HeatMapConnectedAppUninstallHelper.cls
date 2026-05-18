public class HeatMapConnectedAppUninstallHelper {
    public static void getHeatMapUninstall(list<Heat_Map_Install_Request__c> heatMapRecordListForUninstall){
        
        for(Heat_Map_Install_Request__c hm:heatMapRecordListForUninstall){
            for(ClientAndNamedCredMapping__mdt clientandNameCred:[SELECT Account_Id__c,Customer_Org_Url__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Customer_Org_Url__c=:hm.Customer_Org_URL__c]){
                String nameSpacePrefix = '';
                
                Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                
                Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                customMetadata.fullName = nameSpacePrefix + 'ClientAndNamedCredMapping.'+clientandNameCred.DeveloperName;
                customMetadata.label = clientandNameCred.Label;
                
                
                Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
                customField1.field = 'Is_Active__c';
                customField1.value = false;
                customMetadata.values.add(customField1);
                mdContainer.addMetadata(customMetadata);
                
                
                Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
                customField3.field = 'Use_Connected_App__c';
                customField3.value = false;
                customMetadata.values.add(customField3);
                mdContainer.addMetadata(customMetadata);
                
                
                if(!Test.isRunningTest())
                    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
                updateStatusToCompleted(hm.id);
            }
        }
    }
    @future
    private static void updateStatusToCompleted(id heatMapRecordId){
        list<Heat_Map_Install_Request__c> updateList=new list<Heat_Map_Install_Request__c>();
        list<Heat_Map_Install_Request__c> heatMapRecordListForInstall=[SELECT Customer_Org_URL__c,Id,Name,Request_Type__c,Status__c FROM Heat_Map_Install_Request__c where id=:heatMapRecordId];
        for(Heat_Map_Install_Request__c h:heatMapRecordListForInstall){
            Heat_Map_Install_Request__c hm=new Heat_Map_Install_Request__c();
            hm.id=h.id;
            hm.Status__c='Completed';
            updateList.add(hm);
        }
        update updateList;
    }
}