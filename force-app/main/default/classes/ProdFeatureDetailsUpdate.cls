public class ProdFeatureDetailsUpdate {
    public static void updateFeatureIDinFeatureDetails(List<Salesforce_Product_Feature__c> salesforcePFeature){
      
	  set<string> sffeatureset = new set<string>(); 
        set<string> featureIdNew=new set<string>();
        for(Salesforce_Product_Feature__c featurename :salesforcePFeature){ 
    		featureIdNew.add(featurename.id); 
		}
		for(Salesforce_Product_Feature__c featurename :[select id,name from Salesforce_Product_Feature__c where Id Not IN: featureIdNew]){ 
    		sffeatureset.add(featurename.name); 
		} 
       List<SF_Feature_Details__c> featureDetailsList= new List<SF_Feature_Details__c> ();
      
       for(Salesforce_Product_Feature__c eachrecord: salesforcePFeature){
           if(!sffeatureset.contains(eachrecord.name)){
               SF_Feature_Details__c featuredetails = new SF_Feature_Details__c();
               featuredetails.Feature_ID__c = eachrecord.id;
               featuredetails.IsActive__c=true;
               featureDetailsList.add(featuredetails);
           }
        }
         insert featureDetailsList;
    }
}