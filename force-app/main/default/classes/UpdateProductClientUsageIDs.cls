public class UpdateProductClientUsageIDs {
    public static void updateIds(){
        List<Product_Feature_Client_Usage__c> UdatePFCURecords=new List<Product_Feature_Client_Usage__c>();
        List<Product_Subfeature_Client_Usage__c> UdatePsubFCURecords=new List<Product_Subfeature_Client_Usage__c>();
        List<Product_Feature_Client_Usage__c > PFCUList=[Select ID,Account__c,Salesforce_Product_Feature__c,Salesforce_Product_Feature__r.Salesforce_Product__c,(Select Id,Salesforce_Product__c,Salesforce_Product__r.Name FROM Product_Subfeature_Client_Usages__r) FROM Product_Feature_Client_Usage__c WHERE Account__c !='' AND Salesforce_Product_Feature__c  IN ('a4f8M000000BUdjQAG') LIMIT 10];
        for(Product_Feature_Client_Usage__c pfc:PFCUList){
            Product_Feature_Client_Usage__c updatePFCU=new Product_Feature_Client_Usage__c();
            updatePFCU.Id=pfc.Id;
            updatePFCU.Salesforce_Product__c=pfc.Salesforce_Product_Feature__r.Salesforce_Product__c;
            List<Product_Client_Usage__c> pcu=[Select Id FROM Product_Client_Usage__c WHERE Account__c=:pfc.Account__c AND Salesforce_Product__c=:pfc.Salesforce_Product_Feature__r.Salesforce_Product__c LIMIT 1];
            if(!pcu.isEmpty()){
                updatePFCU.Product_Client_Usage__c=pcu[0].id;
            }
            system.debug('pfc--'+pfc);
            UdatePFCURecords.add(updatePFCU);
            for(Product_Subfeature_Client_Usage__c pscu:pfc.Product_Subfeature_Client_Usages__r){
                Product_Subfeature_Client_Usage__c ps=new Product_Subfeature_Client_Usage__c();
                ps.Id=pscu.Id;
                ps.Salesforce_Product__c=pfc.Salesforce_Product_Feature__r.Salesforce_Product__c;
                UdatePsubFCURecords.add(ps);
            }
        }
        if(!UdatePFCURecords.isEmpty()){
            update UdatePFCURecords;
        }
        if(!UdatePsubFCURecords.isEmpty()){
            update UdatePsubFCURecords;
        }
    }
}