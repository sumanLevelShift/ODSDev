public class UpdateChartColorHelper {
    public Static void salesforceProduct(List<Salesforce_Product__c> salesforceProductTrigger){
        List<Salesforce_Product__c> existRecord=[SELECT Chart_Color__c,Id  FROM Salesforce_Product__c where Chart_Color__c !=:''];
        Set<string> checkChartColor=new set<string>();
        List<Salesforce_Product__c> updateSalesforceProduct=New List<Salesforce_Product__c>();
        for(Salesforce_Product__c s:existRecord){
            checkChartColor.add(s.Chart_Color__c);
        }
        for(Salesforce_Product__c s:salesforceProductTrigger){
            if(s.Chart_Color__c == null){
                Salesforce_Product__c sp=new Salesforce_Product__c();
                sp.id=s.id;
                //integer r = integer.valueOf(Math.random() * 255);
                //integer g = integer.valueOf(Math.random() * 255);
                //integer b = integer.valueOf(Math.random() * 255);
                string c=generateRandom();
                if(checkChartColor.Contains(c)){

                    c=generateRandom();
                    sp.Chart_Color__c=c; 
                }
                else{
                    sp.Chart_Color__c=c; 
                }
                updateSalesforceProduct.add(sp);
            }   
        }
        if(!updateSalesforceProduct.isEmpty()){
            update updateSalesforceProduct;
        }
    }
    public Static void salesforceProductFeature(List<Salesforce_Product_Subfeature__c> salesforceProductFeatureTrigger){
        List<Salesforce_Product_Subfeature__c> updateProductFeature=New List<Salesforce_Product_Subfeature__c>();
        Set<id> salesforceFeatureId=new set<id>();
        for(Salesforce_Product_Subfeature__c s:salesforceProductFeatureTrigger){
            salesforceFeatureId.add(s.Salesforce_Product_Feature__c);
        }
        List<Salesforce_Product_Subfeature__c> existRecord=[SELECT Chart_Color__c,Id  FROM Salesforce_Product_Subfeature__c where  Salesforce_Product_Feature__c IN:salesforceFeatureId AND Chart_Color__c !=:''];
        Set<string> checkChartColor=new Set<string>();
        for(Salesforce_Product_Subfeature__c s:existRecord){
            checkChartColor.add(s.Chart_Color__c);
        }
        for(Salesforce_Product_Subfeature__c s:salesforceProductFeatureTrigger){
            if(s.Chart_Color__c == Null){
                Salesforce_Product_Subfeature__c pf=new Salesforce_Product_Subfeature__c();
                pf.id=s.id;
                //integer r = integer.valueOf(Math.random() * 255);
                //integer g = integer.valueOf(Math.random() * 255);
                //integer b = integer.valueOf(Math.random() * 255);
                string c=generateRandom();
                if(checkChartColor.Contains(c)){
                    c=generateRandom();
                    pf.Chart_Color__c=c; 
                }
                else{
                    pf.Chart_Color__c=c; 
                }
                updateProductFeature.add(pf);      
            }  
            if(!updateProductFeature.isEmpty()){
                update updateProductFeature;
            }
        }
    }
    Private static string generateRandom(){
        integer r = integer.valueOf(Math.random() * 255);
        integer g = integer.valueOf(Math.random() * 255);
        integer b = integer.valueOf(Math.random() * 255);
        string c='rgb('+r+','+g+','+b+')';
        return c;
    }
}