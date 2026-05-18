global class ODS_ScheduledInvoiceMnthTimShet implements Schedulable {
    global void execute(SchedulableContext sc) {
        //Monthly batch class
        String monthlyQry = 'SELECT Id,Account__c,Account__r.Name,Account__r.SOW__c,Account__r.InvoiceContact__c,'+
                            'Account__r.Primary_Customer_Email_OptOut__c,Invoice_MnthTimSheet_Date__c,'+
                            'Account__r.Primary_Customer_Email_Id__c,Account__r.BillingStreet,Purchase_Order__c,'+
                            'Account__r.BillingCity,Account__r.BillingState,Account__r.BillingCountry,Account__r.BillingPostalCode,'+
                            'Account__r.Invoice_Type__c,Account__r.ODS_Invoice_Contact_Email__c,'+
                            'Retainer_Fee_Frequency_Type__c,Retainer_Fee_Amount__c,Invoice_MnthTimShet_Sent__c,'+
                            'Subscription_Fee_Discount__c,Contract_Start_Date__c,ODS_Hourly_Rate_Amount__c,'+
                            'Contract_End_Date__c,Invoice_MnthSubs_Date__c,Invoice_Sent__c,'+
                            'Contract_Term__c,Account__r.SOW_Status_Date__c,ODS_Service_Name__c,Account__r.InvoiceContact__r.Name,'+
                            'Account__r.ODS_Invoice_Account_Number__c,Account__r.ODS_Invoice_Count__c'+
                            ' FROM Account_Services__c '+
                            ' WHERE ODS_Hourly_Rate_Amount__c != null AND Do_not_send_invoice__c = false AND '+ 
                            ' Contract_End_Date__c != null AND Invoice_Frequency__c = \'Monthly\'';                      
        
        ODS_Invoice_TimShet_MonthlyBatch mon = new ODS_Invoice_TimShet_MonthlyBatch(monthlyQry); 
        database.executebatch(mon,1); //Running batch of 1 records to avoid governor limits        
    }
}