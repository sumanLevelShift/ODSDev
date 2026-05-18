public class onBoardingDocumentAPIHelper {
    @TestVisible 
    static Map<String, String> clientAndNamedCredMap { 
        get {
            if ( null == clientAndNamedCredMap || clientAndNamedCredMap.isEmpty() ){
                clientAndNamedCredMap = new Map<String,String>();
                
                List<ClientAndNamedCredMapping__mdt > metadataList = new List<ClientAndNamedCredMapping__mdt >();
                metadataList  = [SELECT Label, Account_Id__c , Named_Credentail__c from ClientAndNamedCredMapping__mdt where Is_Active__c=:true];
                for(ClientAndNamedCredMapping__mdt item : metadataList){
                    clientAndNamedCredMap.put(item.Account_Id__c, item.Named_Credentail__c);
                }
            }
            return clientAndNamedCredMap;
        } set; 
    }
    
    public Map<string,string> callAPITocheckForRecords(String accountId, String apiName, String queryString){
        String username='';
        String consumerKey=''; 
        Boolean connectToSandbox=false; 
        Boolean runningInASandbox=false; 
        Boolean useConnectedApp=false;
        String customerOrgUrl=''; 
        Map<string,string> responseMap=new Map<string,string>();
        system.debug('queryString-'+queryString);
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
                req.setEndpoint(clientandNamed.Customer_Org_Url__c+'/services/data/v'+ Label.Heatmap_API_Version + '/'+ apiName.trim() + '/?q=' + queryString);
            }else{
                req.setEndpoint('callout:' + getNamedCredForClient(accountId) + '/v'+ Label.Heatmap_API_Version + '/'+ apiName.trim() + '/?q=' + queryString);
            }
            req.setHeader('Content-Type','application/json');
            req.setMethod('GET');
            HTTPResponse res = http.send(req);
            String response=res.getBody();
            System.debug(response);
            if (res.getStatusCode() == 200) {
                if (response.contains('errorCode')) {
                    responseMap.put('Error',response);                
                }else{
                    responseMap.put('Success',response);  
                }
           }            
        }catch(Exception e){
            //  System.debug('System exception occured');
            //System.debug('message -'+e.getMessage());
            //System.debug('message st-'+e.getStackTraceString());
            responseMap.put('Error',e.getMessage());
            //ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), '');
        }
        return responseMap;
    }
    public String getQueryString(String objQuery, String constraint){
        String queryString = '';
        if(String.isBlank(constraint)){
            queryString = objQuery;
        }else{
            queryString = objQuery + ProdSubfeatureClientUsage_Constants.QUERYSTRING_WHERE + constraint;
        }
        
        queryString = queryString.normalizeSpace().replace(ProdSubfeatureClientUsage_Constants.STRING_SPACE, ProdSubfeatureClientUsage_Constants.STRING_PLUS);
        queryString = queryString.replace(ProdSubfeatureClientUsage_Constants.STRING_PERCENT, ProdSubfeatureClientUsage_Constants.STRING_PERCENTENCODED);
        
        return queryString;
    }
    public OBD_External_Data__c prepareOBDRecord(string accountId, string apiResponse, string section){
        OBD_External_Data__c obd=new OBD_External_Data__c();
        obd.Account__c=accountId;
        obd.API_Response__c=apiResponse;
        obd.Section_Name__c=section;
        return obd;
    }
    Public Messaging.SingleEmailMessage sendMailForFailedAPI(Map<string,string> failedResponse,string accountId){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        User currentUser=[Select Id,Email,Name From User where Id=:UserInfo.getUserId() limit 1];
        list<string> toEmailList=new list<string>();
        toEmailList.add(currentUser.Email);
        Account accountRecord=[Select Id,Name From Account Where Id=:accountId];
        string accountName='';
        if(accountRecord !=null){
            accountName=accountRecord.Name;
        }
        email.setSubject('Onboarding Document Integration is failed for '+accountName);
        String body='Hi '+currentUser.Name+',<br/><br/>';
        body +='The following sections failed. Please review and add the content manually for the failure sections.<br/>';
        body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Section</th><th style=" border: 1px solid black;">Error Message</th></tr>';
        for(string section:failedResponse.keySet()){
            body +='<tr><td style=" border: 1px solid black;text-align:center;">'+section+'</td><td style=" border: 1px solid black;">'+failedResponse.get(section)+'</td></tr>';
        }
        body +='</table><br/><br/>';
        body +='Thanks,';
        body +='<br/><br/>LevelShift Customer Success Manager';
        email.setToAddresses(toEmailList);
        email.setHtmlBody(body);
        return email;
    }
    
    Public void sendMailForBatchJobCompletion(string accountId){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        User currentUser=[Select Id,Email,Name From User where Id=:UserInfo.getUserId() limit 1];
        list<string> toEmailList=new list<string>();
        toEmailList.add(currentUser.Email);
        Account accountRecord=[Select Id,Name From Account Where Id=:accountId];
        string accountName='';
        if(accountRecord !=null){
            accountName=accountRecord.Name;
        }
        email.setSubject('Onboarding Document Integration is Completed for '+accountName);
        String body='Hi '+currentUser.Name+',<br/><br/>';
        body +='The onboarding document for the <b>'+accountName+'</b> is available. Please generate it now.<br/><br/>';
        
        body +='Thanks,';
        body +='<br/>LevelShift Customer Success Manager';
        email.setToAddresses(toEmailList);
        email.setHtmlBody(body);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        mails.add(email);
        Messaging.sendEmail(mails);
    }
    
    public String getNamedCredForClient(String clientId){
        system.debug('clientId--'+clientId);
        String namedCred = ProdSubfeatureClientUsage_Constants.STRING_EMPTY;
        if(clientAndNamedCredMap.containsKey(clientId)){
            namedCred = clientAndNamedCredMap.get(clientId);
        }
        return namedCred;
    }
    public string subString(string response){
        return response.substring(1, response.length() - 1);
    }
}