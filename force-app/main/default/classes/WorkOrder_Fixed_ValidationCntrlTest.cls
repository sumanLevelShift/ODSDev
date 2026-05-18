@isTest
public class WorkOrder_Fixed_ValidationCntrlTest {
    
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
            set<Id> WorkOderIds=new set<Id>();
            set<Id> WorkOrderOwnerIds = new set<Id>();
            Map<Id,Work_Order__c> workdOrderOldMap=new Map<Id,Work_Order__c>();
            String Token='';
            
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accountObject = new Account(
                Name ='Demand Blue CLient1',// Account Name
                Lead_Gen_Name__c = 'Others',             
                Industry = 'Hospitality',
                Project_Code__c ='GHT',
                Customer_Type__c= 'ABC Type'
            );
            insert accountObject;
            
            Contact contactObject = new Contact(
                FirstName ='sathya',
                LastName='c',
                isPrimary__c=true,
                Email='sathya_c@preludesys.com',
                AccountId=accountObject.Id,
                Lead_Gen_Name__c = 'Others'
            );
            insert contactObject;
            
            Work_Order__c workorderObject= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Fixed Price',
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
                PO_Number__c='4578',
                Subscription_Fee_Frequency__c='Monthly'
                // OwnerId=userId1.Id
            );
            
            insert workorderObject;
            Deliverables__c deliverable1=new Deliverables__c();
            deliverable1.Name='deliverable1';
            deliverable1.Amount__c=120000;
            deliverable1.Description__c='Test 1';
            deliverable1.Start_date__c=system.today();
            deliverable1.End_date__c=system.today().addDays(15);
            deliverable1.Work_Order__c=workorderObject.Id;
            insert deliverable1;
            PageReference pageRef = Page.WorkOrder_Fixed_Validation;
            pageRef.getParameters().put('id', workorderObject.Id);
            Test.setCurrentPage(pageRef);
        
            ApexPages.StandardController sc = new ApexPages.StandardController(workorderObject);
            WorkOrder_Fixed_Validation_Controller controller = new WorkOrder_Fixed_Validation_Controller(sc);
            
        }
    }
}