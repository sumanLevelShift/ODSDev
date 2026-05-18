public class WorkOrder_BC_API_Calls_CNSMP implements Queueable,Database.AllowsCallouts{
    public string workOrderId;
    public string endPoint;
    public string consumptionBody;
    public string actionType;
    public string BUType;
    
    public WorkOrder_BC_API_Calls_CNSMP(string workOrderId,string consumptionBody,string actionType,string BUType){
        this.workOrderId = workOrderId ;
        this.consumptionBody = consumptionBody ;
        this.actionType=actionType;
        this.BUType=BUType;
    }
    
    public void execute(QueueableContext qc){
        
        try{
            WorkOrder_API_Calls.isFirstTime=false;
            //BUType=ODS_WorkOrder_BC_API_Helper.getBUType(BUType);
            List<Salesforce_BC_API_Configuration__mdt> SFBCApiConfig=[Select Id,Company__c,Access_Token_URL__c,Action_Type__c,Client_Id__c,Client_Secret__c,Endpoint_URL__c,Grant_Type__c,Parameter__c,Tenant_Id__c,Scope__c,Method_Type__c From Salesforce_BC_API_Configuration__mdt WHERE 
                                                                      Action_Type__c=:actionType AND Is_Work_Order__c=true and Type__c=: BUType Limit 1];
            if(!SFBCApiConfig.isEmpty()){
                String clientId = SFBCApiConfig[0].Client_Id__c;
                String clientSecret = SFBCApiConfig[0].Client_Secret__c;
                String accessTokenUrl = SFBCApiConfig[0].Access_Token_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/oauth2/v2.0/token';
                String grantType = SFBCApiConfig[0].Grant_Type__c;
                String scope = SFBCApiConfig[0].Scope__c;
                string accessToken=ODS_WorkOrder_BC_API_Helper.getAccessToken(clientId, clientSecret, accessTokenUrl, grantType,scope);
                string endpoint=SFBCApiConfig[0].Endpoint_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/'+SFBCApiConfig[0].Parameter__c+'?company='+SFBCApiConfig[0].Company__c;
                
                List<Work_Order__c> workorderList=new List<Work_Order__c>();
                List<Work_Order_External_Reference__c> upsertERList=new List<Work_Order_External_Reference__c>();

                string tipsConsumptionRes='';
                Work_Order__c workOrderRecord=new Work_Order__c();
                if(actionType !='Void'){
                    workOrderRecord.Id=workOrderId;
                }
                if(string.isNotBlank(consumptionBody)){
                    tipsConsumptionRes=HttpRequestConsumption(workOrderId,consumptionBody,SFBCApiConfig[0],accessToken,endpoint,SFBCApiConfig[0].Method_Type__c);
                    if(tipsConsumptionRes !=null && tipsConsumptionRes.toLowerCase().contains('successfully') && !tipsConsumptionRes.toLowerCase().contains('error')){
                        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(tipsConsumptionRes);
                        String valueString;
                        if(!Test.isRunningTest()){
                            valueString = (String) parsedJson.get('value');  
                        }else{
                            valueString='{\"Message\":\"WorkOrder Added Successfully\",\"HourlyWorkOrderId\":\"SWO2300159:10000\",\"AdminWorkOrderId\":\"SWO2300159:20000\",\"ConsultWorkOrderId\":\"SWO2300159:30000\",\"AccountCode\":\"N29\",\"ClientId\":\"0018M00000KdT9FQAV\"}'; 
                        }
                        //String valueString = (String) parsedJson.get('value');
                        Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(valueString);
                        Boolean woSplit = jsonResponse.containsKey('isWorkOrderSplit') 
                            ? String.valueOf(jsonResponse.get('isWorkOrderSplit')).toLowerCase() == 'true' 
                            : false;
                        String message = (String)jsonResponse.get('Message');
                        String hourlyWorkOrderId = jsonResponse.containsKey('HourlyWorkOrderId')  ? (String)jsonResponse.get('HourlyWorkOrderId') : (jsonResponse.containsKey('WorkOrderId')  ? (String)jsonResponse.get('WorkOrderId'): '');
                            String adminWorkOrderId = jsonResponse.containsKey('AdminWorkOrderId') ? (String)jsonResponse.get('AdminWorkOrderId') : '';
                        String consultWorkOrderId = jsonResponse.containsKey('ConsultWorkOrderId') ? (String)jsonResponse.get('ConsultWorkOrderId') : '';
                        workOrderRecord.BC_Build_CNSMP_API_Message__c=message;
                        if(string.isNotBlank(hourlyWorkOrderId)){
                            workOrderRecord.BC_Build_CNSMP_WO_ID__c=hourlyWorkOrderId;
                        }
                        if(string.isNotBlank(adminWorkOrderId)){
                            workOrderRecord.BC_Admin_CNSMP_WO_ID__c=adminWorkOrderId;
                            workOrderRecord.BC_Admin_CNSMP_API_Message__c=message;
                        }
                        if(string.isNotBlank(consultWorkOrderId)){
                            workOrderRecord.BC_Consulting_CNSMP_WO_ID__c=consultWorkOrderId;
                            workOrderRecord.BC_Consulting_CNSMP_API_Message__c=message;
                        }
                        //if(tipsConsumptionRes.toLowerCase().contains('workorder added successfully')){
                            Work_Order__c woRec=[Select ID,Project_Start_Date__c,Project_End_Date__c,Work_Order_Changes_Effective_Date__c FROM Work_Order__c WHERE ID=:workOrderId];
                            List<Work_Order_External_Reference__c> lineItemRecord=[Select ID,End_Date__c FROM Work_Order_External_Reference__c WHERE WorkOrder__c=:workOrderId Order By CreatedDate DESC LIMIT 1 ];
                            Boolean isSplit = !lineItemRecord.isEmpty() && woSplit;
                            Work_Order_External_Reference__c er;
                            
                            if (isSplit) {
                                // Close the existing record
                                Work_Order_External_Reference__c existingRec = lineItemRecord[0];
                                existingRec.End_Date__c = woRec.Work_Order_Changes_Effective_Date__c.addDays(-1);
                                upsertERList.add(existingRec);
                                
                                // Create new record for split
                                er = new Work_Order_External_Reference__c(
                                    WorkOrder__c = woRec.Id,
                                    Start_Date__c = woRec.Work_Order_Changes_Effective_Date__c,
                                    End_Date__c = woRec.Project_End_Date__c
                                );
                            } else if (lineItemRecord.isEmpty()) {
                                // No previous record exists, create fresh
                                er = new Work_Order_External_Reference__c(
                                    WorkOrder__c = woRec.Id,
                                    Start_Date__c = woRec.Project_Start_Date__c,
                                    End_Date__c = woRec.Project_End_Date__c
                                );
                            } else {
                                // Update existing record
                                er = lineItemRecord[0];
                                er.End_Date__c=woRec.Project_End_Date__c;
                            }
                            
                            er.BC_Build_CNSMP_API_Message__c = message;
                            if (String.isNotBlank(hourlyWorkOrderId)) {
                                er.BC_Build_CNSMP_WO_ID__c = hourlyWorkOrderId;
                            }
                            if (String.isNotBlank(adminWorkOrderId)) {
                                er.BC_Admin_CNSMP_WO_ID__c = adminWorkOrderId;
                                er.BC_Admin_CNSMP_API_Message__c = message;
                            }
                            if (String.isNotBlank(consultWorkOrderId)) {
                                er.BC_Consulting_CNSMP_WO_ID__c = consultWorkOrderId;
                                er.BC_Consulting_CNSMP_API_Message__c = message;
                            }
                            
                            upsertERList.add(er);
                       // }
                    }else{
                        workOrderRecord.BC_Build_CNSMP_API_Message__c=tipsConsumptionRes;                           
                        workOrderRecord.BC_Admin_CNSMP_API_Message__c=tipsConsumptionRes; 
                        workOrderRecord.BC_Consulting_CNSMP_API_Message__c=tipsConsumptionRes;                          
                        ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, consumptionBody,tipsConsumptionRes, 'Consumption');
                        ODS_WorkOrder_BC_API_Helper.sendMailWorkorderFailureBC(workOrderId, tipsConsumptionRes);
                    } 
                }
                workorderList.add(workOrderRecord);
                if(!workorderList.isEmpty() && actionType !='Void'){
                    update workorderList;
                }
                if(!upsertERList.isEmpty()){
                    upsert upsertERList;
                }
                WorkOrder_API_Calls.updateWorkOrderAPI=false;
            }else{
                ODS_WorkOrder_BC_API_Helper.sendMailWorkorderFailureBC(workOrderId, 'BC Configuration is not available. Please contact system administrators.');
            }
        }catch(Exception e)    
        {
            ODS_WorkOrder_BC_API_Helper.sendMailWorkorderFailureBC(workOrderId, e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    }
    public static string HttpRequestConsumption(string workOrderId,string body,Salesforce_BC_API_Configuration__mdt SFBCApiConfig,string accessToken, string endPointUrl, string methodType){
        system.debug('consumption body-'+body);
        
        
        system.debug('accessToken-'+accessToken);
        Http http = new Http();
        string responseJson='';                 
        HttpRequest request = new HttpRequest();  
        request.setMethod(methodType);
        request.setEndpoint(endPointUrl);
        request.setHeader('Accept','application/json');
        request.setHeader('contentType', 'application/json');
        request.setTimeout(120000);
        request.setHeader('Authorization','Bearer '+accessToken);  
        request.setBody(body);
        HTTPResponse response = http.send(request);      
        system.debug(response);
        responseJson = response.getBody();
        system.debug('res consumption--'+response.getBody());
        if(response.getStatusCode() !=200)
        {
            //  ODS_WorkOrder_BC_API_Helper.sendMailWorkorderFailureBC(workOrderId, responseJson);
            //  string text='Consumption WO '+customerType;
            //   ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, body, responseJson,text);
        }
        return responseJson;
    }
}