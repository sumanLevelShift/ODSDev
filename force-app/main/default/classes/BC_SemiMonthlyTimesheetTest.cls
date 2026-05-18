@isTest
public class BC_SemiMonthlyTimesheetTest {
    static TestMethod void InsertTimeSheetDetailABCType_Test() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount', 'California', True, 2000, '9433578865', 'Others', 'ODS Project');
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test', 'McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@test.com';
            update contact1;
            portalAccount1.ODS_Invoice_Account_Number__c = 'C45';
            portalAccount1.Invoice_Type__c = 'Paper';
            portalAccount1.Primary_Customer_Contact__c = contact1.Id;
            portalAccount1.InvoiceContact__c = contact1.Id;
            portalAccount1.BillingCity = 'Chennai';
            portalAccount1.BillingStreet = 'Siruseri';
            portalAccount1.BillingState = 'Tamilnadu';
            portalAccount1.BillingCountry = 'India';
            portalAccount1.BillingPostalcode = '640000';
            portalAccount1.ODS_Invoice_Count__c = 10;
            portalAccount1.Customer_Type__c='ABC Type';
            update portalAccount1;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet', 'test', true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', portalAccount1.Id, odsSrv.Id);
            Date today = Date.today();
            Integer lastMonth = today.month() - 1;
            Integer lastYear = today.year();
            if (lastMonth == 0) {
                lastMonth = 12;
                lastYear--;
            }
            
            Date startDate = Date.newInstance(lastYear, lastMonth, 1);
            Date endDate = startDate.addMonths(3).addDays(-1);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id, 'Technical Account Manager', portalAccountOwner1.Id, odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id, startDate, endDate, 150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Invoice_Frequency__c = 'Semi-Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;
            Date todayDate = Date.today();
            Date weekStart, weekEnd;
            Integer day = todayDate.day();
            Integer month = todayDate.month();
            Integer year = todayDate.year();
            if (day <= 15) {
                Date firstDayOfCurrentMonth = Date.newInstance(year, month, 1);
                Date lastDayOfPreviousMonth = firstDayOfCurrentMonth.addDays(-1);
                weekStart = Date.newInstance(lastDayOfPreviousMonth.year(), lastDayOfPreviousMonth.month(), 16);
                weekEnd = weekStart.addDays(6);
            } else {
                weekStart = Date.newInstance(year, month, 1);
                weekEnd = weekStart.addDays(6);
            }
            
            Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id, 300, startDate, endDate, string.valueOf(lastMonth), string.valueOf(lastYear));
            Timesheet__c insertTimeSheet1 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = weekStart,Week_End_Date__c = weekEnd,Account_Services__c = accSrvc.Id);
            insert insertTimeSheet1;
            Time_Sheet_Details__c buildTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet1.Id, weekStart.addDays(2));
            buildTS.Initiative_Billing_Type__c='Build';
            update buildTS;
            insertTimeSheet1.Status__c = 'Submitted';
            update insertTimeSheet1;

            List < Timesheet__c > TSList = new List < Timesheet__c > ();
            Timesheet__c TS = new Timesheet__c();
            TS.Time_Sheet_Cost__c = objTmeShtCst1.Id;
            insert TS;
            TSList.add(TS);
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

            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=portalAccount1.Id,
                Project_Start_Date__c=system.today().addDays(-1),
                Project_End_Date__c=system.today().addDays(120),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Semi-Monthly',
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
                Contact_for_Payment_followUp__c=contact1.Id,
                TIPS_CNSMP_WO_ID__c='1234',
                Same_as_the_Invoice_Contact__c=true,
                TIPS_Admin_CNSMP_WO_ID__c='0987',
                TIPS_Consulting_CNSMP_WO_ID__c='6789',
                BC_Admin_CNSMP_WO_ID__c='test1',
                BC_Build_CNSMP_WO_ID__c='test2',
                BC_Consulting_CNSMP_WO_ID__c='test3'
            );
            
            insert workorderObject2;
            Test.startTest();
            BC_SemiMonthlyTimesheetSchedular x = new BC_SemiMonthlyTimesheetSchedular();
            x.execute(null);
            Test.stopTest(); 
            
        }
    }
    static TestMethod void InsertTimeSheetDetail_Test() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount', 'California', True, 2000, '9433578865', 'Others', 'ODS Project');
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test', 'McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@test.com';
            update contact1;
            portalAccount1.ODS_Invoice_Account_Number__c = 'C45';
            portalAccount1.Invoice_Type__c = 'Paper';
            portalAccount1.Primary_Customer_Contact__c = contact1.Id;
            portalAccount1.InvoiceContact__c = contact1.Id;
            portalAccount1.BillingCity = 'Chennai';
            portalAccount1.BillingStreet = 'Siruseri';
            portalAccount1.BillingState = 'Tamilnadu';
            portalAccount1.BillingCountry = 'India';
            portalAccount1.BillingPostalcode = '640000';
            portalAccount1.ODS_Invoice_Count__c = 10;
            update portalAccount1;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet', 'test', true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', portalAccount1.Id, odsSrv.Id);
            Date today = Date.today();
            Integer lastMonth = today.month() - 1;
            Integer lastYear = today.year();
            if (lastMonth == 0) {
                lastMonth = 12;
                lastYear--;
            }
            
            Date startDate = Date.newInstance(lastYear, lastMonth, 1);
            system.debug('startDate-'+startDate);
            Date endDate = startDate.addMonths(2).addDays(-1);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id, 'Technical Account Manager', portalAccountOwner1.Id, odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id, startDate, endDate, 150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Invoice_Frequency__c = 'Semi-Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;
            
             Date todayDate = Date.today();
            Date weekStart, weekEnd;

            Integer day = todayDate.day();
            Integer month = todayDate.month();
            Integer year = todayDate.year();
            
            if (day <= 15) {
                Date firstDayOfCurrentMonth = Date.newInstance(year, month, 1);
                Date lastDayOfPreviousMonth = firstDayOfCurrentMonth.addDays(-1);
                weekStart = Date.newInstance(lastDayOfPreviousMonth.year(), lastDayOfPreviousMonth.month(), 16);
                weekEnd = weekStart.addDays(6);
            } else {
                weekStart = Date.newInstance(year, month, 1);
                weekEnd = weekStart.addDays(6);
            }
            system.debug('weekStart-'+weekStart);
            system.debug('weekEnd-'+weekEnd);
            Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id, 300, startDate, endDate, string.valueOf(lastMonth), string.valueOf(lastYear));
            Timesheet__c insertTimeSheet1 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = weekStart,Week_End_Date__c = weekEnd,Account_Services__c = accSrvc.Id);
            insert insertTimeSheet1;
            ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet1.Id, weekStart.addDays(3));
            insertTimeSheet1.Status__c = 'Submitted';
            update insertTimeSheet1;

            List < Timesheet__c > TSList = new List < Timesheet__c > ();
            Timesheet__c TS = new Timesheet__c();
            TS.Time_Sheet_Cost__c = objTmeShtCst1.Id;
            insert TS;
            TSList.add(TS);
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
            
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=portalAccount1.Id,
                Project_Start_Date__c=startDate,
                Project_End_Date__c=system.today().addDays(120),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Semi-Monthly',
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
                Contact_for_Payment_followUp__c=contact1.Id,
                TIPS_CNSMP_WO_ID__c='1234',
                Same_as_the_Invoice_Contact__c=true,
                BC_Admin_CNSMP_WO_ID__c='test1',
                BC_Build_CNSMP_WO_ID__c='test2',
                BC_Consulting_CNSMP_WO_ID__c='test3'
            );
            
            insert workorderObject2;
            Test.startTest();
            BC_BiWeeklyTimesheetSchedular x = new BC_BiWeeklyTimesheetSchedular();
            x.execute(null);
            Test.stopTest(); 
            
        }
    }
    
    static TestMethod void InsertTimeSheetDetailWeeklyEmail_Test() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount', 'California', True, 2000, '9433578865', 'Others', 'ODS Project');
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test', 'McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@test.com';
            update contact1;
            portalAccount1.ODS_Invoice_Account_Number__c = 'C45';
            portalAccount1.Invoice_Type__c = 'Paper';
            portalAccount1.Primary_Customer_Contact__c = contact1.Id;
            portalAccount1.InvoiceContact__c = contact1.Id;
            portalAccount1.BillingCity = 'Chennai';
            portalAccount1.BillingStreet = 'Siruseri';
            portalAccount1.BillingState = 'Tamilnadu';
            portalAccount1.BillingCountry = 'India';
            portalAccount1.BillingPostalcode = '640000';
            portalAccount1.ODS_Invoice_Count__c = 10;
            update portalAccount1;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet', 'test', true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', portalAccount1.Id, odsSrv.Id);
            
            Date today = Date.today();
            Integer lastMonth = today.month() - 1;
            Integer lastYear = today.year();
            if (lastMonth == 0) {
                lastMonth = 12;
                lastYear--;
            }
            
            Date startDate = Date.newInstance(lastYear, lastMonth, 1);
            Date endDate = startDate.addMonths(2).addDays(-1);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id, 'Technical Account Manager', portalAccountOwner1.Id, odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id, startDate, endDate, 150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Invoice_Frequency__c = 'Semi-Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;
            Date todayDate = Date.today();
            Date weekStart, weekEnd;
            Integer day = todayDate.day();
            Integer month = todayDate.month();
            Integer year = todayDate.year();
            if (day <= 15) {
                Date firstDayOfCurrentMonth = Date.newInstance(year, month, 1);
                Date lastDayOfPreviousMonth = firstDayOfCurrentMonth.addDays(-1);
                weekStart = Date.newInstance(lastDayOfPreviousMonth.year(), lastDayOfPreviousMonth.month(), 16);
                weekEnd = weekStart.addDays(6);
            } else {
                weekStart = Date.newInstance(year, month, 1);
                weekEnd = weekStart.addDays(6);
            }
            Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id, 300, startDate, endDate, string.valueOf(lastMonth), string.valueOf(lastYear));
            Timesheet__c insertTimeSheet1 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = weekStart,Week_End_Date__c = weekEnd,Account_Services__c = accSrvc.Id);
            insert insertTimeSheet1;
            ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet1.Id, weekStart.addDays(1));
            insertTimeSheet1.Status__c = 'Submitted';
            update insertTimeSheet1;

            
            
            /*****To handle exception*****/
            List < Timesheet__c > TSList = new List < Timesheet__c > ();
            Timesheet__c TS = new Timesheet__c();
            TS.Time_Sheet_Cost__c = objTmeShtCst1.Id;
            insert TS;
            TSList.add(TS);
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
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=portalAccount1.Id,
                Project_Start_Date__c=startDate,
                Project_End_Date__c=endDate,
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription-CO',
                Pay_Rate__c=85,
                Billing_Frequency__c='Semi-Monthly',
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
                Contact_for_Payment_followUp__c=contact1.Id,
                Same_as_the_Invoice_Contact__c=true
            );
            
            insert workorderObject2;
            
            String endpoint = 'https://test.com/api';
            String body = '{"key":"value"}';
            String methodType = 'POST';
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Test.startTest();
            BC_SemiMonthlyTimesheetSchedular x = new BC_SemiMonthlyTimesheetSchedular();
            x.execute(null);           
            Test.stopTest();
        }
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