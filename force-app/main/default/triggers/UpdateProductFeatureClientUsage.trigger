trigger UpdateProductFeatureClientUsage on Product_Feature_Client_Usage__c (after insert,after update,before delete) {
    List<Product_Feature_Client_Usage__c> updateRecordList=new List<Product_Feature_Client_Usage__c>();
    List<Product_Client_Usage__c> updateAllocation=new list<Product_Client_Usage__c>();
    set<string> accountIdList=new set<string>();
    set<string> salesforceProductIdList=new set<string>();
    if(Trigger.isAfter && !ProductClientUsageHelper.quoteRecursion)
    {
        if(Trigger.isInsert)
        {
            For(Product_Feature_Client_Usage__c p:Trigger.new){
                AggregateResult[] aggregateList=[SELECT Sum(Client_Overall_Usage__c),sum(Feature_Percentage__c),sum(Client_Usage_Percentage__c),Salesforce_Product__c,Account__c  FROM Product_Feature_Client_Usage__c 
                                                 where Account__c=:p.Account__c group by Salesforce_Product__c,Account__c];
                for(AggregateResult ar:aggregateList)
                {
                    decimal allocation=0;
                    decimal total=0;
                    decimal totalOfClient=0;
                    decimal clientOverallUsage=(decimal)ar.get('expr0');
                    decimal featureUsage=(decimal)ar.get('expr1');
                    if(featureUsage !=0 || featureUsage !=0.0 ){
                        
                        allocation=(clientOverallUsage/featureUsage)*100;
                        
                        allocation=allocation.setScale(0);
                    }
                    Product_Client_Usage__c productClientList=[SELECT Id,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c
                                                               where Salesforce_Product__c=:(ID)ar.get('Salesforce_Product__c') And Account__c=:(ID)ar.get('Account__c') limit 1];
                    productClientList.Salesforce_Product_Usage__c=allocation;
                    productClientList.Sum_Of_Feature_Weightage__c=featureUsage;
                    updateAllocation.add(productClientList);
                    
                }
                break;
            }
            if(!updateAllocation.isEmpty()){
                update updateAllocation;
            }
        }
        
        if(Trigger.isUpdate)
        {
            List<Product_Client_Usage__c> updateAllocationU=new list<Product_Client_Usage__c>();
            
            if(SalesforceUtilizationBasisHelper.firstRun){
                SalesforceUtilizationBasisHelper.firstRun=false;
                For(Product_Feature_Client_Usage__c p:Trigger.new){
                    system.debug('p--'+p);
                    AggregateResult[] aggregateList=[SELECT Sum(Client_Overall_Usage__c),sum(Feature_Percentage__c),sum(Client_Usage_Percentage__c),Product_Client_Usage__c  FROM Product_Feature_Client_Usage__c 
                                                     where Account__c=:p.Account__c AND Product_Client_Usage__c=:p.Product_Client_Usage__c group by Product_Client_Usage__c];
                    for(AggregateResult ar:aggregateList)
                    {
                        system.debug('ar--'+ar);
                        decimal allocation=0;
                        decimal total=0;
                        decimal totalOfClient=0;
                        decimal clientOverallUsage=(decimal)ar.get('expr0');
                        decimal featureUsage=(decimal)ar.get('expr1');
                        if(featureUsage !=0 || featureUsage !=0.0 ){
                            allocation=(clientOverallUsage/featureUsage)*100;
                            allocation=allocation.setScale(0);
                        }
                        Product_Client_Usage__c productClientList=[SELECT Id,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c
                                                                   where Id=:(ID)ar.get('Product_Client_Usage__c') limit 1];
                        productClientList.Salesforce_Product_Usage__c=allocation;
                        productClientList.Sum_Of_Feature_Weightage__c=featureUsage;
                        updateAllocationU.add(productClientList);
                        
                    }
                    break;
                }
                if(!updateAllocationU.isEmpty()){
                    system.debug('updateAllocation--'+updateAllocationU.size());
                    system.debug('updateAllocation--'+updateAllocationU);
                    update updateAllocationU;
                }
            }
        }
    }
    if(Trigger.isBefore && Trigger.isDelete && !ProductClientUsageHelper.quoteRecursion){
        For(Product_Feature_Client_Usage__c p:Trigger.old){
            AggregateResult[] aggregateList=[SELECT Sum(Client_Overall_Usage__c),sum(Feature_Percentage__c),sum(Client_Usage_Percentage__c),Salesforce_Product__c,Account__c  FROM Product_Feature_Client_Usage__c 
                                             where Account__c=:p.Account__c and Id !=:p.id AND Product_Client_Usage__c !=null group by Salesforce_Product__c,Account__c];
            for(AggregateResult ar:aggregateList)
            {
                decimal allocation=0;
                decimal total=0;
                decimal totalOfClient=0;
                decimal sumOfClientUsage=(decimal)ar.get('expr2');
                
                decimal clientOverallUsage=(decimal)ar.get('expr0');
                decimal featureUsage=(decimal)ar.get('expr1');
                if(featureUsage !=0 || featureUsage !=0.0 ){
                    
                    allocation=(clientOverallUsage/featureUsage)*100;
                    
                    allocation=allocation.setScale(0);
                }
                Product_Client_Usage__c productClientList=[SELECT Id,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c
                                                           where Salesforce_Product__c=:(ID)ar.get('Salesforce_Product__c') And Account__c=:(ID)ar.get('Account__c') limit 1];
                productClientList.Salesforce_Product_Usage__c=allocation;
                productClientList.Sum_Of_Feature_Weightage__c=featureUsage;
                updateAllocation.add(productClientList);
                
            }
            break;
        }
        if(! updateAllocation.isEmpty())
        {      update updateAllocation; 
        }
    }
    
}