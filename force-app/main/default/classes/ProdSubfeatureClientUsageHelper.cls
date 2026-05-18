/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             23-MAR-2021
* @Status           In-Progress
* @Class Name       ProdSubfeatureClientUsageHelper
* @description      This is a helper class for - ProdSubfeatureClientUsageSchedular

*********************************************************************************************
Version     Date       Team          Comments
*********************************************************************************************
* 1         Mar 2021    Suman          Initial Creation
*********************************************************************************************/

public class ProdSubfeatureClientUsageHelper {
    
    public List<Heat_Map_Log__c> heatMapLogList {get; set;}
    public class CustomException extends Exception {}
    ProdSubfeatureClientUsageAPIHelper apiHelper=new ProdSubfeatureClientUsageAPIHelper();
    
    @TestVisible 
    public static Map<Id, List<Salesforce_Subfeature_Rule_Constraint__c>> subfeatureIdAndRuleMap { 
        get {
            if ( null == subfeatureIdAndRuleMap || subfeatureIdAndRuleMap.isEmpty() ){
                subfeatureIdAndRuleMap = new Map<Id, List<Salesforce_Subfeature_Rule_Constraint__c>>();
                
                List<Salesforce_Subfeature_Rule_Constraint__c> constraintList = new List<Salesforce_Subfeature_Rule_Constraint__c>();
                constraintList = [SELECT Name,Constraint__c,Id,OwnerId,Salesforce_Subfeature_Rule__r.Rule__c,Salesforce_Subfeature_Rule__r.Salesforce_Product_Subfeature__c, Subfeature_Name__c, Salesforce_Subfeature_Rule__r.Rest_API_Name__c,Salesforce_Subfeature_Rule__r.Type__c,Salesforce_Subfeature_Rule__r.Has_Extended_Validation__c,Salesforce_Subfeature_Rule__r.IsRuleHelperApplicable__c,Usage_Percentage__c FROM Salesforce_Subfeature_Rule_Constraint__c where Salesforce_Subfeature_Rule__r.Active__c=:true AND Salesforce_Subfeature_Rule__r.Salesforce_Product_Subfeature__r.Active__c=true ORDER BY Execution_Order__c ASC LIMIT 10000];
                for(Salesforce_Subfeature_Rule_Constraint__c item : constraintList){
                    if(subfeatureIdAndRuleMap.containsKey(item.Salesforce_Subfeature_Rule__r.Salesforce_Product_Subfeature__c)){
                        List<Salesforce_Subfeature_Rule_Constraint__c> ruleList = subfeatureIdAndRuleMap.get(item.Salesforce_Subfeature_Rule__r.Salesforce_Product_Subfeature__c);
                        ruleList.add(item);
                        subfeatureIdAndRuleMap.put(item.Salesforce_Subfeature_Rule__r.Salesforce_Product_Subfeature__c, ruleList);
                    }
                    else{
                        List<Salesforce_Subfeature_Rule_Constraint__c> ruleList = new List<Salesforce_Subfeature_Rule_Constraint__c>();
                        ruleList.add(item);
                        subfeatureIdAndRuleMap.put(item.Salesforce_Subfeature_Rule__r.Salesforce_Product_Subfeature__c, ruleList);
                    }
                }
                return subfeatureIdAndRuleMap;     
            }
            return subfeatureIdAndRuleMap;
        } set; 
    }
    
    @TestVisible 
    static List<Id> subfeatureToBeAddedManuallyList { 
        get {
            if ( null == subfeatureToBeAddedManuallyList || subfeatureToBeAddedManuallyList.isEmpty() ){
                subfeatureToBeAddedManuallyList = new List<Id>();
                
                List<Salesforce_Subfeature_Rules__c> ruleList = new List<Salesforce_Subfeature_Rules__c>();
                ruleList = [SELECT Id,Salesforce_Product_Subfeature__c FROM Salesforce_Subfeature_Rules__c WHERE Type__c = 'Manual'];
                for(Salesforce_Subfeature_Rules__c item : ruleList){
                    subfeatureToBeAddedManuallyList.add(item.Salesforce_Product_Subfeature__c);
                }
                return subfeatureToBeAddedManuallyList;     
            }
            return subfeatureToBeAddedManuallyList;
        } set; 
    }
    
