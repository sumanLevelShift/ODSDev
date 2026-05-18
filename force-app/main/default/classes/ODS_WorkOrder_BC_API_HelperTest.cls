@isTest
public class ODS_WorkOrder_BC_API_HelperTest {
    public static testMethod void testWorkOrderDetailsForQueueable(){
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
            List<Salesforce_BC_API_Configuration__mdt> SFBCApiConfig=[Select Id,Company__c,Access_Token_URL__c,Action_Type__c,Client_Id__c,Client_Secret__c,Endpoint_URL__c,Grant_Type__c,Parameter__c,Tenant_Id__c,Scope__c,Method_Type__c From Salesforce_BC_API_Configuration__mdt WHERE 
                                                                      Action_Type__c=:'Add' Limit 1];            
            String accessTokenUrl = SFBCApiConfig[0].Access_Token_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/oauth2/v2.0/token';
            string endpoint=SFBCApiConfig[0].Endpoint_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/'+SFBCApiConfig[0].Parameter__c+'?company='+SFBCApiConfig[0].Company__c;
            
            Test.startTest();
            // System.enqueueJob(workOrderAPI);
            Test.setMock(HttpCalloutMock.class, new AccessTokenMockHttpResponseGenerator(accessTokenUrl));
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
                BC_Work_Order_ID__c = 'SWO2300153',
                Work_Order_Changes_Effective_Date__c=system.today().addDays(9)
            );
            insert workorderObject2;
            Test.setMock(HttpCalloutMock.class, new WorkOrderMockTest(accountObject.id,endpoint));      
            
            
            Test.stopTest();
        }
    }
    public static testMethod void testWorkOrderDetailsForQueueableError(){
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
            List<Salesforce_BC_API_Configuration__mdt> SFBCApiConfig=[Select Id,Company__c,Access_Token_URL__c,Action_Type__c,Client_Id__c,Client_Secret__c,Endpoint_URL__c,Grant_Type__c,Parameter__c,Tenant_Id__c,Scope__c,Method_Type__c From Salesforce_BC_API_Configuration__mdt WHERE 
                                                                      Action_Type__c=:'Add' AND Is_Work_Order__c=true Limit 1];            
            String accessTokenUrl = SFBCApiConfig[0].Access_Token_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/oauth2/v2.0/token';
            string endpoint=SFBCApiConfig[0].Endpoint_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/'+SFBCApiConfig[0].Parameter__c+'?company='+SFBCApiConfig[0].Company__c;
            
            Test.startTest();
            // System.enqueueJob(workOrderAPI);
            Test.setMock(HttpCalloutMock.class, new AccessTokenMockHttpResponseGenerator(accessTokenUrl));
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
                BC_Work_Order_ID__c = 'SWO2300153',
                Work_Order_Changes_Effective_Date__c=system.today().addDays(9)
            );
            insert workorderObject2;
            WorkOrder_API_Calls.updateWorkOrderAPI=true;
            workorderObject2.Admin_Hourly_Rate__c=34;
            workorderObject2.Consulting_Hourly_Rate__c=56;
            update workorderObject2;
            Test.setMock(HttpCalloutMock.class, new WorkOrderMockTestError(accountObject.id,endpoint));      
            
            
            Test.stopTest();
        }
    }
    public class WorkOrderMockTestError implements HttpCalloutMock {
        public string accountId='';
        public string endpointUrl='';
        public WorkOrderMockTestError(string acc,string endpointUrl){
            this.accountId=acc;
            this.endpointUrl=endpointUrl;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(endpointUrl);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InEtMjNmYWxldlpoaEQzaG05Q1Fia1A1TVF5VSIsImtpZCI6InEtMjNmYWxldlpoaEQzaG05Q1Fia1A1TVF5VSJ9.eyJhdWQiOiJodHRwczovL2FwaS5idXNpbmVzc2NlbnRyYWwuZHluYW1pY3MuY29tIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvZGY2ZWZmMzItNmY3MS00MjMwLTgyM2UtOTBkNGFlZWZkYTI1LyIsImlhdCI6MTcxMzE4MDExMCwibmJmIjoxNzEzMTgwMTEwLCJleHAiOjE3MTMxODQwMTAsImFpbyI6IkUyTmdZS2pqWjFraWZYUHV2NTdsa1YyVFo3SDhBQUE9IiwiYXBwaWQiOiJlMDk3MDQ2YS01NThhLTQwNGMtOTNlMS1jNTI2MDA4MjkyNmUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kZjZlZmYzMi02ZjcxLTQyMzAtODIzZS05MGQ0YWVlZmRhMjUvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiIxYTczMjdlOS1hYzg1LTQ1N2MtOTUwYy05MzdjN2NiZjNjNDQiLCJyaCI6IjAuQVFNQU12OXUzM0Z2TUVLQ1BwRFVydV9hSlQzdmJabHNzMU5CaGdlbV9Ud0J1SjhCQVFBLiIsInJvbGVzIjpbIkF1dG9tYXRpb24uUmVhZFdyaXRlLkFsbCIsImFwcF9hY2Nlc3MiLCJBZG1pbkNlbnRlci5SZWFkV3JpdGUuQWxsIiwiQVBJLlJlYWRXcml0ZS5BbGwiXSwic3ViIjoiMWE3MzI3ZTktYWM4NS00NTdjLTk1MGMtOTM3YzdjYmYzYzQ0IiwidGlkIjoiZGY2ZWZmMzItNmY3MS00MjMwLTgyM2UtOTBkNGFlZWZkYTI1IiwidXRpIjoiUWlNblJsUEZFRUtubEV6YXloTERBUSIsInZlciI6IjEuMCJ9.RrZnXSWONhAEEXo6DlhgracHpDIKJ0cjWP-9vtCSxUni-mjnVoOymA_O1lXxAp6xHGjPSa62lBv4YcMl-ngaVg2avcSGi4ToUEuxU99RgtDxlhTO-Lte0Yf6VoE-v_zR5puEPaIqLXr6KTJbJnR-p4B9BWuMWPxIYM13NaBS7CWLi1-Kdu8qMBVmBolhjbwp0rumTe6oj5fWWSMRaqJbUADosFmLU2xoztwCoTmqejB0EilFIhadTW2x4b9W_QoUrBkZz53chKgbTO4njTvrOhsA_cwwrN1dAWVnt4YTl6H3kp3jL_MXpXrNkqr4E64xlZMuErbBm5gVNeeC37cm8g');
            res.setBody('Error');
            res.setStatusCode(200);
            return res;
            
        }
        
    }
    public class WorkOrderMockTest implements HttpCalloutMock {
        public string accountId='';
        public string endpointUrl='';
        public WorkOrderMockTest(string acc,string endpointUrl){
            this.accountId=acc;
            this.endpointUrl=endpointUrl;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(endpointUrl);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InEtMjNmYWxldlpoaEQzaG05Q1Fia1A1TVF5VSIsImtpZCI6InEtMjNmYWxldlpoaEQzaG05Q1Fia1A1TVF5VSJ9.eyJhdWQiOiJodHRwczovL2FwaS5idXNpbmVzc2NlbnRyYWwuZHluYW1pY3MuY29tIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvZGY2ZWZmMzItNmY3MS00MjMwLTgyM2UtOTBkNGFlZWZkYTI1LyIsImlhdCI6MTcxMzE4MDExMCwibmJmIjoxNzEzMTgwMTEwLCJleHAiOjE3MTMxODQwMTAsImFpbyI6IkUyTmdZS2pqWjFraWZYUHV2NTdsa1YyVFo3SDhBQUE9IiwiYXBwaWQiOiJlMDk3MDQ2YS01NThhLTQwNGMtOTNlMS1jNTI2MDA4MjkyNmUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kZjZlZmYzMi02ZjcxLTQyMzAtODIzZS05MGQ0YWVlZmRhMjUvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiIxYTczMjdlOS1hYzg1LTQ1N2MtOTUwYy05MzdjN2NiZjNjNDQiLCJyaCI6IjAuQVFNQU12OXUzM0Z2TUVLQ1BwRFVydV9hSlQzdmJabHNzMU5CaGdlbV9Ud0J1SjhCQVFBLiIsInJvbGVzIjpbIkF1dG9tYXRpb24uUmVhZFdyaXRlLkFsbCIsImFwcF9hY2Nlc3MiLCJBZG1pbkNlbnRlci5SZWFkV3JpdGUuQWxsIiwiQVBJLlJlYWRXcml0ZS5BbGwiXSwic3ViIjoiMWE3MzI3ZTktYWM4NS00NTdjLTk1MGMtOTM3YzdjYmYzYzQ0IiwidGlkIjoiZGY2ZWZmMzItNmY3MS00MjMwLTgyM2UtOTBkNGFlZWZkYTI1IiwidXRpIjoiUWlNblJsUEZFRUtubEV6YXloTERBUSIsInZlciI6IjEuMCJ9.RrZnXSWONhAEEXo6DlhgracHpDIKJ0cjWP-9vtCSxUni-mjnVoOymA_O1lXxAp6xHGjPSa62lBv4YcMl-ngaVg2avcSGi4ToUEuxU99RgtDxlhTO-Lte0Yf6VoE-v_zR5puEPaIqLXr6KTJbJnR-p4B9BWuMWPxIYM13NaBS7CWLi1-Kdu8qMBVmBolhjbwp0rumTe6oj5fWWSMRaqJbUADosFmLU2xoztwCoTmqejB0EilFIhadTW2x4b9W_QoUrBkZz53chKgbTO4njTvrOhsA_cwwrN1dAWVnt4YTl6H3kp3jL_MXpXrNkqr4E64xlZMuErbBm5gVNeeC37cm8g');
            res.setBody('{"@odata.context":"test","value":{\"Message\":\"WorkOrder Added Successfully\",\"WorkOrderId\":\"SWO2300156\",\"AccountCode\":\"N29\",\"ClientId\":\"'+accountId+'\"}}');
            res.setStatusCode(200);
            return res;
            
        }
        
    } 
    public class AccessTokenMockHttpResponseGenerator implements HttpCalloutMock {
        public string endPoinUrl='';
        public AccessTokenMockHttpResponseGenerator(string e){
            this.endPoinUrl=e;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InEtMjNmYWxldlpoaEQzaG05Q1Fia1A1TVF5VSIsImtpZCI6InEtMjNmYWxldlpoaEQzaG05Q1Fia1A1TVF5VSJ9.eyJhdWQiOiJodHRwczovL2FwaS5idXNpbmVzc2NlbnRyYWwuZHluYW1pY3MuY29tIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvZGY2ZWZmMzItNmY3MS00MjMwLTgyM2UtOTBkNGFlZWZkYTI1LyIsImlhdCI6MTcxMzE4MDExMCwibmJmIjoxNzEzMTgwMTEwLCJleHAiOjE3MTMxODQwMTAsImFpbyI6IkUyTmdZS2pqWjFraWZYUHV2NTdsa1YyVFo3SDhBQUE9IiwiYXBwaWQiOiJlMDk3MDQ2YS01NThhLTQwNGMtOTNlMS1jNTI2MDA4MjkyNmUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kZjZlZmYzMi02ZjcxLTQyMzAtODIzZS05MGQ0YWVlZmRhMjUvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiIxYTczMjdlOS1hYzg1LTQ1N2MtOTUwYy05MzdjN2NiZjNjNDQiLCJyaCI6IjAuQVFNQU12OXUzM0Z2TUVLQ1BwRFVydV9hSlQzdmJabHNzMU5CaGdlbV9Ud0J1SjhCQVFBLiIsInJvbGVzIjpbIkF1dG9tYXRpb24uUmVhZFdyaXRlLkFsbCIsImFwcF9hY2Nlc3MiLCJBZG1pbkNlbnRlci5SZWFkV3JpdGUuQWxsIiwiQVBJLlJlYWRXcml0ZS5BbGwiXSwic3ViIjoiMWE3MzI3ZTktYWM4NS00NTdjLTk1MGMtOTM3YzdjYmYzYzQ0IiwidGlkIjoiZGY2ZWZmMzItNmY3MS00MjMwLTgyM2UtOTBkNGFlZWZkYTI1IiwidXRpIjoiUWlNblJsUEZFRUtubEV6YXloTERBUSIsInZlciI6IjEuMCJ9.RrZnXSWONhAEEXo6DlhgracHpDIKJ0cjWP-9vtCSxUni-mjnVoOymA_O1lXxAp6xHGjPSa62lBv4YcMl-ngaVg2avcSGi4ToUEuxU99RgtDxlhTO-Lte0Yf6VoE-v_zR5puEPaIqLXr6KTJbJnR-p4B9BWuMWPxIYM13NaBS7CWLi1-Kdu8qMBVmBolhjbwp0rumTe6oj5fWWSMRaqJbUADosFmLU2xoztwCoTmqejB0EilFIhadTW2x4b9W_QoUrBkZz53chKgbTO4njTvrOhsA_cwwrN1dAWVnt4YTl6H3kp3jL_MXpXrNkqr4E64xlZMuErbBm5gVNeeC37cm8g"}');
            res.setStatusCode(200);
            return res;
        }
    }
}