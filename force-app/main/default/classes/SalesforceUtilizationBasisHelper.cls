public class SalesforceUtilizationBasisHelper {
    public static boolean firstRun = true; 

    public static void updateOverAllUsage(List<Account> accountTrigger){
        try{
            list<Product_Feature_Client_Usage__c> updatePFCUList=new List<Product_Feature_Client_Usage__c>();
            List<Product_Client_Usage__c> updateProductClientUsage=new list<Product_Client_Usage__c>();
            List<Product_Client_Usage__c> updateProductClientUsageAVG=new list<Product_Client_Usage__c>();
            List<Product_Subfeature_Client_Usage__c> PSFCUUpdateList=new list<Product_Subfeature_Client_Usage__c>();
            List<string> attributeApiName=new list<string>();
            Set<string> sourceApiName=new set<string>();
            list<string> attributeApiNameList=new list<string>();
            list<string> sourceApiNameList=new list<string>();
            set<id> accIDSet=new set<id>();
            

            List<Salesforce_Utilization_Basis_Mapping__mdt> basisMapping=[SELECT id,Condition__c,Attribute_API_Name__c,DeveloperName,Source_Field_API_Name__c,Source_Object__c FROM Salesforce_Utilization_Basis_Mapping__mdt];
            
            for(Salesforce_Utilization_Basis_Mapping__mdt m:basisMapping){
                attributeApiName.add(m.Attribute_API_Name__c); 
                sourceApiName.add(m.Source_Field_API_Name__c);
            }
            attributeApiNameList.addAll(attributeApiName);
            for(Account a:accountTrigger){
                accIDSet.add(a.id);
            }
            sourceApiNameList.addAll(sourceApiName);
            
            List<Salesforce_Utilization_Basis_Attributes__mdt> getBasisAttributes = Database.query('SELECT id,'+String.join(attributeApiNameList, ',')+',(SELECT DeveloperName,Product__c,Utilization_in_Percentage__c FROM SalesforceUtilizationBasisAttributeDatas__r ORDER BY DeveloperName ASC NULLS FIRST) FROM Salesforce_Utilization_Basis_Attributes__mdt');
            List<Account> accountRecordList=Database.query('SELECT id,'+String.join(sourceApiNameList, ',')+' From Account where Id IN : accIDSet');
            list<Product_Subfeature_Client_Usage__c> productSubFeatureClient=[SELECT Id,Name,Account__c,Client_Usage_Percentage__c,Salesforce_Product_Feature__c,Salesforce_Product_Feature__r.Name,Salesforce_Product__c,Salesforce_Product__r.Name FROM Product_Subfeature_Client_Usage__c Where Account__c IN:accIDSet];
            list<Product_Feature_Client_Usage__c> productFeature=[SELECT Account__c,Client_Usage_Percentage__c,Salesforce_Product_Feature__r.Name,Salesforce_Product__r.Name FROM Product_Feature_Client_Usage__c where Account__c IN:accIDSet];
            for(Account a:accountRecordList){
                for(Salesforce_Utilization_Basis_Attributes__mdt su:getBasisAttributes){
                    system.debug('su---'+su);
                    list<boolean> conditionList=new List<boolean>();
                    for(Salesforce_Utilization_Basis_Mapping__mdt bm:basisMapping){
                        system.debug('bm-'+bm);
                        if(bm.Condition__c=='Contains')
                        {
                            string basicAttIn=(string)su.get((string) bm.Attribute_API_Name__c);
                            string accountIn=(string) a.get((string) bm.Source_Field_API_Name__c);
                            boolean a1=accountIn.contains(basicAttIn); 
                            conditionList.add(a1);
                        }
                        if(bm.Condition__c=='Equal To')
                        {
                            boolean b1=(string) a.get((string) bm.Source_Field_API_Name__c) == (string) su.get((string) bm.Attribute_API_Name__c);  
                            conditionList.add(b1);
                        }
                        if(bm.Condition__c=='Less Than Equal To')
                        {
                            boolean c1 =(decimal)a.get((string) bm.Source_Field_API_Name__c) <= (decimal) su.get((string) bm.Attribute_API_Name__c); 
                            conditionList.add(c1);
                        }
                        if(bm.Condition__c=='Greater Than Equal To')
                        {
                            boolean d1 =(decimal) a.get((string) bm.Source_Field_API_Name__c) >= (decimal) su.get((string) bm.Attribute_API_Name__c);  
                            conditionList.add(d1);
                        }
                        if(bm.Condition__c=='Greater Than')
                        {
                            boolean e1 =(decimal) a.get((string) bm.Source_Field_API_Name__c) > (decimal) su.get((string) bm.Attribute_API_Name__c);  
                            conditionList.add(e1);
                        }
                        if(bm.Condition__c=='Less Than')
                        {
                            boolean f1 =(decimal) a.get((string) bm.Source_Field_API_Name__c) < (decimal) su.get((string) bm.Attribute_API_Name__c);  
                            conditionList.add(f1);
                        }
                    }
                    boolean finalCondition=false;
                    if(!conditionList.Contains(false)){
                        finalCondition=true;
                    }
                    if(finalCondition){
                        for(SalesforceUtilizationBasisAttributeData__mdt sad:su.SalesforceUtilizationBasisAttributeDatas__r){
                            system.debug('sad--'+sad);
                            PSFCUUpdateList.addAll(getProductSubFeatureClientUsage(a.id,sad,productSubFeatureClient));
                            updatePFCUList.addAll(getProductFeatureClientUsage(a.id,sad,productFeature));
                            updateProductClientUsage.add(getProductClientUsage(a.id,sad));
                        }
                    }

                }
            }  
system.debug('PSFCUUpdateList--'+PSFCUUpdateList);
system.debug('PSFCUUpdateList--'+updatePFCUList);
system.debug('PSFCUUpdateList--'+updateProductClientUsage);            
            if(!PSFCUUpdateList.isEmpty()){
                update PSFCUUpdateList;
            }
            if(!updatePFCUList.isEmpty()){
                update updatePFCUList;
                
            }
            if(!updateProductClientUsage.isEmpty()){
                update updateProductClientUsage;
            }

            for(Account a:accountTrigger){
                
               updateProductClientUsageAVG.addAll(ProdSubfeatureClientUsageController.calculateAvgUsage(a));
            }
            if(!updateProductClientUsageAVG.isEmpty()){
                update updateProductClientUsageAVG;
            }
        }catch(Exception e){
            system.debug('error Casue-------'+e.getCause());
            system.debug('error LineNumber--'+e.getLineNumber());
            system.debug('error message-----'+e.getMessage());
        }
    }
    
    //To update Sub Feature client Usage
    public static List<Product_Subfeature_Client_Usage__c> getProductSubFeatureClientUsage(string accId,SalesforceUtilizationBasisAttributeData__mdt utilization,list<Product_Subfeature_Client_Usage__c> productSubFeatureClient)
    {
        List<Product_Subfeature_Client_Usage__c> PSFCUUpdateList=new list<Product_Subfeature_Client_Usage__c>();
        List<SalesforceUtilizationBasisSubFeatureData__mdt> subFeatureData=[SELECT id,Feature_Name__c,Label,Product__c,SalesforceUtilizationBasisFeatureData__c,Sub_Feature_Name__c,Utilization_in_Percentage__c FROM SalesforceUtilizationBasisSubFeatureData__mdt where Product__c=:utilization.Product__c ORDER BY Feature_Name__c ASC NULLS FIRST];
        for(SalesforceUtilizationBasisSubFeatureData__mdt subFeCMDT:subFeatureData){
            system.debug('subFeCMDT--'+subFeCMDT);
            for(Product_Subfeature_Client_Usage__c pSFCU:productSubFeatureClient){
                system.debug('pSFCU--'+pSFCU);
                if(pSFCU.Name==subFeCMDT.Sub_Feature_Name__c && pSFCU.Salesforce_Product_Feature__r.Name==subFeCMDT.Feature_Name__c && pSFCU.Salesforce_Product__r.Name==subFeCMDT.Product__c){
                    Product_Subfeature_Client_Usage__c p=new Product_Subfeature_Client_Usage__c();
                    p.id=pSFCU.id;
                    p.Client_Usage_Percentage__c=subFeCMDT.Utilization_in_Percentage__c;
                    PSFCUUpdateList.add(p);
                }
                
            }
        }
        system.debug('PSFCUUpdateList--'+PSFCUUpdateList);
        return PSFCUUpdateList;
    }
    
    //To update Feature client Usage
    public static List<Product_Feature_Client_Usage__c> getProductFeatureClientUsage(string accId,SalesforceUtilizationBasisAttributeData__mdt utilization,list<Product_Feature_Client_Usage__c> productFeature){
        firstRun=false;
        List<Product_Feature_Client_Usage__c> PFCUUpdateList=new list<Product_Feature_Client_Usage__c>();
        List<SalesforceUtilizationBasisFeatureData__mdt> featureDataCMDT=[SELECT Utilization_in_Percentage__c,DeveloperName,Feature_Name__c,Product__c FROM SalesforceUtilizationBasisFeatureData__mdt WHERE SalesforceUtilizationBasisAttributeData__c =:utilization.id ORDER BY Feature_Name__c ASC NULLS FIRST];
        for(SalesforceUtilizationBasisFeatureData__mdt fd:featureDataCMDT){
            for(Product_Feature_Client_Usage__c pf:productFeature){
                if(pf.Salesforce_Product_Feature__r.Name==fd.Feature_Name__c && pf.Salesforce_Product__r.Name==fd.Product__c && pf.Account__c==accId){
                    Product_Feature_Client_Usage__c p=new Product_Feature_Client_Usage__c();
                    p.id=pf.id;
                    p.Client_Usage_Percentage__c=fd.Utilization_in_Percentage__c;
                    PFCUUpdateList.add(p);
                }
                
            }
        }
        return PFCUUpdateList;
    }
    
    //To Update Product client usage.
    public static Product_Client_Usage__c getProductClientUsage(string accId,SalesforceUtilizationBasisAttributeData__mdt utilization){
        system.debug('utilization---'+utilization);
        Product_Client_Usage__c productClientUsageMap=[SELECT id,Account__c,Product_Name__c,Salesforce_Product_Usage__c,Salesforce_Product__c FROM Product_Client_Usage__c where Account__c =:accId AND Product_Name__c=:utilization.Product__c limit 1];
        Product_Client_Usage__c p=new Product_Client_Usage__c();
        p.Id=productClientUsageMap.id;
        p.Salesforce_Product_Usage__c=utilization.Utilization_in_Percentage__c;
        return p;    
    }
    
}