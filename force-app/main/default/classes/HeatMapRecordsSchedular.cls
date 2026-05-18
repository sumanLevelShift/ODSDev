global class HeatMapRecordsSchedular implements Schedulable, Database.AllowsCallouts{
    String accountID;
    public HeatMapRecordsSchedular(String a){
        this.accountID=a;   
    }
    global void execute(SchedulableContext sc) {
        if(accountID !=null){
            SF_Feature_Details__c getFeatureDetails=[SELECT Execution_Order__c,Id,Feature_ID__c,IsActive__c,Feature_ID__r.Salesforce_Product__c  FROM SF_Feature_Details__c WHERE IsActive__c=true AND Feature_ID__c !=null AND Feature_ID__r.Active__c=true ORDER BY Execution_Order__c ASC NULLS FIRST limit 1];
            ProdSubfeatureClientUsageBatch obj = new ProdSubfeatureClientUsageBatch(getFeatureDetails.Feature_ID__c ,getFeatureDetails.Execution_Order__c,accountId,getFeatureDetails.Feature_ID__r.Salesforce_Product__c);
            Database.executeBatch(obj);
            
            string jobName='HeatMap Request From ConApp For '+accountID;
            CronJobDetail cj=[SELECT Id,JobType,Name FROM CronJobDetail where Name=:jobName limit 1];
            if(cj !=null){
                CronTrigger c=[select id from CronTrigger where CronJobDetailId =:cj.id];
                if(c !=null){
                    System.abortJob(c.id);    
                }
            }
        }
    }
    
}