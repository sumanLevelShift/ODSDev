public without sharing class ProductClientUsageHelper {
    public static boolean quoteRecursion;
    static {
        quoteRecursion = false;
    }
    public static void createSalesforceProductToClient(List<Salesforce_Product__c> salesforceProduct)
    {
        List<Product_Client_Usage__c> insertClient=new List<Product_Client_Usage__c>();
        List<Product_Client_Usage__c> productClient=[SELECT Account__c,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c];
        if(!productClient.isEmpty()){
            for(Salesforce_Product__c sp:salesforceProduct)
            {
                String acc;
                for(Product_Client_Usage__c p:productClient)
                {
                    if(p.Account__c !=acc){
                        Product_Client_Usage__c pc=new Product_Client_Usage__c();
                        pc.Salesforce_Product__c=sp.id;
                        pc.Account__c=p.Account__c;
                        pc.Salesforce_Product_Usage__c =0;
                        insertClient.add(pc);
                        acc=p.Account__c;
                    }
                }
            }
        }
        //insert insertClient;
        if(!insertClient.isEmpty()){
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, insertClient); 
            insert decision.getRecords();
        }
    }  
    Public Static void createSalesforceFeatureProductToClient(List<Salesforce_Product_Feature__c> salesforcePFeature)
    {
        List<Product_Feature_Client_Usage__c> insertClient=new List<Product_Feature_Client_Usage__c>();
        List<Salesforce_Product_Feature__c> updateSalesforceProductFeat=new List<Salesforce_Product_Feature__c>();
        List<Product_Client_Usage__c> productClient=[SELECT Account__c,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c];
        Map<String,List<Decimal>> usageWeightageData = new Map<String,List<Decimal>>();
        List<String> productClientUsageIDs = new List<String>();
        for(Salesforce_Product_Feature__c sp:salesforcePFeature)
        {
            if(sp.Chart_Color__c == Null){
                integer r = integer.valueOf(Math.random() * 255);
                integer g = integer.valueOf(Math.random() * 255);
                integer b = integer.valueOf(Math.random() * 255);
                string c='rgb('+r+','+g+','+b+')';
                Salesforce_Product_Feature__c s=new Salesforce_Product_Feature__c();
                s.id=sp.id;
                s.Chart_Color__c=c;
                updateSalesforceProductFeat.add(s);
            }
            String acc=null;
            for(Product_Client_Usage__c p:productClient)
            {
                if(sp.Salesforce_Product__c == p.Salesforce_Product__c)
                {
                    Product_Feature_Client_Usage__c pf=new Product_Feature_Client_Usage__c();
                    pf.Account__c=p.Account__c;
                    pf.Salesforce_Product_Feature__c=sp.id;
                    pf.Product_Client_Usage__c=p.id;
                    pf.Salesforce_Product__c=sp.Salesforce_Product__c;
                    pf.Feature_Percentage__c=sp.Feature_Percentage__c;
                    pf.Client_Usage_Percentage__c=0;
                    acc=p.Account__c;
                    insertClient.add(pf);
                }
                
            }
        }
        
        if(!insertClient.isEmpty())
        {
            quoteRecursion=true;
            insert insertClient;
        }
        if(!updateSalesforceProductFeat.isEmpty()){
            update updateSalesforceProductFeat;
        }
        //SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, insertClient); 
        //insert decision.getRecords();
        List<Product_Client_Usage__c> updateAllocation=new list<Product_Client_Usage__c>();
        string flag=null;
        
        for(Product_Feature_Client_Usage__c pf:insertClient)
        {
            decimal allocation=0;
            decimal total=0;
            decimal sumOfFeature=0;
            decimal sumOfClientUsage=0;
            for(Product_Feature_Client_Usage__c relatedPF:[Select id,Feature_Percentage__c,Client_Usage_Percentage__c From Product_Feature_Client_Usage__c Where 
                                                           Account__c=:pf.Account__c
                                                           And Salesforce_Product__c=:pf.Salesforce_Product__c])
            {
                sumOfClientUsage=sumOfClientUsage+relatedPF.Client_Usage_Percentage__c;
                sumOfFeature=sumOfFeature+relatedPF.Feature_Percentage__c;
                total=total+(relatedPF.Feature_Percentage__c * relatedPF.Client_Usage_Percentage__c);
            }
            total=total/100;
            allocation=(total/sumOfFeature)*100;
            allocation=allocation.setScale(0);
            if(pf.Product_Client_Usage__c !=flag){
                flag=pf.Product_Client_Usage__c;
                
                productClientUsageIDs.add(pf.Product_Client_Usage__c);
                List<Decimal> usageWeightage = new List<Decimal>();
                usageWeightage.add(allocation);
                usageWeightage.add(sumOfFeature);
                usageWeightageData.put(pf.Product_Client_Usage__c, usageWeightage);
            }
        }
        
        for(Product_Client_Usage__c pc:[SELECT Id,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c
                                        where id=:productClientUsageIDs]){
                                            
                                            Product_Client_Usage__c updateProduct=new Product_Client_Usage__c();
                                            updateProduct.id=pc.id;
                                            List<Decimal> usageWeightage = usageWeightageData.get(pc.Id);
                                            updateProduct.Salesforce_Product_Usage__c=usageWeightage[0];
                                            updateProduct.Sum_Of_Feature_Weightage__c=usageWeightage[1];
                                            updateAllocation.add(updateProduct);
                                        }        
        
        if(! updateAllocation.isEmpty())
        {      
            update updateAllocation; 
        }
    }
    public static void updateProductClientFeature(List<Salesforce_Product_Feature__c> salesforceProductList){
        List<Product_Feature_Client_Usage__c> updateFeatureValue=new List<Product_Feature_Client_Usage__c>();
        List<Salesforce_Product_Feature__c> updateSalesforceProductFeat=new List<Salesforce_Product_Feature__c>();

        set<id> featureId=new set<id>();
        for(Salesforce_Product_Feature__c spf:salesforceProductList){
            featureId.add(spf.id);
        }
        List<Salesforce_Product_Feature__c> salesforceProductListV1=[Select id,Chart_Color__c,Feature_Percentage__c,(SELECT Client_Usage_Percentage__c,Feature_Percentage__c,Id,Product_Client_Usage__c,Salesforce_Product_Feature__c,Salesforce_Product__c FROM Product_Feature_Client_Usages__r) from Salesforce_Product_Feature__c Where Id IN:featureId];
        for(Salesforce_Product_Feature__c spf:salesforceProductListV1){
            if(spf.Chart_Color__c == Null){
                integer r = integer.valueOf(Math.random() * 255);
                integer g = integer.valueOf(Math.random() * 255);
                integer b = integer.valueOf(Math.random() * 255);
                string c='rgb('+r+','+g+','+b+')';
                Salesforce_Product_Feature__c s=new Salesforce_Product_Feature__c();
                s.id=spf.id;
                s.Chart_Color__c=c;
                updateSalesforceProductFeat.add(s);
            }
            For(Product_Feature_Client_Usage__c pf:spf.Product_Feature_Client_Usages__r){
                Product_Feature_Client_Usage__c p=new Product_Feature_Client_Usage__c();
                p.id=pf.id;
                p.Feature_Percentage__c=spf.Feature_Percentage__c;
                updateFeatureValue.add(p);
            }    
        } 
        if(! updateFeatureValue.isEmpty())
        {
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, updateFeatureValue); 
            update decision.getRecords();
        }
        if(!updateSalesforceProductFeat.isEmpty()){
            update updateSalesforceProductFeat;
        }
        // Update updateFeatureValue; 
    }
    public static void deleteProductClientFeature(List<Salesforce_Product_Feature__c> salesforceProductList){
        List<id> deleteClient=new List<id>();
        List<Product_Client_Usage__c> updateAllocation=new list<Product_Client_Usage__c>();
        set<id> featureId=new set<id>();
        Map<String,List<Decimal>> usageWeightageData = new Map<String,List<Decimal>>();
        List<String> productClientUsageIDs = new List<String>();        
        for(Salesforce_Product_Feature__c spf:salesforceProductList){
            featureId.add(spf.id);
        }
        List<Salesforce_Product_Feature__c> salesforceProductListV1=[Select id,Feature_Percentage__c,(SELECT Client_Usage_Percentage__c,Feature_Percentage__c,Id,Product_Client_Usage__c,Salesforce_Product_Feature__c,Salesforce_Product__c FROM Product_Feature_Client_Usages__r) from Salesforce_Product_Feature__c Where Id IN:featureId];
        For(Salesforce_Product_Feature__c spf:salesforceProductListV1){
            For(Product_Feature_Client_Usage__c pf:spf.Product_Feature_Client_Usages__r){
                deleteClient.add(pf.id);
            }
        }
        string flag=null;
        
        For(Product_Feature_Client_Usage__c pf:[Select Id,Account__c,Feature_Percentage__c,Client_Overall_Usage__c,Salesforce_Product__c,Product_Client_Usage__c
                                                From Product_Feature_Client_Usage__c Where Id IN:  deleteClient ]){
                                                    decimal allocation=0;
                                                    decimal total=0;
                                                    decimal sumOfFeature=0;
                                                    decimal sumOfClientUsage=0;
                                                    for(Product_Feature_Client_Usage__c relatedPF:[Select id,Feature_Percentage__c,Client_Usage_Percentage__c From Product_Feature_Client_Usage__c Where 
                                                                                                   Account__c=:pf.Account__c
                                                                                                   And Salesforce_Product__c=:pf.Salesforce_Product__c and Id !=:pf.id])
                                                    {
                                                        sumOfClientUsage=sumOfClientUsage+relatedPF.Client_Usage_Percentage__c;
                                                        sumOfFeature=sumOfFeature+relatedPF.Feature_Percentage__c;
                                                        total=total+(relatedPF.Feature_Percentage__c * relatedPF.Client_Usage_Percentage__c);
                                                    }
                                                    if(sumOfFeature!=0){
                                                        total=total/100;
                                                        allocation=(total/sumOfFeature)*100;
                                                        allocation=allocation.setScale(0);
                                                    }
                                                    if(pf.Product_Client_Usage__c !=flag){
                                                        flag=pf.Product_Client_Usage__c;
                                                        
                                                        productClientUsageIDs.add(pf.Product_Client_Usage__c);
                                                        List<Decimal> usageWeightage = new List<Decimal>();
                                                        usageWeightage.add(allocation);
                                                        usageWeightage.add(sumOfFeature);
                                                        usageWeightageData.put(pf.Product_Client_Usage__c, usageWeightage);                                                        
                                                        
                                                    }
                                                }
        for(Product_Client_Usage__c pc:[SELECT Id,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c
                                        where id=:productClientUsageIDs]){
                                            Product_Client_Usage__c updateProduct=new Product_Client_Usage__c();
                                            updateProduct.id=pc.id;
                                            List<Decimal> usageWeightage = usageWeightageData.get(pc.Id);
                                            updateProduct.Salesforce_Product_Usage__c=usageWeightage[0];
                                            updateProduct.Sum_Of_Feature_Weightage__c=usageWeightage[1];
                                            updateAllocation.add(updateProduct);                                            
                                        }        
        quoteRecursion=true;
        if(! deleteClient.isEmpty())
        { 
            Database.delete(deleteClient);
        }
        if(! updateAllocation.isEmpty())
        { 
            update updateAllocation; 
        }
        
    }
    public static void deleteSalesforceProductToClient(List<Salesforce_Product__c> salesforceProduct)
    {
        List<id> deleteClient=new List<id>();
        set<id> productId=new set<id>();
        for(Salesforce_Product__c s:salesforceProduct){
            productId.add(s.id);   
        }
        List<Salesforce_Product__c> spList=[Select Id,Name,(SELECT Account__c,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usages__r) From Salesforce_Product__c Where Id IN:productId];
        for(Salesforce_Product__c sp:spList)
        {
            for(Product_Client_Usage__c p:sp.Product_Client_Usages__r)
            {
                deleteClient.add(p.id);
            }
        }
        if(! deleteClient.isEmpty())
        {
            Database.delete(deleteClient);
        }
    } 
}