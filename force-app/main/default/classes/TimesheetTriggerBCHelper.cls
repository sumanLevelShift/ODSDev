public class TimesheetTriggerBCHelper {
    public class TimesheetEntry {
        public String WorkorderId;
        public Date TimesheetTaskDate;
        public Date TimesheetStartDate;
        public Date TimesheetEndDate;
        public Decimal Hours;
        public String Comment;
        public Decimal RowNo;
    }
    public class TimesheetData {
        public List<TimesheetEntry> TimesheetData;
    }
    public static Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> getTimesheetDetailsWeeklyWithWo(String timeSheetId,List<Work_Order__c> validWorkOrders){
        List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c,Timesheet__r.Week_Start_Date__c,Timesheet__r.Week_End_Date__c,Initiative_Billing_Type__c FROM Time_Sheet_Details__c
                                                          WHERE Timesheet__c=:timeSheetId ];
        Map<Work_Order__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap = new Map<Work_Order__c, List<Time_Sheet_Details__c>>();
        
        for(Time_Sheet_Details__c tsd : timesheetDetailsList) {
            for(Work_Order__c wo : validWorkOrders) {
                if(tsd.Timesheet_Date__c >= wo.Project_Start_Date__c && 
                   tsd.Timesheet_Date__c <= wo.Project_End_Date__c) {
                       
                       if(!woToTimesheetDetailsMap.containsKey(wo)) {
                           woToTimesheetDetailsMap.put(wo, new List<Time_Sheet_Details__c>());
                       }
                       woToTimesheetDetailsMap.get(wo).add(tsd);
                       break; 
                   }
            }
        }
        Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woExternalTS = new Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>>();
        for(Work_Order__c workOrder:woToTimesheetDetailsMap.keySet()){
            for(Time_Sheet_Details__c record:woToTimesheetDetailsMap.get(workOrder)){
                for (Work_Order_External_Reference__c er:workOrder.Work_Order_External_References__r){
                    if(record.Timesheet_Date__c >= er.Start_Date__c && 
                       record.Timesheet_Date__c <= er.End_Date__c) {
                           if(!woExternalTS.containsKey(er)) {
                               woExternalTS.put(er, new List<Time_Sheet_Details__c>());
                           }
                           woExternalTS.get(er).add(record);
                           break; 
                       }
                }
            }
        }
        return woExternalTS;
    }
    public static Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> getTimesheetDetailsMonthlyWithWo(Set<id> timesheetId,List<Work_Order__c> validWorkOrders,Date startDate,Date endDate){
        List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c,Initiative_Billing_Type__c FROM Time_Sheet_Details__c
                                                          WHERE Timesheet__c IN: timesheetId AND 
                                                          Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Timesheet_Date__c DESC NULLS FIRST];
        Map<Work_Order__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap = new Map<Work_Order__c, List<Time_Sheet_Details__c>>();
        
        for(Time_Sheet_Details__c tsd : timesheetDetailsList) {
            for(Work_Order__c wo : validWorkOrders) {
                if(tsd.Timesheet_Date__c >= wo.Project_Start_Date__c && 
                   tsd.Timesheet_Date__c <= wo.Project_End_Date__c) {
                       
                       if(!woToTimesheetDetailsMap.containsKey(wo)) {
                           woToTimesheetDetailsMap.put(wo, new List<Time_Sheet_Details__c>());
                       }
                       woToTimesheetDetailsMap.get(wo).add(tsd);
                       break; 
                   }
            }
        }
        Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woExternalTS = new Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>>();
        for(Work_Order__c workOrder:woToTimesheetDetailsMap.keySet()){
            for(Time_Sheet_Details__c record:woToTimesheetDetailsMap.get(workOrder)){
                for (Work_Order_External_Reference__c er:workOrder.Work_Order_External_References__r){
                    if(record.Timesheet_Date__c >= er.Start_Date__c && 
                       record.Timesheet_Date__c <= er.End_Date__c) {
                           if(!woExternalTS.containsKey(er)) {
                               woExternalTS.put(er, new List<Time_Sheet_Details__c>());
                           }
                           woExternalTS.get(er).add(record);
                           break; 
                       }
                }
            }
        }
        return woExternalTS;
    }
    public static string getTimesheetDetailsWeekly(Work_Order_External_Reference__c WorkOrderRecord, List<Time_Sheet_Details__c> timesheetDetailsList){
        TimesheetData timesheetDataObj = new TimesheetData();
        //timesheetDataObj.WorkorderId = tipsId;
        List<TimesheetEntry> timesheetEntries = new List<TimesheetEntry>();
        
        /*List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c,Timesheet__r.Week_Start_Date__c,Timesheet__r.Week_End_Date__c FROM Time_Sheet_Details__c
WHERE ID IN:timesheetDetailsIds];*/
        for (Time_Sheet_Details__c record : timesheetDetailsList) {
            TimesheetEntry entry = new TimesheetEntry();
            entry.WorkorderId = WorkOrderRecord.BC_Build_CNSMP_WO_ID__c;
            entry.TimesheetTaskDate = record.Timesheet_Date__c;
            entry.Hours = record.Hours_Worked__c;
            entry.Comment = record.Task_Name__c;
            entry.RowNo = record.Row_No__c;
            Date tsStart = record.Timesheet__r.Week_Start_Date__c;
            Date tsEnd = record.Timesheet__r.Week_End_Date__c;
            entry.TimesheetStartDate = WorkOrderRecord.Start_Date__c > tsStart ? WorkOrderRecord.Start_Date__c : tsStart;
            entry.TimesheetEndDate = WorkOrderRecord.End_Date__c < tsEnd ? WorkOrderRecord.End_Date__c : tsEnd;
            timesheetEntries.add(entry);
        }
        
        timesheetDataObj.TimesheetData = timesheetEntries;
        String jsonString = JSON.serialize(timesheetDataObj);
        jsonString=jsonString.replaceAll('TimesheetTaskDate', 'Date');
        
        System.debug('jsonString-'+jsonString);   
        return jsonString;
    }
    public static string getTimesheetDetailsMonthly(Work_Order_External_Reference__c er, List<Time_Sheet_Details__c> timesheetDetailsList,Date startDate,Date endDate){
        TimesheetData timesheetDataObj = new TimesheetData();
        //timesheetDataObj.WorkorderId = tipsId;
        List<TimesheetEntry> timesheetEntries = new List<TimesheetEntry>();
        
        /* List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c FROM Time_Sheet_Details__c
WHERE Timesheet__c IN: timesheetId AND 
Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Timesheet_Date__c DESC NULLS FIRST];*/
        for (Time_Sheet_Details__c record : timesheetDetailsList) {
            //system.debug('record-'+record);
            TimesheetEntry entry = new TimesheetEntry();
            entry.WorkorderId =  er.BC_Build_CNSMP_WO_ID__c;
            entry.TimesheetTaskDate = record.Timesheet_Date__c;
            entry.Hours = record.Hours_Worked__c;
            entry.Comment = record.Task_Name__c;
            entry.RowNo = record.Row_No__c;
            Date tsStart = startDate;
            Date tsEnd = endDate;
            entry.TimesheetStartDate = er.Start_Date__c > tsStart ? er.Start_Date__c : tsStart;
            entry.TimesheetEndDate = er.End_Date__c < tsEnd ? er.End_Date__c : tsEnd;
            timesheetEntries.add(entry);
        }           
        
        timesheetDataObj.TimesheetData = timesheetEntries;
        String jsonString = JSON.serialize(timesheetDataObj);
        jsonString=jsonString.replaceAll('TimesheetTaskDate', 'Date');
        System.debug(jsonString);
        return jsonString;
    }
    public static string getTimesheetDetailsWeeklyABC(Work_Order_External_Reference__c WorkOrderRecord, List<Time_Sheet_Details__c> timesheetDetailsList){
        TimesheetData timesheetDataObj = new TimesheetData();
        //timesheetDataObj.WorkorderId = tipsId;
        List<TimesheetEntry> timesheetEntries = new List<TimesheetEntry>();
        
        /* List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c,Timesheet__r.Week_Start_Date__c,Timesheet__r.Week_End_Date__c,Initiative_Billing_Type__c FROM Time_Sheet_Details__c
WHERE Timesheet__c=:timesheetId AND Initiative_Billing_Type__c IN :billingTypeWithIds.keySet()];*/
        for (Time_Sheet_Details__c record : timesheetDetailsList) {
            //system.debug('billingTypeWithIds--'+record);
            TimesheetEntry entry = new TimesheetEntry();
            string bcWOId;
            if(record.Initiative_Billing_Type__c=='Build'){
                bcWOId=WorkOrderRecord.BC_Build_CNSMP_WO_ID__c;
            }else if(record.Initiative_Billing_Type__c=='Admin'){
                bcWOId=WorkOrderRecord.BC_Admin_CNSMP_WO_ID__c;
            }else if(record.Initiative_Billing_Type__c=='Consulting'){
                bcWOId=WorkOrderRecord.BC_Consulting_CNSMP_WO_ID__c;
            }
            if(String.isNotBlank(bcWOId)){
                entry.WorkorderId = bcWOId;
                entry.TimesheetTaskDate = record.Timesheet_Date__c;
                entry.Hours = record.Hours_Worked__c;
                entry.Comment = record.Task_Name__c;
                entry.RowNo = record.Row_No__c;
                Date tsStart = record.Timesheet__r.Week_Start_Date__c;
                Date tsEnd = record.Timesheet__r.Week_End_Date__c;
                entry.TimesheetStartDate = WorkOrderRecord.Start_Date__c > tsStart ? WorkOrderRecord.Start_Date__c : tsStart;
                entry.TimesheetEndDate = WorkOrderRecord.End_Date__c < tsEnd ? WorkOrderRecord.End_Date__c : tsEnd;
                timesheetEntries.add(entry);  
            }
            
        }
        String jsonString ='';
        if(!timesheetEntries.isEmpty()){
            timesheetDataObj.TimesheetData = timesheetEntries;
            jsonString = JSON.serialize(timesheetDataObj);
            jsonString=jsonString.replaceAll('TimesheetTaskDate', 'Date');
            System.debug(jsonString);
        }
        return jsonString;
    }
    public static string getTimesheetDetailsMonthlyABC(Work_Order_External_Reference__c WorkOrderRecord, List<Time_Sheet_Details__c> timesheetDetailsList,Date startDate,Date endDate){
        TimesheetData timesheetDataObj = new TimesheetData();
        // timesheetDataObj.WorkorderId = tipsId;
        List<TimesheetEntry> timesheetEntries = new List<TimesheetEntry>();
        
        /* List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c,Initiative_Billing_Type__c FROM Time_Sheet_Details__c
WHERE Timesheet__c IN: timesheetId AND Initiative_Billing_Type__c IN :billingTypeWithIds.keySet()
AND Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Timesheet_Date__c DESC NULLS FIRST];*/
        for (Time_Sheet_Details__c record : timesheetDetailsList) {
            //('record-'+record);
           // system.debug(record.Timesheet_Date__c+'---hours---'+record.Hours_Worked__c);
            string bcWOId;
            if(record.Initiative_Billing_Type__c=='Build'){
                bcWOId=WorkOrderRecord.BC_Build_CNSMP_WO_ID__c;
            }else if(record.Initiative_Billing_Type__c=='Admin'){
                bcWOId=WorkOrderRecord.BC_Admin_CNSMP_WO_ID__c;
            }else if(record.Initiative_Billing_Type__c=='Consulting'){
                bcWOId=WorkOrderRecord.BC_Consulting_CNSMP_WO_ID__c;
            } 
            if(string.isNotBlank(bcWOId)){
                TimesheetEntry entry = new TimesheetEntry();
                entry.WorkorderId = bcWOId;
                entry.TimesheetTaskDate = record.Timesheet_Date__c;
                entry.Hours = record.Hours_Worked__c;
                entry.Comment = record.Task_Name__c;
                entry.RowNo = record.Row_No__c;
                Date tsStart = startDate;
                Date tsEnd = endDate;
                entry.TimesheetStartDate = WorkOrderRecord.Start_Date__c > tsStart ? WorkOrderRecord.Start_Date__c : tsStart;
                entry.TimesheetEndDate = WorkOrderRecord.End_Date__c < tsEnd ? WorkOrderRecord.End_Date__c : tsEnd;
                timesheetEntries.add(entry);
            }
        }
        String jsonString ='';
        if(!timesheetEntries.isEmpty()){
            timesheetDataObj.TimesheetData = timesheetEntries;
            jsonString = JSON.serialize(timesheetDataObj);
            jsonString=jsonString.replaceAll('TimesheetTaskDate', 'Date');
            System.debug(jsonString);
        }
        return jsonString;
    }
   /* @future(callout = true)
    public static Void HttpRequestBC(string body,string timeSheetId,string billingType,string actionType) {
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
                string accessToken=getAccessToken(clientId, clientSecret, accessTokenUrl, grantType,scope);
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
                        sendMailForFailureTimesheet(timeSheetId,responseJson);
                        ODS_ExceptionUtility.logTipsIntegrationFailure(timeSheetId, body,responseJson, 'Timesheet');
                    }
                }else{
                    System.debug('Error message: ' + response.getStatus());
                    responseJson=response.getStatus()+':'+response.getBody();
                    sendMailForFailureTimesheet(timeSheetId,responseJson);  
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
            sendMailForFailureTimesheet(timeSheetId, e.getMessage());
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
    }*/
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
    public static void sendMailForFailureTimesheet(string timesheetId,string errorMessage){
        
        Messaging.SingleEmailMessage failureEmail = new Messaging.SingleEmailMessage();
        String strHtmlBody = '';
        List<string> sendToList = System.Label.WorkOrderUsersForErrorStatusBC.Split(',');
        failureEmail.setToAddresses(sendToList);
        failureEmail.setSubject('BC Timesheet Integration failed for the timesheet record: '+timesheetId);
        strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>BC Timesheet integration for the SFDC timesheet id : '+timesheetId+' has been failed because of the below. Please update it accordingly.</br> ';
        strHtmlBody += '<br/><br/>BC API Message: <b>'+errorMessage+'</b>';
        strHtmlBody += '<br/><br/>Thanks,<br/><br/>LevelShift Admin<br/>';
        failureEmail.setHtmlBody(strHtmlBody);
        //system.debug('strHtmlBody-'+strHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{failureEmail});
    }
}