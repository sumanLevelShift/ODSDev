@isTest
public class SalesforceUtilizationBasisHelperTest {
    @isTest
    Public static void utlizationMethod(){
        
        Salesforce_Product__c newSalesforceProducttest=new Salesforce_Product__c();
        newSalesforceProducttest.Name='Sales Cloud';
        newSalesforceProducttest.Product_Percentage__c=100;
        insert newSalesforceProducttest;
        
        Salesforce_Product_Feature__c newSalesforceProductFeatureTest=new Salesforce_Product_Feature__c();
        newSalesforceProductFeatureTest.Name='Lead Management';
        newSalesforceProductFeatureTest.Salesforce_Product__c=newSalesforceProducttest.id;
        newSalesforceProductFeatureTest.Client_Usage_Percentage__c=100;
        newSalesforceProductFeatureTest.Feature_Percentage__c=100;
        insert newSalesforceProductFeatureTest; 
        
        Salesforce_Product_Feature__c newSalesforceProductFeatureTest1=new Salesforce_Product_Feature__c();
        newSalesforceProductFeatureTest1.Name='Account and Contact Management';
        newSalesforceProductFeatureTest1.Salesforce_Product__c=newSalesforceProducttest.id;
        newSalesforceProductFeatureTest1.Client_Usage_Percentage__c=100;
        newSalesforceProductFeatureTest1.Feature_Percentage__c=100;
        insert newSalesforceProductFeatureTest1;
        
        Salesforce_Product_Subfeature__c newSalesforceSubFeature=new Salesforce_Product_Subfeature__c();
        newSalesforceSubFeature.Name='Contact Validation Rule';
        newSalesforceSubFeature.Client_Usage_Percentage__c=100;
        newSalesforceSubFeature.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest1.id;
        newSalesforceSubFeature.Subfeature_Percentage__c=89;
        insert newSalesforceSubFeature;
        
        //Service Cloud
        Salesforce_Product__c newSalesforceProducttest1=new Salesforce_Product__c();
        newSalesforceProducttest1.Name='Service Cloud';
        newSalesforceProducttest1.Product_Percentage__c=100;
        insert newSalesforceProducttest1;
        
        Account newAccount = new Account();
        newAccount.Name = 'TestAccount';
        newAccount.AnnualRevenue = 666;
        newAccount.Phone = '95543567654';
        newAccount.Industry = 'Nonprofit';
        newAccount.Lead_Gen_Name__c = 'Others';
        insert newAccount;
        
        Product_Client_Usage__c newProductClientUsage=new Product_Client_Usage__c();
        newProductClientUsage.Account__c=newAccount.id;
        newProductClientUsage.Salesforce_Product__c=newSalesforceProducttest.id;
        newProductClientUsage.Salesforce_Product_Usage__c=100;
        insert newProductClientUsage;
        
        Product_Feature_Client_Usage__c newProductFeatureClient=new Product_Feature_Client_Usage__c();
        newProductFeatureClient.Product_Client_Usage__c=newProductClientUsage.id;
        newProductFeatureClient.Account__c=newAccount.id;
        newProductFeatureClient.Salesforce_Product__c=newSalesforceProducttest.id;
        newProductFeatureClient.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest.id;
        newProductFeatureClient.Client_Usage_Percentage__c=100;
        newProductFeatureClient.Feature_Percentage__c=100;
        insert newProductFeatureClient;
        
        Product_Feature_Client_Usage__c newProductFeatureClient1=new Product_Feature_Client_Usage__c();
        newProductFeatureClient1.Product_Client_Usage__c=newProductClientUsage.id;
        newProductFeatureClient1.Account__c=newAccount.id;
        newProductFeatureClient1.Salesforce_Product__c=newSalesforceProducttest.id;
        newProductFeatureClient1.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest1.id;
        newProductFeatureClient1.Client_Usage_Percentage__c=100;
        newProductFeatureClient1.Feature_Percentage__c=100;
        insert newProductFeatureClient1;
        
        Product_Subfeature_Client_Usage__c newPSCU=new Product_Subfeature_Client_Usage__c();
        newPSCU.Account__c=newAccount.id;
        newPSCU.Client_Usage_Percentage__c=0;
        newPSCU.Name='Contact Validation Rule';
        newPSCU.Salesforce_Product__c=newSalesforceProducttest.id;
        newPSCU.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest1.id;
        newPSCU.Salesforce_Product_Subfeature__c=newSalesforceSubFeature.id;
        newPSCU.Subfeature_Weightage__c=90;
        insert newPSCU;
        
         Product_Client_Usage__c newProductClientUsage1=new Product_Client_Usage__c();
        newProductClientUsage1.Account__c=newAccount.id;
        newProductClientUsage1.Salesforce_Product__c=newSalesforceProducttest1.id;
        newProductClientUsage1.Salesforce_Product_Usage__c=100;
        insert newProductClientUsage1;
        
        system.assertEquals(newProductClientUsage1.Account__c, newAccount.id);
        
    }
}