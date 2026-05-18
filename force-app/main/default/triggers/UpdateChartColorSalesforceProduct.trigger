trigger UpdateChartColorSalesforceProduct on Salesforce_Product__c (After insert,after update) {
    if(Trigger.isAfter)
    {
       UpdateChartColorHelper.salesforceProduct(Trigger.new);
    }
}