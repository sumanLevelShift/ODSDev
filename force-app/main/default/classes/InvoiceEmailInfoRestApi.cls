@RestResource(urlMapping='/tipsInvoiceEmailInfo')
global class InvoiceEmailInfoRestApi {
    @httpPost
    global static String invoiceStagingEmailInfo(string startDate,string endDate,String tipsConsumptionWOId,string emailTo,string emailCC,string emailBody,string emailSubject){
        
        try{
            system.debug('emailBody'+emailBody);
            system.debug('emailSubject'+emailSubject);
            //startdate -> mm/dd/yyyy
            Date startDateValue = Date.parse(startDate);
            Date endDateValue = Date.parse(endDate);
            List<TIPS_Invoice_Staging__c> invoiceStatingList=[Select Id,Consumption_WO_ID__c,Invoice_Start_Date__c,Invoice_End_Date__c From TIPS_Invoice_Staging__c 
                                                              WHERE Is_Email_Info__c=true AND Consumption_WO_ID__c=:tipsConsumptionWOId AND Invoice_Start_Date__c=:startDateValue AND Invoice_End_Date__c=:endDateValue LIMIT 1];
            
            TIPS_Invoice_Staging__c invoiceStaging=new TIPS_Invoice_Staging__c();
            invoiceStaging.Email_To__c=emailTo;
            invoiceStaging.Email_CC__c=emailCC;
            invoiceStaging.Email_Body__c=emailBody;
            invoiceStaging.Subject__c=emailSubject;
            invoiceStaging.Is_Email_Info__c=true;
            invoiceStaging.Invoice_Start_Date__c=startDateValue;
            invoiceStaging.Invoice_End_Date__c=endDateValue;
            invoiceStaging.Consumption_WO_ID__c=tipsConsumptionWOId;
            if(!invoiceStatingList.isEmpty()){
                invoiceStaging.Id= invoiceStatingList[0].Id;
            }
            Upsert invoiceStaging;
            
            return 'Successfully Added TIPS Invoice Statging for this Workorder Id - '+tipsConsumptionWOId+' and Invoice Statging Record ID - '+invoiceStaging.Id;
            
        } catch(Exception e)    
        {
            ODS_ExceptionUtility.LogException(e);
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return 'Error Message: '+e.getMessage() +' in '+e.getStackTraceString()+'.';
        }
    }
}