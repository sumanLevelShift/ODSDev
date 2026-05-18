/*******************************************************************************************
* @author           Sai Abishek
* @version          1.0 
* @Status           Development Completed
* @Class Name       WorkOrderUtilityTest
* @description      This is a test class for WorkOrderUtility. 
*					 
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	08 MAY 2020    	VinothKannan 	Initial Development
*********************************************************************************************/
@isTest(SeeAllData=true) 
public class WorkOrderUtilityTest {
  static testMethod void getAccount() {
      List<id>AccountList=new List<id>();
        Account newaccount = new Account();
        newaccount.Name='Test Account WorkOrder';
        newaccount.Customer_Engagement_Type__c='ODS';
        newaccount.ODS_Hourly_Rate__c=100.00;
        newaccount.Invoice_Frequency__c='Weekly';
        newaccount.Subscription_Fee_terms__c='Monthly';
        newaccount.Contract_Terms__c='Net 30';
      newaccount.Lead_Gen_Name__c ='David' ;
        newaccount.Minimum_billable_hours__c=100.00;
        newaccount.SOW_Status_Date__c=Date.newInstance(2012,12,09);
        newaccount.Invoice_Type__c='Digital';
        insert newaccount;
        AccountList.add(newaccount.Id);
      
      ODS_WorkOrderSettings__c WorkOrderSettings = New ODS_WorkOrderSettings__c();
        WorkOrderSettings.Name ='SFDC Work';
        WorkOrderSettings.Account_Partner_Name__c='Selva Pandian';
        WorkOrderSettings.Execution_Partner_Id__c='00540000001Z4T6';
        WorkOrderSettings.Work_Order_Category__c='New Work Order'; 
        WorkOrderSettings.Project_Sub_Category__c='ODS';
        WorkOrderSettings.LCA_Required__c=true;
        insert WorkOrderSettings;
    
       Id ODSrecordTypeId = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get('WorkOrder').getRecordTypeId();

      system.debug('test-->'+ODSrecordTypeId);
       Work_Order__c workorder=new Work_Order__c();
       workorder.RecordTypeId=ODSrecordTypeId;
       workorder.Account_Manager_Name__c=newaccount.owner.Id;
       workorder.Project_Type__c= newaccount.Customer_Engagement_Type__c;
       workorder.Project_Sub_Category__c=WorkOrderSettings.Project_Sub_Category__c;
       workorder.Project_Name__c= newaccount.Name;
       workorder.Client_Name__c=newaccount.Id;
       workorder.Bill_Rate__c=newaccount.ODS_Hourly_Rate__c;
       workorder.Billing_Frequency__c=newaccount.Invoice_Frequency__c;
       workorder.Subscription_Fee_Frequency__c=newaccount.Subscription_Fee_terms__c;
       workorder.Minumim_Billable_Hours_Per_Month__c=newaccount.Minimum_billable_hours__c;
       workorder.Payment_Terms__c=newaccount.Contract_Terms__c;
       workorder.Project_Start_Date__c=newaccount.SOW_Status_Date__c;
       workorder.Project_End_Date__c=newaccount.SOW_Status_Date__c;
       workorder.Invoice_Submission_Mode__c= newaccount.Invoice_Type__c;
       workorder.Contact_to_Send_the_Invoice__c=newaccount.InvoiceContact__c;
       workorder.Account_Partner__c=WorkOrderSettings.Account_Partner_Name__c;
       //workorder.Execution_Partner__c=WorkOrderSettings.Execution_Partner_Id__c;
            //workorder.Execution_Partner__c ='00540000001Z4T6';
       workorder.Work_Order_Category__c=WorkOrderSettings.Work_Order_Category__c;
       workorder.LCA_Required__c=WorkOrderSettings.LCA_Required__c;
      workorder.Business_Unit__c= 'DemandBlue';
      workorder.SubCategory__c= 'DemandBlue-Consumption';
       workorder.Solution_Architect_Engineer__c='None';
       insert workorder;
     
    WorkOrderUtility.CreateODSWorkOrderRecord(AccountList);
    WorkOrderUtility.CreateWorkOrder(AccountList);
    WorkOrderUtility.getAccountRecord(AccountList);
    WorkOrderUtility.sendEmail('test@demandblue.com','Exception Email','An Error occurred while creating a workorder from account') ;
       
}
    
        
       
}