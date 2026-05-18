trigger CreateProductFeatureToClient on Salesforce_Product_Feature__c (after insert,after Update,before delete) {
   
    if(Trigger.isAfter && Trigger.isInsert)
    {
        ProductClientUsageHelper.createSalesforceFeatureProductToClient(Trigger.New);
        ProdFeatureDetailsUpdate.updateFeatureIDinFeatureDetails(Trigger.New);
    }
     if(Trigger.isAfter && Trigger.isUpdate)
    {
      ProductClientUsageHelper.updateProductClientFeature(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isDelete){
       ProductClientUsageHelper.deleteProductClientFeature(trigger.old); 
    }
}