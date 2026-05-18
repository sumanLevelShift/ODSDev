/*
*Author.............: Mani & Team
*Date...............: 17/May/2018
*Purpose............: Send invoice to customer when Account services subscription type updated to -Monthly-
*TestClass..........: ODS_Invoice_Monthly_Test
*/
public class ODS_Invoice_Monthly
{
    public static void sendMonthlyInvoice(List<Account_Services__c> lAsv,Map<Id,Account_Services__c> mOldAcs,String runningEvent) {
        Set<Id> sAsv = new Set<Id>();  
        for(Account_Services__c acs:lAsv) {            
            //After Insert context
            if(runningEvent == 'AfterInsert') {
                System.debug('@@MonthlyInvoice: '+acs.Retainer_Fee_Frequency_Type__c+'-'+acs.Do_not_send_invoice__c+
                    '-'+acs.Trigger_Subscription_Invoice__c
                    +'-'+acs.Contract_End_Date__c+'-'+acs.Retainer_Fee_Amount__c);
                if(acs.Retainer_Fee_Frequency_Type__c.equalsIgnoreCase('Monthly') && acs.Do_not_send_invoice__c == false
                    && acs.Trigger_Subscription_Invoice__c == true && acs.Invoice_Trial_Running__c == false
                    && acs.Contract_End_Date__c != null && acs.Retainer_Fee_Amount__c != null) {
                    sAsv.add(acs.Id);
                }
            }else if(runningEvent == 'AfterUpdate'){
                //After Update context
                Account_Services__c oldAcs = mOldAcs.get(acs.Id);                
                if(acs.Retainer_Fee_Frequency_Type__c.equalsIgnoreCase('Monthly') && acs.Do_not_send_invoice__c == false
                    && acs.Trigger_Subscription_Invoice__c == true && acs.Invoice_Trial_Running__c == false
                    && (acs.Contract_End_Date__c != oldAcs.Contract_End_Date__c || 
                    acs.Retainer_Fee_Amount__c != oldAcs.Retainer_Fee_Amount__c || 
                    acs.Retainer_Fee_Frequency_Type__c != oldAcs.Retainer_Fee_Frequency_Type__c ||
                    acs.Trigger_Subscription_Invoice__c != oldAcs.Trigger_Subscription_Invoice__c)) {
                    sAsv.add(acs.Id);
                }
            }
        }
        
        if(!sAsv.isEmpty()) {
            if(Boolean.valueOf(System.Label.ODS_Invoice_SendEmail)) {                                
                //Queueable jobs
                System.enqueueJob(new ODS_Invoice_MonthlyQ1(sAsv));                
            }
        }
    }        
        
}