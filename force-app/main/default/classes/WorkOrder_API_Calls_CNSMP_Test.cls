@isTest
public class WorkOrder_API_Calls_CNSMP_Test {
    public static testMethod void testWorkOrderDetailsForQueueable(){
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
            
            //userId = [SELECT Id FROM User WHERE Name = 'Zeeshan Armar' and IsActive=true LIMIT 1];        
            //User userId1 = [SELECT Id,Name FROM User WHERE Name = 'Selva Pandian' and IsActive=true LIMIT 1];
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
                PO_Number__c='4578'
                // OwnerId=userId1.Id
            );
            
            insert workorderObject;
            
            WorkOderIds.add(workorderObject.Id);
            
            Work_Order__c workorderObject1= new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today(),
                Project_End_Date__c=system.today().addDays(15),
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
                //OwnerId=userId1.Id,
                
                Contact_to_Send_the_Invoice__c=contactObject.Id
            );
            
            insert workorderObject1;
            
            
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
                //OwnerId=userId1.Id,
                Contact_for_Payment_followUp__c=contactObject.Id,
                Same_as_the_Invoice_Contact__c=true,
                Tips_Work_Order_ID__c = '10'
            );
            
            insert workorderObject2;
            
            WorkOrder_API_Calls_CNSMP workOrderAPI = new WorkOrder_API_Calls_CNSMP(
                workorderObject1.Id, // workOrderId
                System.Label.TIPS_API_Endpoint, // Endpoint
                '{"key": "value"}', // ConsumptionBody
                '{"key": "value"}', // AdminConsumptionBody
                '{"key": "value"}', // ConsultingConsumptionBody
				 workorderObject1.Name, // workOrderName
                'POST' // MethodType
            );
            
            Test.startTest();
            System.enqueueJob(workOrderAPI);
            Test.setMock(HttpCalloutMock.class, new WorkOrderMockTest(accountObject.Id));
            
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
            //  System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(System.Label.TIPS_API_Endpoint);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer '+accessToken);
            res.setBody('WorkOrder Added Successfully - 12313 - AccountCode :-L85 -  SFClientID :-'+accountId);
            res.setStatusCode(200);
            return res;
            
        }
        
    } 
}