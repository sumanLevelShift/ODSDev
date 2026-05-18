@isTest 
public class WorkOrder_API_Calls_Test {
    
    public static Account accountObject{set;get;}
    public static User userId {set;get;}
    public static Work_Order__c workorderObject{set;get;}
    public static Work_Order__c workorderObject1{set;get;}
        public static testMethod void updateWorkOrderV1(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            
            UserRole testRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Vice_President_Sales'];
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
            
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accountObject = new Account(
                Name ='Demand Blue CLient1',// Account Name
                Lead_Gen_Name__c = 'Others',             
                Industry = 'Hospitality',
                Project_Code__c ='GHT',
                Customer_Type__c= 'ABC Type',
                Account_Type__c='OTHERS'
            );
            insert accountObject;
            Date projStart = date.parse('11/01/2016');
            Date projEnd = date.parse('12/31/2016');
            ODS_Services__c service = ODS_DataFactory_Test_Utility.insertODSServices('DotNet', 'test', true);
            Project_Team_Member__c teamMember = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', accountObject.Id, service.Id);
            User_Account__c usrAcc1 = ODS_DataFactory_Test_Utility.insertUsrAccnt(accountObject.id, 'Technical Account Manager', portalAccountOwner1.Id, service.Id);
            Account_Services__c accService = ODS_DataFactory_Test_Utility.insertAccountServices(
                accountObject.id, projStart, projEnd, 150.0, service.id, 1000, 'Monthly', 
                UserInfo.getUserId(), 'DotNet');
            Contact contactObject = new Contact(
                FirstName ='Test',
                LastName='c',
                isPrimary__c=true,
                Email='test@preludesys.com',
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
                Billing_Frequency__c='Milestone',
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
                Subscription_Fee_Frequency__c='Monthly',
                Tips_Work_Order_ID__c='1234',
                BC_Work_Order_ID__c='1234'
            );           
            
            Test.startTest();
            try {
                Insert workorderObject;
                workorderObject.Bill_Rate__c=20;
                workorderObject.Subscription_Fee_Discount__c=200;
                workorderObject.Annual_Salary__c=3000;
                workorderObject.Billing_Frequency__c='Bi-Weekly';
                workorderObject.Project_End_Date__c=system.today().addDays(16);
                update workorderObject;
                
            } catch(DmlException e) {
            }
            Test.stopTest();
            
        }
    }
    public static testMethod void updateWorkOrder(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            
            UserRole testRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Vice_President_Sales'];
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
            
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accountObject = new Account(
                Name ='Demand Blue CLient1',// Account Name
                Lead_Gen_Name__c = 'Others',             
                Industry = 'Hospitality',
                Project_Code__c ='GHT',
                Customer_Type__c= 'ABC Type',
                Account_Type__c='OTHERS'
            );
            insert accountObject;
            Date projStart = date.parse('11/01/2016');
            Date projEnd = date.parse('12/31/2016');
            ODS_Services__c service = ODS_DataFactory_Test_Utility.insertODSServices('DotNet', 'test', true);
            Project_Team_Member__c teamMember = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', accountObject.Id, service.Id);
            User_Account__c usrAcc1 = ODS_DataFactory_Test_Utility.insertUsrAccnt(accountObject.id, 'Technical Account Manager', portalAccountOwner1.Id, service.Id);
            Account_Services__c accService = ODS_DataFactory_Test_Utility.insertAccountServices(
                accountObject.id, projStart, projEnd, 150.0, service.id, 1000, 'Monthly', 
                UserInfo.getUserId(), 'DotNet');
            Contact contactObject = new Contact(
                FirstName ='Test',
                LastName='c',
                isPrimary__c=true,
                Email='test@preludesys.com',
                AccountId=accountObject.Id,
                Lead_Gen_Name__c = 'Others'
            );
            insert contactObject;
            
            Work_Order__c workorderObject= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription-CO',
                Pay_Rate__c=85,
                Billing_Frequency__c='Milestone',
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
                Subscription_Fee_Frequency__c='Monthly',
                Tips_Work_Order_ID__c='1234',
                BC_Work_Order_ID__c='',
                BC_Build_CNSMP_WO_ID__c='2345'
            );
            
            insert workorderObject;
            
            workorderObject.Bill_Rate__c=500;
            workorderObject.Work_Order_Changes_Effective_Date__c=system.today().addDays(6);
            update workorderObject;
            
            
            Work_Order__c workorderObject1= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Fixed Price',
                Pay_Rate__c=85,
                Billing_Frequency__c='Milestone',
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
                Subscription_Fee_Frequency__c='Monthly',
                Tips_Work_Order_ID__c='1234',
                BC_Work_Order_ID__c='1234'
            );
            insert workorderObject1;

             Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription-CO',
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
                Subscription_Fee_Frequency__c='Monthly',
                Tips_Work_Order_ID__c='1234',
                 BC_Work_Order_ID__c='1234'
            );
            insert workorderObject2;
            
            Test.startTest();
            try {
                workorderObject1.Bill_Rate__c=20;
                update workorderObject1;
                
                workorderObject2.Bill_Rate__c=20;
                workorderObject2.Subscription_Fee_Discount__c=200;
                workorderObject2.Annual_Salary__c=3000;
                workorderObject2.Billing_Frequency__c='Bi-Weekly';
                workorderObject2.Project_End_Date__c=system.today().addDays(16);
                update workorderObject2;
                
            } catch(DmlException e) {
            }
            Test.stopTest();
            
        }
    }

    public static testMethod void testWorkOrderDetails(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            
            UserRole testRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Vice_President_Sales'];
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
            
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            accountObject = new Account(
                Name ='Demand Blue CLient1',// Account Name
                Lead_Gen_Name__c = 'Others',             
                Industry = 'Hospitality',
                Project_Code__c ='GHT',
                Customer_Type__c= 'ABC Type',
                Account_Type__c='OTHERS'
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
            
            workorderObject= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription-CO',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
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
                Subscription_Fee_Frequency__c='Monthly'
            );
            insert workorderObject;
            WorkOderIds.add(workorderObject.Id);
            
            workorderObject1= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today(),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Fixed Price',
                Pay_Rate__c=85,
                Billing_Frequency__c='Milestone',
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
                Project_Code__c='DEMANDSF',
                Subscription_Fee_Frequency__c='Monthly',
                Contact_to_Send_the_Invoice__c=contactObject.Id
            );
            insert workorderObject1;
            
            Deliverables__c deliverable1=new Deliverables__c();
            deliverable1.Name='deliverable1';
            deliverable1.Amount__c=120000;
            deliverable1.Description__c='Test 1';
            deliverable1.Start_date__c=system.today();
            deliverable1.End_date__c=system.today().addDays(15);
            deliverable1.Work_Order__c=workorderObject1.Id;
            insert deliverable1;
            
            Deliverables__c deliverable2=new Deliverables__c();
            deliverable2.Name='deliverable2';
            deliverable2.Amount__c=120000;
            deliverable2.Description__c='Test 2';
            deliverable2.Start_date__c=system.today();
            deliverable2.End_date__c=system.today().addDays(15);       
            deliverable2.Work_Order__c=workorderObject1.Id;
            insert deliverable2;
            
            Deliverables__c deliverable3=new Deliverables__c();
            deliverable3.Name='deliverable3';
            deliverable3.Amount__c=120000;
            deliverable3.Description__c='Test 3';
            deliverable3.Start_date__c=system.today();
            deliverable3.End_date__c=system.today().addDays(15);        
            deliverable3.Work_Order__c=workorderObject1.Id;
            insert deliverable3;
            WorkOderIds.add(workorderObject1.Id);
            
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(7),
                Project_End_Date__c=system.today().addDays(20),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
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
                Project_Code__c='DEMANDSF',
                Contact_for_Payment_followUp__c=contactObject.Id,
                Same_as_the_Invoice_Contact__c=true,
                Tips_Work_Order_ID__c = '10',
                BC_Work_Order_ID__c='1234',
                Subscription_Fee_Frequency__c='Monthly',
                TIPS_Admin_CNSMP_WO_ID__c='11',
                TIPS_Consulting_CNSMP_WO_ID__c='12',
                BC_Build_CNSMP_WO_ID__c='1235',
                BC_Admin_CNSMP_WO_ID__c='1236',
                BC_Consulting_CNSMP_WO_ID__c='198'
            );
            insert workorderObject2;
            workorderObject2.Bill_Rate__c=123;
            workorderObject2.Admin_Hourly_Rate__c=234;
            workorderObject2.Consulting_Hourly_Rate__c=120;
            workorderObject2.Work_Order_Changes_Effective_Date__c=system.today().addDays(10);
            update workorderObject2;
            workdOrderOldMap.put(workorderObject2.Id,workorderObject2);
            
            WorkOderIds.add(workorderObject2.Id);
            WorkOrderOwnerIds.add(workorderObject2.OwnerId);
            
            WorkOrder_API_Calls.AddWorkOrderAPI=false;
            WorkOrder_API_Calls.isFirstTime=true;
            
            Deliverables__c deliverable4=new Deliverables__c();
            deliverable4.Name='deliverable3';
            deliverable4.Amount__c=120000;
            deliverable4.Description__c='Test 3';
            deliverable4.Start_date__c=system.today();
            deliverable4.End_date__c=system.today().addDays(15);        
            deliverable4.Work_Order__c=workorderObject1.Id;
            insert deliverable4;

            Test.startTest();
             WorkOrder_API_Calls.addWorkOrderAPI=false;
            delete deliverable4;

            Test.setMock(HttpCalloutMock.class, new WorkOrderMockTest(accountObject.Id));
            WorkOrder_API_Calls.addWorkOrderAPI=true;
            WorkOrder_API_Calls.updateWorkOrderAPI=true;
            WorkOrder_API_Calls.isFirstTime=true;
            string body='{"data":"'+WorkOrder_API_Calls.AESEncryptDecrypt(WorkOrder_API_Calls.GetInputString(workorderObject2))+'"}';
            WorkOrder_API_Calls.HttpRequest(workorderObject2.Id,System.Label.TIPS_API_Update_Endpoint,body,workorderObject2.Name,'POST',false,'','','');
            workorderObject2.Annual_Salary__c=200;
            workorderObject2.Bill_Rate__c=300;
            workorderObject2.Work_Order_Changes_Effective_Date__c=system.today().addDays(9);
            workorderObject2.Admin_Hourly_Rate__c=10;
            workorderObject2.Consulting_Hourly_Rate__c=20;
            workorderObject2.TIPS_CNSMP_WO_ID__c='2345';
            workorderObject2.TIPS_Admin_CNSMP_WO_ID__c='1234';
            workorderObject2.TIPS_Consulting_CNSMP_WO_ID__c='4567';
            workorderObject2.BC_Build_CNSMP_WO_ID__c='2345';
            workorderObject2.BC_Admin_CNSMP_WO_ID__c='1234';
            workorderObject2.BC_Consulting_CNSMP_WO_ID__c='4567';
            update workorderObject2;
            WorkOrder_API_Calls.AddWorkOrdersUsingAPI(WorkOderIds);
            WorkOrder_API_Calls.updateWorkOrdersUsingAPI(WorkOderIds,workdOrderOldMap);            
            WorkOderIds.add(workorderObject2.id);
            WorkOrder_API_Calls.DeleteWorkOrdersUsingAPI(WorkOderIds);
            system.assertNotEquals(0, WorkOderIds.Size());
            Test.stopTest();
        }
    }
    
    public static testMethod void testWorkOrderDetailsWithError(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            
            UserRole testRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Vice_President_Sales'];
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
            
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            accountObject = new Account(
                Name ='Demand Blue CLient1',// Account Name
                Lead_Gen_Name__c = 'Others',             
                Industry = 'Hospitality',
                Project_Code__c ='GHT',
                Customer_Type__c= 'ABC Type',
                Account_Type__c='OTHERS'
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
            
            workorderObject= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
                Subscription_Fee_Frequency__c='Monthly',
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
                PO_Number__c='4578'
            );
            insert workorderObject;
            WorkOderIds.add(workorderObject.Id);
            
            workorderObject1= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today(),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
                Subscription_Fee_Frequency__c='Monthly',
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
                Project_Code__c='DEMANDSF',              
                Contact_to_Send_the_Invoice__c=contactObject.Id,
                Tips_Work_Order_ID__c='1234',
                BC_Work_Order_ID__c='1234'
            );
            insert workorderObject1;
            //workorderObject1.Subscription_Fee_Sticker_Price__c=500;
            workorderObject1.Bill_Rate__c=123;
            workorderObject1.Admin_Hourly_Rate__c=234;
            workorderObject1.Consulting_Hourly_Rate__c=120;
            workorderObject1.Work_Order_Changes_Effective_Date__c=system.today().addDays(10);
            update workorderObject1;
            
            Deliverables__c deliverable1=new Deliverables__c();
            deliverable1.Name='deliverable1';
            deliverable1.Amount__c=120000;
            deliverable1.Description__c='Test 1';
            deliverable1.Start_date__c=system.today();
            deliverable1.End_date__c=system.today().addDays(15);
            deliverable1.Work_Order__c=workorderObject1.Id;
            insert deliverable1;
            
            Deliverables__c deliverable2=new Deliverables__c();
            deliverable2.Name='deliverable2';
            deliverable2.Amount__c=120000;
            deliverable2.Description__c='Test 2';
            deliverable2.Start_date__c=system.today();
            deliverable2.End_date__c=system.today().addDays(15);       
            deliverable2.Work_Order__c=workorderObject1.Id;
            insert deliverable2;
            
            Deliverables__c deliverable3=new Deliverables__c();
            deliverable3.Name='deliverable3';
            deliverable3.Amount__c=120000;
            deliverable3.Description__c='Test 3';
            deliverable3.Start_date__c=system.today();
            deliverable3.End_date__c=system.today().addDays(15);        
            deliverable3.Work_Order__c=workorderObject1.Id;
            insert deliverable3;
            WorkOderIds.add(workorderObject1.Id);
            
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(7),
                Project_End_Date__c=system.today().addDays(20),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
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
                Project_Code__c='DEMANDSF',
                Contact_for_Payment_followUp__c=contactObject.Id,
                Same_as_the_Invoice_Contact__c=true,
                Tips_Work_Order_ID__c = '10',
                BC_Work_Order_ID__c='10',
                Subscription_Fee_Frequency__c='Monthly'
            );
            insert workorderObject2;

            
            
            workdOrderOldMap.put(workorderObject2.Id,workorderObject2);        
            WorkOderIds.add(workorderObject2.Id);
            WorkOrderOwnerIds.add(workorderObject2.OwnerId);
            
            WorkOrder_API_Calls.AddWorkOrderAPI=false;
            WorkOrder_API_Calls.updateWorkOrderAPI=true;
            
            WorkOrder_API_Calls.isFirstTime=true;
            
            Deliverables__c deliverable4=new Deliverables__c();
            deliverable4.Name='deliverable3';
            deliverable4.Amount__c=120000;
            deliverable4.Description__c='Test 3';
            deliverable4.Start_date__c=system.today();
            deliverable4.End_date__c=system.today().addDays(15);        
            deliverable4.Work_Order__c=workorderObject1.Id;
            insert deliverable4;
            
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new WorkOrderMockErrorTest());
            string body='{"data":"'+WorkOrder_API_Calls.AESEncryptDecrypt(WorkOrder_API_Calls.GetInputString(workorderObject2))+'"}';
            WorkOrder_API_Calls.HttpRequest(workorderObject2.Id,System.Label.TIPS_API_Update_Endpoint,body,workorderObject2.Name,'POST',false,'','','');

            WorkOrder_API_Calls.addWorkOrderAPI=true;
            WorkOrder_API_Calls.updateWorkOrderAPI = true;
            workorderObject2.Annual_Salary__c = 10;
            workorderObject2.Admin_Hourly_Rate__c=20;
            workorderObject2.Consulting_Hourly_Rate__c=30;
            workorderObject2.Work_Order_Changes_Effective_Date__c=system.today().addDays(15);
            update workorderObject2;
            
            WorkOrder_API_Calls.GetInputStringConsumption(workorderObject2, 'Demandblue-Consumption', true, 'Admin');
            WorkOrder_API_Calls.AddWorkOrdersUsingAPI(WorkOderIds);
            WorkOrder_API_Calls.updateWorkOrdersUsingAPI(WorkOderIds, workdOrderOldMap);            
            WorkOrder_API_Calls.DeleteWorkOrdersUsingAPI(WorkOderIds);
            
            Work_Order__c workorderObject3= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(7),
                Project_End_Date__c=system.today().addDays(20),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
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
                Project_Code__c='DEMANDSF',
                Contact_for_Payment_followUp__c=contactObject.Id,
                Same_as_the_Invoice_Contact__c=true,
                Tips_Work_Order_ID__c = '10',
                BC_Work_Order_ID__c='12'
            );
            
            insert workorderObject3;
            delete workorderObject3;
            Test.stopTest();
        }
    }

    
    public class WorkOrderMockTest implements HttpCalloutMock {
        public string accountId='';
        public WorkOrderMockTest(string acc){
            this.accountId=acc;
        }
        public HTTPResponse respond(HTTPRequest req) {
            string accessToken = WorkOrder_API_Calls.GenerateAuthorizationToken();
            HttpResponse res = new HttpResponse();
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(System.Label.TIPS_API_Endpoint);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer '+accessToken);
            res.setBody('"WorkOrder Added Successfully - 14016 - AccountCode :-M03 -  SFClientID :-'+accountId+'"');
            res.setStatusCode(200);
            return res;
            
        }
        
    } 
    public class WorkOrderMockErrorTest implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            string accessToken = WorkOrder_API_Calls.GenerateAuthorizationToken();
            HttpResponse res = new HttpResponse();
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(System.Label.TIPS_API_Endpoint);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer '+accessToken);
            res.setBody('"Please select the effect date."');
            res.setStatusCode(200);
            return res;
            
        }
        
    }
}