@isTest
public class SalesforceProductTest {
    @isTest
    Public Static void newAccount(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account newAccount=new Account();
        newAccount.Name='salesforce Account';
        newAccount.Salesforce_Products__c='FSL,Salesforce Platform';
        newAccount.Lead_Gen_Name__c = 'Others';
        insert newAccount;
        
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='Salesforce Platform';
        newSalesforceProduct.Product_Percentage__c=100;
        newSalesforceProduct.Description__c='Test';
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature.Name='Block Chain';
        newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature.Feature_Percentage__c=100;
        insert newSalesforceProductFeature;
        SalesforceProduct.fetchSalesforceProductAfterAccountSelect(newAccount.id);
    }
    @isTest
    Public Static void fetchProductTest(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account newAccount=new Account();
        newAccount.Name='salesforce Account';
        newAccount.Salesforce_Products__c='FSL,Salesforce Platform';
        newAccount.Lead_Gen_Name__c = 'Others';
        insert newAccount;
        
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='FSL';
        newSalesforceProduct.Product_Percentage__c=100;
        newSalesforceProduct.Description__c='Test';
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature.Name='Block Chain';
        newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature.Feature_Percentage__c=100;
        insert newSalesforceProductFeature;
        List<object> updateRecord=new List<object>();
        updateRecord.add('{Account__c='+newAccount.id+', Salesforce_Product_Usage__c=24, Salesforce_Product__c ='+newSalesforceProduct.id+'}');
        
        string featureUpdateValue='[{"Id":"'+newSalesforceProductFeature.id+'","Client_Usage_Percentage__c":"100"}]';
        
        Test.startTest();
        SalesforceProduct.fetchSalesforceProductAfterAccountSelect(newAccount.id);
        SalesforceProduct.fetchSalesforceProduct();
        SalesforceProduct.fetchSalesforceProductPercentage();
        SalesforceProduct.findFeaturesProduct('FSL',newAccount.id);
        SalesforceProduct.createSalesforceClientUsage(updateRecord,newAccount.id);
        SalesforceProduct.updateClientFeatureUsage(featureUpdateValue,newAccount.id);
        SalesforceProduct.findRecords('Salesforce','Account');
        SalesforceProduct.getCloudName(newSalesforceProductFeature.id);
        SalesforceProduct.getCloudNameFromSP(newSalesforceProduct.id);
        Test.stopTest();
        Salesforce_Product__c newSalesforceProduct1=new Salesforce_Product__c();
        newSalesforceProduct1.Name='Salesforce Platform';
        newSalesforceProduct1.Product_Percentage__c=89;
        newSalesforceProduct1.Description__c='Test';
        insert newSalesforceProduct1;
        Salesforce_Product_Feature__c newSalesforceProductFeature2=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature2.Name='SaaS';
        newSalesforceProductFeature2.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature2.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature2.Feature_Percentage__c=100;
        insert newSalesforceProductFeature2;
        Salesforce_Product_Feature__c newSalesforceProductFeature3=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature3.Name='PaaS';
        newSalesforceProductFeature3.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature3.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature3.Feature_Percentage__c=100;
        insert newSalesforceProductFeature3;
        newSalesforceProductFeature3.Feature_Percentage__c=88;
        update newSalesforceProductFeature3;
        delete newSalesforceProductFeature2;
        delete newSalesforceProduct1;
        
        system.assertEquals(newSalesforceProductFeature.Salesforce_Product__c,newSalesforceProduct.id,'Its Working');
        
    }
    
