/*
*Author.............: Mani & Team
*Date...............: 17/May/2018
*Purpose............: Update running Invoice record number & month back to Account
*TestClass..........: ODS_TimeSheetController_Test and InvoiceTrigger_Test
*/
trigger InvoiceTrigger on Invoice__c (before insert, after insert) {
    
    if(trigger.isBefore) {
        if(trigger.isInsert) {                                            
            for(Invoice__c inv:trigger.New) {  
                //Get the current day for invoice counter
                if(inv.Invoice_Type__c == 'ODS'){
                    Integer invCount = (System.today().day()-1);
                    
                    if(inv.Invoice_Month__c == null || inv.Invoice_Month__c == System.today().month()) {                                      
                        if(inv.Invoice_Count__c != null && inv.Invoice_Count__c != 0) invCount = Integer.valueOf(inv.Invoice_Count__c);
                        inv.Invoice_Number__c = invCount+1;                
                    }else if(inv.Invoice_Month__c != System.today().month()){                    
                        //No need to consider the existing invoice running number, reset the value to current month*/
                        inv.Invoice_Number__c = invCount+1;
                    }
                }
            }
        }
    }
    
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            
            List<Account> lAccToUpd = new List<Account>();
            for(Invoice__c inv:trigger.New) {
                if(inv.Invoice_Type__c == 'ODS'){
                    Account acc = new Account(Id=inv.Invoice_AccountId__c,ODS_Invoice_Count__c=inv.Invoice_Number__c,
                                              ODS_Invoice_Mth__c=system.today().month());                
                    lAccToUpd.add(acc);
                }
            }
            
            if(!lAccToUpd.isEmpty()) {
                update lAccToUpd;
            }
        }
    }
}