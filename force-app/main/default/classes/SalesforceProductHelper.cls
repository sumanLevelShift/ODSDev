public without sharing class SalesforceProductHelper {
    @future
    public static void fetchSalesforceProductAfterAccountSelect(string accountId) {          
        try{
            List<Salesforce_Product__c> spList=SalesforceProductHelper.getProductRecordsFromDB(accountID);
            list<Salesforce_Product_Feature__c> featureList=SalesforceProductHelper.getProductFeatureRecordsFromDB(accountID);
            list<Product_Client_Usage__c> newSCUList1=new List<Product_Client_Usage__c>();
            for(Salesforce_Product__c sp:spList)
            {
                Product_Client_Usage__c newSCU=new Product_Client_Usage__c();
                newSCU.Account__c=accountId;
                newSCU.Salesforce_Product_Usage__c=decimal.valueOf('0');
                newSCU.Salesforce_Product__c=sp.Id;
                newSCUList1.add(newSCU);
            }
            if(!newSCUList1.isEmpty()){
                insert newSCUList1;
            }
            Map<id,id> productIds=new map<id,id>();
            for(Product_Client_Usage__c pc:[SELECT Account__c,Id,Name,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c where Account__c=:accountid])
            {
                productIds.put(pc.Salesforce_Product__c,pc.id);
            }
            List<Product_Feature_Client_Usage__c> insertPFCU=new List<Product_Feature_Client_Usage__c>();
            
            for(Salesforce_Product_Feature__c spf:featureList)
            {
                if(productIds.containsKey(spf.Salesforce_Product__c)){
                    Product_Feature_Client_Usage__c s=new Product_Feature_Client_Usage__c();
                    s.Product_Client_Usage__c=productIds.get(spf.Salesforce_Product__c);                
                    s.Salesforce_Product__c=spf.Salesforce_Product__c;
                    s.Account__c=accountId;
                    s.Salesforce_Product_Feature__c=spf.id;
                    s.Feature_Percentage__c=spf.Feature_Percentage__c;
                    s.Client_Usage_Percentage__c=0;
                    insertPFCU.add(s);
                }
            }
            if(!insertPFCU.isEmpty()){
                insert insertPFCU;
            }
            HeatMapRecordsSchedular HM=new HeatMapRecordsSchedular(accountId);
           // HM.execute(null);
        }catch(Exception e){
            system.debug('exception --'+e.getMessage());
            system.debug('exception --'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    } 
    public static List<Salesforce_Product__c>  getProductRecordsFromDB(Id accountId){
        Set<id> productId=new Set<id>();
        List<Product_Client_Usage__c> productClientUsageList =  [SELECT Salesforce_Product__c,Salesforce_Product__r.Id,Salesforce_Product__r.Name,Salesforce_Product_Usage__c FROM Product_Client_Usage__c WHERE Account__c=:accountId];
        for(Product_Client_Usage__c item : productClientUsageList){
            productId.add(item.Salesforce_Product__c);
        }
        List<Salesforce_Product__c> spList=[Select Id,Name From Salesforce_Product__c Where ID Not IN : productId];
        
        return spList;
    }
    public static List<Salesforce_Product_Feature__c>  getProductFeatureRecordsFromDB(Id accountId){
        Set<id> featureId=new Set<id>();
        List<Product_Feature_Client_Usage__c> productFeatureClientUsageList =  [SELECT Account__c,Id,Product_Client_Usage__c,Salesforce_Product_Feature__c,Salesforce_Product__c FROM Product_Feature_Client_Usage__c WHERE Account__c =:accountId ];
        for(Product_Feature_Client_Usage__c item : productFeatureClientUsageList){
            featureId.Add(item.Salesforce_Product_Feature__c);
        }
        List<Salesforce_Product_Feature__c> featureList=[Select id,Name,Feature_Percentage__c,Chart_Color__c,Salesforce_Product__c from Salesforce_Product_Feature__c Where ID NOT IN :featureId];
        
        return featureList;
    }
}