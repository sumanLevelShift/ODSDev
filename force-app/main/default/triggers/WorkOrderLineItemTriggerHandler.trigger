trigger WorkOrderLineItemTriggerHandler on WorkOrder_Line_Item__c (after insert,after update,after delete, before insert) {
    set<Id> workOrderIds = new set<Id>();
    if ((Trigger.isBefore && Trigger.isInsert)) {
        Set<string> itemMasterIds=new Set<string>();
        for(WorkOrder_Line_Item__c woLi: trigger.new){
            itemMasterIds.add(woLi.Item_Master__c);
        }
        Map<id,Item_Master__c> itemMasterMap=new Map<id,Item_Master__c>([SELECT Id,Description__c,Name,Unit_of_Measure__c,Tax_Rate__c,IsActive__c FROM Item_Master__c WHERE ID IN: itemMasterIds]);
        for(WorkOrder_Line_Item__c woLi: trigger.new){
            if(itemMasterMap.containsKey(woLi.Item_Master__c)){
                Item_Master__c im=itemMasterMap.get(woLi.Item_Master__c);
                woLi.Description__c=im.Description__c;
                woli.Tax_Rate__c=im.Tax_Rate__c;
                //woli.Unit_of_Measure__c=im.Unit_of_Measure__c;
            }
        }
    }
    if(((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate) || (trigger.isAfter && trigger.isDelete))&& !WorkOrder_API_Calls.addWorkOrderAPI){ 
        
        Map<Id,Work_Order__c> workdOrderOldMap=new Map<Id,Work_Order__c>();
        
        if(WorkOrder_API_Calls.isFirstTime){
            
            WorkOrder_API_Calls.isFirstTime = false;
            
            if((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate)){
                for(WorkOrder_Line_Item__c woLi: trigger.new){
                    workOrderIds.add(woLi.WorkOrder__c);
                }   
            }
            List<WorkOrder_Line_Item__c> woliList=new List<WorkOrder_Line_Item__c>();
            if((trigger.isAfter && trigger.isDelete)){
                for(WorkOrder_Line_Item__c woliVar: trigger.old){
                    workOrderIds.add(woliVar.WorkOrder__c);
                    woliList.add(woliVar);
                }
            }
            system.debug('WorkOrderIds------>'+workOrderIds);
            
            List<Work_Order__c> workOrdersList = [SELECT Subscription_Fee_Sticker_Price__c,Subscription_Fee_Discount__c,Client_Name__r.Customer_Type__c,Account_CSM__c, Account_Manager_Name__c,Account_Manager_Name__r.Email, Account_Manager_Name__r.Name, Account_Partner__c, Admin_Hourly_Rate__c , Annual_Salary__c, Bill_Rate__c, Bill_Rate_Type__c, Billing_Frequency__c, Business_Unit__c, Client_Name__c, Client_Name__r.Backup_CSM__c, Client_Name__r.BillingCity, Client_Name__r.BillingCountry, Client_Name__r.BillingPostalCode, Client_Name__r.BillingState, Client_Name__r.BillingStreet, Client_Name__r.Id, Client_Name__r.Industry, Client_Name__r.Name, Client_Name__r.Owner.Name, Client_Name__r.Phone, Client_Name__r.Primary_contact_name__c,Client_Name__r.Client_Code__c, Client_Name__r.Primary_Customer_Contact__c, Client_Name__r.Primary_Customer_Email_Id__c, Client_Name__r.User__c, Consultant__r.Email, Consulting_Hourly_Rate__c , Contact_for_Payment_followUp__c, Contact_to_Send_the_Invoice__c,Contact_to_Send_the_Invoice__r.Name, Contact_to_Send_the_Invoice__r.Email, Contact_for_Payment_followUp__r.Name, Contact_for_Payment_followUp__r.Email, CSM__c, Customer_Type__c, Execution_Partner__c, Execution_Partner__r.Email, Execution_Partner__r.Name, Initial_Gross_Margin__c, LCA_Required__c, Minumim_Billable_Hours_Per_Month__c, Name, OwnerId, Pay_Rate__c, Payment_Terms_Projects__c, PayRate_t_M__c, PERDIEM__c, PO_Number__c, Project_Code__c, Project_End_Date__c, Project_Name__c, Project_Start_Date__c, Same_as_the_Invoice_Contact__c, SubCategory__c, Subscription_Fee_Frequency__c, BC_Work_Order_ID__c, Total_Subscription_Fee__c, Vendor__r.Name, VP__c, Work_Order_Changes_Effective_Date__c,BC_Build_CNSMP_API_Message__c,BC_Admin_CNSMP_WO_ID__c,BC_Consulting_CNSMP_WO_ID__c,Tips_Work_Order_ID__c FROM Work_Order__c
                                                  WHERE Id IN: WorkOrderIds AND BC_Work_Order_ID__c	!='']; 
            
            set<id> workOrderIdsBC=new set<id>();
            for(Work_Order__c WorkOrderVar: workOrdersList)
            {
                workOrderIdsBC.add(WorkOrderVar.Id);
                workdOrderOldMap.put(WorkOrderVar.Id,WorkOrderVar);
            }
            
            if(!workOrderIdsBC.isEmpty())
            {
                if(System.isFuture()) {
                    return;
                }
                WorkOrder_API_Calls.updateWorkOrderAPI = true;
                WorkOrder_API_Calls.updateWorkOrdersUsingAPI(workOrderIdsBC,workdOrderOldMap);
            }
        }
    }
    WorkOrder_API_Calls.addWorkOrderAPI=false;               
}