    public Boolean checkIfSubFeatureUsageToBeAddedManually(String subfeatureId){
        if(subfeatureToBeAddedManuallyList.contains(subfeatureId))
            return true;
        return false;
    }
    
    //Construct the query and make api call to the client org
    public Map<id,Map<id,integer>> checkForUsageInClientOrg(String accountId, String subfeatureId){
        Integer usagePercentage = 0;
        Map<id,Map<id,integer>> ruleListMap=new Map<id,Map<id,integer>>();
        Map<id,integer> ruleIdwithUsage=new Map<id,integer>();
        heatMapLogList=new list<Heat_Map_Log__c>();

        //system.debug('subfeatureIdAndRuleMap-'+subfeatureIdAndRuleMap.containsKey('a3y7i0000008uIbAAI'));
        if(!subfeatureIdAndRuleMap.containsKey(subfeatureId))
            return ruleListMap;
        System.debug('$$ Subfeature - ' + subfeatureId);
        
        List<Salesforce_Subfeature_Rule_Constraint__c> subfeatureRuleList = subfeatureIdAndRuleMap.get(subfeatureId);
        for(Salesforce_Subfeature_Rule_Constraint__c item : subfeatureRuleList){
            //Heat Map Log: Account ID, Product ID, Feature ID,sub feature Id,Rule Id, Apex Class, Start Date Time
			Heat_Map_Log__c hmS=HeatMapLogController.insertHeatMapLogForHelperClassStart(accountId,item.Salesforce_Subfeature_Rule__r.Salesforce_Product_Subfeature__c,item.Salesforce_Subfeature_Rule__c,'ProdSubfeatureClientUsageHelper',system.now());
            heatMapLogList.add(hmS);
            if(item.Salesforce_Subfeature_Rule__r.Type__c=='Chatter'){
                String responseJSON=apiHelper.callAPITocheckForRecords(accountId, item.Salesforce_Subfeature_Rule__r.Rest_API_Name__c,null); 
                if(responseJSON !=null){
                    if(responseJSON.contains('FUNCTIONALITY_NOT_ENABLED')){
                        ruleIdwithUsage.put(item.Salesforce_Subfeature_Rule__c,0);
                        ruleListMap.Put(subfeatureId,ruleIdwithUsage);  
                    }else{
                        ruleIdwithUsage.put(item.Salesforce_Subfeature_Rule__c,Integer.valueOf(item.Usage_Percentage__c));
                        ruleListMap.Put(subfeatureId,ruleIdwithUsage);   
                    }
                }
            }
            else{
                String queryString = getQueryString(item.Salesforce_Subfeature_Rule__r.Rule__c, item.Constraint__c);
                System.debug('$$ Query String - ' + queryString);
                String responseJSON = apiHelper.callAPITocheckForRecords(accountId, item.Salesforce_Subfeature_Rule__r.Rest_API_Name__c ,queryString);
                if(responseJSON !=null){
                    
                    //Check if Subfeature Rule has extended validation
                    if(item.Salesforce_Subfeature_Rule__r.Has_Extended_Validation__c==true){
                        Double usage = RunExtendedValidation.getUtilizationPercentage(item.Subfeature_Name__c, responseJSON,accountId);
                        ruleIdwithUsage.put(item.Salesforce_Subfeature_Rule__c,Integer.valueOf(usage));
                        ruleListMap.Put(subfeatureId,ruleIdwithUsage);
                        //return ruleListMap;
                    } else  if(item.Salesforce_Subfeature_Rule__r.IsRuleHelperApplicable__c == true){
                        system.debug('enter if rule helper-----');
                        Integer duplicateruleusagepercentage = getDuplicateRuleLimitUsage(item.Salesforce_Subfeature_Rule__c, getRecCountFromHTTPResponseJSON(responseJSON));
                        system.debug('duplicateruleusagepercentage>>>' +duplicateruleusagepercentage);
                        ruleIdwithUsage.put(item.Salesforce_Subfeature_Rule__c,duplicateruleusagepercentage);
                        ruleListMap.Put(subfeatureId,ruleIdwithUsage);
                    }
                    else{
                        Integer recCount = getRecCountFromHTTPResponseJSON(responseJSON);
                        System.debug('$$ Rec count - ' + recCount+' name--'+item.name);
                        if(recCount > 0){
                            if(ruleIdwithUsage.containsKey(item.Salesforce_Subfeature_Rule__c)){ 
                                if(ruleIdwithUsage.get(item.Salesforce_Subfeature_Rule__c)==0){
                                    ruleIdwithUsage.put(item.Salesforce_Subfeature_Rule__c,Integer.valueOf(item.Usage_Percentage__c));
                                }
                            }else{
                                ruleIdwithUsage.put(item.Salesforce_Subfeature_Rule__c,Integer.valueOf(item.Usage_Percentage__c));
                            }
                            ruleListMap.Put(subfeatureId,ruleIdwithUsage);    
                        }else{
                            if(!ruleIdwithUsage.containsKey(item.Salesforce_Subfeature_Rule__c)){ 
                                ruleIdwithUsage.put(item.Salesforce_Subfeature_Rule__c,0);
                            }
                            ruleListMap.Put(subfeatureId,ruleIdwithUsage);  
                        }
                    }
                }
            }
            
            if(HeatMapLogController.errorLog != null){
                heatMapLogList.add(HeatMapLogController.errorLog);
            } 
            
            //Heat Map Log: Account ID, Product ID, Feature ID,sub feature Id,Rule Id, Apex Class, End Date Time
            Heat_Map_Log__c hmE=HeatMapLogController.insertHeatMapLogForHelperClassEnd(accountId,item.Salesforce_Subfeature_Rule__r.Salesforce_Product_Subfeature__c,item.Salesforce_Subfeature_Rule__c,'ProdSubfeatureClientUsageHelper',system.now());
            heatMapLogList.add(hmE);
        } 
        
        return ruleListMap;
    }
    public String getQueryString(String objQuery, String constraint){
        String queryString = '';
        if(String.isBlank(constraint))
            queryString = objQuery;
        else
            queryString = objQuery + ProdSubfeatureClientUsage_Constants.QUERYSTRING_WHERE + constraint;
        
        queryString = queryString.normalizeSpace().replace(ProdSubfeatureClientUsage_Constants.STRING_SPACE, ProdSubfeatureClientUsage_Constants.STRING_PLUS);
        queryString = queryString.replace(ProdSubfeatureClientUsage_Constants.STRING_PERCENT, ProdSubfeatureClientUsage_Constants.STRING_PERCENTENCODED);
        
        return queryString;
    }
    
