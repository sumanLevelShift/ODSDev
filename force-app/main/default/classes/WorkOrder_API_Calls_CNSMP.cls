public class WorkOrder_API_Calls_CNSMP implements Queueable,Database.AllowsCallouts{
    public string workOrderId;
    public string endPoint;
    public string consumptionBody;
    public string adminConsumptionBody;
    public string consultingConsumptionBody;
    public string workOrderName;
    public string methodType;
    
    public WorkOrder_API_Calls_CNSMP(string workOrderId,string endPoint,string consumptionBody,string adminConsumptionBody,string consultingConsumptionBody,string workOrderName,string methodType){
        this.workOrderId = workOrderId ;
        this.endPoint = endPoint ;
        this.consumptionBody = consumptionBody ;
        this.adminConsumptionBody = adminConsumptionBody ;
        this.consultingConsumptionBody = consultingConsumptionBody ;
        this.workOrderName = workOrderName ;
        this.methodType = methodType ;
        
    }
    public void execute(QueueableContext qc){
        WorkOrder_API_Calls.isFirstTime=false;

        List<Work_Order__c> workorderList=new List<Work_Order__c>();
        string tipsConsumptionRes='';
        Work_Order__c workOrder1=new Work_Order__c();
        workOrder1.Id=workOrderId;
        if(string.isNotBlank(consumptionBody)){
            tipsConsumptionRes=HttpRequestConsumption(workOrderId,endPoint,consumptionBody,workOrderName,methodType,'Build');
            if(tipsConsumptionRes.contains('-') && !tipsConsumptionRes.contains('Alert Message')){
                workOrder1.TIPS_CNSMP_WO_ID__c=tipsConsumptionRes.split('-')[1];
                workOrder1.Tips_CNSMP_API_Message__c=tipsConsumptionRes.split('-')[0];
            }else{
                workOrder1.Tips_CNSMP_API_Message__c=tipsConsumptionRes;
                ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, consumptionBody,tipsConsumptionRes, 'Build');
            } 
        }
        if(string.isNotBlank(adminConsumptionBody)){
            tipsConsumptionRes=HttpRequestConsumption(workOrderId,endPoint,adminConsumptionBody,workOrderName,methodType,'Admin');
            if(tipsConsumptionRes.contains('-') && !tipsConsumptionRes.contains('Alert Message')){
                workOrder1.Tips_Admin_CNSMP_API_Message__c=tipsConsumptionRes.split('-')[0];    
                workOrder1.TIPS_Admin_CNSMP_WO_ID__c=tipsConsumptionRes.split('-')[1];
            }else{
                workOrder1.Tips_Admin_CNSMP_API_Message__c=tipsConsumptionRes;
                ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, adminConsumptionBody,tipsConsumptionRes, 'Admin');

            }  
        }
        if(string.isNotBlank(consultingConsumptionBody)){
            tipsConsumptionRes=HttpRequestConsumption(workOrderId,endPoint,consultingConsumptionBody,workOrderName,methodType,'Consulting');
            if(tipsConsumptionRes.contains('-') && !tipsConsumptionRes.contains('Alert Message')){
                workOrder1.Tips_Consulting_CNSMP_API_Message__c=tipsConsumptionRes.split('-')[0];
                workOrder1.TIPS_Consulting_CNSMP_WO_ID__c=tipsConsumptionRes.split('-')[1];
            }else{
                workOrder1.Tips_Consulting_CNSMP_API_Message__c=tipsConsumptionRes;
                ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, consultingConsumptionBody,tipsConsumptionRes, 'Consulting');
            }  
        }
        workorderList.add(workOrder1);
        if(!workorderList.isEmpty()){
            update workorderList;
        }
        WorkOrder_API_Calls.updateWorkOrderAPI=false;
    }
    public static string HttpRequestConsumption(Id workOrderId,string endPoint,string body,string workOrderName,string methodType,string customerType)
    {
        try
        {  
            system.debug(customerType+' body -'+body);
            Http http = new Http();
            string responseJson='';
            string accessToken=WorkOrder_API_Calls.GenerateAuthorizationToken();
            system.debug('accessToken:'+accessToken);
            
            //api request 
            HttpRequest request = new HttpRequest();  
            request.setMethod(methodType);
            request.setEndpoint(endPoint);
            request.setTimeout(120000);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer '+accessToken);
            request.setBody(body);
            
            HTTPResponse response = http.send(request);      
            system.debug(response);
            responseJson = response.getBody();
            system.debug(response);
            if(response.getStatusCode()==200)
            {
                system.debug(customerType+'--responseJson------>'+responseJson);
                if(responseJson.contains('-')){
                    String jsonResponse = (String)JSON.deserializeUntyped(responseJson);
                    system.debug('jsonResponse.contains---'+(jsonResponse.contains('-')?jsonResponse.split('-')[1]:jsonResponse));
                }
            }else{
                ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, body, responseJson, customerType);
            }
            return responseJson;  
        }
        catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return e.getMessage() +' at ' +e.getLineNumber();
        }
    }
}