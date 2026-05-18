@isTest
public class TimesheetTriggerHandlerTestClass {
    @testSetup
    public static void createRecords() {
        // Common dates
        Date startDate = date.parse('11/01/2016');
        Date endDate = date.parse('12/31/2016');
        Date weekStart = date.parse('12/11/2016');
        Date weekEnd = date.parse('12/17/2016');
        Date timesheetDate = date.parse('12/16/2016');
        
        // Setup test data
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile adminProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User adminUser = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 
                                                                         'Indumathi', 'en_US', 'en_US', adminProfile.Id, 'America/Chicago', 
                                                                         System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        
        System.runAs(adminUser) {
            // Create common test data
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            UserRole vpRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Vice_President_Sales'];
            User vpUser = new User(
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
                UserRoleId = vpRole.Id
            );
            insert vpUser;
            
            createAccountWithTimesheets('TestAccount', 'ABC Type', 'DotNet', 'ODSDOTNET', startDate, endDate, weekStart, weekEnd, timesheetDate,adminUser);
            // createAccountWithTimesheets('TestAccount1', 'Regular', 'Salesforce', 'Salesforce', startDate, endDate, weekStart, weekEnd, timesheetDate,adminUser);
        }
    }
    
    private static void createAccountWithTimesheets(String accName, String custType, String serviceName, 
                                                    String serviceCode, Date projStart, Date projEnd, Date weekStart, 
                                                    Date weekEnd, Date timesheetDate,user adminUser) {
                                                        
                                                        // Create account
                                                        Account acc = ODS_DataFactory_Test_Utility.InsertAccount(accName, 'California', True, 2000, 
                                                                                                                 '9433578865', 'Others', 'ODS Project');
                                                        acc.Customer_Type__c = custType;
                                                        
                                                        // Create contact
                                                        Contact con = ODS_DataFactory_Test_Utility.InsertContact('Test', 'McTesty', True, acc.Id, 'Others', 'ODS Project');
                                                        con.Email = 'test@test.com';
                                                        update con;
                                                        
                                                        // Update account details
                                                        acc.ODS_Invoice_Account_Number__c = 'C45';
                                                        acc.Invoice_Type__c = 'Paper';
                                                        acc.Primary_Customer_Contact__c = con.Id;
                                                        acc.InvoiceContact__c = con.Id;
                                                        acc.BillingCity = 'Chennai';
                                                        acc.BillingStreet = 'Siruseri';
                                                        acc.BillingState = 'Tamilnadu';
                                                        acc.BillingCountry = 'India';
                                                        acc.BillingPostalCode = '640000';
                                                        acc.ODS_Invoice_Count__c = 10;
                                                        update acc;
                                                        
                                                        // Create service and team member
                                                        ODS_Services__c service = ODS_DataFactory_Test_Utility.insertODSServices(serviceName, 'test', true);
                                                        Project_Team_Member__c teamMember = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', acc.Id, service.Id);
                                                        User_Account__c usrAcc1 = ODS_DataFactory_Test_Utility.insertUsrAccnt(acc.id, 'Technical Account Manager', adminUser.Id, service.Id);
                                                        // Create account service
                                                        Account_Services__c accService = ODS_DataFactory_Test_Utility.insertAccountServices(
                                                            acc.id, projStart, projEnd, 150.0, service.id, 1000, 'Monthly', 
                                                            UserInfo.getUserId(), serviceCode);
                                                        
                                                        // Create work order
                                                        Work_Order__c wo = new Work_Order__c(
                                                            Client_Name__c = acc.Id,
                                                            Project_Start_Date__c = projStart,
                                                            Project_End_Date__c = projEnd,
                                                            Account_Manager_Name__c = [SELECT Id FROM User WHERE Username = 'testuser@example.comVPS'].Id,
                                                            SubCategory__c = 'DemandBlue-Subscription',
                                                            Pay_Rate__c = 85,
                                                            Billing_Frequency__c = 'Monthly',
                                                            Bill_Rate__c = 120000,
                                                            Annual_Salary__c = 25000,
                                                            PERDIEM__c = 920,
                                                            Business_Unit__c = 'DemandBlue',
                                                            Project_Name__c = 'TestProject',
                                                            LCA_Required__c = false,
                                                            Minumim_Billable_Hours_Per_Month__c = 8,
                                                            Bill_Rate_Type__c = 'One Time',
                                                            Initial_Gross_Margin__c = 77.8,
                                                            Payment_Terms_Projects__c = 'Net 30',
                                                            PO_Number__c = '4578',
                                                            Project_Code__c = 'DEMANDSF',
                                                            Contact_for_Payment_followUp__c = con.Id,
                                                            TIPS_CNSMP_WO_ID__c = '1234',
                                                            TIPS_Admin_CNSMP_WO_ID__c = '0987',
                                                            TIPS_Consulting_CNSMP_WO_ID__c = '6789',
                                                            BC_Build_CNSMP_WO_ID__c = '1234',
                                                            BC_Admin_CNSMP_WO_ID__c = '1234',
                                                            BC_Consulting_CNSMP_WO_ID__c = '12367',
                                                            Same_as_the_Invoice_Contact__c = true
                                                        );
                                                        WorkOrder_API_Calls.isFirstTime = false;
                                                        insert wo;
                                                         Work_Order_External_Reference__c woEr=new Work_Order_External_Reference__c(
                                                            BC_Build_CNSMP_WO_ID__c = '1234',
                                                            BC_Admin_CNSMP_WO_ID__c = '1234',
                                                            BC_Consulting_CNSMP_WO_ID__c = '12367',
                                                            Start_Date__c = projStart,
                                                            End_Date__c = projEnd,
                                                            WorkOrder__c=wo.id
                                                        );
                                                        insert woEr;
                                                        Work_Order__c wo1 = new Work_Order__c(
                                                            Client_Name__c = acc.Id,
                                                            Project_Start_Date__c = system.today().addDays(-40),
                                                            Project_End_Date__c = system.today().addDays(-10),
                                                            Account_Manager_Name__c = [SELECT Id FROM User WHERE Username = 'testuser@example.comVPS'].Id,
                                                            SubCategory__c = 'DemandBlue-Subscription',
                                                            Pay_Rate__c = 85,
                                                            Billing_Frequency__c = 'Monthly',
                                                            Bill_Rate__c = 120000,
                                                            Annual_Salary__c = 25000,
                                                            PERDIEM__c = 920,
                                                            Business_Unit__c = 'DemandBlue',
                                                            Project_Name__c = 'TestProject',
                                                            LCA_Required__c = false,
                                                            Minumim_Billable_Hours_Per_Month__c = 8,
                                                            Bill_Rate_Type__c = 'One Time',
                                                            Initial_Gross_Margin__c = 77.8,
                                                            Payment_Terms_Projects__c = 'Net 30',
                                                            PO_Number__c = '4578',
                                                            Project_Code__c = 'DEMANDSF',
                                                            Contact_for_Payment_followUp__c = con.Id,
                                                            TIPS_CNSMP_WO_ID__c = '1234',
                                                            TIPS_Admin_CNSMP_WO_ID__c = '0987',
                                                            TIPS_Consulting_CNSMP_WO_ID__c = '6789',
                                                            BC_Build_CNSMP_WO_ID__c = '1234',
                                                            BC_Admin_CNSMP_WO_ID__c = '1234',
                                                            BC_Consulting_CNSMP_WO_ID__c = '12367',
                                                            Same_as_the_Invoice_Contact__c = true
                                                        );
                                                        WorkOrder_API_Calls.isFirstTime = false;
                                                        insert wo1;
                                                        Work_Order_External_Reference__c woEr1=new Work_Order_External_Reference__c(
                                                            BC_Build_CNSMP_WO_ID__c = '1234',
                                                            BC_Admin_CNSMP_WO_ID__c = '1234',
                                                            BC_Consulting_CNSMP_WO_ID__c = '12367',
                                                            Start_Date__c = system.today().addDays(-40),
                                                            End_Date__c = system.today().addDays(-10),
                                                            WorkOrder__c=wo1.id
                                                        );
                                                        insert woEr1;
                                                        // Create timesheet cost
                                                        Time_Sheet_Cost__c tsCost = ODS_DataFactory_Test_Utility.insertTimesheetCost(
                                                            accService.Id, 300, projStart, projEnd, '11', '2016');
                                                        
                                                        // Create timesheet
                                                        Timesheet__c ts = new Timesheet__c(
                                                            Name = 'TestName',
                                                            Time_Sheet_Cost__c = tsCost.Id,
                                                            Week_Start_Date__c = weekStart,
                                                            Week_End_Date__c = weekEnd,
                                                            Account_Services__c = accService.Id
                                                        );
                                                        insert ts;
                                                        
                                                        // Create timesheet details for different billing types
                                                        List<String> billingTypes = new List<String>{'Build', 'Admin', 'Consulting'};
                                                            for(String type : billingTypes) {
                                                                Time_Sheet_Details__c tsDetail = new Time_Sheet_Details__c(
                                                                    Hours_Worked__c = 5,
                                                                    Resource_Id__c = teamMember.Id,
                                                                    Resource__c = 'Test Res',
                                                                    Timesheet__c = ts.id,
                                                                    Timesheet_Date__c = timesheetDate,
                                                                    Initiative_Billing_Type__c = type
                                                                );
                                                                insert tsDetail;
                                                            }
                                                    }
    static TestMethod void InsertTimeSheetABCWeekly() {
        Account_Services__c accSer=[Select ID FROM Account_Services__c WHERE Account__r.Customer_Type__c='ABC Type' LIMIT 1];
        accSer.Contract_Term__c = 'Net 30';
        accSer.Invoice_Frequency__c = 'Weekly';
        update accSer;
        Timesheet__c insertTimeSheet1=[Select ID FROM Timesheet__c WHERE Account_Services__c=:accSer.id LIMIT 1];
        insertTimeSheet1.Status__c='Submitted';
        Update insertTimeSheet1;
        
        
        TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id);
        //TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id);
        //TimesheetTriggerHandler.sendTimesheet(insertTimeSheet2.id);
        //TimesheetTriggerHandler.sendTimesheet(insertTimeSheet2.id);
        
    }
        static TestMethod void InsertTimeSheetABCBiWeekly() {
        Account_Services__c accSer=[Select ID FROM Account_Services__c WHERE Account__r.Customer_Type__c='ABC Type' LIMIT 1];
        accSer.Contract_Term__c = 'Net 30';
        accSer.Invoice_Frequency__c = 'Bi-Weekly';
        update accSer;
        Timesheet__c insertTimeSheet1=[Select ID FROM Timesheet__c WHERE Account_Services__c=:accSer.id LIMIT 1];
        insertTimeSheet1.Status__c='Submitted';
        Update insertTimeSheet1;
        
        
        TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id);
        
    }
     static TestMethod void InsertTimeSheetABCSemiMonthly() {
        Account_Services__c accSer=[Select ID FROM Account_Services__c WHERE Account__r.Customer_Type__c='ABC Type' LIMIT 1];
        accSer.Contract_Term__c = 'Net 30';
        accSer.Invoice_Frequency__c = 'Semi-Monthly';
        update accSer;
        Timesheet__c insertTimeSheet1=[Select ID FROM Timesheet__c WHERE Account_Services__c=:accSer.id LIMIT 1];
        insertTimeSheet1.Status__c='Submitted';
        Update insertTimeSheet1;
        
        
        TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id);
        
    }
    static TestMethod void InsertTimeSheetABCMonthly_Test() {
        Account_Services__c accSer=[Select ID FROM Account_Services__c WHERE Account__r.Customer_Type__c ='ABC Type' LIMIT 1];
        accSer.Contract_Term__c = 'Net 30';
        accSer.Invoice_Frequency__c = 'Monthly';
        update accSer;
        Timesheet__c insertTimeSheet1=[Select ID FROM Timesheet__c WHERE Account_Services__c=:accSer.id LIMIT 1];
        insertTimeSheet1.Status__c='Submitted';
        Update insertTimeSheet1;
        TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id);  
    }
    static TestMethod void timesheetABCMonthlyFail_Test() {
        Account_Services__c accSer=[Select ID FROM Account_Services__c WHERE Account__r.Customer_Type__c ='ABC Type' LIMIT 1];
        accSer.Contract_Term__c = 'Net 30';
        accSer.Invoice_Frequency__c = 'Monthly';
        update accSer;
        Work_Order__c wo=[Select ID FROM Work_Order__c LIMIT 1];
        wo.BC_Admin_CNSMP_WO_ID__c='';
        wo.BC_Build_CNSMP_WO_ID__c='';
        wo.BC_Consulting_CNSMP_WO_ID__c='';
        update wo;
        Timesheet__c insertTimeSheet1=[Select ID FROM Timesheet__c WHERE Account_Services__c=:accSer.id LIMIT 1];
        insertTimeSheet1.Status__c='Submitted';
        Update insertTimeSheet1;
        TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id);  
    }
    static TestMethod void timesheetABCWeeklyFail_Test() {
        Account_Services__c accSer=[Select ID FROM Account_Services__c WHERE Account__r.Customer_Type__c ='ABC Type' LIMIT 1];
        accSer.Contract_Term__c = 'Net 30';
        accSer.Invoice_Frequency__c = 'Weekly';
        update accSer;
        Work_Order__c wo=[Select ID FROM Work_Order__c LIMIT 1];
        wo.BC_Admin_CNSMP_WO_ID__c='';
        wo.BC_Build_CNSMP_WO_ID__c='';
        wo.BC_Consulting_CNSMP_WO_ID__c='';
        update wo;
        Timesheet__c insertTimeSheet1=[Select ID FROM Timesheet__c WHERE Account_Services__c=:accSer.id LIMIT 1];
        insertTimeSheet1.Status__c='Submitted';
        Update insertTimeSheet1;
        //TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id); 
        
    }
    static TestMethod void timesheetABCMonthlyFail1_Test() {
        Account_Services__c accSer=[Select ID FROM Account_Services__c WHERE Account__r.Customer_Type__c ='ABC Type' LIMIT 1];
        accSer.Contract_Term__c = 'Net 30';
        accSer.Invoice_Frequency__c = 'Monthly';
        update accSer;
        Work_Order__c wo=[Select ID FROM Work_Order__c LIMIT 1];
        Delete wo;
        Timesheet__c insertTimeSheet1=[Select ID FROM Timesheet__c WHERE Account_Services__c=:accSer.id LIMIT 1];
        insertTimeSheet1.Status__c='Submitted';
        Update insertTimeSheet1;
        TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id); 
        
    }
    static TestMethod void timesheetABCWeeklyFail1_Test() {
        Account_Services__c accSer=[Select ID FROM Account_Services__c WHERE Account__r.Customer_Type__c ='ABC Type' LIMIT 1];
        accSer.Contract_Term__c = 'Net 30';
        accSer.Invoice_Frequency__c = 'Weekly';
        update accSer;
        Work_Order__c wo=[Select ID FROM Work_Order__c LIMIT 1];
        Delete wo;
        Timesheet__c insertTimeSheet1=[Select ID FROM Timesheet__c WHERE Account_Services__c=:accSer.id LIMIT 1];
        insertTimeSheet1.Status__c='Submitted';
        Update insertTimeSheet1;
        TimesheetTriggerHandler.sendTimesheet(insertTimeSheet1.id); 
        
    }
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody('{"response":"success"}');
            return response;
        }
    }
}