    //Now get the subfeature client usage records for all subfeatures from Product_Subfeature_Client_Usage__c object
    public Map<Id,Product_Subfeature_Client_Usage__c> getSubFeatureUsageRecordsFromDB(Id accountId, Id productId ,set<Id> featureId){
        Map<Id,Product_Subfeature_Client_Usage__c> subfeatureIdAndClientUsageMap = new Map<Id,Product_Subfeature_Client_Usage__c>();
        
        List<Product_Subfeature_Client_Usage__c> subfeatureClientUsageList = new List<Product_Subfeature_Client_Usage__c>();
        subfeatureClientUsageList = [SELECT Id, Salesforce_Product_Subfeature__c, Product_Feature_Client_Usage__c, Subfeature_Weightage__c, Client_Usage_Percentage__c FROM Product_Subfeature_Client_Usage__c WHERE Salesforce_Product_Feature__c IN: featureId AND Account__c=:accountId AND Salesforce_Product__c=:productId LIMIT 10000];
        for(Product_Subfeature_Client_Usage__c item : subfeatureClientUsageList)
            subfeatureIdAndClientUsageMap.put(item.Salesforce_Product_Subfeature__c, item);
        
        return subfeatureIdAndClientUsageMap;
    }
    
    //Update the subfeature client usage for all subfeatures in Product_Subfeature_Client_Usage__c object
    public List<Product_Subfeature_Client_Usage__c> updateSubFeatureUsageRecordsInDB(Map<Id,Product_Subfeature_Client_Usage__c> subfeatureIdAndExistingClientUsageMap, Map<Salesforce_Product_Subfeature__c,Integer> subfeatureAndOrgResultMap, Product_Feature_Client_Usage__c prodFeatureUsageToBeUpdated, Id accountId,Map<string,string> subfeatureWithRecommendation){
        system.debug('subfeatureAndOrgResultMap--'+subfeatureAndOrgResultMap);
        List<Product_Subfeature_Client_Usage__c> subfeatureClientUsageTotalList = new List<Product_Subfeature_Client_Usage__c>();
        
        List<Product_Subfeature_Client_Usage__c> subfeatureClientUsageToBeUpdatedList = new List<Product_Subfeature_Client_Usage__c>();
        List<Product_Subfeature_Client_Usage__c> subfeatureClientUsageToBeInsertedList = new List<Product_Subfeature_Client_Usage__c>();
        for(Salesforce_Product_Subfeature__c item : subfeatureAndOrgResultMap.keySet()){
            string Recommendation=subfeatureWithRecommendation.get(item.id);
            //Recommendation=Recommendation.replaceAll('null', null);
            if(Recommendation =='null'){
                Recommendation=null;
            }
            if(!subfeatureIdAndExistingClientUsageMap.containsKey(item.Id)){

                Product_Subfeature_Client_Usage__c subfeatureClientUsage = new Product_Subfeature_Client_Usage__c();
                subfeatureClientUsage.Name = item.Name;
                subfeatureClientUsage.Account__c = accountId;
                subfeatureClientUsage.Salesforce_Product__c = item.Salesforce_Product_Feature__r.Salesforce_Product__c;
                subfeatureClientUsage.Salesforce_Product_Feature__c = item.Salesforce_Product_Feature__c;
                subfeatureClientUsage.Salesforce_Product_Subfeature__c = item.id;
                subfeatureClientUsage.Product_Feature_Client_Usage__c = prodFeatureUsageToBeUpdated.Id;
                subfeatureClientUsage.Subfeature_Weightage__c = item.Subfeature_Percentage__c;
                subfeatureClientUsage.Client_Usage_Percentage__c = subfeatureAndOrgResultMap.get(item);
                subfeatureClientUsage.Recommendation__c=Recommendation;
                subfeatureClientUsageToBeInsertedList.add(subfeatureClientUsage);
                continue;
            }
            
            Product_Subfeature_Client_Usage__c subfeatureClientUsage = subfeatureIdAndExistingClientUsageMap.get(item.Id);
            subfeatureClientUsage.Subfeature_Weightage__c = item.Subfeature_Percentage__c;
            subfeatureClientUsage.Client_Usage_Percentage__c = subfeatureAndOrgResultMap.get(item);
            subfeatureClientUsage.Recommendation__c=Recommendation;
            subfeatureClientUsageToBeUpdatedList.add(subfeatureClientUsage);
        }
        
        if(!subfeatureClientUsageToBeUpdatedList.isEmpty()){
            update subfeatureClientUsageToBeUpdatedList;
            subfeatureClientUsageTotalList.addAll(subfeatureClientUsageToBeUpdatedList);
        }
        if(!subfeatureClientUsageToBeInsertedList.isEmpty()){
            insert subfeatureClientUsageToBeInsertedList;
            subfeatureClientUsageTotalList.addAll(subfeatureClientUsageToBeInsertedList);
        }
        
        return subfeatureClientUsageTotalList;
    }
    
