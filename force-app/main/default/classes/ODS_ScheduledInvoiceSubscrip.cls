/*
*Author: Mani and Team
*Purpose: Schdeuler class for Monthly Subscription batch
*Created on: 06/JUN/2018
*Test Class: ODS_Invoice_Subsc_MonthlyBatch_Test
*/
global class ODS_ScheduledInvoiceSubscrip implements Schedulable {
    global void execute(SchedulableContext sc) {
        //Monthly batch class
        String monthlyQry = 'SELECT Id,Account__c,Account__r.Name,Account__r.SOW__c,'+
                            'Account__r.Primary_Customer_Email_OptOut__c,'+
                            'Account__r.Primary_Customer_Email_Id__c,Account__r.BillingStreet,'+
                            'Account__r.BillingCity,Account__r.BillingState,Account__r.BillingCountry,Account__r.BillingPostalCode,'+
                            'Account__r.Invoice_Type__c,Account__r.ODS_Invoice_Contact_Email__c,'+
                            'Retainer_Fee_Frequency_Type__c,Retainer_Fee_Amount__c,Purchase_Order__c,'+
                            'Subscription_Fee_Discount__c,Contract_Start_Date__c,Account__r.InvoiceContact__c,'+
                            'Contract_End_Date__c,Invoice_MnthSubs_Date__c,Invoice_Sent__c,Invoice_Monthly_Subscription_Discount__c,'+
                            'Contract_Term__c,Account__r.SOW_Status_Date__c,ODS_Service_Name__c,'+
                            'Account__r.ODS_Invoice_Account_Number__c,Account__r.ODS_Invoice_Count__c'+
                            ' FROM Account_Services__c '+
                            ' WHERE Account__r.SOW__c = \'Fully Executed\' AND Do_not_send_invoice__c = false AND '+ 
                            ' Contract_End_Date__c != null AND Retainer_Fee_Frequency_Type__c = \'Monthly\' AND '+ 
                            ' Retainer_Fee_Amount__c != null AND Trigger_Subscription_Invoice__c = true';                      
        
        ODS_Invoice_Subsc_MonthlyBatch mon = new ODS_Invoice_Subsc_MonthlyBatch(monthlyQry); 
        database.executebatch(mon,5); //Running batch of 5 records to avoid governor limits        
    }
}