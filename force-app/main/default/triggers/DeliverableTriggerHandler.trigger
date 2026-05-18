trigger DeliverableTriggerHandler on Deliverables__c (after insert,after update,after delete) {
    try{ 
        List<AggregateResult> deliverablesAggregateList=new List<AggregateResult>();
        set<Id> workOrderIds = new set<Id>();
        
        if(((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate) || (trigger.isAfter && trigger.isDelete))&& !WorkOrder_API_Calls.addWorkOrderAPI){ 
            
            Map<Id,Work_Order__c> workdOrderOldMap=new Map<Id,Work_Order__c>();
            
            if(WorkOrder_API_Calls.isFirstTime){
                
                WorkOrder_API_Calls.isFirstTime = false;
                
                if((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate)){
                    for(Deliverables__c DeliverableVar: trigger.new){
                        workOrderIds.add(DeliverableVar.Work_Order__c);
                    }   
                }
                List<Deliverables__c> deleteDeliverablesList=new List<Deliverables__c>();
                if((trigger.isAfter && trigger.isDelete)){
                    for(Deliverables__c DeliverableVar: trigger.old){
                        workOrderIds.add(DeliverableVar.Work_Order__c);
                        deleteDeliverablesList.add(DeliverableVar);
                    }
                }
                system.debug('WorkOrderIds------>'+workOrderIds);
                
                deliverablesAggregateList=[Select Work_Order__c,Sum(Amount__c)amt from Deliverables__c where Work_Order__c IN: WorkOrderIds group by Work_Order__c];
                
                List<Work_Order__c> workOrdersList;
                If(!boolean.valueOf(system.label.BC_Integration)){
                    workOrdersList = [SELECT Subscription_Fee_Sticker_Price__c,Subscription_Fee_Discount__c,Client_Name__r.Customer_Type__c,Account_CSM__c, Account_Manager_Name__c,Account_Manager_Name__r.Email, Account_Manager_Name__r.Name, Account_Partner__c, Admin_Hourly_Rate__c , Annual_Salary__c, Bill_Rate__c, Bill_Rate_Type__c, Billing_Frequency__c, Business_Unit__c, Client_Name__c, Client_Name__r.Backup_CSM__c, Client_Name__r.BillingCity, Client_Name__r.BillingCountry, Client_Name__r.BillingPostalCode, Client_Name__r.BillingState, Client_Name__r.BillingStreet, Client_Name__r.Id, Client_Name__r.Industry, Client_Name__r.Name, Client_Name__r.Owner.Name, Client_Name__r.Phone, Client_Name__r.Primary_contact_name__c,Client_Name__r.Client_Code__c, Client_Name__r.Primary_Customer_Contact__c, Client_Name__r.Primary_Customer_Email_Id__c, Client_Name__r.User__c, Consultant__r.Email, Consulting_Hourly_Rate__c , Contact_for_Payment_followUp__c, Contact_to_Send_the_Invoice__c,Contact_to_Send_the_Invoice__r.Name, Contact_to_Send_the_Invoice__r.Email, Contact_for_Payment_followUp__r.Name, Contact_for_Payment_followUp__r.Email, CSM__c, Customer_Type__c, Execution_Partner__c, Execution_Partner__r.Email, Execution_Partner__r.Name, Initial_Gross_Margin__c, LCA_Required__c, Minumim_Billable_Hours_Per_Month__c, Name, OwnerId, Pay_Rate__c, Payment_Terms_Projects__c, PayRate_t_M__c, PERDIEM__c, PO_Number__c, Project_Code__c, Project_End_Date__c, Project_Name__c, Project_Start_Date__c, Same_as_the_Invoice_Contact__c, SubCategory__c, Subscription_Fee_Frequency__c, Tips_Work_Order_ID__c, Total_Subscription_Fee__c, Vendor__r.Name, VP__c, Work_Order_Changes_Effective_Date__c, TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,Tips_CNSMP_API_Message__c,Tips_Admin_CNSMP_API_Message__c,Tips_Consulting_CNSMP_API_Message__c FROM Work_Order__c
                                      WHERE Id IN: WorkOrderIds AND Tips_Work_Order_ID__c !=''];   
                }else{
                    workOrdersList = [SELECT Subscription_Fee_Sticker_Price__c,Subscription_Fee_Discount__c,Client_Name__r.Customer_Type__c,Account_CSM__c, Account_Manager_Name__c,Account_Manager_Name__r.Email, Account_Manager_Name__r.Name, Account_Partner__c, Admin_Hourly_Rate__c , Annual_Salary__c, Bill_Rate__c, Bill_Rate_Type__c, Billing_Frequency__c, Business_Unit__c, Client_Name__c, Client_Name__r.Backup_CSM__c, Client_Name__r.BillingCity, Client_Name__r.BillingCountry, Client_Name__r.BillingPostalCode, Client_Name__r.BillingState, Client_Name__r.BillingStreet, Client_Name__r.Id, Client_Name__r.Industry, Client_Name__r.Name, Client_Name__r.Owner.Name, Client_Name__r.Phone, Client_Name__r.Primary_contact_name__c,Client_Name__r.Client_Code__c, Client_Name__r.Primary_Customer_Contact__c, Client_Name__r.Primary_Customer_Email_Id__c, Client_Name__r.User__c, Consultant__r.Email, Consulting_Hourly_Rate__c , Contact_for_Payment_followUp__c, Contact_to_Send_the_Invoice__c,Contact_to_Send_the_Invoice__r.Name, Contact_to_Send_the_Invoice__r.Email, Contact_for_Payment_followUp__r.Name, Contact_for_Payment_followUp__r.Email, CSM__c, Customer_Type__c, Execution_Partner__c, Execution_Partner__r.Email, Execution_Partner__r.Name, Initial_Gross_Margin__c, LCA_Required__c, Minumim_Billable_Hours_Per_Month__c, Name, OwnerId, Pay_Rate__c, Payment_Terms_Projects__c, PayRate_t_M__c, PERDIEM__c, PO_Number__c, Project_Code__c, Project_End_Date__c, Project_Name__c, Project_Start_Date__c, Same_as_the_Invoice_Contact__c, SubCategory__c, Subscription_Fee_Frequency__c, BC_Work_Order_ID__c, Total_Subscription_Fee__c, Vendor__r.Name, VP__c, Work_Order_Changes_Effective_Date__c,BC_Build_CNSMP_API_Message__c,BC_Admin_CNSMP_WO_ID__c,BC_Consulting_CNSMP_WO_ID__c,Tips_Work_Order_ID__c FROM Work_Order__c
                                      WHERE Id IN: WorkOrderIds AND BC_Work_Order_ID__c	!='']; 
                }
                
                //List<Work_Order__c> workOrdersList =[SELECT Account_Manager_Name__c,Work_Order_Changes_Effective_Date__c,Tips_Work_Order_ID__c,Name,Client_Name__r.Id,Client_Name__c,Contact_for_Payment_followUp__r.Email,Contact_for_Payment_followUp__r.Name,Contact_to_Send_the_Invoice__r.Name,Contact_to_Send_the_Invoice__r.Email,Contact_to_Send_the_Invoice__c,Contact_for_Payment_followUp__c,Same_as_the_Invoice_Contact__c,Project_Code__c,Client_Name__r.Primary_Customer_Contact__c,Client_Name__r.Primary_contact_name__c,Client_Name__r.Primary_Customer_Email_Id__c,Client_Name__r.BillingCountry,Client_Name__r.BillingStreet,Client_Name__r.BillingCity,Client_Name__r.BillingState,Client_Name__r.BillingPostalCode,Client_Name__r.Industry,Client_Name__r.Phone,PO_Number__c,Payment_Terms_Projects__c,Account_CSM__c,VP__c,Pay_Rate__c,Consultant__r.Email,OwnerId,Client_Name__r.Name,Vendor__r.Name,Project_Start_Date__c,Project_End_Date__c,Bill_Rate__c,PayRate_t_M__c,Billing_Frequency__c,Annual_Salary__c,PERDIEM__c,Account_Manager_Name__r.Name,Execution_Partner__r.Name,SubCategory__c,Business_Unit__c,Project_Name__c,LCA_Required__c,Minumim_Billable_Hours_Per_Month__c,Bill_Rate_Type__c,Initial_Gross_Margin__c,Account_Partner__c FROM Work_Order__c WHERE Id IN: WorkOrderIds]; 
                system.debug('workOrdersList------>'+workOrdersList);
                set<id> workOrderIdsTips=new set<id>();
                for(Work_Order__c WorkOrderVar: workOrdersList)
                {
                    system.debug('WorkOrderVar.Tips_Work_Order_ID__c------>'+WorkOrderVar.Tips_Work_Order_ID__c);
                    workOrderIdsTips.add(WorkOrderVar.Id);
                    workdOrderOldMap.put(WorkOrderVar.Id,WorkOrderVar);
                }
                
                if(workOrderIdsTips.size()>0)
                {
                    if(System.isFuture()) {
                        return;
                    }
                    WorkOrder_API_Calls.updateWorkOrderAPI = true;
                    WorkOrder_API_Calls.triggeredFromDeliverable = true;
                    WorkOrder_API_Calls.updateWorkOrdersUsingAPIForDeliverable(workOrderIdsTips,workdOrderOldMap,deleteDeliverablesList);
                }
            }
        }
        WorkOrder_API_Calls.addWorkOrderAPI=false;
        system.debug('deliverablesAggregateList-'+deliverablesAggregateList);
        List<Work_Order__c> workOrderUpdateList=new List<Work_Order__c>();
        Map<Id, Decimal> workOrderAmountMap = new Map<Id, Decimal>();
        for (AggregateResult result : deliverablesAggregateList) {
            Id workOrderId = (Id)result.get('Work_Order__c');
            Decimal amount = (Decimal)result.get('amt');
            workOrderAmountMap.put(workOrderId, amount);
        }
        for (Id workOrderId : WorkOrderIds) {
            Work_Order__c wo = new Work_Order__c();
            wo.Id = workOrderId;
            if (workOrderAmountMap.containsKey(workOrderId)) {
                wo.Bill_Rate__c = workOrderAmountMap.get(workOrderId);
            } else {
                wo.Bill_Rate__c = 0;
            }
            workOrderUpdateList.add(wo);
        }
        if(!workOrderUpdateList.isEmpty()){
            WorkOrder_API_Calls.isFirstTime = false;
            WorkOrder_API_Calls.byPassValidation = true;
            update workOrderUpdateList;
        }
    }
    catch(Exception e)    
    {
        // WorkOrder_API_Calls.addWorkOrderAPI=false;
        system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
    }               
}