    //Calculate the cumlative usage of all subfeatures
    public Decimal getSumOfClientUsageWeightageOfSubfeatures(List<Product_Subfeature_Client_Usage__c> subfeatureClientUsageList,string featureId,string accountID){
        Decimal sumClientUsageWeightageOfSubfeatures=0;//To be updated to Product_Feature_Client_Usage__c record
        subfeatureClientUsageList=[Select ID,Client_Usage_Weightage__c from  Product_Subfeature_Client_Usage__c where Salesforce_Product_Feature__c=:featureId];
        AggregateResult[] aggregateList=[SELECT Sum(Client_Usage_Weightage__c)clientUsage,Salesforce_Product__c,Account__c FROM Product_Subfeature_Client_Usage__c 
                                         where Salesforce_Product_Feature__c=:featureId and Account__c=:accountID group by Salesforce_Product_Feature__c,Salesforce_Product__c,Account__c];
        /*system.debug('(decimal)ar.get'+aggregateList[0].get('clientUsage'));
for(Product_Subfeature_Client_Usage__c item:subfeatureClientUsageList){
system.debug('item--'+item);
sumClientUsageWeightageOfSubfeatures += item.Client_Usage_Weightage__c;
}
System.debug('sumClientUsageWeightageOfSubfeatures-' + sumClientUsageWeightageOfSubfeatures);
*/
        return (decimal)aggregateList[0].get('clientUsage');
    }
    
