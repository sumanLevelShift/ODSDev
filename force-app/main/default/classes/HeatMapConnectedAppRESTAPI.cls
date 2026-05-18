@RestResource(urlMapping='/heatmapinstall')
global class HeatMapConnectedAppRESTAPI {
    @HttpPost
    global static string heatMapRestApi(string username, string orgBaseURL, string orgId, boolean isSandbox){
        Heat_Map_Install_Request__c heatMap=new Heat_Map_Install_Request__c();
        heatMap.Username__c=username;
        heatMap.Customer_Org_URL__c=orgBaseURL;
        heatMap.Organization_Id__c=orgId;
        heatMap.Is_Sandbox__c = isSandbox;
        insert heatMap;
        
        return heatMap.id;        
    }
}