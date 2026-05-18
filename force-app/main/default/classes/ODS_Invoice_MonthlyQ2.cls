public class ODS_Invoice_MonthlyQ2 implements Queueable,Database.AllowsCallouts {
    Set<Id> sAccServIds;
    public ODS_Invoice_MonthlyQ2(Set<Id> records) {
        this.sAccServIds = records;
    }
    public void execute(QueueableContext context) {
        List<Account_Services__c> lAcLog = new List<Account_Services__c>();
        List<Account_Services__c> lAccServ = new List<Account_Services__c>([SELECT Id,Account__r.SOW__c,
                        Account__r.Primary_Customer_Email_OptOut__c,Account__r.SOW_Start_Date__c,Invoice_MnthSubs_Sent__c,
                        Contract_Start_Date__c,Contract_End_Date__c,Invoice_MnthSubs_Date__c                       
                    FROM Account_Services__c 
                    WHERE Account__r.SOW__c = 'Fully Executed' AND Do_not_send_invoice__c = false AND  
                        Contract_End_Date__c != null AND Retainer_Fee_Frequency_Type__c = 'Monthly' AND  
                        Retainer_Fee_Amount__c != null AND Id IN:sAccServIds]);
         if(!lAccServ.isEmpty()) {               
             for(Account_Services__c asId:lAccServ) { 
                if((asId.Invoice_MnthSubs_Date__c == null || asId.Invoice_MnthSubs_Date__c.month() < System.Today().month()) 
                        && (asId.Invoice_MnthSubs_Date__c == null || asId.Invoice_MnthSubs_Date__c < asId.Contract_End_Date__c)) {           
                    asId.Invoice_MnthSubs_Date__c = System.today();   
                    asId.Invoice_MnthSubs_Sent__c = true;        
                    lAcLog.add(asId);
                }
            }
        }
        if(!lAcLog.isEmpty()) {
            update lAcLog;
        }    
    }
}