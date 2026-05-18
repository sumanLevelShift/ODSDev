public class WorkOrder_Project_Details_Controller {
    public Work_Order__c workOrderObj {get;set;}
    public string projectstart{get;set;}
    public string projectend{get;set;}
    Public string projectCode{get;set;}
    Public string vendorName{get;set;}
    Public boolean IsShow{get;set;}
    public WorkOrder_Project_Details_Controller(ApexPages.StandardController sc) {
        String WorkOrderId = ApexPages.currentPage().getParameters().get('id');
        workOrderObj = [SELECT Vendor__r.name,Name,Work_Order_Category__c,Work_Order_Status__c,Account_CSM__c,Account_Manager_Name__r.name,Account_Partner__c,Execution_Partner__r.name,Business_Unit__c,SubCategory__c,Bill_Rate__c,Bill_Rate_Type__c,Billing_Frequency__c,Minumim_Billable_Hours_Per_Month__c,Initial_Gross_Margin__c,Payment_Terms_Projects__c,LCA_Required_Formula__c,Contact_to_Send_the_Invoice__r.name,Project_Code__c,Client_Name__r.Name,Project_Start_Date__c,Project_End_Date__c,Project_Name__c FROM Work_Order__c WHERE Id =:WorkOrderId limit 1];
        projectstart =  DateTime.newInstance(workOrderObj.Project_Start_Date__c.year(),workOrderObj.Project_Start_Date__c.month(),workOrderObj.Project_Start_Date__c.day()).format('MM/dd/YYYY');
        projectend = DateTime.newInstance(workOrderObj.Project_End_Date__c.year(),workOrderObj.Project_End_Date__c.month(),workOrderObj.Project_End_Date__c.day()).format('MM/dd/YYYY');
        vendorName=workOrderObj.Vendor__r.Name==null?'Prelude Systems Inc':workOrderObj.Vendor__r.Name;
        IsShow=String.isNotBlank(workOrderObj.Project_Code__c)?true:false;
    }
    
    public void UpdateProjectCode()
    {
        try{
            system.debug('project code'+projectCode);
            
           // update work order
            workOrderObj.Project_Code__c=projectCode;
            update workOrderObj;
            IsShow=String.isNotBlank(workOrderObj.Project_Code__c)?true:false;
            projectCode='';
            string baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+workOrderObj.Id;
            //sent email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toEmail = new List<String>();
            List<String> ccEmail = new List<String>();  
            toEmail.add(System.Label.Finance_MailID);
            mail.setToAddresses(toEmail);
            mail.setSubject(System.Label.WorkOrder_Mail_Subject);
  
            String body='<html><body>Hi Team,<br/><br/>Work order project code has been updated successfully.<br/><br/>Work Order link: <a href="'+baseUrl+'"><b>'+workOrderObj.Name+'</b></a><br/><br/>Regards,<br/>PreludeSys Support</body> </html>';            
            mail.setHtmlBody(body);
            system.debug('body====>'+mail);
            Messaging.SendEmailResult[] er = Messaging.SendEmail(new Messaging.SingleEmailMessage[]{mail});
            
             system.debug('message====>'+er);
            
        }
        catch(Exception e)    
        {
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    }
}