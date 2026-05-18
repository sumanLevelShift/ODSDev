/*******************************************************************************************
* @author           Suman & Sathish
* @version          1.0 
* @date             24-MAR-2021
* @Status           In-Progress
* @Class Name       ProdSubfeatureClientUsageBatch
* @description      This apex class will calculate the subfeature client usage for subfeatures and will finally update the
parent feature client usage. This will be called via schedular - ProdSubfeatureClientUsageSchedular

*********************************************************************************************
Version     Date               Team          Comments
*********************************************************************************************
* 1         Mar 2021    Suman & Sathish          Initial Creation
*********************************************************************************************/
global class ProdSubfeatureClientUsageBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    String accountID;//Hard coded for now
    String productID;//Hard coded for now
    //String leadMgtFeatureId = 'a4f030000004CuP';//Hard coded for now
    //set<id> featureIDDemo=new set<id>{'a3P3D000001GBEDUA4','a3P3D000001GBEEUA4'};
    Set<id> featureIdList=new set<id>();  
    List<Product_Feature_Client_Usage__c> updatePFCUList=new List<Product_Feature_Client_Usage__c>();
    List<Heat_Map_Log__c> heatMapLogList=new list<Heat_Map_Log__c>();
    
    string featureid;
    string orderId;
    public ProdSubfeatureClientUsageBatch(string featureId,string orderId,string acc,string product){
        this.featureIdList.add(featureId);
        this.orderId=orderId;
        this.accountID=acc;
        this.productID=product;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('account id--'+accountID+'+productID-'+productID+'-featureIdList-'+featureIdList+'-orderId-'+orderId);
        //Get the Parent feature usage record. The 'Client_Usage_Percentage__c' for this record will be updated in the end finally. 
        return Database.getQueryLocator('SELECT Id,Client_Usage_Percentage__c,Salesforce_Product_Feature__r.Name FROM Product_Feature_Client_Usage__c WHERE Salesforce_Product_Feature__c IN : featureIdList AND Salesforce_Product__c=:productID AND Account__c =:accountID ORDER BY CreatedDate DESC');
    }
    global void execute(Database.BatchableContext BC, List<Product_Feature_Client_Usage__c> scope) {
        ProdSubfeatureClientUsageHelper helper=new ProdSubfeatureClientUsageHelper();
        System.debug('### Query Locator Result Id - ' + scope.get(0).Id);
        try{
            
            Product_Feature_Client_Usage__c prodFeatureUsageToBeUpdated = scope.get(0);
            //Product_Feature_Client_Usage__c prodFeatureUsageToBeUpdated = helper.getProdFeatureUsageRecToBeUpdated(leadMgtFeatureId, productId, accountID);
            Map<string,string> subfeatureWithRecommendation=new Map<string,string>();
            //Get all subfeatures list and calculate their usage in the client org/account
            Map<Salesforce_Product_Subfeature__c,Integer> subfeatureAndOrgResultMap=new Map<Salesforce_Product_Subfeature__c,Integer>();
            List<Salesforce_Product_Subfeature__c> leadMgtSubfeatureList = helper.getSubfeatureList(featureIdList);
            List<Recommendation_Mapping__mdt> recommendationMapping=[SELECT Lookup_Field_Name__c,Lower_Limit__c,Upper_Limit__c FROM Recommendation_Mapping__mdt ORDER BY DeveloperName ASC NULLS FIRST];
            for(Salesforce_Product_Subfeature__c subfeatureItem : leadMgtSubfeatureList){
                Map<id,Map<id,integer>> ruleListMap=new Map<id,Map<id,integer>>(); 
                system.debug('subfeatureItem-'+subfeatureItem);
                if(helper.checkIfSubFeatureUsageToBeAddedManually(subfeatureItem.Id))
                    continue;
                Integer usagePercentage = 0;
                system.debug('subfeatureItem-'+subfeatureItem.id);
                system.debug('accountID--'+accountID);
                ruleListMap = helper.checkForUsageInClientOrg(accountID,subfeatureItem.Id);
                usagePercentage=helper.calculatedFinalUsage(ruleListMap,subfeatureItem.Name);
                subfeatureAndOrgResultMap.put(subfeatureItem, usagePercentage);
                heatMapLogList.addAll(helper.heatMapLogList);
                for(id subfeatureId:ruleListMap.keySet()){
                    Map<id,integer> rulesWithUsageMap=ruleListMap.get(subfeatureId);
                    string recommendationContent='';
                    for(id subRuleId:rulesWithUsageMap.keySet()){
                        integer usage=rulesWithUsageMap.get(subRuleId);
                        List<Salesforce_Subfeature_Rules__c> subfeatureRuleRecord=[SELECT id,Recommendation_Excellent__c,Recommendation_Fair__c,Recommendation_Good__c,Recommendation_Poor__c FROM Salesforce_Subfeature_Rules__c Where Id=:subRuleId];
                        for(Recommendation_Mapping__mdt rm:recommendationMapping){
                            if(usage>=rm.Lower_Limit__c && usage<=rm.Upper_Limit__c){
                                if(rm.Lookup_Field_Name__c =='Poor'){
                                    recommendationContent +=subfeatureRuleRecord[0].Recommendation_Poor__c;
                                }
                                if(rm.Lookup_Field_Name__c =='Fair'){
                                    recommendationContent +=subfeatureRuleRecord[0].Recommendation_Fair__c;
                                }
                                if(rm.Lookup_Field_Name__c =='Good'){
                                  recommendationContent +=subfeatureRuleRecord[0].Recommendation_Good__c;  
                                }
                                if(rm.Lookup_Field_Name__c =='Excellent'){
                                  recommendationContent +=subfeatureRuleRecord[0].Recommendation_Excellent__c;   
                                }
                                subfeatureWithRecommendation.put(subfeatureId,recommendationContent);
                            }
                        }
                    } 
                }
            }
            //Now get the existing subfeature client usage records for all subfeatures(under parent Feature) from Product_Subfeature_Client_Usage__c object
            Map<Id,Product_Subfeature_Client_Usage__c> subfeatureIdAndExistingClientUsageMap = helper.getSubFeatureUsageRecordsFromDB(accountID, productID, featureIdList);
            //And update the subfeature client usage for all subfeatures in the above existing list
            helper.updateSubFeatureUsageRecordsInDB(subfeatureIdAndExistingClientUsageMap, subfeatureAndOrgResultMap, prodFeatureUsageToBeUpdated, accountID,subfeatureWithRecommendation);
            
            //Calculate the cumlative usage of all subfeatures & update the parent feature usage record.To be updated to Product_Feature_Client_Usage__c record
            List<Product_Subfeature_Client_Usage__c> subfeatureClientUsageUpdatedList = helper.getAllSubFeatureUsageRecordsFromDB(accountID, productID, featureIdList);
            //subfeatureClientUsageUpdatedList=[Select ID,Client_Usage_Weightage__c from  Product_Subfeature_Client_Usage__c where Salesforce_Product_Feature__c=:'a4f030000004CuP'];
            //Map<id,Product_Subfeature_Client_Usage__c> proSubCUMap=new Map<id,Product_Subfeature_Client_Usage__c>(subfeatureClientUsageUpdatedList);
            for (Id featureId:featureIdList){
                Decimal sumClientUsageWeightageOfSubfeatures = helper.getSumOfClientUsageWeightageOfSubfeatures(subfeatureClientUsageUpdatedList,featureId,accountId);
                system.debug('sumClientUsageWeightageOfSubfeatures--'+sumClientUsageWeightageOfSubfeatures);
                //Now update the parent feature usage record's Client Usage
                Product_Feature_Client_Usage__c  PFCU=[SELECT Client_Usage_Percentage__c,Id FROM Product_Feature_Client_Usage__c WHERE Account__c =: accountID AND Salesforce_Product_Feature__c =: featureID AND Salesforce_Product__c =: productID Limit 1];
                PFCU.Client_Usage_Percentage__c = sumClientUsageWeightageOfSubfeatures.round(System.RoundingMode.HALF_UP);
                updatePFCUList.add(PFCU);
            }
            
            if(!updatePFCUList.IsEmpty()){
                Update updatePFCUList; 
                for (Id featureId:featureIdList){
                    //Heat Map Log: Account ID, Product ID, Feature ID, Apex Class, End Date Time
                    Heat_Map_Log__c hm=HeatMapLogController.insertHeatMapLogForBatchClass(accountID,productID,featureId,'ProdSubfeatureClientUsageBatch',system.Now());
                    heatMapLogList.add(hm);
                }
            }            
            if(!heatMapLogList.isEmpty()){
                insert heatMapLogList;
            }
        }catch(Exception e){
            System.debug('System exception occured');
            System.debug('message -'+e.getMessage());
            System.debug('message st-'+e.getStackTraceString());
            System.debug('message c-'+e.getCause());
            System.debug('message -'+e.getCause());
        }
    }
    global void finish(Database.BatchableContext BC){
        try{ 
            AsyncApexJob completedjob = [Select Id, Status,CompletedDate from AsyncApexJob where status='Completed' AND Id = :BC.getJobId()];
            
            SF_Feature_Details__c sfD=[SELECT Execution_Order__c,Id,SF_Feature_Name__c,SF_Product_Name__c FROM SF_Feature_Details__c WHERE IsActive__c = true AND Feature_ID__c !=null order by Execution_Order__c desc limit 1];  
            if(orderId == sfD.Execution_Order__c){
                ProdSubfeatureClientUsageController.updateCustomMetaData(accountID,completedjob.CompletedDate);
                //DeleteCompletedJobHeatMap.deleteScheduledJob();
            }
            Integer oId=integer.valueOf(orderId)+1;
            string oId1=string.valueOf(oId);
            if(oId1.length()==1){
                oId1='00'+oId1;
            }else if(oId1.length()==2){
                oId1='0'+oId1;
            }
            SF_Feature_Details__c getFirstFeatureDetails=[SELECT Execution_Order__c,Id,Feature_ID__c,IsActive__c,Feature_ID__r.Salesforce_Product__c  FROM SF_Feature_Details__c WHERE IsActive__c=true AND Feature_ID__c !=null ORDER BY Execution_Order__c ASC NULLS FIRST limit 1];
            if(getFirstFeatureDetails.Execution_Order__c !=orderId){
                string jobName=orderId+' - Heatmap Account For '+accountID;
                CronJobDetail cj=[SELECT Id,JobType,Name FROM CronJobDetail where Name=:jobName limit 1];
                CronTrigger c=[select id from CronTrigger where CronJobDetailId =:cj.id];
                System.abortJob(c.id);  
            }
            
            SF_Feature_Details__c getFeatureDetails=[SELECT Execution_Order__c,Id,Feature_ID__c,IsActive__c,Feature_ID__r.Salesforce_Product__c,Feature_ID__r.Active__c FROM SF_Feature_Details__c where Execution_Order__c=:oId1 AND Feature_ID__c !=null];
            DateTime currentDateTime=System.now().addMinutes(1);                            
            String nextScheduleTime=String.valueof(currentDateTime.second()) +' '+String.valueof(currentDateTime.minute())+' '
                +String.valueof(currentDateTime.hour())+' '+String.valueof(currentDateTime.day())+' '
                +String.valueof(currentDateTime.month())+' ? '+String.valueof(currentDateTime.Year());
            
            
            if(getFeatureDetails.IsActive__c==true && getFeatureDetails.Feature_ID__r.Active__c==true)
            {
                System.schedule(oId1+' - Heatmap Account For '+accountID,nextScheduleTime, new ProdSubfeatureClientUsageSchedularForAcc(getFeatureDetails.Feature_ID__c ,getFeatureDetails.Execution_Order__c,accountID,getFeatureDetails.Feature_ID__r.Salesforce_Product__c));     
            }
            else
            {
                do{
                    getFeatureDetails=null;
                    oId=integer.valueOf(oId1)+1;
                    oId1=string.valueOf(oId);
                    if(oId1.length()==1){
                        oId1='00'+oId1;
                    }else if(oId1.length()==2){
                        oId1='0'+oId1;
                    }
                    getFeatureDetails=[SELECT Feature_ID__r.Active__c,Execution_Order__c,Id,Feature_ID__c,IsActive__c,Feature_ID__r.Salesforce_Product__c  FROM SF_Feature_Details__c where Execution_Order__c=:oId1 AND Feature_ID__c !=null];
                    
                } while(getFeatureDetails.IsActive__c !=true && getFeatureDetails.Feature_ID__r.Active__c !=true);
                
                System.schedule(oId1+' - Heatmap Account For '+accountID,nextScheduleTime, new ProdSubfeatureClientUsageSchedularForAcc(getFeatureDetails.Feature_ID__c ,getFeatureDetails.Execution_Order__c,accountID,getFeatureDetails.Feature_ID__r.Salesforce_Product__c));
            }
            
            
            //System.abortJob(completedjob.id);
            
        }catch(Exception e){
            system.debug('in Batch class---'+e.getMessage()+' at line no-'+e.getLineNumber());
        }
        
    }
}