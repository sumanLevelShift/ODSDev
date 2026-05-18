public class monthlyTimesheetBCHelper {
    private static String accessToken;

    public static List<Timesheet__c> monthlyTimesheetsABC(Set<id> timesheetIdSet,Date startDate,Date endDate,string accountId, List<Work_Order__c> validWorkOrders,
                                                          List<BC_EmailRequest> emailRequests)
    {
        String stDtStr = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/YYYY');
        String edDtStr = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/YYYY');
        string buildRes='';
        string adminRes='';
        string consultingRes='';
        string accountName='';
        List<Timesheet__c> updateTimesheet=new List<Timesheet__c>();
        List<Account> accountRecords=[Select Id,Name From Account Where Id=:accountId Limit 1];
        if(!accountRecords.isEmpty()){
            accountName=accountRecords[0].Name;
        }
        
        
        Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap =TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyWithWo(timesheetIdSet,validWorkOrders,startDate,endDate);
        Integer totalWorkOrders = woToTimesheetDetailsMap.size();
        Integer currentIteration = 0;
        for(Work_Order_External_Reference__c Wo:woToTimesheetDetailsMap.keySet())
        {
            currentIteration++;
            List<Time_Sheet_Details__c> timesheetDetailsRecords=woToTimesheetDetailsMap.get(wo);
            if(String.isNotBlank(wo.BC_Build_CNSMP_WO_ID__c) && String.isNotBlank(wo.BC_Admin_CNSMP_WO_ID__c) && String.isNotBlank(wo.BC_Consulting_CNSMP_WO_ID__c)){
                if(!timesheetDetailsRecords.isEmpty()){  
                    string body = '{"data":"' + AESEncryptDecrypt(TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyABC(Wo,timesheetDetailsRecords,startDate,endDate)) + '"}';
                    buildRes=httpRequestBC(body);
                    if(!buildRes.toLowerCase().contains('successfully')){
                        List<id> timesheetIdList=new List<id>();
                        timesheetIdList.addAll(timesheetIdSet);
                        emailRequests.add(new BC_EmailRequest('INTEGRATION_FAILURE', accountId,timesheetIdList, buildRes,  startDate, endDate));
                        //emailsToSend.add(sendMailForIntegrationFailureTimesheet(timesheetIdList[0],buildRes,startDate,endDate)); 
                    }
                    for(Id timesheetId:timesheetIdSet){
                        Timesheet__c t=new Timesheet__c();
                        t.Id=timesheetId;
                        t.BC_Build_API_Response__c=buildRes;                
                        t.BC_Admin_API_Response__c=buildRes;                
                        t.BC_Consult_API_Response__c=buildRes;                
                        updateTimesheet.add(t);
                    }
                }
            }else{
                emailRequests.add(new BC_EmailRequest('FAILURE', accountId, null,'Missing BC Work Order ID',startDate,endDate));
            }
            if(currentIteration < totalWorkOrders) {
                Long startTime = System.currentTimeMillis();
                while(System.currentTimeMillis() - startTime < 1000) {
                    // Wait for 1 seconds
                }
            }
        }  
        
        return updateTimesheet;
    }
    public static List<Timesheet__c> monthlyTimesheets(Set<Id> timesheetIdSet,Date startDate,Date endDate,String accountId,List<Work_Order__c> validWorkOrders,
                                                      List<BC_EmailRequest> emailRequests){
        String stDtStr = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/YYYY');
        String edDtStr = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/YYYY');

         List<Timesheet__c> updateTimesheet=new List<Timesheet__c>();
        boolean BC_Integration=boolean.valueOf(system.label.BC_Integration);
       Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap =TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyWithWo(timesheetIdSet,validWorkOrders,startDate,endDate);
        Integer totalWorkOrders = woToTimesheetDetailsMap.size();
		Integer currentIteration = 0;
        for(Work_Order_External_Reference__c Wo:woToTimesheetDetailsMap.keySet()){
             currentIteration++;
            String workOrderID=wo.BC_Build_CNSMP_WO_ID__c;
            if(String.isNotBlank(workOrderID)){
                List<Time_Sheet_Details__c> timesheetDetailsRecords=woToTimesheetDetailsMap.get(wo);
                if(!timesheetDetailsRecords.isEmpty()){
                    string body = '{"data":"' + AESEncryptDecrypt(TimesheetTriggerBCHelper.getTimesheetDetailsMonthly(Wo,timesheetDetailsRecords,startDate,endDate)) + '"}';
                    string res=httpRequestBC(body); 
                    system.debug('res-'+res);
                    if(!res.toLowerCase().contains('successfully')){
                        List<id> timesheetIdList=new List<id>();
                        timesheetIdList.addAll(timesheetIdSet);
                        //emailsToSend.add(sendMailForIntegrationFailureTimesheet(timesheetIdList[0],res,startDate,endDate)); 
                         emailRequests.add(new BC_EmailRequest('INTEGRATION_FAILURE', accountId,timesheetIdList, res,  startDate, endDate));
                    }
                    for(Id timesheetId:timesheetIdSet){
                        Timesheet__c t=new Timesheet__c();
                        t.Id=timesheetId;
                        t.BC_Build_API_Response__c=res;
                        updateTimesheet.add(t);
                    }
                }
                if(currentIteration < totalWorkOrders) {
                    Long startTime = System.currentTimeMillis();
                    while(System.currentTimeMillis() - startTime < 1000) {
                        // Wait for 1 seconds
                    }
                }
            }else{
                emailRequests.add(new BC_EmailRequest('FAILURE', accountId, null,'Missing BC Work Order ID',startDate,endDate));
            }
        }
        return updateTimesheet;
    }
    public static Map<id,List<Work_Order__c>> getBCIdWO(Set<id> accountId,Date WeekStartDate, Date weekEndDate){
        Map<id,List<Work_Order__c>> validaWorkOrdersMap=new Map<id,List<Work_Order__c>>();
        List<Work_Order__c> wOList=new List<Work_Order__c>();
        wOList=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c,
                (SELECT ID,Start_Date__c,End_Date__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c FROM Work_Order_External_References__r
                 WHERE Start_Date__c <=: weekEndDate AND End_Date__c >=: WeekStartDate) FROM Work_Order__c
                WHERE Client_Name__c IN:accountId AND Project_Start_Date__c <=: weekEndDate AND Project_End_Date__c >=: WeekStartDate AND SubCategory__c IN ('DemandBlue-Subscription','DemandBlue-Subscription-CO') ORDER BY CreatedDate DESC];
        
        for(Work_Order__c wo:wOList){
            string subCategoryConsumption='';
            string subCategoryConsumptionCO='';
            if(wo.Business_Unit__c=='DemandBlue'){
                subCategoryConsumption=wo.Business_Unit__c+'-Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+'-Subscription-CO';   
            }else{
                subCategoryConsumption=wo.Business_Unit__c+' -Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+' -Subscription-CO'; 
            }
            if(wo.SubCategory__c==subCategoryConsumption || wo.SubCategory__c==subCategoryConsumptionCO){
                //validaWorkOrdersMap.put(wo.Client_Name__c,wo);
                List<Work_Order__c> workOrderList=new List<Work_Order__c>();
                workOrderList.add(wo);
                if(validaWorkOrdersMap.containsKey(wo.Client_Name__c)){
                    workOrderList.addAll(validaWorkOrdersMap.get(wo.Client_Name__c));
                }
                validaWorkOrdersMap.put(wo.Client_Name__c,workOrderList);
            }
        }
        return validaWorkOrdersMap;
    }
    /*public static Messaging.SingleEmailMessage sendMailForFailureTimesheet(string accountId,Date startDate, Date endDate){
        List<account> accountRecord=[Select Id,Name From Account Where ID=:accountId];
            String stDtStr = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/YYYY');
            String edDtStr = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/YYYY');
            List<string> sendTo1 = System.Label.WorkOrderUsersForErrorStatusBC.Split(',');
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject('Timesheet and BC Integration failed - '+accountRecord[0].Name);
            semail.setToAddresses(sendTo1);
            String strHtmlBody = '';                     
            strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>The timesheet integration for <b>'+ accountRecord[0].Name+ '</b> failed for the period from <b>'+ stDtStr +'</b> to <b>'+edDtStr+'</b> due to unavailability of BC (Consumption) Work Order ID.</br> ';
            strHtmlBody += '<br/><br/>Thanks,<br/><br/>Demandblue Admin<br/>';
            semail.setHtmlBody(strHtmlBody);
            system.debug('strHtmlBody-'+strHtmlBody);
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            return semail;
    }*/
    public static string httpRequestBC(string body) {
        try {
            List<Salesforce_BC_API_Configuration__mdt> SFBCApiConfig=[Select Id,Company__c,Access_Token_URL__c,Action_Type__c,Client_Id__c,Client_Secret__c,Endpoint_URL__c,Grant_Type__c,Parameter__c,Tenant_Id__c,Scope__c,Method_Type__c From Salesforce_BC_API_Configuration__mdt WHERE 
                                                                      Action_Type__c='Add' AND Is_Timesheet__c=true Limit 1];
            if(!SFBCApiConfig.isEmpty()){
                String clientId = SFBCApiConfig[0].Client_Id__c;
                String clientSecret = SFBCApiConfig[0].Client_Secret__c;
                String accessTokenUrl = SFBCApiConfig[0].Access_Token_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/oauth2/v2.0/token';
                String grantType = SFBCApiConfig[0].Grant_Type__c;
                String scope = SFBCApiConfig[0].Scope__c;
                if(string.isBlank(accessToken)){
                accessToken=getAccessToken(clientId, clientSecret, accessTokenUrl, grantType,scope);
                }
                system.debug('body--'+body);
                Http http = new Http();
                string responseJson = '';
                string endpointUrl=SFBCApiConfig[0].Endpoint_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/'+SFBCApiConfig[0].Parameter__c+'?company='+SFBCApiConfig[0].Company__c;
                
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
                
                if (response.getStatusCode() == 200) {
                    System.debug('Error message: ' + response.getStatus());
                    Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
                    responseJson = (String) parsedJson.get('value');  
                }  
                return responseJson;
            }
            return 'BC Timesheet Configuration is not available.';
        } catch (Exception e) {
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String className = stackTrace.substringAfter('.').substringBefore('.');	
            String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
            
           // ODS_ExceptionUtility.LogException(e);
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage() +'.   method name:'+methodName+'. class name: '+className);
            return e.getMessage();
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
   /* public static Messaging.SingleEmailMessage sendMailForIntegrationFailureTimesheet(id timesheetId,string errorMessage,Date startDate, Date endDate){
        
        Messaging.SingleEmailMessage failureEmail = new Messaging.SingleEmailMessage();
        String strHtmlBody = '';
        List<string> sendToList = System.Label.WorkOrderUsersForErrorStatusBC.Split(',');
        failureEmail.setToAddresses(sendToList);
        failureEmail.setSubject('BC Timesheet Integration failed for the timesheet record: '+timesheetId);
        strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>BC Timesheet integration for the SFDC timesheet id : '+timesheetId+' has been failed from '+startDate+' to '+ endDate +'because of the below. Please update it accordingly.</br> ';
        strHtmlBody += '<br/><br/><b>BC API Message: </b>'+errorMessage;
        strHtmlBody += '<br/><br/>Thanks,<br/><br/>Demandblue Admin<br/>';
        failureEmail.setHtmlBody(strHtmlBody);
        //system.debug('strHtmlBody-'+strHtmlBody);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{failureEmail});
        return failureEmail;
    }*/
    public static string AESEncryptDecrypt(String inputString) {
        try {
            system.debug('inputString-'+inputString);
            Blob key = Blob.valueOf(System.Label.AES_Key);
            Blob data = Blob.valueOf(inputString);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
            JWT jwt = new JWT('HS256');
            string encrypted = EncodingUtil.base64Encode(encryptedData);
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encryptedData);
            String decryptedString = decrypted.toString();
            return encrypted;
        } catch (Exception e) {
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage());
            return '';
        }
    }
    public static Messaging.SingleEmailMessage createFailureEmail(BC_EmailRequest req) {
        Account acc = [SELECT Name FROM Account WHERE Id = :req.accountId LIMIT 1];
        String stDtStr = DateTime.newInstance(req.startDate.year(), req.startDate.month(), req.startDate.day()).format('MM/dd/YYYY');
        String edDtStr = DateTime.newInstance(req.endDate.year(), req.endDate.month(), req.endDate.day()).format('MM/dd/YYYY');
        List<string> recipients = System.Label.WorkOrderUsersForErrorStatusBC.Split(',');
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Timesheet and BC Integration failed - ' + acc.Name);
        email.setToAddresses(recipients);
        
        String body = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>' +
            'The timesheet integration for <b>' + acc.Name + '</b> failed for the period from <b>' + stDtStr + 
            '</b> to <b>' + edDtStr + '</b> due to unavailability of BC (Consumption) Work Order ID.</br> ' +
            '<br/><br/>Thanks,<br/><br/>LevelShift Admin<br/>';
        email.setHtmlBody(body);
        
        return email;
    }
    
    public static Messaging.SingleEmailMessage createIntegrationFailureEmail(BC_EmailRequest req) {
        List<string> recipients = System.Label.WorkOrderUsersForErrorStatusBC.Split(',');
        String stDtStr = DateTime.newInstance(req.startDate.year(), req.startDate.month(), req.startDate.day()).format('MM/dd/YYYY');
        String edDtStr = DateTime.newInstance(req.endDate.year(), req.endDate.month(), req.endDate.day()).format('MM/dd/YYYY');
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('BC Timesheet Integration failed for the timesheet record: ' + req.timesheetId);
        email.setToAddresses(recipients);
        
        String body = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>' +
            'BC Timesheet integration for the SFDC timesheet id : ' + req.timesheetId + 
            ' has been failed from ' + stDtStr + ' to ' + edDtStr + 
            ' because of the below. Please update it accordingly.</br> ' +
            '<br/><br/><b>BC API Message: </b>' + req.errorMessage +
            '<br/><br/>Thanks,<br/><br/>LevelShift Admin<br/>';
        email.setHtmlBody(body);
        
        return email;
    }
}