/*******************************************************************************************
* @author           Suman & Sathish
* @version          1.0 
* @date             24-MAR-2021
* @Status           In-Progress
* @Class Name       ProdSubfeatureClientUsageSchedular
* @description      This schedular will call batch - ProdSubfeatureClientUsageBatch.

*********************************************************************************************
Version     Date               Team          Comments
*********************************************************************************************
* 1         Mar 2021    Suman & Sathish          Initial Creation
*********************************************************************************************/
global class ProdSubfeatureClientUsageSchedular implements Schedulable, Database.AllowsCallouts{
    
    global void execute(SchedulableContext sc) {
        try{
            //DeleteCompletedJobHeatMap.deleteScheduledJob();
            //Set<id> AccountIDList=new set<id>{'0013D00000YoJk9QAF','0013D00000eBO0AQAW'};
            list<ClientAndNamedCredMapping__mdt> clientandNameCredList=[SELECT Account_Id__c,Is_Active__c,Last_Run_Date_Time__c,Named_Credentail__c,Next_Run_Date_Time__c,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where 
                                                                        Is_Active__c=:true and Account_Id__c !=:'NOT_FOUND' AND In_progress__c=false];
            for(ClientAndNamedCredMapping__mdt clientandNameCred:clientandNameCredList)
            {
                if((clientandNameCred.Next_Run_Date_Time__c < system.now().addDays(-1) && clientandNameCred.Schedule_Frequency__c == 'Daily')||
                   (clientandNameCred.Next_Run_Date_Time__c < system.now().addDays(-7) && clientandNameCred.Schedule_Frequency__c == 'Weekly')||
                   (clientandNameCred.Next_Run_Date_Time__c < system.now().addMonths(-1) && clientandNameCred.Schedule_Frequency__c == 'Monthly')||
                   (clientandNameCred.Next_Run_Date_Time__c < system.now().addMonths(-3) && clientandNameCred.Schedule_Frequency__c == 'Quarterly') ||
                   (clientandNameCred.Next_Run_Date_Time__c ==null && clientandNameCred.Last_Run_Date_Time__c ==null))
                {
                    //Need to add logic for delete old log files (for 90days old or 180days then use custom label)
                    //Heat Map Log: Account ID, Product ID, Feature ID, Apex Class, Start Date Time
                    SF_Feature_Details__c getFeatureDetails=[SELECT Execution_Order__c,Id,Feature_ID__c,IsActive__c,Feature_ID__r.Salesforce_Product__c  FROM SF_Feature_Details__c WHERE IsActive__c=true AND Feature_ID__c !=null AND Feature_ID__r.Active__c=true ORDER BY Execution_Order__c ASC NULLS FIRST limit 1];
                    ProdSubfeatureClientUsageController.updateCustomMetaDataForInProgress(clientandNameCred.Account_Id__c,true);
                    Heat_Map_Log__c hm=HeatMapLogController.insertHeatMapLogForSchedularClass(clientandNameCred.Account_Id__c,getFeatureDetails.Feature_ID__r.Salesforce_Product__c,getFeatureDetails.Feature_ID__c,'ProdSubfeatureClientUsageSchedular',system.Now());
                    Insert hm;
                    ProdSubfeatureClientUsageBatch obj = new ProdSubfeatureClientUsageBatch(getFeatureDetails.Feature_ID__c ,getFeatureDetails.Execution_Order__c,clientandNameCred.Account_Id__c,getFeatureDetails.Feature_ID__r.Salesforce_Product__c);
                    Database.executeBatch(obj);
                }
            }
        }catch(Exception e){
            System.debug('System exception occured');
            System.debug('message -'+e.getMessage());
            System.debug('message st-'+e.getStackTraceString());
            System.debug('message c-'+e.getCause());
            System.debug('message -'+e.getCause());
        }
    }
}