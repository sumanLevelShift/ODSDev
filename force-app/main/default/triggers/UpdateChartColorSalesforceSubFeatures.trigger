trigger UpdateChartColorSalesforceSubFeatures on Salesforce_Product_Subfeature__c (After insert,after Update) {
    if(Trigger.isAfter)
    {
        UpdateChartColorHelper.salesforceProductFeature(Trigger.New);
    }
}