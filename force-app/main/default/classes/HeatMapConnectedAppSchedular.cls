global class HeatMapConnectedAppSchedular implements Schedulable, Database.AllowsCallouts{
    
    global void execute(SchedulableContext sc) {
        
        //For record type is install
        list<Heat_Map_Install_Request__c> heatMapRecordListForInstall=[SELECT Is_Sandbox__c,Organization_Id__c,Username__c,Customer_Org_URL__c,Id,Name,Request_Type__c,Status__c FROM Heat_Map_Install_Request__c where Request_Type__c =:'Install' and Status__c=:'New'];
        if(!heatMapRecordListForInstall.isEmpty()){
            HeatMapConnectedAppInstallHelper.getHeatMapInstallRequest(heatMapRecordListForInstall);
        }
        
        //For record type is uninstall
        list<Heat_Map_Install_Request__c> heatMapRecordListForUninstall=[SELECT Is_Sandbox__c,Organization_Id__c,Username__c,Customer_Org_URL__c,Id,Name,Request_Type__c,Status__c FROM Heat_Map_Install_Request__c where Request_Type__c =:'Uninstall' and Status__c=:'New'];
        if(!heatMapRecordListForUninstall.isEmpty()){
            HeatMapConnectedAppUninstallHelper.getHeatMapUninstall(heatMapRecordListForUninstall);
        }
    }
}