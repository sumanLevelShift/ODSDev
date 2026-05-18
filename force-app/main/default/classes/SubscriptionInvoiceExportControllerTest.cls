@isTest
public class SubscriptionInvoiceExportControllerTest {
    public static testMethod void testWorkOrderDetails(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            
            UserRole testRole = [SELECT Id FROM UserRole WHERE Name = 'Vice President Sales'];
            User testUser = new User(
                Username = 'testuser@example.comVPS',
                FirstName = 'Test',
                LastName = 'User',
                Email = 'testuser@example.com',
                Alias = 'testusr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = UserInfo.getProfileId(),
                LanguageLocaleKey = 'en_US',
                UserRoleId = testRole.Id
            );
            insert testUser;
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accountObject = new Account(
                Name ='Demand Blue',// Account Name
                Lead_Gen_Name__c = 'Others',             
                Industry = 'Hospitality',
                Project_Code__c ='GHT',
                Customer_Type__c= 'ABC Type'
            );
            insert accountObject;
            
            Contact contactObject = new Contact(
                FirstName ='test',
                LastName='c',
                isPrimary__c=true,
                Email='test@gmail.com',
                AccountId=accountObject.Id,
                Lead_Gen_Name__c = 'Others'
            );
            insert contactObject;
            
            Work_Order__c workorderObject= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Account_CSM__c ='Arun  Govindan',
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(150),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
                Bill_Rate__c =12000,
                Annual_Salary__c=25000,
                PERDIEM__c=920,
                Business_Unit__c='DemandBlue',
                Project_Name__c='TestProject',
                LCA_Required__c=false,
                Minumim_Billable_Hours_Per_Month__c=8,
                Bill_Rate_Type__c='One Time',
                Initial_Gross_Margin__c=77.8,
                Payment_Terms_Projects__c='Net 30',
                Project_Code__c='TESTSFPPRJ',
                Subscription_Fee_Exceptions__c ='test',
                Subscription_Fee_Terms__c='test2',
                Subscription_Fee__c = 300,
                PO_Number__c='4578',
                Subscription_Fee_Frequency__c='Monthly'
            );
            insert workorderObject;
            
            Work_Order__c workorderObject1= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Account_CSM__c ='Arun  Govindan',
                Project_Start_Date__c=system.today().addDays(1),
                Project_End_Date__c=system.today().addDays(100),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription-co',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
                Bill_Rate__c =12000,
                Annual_Salary__c=25000,
                PERDIEM__c=920,
                Business_Unit__c='DemandBlue',
                Project_Name__c='TestProject1',
                LCA_Required__c=false,
                Minumim_Billable_Hours_Per_Month__c=8,
                Bill_Rate_Type__c='One Time',
                Initial_Gross_Margin__c=77.8,
                Payment_Terms_Projects__c='Net 30',
                PO_Number__c='6352',
                Project_Code__c='nullSFPPRJ',
                Subscription_Fee_Exceptions__c ='test',
                Subscription_Fee_Terms__c='test2',
                Subscription_Fee__c = 300,
                Subscription_Fee_Frequency__c='Annually'
                
            );
            
            insert workorderObject1;
            System.runAs (testUser ) 
            {                 
                Test.startTest();
                PageReference pageRef = Page.SubscriptionInvoiceExcel;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('selectedYear','2023-2024');
                Test.StopTest();
                SubscriptionInvoiceExportController custContrlr = new SubscriptionInvoiceExportController(); 
                SubscriptionInvoiceExportController.getTableLabels();
                custContrlr.GetSubscriptionExport();
                // Assert the expected results
                System.assertEquals('TestProject', workorderObject.Project_Name__c, 'TestProject');
                System.assertEquals('TestProject1', workorderObject1.Project_Name__c, 'TestProject1');
                
                
            } 
        }
    }
}