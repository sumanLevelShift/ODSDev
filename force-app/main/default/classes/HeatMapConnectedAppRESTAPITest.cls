@isTest
public class HeatMapConnectedAppRESTAPITest {
    @isTest
    public static void testRestApi(){
        
        Heat_Map_Install_Request__c heatMap=new Heat_Map_Install_Request__c();
        heatMap.Username__c='sfadmin@demandblue.com';
        heatMap.Customer_Org_URL__c='https://demandblue--ODSDEV.my.salesforce.com';
        heatMap.Request_Type__c='Install';
        heatMap.Status__c='New';
        heatMap.Is_Sandbox__c=true;
        insert heatMap;
        
        Heat_Map_Install_Request__c heatMap1=new Heat_Map_Install_Request__c();
        heatMap1.Username__c='sfadmin@demandblue1.com.ODSUAT';
        heatMap1.Customer_Org_URL__c='https://demandblue--ODSUAT.my.salesforce.com';
        heatMap1.Organization_Id__c=userinfo.getOrganizationId();
        insert heatMap1;
        
        Heat_Map_Install_Request__c heatMap2=new Heat_Map_Install_Request__c();
        heatMap2.Username__c='sfadmin@demandblue.com';
        heatMap2.Customer_Org_URL__c='https://demandblue--ODSDEV.my.salesforce.com';
        insert heatMap2;
        
        ClientAndNamedCredMapping__mdt clientandNameCred=[SELECT Account_Id__c,Customer_Org_Url__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Customer_Org_Url__c !=:NULL Limit 1];
        Heat_Map_Install_Request__c heatMap3=new Heat_Map_Install_Request__c();
        heatMap3.Customer_Org_URL__c=clientandNameCred.Customer_Org_Url__c;
        heatMap3.Request_Type__c='Uninstall';
        heatMap.Status__c='New';
        heatMap.Is_Sandbox__c=true;
        insert heatMap3;
        
        
        HeatMapConnectedAppRESTAPI reqst=new HeatMapConnectedAppRESTAPI();
        String JsonMsg=JSON.serialize(reqst);
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/heatmapinstall';
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        HeatMapConnectedAppInstallHelper.getHeatMap(heatMap1.id);
        HeatMapConnectedAppInstallHelper.getHeatMapForClassic(heatMap1.id);
        HeatMapConnectedAppRESTAPI.heatMapRestApi(heatMap.Username__c,heatMap.Customer_Org_URL__c,userinfo.getOrganizationId(),true);
        HeatMapConnectedAppUninstallRESTAPI.heatMapUnistallRestApi(heatMap1.Customer_Org_URL__c);
        HeatMapConnectedAppSchedular sch=new HeatMapConnectedAppSchedular();
        sch.execute(null);
        // ClientAndNamedCredMapping__mdt clientandNameCred=[SELECT Account_Id__c,Customer_Org_Url__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt Limit 1];
        
        // HeatMapConnectedAppRESTAPI.updateCustomMetaData(clientandNameCred.Username__c, 'url');
        system.assertEquals(heatMap.Status__c, 'New');
        Test.stopTest();
    }
    @isTest
    public static void testRestApiv1(){
        HeatMapConnectedAppRESTAPI reqst=new HeatMapConnectedAppRESTAPI();
        String JsonMsg=JSON.serialize(reqst);
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/heatmapinstall';
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        HeatMapConnectedAppRESTAPI.heatMapRestApi('sfadmin@demandblue.com','test',userinfo.getOrganizationId(),true);
        list<ClientAndNamedCredMapping__mdt> clientandNameCred=[SELECT Account_Id__c,Customer_Org_Url__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Account_Id__c !=:'NEW'Limit 1];
        
        Heat_Map_Install_Request__c heatMap=new Heat_Map_Install_Request__c();
        heatMap.Username__c=clientandNameCred[0].Username__c;
        heatMap.Customer_Org_URL__c=clientandNameCred[0].Username__c;
        insert heatMap;
        
        HeatMapConnectedAppRESTAPI.heatMapRestApi(clientandNameCred[0].Username__c,'url',userinfo.getOrganizationId(),true);
        HeatMapConnectedAppInstallHelper.updateCustomMetaData(clientandNameCred[0].Username__c,clientandNameCred[0].Customer_Org_Url__c,clientandNameCred,heatMap,clientandNameCred[0].Account_Id__c);
        system.assertEquals(heatMap.Username__c, clientandNameCred[0].Username__c);
        Test.stopTest();
    }
}