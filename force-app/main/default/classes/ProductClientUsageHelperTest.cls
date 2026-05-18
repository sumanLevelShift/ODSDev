@isTest
public class ProductClientUsageHelperTest {
    @isTest
    Public Static void createProductToClientTest(){
        Account newAccount=new Account();
        newAccount.Name='Demand Test';
        newAccount.Lead_Gen_Name__c = 'Others';
        insert newAccount;
        
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='Marketing';
        newSalesforceProduct.Product_Percentage__c=100;
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
        
        newAccount.Industry='Nonprofit Organization';
        newAccount.AnnualRevenue=1000;
        update newAccount;
        
        delete newSalesforceProductFeature1;
        delete newSalesforceProduct1;
        system.assertEquals(newProductClientUsage.Salesforce_Product__c, newSalesforceProduct.id,'Its Working Education');
    }
}