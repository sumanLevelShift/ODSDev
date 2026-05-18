@isTest
public class HeatMapConnectedAppStatusTest {
    @isTest
    public static void testHeatMapConnectedAppStatus(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/heatmapstatus';
        req.httpMethod = 'GET';
        req.addParameter('orgBaseURL','https://test.salesforce.com');
        
        RestContext.request = req;
        RestContext.response= res;
        test.startTest();
        HeatMapConnectedAppStatus.checkActivationStatus();
        system.assertEquals(req.httpMethod , 'GET');
        test.stopTest();
    }
    
}