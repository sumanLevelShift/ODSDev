/*******************************************************************************************
* @author           VinothKannan
* @version          1.0 
* @Status           Development Completed
* @Class Name       WorkOrderUtility
* @description      This class is written to Create the workorder for 'ODS' recordType. 
*					This class is invoked from 'ODS_Generate Work Order Email V1.3' Process builder 
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	30 APR 2020    	VinothKannan 	Initial Development
*********************************************************************************************/
public with sharing class WorkOrderUtility {
	//This method is invoked from 'ODS_Generate Work Order Email V1.3' Process builder 
  	@InvocableMethod
    public static void CreateODSWorkOrderRecord(List<Id> AccountId)
    {
        System.debug('$$$ CreateODSWorkOrderRecord method Invoked');
        CreateWorkOrder(AccountId);
    }
    
    //Get the Account record based on the ID
    public static List<Account> getAccountRecord(List<Id> AccountId)
    {
        if(AccountId != null)
        {
            return [SELECT Id,Name,Customer_Engagement_Type__c,InvoiceContact__r.Id,Owner.id,Owner.Name,Owner.Email,ODS_Hourly_Rate__c,
                    			Invoice_Frequency__c,Subscription_Fee_terms__c,Contract_Terms__c,Minimum_billable_hours__c,
                    			SOW_Status_Date__c,Invoice_Type__c FROM Account WHERE Id in :AccountId];
        }
        else
        { return null; }
    }
   
    //Create the ODS workorder based on Account record ID
    public static void CreateWorkOrder(List<Id> AccountId)
    {
        String accountManagerEmail ='';
        try{ 
       		ODS_WorkOrderSettings__c WorkOrderSettings = ODS_WorkOrderSettings__c.getValues('SFDC');
            List<Account> parentAccountRecords = getAccountRecord(AccountId);
            Id ODSrecordTypeId = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get('WorkOrder').getRecordTypeId();
            
            if(parentAccountRecords != null)
            {
                for(Account parentAccountRecord : parentAccountRecords){
                    try{
               		Work_Order__c newWorkOrder = new Work_Order__c();                  
                    newWorkOrder.Account_Manager_Name__c = '00540000000oCwC';//ID testAccountId = '00540000000oCwC';	
                    accountManagerEmail = parentAccountRecord.Owner.Email;
                    newWorkOrder.Account_Partner__c = WorkOrderSettings.Account_Partner_Name__c; 
                    newWorkOrder.Execution_Partner__c = WorkOrderSettings.Execution_Partner_Id__c; //ID testId = '00540000001Z4T6';                              
                    newWorkOrder.Work_Order_Category__c = WorkOrderSettings.Work_Order_Category__c; //'New WorkOrder';                       
                    newWorkOrder.RecordTypeId = ODSrecordTypeId;
                    newWorkOrder.Solution_Architect_Engineer__c ='None';    
                    newWorkOrder.Project_Type__c = parentAccountRecord.Customer_Engagement_Type__c == 'ODS' ? 
                                                        parentAccountRecord.Customer_Engagement_Type__c : null;
                    newWorkOrder.Project_Sub_Category__c = 'ODS'; // WorkOrderSettings.Project_Sub_Category__c;
                    newWorkOrder.Project_Name__c = parentAccountRecord.Name;
                    newWorkOrder.Client_Name__c = parentAccountRecord.Id;                        
                    newWorkOrder.Bill_Rate__c = parentAccountRecord.ODS_Hourly_Rate__c;   
                    newWorkOrder.Billing_Frequency__c = parentAccountRecord.Invoice_Frequency__c;
                    //subsription fees
                    newWorkOrder.Subscription_Fee_Frequency__c = parentAccountRecord.Subscription_Fee_terms__c;
                    newWorkOrder.Minumim_Billable_Hours_Per_Month__c = parentAccountRecord.Minimum_billable_hours__c;
                    newWorkOrder.Payment_Terms__c = parentAccountRecord.Contract_Terms__c;
                    newWorkOrder.Project_Start_Date__c = parentAccountRecord.SOW_Status_Date__c;
                    newWorkOrder.Project_End_Date__c = parentAccountRecord.SOW_Status_Date__c;
                    newWorkOrder.LCA_Required__c = WorkOrderSettings.LCA_Required__c;
                    newWorkOrder.Invoice_Submission_Mode__c = parentAccountRecord.Invoice_Type__c;
                    newWorkOrder.Contact_to_Send_the_Invoice__c = parentAccountRecord.InvoiceContact__r.Id;
                    newWorkOrder.Work_Order_Status__c = 'Submitted';
                    newWorkOrder.WO_from_Account__c=True;
                    
                    Insert newWorkOrder;
                    }
        			catch(Exception wOException){
       					System.debug(wOException);
            			string emailBody = '<table><tr><td>Account Name: </td><td>'+parentAccountRecord.Name+'</td></tr>'+
                                            '<tr><td>Account Manager Name: </td><td>'+parentAccountRecord.Owner.Name+'</td></tr>'+
                                            '<tr><td>Execution Partner: </td><td>'+WorkOrderSettings.Execution_Partner_Id__c+'</td></tr></table>';
            			sendEmail(accountManagerEmail,wOException.getMessage(),emailBody); //accountManagerEmail
        			}
               	}
        	} 
     	}
        catch(Exception wOException){
       		System.debug(wOException);
            sendEmail(accountManagerEmail,wOException.getMessage(),' ');//accountManagerEmail
        }
    }
    
    //To Send the Exception email
    public static void sendEmail(String ToEmailAddress,String EmailMessage,String EmailBody)
    { 
        try{
          	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
            String[] toAddresses = new String[] {ToEmailAddress};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('LevelShift Workorder');
            mail.setSubject('Exception in "ODS" work order creation');
            mail.setHtmlBody('Hello, <br/><br/>This is the Exception mail While creating the "ODS" work order. <br/>The Exception message::: '+ EmailMessage +'<br/>'+EmailBody+'<br/><br/>Regards<br/> LevelShift');
            //String mailBody = ''+ msg;
            //mail.setPlainTextBody(mailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
        Catch(Exception mailException)
        {
            System.debug('mailException::::' + mailException);
        }
    }
}