    public Product_Feature_Client_Usage__c getProdFeatureUsageRecToBeUpdated(Id featureId, Id productId, Id accountId){
        
        Product_Feature_Client_Usage__c prodFeatureUsageToBeUpdated=[SELECT Id,Client_Usage_Percentage__c,Salesforce_Product_Feature__r.Name FROM Product_Feature_Client_Usage__c WHERE Salesforce_Product_Feature__c =:featureId  AND Salesforce_Product__c=:productId AND Account__c=:accountID ORDER BY CreatedDate DESC LIMIT 1];
        return prodFeatureUsageToBeUpdated;
        
    }
    
    public List<Salesforce_Product_Subfeature__c> getSubfeatureList(Set<Id> featureId){
        List<Salesforce_Product_Subfeature__c> leadMgtSubfeatureList = new List<Salesforce_Product_Subfeature__c>();
        leadMgtSubfeatureList = [SELECT Client_Usage_Percentage__c,Id,Name,Salesforce_Product_Feature__c,Salesforce_Product_Feature__r.Salesforce_Product__c,Subfeature_Percentage__c FROM Salesforce_Product_Subfeature__c WHERE Salesforce_Product_Feature__c IN: featureId AND Active__c=true LIMIT 10000];
        system.debug('leadMgtSubfeatureList--'+leadMgtSubfeatureList.size());
        if(leadMgtSubfeatureList.isEmpty())
            throw new CustomException('Subfeature records not found for feature!!');
        return leadMgtSubfeatureList;
    }
    
    //Get the subfeature client usage records for all subfeatures from Product_Subfeature_Client_Usage__c object
    public List<Product_Subfeature_Client_Usage__c> getAllSubFeatureUsageRecordsFromDB(Id accountId, Id productId ,set<Id> featureId){
        List<Product_Subfeature_Client_Usage__c> subfeatureClientUsageList = new List<Product_Subfeature_Client_Usage__c>();
        subfeatureClientUsageList = [SELECT Id, Salesforce_Product_Subfeature__c, Client_Usage_Weightage__c FROM Product_Subfeature_Client_Usage__c WHERE Salesforce_Product_Feature__c IN: featureId AND Account__c=:accountId AND Salesforce_Product__c=:productId LIMIT 10000];
        
        return subfeatureClientUsageList;
    }
    
