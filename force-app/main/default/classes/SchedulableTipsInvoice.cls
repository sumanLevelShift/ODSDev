global class SchedulableTipsInvoice implements Schedulable {
 global void execute(SchedulableContext sc) {
       
        TipsInvoiceBatch InvoiceInstance = new TipsInvoiceBatch(); 
       database.executebatch(InvoiceInstance,1);
    }
    
 }