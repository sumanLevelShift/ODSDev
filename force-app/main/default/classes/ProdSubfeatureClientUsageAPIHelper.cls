/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             26-MAR-2021
* @Status           In-Progress
* @Class Name     	ProdSubfeatureClientUsageAPIHelper
* @description      This is a helper class for - ProdSubfeatureClientUsageHelper

*********************************************************************************************
Version     Date       Team          Comments
*********************************************************************************************
* 1      	Mar 2021    Suman          Initial Creation
*********************************************************************************************/
public class ProdSubfeatureClientUsageAPIHelper {
    
    @TestVisible 
    static Map<String, String> clientAndNamedCredMap { 
        get {
            if ( null == clientAndNamedCredMap || clientAndNamedCredMap.isEmpty() ){
                clientAndNamedCredMap = new Map<String,String>();
                
                List<ClientAndNamedCredMapping__mdt > metadataList = new List<ClientAndNamedCredMapping__mdt >();
                metadataList  = [SELECT Label, Account_Id__c , Named_Credentail__c from ClientAndNamedCredMapping__mdt where Is_Active__c=:true];
                for(ClientAndNamedCredMapping__mdt item : metadataList)
                    clientAndNamedCredMap.put(item.Account_Id__c, item.Named_Credentail__c);
            }
            return clientAndNamedCredMap;
        } set; 
    }
    
    public String callAPITocheckForRecords(String accountId, String apiName, String queryString){
        String username='';
        String consumerKey=''; 
        Boolean connectToSandbox=false; 
        Boolean runningInASandbox=false; 
        Boolean useConnectedApp=false;
        String customerOrgUrl=''; 
        try{
            Heat_Map_Connected_App__mdt connectedApp=[SELECT Certificate_Name__c,Consumer_Key__c,DeveloperName,Label FROM Heat_Map_Connected_App__mdt where DeveloperName=:Label.Heatmap_Connected_App ];
            ClientAndNamedCredMapping__mdt clientandNamed=[SELECT Connect_to_sandbox__c,Account_Id__c,Customer_Org_Url__c,DeveloperName,Id,Is_Active__c,Label,MasterLabel,Named_Credentail__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Account_Id__c =:accountId limit 1];
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            username=clientandNamed.Username__c;
            consumerKey=connectedApp.Consumer_Key__c;
            connectToSandbox=clientandNamed.Connect_to_sandbox__c;
            useConnectedApp=clientandNamed.Use_Connected_App__c;
            customerOrgUrl=clientandNamed.Customer_Org_Url__c;
            if(clientandNamed.Use_Connected_App__c==true){
                runningInASandbox=JWT_S2SAccessToken.runningInASandbox;
                if(clientandNamed.Connect_to_sandbox__c){
                    runningInASandbox=true;
                }
                JWT_S2SAccessToken jwtAccessToken=new JWT_S2SAccessToken(); 
                Auth.JWT jwt = jwtAccessToken.getAuthJWT(clientandNamed.Username__c, connectedApp.Consumer_Key__c,runningInASandbox);
                jwtAccessToken.addAuthorizationHeader(req, jwt,connectedApp.Certificate_Name__c,runningInASandbox);
                if(queryString==null){
                    req.setEndpoint(clientandNamed.Customer_Org_Url__c+'/services/data/v'+ Label.Heatmap_API_Version + '/'+ apiName.trim() + '/');
                    
                }else{
                    req.setEndpoint(clientandNamed.Customer_Org_Url__c+'/services/data/v'+ Label.Heatmap_API_Version + '/'+ apiName.trim() + '/?q=' + queryString);
                }
            }else{
                if(queryString==null){
                    req.setEndpoint('callout:' + getNamedCredForClient(accountId) + '/v'+ Label.Heatmap_API_Version + '/'+ apiName.trim() + '/');
                    
                }else { 
                    req.setEndpoint('callout:' + getNamedCredForClient(accountId) + '/v'+ Label.Heatmap_API_Version + '/'+ apiName.trim() + '/?q=' + queryString);
                }
            }
            req.setHeader('Content-Type','application/json');
            req.setMethod('GET');
            HTTPResponse res = http.send(req);
            String response=res.getBody();
            System.debug(response);
            //Integer recordCount = getRecCountFromHTTPResponseJSON(response);
            
            return response;
        }catch(Exception e){
            System.debug('System exception occured');
            System.debug('message -'+e.getMessage());
            System.debug('message st-'+e.getStackTraceString());
        	String errorMessage = 'ProdSubfeatureClientUsageAPIHelper Error Data: Username='+ username +', ConsumerKey='+ consumerKey +', ConnectToSandbox='+ connectToSandbox;
            errorMessage += ', RunningInASandbox='+ runningInASandbox +', UseConnectedApp='+ useConnectedApp +', CustomerOrgUrl='+ customerOrgUrl;
            errorMessage += ', ApiName='+ apiName +', QueryString='+ queryString +'; Error Message: '+ e.getMessage() +'; Stack Trace: '+ e.getStackTraceString();
            System.debug(errorMessage);
          	HeatMapLogController.insertHeatMapLog(accountId,errorMessage,'ProdSubfeatureClientUsageAPIHelper');
            return null;
        }
        
    }
    
    public String getNamedCredForClient(String clientId){
        system.debug('clientId--'+clientId);
        String namedCred = ProdSubfeatureClientUsage_Constants.STRING_EMPTY;
        if(clientAndNamedCredMap.containsKey(clientId))
            namedCred = clientAndNamedCredMap.get(clientId);
        return namedCred;
    }
}