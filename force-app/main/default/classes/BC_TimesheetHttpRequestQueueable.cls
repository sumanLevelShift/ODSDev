public class BC_TimesheetHttpRequestQueueable implements Queueable,Database.AllowsCallouts {
    private String body;
    private String timeSheetId;
    private String billingType;
    private String actionType;
    
    public BC_TimesheetHttpRequestQueueable(String body, String timeSheetId, String billingType, String actionType) {
        this.body = body;
        this.timeSheetId = timeSheetId;
        this.billingType = billingType;
        this.actionType = actionType;
    }
    
    public void execute(QueueableContext context) {
        try {
            List<Salesforce_BC_API_Configuration__mdt> SFBCApiConfig=[Select Id,Company__c,Access_Token_URL__c,Action_Type__c,Client_Id__c,Client_Secret__c,Endpoint_URL__c,Grant_Type__c,Parameter__c,Tenant_Id__c,Scope__c,Method_Type__c From Salesforce_BC_API_Configuration__mdt WHERE 
                                                                      Action_Type__c=:actionType AND Is_Timesheet__c=true Limit 1];
            if(!SFBCApiConfig.isEmpty()){
                String clientId = SFBCApiConfig[0].Client_Id__c;
                String clientSecret = SFBCApiConfig[0].Client_Secret__c;
                String accessTokenUrl = SFBCApiConfig[0].Access_Token_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/oauth2/v2.0/token';
                String grantType = SFBCApiConfig[0].Grant_Type__c;
                String scope = SFBCApiConfig[0].Scope__c;
                system.debug('accessTokenUrl-'+accessTokenUrl);
                string accessToken=TimesheetTriggerBCHelper.getAccessToken(clientId, clientSecret, accessTokenUrl, grantType,scope);
                system.debug('accessToken-'+accessToken);
                system.debug('body--'+body);
                Http http = new Http();
                string responseJson = '';
                string endpointUrl=SFBCApiConfig[0].Endpoint_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/'+SFBCApiConfig[0].Parameter__c+'?company='+SFBCApiConfig[0].Company__c;
                system.debug('endpointUrl-'+endpointUrl);
                //api request 
                HttpRequest request = new HttpRequest();
                request.setMethod(SFBCApiConfig[0].Method_Type__c);
                request.setEndpoint(endpointUrl);
                request.setTimeout(120000);
                request.setHeader('Accept','application/json');
                request.setHeader('contentType', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + accessToken);
                
                request.setBody(body);
                
                HTTPResponse response = http.send(request);
                responseJson = response.getBody();            
                system.debug(response.getStatusCode());
                system.debug(response.getStatus());
                system.debug('res--'+responseJson);
                
                Timesheet__c t=new Timesheet__c();
                t.Id=timeSheetId;
                if (response.getStatusCode() == 200) {
                    Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
                    responseJson = (String) parsedJson.get('value');  
                    system.debug('responseJson-'+responseJson);
                    if(!response.getBody().toLowerCase().contains('successfully') ){
                        TimesheetTriggerBCHelper.sendMailForFailureTimesheet(timeSheetId,responseJson);
                        ODS_ExceptionUtility.logTipsIntegrationFailure(timeSheetId, body,responseJson, 'Timesheet');
                    }
                }else{
                    System.debug('Error message: ' + response.getStatus());
                    responseJson=response.getStatus()+':'+response.getBody();
                    TimesheetTriggerBCHelper.sendMailForFailureTimesheet(timeSheetId,responseJson);  
                    ODS_ExceptionUtility.logTipsIntegrationFailure(timeSheetId, body,responseJson, 'Timesheet');
                    
                }
                if(billingType=='Build'){
                    t.BC_Build_API_Response__c=responseJson;
                }
                if(billingType=='Admin'){
                    t.BC_Admin_API_Response__c=responseJson;
                }
                if(billingType=='Consulting'){
                    t.BC_Consult_API_Response__c=responseJson;
                }
                update t;
            }
            
        } catch (Exception e) {
            ODS_ExceptionUtility.logTipsIntegrationFailure(timeSheetId, body, e.getMessage(), 'Timesheet');
            TimesheetTriggerBCHelper.sendMailForFailureTimesheet(timeSheetId, e.getMessage());
            Timesheet__c t=new Timesheet__c();
            t.Id=timeSheetId;
            if(billingType=='Build'){
                t.BC_Build_API_Response__c='Error Message: '+ e.getMessage();
            }
            if(billingType=='Admin'){
                t.BC_Admin_API_Response__c='Error Message: '+ e.getMessage();
            }
            if(billingType=='Consulting'){
                t.BC_Consult_API_Response__c='Error Message: '+ e.getMessage();
            }
            update t;
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage());
        }
    }
}