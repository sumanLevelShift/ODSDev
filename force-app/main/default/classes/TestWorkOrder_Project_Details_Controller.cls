@isTest 
public class TestWorkOrder_Project_Details_Controller {
    
    public static testMethod void testWorkOrderDetails(){
        User userId = [SELECT Id FROM User WHERE Name = 'Zeeshan Armar' and IsActive=true LIMIT 1];        
        User userId1 = [SELECT Id FROM User WHERE Name = 'Selva Pandian' and IsActive=true LIMIT 1]; 
        
        Account accountObject = new Account(
            Name ='DemandBlue TestClient',// Account Name
            Lead_Gen_Name__c = 'Others',             
            Industry = 'Hospitality',
            Backup_CSM__c=userId1.Id
        );
        insert accountObject;
        Work_Order__c  workorderObject= new Work_Order__c(
            Client_Name__c=accountObject.Id,
            Project_Start_Date__c=system.today().addDays(5),
            Project_End_Date__c=system.today().addDays(15),
            Account_Manager_Name__c=userId.Id,
            SubCategory__c='DemandBlue-Subscription',
            Pay_Rate__c=85,
            Billing_Frequency__c='Monthly',
            Account_Partner__c='Selva Pandian',
            Bill_Rate__c =120000,
            Annual_Salary__c=25000,
            PERDIEM__c=920,
            Business_Unit__c='DemandBlue',
            Project_Name__c='TestProject',
            LCA_Required__c=false,
            Minumim_Billable_Hours_Per_Month__c=8,
            Bill_Rate_Type__c='One Time',
            Initial_Gross_Margin__c=77.8,
            Payment_Terms_Projects__c='Net 30',
            PO_Number__c='4578',
            Execution_Partner__c=userId1.Id,
            Project_Code__c='DEMANDSF',
            OwnerId=userId1.Id
        );
        
        insert workorderObject;
        
        Test.startTest();
        PageReference pageRef = Page.WorkOrder_Project_Details;
        pageRef.getParameters().put('id', String.valueOf(workorderObject.Id));
        Test.setCurrentPage(pageRef);
        try{
            ApexPages.StandardController sc = new ApexPages.StandardController(workorderObject);
            WorkOrder_Project_Details_Controller workOrderProj=new WorkOrder_Project_Details_Controller(sc);           
            workOrderProj.UpdateProjectCode();
        }
        catch(Exception error)
        {
            system.debug(error);
        }
        Test.stopTest();
    } 
    
}