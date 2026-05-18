global class SchedulableAccountService implements Schedulable{
    global void execute(SchedulableContext sc) {
       
        AccountServiceInvoice InvoiceInstance = new AccountServiceInvoice(); 
       database.executebatch(InvoiceInstance,1);
    }
 }