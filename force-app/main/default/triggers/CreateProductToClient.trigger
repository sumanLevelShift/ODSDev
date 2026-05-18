trigger CreateProductToClient on Salesforce_Product__c (after insert,before delete,after update) 
{
    List<Salesforce_Product__c> updateSalesforceProduct=new List<Salesforce_Product__c>();
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {

            ProductClientUsageHelper.createSalesforceProductToClient(trigger.new);
            
        }
    }

    if(Trigger.isBefore)
    {
        if(Trigger.isDelete)
        {
           
            /* if(ProductClientUsageHelper.quoteRecursion)
                return;
            ProductClientUsageHelper.quoteRecursion = true;
            */
            ProductClientUsageHelper.deleteSalesforceProductToClient(trigger.old);
        }
    }
}