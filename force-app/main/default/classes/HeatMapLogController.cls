public class HeatMapLogController {
    private static Heat_Map_Log__c heatMapErrorLog;
    public static Heat_Map_Log__c errorLog{
        get{
            return heatMapErrorLog;
        }
    }
    
    public static Heat_Map_Log__c insertHeatMapLogForSchedularClass(string accId,string productId,String featureId,string apexClass,datetime start){
        Heat_Map_Log__c hm=new Heat_Map_Log__c();
        hm.Account_Id__c=accId;
        hm.Product_Id__c=productId;
        hm.Feature_Id__c=featureId;
        hm.Apex_Class__c=apexClass;
        hm.Start_Date_Time__c=start;
        return hm;
    }
    public static Heat_Map_Log__c insertHeatMapLogForBatchClass(string accId,string productId,String featureId,string apexClass,datetime endTime){
        Heat_Map_Log__c hm=new Heat_Map_Log__c();
        hm.Account_Id__c=accId;
        hm.Product_Id__c=productId;
        hm.Feature_Id__c=featureId;
        hm.Apex_Class__c=apexClass;
        hm.End_Date_Time__c=endTime;
        return hm;
    }
      public static Heat_Map_Log__c insertHeatMapLogForHelperClassStart(string accId,string subFeatureId,String ruleId,string apexClass,datetime start){
        Heat_Map_Log__c hm=new Heat_Map_Log__c();
        hm.Account_Id__c=accId;
        hm.Subfeature_Id__c=subFeatureId;
        hm.Rule_Id__c=ruleId;
        hm.Apex_Class__c=apexClass;
        hm.Start_Date_Time__c=start;
        return hm;
    }
      public static Heat_Map_Log__c insertHeatMapLogForHelperClassEnd(string accId,string subFeatureId,String ruleId,string apexClass,datetime endTime){
        Heat_Map_Log__c hm=new Heat_Map_Log__c();
        hm.Account_Id__c=accId;
        hm.Subfeature_Id__c=subFeatureId;
        hm.Rule_Id__c=ruleId;
        hm.Apex_Class__c=apexClass;
        hm.End_Date_Time__c=endTime;
        return hm;
    }
    public static void insertHeatMapLog(string accountId,string errorMessage,string apexClass){
        Heat_Map_Log__c hm=new Heat_Map_Log__c();
        hm.Account_Id__c=accountId;
        hm.Error_Message__c=errorMessage;
        hm.Apex_Class__c=apexClass;
        heatMapErrorLog = hm;
    }
}