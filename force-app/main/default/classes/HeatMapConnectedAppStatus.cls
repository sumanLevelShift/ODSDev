@RestResource(urlMapping='/heatmapstatus')
global class HeatMapConnectedAppStatus {
    @HttpGet
    global static Boolean checkActivationStatus(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String orgBaseURL = req.params.get('orgBaseURL');
        
        System.Debug('orgBaseURL: ' + orgBaseURL);
        
        List<ClientAndNamedCredMapping__mdt> customerOrg = [SELECT Customer_Org_Url__c, Id, Is_Active__c,Use_Connected_App__c 
                                                            FROM ClientAndNamedCredMapping__mdt 
                                                            WHERE Customer_Org_Url__c=:orgBaseURL AND Is_Active__c = True 
                                                            AND Use_Connected_App__c = True];
        if(customerOrg.isEmpty()){
            return False;
        }
        return True;
    }
}