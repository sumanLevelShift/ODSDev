global class ODSInvoiceInsertionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query='Select Id,Consumption_WO_ID__c,Invoice_Start_Date__c,Invoice_End_Date__c,Invoice_PDF__c,File_Name__c,Email_Body__c,Email_CC__c,Email_To__c,Subject__c From TIPS_Invoice_Staging__c WHERE Is_Email_Info__c=false ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<TIPS_Invoice_Staging__c> invoiceStagingList) {
        Map<string,TIPS_Invoice_Staging__c> tipsInvoiceStagingMap=new Map<string,TIPS_Invoice_Staging__c>();
        Map<string,string> tipsIdWithFileName=new Map<string,string>();
        try{
            for(TIPS_Invoice_Staging__c iStaging:invoiceStagingList){
                tipsInvoiceStagingMap.put(iStaging.Consumption_WO_ID__c,iStaging);
                tipsIdWithFileName.put(iStaging.Consumption_WO_ID__c,iStaging.File_Name__c);
            }
            system.debug('tipsInvoiceStagingMap-'+tipsInvoiceStagingMap);
            //Map<string,String> tipsIdAndBillingType=ODSInvoiceInsertionController.getBillingType(tipsInvoiceStagingMap.keySet());
            //key is tipsId and pair is accountId
            Map<string,Id> tipsIdANdAccountIdSet=ODSInvoiceInsertionController.getAccountId(tipsInvoiceStagingMap.keySet());
            system.debug('tipsIdANdAccountIdSet-'+tipsIdANdAccountIdSet);
            //key is accountId and pair is account service
            Map<Id,Account_Services__c> accountServiceWithAccId=ODSInvoiceInsertionController.getAccountService(tipsIdANdAccountIdSet.Values());
            system.debug('accountServiceWithAccId-'+accountServiceWithAccId);
            
            List<Invoice__c> newInvoiceList=new List<Invoice__c>();
            for(string tipsConId:tipsInvoiceStagingMap.keySet()){
                string accountId=tipsIdANdAccountIdSet.get(tipsConId);
                Account_Services__c accountService=accountServiceWithAccId.get(accountId);
                TIPS_Invoice_Staging__c invoiceStaging=tipsInvoiceStagingMap.get(tipsConId);
                
                if(accountService !=null){
                    Date invoiceStartDate=invoiceStaging.Invoice_Start_Date__c;
                    Date invoiceEndDate=invoiceStaging.Invoice_End_Date__c;
                    Datetime invoiceStartDateTime = DateTime.newinstance(invoiceStartDate.year(),invoiceStartDate.month(),invoiceStartDate.day());
                    system.debug('invoiceStartDateTime.fo-'+invoiceStartDateTime.format('MMMM'));
                    Invoice__c invoiceRecord = new Invoice__c();
                    invoiceRecord.Account_Services__c=accountService.Id;
                    invoiceRecord.Account__c=accountId;
                    invoiceRecord.Billing_Start_Date__c=invoiceStaging.Invoice_Start_Date__c;
                    invoiceRecord.Billing_End_Date__c=invoiceStaging.Invoice_End_Date__c;
                    invoiceRecord.Year__c=invoiceStartDate.year();
                    invoiceRecord.Month__c=invoiceStartDateTime.format('MMMM');
                    invoiceRecord.Invoice_Type__c = 'ODS';
                    invoiceRecord.TIPS_CNSMP_WO_ID__c=tipsConId;
                    //invoiceRecord.Billing_Type__c=tipsIdAndBillingType.get(tipsConId);
                    invoiceRecord.Status__c='Saved';
                    list<Invoice__c> existingInvoice=[Select Id From Invoice__c WHERE Billing_Start_Date__c=:invoiceStaging.Invoice_Start_Date__c AND
                                               Billing_End_Date__c=:invoiceStaging.Invoice_End_Date__c AND Account_Services__c=:accountService.Id 
                                               AND Account__c=:accountId LIMIT 1];
                    if(!existingInvoice.isEmpty()){
                      invoiceRecord.id= existingInvoice[0].id;
                    }
                    newInvoiceList.add(invoiceRecord);
                }
            }
            if(!newInvoiceList.isEmpty()){
                Set<Id> invoiceId=new Set<Id>();
                Database.UpsertResult[] saveResultList = Database.upsert(newInvoiceList, false);
                for (Database.UpsertResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        invoiceId.add(sr.getId());
                    }
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                Set<String> insertedTipsId=new Set<String>();
                List<Invoice__c> invoiceRecordsList=new List<Invoice__c>();
                List<TIPS_Invoice_Staging__c> tipsInvoiceStagingDeletion = new List<TIPS_Invoice_Staging__c>();

                Map<Id,Invoice__c> invoiceRecords=new Map<Id,Invoice__c>([Select ID,Account_Services__c,Account__c,Account__r.Name,Billing_End_Date__c,Billing_Start_Date__c,TIPS_CNSMP_WO_ID__c,Email__c,Invoice_CC__c FROM Invoice__c WHERE Id IN:invoiceId ]);
                for(Invoice__c invoice:invoiceRecords.Values()){
                    insertedTipsId.add(invoice.TIPS_CNSMP_WO_ID__c);
                    TIPS_Invoice_Staging__c invoiceStaging=tipsInvoiceStagingMap.get(invoice.TIPS_CNSMP_WO_ID__c);
                    List<ContentDocumentLink> condoclink = new List<ContentDocumentLink>();
                    condoclink = [SELECT id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: invoice.Id];
                    Boolean hasTimesheetFile = false;
                    Boolean hasInvoiceFile = false;
                    if(!condoclink.isEmpty())
                    {
                        Set<id> condoset = new Set<id>(); 
                        for(ContentDocumentLink condl : condoclink){
                            condoset.add(condl.ContentDocumentId);
                        }
                        
                        List<ContentVersion> conv = new List<ContentVersion>();
                        conv = [SELECT id,Type__c,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: condoset];                
                        
                        for(ContentVersion c : conv){
                            if(c.Type__c == 'Timesheet'){
                                hasTimesheetFile = true;
                            }
                            
                            else if(c.Type__c == 'Invoice'){
                                hasInvoiceFile = true;
                            }
                            
                        }                 
                    }
                    //Account Name Invoice 
                    string invoicePDFName=tipsIdWithFileName.get(invoice.TIPS_CNSMP_WO_ID__c);
                    ODSInvoiceInsertionController.insertTimesheetPDFToInvoice(invoice.Account_Services__c, invoice.Billing_Start_Date__c, invoice.Billing_End_Date__c,invoice.Id,invoice.TIPS_CNSMP_WO_ID__c,hasTimesheetFile);
                    if(invoiceStaging !=null){
                        ODSInvoiceInsertionController.insertInvoicePDF(invoiceStaging.Invoice_PDF__c,invoice.id,invoicePDFName,hasInvoiceFile);
                    }
                    Invoice__c i=new Invoice__c();
                    i.id=invoice.id;
                    i.Uploaded_by__c=UserInfo.getUserId();
                    i.Uploaded_Date__c=system.now();
                    i.Attachment_File__c=invoicePDFName;
                    TIPS_Invoice_Staging__c tipsEmailInfo=ODSInvoiceInsertionController.getEmailInfoInvoice(invoice.TIPS_CNSMP_WO_ID__c, invoice.Billing_Start_Date__c, invoice.Billing_End_Date__c);
                    if(tipsEmailInfo != null){
                        i.Status__c='Submitted';
                        string emailto = '';
                        Set<String> emailSet = new Set<String>();
                        
                        if (String.isBlank(invoice.Email__c)) {
                            emailSet.add(tipsEmailInfo.Email_To__c);
                        } else {
                            List<String> toValues = invoice.Email__c.split(',');

                            emailSet.addAll(toValues);
                            emailSet.add(tipsEmailInfo.Email_To__c);
                        }
                        
                        emailto = String.join(new List<String>(emailSet), ',');
                        
                        string invoiceCC = '';
                        Set<String> ccSet = new Set<String>();
                        
                        if (String.isBlank(invoice.Invoice_CC__c)) {
                            ccSet.add(tipsEmailInfo.Email_CC__c);
                        } else {
                            List<String> ccValues = invoice.Invoice_CC__c.split(',');
                            ccSet.addAll(ccValues);
                            ccSet.add(tipsEmailInfo.Email_CC__c);
                        }
                        
                        invoiceCC = String.join(new List<String>(ccSet), ',');
                        
                        i.Email__c=emailto;
                        i.Invoice_CC__c=invoiceCC;
                        i.Subject__c=tipsEmailInfo.Subject__c;
                        i.Email_Body__c=tipsEmailInfo.Email_Body__c;
                        tipsInvoiceStagingDeletion.add(tipsEmailInfo);
                    }
                    invoiceRecordsList.add(i);
                }
                If(!invoiceRecordsList.isEmpty()){
                    update invoiceRecordsList;
                }
                for(string i:insertedTipsId){
                    tipsInvoiceStagingDeletion.add(tipsInvoiceStagingMap.get(i));
                }
                system.debug('tipsInvoiceStagingDeletion 1--'+tipsInvoiceStagingDeletion);
                if(!tipsInvoiceStagingDeletion.isEmpty()){
                    Delete tipsInvoiceStagingDeletion;
                }
            }
        } catch(Exception e)    
        {
            ODS_ExceptionUtility.LogException(e);
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            ODSInvoiceInsertionController.sendMailForFailureInvoice(e);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}