@RestResource(urlMapping='/tipsInvoiceStaging')
global class  TipsInvoiceStagingRestApi {
    @httpPost
    global static string insertInvoiceStaging(string startDate,string endDate,String tipsConsumptionWOId,string invoicePDF,string fileName){
        
        try{
            date iStartDate=Date.parse(startDate);
            date iEndDate=Date.parse(endDate);
            List<TIPS_Invoice_Staging__c> invoiceStatingList=[Select Id,Consumption_WO_ID__c,Invoice_Start_Date__c,Invoice_End_Date__c From TIPS_Invoice_Staging__c 
                                                              WHERE Is_Email_Info__c=false AND Consumption_WO_ID__c=:tipsConsumptionWOId AND Invoice_Start_Date__c=:iStartDate AND Invoice_End_Date__c=:iEndDate];
            TIPS_Invoice_Staging__c invoiceStaging=new TIPS_Invoice_Staging__c();
            if(!invoiceStatingList.isEmpty()){
                invoiceStaging.Id=invoiceStatingList[0].Id;
            }
            invoiceStaging.Invoice_Start_Date__c=iStartDate;
            invoiceStaging.Invoice_End_Date__c=iEndDate;
            invoiceStaging.Consumption_WO_ID__c=tipsConsumptionWOId;
            invoiceStaging.Invoice_PDF__c=invoicePDF;
            invoiceStaging.File_Name__c=fileName;
            invoiceStaging.Is_Email_Info__c=false;
            Upsert invoiceStaging;   
            return 'Successfully Added TIPS Invoice Statging for this Workorder Id - '+tipsConsumptionWOId+' and Invoice Statging Record ID - '+invoiceStaging.Id;
        } catch(Exception e){
            ODS_ExceptionUtility.LogException(e);
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return 'Error Message: '+e.getMessage() +' in '+e.getStackTraceString();
        }
    }
}