public without sharing class SalesforceProduct {
    public static Boolean isExecuted = false;
    public class ProductFeature{
        @AuraEnabled
        public string Id {get; set;} 
        @AuraEnabled
        public string Name {get; set;}
        @AuraEnabled
        public decimal clientUsage {get; set;} 
        public ProductFeature(string a,string b,decimal c) {
            Id = a;
            Name = b;
            clientUsage=c;
        }
    }
    
    public class ProductLevel{
        @AuraEnabled
        public string Id {get; set;} 
        @AuraEnabled
        public string Name {get; set;}
        @AuraEnabled
        public decimal productUsage {get; set;} 
        @AuraEnabled
        public List<ProductFeature> productFeatureList {get; set;} 
        
        public ProductLevel(string a,string b,decimal c,list<ProductFeature> d) {
            Id = a;
            Name = b;
            productUsage=c;
            productFeatureList=d;
        }
    }
    @AuraEnabled(Cacheable=false)
    public static void updateSessionData(string accountId,string serviceId){
        ODS_Common_Utility.upsertSessionData(accountId,serviceId);  
    }
    
    @AuraEnabled( cacheable = false )
    public static List<ProductLevel> fetchSalesforceProductAfterAccountSelect(string accountId) {  
        system.debug('@@accountId@@-'+accountId);
        List<ProductLevel> wrpproductLevel=new List<ProductLevel>();
        
        try{
            Set<Id> filterProductId=New Set<Id>();
            filterProductId.addAll(SalesforceProductFilterHelper.productFilter(accountId));
            runSalesforceProductAfterAccountSelect(accountId);
           // List<Salesforce_Product__c> spList=[Select Id,Name From Salesforce_Product__c Where Id IN:filterProductId];
            List<Product_Client_Usage__c> pcuList=[SELECT Salesforce_Product__r.Id,Salesforce_Product__r.Name,Salesforce_Product_Usage__c ,(Select id,Product_Client_Usage__c,Salesforce_Product_Feature__r.id,Salesforce_Product_Feature__r.Name  from Product_Feature_Client_Usages__r) FROM Product_Client_Usage__c WHERE Account__c=:accountId AND Salesforce_Product__c IN:filterProductId ORDER BY Salesforce_Product__c ASC NULLS FIRST];
           if(!pcuList.isEmpty()){
                for(Product_Client_Usage__c p:pcuList){
                    list<ProductFeature> wrproductFeature=new list<ProductFeature>();
                    for(Product_Feature_Client_Usage__c p1:[Select Id,Salesforce_Product_Feature__r.id,Salesforce_Product_Feature__r.Name,Client_Usage_Percentage__c From Product_Feature_Client_Usage__c Where Salesforce_Product__c=:p.Salesforce_Product__c And Account__c=:accountId AND Salesforce_Product_Feature__r.Active__c=true]){
                        wrproductFeature.add(new ProductFeature(p1.Salesforce_Product_Feature__r.id,p1.Salesforce_Product_Feature__r.Name,p1.Client_Usage_Percentage__c));
                    }
                    wrpproductLevel.add( new ProductLevel(p.Salesforce_Product__r.Id,p.Salesforce_Product__r.Name,p.Salesforce_Product_Usage__c,wrproductFeature));
                }
            }
            /*if(!pcuList.isEmpty()){
                for(Product_Client_Usage__c p:pcuList){
                    list<ProductFeature> wrproductFeature=new list<ProductFeature>();
                    for(Product_Feature_Client_Usage__c p1:[Select Id,Salesforce_Product_Feature__r.id,Salesforce_Product_Feature__r.Name,Client_Usage_Percentage__c From Product_Feature_Client_Usage__c Where Salesforce_Product__c=:p.Salesforce_Product__c And Account__c=:accountId AND Salesforce_Product_Feature__r.Active__c=true]){
                        wrproductFeature.add(new ProductFeature(p1.Salesforce_Product_Feature__r.id,p1.Salesforce_Product_Feature__r.Name,p1.Client_Usage_Percentage__c));
                    }
                    wrpproductLevel.add( new ProductLevel(p.Salesforce_Product__r.Id,p.Salesforce_Product__r.Name,p.Salesforce_Product_Usage__c,wrproductFeature));
                }
            }else
            {
                list<Product_Client_Usage__c> newSCUList1=new List<Product_Client_Usage__c>();
                for(Salesforce_Product__c sp:spList)
                {
                    Product_Client_Usage__c newSCU=new Product_Client_Usage__c();
                    newSCU.Account__c=accountId;
                    newSCU.Salesforce_Product_Usage__c=decimal.valueOf('0');
                    newSCU.Salesforce_Product__c=sp.Id;
                    newSCUList1.add(newSCU);
                }
                insert newSCUList1;
                List<Product_Feature_Client_Usage__c> insertPFCU=new List<Product_Feature_Client_Usage__c>();
                for(Salesforce_Product__c sp:spList)
                {
                    for(Product_Client_Usage__c pc:[SELECT Account__c,Id,Name,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c where Salesforce_Product__c=:sp.id And Account__c=:accountid])
                    {
                        for(Salesforce_Product_Feature__c spf:[SELECT Client_Usage_Percentage__c,Name,Salesforce_Product__c,Feature_Percentage__c FROM Salesforce_Product_Feature__c where Salesforce_Product__c=:sp.id])
                        {
                            Product_Feature_Client_Usage__c s=new Product_Feature_Client_Usage__c();
                            s.Product_Client_Usage__c=pc.id;                
                            s.Salesforce_Product__c=sp.id;
                            s.Account__c=accountId;
                            s.Salesforce_Product_Feature__c=spf.id;
                            s.Feature_Percentage__c=spf.Feature_Percentage__c;
                            s.Client_Usage_Percentage__c=0;
                            insertPFCU.add(s);
                        }
                    }
                }
                insert insertPFCU;
                List<Product_Client_Usage__c> pcuList1=[SELECT Salesforce_Product__r.Id,Salesforce_Product__r.Name,Salesforce_Product_Usage__c ,(Select id,Product_Client_Usage__c,Salesforce_Product_Feature__r.id,Salesforce_Product_Feature__r.Name  from Product_Feature_Client_Usages__r) FROM Product_Client_Usage__c WHERE Account__c=:accountId ORDER BY Salesforce_Product__c ASC NULLS FIRST];
                for(Product_Client_Usage__c p:pcuList1){
                    list<ProductFeature> wrproductFeature=new list<ProductFeature>();
                    for(Product_Feature_Client_Usage__c p1:[Select Id,Salesforce_Product_Feature__r.id,Salesforce_Product_Feature__r.Name,Client_Usage_Percentage__c From Product_Feature_Client_Usage__c Where Salesforce_Product__c=:p.Salesforce_Product__c And Account__c=:accountId AND Salesforce_Product_Feature__r.Active__c=true]){
                        wrproductFeature.add(new ProductFeature(p1.Salesforce_Product_Feature__r.id,p1.Salesforce_Product_Feature__r.Name,p1.Client_Usage_Percentage__c));
                    }
                    wrpproductLevel.add( new ProductLevel(p.Salesforce_Product__r.Id,p.Salesforce_Product__r.Name,p.Salesforce_Product_Usage__c,wrproductFeature));
                }
            }*/
            return wrpproductLevel;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void runSalesforceProductAfterAccountSelect(string accountId) {          
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

    @AuraEnabled( cacheable = true )
    public static List<ProductLevel> fetchSalesforceProduct() {  
        try{
            List<ProductLevel> wrpproductLevel=new List<ProductLevel>();
            for(Salesforce_Product__c p:[SELECT Id,Name,Product_Percentage__c FROM Salesforce_Product__c]){
                list<ProductFeature> wrproductFeature=new list<ProductFeature>();
                for(Salesforce_product_feature__c p1:[SELECT Client_Usage_Percentage__c,Id,Name,Salesforce_Product__c FROM Salesforce_product_feature__c where Salesforce_Product__c=:p.id]){
                    wrproductFeature.add(new ProductFeature(p1.id,p1.Name,p1.Client_Usage_Percentage__c));
                }
                wrpproductLevel.add( new ProductLevel(p.Id,p.Name,100,wrproductFeature));
            }
            return wrpproductLevel;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled( cacheable = true )
    public static List< Salesforce_Product__c > fetchSalesforceProductPercentage() {   
        try{
            return [SELECT Id, Name,Product_Percentage__c FROM Salesforce_Product__c];  
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName) {  
        try{
            List<sObject> lookUpList =new List<sObject>();
            String queryName= searchKey + '%';
            lookUpList=[Select Id, Name from Account Where (Name Like :queryName) LIMIT  6];
            
            return lookUpList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=false)  
    public static List<Product_Feature_Client_Usage__c> findFeaturesProduct(String feature,string accountId) 
    {  
        try{
            
            return [SELECT Chart_Color_Code__c,Client_Usage_Weightage__c,Client_Usage_Percentage__c,Feature_Weightage_Percentage__c,Id,Salesforce_Product_Feature__r.Name FROM Product_Feature_Client_Usage__c WHERE Salesforce_Product__r.Name=:feature And Account__c=:accountId AND Salesforce_Product_Feature__r.Active__c=true];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)  
    public static List<WarpCharRecord> createSalesforceClientUsage(object[] salesforceClientUsage,string accountid) { 
        try{
            set<id> salesforceProductId=new set<id>();
            List<WarpCharRecord> warpCharRecordList=New List<WarpCharRecord>();
            List<Product_Client_Usage__c> newSCUList=new List<Product_Client_Usage__c>();
            List<Product_Client_Usage__c> pcuList=[SELECT Salesforce_Product__r.Id,Salesforce_Product__r.Name,Salesforce_Product_Usage__c ,(Select id,Product_Client_Usage__c,Salesforce_Product_Feature__r.id,Salesforce_Product_Feature__r.Name  from Product_Feature_Client_Usages__r) FROM Product_Client_Usage__c WHERE Account__c=:accountid];
            
            for(object sc:salesforceClientUsage)
            {
                system.debug('sc--'+sc);
                string s=string.valueOf(sc);
                String[] arrTest = s.split('\\=');
                string productId=arrTest[3].SubStringBefore('}');
                for(Product_Client_Usage__c p:[Select Id,Salesforce_Product__c,Salesforce_Product_Usage__c From Product_Client_Usage__c where
                                               Salesforce_Product__c =:productId And Account__c=:accountid]) 
                {
                    Product_Client_Usage__c newSCU=new Product_Client_Usage__c();        
                    newSCU.id=p.id;
                    newSCU.Salesforce_Product_Usage__c=decimal.valueOf(arrTest[2].SubStringBefore(','));
                    newSCUList.add(newSCU);
                    salesforceProductId.add(arrTest[3].SubStringBefore('}'));
                    
                }
            }
            update newSCUList;
            Set<Id> filterProductId=New Set<Id>();
            filterProductId.addAll(SalesforceProductFilterHelper.productFilter(accountid));
            
            for(Product_Client_Usage__c pc:[Select Id,Salesforce_Product_Usage__c,Salesforce_Product__r.Name,Chart_Color_Code__c From Product_Client_Usage__c where Account__c=:accountid AND Salesforce_Product__c IN: filterProductId ORDER BY Salesforce_Product__c ASC NULLS FIRST]){
                warpCharRecordList.add(new WarpCharRecord(pc.Salesforce_Product__r.Name,pc.Salesforce_Product_Usage__c,pc.Chart_Color_Code__c));
                
            }
            
            return warpCharRecordList;
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static list<ProductLevel> updateClientFeatureUsage(String updateObjStr, string accountId) {
        try{
            set<id> salesforceProductId=new set<id>();
            List<Product_Feature_Client_Usage__c > updateSalesforceFeature=new list<Product_Feature_Client_Usage__c >();
            set<id> salesforceFeatureId=new set<id>();
            system.debug('updateObjStr--'+updateObjStr);
            List<Object> obList = (List<object>) json.deserializeUntyped(updateObjStr);
            List<Product_Client_Usage__c> pcuList=[SELECT Salesforce_Product__r.Id,Salesforce_Product__r.Name,Salesforce_Product_Usage__c ,(Select id,Product_Client_Usage__c,Salesforce_Product_Feature__r.id,Salesforce_Product_Feature__r.Name  from Product_Feature_Client_Usages__r) FROM Product_Client_Usage__c WHERE Account__c=:accountid];
            List<Product_Client_Usage__c> newSCUList1=new list<Product_Client_Usage__c>();
            if(pcuList.isEmpty()){
                for(Salesforce_Product__c sp:[Select Id,Name From Salesforce_Product__c])
                {
                    Product_Client_Usage__c newSCU=new Product_Client_Usage__c();
                    newSCU.Account__c=accountid;
                    newSCU.Salesforce_Product_Usage__c=decimal.valueOf('0');
                    newSCU.Salesforce_Product__c=sp.Id;
                    newSCUList1.add(newSCU);
                    // warpCharRecordList.add(new warpCharRecord(sp.Name,100));
                }
                insert newSCUList1;
            }
            
            for(object ob : obList) 
            {
                Map<String, object> obmap = (Map<String, object>)ob;
                String idSP = (String)obmap.get('Id');
                String idFe = (String)obmap.get('Client_Usage_Percentage__c');
                salesforceFeatureId.add(idSP);
                for(Product_Feature_Client_Usage__c pc:[Select Id,Client_Usage_Percentage__c,Salesforce_Product_Feature__c,Salesforce_Product__c From
                                                        Product_Feature_Client_Usage__c Where Salesforce_Product_Feature__c=:idSP And Account__c=:accountId])
                {
                    Product_Feature_Client_Usage__c s=new Product_Feature_Client_Usage__c();
                    s.id=pc.id;
                    s.Client_Usage_Percentage__c=0;
                    updateSalesforceFeature.add(s);
                    salesforceProductId.add(pc.Salesforce_Product__c);
                }
                
            }
            
            Update updateSalesforceFeature;
            
            return fetchSalesforceProductAfterAccountSelect(accountId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=false)
    public static string getCloudName(String featureId){
        Salesforce_Product_Feature__c getSPF=[SELECT Name,Salesforce_Product__r.Name FROM Salesforce_Product_Feature__c WHERE Id =: featureId];
        return getSPF.Salesforce_Product__r.Name;
    }
    @AuraEnabled(cacheable=false)
    public static string getCloudNameFromSP(String featureId){
        Salesforce_Product__c getSPF=[SELECT Id,Name FROM Salesforce_Product__c WHERE Id =: featureId];
        return getSPF.Name;
    }
    public class WarpCharRecord {
        @AuraEnabled
        public string label {get; set;}
        @AuraEnabled
        public decimal value {get; set;} 
        @AuraEnabled
        public string color {get; set;} 
        public WarpCharRecord(string a,decimal b,string c) {
            label = a;
            value = b;
            color=c;
        }
    }
}