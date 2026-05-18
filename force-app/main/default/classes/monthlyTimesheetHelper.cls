public class monthlyTimesheetHelper {
    public static List<Timesheet__c> monthlyTimesheetsABC(Set<id> timesheetIdSet,string buildTipsIDWO,Date startDate,Date endDate,string adminTipsIDWO,string consultingTipsIDWO,string accountId){
        String stDtStr = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/YYYY');
        String edDtStr = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/YYYY');
        string buildRes='';
        string adminRes='';
        string consultingRes='';
        if(string.isNotBlank(buildTipsIDWO)){
            string body = '{"data":"' + AESEncryptDecrypt(TimesheetTriggerHelper.getTimesheetDetailsMonthlyABC(buildTipsIDWO,timesheetIdSet,'Build',startDate,endDate)) + '"}';
            buildRes=HttpRequest(System.Label.TIPS_Timesheet_API_Endpoint, body, 'POST');  
        }else{
            sendMailForFailureTimesheet(accountId,startDate,endDate);    
        }
        if(string.isNotBlank(adminTipsIDWO)){
            string body = '{"data":"' + AESEncryptDecrypt(TimesheetTriggerHelper.getTimesheetDetailsMonthlyABC(adminTipsIDWO,timesheetIdSet,'Admin',startDate,endDate)) + '"}';
            adminRes=HttpRequest(System.Label.TIPS_Timesheet_API_Endpoint, body, 'POST');    
        }else{
            sendMailForFailureTimesheet(accountId,startDate,endDate); 
        }
        if(string.isNotBlank(consultingTipsIDWO)){
            string body = '{"data":"' + AESEncryptDecrypt(TimesheetTriggerHelper.getTimesheetDetailsMonthlyABC(consultingTipsIDWO,timesheetIdSet,'Consulting',startDate,endDate)) + '"}';
            consultingRes=HttpRequest(System.Label.TIPS_Timesheet_API_Endpoint, body, 'POST');     
        }else{
            sendMailForFailureTimesheet(accountId,startDate,endDate);    
        }
        
        List<Timesheet__c> updateTimesheet=new List<Timesheet__c>();
        for(Id timesheetId:timesheetIdSet){
            Timesheet__c t=new Timesheet__c();
            t.Id=timesheetId;
            t.TIPS_Api_Response__c=buildRes;                
            t.TIPS_Api_Admin_Response__c=adminRes;                
            t.TIPS_Api_Consulting_Response__c=consultingRes;                
            updateTimesheet.add(t);
        }
        return updateTimesheet;
    }
    public static List<Timesheet__c> monthlyTimesheets(Set<Id> timesheetIdSet,string tipsIDWO,Date startDate,Date endDate){
        String stDtStr = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/YYYY');
        String edDtStr = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/YYYY');
        string body = '{"data":"' + AESEncryptDecrypt(TimesheetTriggerHelper.getTimesheetDetailsMonthly(tipsIDWO,timesheetIdSet,startDate,endDate)) + '"}';
        system.debug('non abc '+body);
        system.debug('timesheetIdSet-'+timesheetIdSet);
        string res=HttpRequest(System.Label.TIPS_Timesheet_API_Endpoint, body, 'POST');
        List<Timesheet__c> updateTimesheet=new List<Timesheet__c>();
        for(Id timesheetId:timesheetIdSet){
            Timesheet__c t=new Timesheet__c();
            t.Id=timesheetId;
            t.TIPS_Api_Response__c=res;
            updateTimesheet.add(t);
        }
        return updateTimesheet;
    }
    public static Map<id,Work_Order__c> getTIPSIdWO(Set<id> accountId, Date weekEndDate){
        Map<id,Work_Order__c> tipsWorkOrder=new Map<id,Work_Order__c>();
        List<Work_Order__c> wOList=new List<Work_Order__c>();
        wOList=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c FROM Work_Order__c
                WHERE Client_Name__c IN:accountId AND Project_Start_Date__c <=: weekEndDate AND Project_End_Date__c >=: weekEndDate AND SubCategory__c LIKE '%Subscription%' ORDER BY CreatedDate DESC];
        if(wOList.isEmpty()){
            List<AggregateResult> aggregateResults = [SELECT MAX(CreatedDate) maxCreatedDate, Client_Name__c FROM Work_Order__c WHERE Client_Name__c IN :accountId AND SubCategory__c LIKE '%Subscription%' GROUP BY Client_Name__c];            
            for (AggregateResult aggregateResult : aggregateResults) {
                Datetime maxCreatedDate = (Datetime)aggregateResult.get('maxCreatedDate');
                Id clientId = (Id)aggregateResult.get('Client_Name__c');
                Work_Order__c recentWorkOrder = [SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c FROM Work_Order__c WHERE Client_Name__c = :clientId AND CreatedDate = :maxCreatedDate];
                if(recentWorkOrder !=null){
                wOList.add(recentWorkOrder);
                }
            }
        }
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
                system.debug('wo.Client_Name__c-'+wo.Client_Name__c);
                tipsWorkOrder.put(wo.Client_Name__c,wo);
            }
        }
        return tipsWorkOrder;
    }
    public static void sendMailForFailureTimesheet(string accountId,Date startDate, Date endDate){
        List<account> accountRecord=[Select Id,Name From Account Where ID=:accountId];
        if(!accountRecord.isEmpty()){
            String stDtStr = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/YYYY');
            String edDtStr = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/YYYY');
            List<string> sendTo1 = System.Label.WorkOrderUsersForErrorStatus.Split(',');
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject('Timesheet and TIPS Integration failed - '+accountRecord[0].Name);
            semail.setToAddresses(sendTo1);
            String strHtmlBody = '';                     
            strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>The timesheet integration for <b>'+ accountRecord[0].Name+ '</b> failed for the period from <b>'+ stDtStr +'</b> to <b>'+edDtStr+'</b> due to unavailability of TIPS (Consumption) Work Order ID.</br> ';
            strHtmlBody += '<br/><br/>Thanks,<br/><br/>LevelShift Admin<br/>';
            semail.setHtmlBody(strHtmlBody);
            system.debug('strHtmlBody-'+strHtmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        }
    }
    public static string HttpRequest(string Endpoint, string body, string MethodType) {
        try {
            system.debug('body--'+body);
            Http http = new Http();
            string responseJson = '';
            string accessToken = GenerateAuthorizationToken();
            //api request 
            HttpRequest request = new HttpRequest();
            request.setMethod(MethodType);
            request.setEndpoint(Endpoint);
            request.setTimeout(120000);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            
            request.setBody(body);
            
            HTTPResponse response = http.send(request);
            responseJson = response.getBody();            
            system.debug(response.getStatusCode());
            system.debug(response.getStatus());
            system.debug('res--'+responseJson);
            
            if (response.getStatusCode() != 200) {
                System.debug('Error message: ' + response.getStatus());
                return response.getStatus();
            }else{
                return responseJson;
            }
            
        } catch (Exception e) {
            ODS_ExceptionUtility.LogException(e);
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage());
            return e.getMessage();
        }
    }
    public static string GenerateAuthorizationToken() {
        try {
            JWT jwt = new JWT('HS256');
            jwt.privateKey = System.Label.JWT_Private_Key;
            jwt.iss = System.Label.JWT_Issuer;
            jwt.aud = System.Label.JWT_Aud;
            jwt.subject = System.Label.JWT_Subject;
            jwt.audience = System.Label.JWT_Audience;
            string token = jwt.GetToken();
            return token;
        } catch (Exception e) {
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage());
            return '';
        }
    }
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
}