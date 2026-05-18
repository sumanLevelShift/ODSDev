@isTest
public class HeatMapRecordsSchedularTest {
    @isTest
    Public static void heatMapRecord(){
        Account newAccount=new Account();
        newAccount.Name='salesforce Account';
        newAccount.Lead_Gen_Name__c = 'Others';
        insert newAccount;
        
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='FSL';
        newSalesforceProduct.Product_Percentage__c=100;
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature.Name='Block Chain';
        newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature.Feature_Percentage__c=100;
        insert newSalesforceProductFeature;
        
        SF_Feature_Details__c sfFTest=new SF_Feature_Details__c();
        sfFTest.Feature_ID__c=newSalesforceProductFeature.id;
        sfFTest.IsActive__c=true;
        insert sfFTest;
        
        HeatMapRecordsSchedular x1 = new HeatMapRecordsSchedular(newAccount.id);
        String jobId = System.schedule('HeatMap Request From ConApp For '+newAccount.id,'0 24 * * * ?', x1);
        ProdSubfeatureClientUsageBatch cu1=new ProdSubfeatureClientUsageBatch(newSalesforceProductFeature.id,'001',newAccount.id,newSalesforceProduct.id);
        system.assertEquals(sfFTest.IsActive__c, true);
    }
}