global class ODSInvoiceInsertionSchedular implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext sc) {
            ODSInvoiceInsertionBatch invoiceBatch = new ODSInvoiceInsertionBatch();
            Database.executeBatch(new ODSInvoiceInsertionBatch(),1);
       
    }
}