    // Parse JSON response to get the total record count.
    public Integer getRecCountFromHTTPResponseJSON(String response){
        Integer recordCount = 0;
        JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == ProdSubfeatureClientUsage_Constants.APIRESULT_TOTALSIZE)) {                
                parser.nextToken();// Get the value.
                recordCount = parser.getIntegerValue();
                break;    
            }
        }
        return recordCount;
    }
    public integer calculatedFinalUsage(map<id,map<id,integer>> subRuleList,string name){
        integer ClientUsage=0;
        
        for(id subFeatureID : subRuleList.keySet()){
            AggregateResult[] aggregateList=[SELECT Sum(Subfeature_Rule_Percentage__c )sumOfRulePercantage,Salesforce_Product_Subfeature__c FROM Salesforce_Subfeature_Rules__c 
                                             where Salesforce_Product_Subfeature__c =:subFeatureID and Active__c=true group by Salesforce_Product_Subfeature__c];
            decimal sumOfValue=(decimal)aggregateList[0].get('sumOfRulePercantage');
            for(id subRuleID : subRuleList.get(subFeatureID).keySet()){
                system.debug('Name !!-'+name+'--rule id --'+subRuleID+'--usage--'+subRuleList.get(subFeatureID).get(subRuleID));
                
                ClientUsage=ClientUsage+calculateRuleUsage(subRuleID,subRuleList.get(subFeatureID).get(subRuleID),sumOfValue);
            }
        }
        return ClientUsage;
    }
    public integer calculateRuleUsage(string subRule, integer usage,decimal sumOfRulePercantage){
        decimal clientUsageWgth=0;
        system.debug('Rule Id '+subRule+' usage '+usage+' sumOfRulePercantage '+sumOfRulePercantage);
        Salesforce_Subfeature_Rules__c subFeatureRule=[SELECT Subfeature_Rule_Percentage__c FROM Salesforce_Subfeature_Rules__c where ID=:subRule and Active__c=true];  
        decimal rulePercentage=0;
        if(sumOfRulePercantage !=null){
            if(subFeatureRule.Subfeature_Rule_Percentage__c !=null){
                rulePercentage=subFeatureRule.Subfeature_Rule_Percentage__c; 
            }
            decimal subFeatureRulePercentageWgth=rulePercentage/sumOfRulePercantage;
            clientUsageWgth= subFeatureRulePercentageWgth*usage;
            return Integer.valueOf(clientUsageWgth); 
        }
        return usage;
    }
    
    public static integer getDuplicateRuleLimitUsage(string ruleID, integer recCount){
        Map<ID, Salesforce_Subfeature_Rule_Helper__c> fetchRuleHelperMap = new Map<ID, Salesforce_Subfeature_Rule_Helper__c>(
            [Select id, name, Record_Count_Size__c, Usage_Percentage__c,Salesforce_Subfeature_Rule__c,Salesforce_Subfeature_Rule__r.name
             from Salesforce_Subfeature_Rule_Helper__c where Salesforce_Subfeature_Rule__c =:ruleID]);
        
        for(Salesforce_Subfeature_Rule_Helper__c eachrulehelper : fetchRuleHelperMap.values())
        {
            if(fetchRuleHelperMap.get(eachrulehelper.id).Salesforce_Subfeature_Rule__r.name.contains('Duplicate Rule'))
            {
                system.debug('duplicate rules------' +fetchRuleHelperMap.get(eachrulehelper.id).Salesforce_Subfeature_Rule__r.name);
                if(eachrulehelper.Record_Count_Size__c >=5 && recCount>=5)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c ==4 && recCount==4)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c ==3 && recCount==3)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c ==2 && recCount==2)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c <=1 && recCount<=1)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }
            }
            if(fetchRuleHelperMap.get(eachrulehelper.id).Salesforce_Subfeature_Rule__r.name.contains('Validation Rule'))
            {
                system.debug('validation rules------' +fetchRuleHelperMap.get(eachrulehelper.id).Salesforce_Subfeature_Rule__r.name);
                if(eachrulehelper.Record_Count_Size__c >=20 && recCount>=20)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if((eachrulehelper.Record_Count_Size__c >=15 && eachrulehelper.Record_Count_Size__c <20) && (recCount>=15 && recCount<20))
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if((eachrulehelper.Record_Count_Size__c >=10 && eachrulehelper.Record_Count_Size__c <15) && (recCount>=10 && recCount<15))
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if((eachrulehelper.Record_Count_Size__c >=5 && eachrulehelper.Record_Count_Size__c <10) && (recCount>=5 && recCount<10))
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if((eachrulehelper.Record_Count_Size__c <=4 && eachrulehelper.Record_Count_Size__c !=0) && (recCount<=4 && recCount!=0))
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }
            }
            if(fetchRuleHelperMap.get(eachrulehelper.id).Salesforce_Subfeature_Rule__r.name.contains('MobileSettingsAssignment'))
            {
                system.debug('MobileSettingsAssignment------' +fetchRuleHelperMap.get(eachrulehelper.id).Salesforce_Subfeature_Rule__r.name);
                if(eachrulehelper.Record_Count_Size__c >=5 && recCount>=5)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c ==4 && recCount==4)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c ==3 && recCount==3)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c ==2 && recCount==2)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c ==1 && recCount==1)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }else if(eachrulehelper.Record_Count_Size__c ==0 && recCount==0)
                {
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c);
                }
            }
            if(fetchRuleHelperMap.get(eachrulehelper.id).Salesforce_Subfeature_Rule__r.name.contains('Feed'))
            {
                if(eachrulehelper.Record_Count_Size__c == recCount){
                    return Integer.valueOf(eachrulehelper.Usage_Percentage__c); 
                }
            }
            
        }
        
        return recCount;
    }
    
    
    
}