/*******************************************************************************************
* @author           Sathish & Suman
* @version          1.0 
* @date             30-MAR-2021
* @Status           In-Progress
* @Class Name     	ProdSubfeatureClientUsageController
* @description      This apex class is controller for web comp - ProdSubfeatureClientUsageManualEntryList

*********************************************************************************************
Version     Date               Team          Comments
*********************************************************************************************
* 1      	Mar 2021    Sathish & Suman         Initial Creation
*********************************************************************************************/
public without sharing class ProdSubfeatureClientUsageController {
    
    @AuraEnabled (cacheable=true)
    public static List<Account> getAccountList(){
        set<id> accountIdList=new set<id>();
        string userID=UserInfo.getUserId();
        List<User_Account__c> userAccList=[SELECT Name, User__c, Account__c,Account__r.Count_of_ODS_Engagement_Type__c,  Account__r.name, Account__r.Count_of_Services__c FROM User_Account__c WHERE Account__r.Is_Portal_Access__c =: true AND Account__r.Count_of_Services__c >: 0];
        for(User_Account__c ua:userAccList){
            accountIdList.add(ua.Account__c);
        }
        return [SELECT Id, Name FROM Account where Id IN: accountIdList ORDER BY Name ASC LIMIT 10000];
    }
    @AuraEnabled (cacheable=false)
    public static List<Salesforce_Product_Feature__c> getFeatureList(string productId){
        Set<Id> subFeatureIDList = new Set<Id>();
        Set<Id> featureIDList = new Set<Id>();
        List<Salesforce_Subfeature_Rules__c> salesforceSubfeatureRule=[SELECT Id, Salesforce_Product_Subfeature__c FROM Salesforce_Subfeature_Rules__c WHERE Type__c = 'Manual' AND Salesforce_Product_Subfeature__r.Active__c=true];
        for(Salesforce_Subfeature_Rules__c item:salesforceSubfeatureRule){
            subFeatureIDList.add(item.Salesforce_Product_Subfeature__c);  
        }
        List<Salesforce_Product_Subfeature__c> salesforceSubfeatureList=[SELECT Id, Subfeature_Percentage__c,Name,Salesforce_Product_Feature__c, Salesforce_Product_Feature__r.Name,Salesforce_Product_Feature__r.Salesforce_Product__c FROM Salesforce_Product_Subfeature__c where Id IN: subFeatureIDList AND Active__c=true];
        for(Salesforce_Product_Subfeature__c spf:salesforceSubfeatureList){
           featureIDList.add(spf.Salesforce_Product_Feature__c);
        }
        return [Select Id,Name from Salesforce_Product_Feature__c where Salesforce_Product__c=:productId AND ID IN: featureIDList AND Active__c=true ORDER BY Name ASC];
    }
    @AuraEnabled (cacheable=false)
    public static List<Salesforce_Product__c> getProductList(string accountId){
        Set<Id> subFeatureIDList = new Set<Id>();
        Set<Id> productIDList = new Set<Id>();
        Set<Id> filterProductId=New Set<Id>();
        filterProductId.addAll(SalesforceProductFilterHelper.productFilter(accountId));
        List<Salesforce_Subfeature_Rules__c> salesforceSubfeatureRule=[SELECT Id, Salesforce_Product_Subfeature__c FROM Salesforce_Subfeature_Rules__c WHERE Type__c = 'Manual' AND Salesforce_Product_Subfeature__r.Active__c=true];
        for(Salesforce_Subfeature_Rules__c item:salesforceSubfeatureRule){
            subFeatureIDList.add(item.Salesforce_Product_Subfeature__c);  
        }
        List<Salesforce_Product_Subfeature__c> salesforceSubfeatureList=[SELECT Id, Subfeature_Percentage__c,Name,Salesforce_Product_Feature__c, Salesforce_Product_Feature__r.Name,Salesforce_Product_Feature__r.Salesforce_Product__c FROM Salesforce_Product_Subfeature__c where Id IN: subFeatureIDList AND Active__c=true];
        for(Salesforce_Product_Subfeature__c spf:salesforceSubfeatureList){
            if(filterProductId.contains(spf.Salesforce_Product_Feature__r.Salesforce_Product__c)){
                productIDList.add(spf.Salesforce_Product_Feature__r.Salesforce_Product__c);
            }
        }
     
        List<Salesforce_Product__c> returnProduct=[SELECT Id,Name FROM Salesforce_Product__c WHERE ID IN: productIDList ORDER BY Name ASC];
        return returnProduct;
    }
    @AuraEnabled (cacheable=false)
    public static List<Product_Subfeature_Client_Usage__c> getManualEntrySubFeatureList(string featureId,string accountId){
        Set<Id> subFeatureIDList = new Set<Id>();
        Set<Id> productClientSubFeatureIDList=new Set<Id>();
        List<Salesforce_Subfeature_Rules__c> salesforceSubfeatureRule=[SELECT Id, Salesforce_Product_Subfeature__c FROM Salesforce_Subfeature_Rules__c WHERE Type__c = 'Manual' AND Salesforce_Product_Subfeature__r.Active__c=true];
        for(Salesforce_Subfeature_Rules__c item:salesforceSubfeatureRule)
            subFeatureIDList.add(item.Salesforce_Product_Subfeature__c);  
        
        List<Salesforce_Product_Subfeature__c> salesforceSubfeatureList=[SELECT Id, Subfeature_Percentage__c,Name,Salesforce_Product_Feature__c, Salesforce_Product_Feature__r.Name,Salesforce_Product_Feature__r.Salesforce_Product__c FROM Salesforce_Product_Subfeature__c where Id IN: subFeatureIDList AND Salesforce_Product_Feature__c=:featureId AND Active__c=true];
        for (Salesforce_Product_Subfeature__c ss:salesforceSubfeatureList){
            productClientSubFeatureIDList.add(ss.id);
        }
        List<Product_Subfeature_Client_Usage__c> productSubFeatureList=[SELECT Account__c,Client_Usage_Percentage__c,Name,Salesforce_Product_Subfeature__c,Salesforce_Product__c 
                                                                        FROM Product_Subfeature_Client_Usage__c where Account__c=:accountId and Salesforce_Product_Subfeature__c IN:productClientSubFeatureIDList];
        if(productSubFeatureList.isEmpty()){
            for(Salesforce_Product_Subfeature__c sp:salesforceSubfeatureList){
                id pfcu=[Select id from Product_Feature_Client_Usage__c where Salesforce_Product_Feature__c=:sp.Salesforce_Product_Feature__c and Account__c=:accountId limit 1].id;
                Product_Subfeature_Client_Usage__c p=new Product_Subfeature_Client_Usage__c();
                p.Account__c=accountId;
                p.Salesforce_Product__c=sp.Salesforce_Product_Feature__r.Salesforce_Product__c;
                p.Salesforce_Product_Feature__c=sp.Salesforce_Product_Feature__c;
                p.Salesforce_Product_Subfeature__c=sp.id;
                p.Subfeature_Weightage__c=sp.Subfeature_Percentage__c;
                p.Product_Feature_Client_Usage__c=pfcu;
                p.Client_Usage_Percentage__c=0;
                p.Name=sp.Name;
                productSubFeatureList.add(p);
            }
            insert productSubFeatureList;
        }
        return productSubFeatureList;
    }
    
    /*
@AuraEnabled (cacheable=true)
public static Salesforce_Product_Feature__c getFeatureName(){
Salesforce_Product_Feature__c spf=[SELECT Id,Name,Salesforce_Product__c FROM Salesforce_Product_Feature__c WHERE Salesforce_Product__r.Name =: 'Sales Cloud' AND Name =: 'Lead Management'];
return spf;
}*/
    
    @AuraEnabled (cacheable=false)
    public static void saveProductSubFeatureClientUsage(String clientUsageJson,String accountId,String leadMgtFeatureId,String productId){
        system.debug('feat--'+leadMgtFeatureId);
        system.debug('pro--'+productId);
        system.debug('acc--'+accountId);
        set<Id> featureIDList=new Set<id>{leadMgtFeatureId};
            Map<String,Decimal> subfeatureIdAndUsageMap = new Map<String,Decimal>();
        system.debug('clientUsageJson-'+clientUsageJson);
        for(object ob : (List<object>) json.deserializeUntyped(clientUsageJson)) 
        {
            Map<String, object> obmap = (Map<String, object>)ob;
            subfeatureIdAndUsageMap.put((String)obmap.get('Id'), Decimal.valueOf((String)obmap.get('Client_Usage_Percentage__c')));
            system.debug('subfeatureIdAndUsageMap--'+subfeatureIdAndUsageMap);
        }        
        
        //Get the Subfeature client usage records from DB which needs to be updated
        List<Product_Subfeature_Client_Usage__c> subfeatureExistingClientUsageList = new List<Product_Subfeature_Client_Usage__c>();
        subfeatureExistingClientUsageList=[SELECT Id, Salesforce_Product_Subfeature__c, Client_Usage_Percentage__c FROM Product_Subfeature_Client_Usage__c 
                                           where Account__c=:accountId AND 
                                           Salesforce_Product_Feature__c=:leadMgtFeatureId AND 
                                           //Salesforce_Product__c=:productId AND 
                                           ID IN:subfeatureIdAndUsageMap.keySet()];
        system.debug('subfeatureExistingClientUsageList-'+subfeatureExistingClientUsageList);
        //Update the Subfeature client usage records to DB
        List<Product_Subfeature_Client_Usage__c> toBeUpdatedSubfeatureClientUsageList = new List<Product_Subfeature_Client_Usage__c>();
        for(Product_Subfeature_Client_Usage__c item : subfeatureExistingClientUsageList){
            item.Client_Usage_Percentage__c = subfeatureIdAndUsageMap.get(item.Id);
            toBeUpdatedSubfeatureClientUsageList.add(item);
        }
        update toBeUpdatedSubfeatureClientUsageList; 
        
        ProdSubfeatureClientUsageHelper helper = new ProdSubfeatureClientUsageHelper();
        //Now get all subfeature client usage records for all subfeatures(under parent Feature) from Product_Subfeature_Client_Usage__c object
        List<Product_Subfeature_Client_Usage__c> subfeatureClientUsageList = helper.getAllSubFeatureUsageRecordsFromDB(accountId, productId, featureIDList);
        for(id featureId:featureIDList)
        {
            //Calculate the cumlative usage of all subfeatures & update the parent feature usage record.To be updated to Product_Feature_Client_Usage__c record
            Decimal sumClientUsageWeightageOfSubfeatures = helper.getSumOfClientUsageWeightageOfSubfeatures(subfeatureClientUsageList,featureId,accountId);
            //Now update the parent feature usage record's Client Usage
            Product_Feature_Client_Usage__c prodFeatureUsageToBeUpdated = helper.getProdFeatureUsageRecToBeUpdated(featureId, productId, accountId);
            prodFeatureUsageToBeUpdated.Client_Usage_Percentage__c = sumClientUsageWeightageOfSubfeatures.round(System.RoundingMode.HALF_UP);
            update prodFeatureUsageToBeUpdated;
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static List<Product_Subfeature_Client_Usage__c> getProductSubFeatureDetails(string subFeatureName,string accountId,string cloudName){
        system.debug('subFeatureName-'+subFeatureName);
        return [Select Id,Name,Client_Usage_Percentage__c,Chart_Color_Code__c,Salesforce_Product__r.Name from Product_Subfeature_Client_Usage__c where Salesforce_Product__r.Name=:cloudName and Salesforce_Product_Feature__r.Name=:subFeatureName and Account__c=:accountId AND Salesforce_Product_Subfeature__r.Active__c=true ORDER BY Name ASC];
    }
    
    public static List<Product_Client_Usage__c> calculateAvgUsage(account a){
        List<Product_Client_Usage__c> updateProductClientUsageAVG=new list<Product_Client_Usage__c>();
        AggregateResult[] aggregateList=[SELECT Sum(Salesforce_Product_Usage__c), Account__c  FROM Product_Client_Usage__c 
                                         where Account__c =:a.id group by Account__c];
        for(AggregateResult ar:aggregateList)
        {
            for(Product_Client_Usage__c pc:[Select id,Salesforce_Product_Usage__c,Usage_Weighted_Average__c,Account__c from Product_Client_Usage__c where Account__c=:a.id])  
            {
                Product_Client_Usage__c p=new Product_Client_Usage__c();
                p.id=pc.id;
                p.Usage_Weighted_Average__c=(pc.Salesforce_Product_Usage__c/(decimal)ar.get('expr0'))*100;
                updateProductClientUsageAVG.add(p);
            } 
        }
        return updateProductClientUsageAVG;
    }
    public static void updateCustomMetaData(string accountId,datetime CompletedDate){
        
        ClientAndNamedCredMapping__mdt clientandNameCred=[SELECT Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c =:accountID];
        
        clientandNameCred.Last_Run_Date_Time__c=CompletedDate;
        if(clientandNameCred.Schedule_Frequency__c=='Daily'){
            clientandNameCred.Next_Run_Date_Time__c=Datetime.now().addDays(1);
        }else if(clientandNameCred.Schedule_Frequency__c=='Weekly'){
            clientandNameCred.Next_Run_Date_Time__c=Datetime.now().addDays(7);
        }else if(clientandNameCred.Schedule_Frequency__c=='Monthly'){                    
            clientandNameCred.Next_Run_Date_Time__c=Datetime.now().addMonths(1);
        }else if(clientandNameCred.Schedule_Frequency__c=='Quarterly'){
            clientandNameCred.Next_Run_Date_Time__c=Datetime.now().addMonths(3);
        }
        clientandNameCred.In_progress__c=false;

        String jobId2 = Test.isRunningTest() ? 'Fake Job Id' : CustomMetaDataUpdation.upsertMetadata(clientandNameCred);
    }
   @future(callout=true)
    public static void updateCustomMetaDataForInProgress(string accountId,boolean inProgress){
        ClientAndNamedCredMapping__mdt clientandNameCred=[SELECT In_progress__c,Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c =:accountID];
        clientandNameCred.In_progress__c=inProgress;
        String jobId2 = Test.isRunningTest() ? 'Fake Job Id' : CustomMetaDataUpdation.upsertMetadata(clientandNameCred);
    }
    @AuraEnabled(cacheable=false)  
    public static boolean checkConnectedApp(string accountId){
        try{
            ClientAndNamedCredMapping__mdt conApp=[SELECT id,Account_Id__c,Is_Active__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Account_Id__c=:accountId];
            return conApp.Use_Connected_App__c;    
        }catch(exception e){
            return false;
        }
        
    }
}