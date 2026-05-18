trigger Work_order_trigger on Work_Order__c (before insert,after insert,after update,before delete,before update) {
    if(trigger.isBefore && trigger.isUpdate)
    {
        boolean isBCIntegration=Boolean.valueOf(System.Label.BC_Integration);
        for(Work_Order__c workOrderVar : Trigger.new) {
            Work_Order__c oldWorkOrderData = Trigger.oldMap.get(workOrderVar.Id);
            
            string subCategoryVar=workOrderVar.SubCategory__c;
            if(subCategoryVar.toLowerCase().contains('subscription') && 
               (oldWorkOrderData.Subscription_Fee_Discount__c != workOrderVar.Subscription_Fee_Discount__c || 
                oldWorkOrderData.Subscription_Fee_Sticker_Price__c != workOrderVar.Subscription_Fee_Sticker_Price__c ))
            {
                //errorMessage=true;  
                workOrderVar.addError('Changes to Subscription Fee Sticker Price or Discount fields are restricted.'); 
            }
            if(workOrderVar.Work_Order_Changes_Effective_Date__c == null){
                boolean errorMessage=false;
                //Validation for Admin and Consulting
                if(workOrderVar.Customer_Type__c=='ABC Type' && subCategoryVar.toLowerCase().contains('subscription')){
                    if(((!isBCIntegration && workOrderVar.TIPS_Consulting_CNSMP_WO_ID__c != null) 
                        ||(isBCIntegration && workOrderVar.BC_Consulting_CNSMP_WO_ID__c != null))
                       && oldWorkOrderData.Consulting_Hourly_Rate__c != workOrderVar.Consulting_Hourly_Rate__c)
                    {                        errorMessage=true; 
                    }
                    if(((!isBCIntegration && workOrderVar.TIPS_Admin_CNSMP_WO_ID__c !=null)
                        ||(isBCIntegration && workOrderVar.BC_Admin_CNSMP_WO_ID__c !=null))
                       && oldWorkOrderData.Admin_Hourly_Rate__c != workOrderVar.Admin_Hourly_Rate__c)
                    {                        errorMessage=true; 
                    }
                }
                //Validation for Build
                if(((!isBCIntegration && workOrderVar.TIPS_CNSMP_WO_ID__c !=null)
                    ||(isBCIntegration && workOrderVar.BC_Build_CNSMP_WO_ID__c !=null)) 
                   && oldWorkOrderData.Bill_Rate__c != workOrderVar.Bill_Rate__c)
                {                    errorMessage=true; 
                }
                if((!isBCIntegration && workOrderVar.Tips_Work_Order_ID__c !=null)
                   || (isBCIntegration && workOrderVar.BC_Work_Order_ID__c !=null)){
                       //Validation for non subscription WO
                       if(!WorkOrder_API_Calls.byPassValidation && !subCategoryVar.toLowerCase().contains('subscription') && oldWorkOrderData.Bill_Rate__c != workOrderVar.Bill_Rate__c )
                       {
                           errorMessage=true; 
                       }
                       //Validation for Subscription
                       
                      /* if(oldWorkOrderData.Annual_Salary__c != workOrderVar.Annual_Salary__c ||
                          oldWorkOrderData.Account_Manager_Name__c != workOrderVar.Account_Manager_Name__c || 
                          oldWorkOrderData.PERDIEM__c != workOrderVar.PERDIEM__c || 
                          oldWorkOrderData.Pay_Rate__c != workOrderVar.Pay_Rate__c || 
                          oldWorkOrderData.Bill_Rate_Type__c != workOrderVar.Bill_Rate_Type__c ||
                          oldWorkOrderData.Delivery_Partner__c != workOrderVar.Delivery_Partner__c ){
                              errorMessage=true;  
                          }*/
                   }
                system.debug('errorMessage-'+errorMessage);
                if(errorMessage){
                    workOrderVar.Work_Order_Changes_Effective_Date__c.addError('Please enter the Effective Date.'); 
                }
            }
        }
    }
    
    if(trigger.isBefore && trigger.isInsert)
    {
        system.debug('line--81');
        Map<Id,string> ExistingClientWorkOrders=new Map<Id,string>();
        Map<Id,string> WorkOrdersClientProjectCode=new Map<Id,string>();
        Map<Id,Account> accountWithNoProjectCode=new Map<Id,Account>();
        Map<string,string> WorkOrderClientsubcategories=new Map<string,string>();
        
        String projectCodeForConSub='';
        
        Set<Id> WorkOrderClients=new Set<Id>();
        
        for(Work_Order__c WorkOrderVar: trigger.new){
            system.debug('line--91'+WorkOrderVar);
            WorkOrderClients.add(WorkOrderVar.Client_Name__c);
            WorkOrderClientsubcategories.put(WorkOrderVar.Client_Name__c,WorkOrderVar.SubCategory__c);
        }
        
        List<Work_Order__c> lstClientExistingWorkOrders =[SELECT Id,Project_Code__c,SubCategory__c,Client_Name__c FROM Work_Order__c WHERE Client_Name__c IN: WorkOrderClients ORDER BY Name DESC];
        List<String> lstClientSubCategories=new List<string>{'DemandBlue-Consumption','DemandBlue-Consumption-CO','DemandBlue-Subscription','DemandBlue-Subscription-CO','DemandDynamics -Subscription','DemandDynamics -Subscription-CO','DemandDynamics -Consumption','DemandDynamics -Consumption-CO'
            };
          //  List<String> lstClientSubCategories2=new List<string>{'DemandBlue-Fixed Price','DemandBlue-Fixed Price-CO','DemandBlue-Expense','DemandBlue-Expense-CO','DemandBlue-T&M','DemandBlue-T&M-CO',
          //      'DemandDynamics -Fixed Price','DemandDynamics -Fixed Price-CO','DemandDynamics -Expense','DemandDynamics -Expense-CO','DemandDynamics -T&M','DemandDynamics -T&M-CO','DemandDynamics -License Fee','DemandDynamics -License Fee-CO'};
                Boolean isFirst=false; 
        String ConSubProjectCode ='';
        system.debug('lstClientExistingWorkOrders------>'+lstClientExistingWorkOrders);
        if(lstClientExistingWorkOrders.size()>0)
        {
            for(Work_Order__c workOrderObj:lstClientExistingWorkOrders)
            {                   
                string clientName='';
                if(!ExistingClientWorkOrders.containsKey(workOrderObj.Client_Name__c))
                {
                    isFirst=false;
                }
                if(!lstClientSubCategories.contains(workOrderObj.SubCategory__c) && isFirst==false)
                {
                    ExistingClientWorkOrders.put(workOrderObj.Client_Name__c,workOrderObj.Project_Code__c);
                    isFirst=true;
                }
                else if(lstClientSubCategories.contains(workOrderObj.SubCategory__c))
                {
                    projectCodeForConSub=workOrderObj.Project_Code__c;
                    clientName=workOrderObj.Client_Name__c;
                }
                if(lstClientSubCategories.contains(workOrderObj.SubCategory__c))
                {
                    ConSubProjectCode =workOrderObj.Project_Code__c;
                }
            }
        }
        
        List<Account> lstAccountProjectCodes= [SELECT Id,Name,Project_Code__c FROM Account WHERE Id =: WorkOrderClients];
        if(lstAccountProjectCodes.size()>0)
        {
            for(Account accObj:lstAccountProjectCodes)
            {
                system.debug('AccId------>'+accObj.Id);
                if(String.isBlank(accObj.Project_Code__c)){
                    accObj.Project_Code__c = ODS_Common_Utility.generateProjectCodeforAccount(accObj.Name);
                    accountWithNoProjectCode.put(accObj.Id,accObj);
                }               
                WorkOrdersClientProjectCode.put(accObj.Id,accObj.Project_Code__c);
                System.debug('accObj.Project_Code__c---'+ accObj.Project_Code__c);
            }
            if(!accountWithNoProjectCode.isEmpty()){
                Database.update(accountWithNoProjectCode.values());
                
            }
        }
        
        for(Work_Order__c WorkOrderVar: trigger.new){
            system.debug('new work order------>'+trigger.new); 
            system.debug('WorkOrderVar------>'+WorkOrderVar.Client_Name__c);
            system.debug('PC------>'+WorkOrderVar.Project_Code__c);
            List<string> nextCharactersSet=new List<string>();
            if(!String.isBlank(projectCodeForConSub) && lstClientSubCategories.contains(WorkOrderVar.SubCategory__c))
                
            {
                if (projectCodeForConSub.length() > 4 && projectCodeForConSub.left(4) == 'null') {
                    WorkOrderVar.Project_Code__c = WorkOrderVar.Client_Name__r.Project_Code__c ;
                    
                }
                else{
                    WorkOrderVar.Project_Code__c=projectCodeForConSub;
                }
                
                
            }
            else
            {
                String nextCharacter = 'A';
                String lastCharacters ='';
                String projectCode ='';
                system.debug('ExistingClientWorkOrders------>'+ExistingClientWorkOrders); 
                if(ExistingClientWorkOrders.containskey(WorkOrderVar.Client_Name__c))
                {
                    projectCode=ExistingClientWorkOrders.get(WorkOrderVar.Client_Name__c);
                }
                else
                {
                    projectCode=projectCodeForConSub;
                }
                if(projectCode!=null && projectCode!='')
                {
                    String character=projectCode.right(4).left(1);
                    nextCharactersSet.add(character);
                    if(string.isNotBlank(ConSubProjectCode)){
                        nextCharactersSet.add(ConSubProjectCode.right(4).left(1));
                    }else{
                        nextCharactersSet.add(nextCharacter);
                    }
                    system.debug('nextCharactersSet------>'+nextCharactersSet);
                    system.debug('character------>'+character); 
                    nextCharactersSet.sort();
                    character=nextCharactersSet.get(nextCharactersSet.size() - 1);
                    system.debug('after character------>'+character); 
                    character = (character == 'Z')  ? '/' : character;
                    Integer[] ASCIINumericRepresentation = character.getChars();
                    nextCharacter = String.fromCharArray(new List<Integer> {ASCIINumericRepresentation[0] + 1});
                }
                system.debug('nextCharacter------>'+nextCharacter); 
                if(WorkOrderVar.SubCategory__c=='DemandBlue-Fixed Price' || WorkOrderVar.SubCategory__c=='DemandBlue-Fixed Price-CO' 
                   || WorkOrderVar.SubCategory__c=='DemandDynamics -Fixed Price' || WorkOrderVar.SubCategory__c=='DemandDynamics -Fixed Price-CO'
                  || WorkOrderVar.SubCategory__c=='DX -Fixed Price' || WorkOrderVar.SubCategory__c=='DX -Fixed Price-CO'
                  || WorkOrderVar.SubCategory__c=='Enterprise Integration -Fixed Price' || WorkOrderVar.SubCategory__c=='Enterprise Integration -Fixed Price-CO' ||
                   WorkOrderVar.SubCategory__c=='Staffing- Fixed Price-CO'|| WorkOrderVar.SubCategory__c=='Staffing- Fixed Price')
                {
                    lastCharacters=System.Label.Fixed_Price_Code;
                }else if(WorkOrderVar.SubCategory__c=='DemandBlue-Consumption'||WorkOrderVar.SubCategory__c=='DemandBlue-Consumption-CO'||WorkOrderVar.SubCategory__c=='DemandBlue-Subscription'||WorkOrderVar.SubCategory__c=='DemandBlue-Subscription-CO'
                        || WorkOrderVar.SubCategory__c=='DemandDynamics -Consumption' || WorkOrderVar.SubCategory__c=='DemandDynamics -Consumption-CO' || WorkOrderVar.SubCategory__c=='DemandDynamics -Subscription' || WorkOrderVar.SubCategory__c=='DemandDynamics -Subscription-CO')
                {
                    lastCharacters=System.Label.Subscription_Consumption_Code;
                }
                else if(WorkOrderVar.SubCategory__c.contains('T&M'))
                {
                    lastCharacters=System.Label.T_M_Code;
                } else if(WorkOrderVar.SubCategory__c.contains('License Fee'))
                {
                    lastCharacters=System.Label.License_Fee_Code;
                }  else if(WorkOrderVar.SubCategory__c.contains('License Fee'))
                {
                    lastCharacters=System.Label.License_Fee_Code; 
                }else if(WorkOrderVar.SubCategory__c=='KPO -Consumption' || WorkOrderVar.SubCategory__c=='KPO -Consumption-CO')
                {
                    lastCharacters=System.Label.KPO_Consumption_Code; 
                }else if(WorkOrderVar.SubCategory__c=='Staffing- Direct Client' || WorkOrderVar.SubCategory__c=='Staffing- Direct Client-CO')
                {
                    lastCharacters=System.Label.Direct_Client_Code; 
                }else if(WorkOrderVar.SubCategory__c=='Staffing- Tier 2' || WorkOrderVar.SubCategory__c=='Staffing- Tier 2-CO')
                {
                    lastCharacters=System.Label.TIER_Code; 
                }else if(WorkOrderVar.SubCategory__c=='DX -Fixed Unit Price' || WorkOrderVar.SubCategory__c=='DX -Fixed Unit Price-CO' ||
                        WorkOrderVar.SubCategory__c=='Enterprise Integration -Fixed Unit Price' || WorkOrderVar.SubCategory__c=='Enterprise Integration -Fixed Unit Price-CO')
                {
                    lastCharacters=System.Label.Fixed_Unit_Price_Code; 
                }else if(WorkOrderVar.SubCategory__c=='DemandDynamics -Fixed Points' || WorkOrderVar.SubCategory__c=='DemandDynamics -Fixed Points-CO' )
                {
                    lastCharacters=System.Label.Fixed_Points_Code; 
                }
                system.debug('lastCharacters------>'+lastCharacters);  
                string categoryCode=system.Label.Category_Code;
                if(WorkOrderVar.Business_Unit__c=='DemandDynamics'){
                    categoryCode=System.Label.Category_Code_DD;
                }else if(WorkOrderVar.Business_Unit__c=='Staffing'){
                    categoryCode=System.Label.Category_Code_ST;
                }else if(WorkOrderVar.Business_Unit__c=='KPO'){
                    categoryCode=System.Label.Category_Code_KPO;
                }else if(WorkOrderVar.Business_Unit__c=='DX'){
                    categoryCode=System.Label.Category_Code_DX;
                }else if(WorkOrderVar.Business_Unit__c=='Enterprise Integration'){
                    categoryCode=System.Label.Category_Code_EI;
                }
                WorkOrderVar.Project_Code__c=WorkOrdersClientProjectCode.get(WorkOrderVar.Client_Name__c)+categoryCode+nextCharacter+lastCharacters;
            }
            
        }
        
    }
    if((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate)){
        system.debug('WorkOrder_API_Calls.isFirstTime------>'+WorkOrder_API_Calls.isFirstTime);   
        if(WorkOrder_API_Calls.isFirstTime){
            WorkOrder_API_Calls.isFirstTime = false;
            set<Id> WorkOrderIds = new set<Id>();
            set<Id> WorkOrderOwnerIds = new set<Id>();
            map<id,string> workOrderwithSubCategory=new map<id,string>();
            //Added by Vignesh for RecordUpdate Scenario
            set<Id> updatedWorkOrderIds = new set<Id>();
            set<Id> updatedWorkOrderOwnerIds = new set<Id>();
            Map<id,Work_Order__c> accountIdWithWO=new map<id,Work_Order__c>();
            Map<Id, Work_Order__c> billingChangedMap = new Map<Id, Work_Order__c>();
            
            for(Work_Order__c WorkOrderVar: trigger.new){
                system.debug('Project_Code__c------>'+WorkOrderVar.Project_Code__c);
                string subCategoryVar=workOrderVar.SubCategory__c;
                Work_Order__c oldWorkOrderData = Trigger.isUpdate ? Trigger.oldMap.get(workOrderVar.Id) : null;
                
                if (subCategoryVar != null && subCategoryVar.contains('Subscription-CO')) {
                    if (Trigger.isInsert || 
                        (Trigger.isUpdate && oldWorkOrderData.Project_End_Date__c != workOrderVar.Project_End_Date__c)) {
                            accountIdWithWO.put(workOrderVar.Client_Name__c, workOrderVar);
                        }
                }
                
                // Handle Subscription logic for Billing Frequency
                if (subCategoryVar == 'DemandBlue-Subscription' || subCategoryVar =='DemandBlue-Subscription-CO') {
                    if (Trigger.isInsert || 
                        (Trigger.isUpdate && oldWorkOrderData.Billing_Frequency__c != workOrderVar.Billing_Frequency__c)) {
                            billingChangedMap.put(workOrderVar.Client_Name__c, workOrderVar);
                        }
                }
                //DL-175 --> Not sending the fixed WO request to tips. Instead of sending the request to the tips using flow "Fixed_WorkOrder_API_Call" with one day delay.
                Boolean isBCIntegration = Boolean.valueOf(System.Label.BC_Integration);
                Boolean isWorkOrderBlank = isBCIntegration ? (String.isBlank(WorkOrderVar.BC_Work_Order_ID__c) && String.isBlank(WorkOrderVar.BC_Build_CNSMP_WO_ID__c)): String.isBlank(WorkOrderVar.Tips_Work_Order_ID__c);
                Boolean isFixedPrice = subCategoryVar.replaceAll('\\s', '').toLowerCase().contains('fixedprice');
                Boolean islicensefee = subCategoryVar.replaceAll('\\s', '').toLowerCase().contains('licensefee');
                Boolean kpoConsumption=subCategoryVar=='KPO -Consumption-CO' || subCategoryVar=='KPO -Consumption';
                Boolean isFixedUnitPrice = subCategoryVar.replaceAll('\\s', '').toLowerCase().contains('fixedunitprice');
                Boolean isFixedPoints= subCategoryVar.replaceAll('\\s', '').toLowerCase().contains('fixedpoints');
                Boolean isStaffing= WorkOrderVar.Business_Unit__c=='Staffing';

                system.debug('@@ WorkOrder_API_Calls.isFirstTime-'+WorkOrder_API_Calls.isFirstTime);
                system.debug('@@ isBCIntegration-'+isBCIntegration);
                system.debug('@@ isWorkOrderBlank-'+isWorkOrderBlank);
                system.debug('@@ isFixedPrice-'+isFixedPrice);
                
                if (WorkOrderVar.Project_Code__c != null) {
                    if (isWorkOrderBlank && !isFixedPrice && !islicensefee && !isFixedUnitPrice && !kpoConsumption && !isFixedPoints && !isStaffing) {
                        WorkOrderIds.add(WorkOrderVar.Id);
                        WorkOrderOwnerIds.add(WorkOrderVar.Account_Manager_Name__c);
                    } else if (!isWorkOrderBlank && !WorkOrder_API_Calls.triggeredFromDeliverable) {
                        updatedWorkOrderIds.add(WorkOrderVar.Id);
                        updatedWorkOrderOwnerIds.add(WorkOrderVar.Account_Manager_Name__c);
                    }
                }
            }
            
            
            system.debug('WorkOrderIds------>'+WorkOrderIds);
            if(WorkOrderIds.size()>0){
                if(System.isFuture()) {
                    return;
                }
                WorkOrder_API_Calls.addWorkOrderAPI=true;
                WorkOrder_API_Calls.AddWorkOrdersUsingAPI(WorkOrderIds);   
            }
            system.debug('updatedWorkOrderIds-'+updatedWorkOrderIds);
            Set<Id> accountIdsToUpdate = new Set<Id>();
            accountIdsToUpdate.addAll(accountIdWithWO.keySet());
            accountIdsToUpdate.addAll(billingChangedMap.keySet());
            List<Account_Services__c> accSerUpdatedList=new List<Account_Services__c>();
            List<Account_Services__c> accountServiceList=[Select Id,Contract_End_Date__c,Account__c,Invoice_Frequency__c FROM Account_Services__c WHERE Account__c IN:accountIdsToUpdate];
            for(Account_Services__c accSer:accountServiceList){
                Boolean shouldUpdate = false;
                Account_Services__c updatedRecord = new Account_Services__c(Id = accSer.Id);
                
                if (accountIdWithWO.containsKey(accSer.Account__c)) {
                    Work_Order__c wo = accountIdWithWO.get(accSer.Account__c);
                    updatedRecord.Contract_End_Date__c = wo.Project_End_Date__c;
                    shouldUpdate = true;
                }
                
                if (billingChangedMap.containsKey(accSer.Account__c)) {
                    Work_Order__c wo = billingChangedMap.get(accSer.Account__c);
                    updatedRecord.Invoice_Frequency__c = wo.Billing_Frequency__c;
                    shouldUpdate = true;
                }
                
                if (shouldUpdate) {
                    accSerUpdatedList.add(updatedRecord);
                }
            }
            if(!accSerUpdatedList.isEmpty()){
                update accSerUpdatedList;
            }
            
            if(trigger.isAfter && trigger.isUpdate)
            {
                if(updatedWorkOrderIds.size()>0)
                {
                    if(System.isFuture()) {
                        return;
                    }
                    WorkOrder_API_Calls.updateWorkOrderAPI = true;
                    WorkOrder_API_Calls.updateWorkOrdersUsingAPI(updatedWorkOrderIds,trigger.oldMap); 
                }
            }            
        }
    }
    if(trigger.isBefore && trigger.isDelete)
    {
        set<Id> WorkOrderIds = new set<Id>();
        for(Work_Order__c WorkOrderVar: trigger.old){
            system.debug('Project_Code__c------>'+WorkOrderVar.Project_Code__c);
            if((!Boolean.valueOf(System.Label.BC_Integration) && String.isNotBlank(WorkOrderVar.Tips_Work_Order_ID__c))
               || (Boolean.valueOf(System.Label.BC_Integration) && String.isNotBlank(WorkOrderVar.BC_Work_Order_ID__c))){
                   WorkOrderIds.add(WorkOrderVar.Id);
               }
        }
        
        system.debug('WorkOrderIds------>'+WorkOrderIds);
        if(WorkOrderIds.size()>0){
            if(System.isFuture()) {
                return;
            }
            WorkOrder_API_Calls.DeleteWorkOrdersUsingAPI(WorkOrderIds);
        }
    }
}