    @isTest
    Public Static void updateRecordTest(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account newAccount=new Account();
        newAccount.Name='Test Account';
        newAccount.Salesforce_Products__c='Sales Cloud';
        newAccount.Lead_Gen_Name__c = 'Others';
        insert newAccount;
        
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='Sales Cloud';
        newSalesforceProduct.Product_Percentage__c=100;
        newSalesforceProduct.Description__c='Test';
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature.Name='API';
        newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature.Feature_Percentage__c=100;
        insert newSalesforceProductFeature;   
        
        List<object> updateRecord=new List<object>();
        updateRecord.add('{Account__c='+newAccount.id+', Salesforce_Product_Usage__c=24, Salesforce_Product__c ='+newSalesforceProduct.id+'}');
        string featureUpdateValue='[{"Id":"'+newSalesforceProductFeature.id+'","Client_Usage_Percentage__c":"100"}]';
        
        Test.startTest();
        SalesforceProduct.createSalesforceClientUsage(updateRecord,newAccount.id);
        SalesforceProduct.updateClientFeatureUsage(featureUpdateValue,newAccount.id);
        SalesforceProduct.getCloudName(newSalesforceProductFeature.id);
        SalesforceProduct.getCloudNameFromSP(newSalesforceProduct.id);
        Test.stopTest();  
        Product_Client_Usage__c newProductClientUsage=new Product_Client_Usage__c();
        newProductClientUsage.Account__c=newAccount.id;
        newProductClientUsage.Salesforce_Product__c=newSalesforceProduct.id;
        newProductClientUsage.Salesforce_Product_Usage__c=100;
        insert newProductClientUsage;
        
        Product_Feature_Client_Usage__c newProductFeatureClientUsage=new Product_Feature_Client_Usage__c();
        newProductFeatureClientUsage.Product_Client_Usage__c=newProductClientUsage.id;
        newProductFeatureClientUsage.Account__c=newAccount.id;
        newProductFeatureClientUsage.Salesforce_Product__c=newSalesforceProduct.id;
        newProductFeatureClientUsage.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
        newProductFeatureClientUsage.Feature_Percentage__c=newSalesforceProductFeature.Feature_Percentage__c;
        newProductFeatureClientUsage.Client_Usage_Percentage__c=newSalesforceProductFeature.Client_Usage_Percentage__c;
        insert newProductFeatureClientUsage;
        
        Product_Feature_Client_Usage__c newProductFeatureClientUsage1=new Product_Feature_Client_Usage__c();
        newProductFeatureClientUsage1.Product_Client_Usage__c=newProductClientUsage.id;
        newProductFeatureClientUsage1.Account__c=newAccount.id;
        newProductFeatureClientUsage1.Salesforce_Product__c=newSalesforceProduct.id;
        newProductFeatureClientUsage1.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
        newProductFeatureClientUsage1.Feature_Percentage__c=newSalesforceProductFeature.Feature_Percentage__c;
        newProductFeatureClientUsage1.Client_Usage_Percentage__c=newSalesforceProductFeature.Client_Usage_Percentage__c;
        insert newProductFeatureClientUsage1;
        
        newSalesforceProductFeature.Feature_Percentage__c=70;
        update newSalesforceProductFeature;
        ProductClientUsageHelper.quoteRecursion=false;
        delete newProductFeatureClientUsage;
        delete newProductClientUsage;
        
        Salesforce_Product__c newSalesforceProduct1=new Salesforce_Product__c();
        newSalesforceProduct1.Name='Service Cloud';
        newSalesforceProduct1.Product_Percentage__c=100;
        newSalesforceProduct1.Description__c='Test';
        insert newSalesforceProduct1;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature1=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature1.Name='Lead Management';
        newSalesforceProductFeature1.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature1.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature1.Feature_Percentage__c=100;
        insert newSalesforceProductFeature1;
        
        newSalesforceProductFeature1.Feature_Percentage__c=66;
        update newSalesforceProductFeature1;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature2=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature2.Name='SaaS';
        newSalesforceProductFeature2.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature2.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature2.Feature_Percentage__c=100;
        insert newSalesforceProductFeature2;
        Salesforce_Product_Feature__c newSalesforceProductFeature3=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature3.Name='PaaS';
        newSalesforceProductFeature3.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature3.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature3.Feature_Percentage__c=100;
        insert newSalesforceProductFeature3;
        SalesforceProduct.getProductRecordsFromDB(newAccount.id);
        SalesforceProduct.getProductFeatureRecordsFromDB(newAccount.id);
        SalesforceProduct.updateSessionData(newAccount.id, '');
        delete newSalesforceProductFeature1;
        delete newSalesforceProduct1;
        
        system.assertEquals(newSalesforceProductFeature.Salesforce_Product__c,newSalesforceProduct.id,'Its Working Sales');
        
    }
    @isTest
    Public Static void updateFeatureRecordTest(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account newAccount=new Account();
        newAccount.Name='DemandBlue';
        newAccount.Lead_Gen_Name__c = 'Others';
        insert newAccount;
        
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='Sales Cloud';
        newSalesforceProduct.Product_Percentage__c=100;
        newSalesforceProduct.Description__c='Test';
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature.Name='Account And Contact';
        newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature.Feature_Percentage__c=100;
        insert newSalesforceProductFeature;   
        
        List<object> updateRecord=new List<object>();
        updateRecord.add('{Account__c='+newAccount.id+', Salesforce_Product_Usage__c=24, Salesforce_Product__c ='+newSalesforceProduct.id+'}');
        string featureUpdateValue='[{"Id":"'+newSalesforceProductFeature.id+'","Client_Usage_Percentage__c":"100"}]';
        
        Test.startTest();
        //SalesforceProduct.updateClientFeatureUsage(featureUpdateValue,newAccount.id);
        Test.stopTest();  
        
        Salesforce_Product__c newSalesforceProduct1=new Salesforce_Product__c();
        newSalesforceProduct1.Name='Service Cloud';
        newSalesforceProduct1.Product_Percentage__c=100;
        newSalesforceProduct1.Description__c='Test';
        insert newSalesforceProduct1;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature1=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature1.Name='Lead Management';
        newSalesforceProductFeature1.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature1.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature1.Feature_Percentage__c=100;
        insert newSalesforceProductFeature1;
        
        newSalesforceProductFeature1.Feature_Percentage__c=66;
        update newSalesforceProductFeature1;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature2=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature2.Name='SaaS';
        newSalesforceProductFeature2.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature2.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature2.Feature_Percentage__c=100;
        insert newSalesforceProductFeature2;
        Salesforce_Product_Feature__c newSalesforceProductFeature3=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature3.Name='PaaS';
        newSalesforceProductFeature3.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature3.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature3.Feature_Percentage__c=100;
        insert newSalesforceProductFeature3;
        
        delete newSalesforceProductFeature1;
        delete newSalesforceProduct1;
        
        system.assertEquals(updateRecord.size(),1,'Its Working Service');
        
    }
    @isTest 
    Public Static void createProductToClientTest(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account newAccount=new Account();
        newAccount.Name='Demand Test';
        newAccount.Lead_Gen_Name__c = 'Others';
        insert newAccount;
        
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='Marketing';
        newSalesforceProduct.Product_Percentage__c=100;
        newSalesforceProduct.Description__c='Test';
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature.Name='Management';
        newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature.Feature_Percentage__c=100;
        insert newSalesforceProductFeature;
        
        Product_Client_Usage__c newProductClientUsage=new Product_Client_Usage__c();
        newProductClientUsage.Account__c=newAccount.id;
        newProductClientUsage.Salesforce_Product__c=newSalesforceProduct.id;
        newProductClientUsage.Salesforce_Product_Usage__c=100;
        insert newProductClientUsage;
        
        Product_Feature_Client_Usage__c newProductFeatureClientUsage=new Product_Feature_Client_Usage__c();
        newProductFeatureClientUsage.Product_Client_Usage__c=newProductClientUsage.id;
        newProductFeatureClientUsage.Account__c=newAccount.id;
        newProductFeatureClientUsage.Salesforce_Product__c=newSalesforceProduct.id;
        newProductFeatureClientUsage.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
        newProductFeatureClientUsage.Feature_Percentage__c=newSalesforceProductFeature.Feature_Percentage__c;
        newProductFeatureClientUsage.Client_Usage_Percentage__c=newSalesforceProductFeature.Client_Usage_Percentage__c;
        insert newProductFeatureClientUsage;
        
        Salesforce_Product__c newSalesforceProduct1=new Salesforce_Product__c();
        newSalesforceProduct1.Name='Service Cloud';
        newSalesforceProduct1.Product_Percentage__c=100;
        newSalesforceProduct1.Description__c='Test';
        insert newSalesforceProduct1;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature1=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature1.Name='Lead Management';
        newSalesforceProductFeature1.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature1.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature1.Feature_Percentage__c=100;
        insert newSalesforceProductFeature1;
        
        newSalesforceProductFeature1.Feature_Percentage__c=66;
        update newSalesforceProductFeature1;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature2=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature2.Name='SaaS';
        newSalesforceProductFeature2.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature2.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature2.Feature_Percentage__c=100;
        insert newSalesforceProductFeature2;
        Salesforce_Product_Feature__c newSalesforceProductFeature3=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature3.Name='PaaS';
        newSalesforceProductFeature3.Salesforce_Product__c=newSalesforceProduct1.id;
        newSalesforceProductFeature3.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature3.Feature_Percentage__c=100;
        insert newSalesforceProductFeature3;
        
        delete newSalesforceProductFeature1;
        delete newSalesforceProduct1;
        //Salesforce_Product_Feature__c productFature=[Select Id,Salesforce_Product__c From Salesforce_Product_Feature__c where Salesforce_Product__c=:newSalesforceProduct1.id];
        //system.assertEquals(newSalesforceProduct1.id, productFature.Salesforce_Product__c,'Its Working Education');
        system.assertEquals(newProductClientUsage.Salesforce_Product__c, newSalesforceProduct.id,'Its Working Education');
    }
    
}