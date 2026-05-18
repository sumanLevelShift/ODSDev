global class TipsInvoiceBatch implements database.Batchable<Sobject>,Database.Stateful,Database.AllowsCallouts {
    public Set<Id> InvoiceIds=  new Set<Id> ();
    DateTime dt = System.Now().addHours(-1);   
    
    global database.QueryLocator start(database.BatchableContext context){
        string query ='';
        If(!boolean.valueOf(system.label.BC_Integration)){
            query = 'SELECT Tips_Work_Order__c,Invoice_Name__c,Billing_Start_Date__c,Billing_End_Date__c,blng__InvoiceDate__c,blng__TotalAmount__c,blng__Order__r.SBQQ__PaymentTerm__c,Deliverable__c FROM blng__Invoice__c where createddate>=:dt and Tips_Work_Order__c !=null';
        }else{
            query = 'SELECT Tips_Work_Order__c,Invoice_Name__c,Billing_Start_Date__c,Billing_End_Date__c,blng__InvoiceDate__c,blng__TotalAmount__c,blng__Order__r.SBQQ__PaymentTerm__c,Deliverable__c,BC_Invoice_ID__c,BC_Workorder__c FROM blng__Invoice__c where createddate>=:dt and BC_Workorder__c !=null';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(database.BatchableContext context , list<blng__Invoice__c> Scope ){
        for(blng__Invoice__c invoice:Scope){
            InvoiceIds.add(invoice.id);           
        }
        system.debug('InvoiceIds&&&&'+InvoiceIds);
    }
    
    global void finish(database.BatchableContext context){
        system.debug('InvoiceIds####'+InvoiceIds);
        if(InvoiceIds.size() > 0)
        {
            //invoice_API_Calls.AddInvoiceUsingAPI(InvoiceIds);
            If(!boolean.valueOf(system.label.BC_Integration)){
                invoice_API_Calls.AddInvoiceUsingAPI(InvoiceIds);
            }else{
                // call new BC Class.
               ODS_Invoice_BC_API_Helper.AddInvoiceUsingAPI(InvoiceIds);
            }
        }
        
        
    }
    
    
}