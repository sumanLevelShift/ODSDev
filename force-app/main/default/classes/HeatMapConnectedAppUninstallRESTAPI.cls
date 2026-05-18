@RestResource(urlMapping='/heatmapuninstall')
global class HeatMapConnectedAppUninstallRESTAPI {
    @HttpPost
    global static string heatMapUnistallRestApi(string orgBaseURL){        
        Heat_Map_Install_Request__c heatMap=new Heat_Map_Install_Request__c();
        heatMap.Customer_Org_URL__c=orgBaseURL;
        heatMap.Request_Type__c='Uninstall';
        insert heatMap;
        
        return heatMap.id;
    }
}