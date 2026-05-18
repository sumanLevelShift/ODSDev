@isTest
public class InsertFeatureDetailsBatchTest {
@isTest
    public static void batchClass(){
        Salesforce_Product__c newSalesforceProduct2=new Salesforce_Product__c();
            newSalesforceProduct2.Name='Sales Cloud';
            newSalesforceProduct2.Product_Percentage__c=100;
            insert newSalesforceProduct2;
            
            Salesforce_Product_Feature__c newSalesforceProductFeature1=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature1.Name='Test Feature';
            newSalesforceProductFeature1.Salesforce_Product__c=newSalesforceProduct2.id;
            newSalesforceProductFeature1.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature1.Feature_Percentage__c=100;
            insert newSalesforceProductFeature1;
        Salesforce_Product_Feature__c newSalesforceProductFeature2=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature2.Name='Test Feature';
            newSalesforceProductFeature2.Salesforce_Product__c=newSalesforceProduct2.id;
            newSalesforceProductFeature2.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature2.Feature_Percentage__c=100;
            insert newSalesforceProductFeature2;
        test.startTest();
        Database.executeBatch(new InsertFeatureDetailsBatch());
        test.stopTest();
    }
}