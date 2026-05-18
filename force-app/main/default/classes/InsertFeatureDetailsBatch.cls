global class InsertFeatureDetailsBatch implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,name,Salesforce_Product__c from Salesforce_Product_Feature__c';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Salesforce_Product_Feature__c> scope) 
    {
		Set<string> setfeaturenames = new Set<string>();
		set<string> sfproduct = new set<string>();
        for(Salesforce_Product_Feature__c a : scope)
        {
			setfeaturenames.add(a.name);
			sfproduct.add(a.Salesforce_Product__c);
            system.debug('feature name--' +setfeaturenames);
            system.debug('feature name--' +sfproduct);
        }

       List<SF_Feature_Details__c> featureDetailsList= new List<SF_Feature_Details__c> ();
      
       for(Salesforce_Product_Feature__c eachrecord: scope){
           system.debug('for feature name--' +eachrecord.name);
           system.debug('for product id--' +eachrecord.Salesforce_Product__c);
               SF_Feature_Details__c featuredetails = new SF_Feature_Details__c();
               featuredetails.Feature_ID__c = eachrecord.id;
               featuredetails.IsActive__c=true;
               featureDetailsList.add(featuredetails);
        }
         insert featureDetailsList;
    }
    global void finish(Database.BatchableContext BC) {
    }
}