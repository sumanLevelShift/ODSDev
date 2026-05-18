public class WorkOrder_API_Calls{
    public static Boolean ByPassTest=false;
    public static Boolean isFirstTime = true;
    public static Map<string,String> workOrderUsersMap=new Map<string,String>();
    public static Map<Id,Contact> workOrderContactsMap=new Map<Id,Contact>();
    public static List<Deliverables__c> lstOfDeliverablesInfo=new List<Deliverables__c>();
    public static List<Deliverables__c> lstOfDeleteDeliverablesInfo=new List<Deliverables__c>();
    public static List<Work_Order__c> lstOfWorkOrdersToBeUpdated=new List<Work_Order__c>();
    public static Set<Id> expiryDateWordOrderIds = new Set<Id>();
    
    public static Set<Id> expiryDateWordOrderIdsAdmin = new Set<Id>();
    public static Set<Id> expiryDateWordOrderIdsConsulting = new Set<Id>();
    
    public static boolean updateWorkOrderAPI = false;
    public static boolean AddWorkOrderAPI = false;
    //Using this variable from DeliverableTriggerHandler trigger.
    public static boolean byPassValidation = false;
    public static boolean triggeredFromDeliverable = false;
    
    public static boolean adminAPI = false;
    public static boolean buildAPI = false;
    public static boolean consultingAPI = false;
    public static date newProjectStartDate;
    public static Integer count = 0;
    //SN
    public static void AddWorkOrdersUsingAPI(set<Id> setOfWorkOrderIds)
    {
        try{    
            system.debug('add testing');
            
            Set<string> setOfUsernames=new Set<string>();
            Set<Id> setOfWorkOrderContacts=new Set<Id>();
            
            List<Work_Order__c> workOrdersList =[SELECT Client_Name__r.Customer_Type__c,Account_CSM__c, Account_Manager_Name__c, Account_Manager_Name__r.Name,Account_Manager_Name__r.Email, Account_Partner__c, Admin_Hourly_Rate__c , Annual_Salary__c, Bill_Rate__c, Bill_Rate_Type__c, Billing_Frequency__c, Business_Unit__c, Client_Name__c, Client_Name__r.Backup_CSM__c, Client_Name__r.BillingCity, Client_Name__r.BillingCountry, Client_Name__r.BillingPostalCode, Client_Name__r.BillingState, Client_Name__r.BillingStreet, Client_Name__r.Id,Client_Name__r.Client_Code__c, Client_Name__r.Industry, Client_Name__r.Name, Client_Name__r.Owner.Name, Client_Name__r.Phone, Client_Name__r.Primary_contact_name__c, Client_Name__r.Primary_Customer_Contact__c, Client_Name__r.Primary_Customer_Email_Id__c, Client_Name__r.User__c, Consultant__r.Email, Consulting_Hourly_Rate__c , Contact_for_Payment_followUp__c, Contact_to_Send_the_Invoice__c,Contact_to_Send_the_Invoice__r.Name,Contact_to_Send_the_Invoice__r.Email,Contact_for_Payment_followUp__r.Name,Contact_for_Payment_followUp__r.Email, CSM__c, Customer_Type__c, Execution_Partner__c, Execution_Partner__r.Name,Execution_Partner__r.Email, Initial_Gross_Margin__c, LCA_Required__c, Minumim_Billable_Hours_Per_Month__c, Name, OwnerId, Pay_Rate__c, Payment_Terms_Projects__c, PayRate_t_M__c, PERDIEM__c, PO_Number__c, Project_Code__c, Project_End_Date__c, Project_Name__c, Project_Start_Date__c, Same_as_the_Invoice_Contact__c, SubCategory__c, Subscription_Fee_Frequency__c, Tips_Work_Order_ID__c, Total_Subscription_Fee__c, Vendor__r.Name, VP__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,Tips_CNSMP_API_Message__c,Tips_Admin_CNSMP_API_Message__c,Tips_Consulting_CNSMP_API_Message__c,BC_Work_Order_ID__c, BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c, BC_Consulting_CNSMP_API_Message__c, BC_Build_CNSMP_API_Message__c, BC_API_Message__c, BC_Admin_CNSMP_API_Message__c,Work_Order_Changes_Effective_Date__c,Delivery_Partner__c,Delivery_Partner__r.Email,Opportunity_Area__c,Description__c,Entity_Type__c,Client_Partner__c,Client_Partner__r.Email,Client_Name__r.Account_Type__c FROM Work_Order__c WHERE Id IN: setOfWorkOrderIds]; 
            
            for(Work_Order__c workOrderVar: workOrdersList)
            {
                setOfWorkOrderContacts.add(workOrderVar.Client_Name__c);
                if(workOrderVar.Account_Manager_Name__c!=null){setOfUsernames.add(workOrderVar.Account_Manager_Name__r.Name);}
                if(workOrderVar.VP__c!=null){setOfUsernames.add(workOrderVar.VP__c);}
                if(workOrderVar.Account_Partner__c!=null){ setOfUsernames.add(workOrderVar.Account_Partner__c);}
                if(workOrderVar.Execution_Partner__r!=null){setOfUsernames.add(workOrderVar.Execution_Partner__r.Name);}
                if(workOrderVar.Account_CSM__c!=null){setOfUsernames.add(workOrderVar.Account_CSM__c);}
            }
            system.debug('setOfUsernames==>'+setOfUsernames);
            Set<string> setOfTrimmedNames=new Set<string>();
            for(string username:setOfUsernames)
            {
                if(username!=null)
                {
                    string[] splitusername=username.split(' ');
                    string name=splitusername[0].trim()+' '+splitusername[splitusername.size() - 1].trim();
                    setOfTrimmedNames.add(name);
                }
            }
            system.debug('setOfTrimmedNames==>'+setOfTrimmedNames);
            List<User> lstOfUsers=[SELECT Name,Username,Email FROM User WHERE Name IN:setOfTrimmedNames];  
            for(User userVar:lstOfUsers)
            {
                workOrderUsersMap.put(userVar.Name,userVar.Email);
            }
            system.debug('workOrderUsersMap==>'+workOrderUsersMap);
            
            List<Contact> lstOfContacts=[SELECT Name,Email,AccountId FROM Contact WHERE AccountId IN:setOfWorkOrderContacts and isPrimary__c=true Order By lastmodifieddate desc];                  
            if(lstOfContacts.size()>0)   
            {
                for(Contact contactObj:lstOfContacts)
                {
                    workOrderContactsMap.put(contactObj.AccountId,contactObj);
                }
            }
            
            lstOfDeliverablesInfo=[SELECT Id,Work_Order__r.Id,Name,Start_date__c,End_date__c,Description__c,Amount__c FROM Deliverables__c WHERE Work_Order__r.Id IN:setOfWorkOrderIds Order By CreatedDate  ASC];  
            
            system.debug('lstOfDeliverablesInfo:'+lstOfDeliverablesInfo);
            for(Work_Order__c workOrderVar: workOrdersList)
            {
                system.debug('workOrderVar-'+workOrderVar);
                string subCategoryConsumption='';
                string body;
                if (workOrderVar.SubCategory__c != null && workOrderVar.SubCategory__c.contains('Subscription')) {
                    subCategoryConsumption = workOrderVar.SubCategory__c.replace('Subscription', 'Consumption');
                }
                newProjectStartDate=workOrderVar.Project_Start_Date__c;
                If(!boolean.valueOf(system.label.BC_Integration) || ByPassTest==true){
                    body='{"data":"'+AESEncryptDecrypt(GetInputString(workOrderVar))+'"}';
                    system.debug('main encryptedData------>'+body);                    
                    String billConsumptionBody='';
                    String adminConsumptionBody='';
                    String consultingConsumptionBody='';
                    if(workOrderVar.SubCategory__c.contains('Subscription')){
                        if(workOrderVar.Business_Unit__c=='DemandBlue'){
                            billConsumptionBody='{"data":"'+AESEncryptDecrypt(GetInputStringConsumption(workOrderVar,subCategoryConsumption,false,'Build'))+'"}';
                            if(workOrderVar.Client_Name__r.Customer_Type__c=='ABC Type'){
                                adminConsumptionBody='{"data":"'+AESEncryptDecrypt(GetInputStringConsumption(workOrderVar,subCategoryConsumption,true,'Admin'))+'"}';
                                consultingConsumptionBody='{"data":"'+AESEncryptDecrypt(GetInputStringConsumption(workOrderVar,subCategoryConsumption,true,'Consulting'))+'"}';
                            }
                        }
                    }
                    system.debug('build encryptedData------>'+billConsumptionBody);
                    system.debug('admin encryptedData------>'+adminConsumptionBody);
                    system.debug('consult encryptedData------>'+consultingConsumptionBody);
                    HttpRequest(workOrderVar.Id,System.Label.TIPS_API_Endpoint,body,workOrderVar.Name,'POST',false,billConsumptionBody,adminConsumptionBody,consultingConsumptionBody);
                }else{
                    system.debug('BC here');
                    body='{"data":"'+AESEncryptDecrypt(GetInputString(workOrderVar))+'"}';
                    string consumptionBody;
                    if(subCategoryConsumption.contains('Consumption')){
                        consumptionBody='{"data":"'+AESEncryptDecrypt(GetInputStringConsumption(workOrderVar,subCategoryConsumption,false,'Admin'))+'"}';
                    }
                    system.debug('body--'+body);
                    system.debug('consumptionBody-'+consumptionBody);
                    ODS_WorkOrder_BC_API_Helper.workOrderAPI('Add',body,workOrderVar.Id,consumptionBody,workOrderVar.Business_Unit__c,workOrderVar.Entity_Type__c);
                }
                
            }
        }
        catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    }     
    //SN    
    public static void updateWorkOrdersUsingAPI(set<Id> setOfWorkOrderIds,Map<Id,Work_Order__c> workdOrderOldMap)
    {
        try{   
            system.debug('update testing');
            adminAPI=false;
            buildAPI=false;
            consultingAPI=false;
            Set<string> setOfUsernames=new Set<string>();
            Set<Id> setOfWorkOrderContacts=new Set<Id>();
            
            List<Work_Order__c> workOrdersList = [SELECT Subscription_Fee_Sticker_Price__c,Subscription_Fee_Discount__c,Client_Name__r.Customer_Type__c,Account_CSM__c, Account_Manager_Name__c,Account_Manager_Name__r.Email, Account_Manager_Name__r.Name, Account_Partner__c, Admin_Hourly_Rate__c , Annual_Salary__c, Bill_Rate__c, Bill_Rate_Type__c, Billing_Frequency__c, Business_Unit__c, Client_Name__c, Client_Name__r.Backup_CSM__c, Client_Name__r.BillingCity, Client_Name__r.BillingCountry, Client_Name__r.BillingPostalCode, Client_Name__r.BillingState, Client_Name__r.BillingStreet, Client_Name__r.Id, Client_Name__r.Industry, Client_Name__r.Name, Client_Name__r.Owner.Name, Client_Name__r.Phone, Client_Name__r.Primary_contact_name__c,Client_Name__r.Client_Code__c, Client_Name__r.Primary_Customer_Contact__c, Client_Name__r.Primary_Customer_Email_Id__c, Client_Name__r.User__c, Consultant__r.Email, Consulting_Hourly_Rate__c , Contact_for_Payment_followUp__c, Contact_to_Send_the_Invoice__c,Contact_to_Send_the_Invoice__r.Name, Contact_to_Send_the_Invoice__r.Email, Contact_for_Payment_followUp__r.Name, Contact_for_Payment_followUp__r.Email, CSM__c, Customer_Type__c, Execution_Partner__c, Execution_Partner__r.Email, Execution_Partner__r.Name, Initial_Gross_Margin__c, LCA_Required__c, Minumim_Billable_Hours_Per_Month__c, Name, OwnerId, Pay_Rate__c, Payment_Terms_Projects__c, PayRate_t_M__c, PERDIEM__c, PO_Number__c, Project_Code__c, Project_End_Date__c, Project_Name__c, Project_Start_Date__c, Same_as_the_Invoice_Contact__c, SubCategory__c, Subscription_Fee_Frequency__c, Tips_Work_Order_ID__c, Total_Subscription_Fee__c, Vendor__r.Name, VP__c, Work_Order_Changes_Effective_Date__c, TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,Tips_CNSMP_API_Message__c,Tips_Admin_CNSMP_API_Message__c,Tips_Consulting_CNSMP_API_Message__c,BC_Work_Order_ID__c, BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c, BC_Consulting_CNSMP_API_Message__c, BC_Build_CNSMP_API_Message__c, BC_API_Message__c, BC_Admin_CNSMP_API_Message__c,Delivery_Partner__c,Delivery_Partner__r.Email,Opportunity_Area__c,Description__c,Entity_Type__c,Client_Partner__c,Client_Partner__r.Email,Client_Name__r.Account_Type__c FROM Work_Order__c WHERE Id IN: setOfWorkOrderIds];
            
            for(Work_Order__c workOrderVar: workOrdersList)
            {
                setOfWorkOrderContacts.add(workOrderVar.Client_Name__c);
                if(workOrderVar.Account_Manager_Name__c!=null){setOfUsernames.add(workOrderVar.Account_Manager_Name__r.Name);}
                if(workOrderVar.VP__c!=null){setOfUsernames.add(workOrderVar.VP__c);}
                if(workOrderVar.Account_Partner__c!=null){ setOfUsernames.add(workOrderVar.Account_Partner__c);}
                if(workOrderVar.Execution_Partner__r!=null){setOfUsernames.add(workOrderVar.Execution_Partner__r.Name);}
                if(workOrderVar.Account_CSM__c!=null){setOfUsernames.add(workOrderVar.Account_CSM__c);}
                
                Work_Order__c oldWorkOrderData = workdOrderOldMap.get(workOrderVar.Id);
                system.debug('oldWorkOrderData.Annual_Salary__c==>'+oldWorkOrderData.Annual_Salary__c);
                system.debug('oldWorkOrderData.OwnerId==>'+oldWorkOrderData.Account_Manager_Name__c);
                system.debug('oldWorkOrderData.Bill_Rate__c==>'+oldWorkOrderData.Bill_Rate__c);
                system.debug('newWorkOrderData.Bill_Rate__c==>'+workOrderVar.Bill_Rate__c);
                
                Boolean isABCCustomer = workOrderVar.Client_Name__r.Customer_Type__c == 'ABC Type';
                Boolean effectiveDatePresent = workOrderVar.Work_Order_Changes_Effective_Date__c != null;
                newProjectStartDate =effectiveDatePresent?workOrderVar.Work_Order_Changes_Effective_Date__c:workOrderVar.Project_Start_Date__c;
                Boolean subscriptionOnlyChange =
                    oldWorkOrderData.Subscription_Fee_Discount__c != workOrderVar.Subscription_Fee_Discount__c ||
                    oldWorkOrderData.Subscription_Fee_Sticker_Price__c != workOrderVar.Subscription_Fee_Sticker_Price__c;
                
                Boolean billRateChanged = oldWorkOrderData.Bill_Rate__c != workOrderVar.Bill_Rate__c;
                Boolean adminRateChanged = oldWorkOrderData.Admin_Hourly_Rate__c != workOrderVar.Admin_Hourly_Rate__c;
                Boolean consultingRateChanged = oldWorkOrderData.Consulting_Hourly_Rate__c != workOrderVar.Consulting_Hourly_Rate__c;
                
                Boolean otherChanges =
                    /*oldWorkOrderData.Annual_Salary__c != workOrderVar.Annual_Salary__c ||
                    oldWorkOrderData.Account_Manager_Name__c != workOrderVar.Account_Manager_Name__c ||
                    oldWorkOrderData.PERDIEM__c != workOrderVar.PERDIEM__c ||
                    oldWorkOrderData.Pay_Rate__c != workOrderVar.Pay_Rate__c ||*/
                    billRateChanged || adminRateChanged || consultingRateChanged ;
                    /*oldWorkOrderData.Bill_Rate_Type__c != workOrderVar.Bill_Rate_Type__c ||
                    oldWorkOrderData.Delivery_Partner__c != workOrderVar.Delivery_Partner__c;*/
                
                if (effectiveDatePresent && (subscriptionOnlyChange || otherChanges)) {
                    if(subscriptionOnlyChange){
                        expiryDateWordOrderIds.add(workOrderVar.Id);
                    }
                    if (otherChanges) {
                        if (billRateChanged) {
                            expiryDateWordOrderIds.add(workOrderVar.Id);
                            buildAPI = true;
                        }
                        
                        if (isABCCustomer) {
                            if (adminRateChanged) {
                                expiryDateWordOrderIdsAdmin.add(workOrderVar.Id);
                                adminAPI = true;
                            }
                            if (consultingRateChanged) {
                                expiryDateWordOrderIdsConsulting.add(workOrderVar.Id);
                                consultingAPI = true;
                            }
                        }
                    }
                }
            }
            system.debug('expiryDateWordOrderIds-- from update'+expiryDateWordOrderIds);
            system.debug('setOfUsernames update==>'+setOfUsernames);
            Set<string> setOfTrimmedNames=new Set<string>();
            
            for(string username:setOfUsernames)
            {
                if(username!=null)
                {
                    string[] splitusername=username.split(' ');
                    string name=splitusername[0].trim()+' '+splitusername[splitusername.size() - 1].trim();
                    setOfTrimmedNames.add(name);  
                }
                
            }
            system.debug('setOfTrimmedNames==>'+setOfTrimmedNames);
            List<User> lstOfUsers=[SELECT Name,Username,Email FROM User WHERE Name IN:setOfTrimmedNames];  
            for(User userVar:lstOfUsers)
            {
                workOrderUsersMap.put(userVar.Name,userVar.Email);
            }
            system.debug('workOrderUsersMap==>'+workOrderUsersMap);
            List<Contact> lstOfContacts=[SELECT Name,Email,AccountId FROM Contact WHERE AccountId IN:setOfWorkOrderContacts and isPrimary__c=true Order By lastmodifieddate desc];                  
            if(lstOfContacts.size()>0)   
            {
                for(Contact contactObj:lstOfContacts)
                {
                    workOrderContactsMap.put(contactObj.AccountId,contactObj);
                }
            }
            
            lstOfDeliverablesInfo=[SELECT Id,Work_Order__r.Id,Name,Start_date__c,End_date__c,Description__c,Amount__c FROM Deliverables__c WHERE Work_Order__r.Id IN:setOfWorkOrderIds Order By CreatedDate  ASC];  
            
            system.debug('lstOfDeliverablesInfo:'+lstOfDeliverablesInfo);
            for(Work_Order__c workorder: workOrdersList)
            {     
                string subCategoryConsumption='';
                string body;
                if (workorder.SubCategory__c != null && workorder.SubCategory__c.contains('Subscription')) {
                    subCategoryConsumption = workorder.SubCategory__c.replace('Subscription', 'Consumption');
                }
                If(!boolean.valueOf(system.label.BC_Integration) || ByPassTest==true){
                    system.debug('inputstring------>'+GetInputString(workorder));
                    
                    body='{"data":"'+AESEncryptDecrypt(GetInputString(workorder))+'"}';
                    
                    system.debug('encryptedData------>'+body);
                    
                    String billConsumptionBody='';
                    String adminConsumptionBody='';
                    String consultingConsumptionBody='';
                    if(workorder.SubCategory__c.contains('Subscription')){
                        if(workorder.Business_Unit__c=='DemandBlue'){
                            If(buildAPI){
                                billConsumptionBody='{"data":"'+AESEncryptDecrypt(GetInputStringConsumption(workorder,subCategoryConsumption,false,'Build'))+'"}';
                            }
                            if(workorder.Client_Name__r.Customer_Type__c=='ABC Type'){
                                if(adminAPI){
                                    adminConsumptionBody='{"data":"'+AESEncryptDecrypt(GetInputStringConsumption(workorder,subCategoryConsumption,true,'Admin'))+'"}';
                                }
                                if(consultingAPI){
                                    consultingConsumptionBody='{"data":"'+AESEncryptDecrypt(GetInputStringConsumption(workorder,subCategoryConsumption,true,'Consulting'))+'"}';
                                }
                            }
                        }
                    }
                    HttpRequest(workorder.Id,System.Label.TIPS_API_Update_Endpoint,body,workorder.Name,'POST',false,billConsumptionBody,adminConsumptionBody,consultingConsumptionBody);
                }else{
                    if(String.isNotBlank(workorder.BC_Work_Order_ID__c))
                        body='{"data":"'+AESEncryptDecrypt(GetInputString(workorder))+'"}';
                    string consumptionBody;
                    if(subCategoryConsumption.contains('Consumption') && String.isNotBlank(workorder.BC_Build_CNSMP_WO_ID__c)){
                        consumptionBody='{"data":"'+AESEncryptDecrypt(GetInputStringConsumption(workorder,subCategoryConsumption,false,'Admin'))+'"}';
                    }
                    system.debug('body--'+body);
                    system.debug('consumptionBody-'+consumptionBody);
                    ODS_WorkOrder_BC_API_Helper.workOrderAPI('Update',body,workorder.Id,consumptionBody,workorder.Business_Unit__c,workOrder.Entity_Type__c);
                }                
            }
            
            updateWorkOrderAPI = false;
            
        }
        catch(Exception e)    
        {
            updateWorkOrderAPI = false;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    }   
    //This method invoked from 'DeliverableTriggerHandler' apex trigger.
    public static void updateWorkOrdersUsingAPIForDeliverable(set<Id> setOfWorkOrderIds,Map<Id,Work_Order__c> workdOrderOldMap,List<Deliverables__c> deleteDeliverablesList)
    {
        try{  
            lstOfDeleteDeliverablesInfo=new list<Deliverables__c>();
            lstOfDeleteDeliverablesInfo=deleteDeliverablesList;
            system.debug('update testing');
            adminAPI=false;
            buildAPI=false;
            consultingAPI=false;
            Set<string> setOfUsernames=new Set<string>();
            Set<Id> setOfWorkOrderContacts=new Set<Id>();
            
            List<Work_Order__c> workOrdersList = [SELECT Subscription_Fee_Sticker_Price__c,Subscription_Fee_Discount__c,Client_Name__r.Customer_Type__c,Account_CSM__c, Account_Manager_Name__c,Account_Manager_Name__r.Email, Account_Manager_Name__r.Name, Account_Partner__c, Admin_Hourly_Rate__c , Annual_Salary__c, Bill_Rate__c, Bill_Rate_Type__c, Billing_Frequency__c, Business_Unit__c, Client_Name__c, Client_Name__r.Backup_CSM__c, Client_Name__r.BillingCity, Client_Name__r.BillingCountry, Client_Name__r.BillingPostalCode, Client_Name__r.BillingState, Client_Name__r.BillingStreet, Client_Name__r.Id, Client_Name__r.Industry, Client_Name__r.Name, Client_Name__r.Owner.Name, Client_Name__r.Phone, Client_Name__r.Primary_contact_name__c,Client_Name__r.Client_Code__c, Client_Name__r.Primary_Customer_Contact__c, Client_Name__r.Primary_Customer_Email_Id__c, Client_Name__r.User__c, Consultant__r.Email, Consulting_Hourly_Rate__c , Contact_for_Payment_followUp__c, Contact_to_Send_the_Invoice__c,Contact_to_Send_the_Invoice__r.Name, Contact_to_Send_the_Invoice__r.Email, Contact_for_Payment_followUp__r.Name, Contact_for_Payment_followUp__r.Email, CSM__c, Customer_Type__c, Execution_Partner__c, Execution_Partner__r.Email, Execution_Partner__r.Name, Initial_Gross_Margin__c, LCA_Required__c, Minumim_Billable_Hours_Per_Month__c, Name, OwnerId, Pay_Rate__c, Payment_Terms_Projects__c, PayRate_t_M__c, PERDIEM__c, PO_Number__c, Project_Code__c, Project_End_Date__c, Project_Name__c, Project_Start_Date__c, Same_as_the_Invoice_Contact__c, SubCategory__c, Subscription_Fee_Frequency__c, Tips_Work_Order_ID__c, Total_Subscription_Fee__c, Vendor__r.Name, VP__c, Work_Order_Changes_Effective_Date__c, TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,Tips_CNSMP_API_Message__c,Tips_Admin_CNSMP_API_Message__c,Tips_Consulting_CNSMP_API_Message__c,BC_Work_Order_ID__c, BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c, BC_Consulting_CNSMP_API_Message__c, BC_Build_CNSMP_API_Message__c, BC_API_Message__c, BC_Admin_CNSMP_API_Message__c,Delivery_Partner__c,Delivery_Partner__r.Email,Opportunity_Area__c,Description__c,Entity_Type__c,Client_Partner__c,Client_Partner__r.Email,Client_Name__r.Account_Type__c	 FROM Work_Order__c WHERE Id IN: setOfWorkOrderIds];
            
            for(Work_Order__c workOrderVar: workOrdersList)
            {
                setOfWorkOrderContacts.add(workOrderVar.Client_Name__c);
                if(workOrderVar.Account_Manager_Name__c!=null){setOfUsernames.add(workOrderVar.Account_Manager_Name__r.Name);}
                if(workOrderVar.VP__c!=null){setOfUsernames.add(workOrderVar.VP__c);}
                if(workOrderVar.Account_Partner__c!=null){ setOfUsernames.add(workOrderVar.Account_Partner__c);}
                if(workOrderVar.Execution_Partner__r!=null){setOfUsernames.add(workOrderVar.Execution_Partner__r.Name);}
                if(workOrderVar.Account_CSM__c!=null){setOfUsernames.add(workOrderVar.Account_CSM__c);}
                
                Work_Order__c oldWorkOrderData = workdOrderOldMap.get(workOrderVar.Id);
                system.debug('oldWorkOrderData.Annual_Salary__c==>'+oldWorkOrderData.Annual_Salary__c);
                system.debug('oldWorkOrderData.OwnerId==>'+oldWorkOrderData.Account_Manager_Name__c);
                system.debug('oldWorkOrderData.Bill_Rate__c==>'+oldWorkOrderData.Bill_Rate__c);
                system.debug('newWorkOrderData.Bill_Rate__c==>'+workOrderVar.Bill_Rate__c);

                
            }
            system.debug('expiryDateWordOrderIds-- from update'+expiryDateWordOrderIds);
            system.debug('setOfUsernames update==>'+setOfUsernames);
            Set<string> setOfTrimmedNames=new Set<string>();
            
            for(string username:setOfUsernames)
            {
                if(username!=null)
                {
                    string[] splitusername=username.split(' ');
                    string name=splitusername[0].trim()+' '+splitusername[splitusername.size() - 1].trim();
                    setOfTrimmedNames.add(name);  
                }
                
            }
            system.debug('setOfTrimmedNames==>'+setOfTrimmedNames);
            List<User> lstOfUsers=[SELECT Name,Username,Email FROM User WHERE Name IN:setOfTrimmedNames];  
            for(User userVar:lstOfUsers)
            {
                workOrderUsersMap.put(userVar.Name,userVar.Email);
            }
            system.debug('workOrderUsersMap==>'+workOrderUsersMap);
            List<Contact> lstOfContacts=[SELECT Name,Email,AccountId FROM Contact WHERE AccountId IN:setOfWorkOrderContacts and isPrimary__c=true Order By lastmodifieddate desc];                  
            if(lstOfContacts.size()>0)   
            {
                for(Contact contactObj:lstOfContacts)
                {
                    workOrderContactsMap.put(contactObj.AccountId,contactObj);
                }
            }
            
            lstOfDeliverablesInfo=[SELECT Id,Work_Order__r.Id,Name,Start_date__c,End_date__c,Description__c,Amount__c FROM Deliverables__c WHERE Work_Order__r.Id IN:setOfWorkOrderIds Order By CreatedDate  ASC];  
            
            system.debug('lstOfDeliverablesInfo:'+lstOfDeliverablesInfo);
            for(Work_Order__c workorder: workOrdersList)
            {   
                //string subCategoryConsumption='';
                string body;
                /* if(workorder.SubCategory__c.contains('Subscription')){
if(workorder.Business_Unit__c=='DemandBlue'){
if(workorder.SubCategory__c==workorder.Business_Unit__c+'-Subscription'){
subCategoryConsumption=workorder.Business_Unit__c+'-Consumption';  
}else{
subCategoryConsumption=workorder.Business_Unit__c+'-Consumption-CO';   
}
}
}*/
                If(!boolean.valueOf(system.label.BC_Integration) || ByPassTest==true){
                    // system.debug('inputstring------>'+GetInputString(workorder));
                    
                    body='{"data":"'+AESEncryptDecrypt(GetInputString(workorder))+'"}';
                    
                    system.debug('encryptedData------>'+body);
                    
                    String billConsumptionBody='';
                    String adminConsumptionBody='';
                    String consultingConsumptionBody='';
                    HttpRequest(workorder.Id,System.Label.TIPS_API_Update_Endpoint,body,workorder.Name,'POST',false,billConsumptionBody,adminConsumptionBody,consultingConsumptionBody);
                    
                }else{
                    body='{"data":"'+AESEncryptDecrypt(GetInputString(workorder))+'"}';
                    string consumptionBody;
                    system.debug('body--'+body);
                    system.debug('consumptionBody-'+consumptionBody);
                    ODS_WorkOrder_BC_API_Helper.workOrderAPI('Update',body,workorder.Id,consumptionBody,workorder.Business_Unit__c,workorder.Entity_Type__c);
                }
            }
            
            updateWorkOrderAPI = false;
            triggeredFromDeliverable=false;
        }
        catch(Exception e)    
        {
            updateWorkOrderAPI = false;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    }
    public static void DeleteWorkOrdersUsingAPI(set<Id> setOfWorkOrderIds)
    {
        try
        {
            
            List<Work_Order__c> workOrdersListTodelete =[SELECT Id,Name,Tips_Work_Order_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,SubCategory__c,BC_Work_Order_ID__c, BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c, BC_Consulting_CNSMP_API_Message__c, BC_Build_CNSMP_API_Message__c, BC_API_Message__c, BC_Admin_CNSMP_API_Message__c,Entity_Type__c,Business_Unit__c	 FROM Work_Order__c WHERE Id IN: setOfWorkOrderIds]; 
            
            for(Work_Order__c workorder: workOrdersListTodelete)
            {
                If(!boolean.valueOf(system.label.BC_Integration) || ByPassTest==true){
                    
                    String voidWorkOrder ='{"TipsWorkorder_Id":"'+workorder.Tips_Work_Order_ID__c+'","Void_Wo":"True"}';
                    system.debug('VoidWorkOrder------>'+voidWorkOrder);
                    string body='{"data":"'+AESEncryptDecrypt(voidWorkOrder)+'"}';
                    system.debug('encryptedData------>'+body);
                    String voidWorkOrderBuildCnsmp ='';
                    String voidWorkOrderAdminCnsmp ='';
                    String voidWorkOrderconsultCnsmp ='';
                    if(string.isNotBlank(workorder.TIPS_CNSMP_WO_ID__c)){
                        voidWorkOrderBuildCnsmp ='{"TipsWorkorder_Id":"'+workorder.TIPS_CNSMP_WO_ID__c+'","Void_Wo":"True"}';
                        voidWorkOrderBuildCnsmp='{"data":"'+AESEncryptDecrypt(voidWorkOrderBuildCnsmp)+'"}';
                        
                    }
                    if(string.isNotBlank(workorder.TIPS_Admin_CNSMP_WO_ID__c)){
                        voidWorkOrderAdminCnsmp ='{"TipsWorkorder_Id":"'+workorder.TIPS_Admin_CNSMP_WO_ID__c+'","Void_Wo":"True"}';
                        voidWorkOrderAdminCnsmp='{"data":"'+AESEncryptDecrypt(voidWorkOrderAdminCnsmp)+'"}';
                    }
                    if(string.isNotBlank(workorder.TIPS_Consulting_CNSMP_WO_ID__c)){
                        voidWorkOrderconsultCnsmp ='{"TipsWorkorder_Id":"'+workorder.TIPS_Consulting_CNSMP_WO_ID__c+'","Void_Wo":"True"}';
                        voidWorkOrderconsultCnsmp='{"data":"'+AESEncryptDecrypt(voidWorkOrderconsultCnsmp)+'"}';
                    }
                    
                    HttpRequest(workorder.Id,System.Label.TIPS_API_Void_Endpoint,body,workorder.Name,'POST',true,voidWorkOrderBuildCnsmp,voidWorkOrderAdminCnsmp,voidWorkOrderconsultCnsmp);
                }else{
                    string body='{"VoidOrders":[{"WordOrderid":"'+workorder.BC_Work_Order_ID__c+'"}]}';
                    body='{"data":"'+AESEncryptDecrypt(body)+'"}';
                    string consumptionbody='';
                    if(workorder.SubCategory__c.contains('Subscription')){
                        consumptionbody ='{"VoidOrders":[';
                        if(string.isNotBlank(workorder.BC_Build_CNSMP_WO_ID__c)){
                            consumptionbody +='{"WordOrderid":"'+workorder.BC_Build_CNSMP_WO_ID__c+'"}';
                        }
                        if(string.isNotBlank(workorder.BC_Admin_CNSMP_WO_ID__c)){
                            consumptionbody +=',{"WordOrderid":"'+workorder.BC_Admin_CNSMP_WO_ID__c+'"}';
                        }
                        if(string.isNotBlank(workorder.BC_Consulting_CNSMP_WO_ID__c)){
                            consumptionbody +=',{"WordOrderid":"'+workorder.BC_Consulting_CNSMP_WO_ID__c+'"}';
                        }
                        consumptionbody +=']}';
                        consumptionbody='{"data":"'+AESEncryptDecrypt(consumptionbody)+'"}';
                    }
                    ODS_WorkOrder_BC_API_Helper.workOrderAPI('Void',body,workorder.id,consumptionbody,workorder.Business_Unit__c,workorder.Entity_Type__c);
                }
                
            }
        }
        catch(Exception e)
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug(e.getMessage());
        }
    }
    //SN
    @future (callout=true) 
    public static Void HttpRequest(Id workOrderId,string Endpoint,string body,string workOrderName,string MethodType,boolean isdelete,string billConsumptionBody,string adminConsumptionBody,string consultingConsumptionBody)
    {
        try
        {   Work_Order__c workOrderRecord;
         if(!isdelete){
             workOrderRecord=[SELECT Id,Tips_Work_Order_ID__c,Business_Unit__c FROM Work_Order__c WHERE Id=:workOrderId LIMIT 1];
         }
         
         Http http = new Http();
         string responseJson='';
         string accessToken=GenerateAuthorizationToken();
         system.debug('accessToken:'+accessToken);
         
         //api request 
         HttpRequest request = new HttpRequest();  
         request.setMethod(MethodType);
         request.setEndpoint(Endpoint);
         request.setTimeout(120000);
         request.setHeader('Content-Type','application/json');
         request.setHeader('Authorization','Bearer '+accessToken);            
         system.debug('encryptedData------>'+body);
         request.setBody(body);
         HTTPResponse response = http.send(request);      
         system.debug(response);
         responseJson = response.getBody();
         system.debug(response);
         if(response.getStatusCode()==200 && !isdelete)
         {
             system.debug('responseJson------>'+responseJson);
             if(responseJson.contains('-') && !responseJson.contains('Alert Message')){
                 String jsonResponse = (String)JSON.deserializeUntyped(responseJson);
                 
                 Work_Order__c workOrder1=new Work_Order__c();
                 workOrder1.Id=workOrderId;
                 workOrder1.Tips_API_Message__c=jsonResponse.split('-')[0];
                 workOrder1.Tips_Work_Order_ID__c=jsonResponse.split('-')[1];
                 lstOfWorkOrdersToBeUpdated.add(workOrder1);
                 List<string> jsonResponseList=jsonResponse.split('-');
                 system.debug('jsonResponse.contains1---'+(jsonResponse.contains('-')?jsonResponse.split('-')[1]:jsonResponse));
                 
                 if(jsonResponseList.Size()==6){   
                     //sample jsonResponse----->"WorkOrder Added Successfully - 12734 - AccountCode :-M09 -  SFClientID :-0018M00000MOmyXQAT"                     
                     system.debug('jsonResponse.contains2---'+(jsonResponse.contains('-')?jsonResponse.split('-')[2]:jsonResponse));
                     system.debug('jsonResponse.contains3---'+(jsonResponse.contains('-')?jsonResponse.split('-')[3]:jsonResponse));
                     system.debug('jsonResponse.contains4---'+(jsonResponse.contains('-')?jsonResponse.split('-')[4]:jsonResponse));
                     system.debug('jsonResponse.contains5---'+(jsonResponse.contains('-')?jsonResponse.split('-')[5]:jsonResponse));
                     Set<string> Clientcode=new Set<string>();
                     string CD=jsonResponse.split('-')[5];
                     Clientcode.add(CD);
                     system.debug('Clientcode==>'+Clientcode);
                     List<Account> Acc=[SELECT Client_Code__c FROM Account WHERE id IN:Clientcode];
                     system.debug('Acc out==>'+Acc);
                     if(Acc.size()>0)   
                     {
                         system.debug('Acc inside==>'+Acc);
                         for(Account AccVar:Acc)
                         {
                             AccVar.Client_Code__c=jsonResponse.split('-')[3];
                             system.debug('After client code==>'+AccVar.Client_Code__c);
                         }
                         update Acc;
                         
                     }
                 }
             }
             else
             {
                 If(!isdelete && workOrderRecord.Tips_Work_Order_ID__c==Null){
                     billConsumptionBody='';
                     adminConsumptionBody='';
                     consultingConsumptionBody='';
                 }
                 if(responseJson.length()>3000)
                 {
                     //send error response as email with attachment
                     
                     List<string> sendTo = System.Label.WorkOrder_Users.Split('\r\n');
                     blob fileBody =Blob.valueOf(responseJson);
                     Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                     efa.setFileName(workOrderName+'.txt');
                     efa.setBody(fileBody);		
                     Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                     semail.setSubject('Work Orders Error Status');
                     semail.setToAddresses(sendTo);
                     semail.setPlainTextBody('Please find the attached book details');
                     semail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
                     
                 }
                 else
                 {
                     Work_Order__c workOrder2=new Work_Order__c();
                     workOrder2.Id=workOrderId;
                     workOrder2.Tips_API_Message__c=responseJson;
                     lstOfWorkOrdersToBeUpdated.add(workOrder2);
                     sendMailWorkorderFailure(workOrderId, responseJson);
                     ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, body, responseJson, 'Subscription');
                 }
             }
             
             if(!isdelete && workOrderRecord.Business_Unit__c=='DemandBlue'){
                 Id jobID=System.enqueueJob(new WorkOrder_API_Calls_CNSMP(workOrderId,Endpoint,billConsumptionBody,adminConsumptionBody,consultingConsumptionBody,workOrderName,MethodType));
             }
             
         }
         //sending error mail
         else 
         {
             sendMailWorkorderFailure(workOrderId, responseJson);
             ODS_ExceptionUtility.logTipsIntegrationFailure(workOrderId, body, responseJson, 'Subscription');
             
         }
         //update work orders
         if(!lstOfWorkOrdersToBeUpdated.isEmpty())
         {
             system.debug('lstOfWorkOrdersToBeUpdated--'+lstOfWorkOrdersToBeUpdated);
             update lstOfWorkOrdersToBeUpdated;
         }
         updateWorkOrderAPI = false;
        }
        catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    }    
    
    public static String GetInputString(Work_Order__c workOrderVar)
    {
        try{ 
            
            List<Deliverables__c> lstOfmilestonesInfo=new List<Deliverables__c>();
            Date startDate=newProjectStartDate!=null?newProjectStartDate:workOrderVar.Project_Start_Date__c;
            Date endDate=workOrderVar.Project_End_Date__c;
            
            string subCategoryVar=workOrderVar.SubCategory__c;
            string SubscriptionFrequency=workOrderVar.Subscription_Fee_Frequency__c;
            system.debug('subCategoryVar -->'+subCategoryVar);
            String projectStartDate='';String projectend='';String milestonestart=''; String milestoneend='';string useremailId='';
            string primaryContactName='';string primaryContactEmailId='';
            
            string vendorName=workOrderVar.Vendor__r.Name==null?System.Label.Vendor_Default_Value:workOrderVar.Vendor__r.Name;
            string annualSalary=workOrderVar.Annual_Salary__c==null?'0':String.valueOf(workOrderVar.Annual_Salary__c);
            string peridiumAmount=workOrderVar.PERDIEM__c==null?'0':String.valueOf(workOrderVar.PERDIEM__c);
            string baseRate=workOrderVar.PayRate_t_M__c==null?'0':String.valueOf(workOrderVar.PayRate_t_M__c);
            string miniumBillHours=workOrderVar.Minumim_Billable_Hours_Per_Month__c==null?'0':String.valueOf(workOrderVar.Minumim_Billable_Hours_Per_Month__c);
            string milestoneInfo='';
            Decimal billrate=0.0;
            string billratetype='';
            if(subCategoryVar.toLowerCase().contains('subscription'))
            {
                billrate=workOrderVar.Total_Subscription_Fee__c;
            }
            else 
            {
                billrate=workOrderVar.Bill_Rate__c;
            }
            if(subCategoryVar.toLowerCase().contains('subscription'))
            {
                if (SubscriptionFrequency.toLowerCase().contains('annually'))
                {
                    billratetype='One Time';
                }
                else if (SubscriptionFrequency.toLowerCase().contains('upfront'))
                {
                    billratetype='One Time';
                }
                else{
                    billratetype=String.valueOf(workOrderVar.Subscription_Fee_Frequency__c);
                }
            }
            else 
            {
                billratetype=String.valueOf(workOrderVar.Bill_Rate_Type__c);
            }
            if(billrate!=null){
            billrate=billrate.setScale(2);
            }else{
               billrate=0; 
            }
            
            if(workOrderVar.Contact_to_Send_the_Invoice__c!=null||workOrderVar.Contact_for_Payment_followUp__c!=null)
            {
                if(workOrderVar.Contact_to_Send_the_Invoice__c!=null)
                {
                    primaryContactName=workOrderVar.Contact_to_Send_the_Invoice__r.Name;
                    primaryContactEmailId=workOrderVar.Contact_to_Send_the_Invoice__r.Email;
                }
                else if(workOrderVar.Contact_for_Payment_followUp__c!=null && workOrderVar.Same_as_the_Invoice_Contact__c ==true)
                {
                    primaryContactName=workOrderVar.Contact_for_Payment_followUp__r.Name;
                    primaryContactEmailId=workOrderVar.Contact_for_Payment_followUp__r.Email;
                }
            }
            else
            {
                if(workOrderVar.Client_Name__r.Primary_Customer_Contact__c!=null)
                {
                    primaryContactName=workOrderVar.Client_Name__r.Primary_contact_name__c;
                    primaryContactEmailId=workOrderVar.Client_Name__r.Primary_Customer_Email_Id__c;
                }
                else
                {
                    if(workOrderContactsMap.size()>0)
                    {
                        primaryContactName=workOrderContactsMap.get(workOrderVar.Client_Name__c).Name;
                        primaryContactEmailId=workOrderContactsMap.get(workOrderVar.Client_Name__c).Email;
                    }
                }
            }
            if(startDate!=null && endDate!=null)
            {
                projectStartDate =  DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('MM/dd/yyyy');
                projectend = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MM/dd/yyyy');
            }
            if(subCategoryVar.replaceAll('\\s','').toLowerCase().contains('fixedprice')){
                date workOrderEndDate=workOrderVar.Project_End_Date__c;
                List<Deliverables__c> deliverablesToFix = [ SELECT Id, End_Date__c FROM Deliverables__c WHERE Work_Order__c = :workOrderVar.Id AND End_Date__c > :workOrderEndDate ORDER by End_Date__c DESC LIMIT 1 ];
                
                if(!deliverablesToFix.isEmpty()) {
                    workOrderEndDate = deliverablesToFix[0].End_Date__c;
                    projectend = DateTime.newInstance(workOrderEndDate.year(),workOrderEndDate.month(),workOrderEndDate.day()).format('MM/dd/yyyy');
                }
            }
            if(workOrderVar.Consultant__r.Email==null)
            {
                if(subCategoryVar.toLowerCase().contains('subscription'))
                {
                    useremailId=System.Label.Tips_Subscription_UserEmailId;
                }
                else if(subCategoryVar.toLowerCase().contains('consumption'))
                {
                    useremailId=System.Label.Tips_Consumption_UserEmailId;
                }            
            }
            else
            {
                useremailId=workOrderVar.Consultant__r.Email;
            }
            string[] splitusername;
            string projectManager;
            string client_partner;
            List<account> accountList=[Select Backup_CSM__r.Email,User__c,User__r.Email,Client_Partner__c,Client_Partner__r.Email From Account WHERE ID=:workOrderVar.Client_Name__c limit 1];
            if(workOrderVar.Client_Partner__c!=null)
            {
                client_partner=workOrderVar.Client_Partner__r.Email;
            }
            if(accountList[0].User__c!=null){
                projectManager=accountList[0].User__r.Email;
            }
            else
            {
                projectManager=accountList[0].Backup_CSM__r.Email;
            }   
            string businessUnitValue=workOrderVar.Business_Unit__c;
            if (businessUnitValue != null && businessUnitValue.contains('DemandDynamics')) {
                businessUnitValue = businessUnitValue.replace('DemandDynamics', 'DD');
            }
            if (businessUnitValue != null && businessUnitValue.contains('Enterprise Integration')) {
                businessUnitValue = businessUnitValue.replace('Enterprise Integration', 'EI');
            }
            if (businessUnitValue != null && businessUnitValue.contains('Staffing')) {
                businessUnitValue = businessUnitValue.replace('Staffing', 'ST');
            }
            decimal grossMargin=workOrderVar.Initial_Gross_Margin__c;
            if(grossMargin==null){
                grossMargin=0;
            }
            string vbEmail=workOrderUsersMap.get(workOrderVar.VP__c);
            string accountPartnerEmail=workOrderUsersMap.get(workOrderVar.Account_Partner__c);  
            string deliveryPartner=string.isNotBlank(workOrderVar.Delivery_Partner__c)?workOrderVar.Delivery_Partner__r.Email:null;
            string billingTerm=workOrderVar.Payment_Terms_Projects__c=='Due on Reciept'?'DUEONRECEI':workOrderVar.Payment_Terms_Projects__c;
            String workOrderInputString ='{"Project_Code":"'+workOrderVar.Project_Code__c+'","Project_Name":"'+workOrderVar.Project_Name__c+'","MasterProject_Start_Dt":"'+projectStartDate+'","MasterProject_End_Dt":"'+projectend+'","Client_Name":"'+workOrderVar.Client_Name__r.Name+'","Contact_Name":"'+primaryContactName+'","Client_EmailId":"'+primaryContactEmailId+'","Client_Address":"'+workOrderVar.Client_Name__r.BillingStreet+'","Client_City":"'+workOrderVar.Client_Name__r.BillingCity+'","Client_State":"'+workOrderVar.Client_Name__r.BillingState+'","Client_ZipCode":"'+workOrderVar.Client_Name__r.BillingPostalCode+'","Client_Vertical":"'+System.Label.Account_Vertical_Picklist_Value+'","Client_SubCategory":"'+workOrderVar.Client_Name__r.Industry+'","SFClient_Id":"'+workOrderVar.Client_Name__r.Id+'","Work_Phone_Number":"'+workOrderVar.Client_Name__r.Phone+'","UserEmail_Id":"'+useremailId+'","Vendor_Name":"'+vendorName+'","Project_Start_Dt":"'+projectStartDate+'","Project_End_Dt":"'+projectend+'","Bill_Rate":"'+billrate+'","Timesheet_Freq":"'+workOrderVar.Billing_Frequency__c+'","AnnualSalary":"'+annualSalary+'","Peridium_Amount":"'+peridiumAmount+'","Business_Team_Name":"'+workOrderVar.Account_Manager_Name__r.Email+'","Base_Rate":"'+baseRate+'","LcaUpdateReq":"'+workOrderVar.LCA_Required__c+'","BusinessUnitType":"'+businessUnitValue+'","BusinessUnitCategory":"'+subCategoryVar+'","Min_BillHours":"'+miniumBillHours+'","BillRateType":"'+billratetype+'","GrossMargin":"'+grossMargin+'","Rep":"'+workOrderVar.Account_Manager_Name__r.Email+'","VP":"'+vbEmail+'","Account_Partner":"'+accountPartnerEmail+'","Execution_Partner":"'+workOrderVar.Execution_Partner__r.Email+'","Project_Manager":"'+projectManager+'","Billing_Terms":"'+billingTerm+'","PO_Number":"'+workOrderVar.PO_Number__c+'",';
            workOrderInputString=workOrderInputString+'"Account_Num":"'+workOrderVar.Client_Name__r.Client_Code__c+'","Client_Country":"'+workOrderVar.Client_Name__r.BillingCountry +'","CustomerType": "'+workOrderVar.Customer_Type__c+'","Delivery_Partner":"'+deliveryPartner+'","Subcampaign":"'+workOrderVar.Opportunity_Area__c+'","Client_Partner":"'+client_partner+'","Account_Type":"'+workOrderVar.Client_Name__r.Account_Type__c+'",';
            
            system.debug('workOrderInputString-'+workOrderInputString);
            system.debug('updateWorkOrderAPI-'+updateWorkOrderAPI);
            if(updateWorkOrderAPI)
            {
                If(!boolean.valueOf(system.label.BC_Integration)){
                    workOrderInputString = workOrderInputString +'"TipsWorkorder_Id":"'+workOrderVar.Tips_Work_Order_ID__c+'",';
                }else{
                    workOrderInputString = workOrderInputString +'"TipsWorkorder_Id":"'+workOrderVar.BC_Work_Order_ID__c+'",';   
                }
                
                Datetime effectiveDateTime = (Datetime)workOrderVar.Work_Order_Changes_Effective_Date__c; 
                String effectiveDate =workOrderVar.Work_Order_Changes_Effective_Date__c!=null?DateTime.newInstance(workOrderVar.Work_Order_Changes_Effective_Date__c.year(),workOrderVar.Work_Order_Changes_Effective_Date__c.month(),workOrderVar.Work_Order_Changes_Effective_Date__c.day()).format('MM/dd/yyyy'):'';
                system.debug('expiryDateWordOrderIds-- from sub'+expiryDateWordOrderIds);
                
                if(expiryDateWordOrderIds.contains(workOrderVar.Id))
                {
                    System.debug('effectiveDate'+effectiveDate);
                    workOrderInputString = workOrderInputString + '"Effective_Date":"'+effectiveDate+'",';
                }
                else
                {
                    System.debug('effectiveDate2');
                    workOrderInputString = workOrderInputString + '"Effective_Date":"",';
                }
                
                
            }
            system.debug('lstOfDeliverablesInfo 2:'+lstOfDeliverablesInfo);
            system.debug('subCategoryVar 2:'+subCategoryVar.replaceAll('\\s','').toLowerCase());
            if(lstOfmilestonesInfo.isEmpty() && !lstOfDeleteDeliverablesInfo.isEmpty() && subCategoryVar.replaceAll('\\s','').toLowerCase().contains('fixedprice')){
                milestoneInfo='"MileStoneDetail": ['; 
                for(Deliverables__c deliverableVar:lstOfDeleteDeliverablesInfo){
                    if(deliverableVar.Start_date__c !=null && deliverableVar.End_date__c!=null)
                    {
                        milestonestart =  DateTime.newInstance(deliverableVar.Start_date__c.year(),deliverableVar.Start_date__c.month(),deliverableVar.Start_date__c.day()).format('MM/dd/yyyy');
                        milestoneend = DateTime.newInstance(deliverableVar.End_date__c.year(),deliverableVar.End_date__c.month(),deliverableVar.End_date__c.day()).format('MM/dd/yyyy');
                    } 
                    string deliveryInfo='{"Deliverable_Name":"'+deliverableVar.Name+'","Description":"'+deliverableVar.Description__c+'","MileStone_StartDt":"'+milestonestart+'","MileStone_EndDt":"'+milestoneend+'","BillRate_Amt":"0","IsVoid":"true","SF_MilestoneId":"'+deliverableVar.Id+'"}';
                    milestoneInfo=milestoneInfo+deliveryInfo+',';  
                }
                milestoneInfo=milestoneInfo.removeEnd(',')+']';
                
            }
            if(lstOfDeliverablesInfo.size()>0 && subCategoryVar.replaceAll('\\s','').toLowerCase().contains('fixedprice'))
            {
                system.debug('Inside If:');
                for(Deliverables__c deliverableVar:lstOfDeliverablesInfo)
                {
                    if(deliverableVar.Work_Order__r.Id==workOrderVar.Id)
                    {
                        lstOfmilestonesInfo.add(deliverableVar);
                    }
                }
                system.debug('lstOfmilestonesInfo:'+lstOfmilestonesInfo);
                
                if(lstOfmilestonesInfo.size()>0)
                {
                    milestoneInfo='"MileStoneDetail": [';
                    for(Deliverables__c deliverableVar: lstOfmilestonesInfo)
                    {
                        if(deliverableVar.Start_date__c !=null && deliverableVar.End_date__c!=null)
                        {
                            milestonestart =  DateTime.newInstance(deliverableVar.Start_date__c.year(),deliverableVar.Start_date__c.month(),deliverableVar.Start_date__c.day()).format('MM/dd/yyyy');
                            milestoneend = DateTime.newInstance(deliverableVar.End_date__c.year(),deliverableVar.End_date__c.month(),deliverableVar.End_date__c.day()).format('MM/dd/yyyy');
                        } 
                        string deliveryInfo='{"Deliverable_Name":"'+deliverableVar.Name+'","Description":"'+deliverableVar.Description__c+'","MileStone_StartDt":"'+milestonestart+'","MileStone_EndDt":"'+milestoneend+'","BillRate_Amt":"'+deliverableVar.Amount__c+'","IsVoid":"0","SF_MilestoneId":"'+deliverableVar.Id+'"}';
                        milestoneInfo=milestoneInfo+deliveryInfo+',';
                    }
                    //For Deliverable records.
                    if(!lstOfDeleteDeliverablesInfo.isEmpty()){
                        for(Deliverables__c deliverableVar:lstOfDeleteDeliverablesInfo){
                            if(deliverableVar.Start_date__c !=null && deliverableVar.End_date__c!=null)
                            {
                                milestonestart =  DateTime.newInstance(deliverableVar.Start_date__c.year(),deliverableVar.Start_date__c.month(),deliverableVar.Start_date__c.day()).format('MM/dd/yyyy');
                                milestoneend = DateTime.newInstance(deliverableVar.End_date__c.year(),deliverableVar.End_date__c.month(),deliverableVar.End_date__c.day()).format('MM/dd/yyyy');
                            } 
                            string deliveryInfo='{"Deliverable_Name":"'+deliverableVar.Name+'","Description":"'+deliverableVar.Description__c+'","MileStone_StartDt":"'+milestonestart+'","MileStone_EndDt":"'+milestoneend+'","BillRate_Amt":"0","IsVoid":"true","SF_MilestoneId":"'+deliverableVar.Id+'"}';
                            milestoneInfo=milestoneInfo+deliveryInfo+',';  
                        }
                    }
                    milestoneInfo=milestoneInfo.removeEnd(',')+']';
                }
                system.debug('milestoneInfo------>'+milestoneInfo);         
            }
            else
            {
                if(lstOfDeleteDeliverablesInfo.isEmpty()){
                    milestoneInfo='"MileStoneDetail":""';
                }
            }
            List<WorkOrder_Line_Item__c> workOrderLineDetils=[SELECT Description__c,Id,Item_Master__c,Quantity__c,Rate__c,RecordType.Name,Unit_of_Measure__c,WorkOrder__c,Tax_Rate__c,Effective_Date__c,Deactivation_Date__c,
                                                              Description_2__c,Resource__c,Resource__r.Email
                                                              FROM WorkOrder_Line_Item__c WHERE WorkOrder__c=:workOrderVar.id Order By CreatedDate  ASC];
            string SKULineDetails;
            string subcat=subCategoryVar.replaceAll('\\s','').toLowerCase();
            if(!workOrderLineDetils.isEmpty() && (subcat.contains('licensefee') ||
                                                 subCategoryVar=='KPO -Consumption' || subCategoryVar=='KPO -Consumption-CO') ||
              subcat.contains('fixedunitprice') || subcat.contains('fixedpoints') || workOrderVar.Business_Unit__c=='Staffing'){
                SKULineDetails='"SKULineDetails": [';
                for(WorkOrder_Line_Item__c woli:workOrderLineDetils){
                   	string effectiveDate;
                    String deactivationDate;
                    if(woli.Effective_Date__c !=null){
                        effectiveDate =  DateTime.newInstance(woli.Effective_Date__c.year(),woli.Effective_Date__c.month(),woli.Effective_Date__c.day()).format('MM/dd/yyyy');
                    }
                    if(woli.Deactivation_Date__c !=null){
                        deactivationDate =  DateTime.newInstance(woli.Deactivation_Date__c.year(),woli.Deactivation_Date__c.month(),woli.Deactivation_Date__c.day()).format('MM/dd/yyyy');
                    }
                    String resourceAddress;
                    if(workOrderVar.Business_Unit__c=='Staffing' && String.isNotBlank(woli.Resource__c)){
                        resourceAddress=woli.Resource__r.Email;
                   }
                    decimal taxRate=woli.Tax_Rate__c!=null?woli.Tax_Rate__c:0;
                    string UOM=woli.Unit_of_Measure__c;
                    decimal rate=woli.Rate__c;
                    rate = rate.setScale(5, RoundingMode.HALF_UP);
                    string skuLine='{"SF_SKU_ID":"'+woli.Item_Master__c+'","Description":"'+woli.Description__c+'","Unit_of_Measure":"'+UOM+'","Quantity":"'+woli.Quantity__c+'","Unit_Price":"'+rate+'","Tax_Per":"'+taxRate+'","Deactivation_Date":"'+deactivationDate+'","Effective_Date":"'+effectiveDate+'","SF_WOLIID":"'+woli.Id+'","Type":"'+woli.RecordType.Name+'","Description2":"'+woli.Description_2__c+'","Resource_Email":"'+resourceAddress+'"}';
                    SKULineDetails=SKULineDetails+skuLine+',';  
                }
                  SKULineDetails=SKULineDetails.removeEnd(',')+']';
              }else{  
                  SKULineDetails='"SKULineDetails":""'; 
              }
            If(!boolean.valueOf(system.label.BC_Integration)){
                workOrderInputString=workOrderInputString+milestoneInfo+'}';
            }else{
                //workOrderInputString=workOrderInputString.replace('"TipsWorkorder_Id"', '"BCOrder_id"');
                workOrderInputString=workOrderInputString+milestoneInfo+','+SKULineDetails+',"LineDetail":""}';  
            }
            system.debug('workOrderInputString------>'+workOrderInputString);
            return workOrderInputString.replaceAll('null','');      
        }
        catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return'';
        }
    }
    
    public static string GenerateAuthorizationToken()
    {
        try{
            JWT jwt = new JWT('HS256');
            jwt.privateKey =System.Label.JWT_Private_Key;
            jwt.iss = System.Label.JWT_Issuer;
            jwt.aud =System.Label.JWT_Aud;
            jwt.subject = System.Label.JWT_Subject;
            jwt.audience = System.Label.JWT_Audience;
            string token = jwt.GetToken();  
            system.debug('token===='+token);
            return token;
        }
        catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return'';
        }
    }
    
    public static string AESEncryptDecrypt(String inputString)
    {
        try
        {
            system.debug('inputString------>'+inputString);        
            Blob key=Blob.valueOf(System.Label.AES_Key);
            system.debug('key------>'+key);
            Blob data = Blob.valueOf(inputString);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128',key, data);
            JWT jwt = new JWT('HS256');
            string encrypted=EncodingUtil.base64Encode(encryptedData);
            system.debug('encryptedData------>'+encrypted);
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encryptedData);
            String decryptedString = decrypted.toString();
            system.debug('decryptedData------>'+decryptedString);	
            return encrypted;
        }
        catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return'';
        }
    }
    
    public static String GetInputStringConsumption(Work_Order__c workOrderVar,string subcatgory,boolean customerType,string billType)
    {
        try{ 
            List<Deliverables__c> lstOfmilestonesInfo=new List<Deliverables__c>();
            Date startDate=newProjectStartDate!=null?newProjectStartDate:workOrderVar.Project_Start_Date__c;
            Date endDate=workOrderVar.Project_End_Date__c;
            
            string tipsConsumptionWoID='';
            string subCategoryVar=subcatgory;
            
            string SubscriptionFrequency=workOrderVar.Subscription_Fee_Frequency__c;
            system.debug('subCategoryVar -->'+subCategoryVar);
            String projectStartDate='';String projectend='';String milestonestart=''; String milestoneend='';string useremailId='';
            string primaryContactName='';string primaryContactEmailId='';
            
            string vendorName=workOrderVar.Vendor__r.Name==null?System.Label.Vendor_Default_Value:workOrderVar.Vendor__r.Name;
            string annualSalary=workOrderVar.Annual_Salary__c==null?'0':String.valueOf(workOrderVar.Annual_Salary__c);
            string peridiumAmount=workOrderVar.PERDIEM__c==null?'0':String.valueOf(workOrderVar.PERDIEM__c);
            string baseRate=workOrderVar.PayRate_t_M__c==null?'0':String.valueOf(workOrderVar.PayRate_t_M__c);
            string miniumBillHours=workOrderVar.Minumim_Billable_Hours_Per_Month__c==null?'0':String.valueOf(workOrderVar.Minumim_Billable_Hours_Per_Month__c);
            string milestoneInfo='';
            Decimal billrate=0.0;
            string billratetype='';
            boolean isBCIntegration=Boolean.valueOf(System.Label.BC_Integration);
            if(billType=='Build'){
                tipsConsumptionWoID=workOrderVar.TIPS_CNSMP_WO_ID__c;
                billratetype='Hourly';
                billrate=workOrderVar.Bill_Rate__c;
            }
            
            if(customerType){
                if(billType=='Admin'){
                    tipsConsumptionWoID=workOrderVar.TIPS_Admin_CNSMP_WO_ID__c; 
                    billratetype='Admin';
                    billrate=workOrderVar.Admin_Hourly_Rate__c;
                    
                }
                if(billType=='Consulting'){
                    tipsConsumptionWoID= workOrderVar.TIPS_Consulting_CNSMP_WO_ID__c ;
                    billratetype='Consult';
                    billrate=workOrderVar.Consulting_Hourly_Rate__c;
                }
            }
            billrate=billrate.setScale(2);
            system.debug('billrate-'+billrate);
            if(workOrderVar.Contact_to_Send_the_Invoice__c!=null||workOrderVar.Contact_for_Payment_followUp__c!=null)
            {
                if(workOrderVar.Contact_to_Send_the_Invoice__c!=null)
                {
                    primaryContactName=workOrderVar.Contact_to_Send_the_Invoice__r.Name;
                    primaryContactEmailId=workOrderVar.Contact_to_Send_the_Invoice__r.Email;
                }
                else if(workOrderVar.Contact_for_Payment_followUp__c!=null && workOrderVar.Same_as_the_Invoice_Contact__c ==true)
                {
                    primaryContactName=workOrderVar.Contact_for_Payment_followUp__r.Name;
                    primaryContactEmailId=workOrderVar.Contact_for_Payment_followUp__r.Email;
                }
            }
            else
            {
                if(workOrderVar.Client_Name__r.Primary_Customer_Contact__c!=null)
                {
                    primaryContactName=workOrderVar.Client_Name__r.Primary_contact_name__c;
                    primaryContactEmailId=workOrderVar.Client_Name__r.Primary_Customer_Email_Id__c;
                }
                else
                {
                    if(workOrderContactsMap.size()>0)
                    {
                        primaryContactName=workOrderContactsMap.get(workOrderVar.Client_Name__c).Name;
                        primaryContactEmailId=workOrderContactsMap.get(workOrderVar.Client_Name__c).Email;
                    }
                }
            }
            if(startDate!=null && endDate!=null)
            {
                projectStartDate =  DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('MM/dd/yyyy');
                projectend = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MM/dd/yyyy');
            }
            if(workOrderVar.Consultant__r.Email==null)
            {
                useremailId=System.Label.Tips_Consumption_UserEmailId;
            }
            else
            {
                useremailId=workOrderVar.Consultant__r.Email;
            }
            
            string[] splitusername;
            string projectManager;
            string client_partner;
            List<account> accountList=[Select Backup_CSM__r.Email,User__c,User__r.Email,Client_Partner__c,Client_Partner__r.Email From Account WHERE ID=:workOrderVar.Client_Name__c limit 1];
             if(workOrderVar.Client_Partner__c!=null)
            {
                client_partner=workOrderVar.Client_Partner__r.Email;
            }
            
            if(accountList[0].User__c!=null){
                projectManager=accountList[0].User__r.Email;
            }
            else
            {
                projectManager=accountList[0].Backup_CSM__r.Email;
            }   
            
            string businessUnitValue=workOrderVar.Business_Unit__c;
            if (businessUnitValue != null && businessUnitValue.contains('DemandDynamics')) {
                businessUnitValue = businessUnitValue.replace('DemandDynamics', 'DD');
            }
            if (businessUnitValue != null && businessUnitValue.contains('Enterprise Integration')) {
                businessUnitValue = businessUnitValue.replace('Enterprise Integration', 'EI');
            }
            if (businessUnitValue != null && businessUnitValue.contains('Staffing')) {
                businessUnitValue = businessUnitValue.replace('Staffing', 'ST');
            }
            system.debug('workOrderUsersMap-'+workOrderUsersMap);
            string vbEmail=workOrderUsersMap.get(workOrderVar.VP__c);
            string accountPartnerEmail=workOrderUsersMap.get(workOrderVar.Account_Partner__c);  
            string deliveryPartner=string.isNotBlank(workOrderVar.Delivery_Partner__c)?workOrderVar.Delivery_Partner__r.Email:null;
            decimal grossMargin=workOrderVar.Initial_Gross_Margin__c;
            if(grossMargin==null){
                grossMargin=0;
            }
            string billingTerm=workOrderVar.Payment_Terms_Projects__c=='Due on Reciept'?'DUEONRECEI':workOrderVar.Payment_Terms_Projects__c;
            String workOrderInputString ='{"Project_Code":"'+workOrderVar.Project_Code__c+'","Project_Name":"'+workOrderVar.Project_Name__c+'","Description":"'+workOrderVar.Description__c+'","MasterProject_Start_Dt":"'+projectStartDate+'","MasterProject_End_Dt":"'+projectend+'","Client_Name":"'+workOrderVar.Client_Name__r.Name+'","Contact_Name":"'+primaryContactName+'","Client_EmailId":"'+primaryContactEmailId+'","Client_Address":"'+workOrderVar.Client_Name__r.BillingStreet+'","Client_City":"'+workOrderVar.Client_Name__r.BillingCity+'","Client_State":"'+workOrderVar.Client_Name__r.BillingState+'","Client_ZipCode":"'+workOrderVar.Client_Name__r.BillingPostalCode+'","Client_Vertical":"'+System.Label.Account_Vertical_Picklist_Value+'","Client_SubCategory":"'+workOrderVar.Client_Name__r.Industry+'","SFClient_Id":"'+workOrderVar.Client_Name__r.Id+'","Work_Phone_Number":"'+workOrderVar.Client_Name__r.Phone+'","UserEmail_Id":"'+useremailId+'","Vendor_Name":"'+vendorName+'","Project_Start_Dt":"'+projectStartDate+'","Project_End_Dt":"'+projectend+'","Bill_Rate":"'+billrate+'","Timesheet_Freq":"'+workOrderVar.Billing_Frequency__c+'","AnnualSalary":"'+annualSalary+'","Peridium_Amount":"'+peridiumAmount+'","Business_Team_Name":"'+workOrderVar.Account_Manager_Name__r.Email+'","Base_Rate":"'+baseRate+'","LcaUpdateReq":"'+workOrderVar.LCA_Required__c+'","BusinessUnitType":"'+businessUnitValue+'","BusinessUnitCategory":"'+subCategoryVar+'","Min_BillHours":"'+miniumBillHours+'","BillRateType":"'+billratetype+'","GrossMargin":"'+grossMargin+'","Rep":"'+workOrderVar.Account_Manager_Name__r.Email+'","VP":"'+vbEmail+'","Account_Partner":"'+accountPartnerEmail+'","Execution_Partner":"'+workOrderVar.Execution_Partner__r.Email+'","Project_Manager":"'+projectManager+'","Billing_Terms":"'+billingTerm+'","PO_Number":"'+workOrderVar.PO_Number__c+'",';
            workOrderInputString=workOrderInputString+'"Account_Num":"'+workOrderVar.Client_Name__r.Client_Code__c+'","Client_Country":"'+workOrderVar.Client_Name__r.BillingCountry +'","CustomerType": "'+workOrderVar.Customer_Type__c+'","Delivery_Partner":"'+deliveryPartner+'","Subcampaign":"'+workOrderVar.Opportunity_Area__c+'","Client_Partner":"'+client_partner+'","Account_Type":"'+workOrderVar.Client_Name__r.Account_Type__c+'",';
            system.debug('updateWorkOrderAPI-'+updateWorkOrderAPI);
            if(updateWorkOrderAPI)
            {
                If(!boolean.valueOf(system.label.BC_Integration)){
                    workOrderInputString = workOrderInputString + '"TipsWorkorder_Id":"'+tipsConsumptionWoID+'",';
                }
                
                Datetime effectiveDateTime = (Datetime)workOrderVar.Work_Order_Changes_Effective_Date__c; 
                String effectiveDate =workOrderVar.Work_Order_Changes_Effective_Date__c!=null?DateTime.newInstance(workOrderVar.Work_Order_Changes_Effective_Date__c.year(),workOrderVar.Work_Order_Changes_Effective_Date__c.month(),workOrderVar.Work_Order_Changes_Effective_Date__c.day()).format('MM/dd/yyyy'):'';
                system.debug(billType+'--expiryDateWordOrderIds-- from Cons'+expiryDateWordOrderIds);
                If(!boolean.valueOf(system.label.BC_Integration)){
                    if(expiryDateWordOrderIds.contains(workOrderVar.Id) && billType=='Build')
                    {
                        workOrderInputString = workOrderInputString + '"Effective_Date":"'+effectiveDate+'",';
                    }else if(expiryDateWordOrderIdsAdmin.contains(workOrderVar.Id) && billType=='Admin'){
                        workOrderInputString = workOrderInputString + '"Effective_Date":"'+effectiveDate+'",';
                    }else if(expiryDateWordOrderIdsConsulting.contains(workOrderVar.Id) && billType=='Consulting'){
                        workOrderInputString = workOrderInputString + '"Effective_Date":"'+effectiveDate+'",';
                    }else
                    {
                        workOrderInputString = workOrderInputString + '"Effective_Date":"",';
                    }
                }else{
                    if((expiryDateWordOrderIds.contains(workOrderVar.Id) && buildAPI) || (expiryDateWordOrderIdsAdmin.contains(workOrderVar.Id) && adminAPI)
                       || (expiryDateWordOrderIdsConsulting.contains(workOrderVar.Id) && consultingAPI))
                    {
                        workOrderInputString = workOrderInputString + '"Effective_Date":"'+effectiveDate+'",';
                    }else
                    {
                        workOrderInputString = workOrderInputString + '"Effective_Date":"",';
                    }  
                }
            }
            
            milestoneInfo='"MileStoneDetail":""';
            If(!boolean.valueOf(system.label.BC_Integration)){
                workOrderInputString=workOrderInputString+milestoneInfo+'}';
            }else{
                Boolean isCustomerType=false;
                system.debug('workOrderVar.Customer_Type__c--'+workOrderVar.Customer_Type__c);
                if(workOrderVar.Customer_Type__c=='ABC Type'){
                    isCustomerType=true;
                }
                system.debug('buildAPI-'+buildAPI);
                system.debug('adminAPI-'+adminAPI);
                system.debug('consultingAPI-'+consultingAPI);
                string lineDetails=','+ODS_WorkOrder_BC_API_Helper.getLineDetailsJson(workOrderVar,updateWorkOrderAPI,isCustomerType,buildAPI,adminAPI,consultingAPI);
                workOrderInputString=workOrderInputString+milestoneInfo+lineDetails+'}';
            }
            system.debug('workOrderInputString------>'+workOrderInputString);
            return workOrderInputString.replaceAll('null','');      
        }
        catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return e.getMessage()+ ' at ' +e.getLineNumber();
        }
    }
    public static void sendMailWorkorderFailure(Id workOrderId, String TipsApiMessage){
        List<string> sendTo1 = System.Label.WorkOrderUsersForErrorStatus.Split(',');
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setSubject('TIPS Work order Integration failed for the work order record: ' + workOrderId);
        semail.setToAddresses(sendTo1);
        String strHtmlBody = '';                     
        strHtmlBody= 'Hi, <br/> TIPS Work order integration for the SFDC work order id : <b> '+ workOrderId + '</b> has been failed because of the below. Please update it accordingly. <br/> <br/> TIPS API Message  : <b>'+ TipsApiMessage + '</b>';
        semail.setHtmlBody(strHtmlBody);
        system.debug('strHtmlBody-'+strHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
    }
    
}