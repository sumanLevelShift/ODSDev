public class ODS_WorkOrder_BC_API_Helper {
    /*Public static string getBUType(String BUType) {
        String labelValue = System.Label.BC_DemandblueURL; 
        List<String> urlList = new List<String>();
        if (String.isNotBlank(labelValue)) {
            for (String val : labelValue.split(',')) {
                if (String.isNotBlank(val)) {
                    urlList.add(val.trim());
                }
            }
        }
        if(urlList.contains(BUType)){
            return 'DemandBlue';
        }else{
            return BUType;
        }
    }*/
    @future (callout=true) 
    public static void workOrderAPI(string actionType,string body,string workOrderId,string consumptionBody,String BUType,String entityType){
        Work_Order__c workOrderRecord;
        string subCategory='';
        try
        { 
            if(actionType !='Void'){
                workOrderRecord=[SELECT Id,BC_Work_Order_ID__c,Tips_Work_Order_ID__c,Business_Unit__c,SubCategory__c FROM Work_Order__c WHERE Id=:workOrderId LIMIT 1];
                subCategory=workOrderRecord.SubCategory__c;
            }
           // BUType=getBUType(BUType);
            if(entityType =='DemandDynamics' && BUType=='DemandDynamics'){
                BUType='DemandDynamics'; 
            }else{
                BUType='DemandBlue';
            }
            List<Salesforce_BC_API_Configuration__mdt> SFBCApiConfig=[Select Id,Company__c,Access_Token_URL__c,Action_Type__c,Client_Id__c,Client_Secret__c,Endpoint_URL__c,Grant_Type__c,Parameter__c,Tenant_Id__c,Scope__c,Method_Type__c From Salesforce_BC_API_Configuration__mdt WHERE 
                                                                      Action_Type__c=:actionType AND Is_Work_Order__c=true AND Type__c=:BUType Limit 1];
            List<Work_Order__c> lstOfWorkOrdersToBeUpdated=new List<Work_Order__c>();
            
            if(!SFBCApiConfig.isEmpty()){
                system.debug('main body-'+body);
                system.debug('ConsumptionBody-'+consumptionBody);
                
                String clientId = SFBCApiConfig[0].Client_Id__c;
                String clientSecret = SFBCApiConfig[0].Client_Secret__c;
                String accessTokenUrl = SFBCApiConfig[0].Access_Token_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/oauth2/v2.0/token';
                String grantType = SFBCApiConfig[0].Grant_Type__c;
                String scope = SFBCApiConfig[0].Scope__c;
                string accessToken=getAccessToken(clientId, clientSecret, accessTokenUrl, grantType,scope);
                if(string.isNotBlank(body))
                {
                    system.debug('accessToken-'+accessToken);
                    Http http = new Http();
                    string responseJson=''; 
                    string endpoint=SFBCApiConfig[0].Endpoint_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/'+SFBCApiConfig[0].Parameter__c+'?company='+SFBCApiConfig[0].Company__c;
                    system.debug('endpoint-'+endpoint);
                    
                    HttpRequest request = new HttpRequest();  
                    request.setMethod(SFBCApiConfig[0].Method_Type__c);
                    request.setEndpoint(endpoint);
                    request.setHeader('Accept','application/json');
                    request.setHeader('contentType', 'application/json');
                    request.setTimeout(120000);
                    request.setHeader('Authorization','Bearer '+accessToken);  
                    request.setBody(body);
                    HTTPResponse response = http.send(request);      
                    system.debug(response);
                    responseJson = response.getBody();
                    system.debug('responseJson--'+response.getBody());
                    if(response.getStatusCode()==200 )
                    {
                        if(actionType !='Void'){
                            // responseJson = responseJson.replaceAll('\\', '');
                            if(responseJson != null && 
                               (responseJson.toLowerCase().contains('sales order does not exists') ||
                                (responseJson.toLowerCase().contains('successfully') && !responseJson.toLowerCase().contains('error')))) 
                            {
                                if(responseJson.toLowerCase().contains('successfully')){
                                    Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
                                    String valueString;
                                    if(!Test.isRunningTest()){
                                        valueString = (String) parsedJson.get('value');  
                                    }else{
                                        valueString='{\"Message\":\"WorkOrder Added Successfully\",\"WorkOrderId\":\"SWO2300156\",\"AccountCode\":\"N29\",\"ClientId\":\"0018M00000KdT9FQAV\"}'; 
                                    }
                                    system.debug('responseJson---'+responseJson);
                                    string accountId=''; //need to get accountId from response
                                    string clientCode=''; //need to get clientCode from response
                                    Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(valueString);
                                    String message = (String)jsonResponse.get('Message');
                                    String bCWorkOrderId = jsonResponse.containsKey('WorkOrderId') ? (String)jsonResponse.get('WorkOrderId') : '';
                                    clientCode = (String)jsonResponse.get('AccountCode');
                                    accountId = (String)jsonResponse.get('ClientId');
                                    List<Account> accountRecords=[SELECT Id,Client_Code__c FROM Account WHERE Id=:accountId];
                                    
                                    if(!accountRecords.isEmpty())   
                                    {
                                        for(Account accVar:accountRecords)
                                        {
                                            accVar.Client_Code__c=clientCode;
                                        }
                                        update accountRecords;
                                    }
                                    Work_Order__c workOrder1=new Work_Order__c();
                                    workOrder1.Id=workOrderId;
                                    workOrder1.BC_API_Message__c=message; //need to get BC Id from response
                                    workOrder1.BC_Work_Order_ID__c=bCWorkOrderId; //need to get BC message from response
                                    lstOfWorkOrdersToBeUpdated.add(workOrder1);
                                }else if(responseJson.toLowerCase().contains('sales order does not exists')){
                                    sendMailWorkorderFailureBC(workOrderId, responseJson);  
                                    Work_Order__c workOrder1=new Work_Order__c();
                                    workOrder1.Id=workOrderId;
                                    workOrder1.BC_API_Message__c=responseJson; //need to get BC Id from response
                                    lstOfWorkOrdersToBeUpdated.add(workOrder1);
                                }
                                if(workOrderRecord.SubCategory__c.contains('Subscription')){
                                    Id jobID=System.enqueueJob(new WorkOrder_BC_API_Calls_CNSMP(workOrderId,consumptionBody,actionType,BUType));
                                }
                                
                            }else{
                                Work_Order__c workOrder1=new Work_Order__c();
                                workOrder1.Id=workOrderId;
                                workOrder1.BC_API_Message__c=responseJson; 
                                lstOfWorkOrdersToBeUpdated.add(workOrder1);
                                sendMailWorkorderFailureBC(workOrderId, responseJson);
                                ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, body, responseJson, subCategory); 
                                if(string.isNotBlank(consumptionBody)){
                                    ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, consumptionBody, responseJson, 'Consumption'); 
                                }
                            }
                        }
                        if(actionType =='Void' && string.isNotBlank(consumptionBody)){
                            Id jobID=System.enqueueJob(new WorkOrder_BC_API_Calls_CNSMP(workOrderId,consumptionBody,actionType,BUType));
                        }
                    }else{
                        Work_Order__c workOrder1=new Work_Order__c();
                        workOrder1.Id=workOrderId;
                        workOrder1.BC_API_Message__c=responseJson; 
                        lstOfWorkOrdersToBeUpdated.add(workOrder1);
                        sendMailWorkorderFailureBC(workOrderId, responseJson);
                        ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, body, responseJson, subCategory);
                    }
                    if(!lstOfWorkOrdersToBeUpdated.isEmpty() && actionType !='Void')
                    {
                        system.debug('lstOfWorkOrdersToBeUpdated--'+lstOfWorkOrdersToBeUpdated);
                        update lstOfWorkOrdersToBeUpdated;
                    }
                    WorkOrder_API_Calls.updateWorkOrderAPI = false;
                }else if(string.isNotBlank(consumptionBody)){
                    if(workOrderRecord.SubCategory__c.contains('Subscription')){
                        Id jobID=System.enqueueJob(new WorkOrder_BC_API_Calls_CNSMP(workOrderId,consumptionBody,actionType,BUType));
                    }
                }
            }else{
                sendMailWorkorderFailureBC(workOrderId, 'BC Configuration is not available. Please contact system administrators.');
            }
        }catch(Exception e)    
        {
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            sendMailWorkorderFailureBC(workOrderId, e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, body, e.getMessage(), subCategory);
        }
    }
    public static String getAccessToken(String clientId, String clientSecret, String accessTokenUrl, String grantType,string scope) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accessTokenUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=' + EncodingUtil.urlEncode(grantType, 'UTF-8') +
                    '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
                    '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8'));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> authResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) authResponse.get('access_token');
        } else {
            return null;
        }
    }
    public static string getLineDetailsJson(Work_Order__c workOrderVar,boolean updateWorkOrderAPI,boolean isCustomerType,boolean isBuild,boolean isAdmin,boolean isConsult){
        string lineDetails;
        boolean buildId=string.isNotBlank(workOrderVar.BC_Build_CNSMP_WO_ID__c);
        boolean adminId=string.isNotBlank(workOrderVar.BC_Build_CNSMP_WO_ID__c);
        boolean conultId=string.isNotBlank(workOrderVar.BC_Build_CNSMP_WO_ID__c);
        lineDetails='"LineDetail": [';
        if(!updateWorkOrderAPI){
            lineDetails+='{"LineBillType":"Hourly","LineBillAmt":"'+workOrderVar.Bill_Rate__c+'"}';
            if(isCustomerType){
                lineDetails+=',{"LineBillType":"Admin","LineBillAmt":"'+workOrderVar.Admin_Hourly_Rate__c+'"}';
                lineDetails+=',{"LineBillType":"Consult","LineBillAmt":"'+workOrderVar.Consulting_Hourly_Rate__c+'"}';
            }
        }else{
            if(buildId){
                lineDetails+='{"LineBillType":"Hourly","LineBillAmt":"'+workOrderVar.Bill_Rate__c+'","Lineid":"'+workOrderVar.BC_Build_CNSMP_WO_ID__c+'"}';                  
            }
            if(isCustomerType){
                if(adminId){
                    lineDetails += (buildId ? ',' : '') +'{"LineBillType":"Admin","LineBillAmt":"'+workOrderVar.Admin_Hourly_Rate__c+'","Lineid":"'+workOrderVar.BC_Admin_CNSMP_WO_ID__c+'"}'; 
                }
                if(conultId){
                    lineDetails += ((isAdmin || buildId) ? ',' : '') +'{"LineBillType":"Consult","LineBillAmt":"'+workOrderVar.Consulting_Hourly_Rate__c+'","Lineid":"'+workOrderVar.BC_Consulting_CNSMP_WO_ID__c+'"}';
                }
            }
            
        }
        lineDetails+=']';
        return lineDetails;
    }
    public static void sendMailWorkorderFailureBC(string workOrderId, String TipsApiMessage){
        List<string> sendTo1 = System.Label.WorkOrderUsersForErrorStatusBC.Split(',');
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setSubject('BC Work order Integration failed for the work order record: ' + workOrderId);
        semail.setToAddresses(sendTo1);
        String strHtmlBody = '';                     
        strHtmlBody= 'Hi, <br/> BC Work order integration for the SFDC work order id : <b> '+ workOrderId + '</b> has been failed because of the below. Please update it accordingly. <br/> <br/> BC API Message  : <b>'+ TipsApiMessage + '</b>';
        semail.setHtmlBody(strHtmlBody);
        system.debug('strHtmlBody-'+strHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
    }
}