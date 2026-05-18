public class WorkOrder_API_Calls_Licensefee {
    @InvocableMethod(label='LicenseFee Work Order')
    public static void licenseWorkOrdersUsingAPI(List<string> workOrderId){
        set<id> addWorkOrderIdSet=new set<id>();        
        Map<Id,Work_Order__c> workOrderMap=New Map<Id,Work_Order__c>([SELECT Id,Project_Code__c,BC_Work_Order_ID__c FROM Work_Order__c WHERE Id IN: workOrderId]);
        for(Work_Order__c wo:workOrderMap.values()){
            if(wo.Project_Code__c!=null && String.isBlank(wo.BC_Work_Order_ID__c)){
                addWorkOrderIdSet.add(wo.id);
            }
        }
        if(!addWorkOrderIdSet.isEmpty()){
            WorkOrder_API_Calls.addWorkOrderAPI=true;
            WorkOrder_API_Calls.AddWorkOrdersUsingAPI(addWorkOrderIdSet); 
        }
    }
}