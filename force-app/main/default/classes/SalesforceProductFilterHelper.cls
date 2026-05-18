public class SalesforceProductFilterHelper {
    public static Set<Id> productFilter(string accountId){
        Set<Id> salesforceProductId=New Set<Id>();
        List<String> salesforceProductList=new List<String>();
        List<Account> getAccount=[SELECT Id,Salesforce_Products__c FROM Account WHERE Id=:accountId limit 1];
        if(!getAccount.isEmpty()){
            string products=getAccount[0].Salesforce_Products__c;
            if(string.isNotBlank(products)){
                salesforceProductList = products.split(',');
            }
            List<String> salesforceProductFinal=New List<String>();
            for(String s:salesforceProductList){
                salesforceProductFinal.add(s.trim());
            }    
            salesforceProductFinal.add('Salesforce Platform');            
            List<Salesforce_Product__c> salesforceProductRecords=[SELECT Id,Name FROM Salesforce_Product__c WHERE Name IN: salesforceProductFinal];
            for(Salesforce_Product__c sp:salesforceProductRecords){
                salesforceProductId.add(sp.Id);
            }
        }
        return salesforceProductId;
    }
}