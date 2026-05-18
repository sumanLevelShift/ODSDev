public without sharing class ODSInvoiceInsertionController {
    /*public static Map<string,String> getBillingType(Set<string> tipsId){
        system.debug('tipsId-'+tipsId);
        List<Work_Order__c> workOrderList=[ Select Id,Client_Name__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c From Work_Order__c 
                                           WHERE TIPS_CNSMP_WO_ID__c IN: tipsId OR TIPS_Admin_CNSMP_WO_ID__c IN: tipsId OR TIPS_Consulting_CNSMP_WO_ID__c IN: tipsId];
        Map<string,String> tipsIdAndBillingType=new Map<string,String>();
        system.debug('workOrderList-'+workOrderList);
        for(Work_Order__c wo:workOrderList){
            if(tipsId.Contains(wo.TIPS_CNSMP_WO_ID__c))
                tipsIdAndBillingType.put(wo.TIPS_CNSMP_WO_ID__c,'Build'); 
            if(tipsId.Contains(wo.TIPS_Admin_CNSMP_WO_ID__c))
                tipsIdAndBillingType.put(wo.TIPS_Admin_CNSMP_WO_ID__c,'Admin'); 
            if(tipsId.Contains(wo.TIPS_Consulting_CNSMP_WO_ID__c))
                tipsIdAndBillingType.put(wo.TIPS_Consulting_CNSMP_WO_ID__c,'Consulting'); 
        }
        return tipsIdAndBillingType;
    }*/
    public static Map<string,ID> getAccountId(Set<string> tipsId){
        system.debug('tipsId-'+tipsId);
        List<Work_Order__c> workOrderList=[ Select Id,Client_Name__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c From Work_Order__c 
                                           WHERE TIPS_CNSMP_WO_ID__c IN: tipsId OR TIPS_Admin_CNSMP_WO_ID__c IN: tipsId OR TIPS_Consulting_CNSMP_WO_ID__c IN: tipsId];
        Map<string,Id> tipsIdANdAccountIdSet=new Map<string,Id>();
        system.debug('workOrderList-'+workOrderList);
        for(Work_Order__c wo:workOrderList){
            if(tipsId.Contains(wo.TIPS_CNSMP_WO_ID__c))
                tipsIdANdAccountIdSet.put(wo.TIPS_CNSMP_WO_ID__c,wo.Client_Name__c); 
            if(tipsId.Contains(wo.TIPS_Admin_CNSMP_WO_ID__c))
                tipsIdANdAccountIdSet.put(wo.TIPS_Admin_CNSMP_WO_ID__c,wo.Client_Name__c); 
            if(tipsId.Contains(wo.TIPS_Consulting_CNSMP_WO_ID__c))
                tipsIdANdAccountIdSet.put(wo.TIPS_Consulting_CNSMP_WO_ID__c,wo.Client_Name__c); 
        }
        return tipsIdANdAccountIdSet;
    }
    public static Map<Id,Account_Services__c> getAccountService(List<id> accountId){
        List<Account_Services__c> accountService=[Select Id,Account__c From Account_Services__c WHERE Account__c IN:accountId];
        Map<Id,Account_Services__c> accountServiceWithAccId=new Map<Id,Account_Services__c>();
        for(Account_Services__c aSer:accountService){
            accountServiceWithAccId.put(aSer.Account__c,aSer);
        }
        return accountServiceWithAccId;
    }
    public static TIPS_Invoice_Staging__c getEmailInfoInvoice(string tipsId,date startDate,date endDate){
        TIPS_Invoice_Staging__c tipsIS=[Select Id,Email_Body__c,Email_CC__c,Email_To__c,Subject__c From TIPS_Invoice_Staging__c 
                                        WHERE Is_Email_Info__c=true AND Consumption_WO_ID__c=:tipsId AND Invoice_Start_Date__c=:startDate AND Invoice_End_Date__c=:endDate];
        return tipsIS;
    }
    public static void insertTimesheetPDFToInvoice(Id accountServiceId, Date startDate, Date endDate, String invoiceId,string tipsId,boolean hasTimesheetFile){
        //string name=tipsId+'%';
        Datetime stTimesheetDate = DateTime.newinstance(startDate.year(),startDate.month(),startDate.day());
        Datetime enTimesheetDate = DateTime.newinstance(endDate.year(),endDate.month(),endDate.day());
        string name='%'+' - '+stTimesheetDate.format('MM-dd-yyyy')+' to '+enTimesheetDate.format('MM-dd-yyyy')+'%';
        Map<Id,Timesheet__c> timesheetList=new Map<Id,Timesheet__c>([Select Id From Timesheet__c WHERE (Status__c=:'Submitted' OR Status__c=:'Approved') AND Account_Services__c =:accountServiceId AND ((Week_Start_Date__c >=: startDate and Week_End_Date__c <=: endDate ) OR (Week_Start_Date__c <: startDate AND Week_End_Date__c >: startDate) OR (Week_Start_Date__c <: endDate AND Week_End_Date__c >: endDate))]);
        system.debug('timesheetList--'+timesheetList.keySet());
        set<Id> contentDocIDList = new set<Id>();
        for(ContentDocumentLink conDocLink : [SELECT ContentDocumentId,Id FROM ContentDocumentLink WHERE ContentDocument.Title LIKE :name AND LinkedEntityId = :timesheetList.keySet()]){
            contentDocIDList.add(conDocLink.ContentDocumentId);
        }
        Map<String, ContentVersion> ContentVersionMap = new Map<String, ContentVersion>();
        List<ContentVersion> cvList=[SELECT ContentDocumentId,Title,Type__c,PathOnClient,VersionData FROM ContentVersion WHERE Title LIKE :name AND ContentDocumentId IN:contentDocIDList ORDER BY CreatedDate DESC NULLS FIRST];
        
        for (ContentVersion c : cvList) {
            if (!ContentVersionMap.containsKey(c.Title)) {
                ContentVersionMap.put(c.Title, c);
            }
        }
        for(ContentVersion c:ContentVersionMap.Values()){
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = c.PathOnClient; 
            conVer.Title = c.Title; 
            conVer.VersionData = c.VersionData;
            if(!hasTimesheetFile){
                conVer.Type__c = 'Timesheet';
            }else{
                conVer.Type__c = 'Supporting Document';
            }
            insert conVer; 
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
            cdl.LinkedEntityId = invoiceId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
        
    }
    public static void insertInvoicePDF(string body,string invoiceId,string fileName,boolean hasInvoiceFile){
        if(string.isNotBlank(body)){
          
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = fileName; 
            conVer.Title = fileName; 
            conVer.VersionData = EncodingUtil.base64Decode(body);
            if(!hasInvoiceFile){
                conVer.Type__c = 'Invoice';
            }else{
                conVer.Type__c = 'Supporting Document';
            }
            insert conVer; 
            ContentDocumentLink cdl = new ContentDocumentLink();
            id contentdocumentid = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
            cdl.ContentDocumentId = contentdocumentid;
            cdl.LinkedEntityId = invoiceId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
    }
    public static void sendMailForFailureInvoice(Exception e){
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        List<string> sendToList = System.Label.InvoiceUser.Split(',');
        Messaging.SingleEmailMessage failureEmail = new Messaging.SingleEmailMessage();
        failureEmail.setSubject('ODS Invoice Insertion is Failed');
        string strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>';
        strHtmlBody +='<p> ODS Invoice insertion is failed. Please find the below error message,</p>';
        strHtmlBody +='<p> <b>Message: </b>'+e.getMessage()+'</p><p><b>Stack Trace: </b>'+stackTrace+'</p></td></tr></table><br/>Thanks,<br/><br/>LevelShift Admin<br/>';
        failureEmail.setToAddresses(sendToList);
        failureEmail.setHtmlBody(strHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{failureEmail});    
    }
    
}