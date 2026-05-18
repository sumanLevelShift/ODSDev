global class ProdSubfeatureClientUsageSchedularForAcc implements Schedulable, Database.AllowsCallouts{
    global string featureId;
    global string orderId;
    global string accountId;
    global string productId;
    global ProdSubfeatureClientUsageSchedularForAcc(string f,string orderId,string acc,string pro){
        this.featureId=f;
        this.orderId=orderId;
        this.accountId=acc;
        this.productId=pro;
    }
    global void execute(SchedulableContext sc) {
        //Heat Map Log: Account ID, Product ID, Feature ID, Apex Class, Start Date Time
        Heat_Map_Log__c hm=HeatMapLogController.insertHeatMapLogForSchedularClass(accountId,productId,featureId,'ProdSubfeatureClientUsageSchedularForAcc',system.Now());
        insert hm;
        ProdSubfeatureClientUsageBatch obj = new ProdSubfeatureClientUsageBatch(featureId,orderId,accountId,productId);
        Database.executeBatch(obj);
    }
}