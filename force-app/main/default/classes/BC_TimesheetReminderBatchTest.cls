@isTest
public class BC_TimesheetReminderBatchTest {
    static TestMethod void biWeeklyTimesheet_Test() {
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
            accSrvc.Invoice_Frequency__c = 'Bi-Weekly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;
            Date thisWeekMonday = today.toStartOfWeek().addDays(1);
            Date endOfLastWeek = thisWeekMonday.addDays(-1); 
            Date startOfLastWeek = endOfLastWeek.addDays(-6);   
            
            Date endOfSecondLastWeek = startOfLastWeek.addDays(-1);
            Date startOfSecondLastWeek = endOfSecondLastWeek.addDays(-6);
            Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id, 300, startDate, endDate, string.valueOf(lastMonth), string.valueOf(lastYear));
            Timesheet__c insertTimeSheet1 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = startOfSecondLastWeek,Week_End_Date__c = endOfSecondLastWeek,Account_Services__c = accSrvc.Id);
            insert insertTimeSheet1;
            Time_Sheet_Details__c buildTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet1.Id, startOfSecondLastWeek.addDays(1));
            buildTS.Initiative_Billing_Type__c='Build';
            update buildTS;
            insertTimeSheet1.Status__c = 'Submitted';
            insertTimeSheet1.Non_Bi_Weekly__c=true;
            update insertTimeSheet1;
            Timesheet__c insertTimeSheet2 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = startOfLastWeek,Week_End_Date__c =endOfLastWeek,Account_Services__c = accSrvc.Id);
            insert insertTimeSheet2;
            Time_Sheet_Details__c adminTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet2.Id,  startOfLastWeek.addDays(0));
            adminTS.Initiative_Billing_Type__c='Admin';
            update adminTS;
            Time_Sheet_Details__c consultingTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet2.Id,  startOfLastWeek.addDays(1));
            consultingTS.Initiative_Billing_Type__c='Consulting';
            update consultingTS;
            insertTimeSheet2.Status__c = 'Saved';
            update insertTimeSheet2;
            
            
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
            //  User userId = [SELECT Id FROM User WHERE Name = 'Zeeshan Armar' and IsActive=true LIMIT 1];        
            //  User userId1 = [SELECT Id,Name FROM User WHERE Name = 'Selva Pandian' and IsActive=true LIMIT 1];
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=portalAccount1.Id,
                Project_Start_Date__c=system.today().addDays(-1),
                Project_End_Date__c=system.today().addDays(120),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Bi-Weekly',
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
            BC_TimesheetReminderBiWeeklyScheduler x = new BC_TimesheetReminderBiWeeklyScheduler();
            x.execute(null);
            Test.stopTest(); 
            
        }
    }
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
            Date endDate = startDate.addMonths(1).addDays(-1);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id, 'Technical Account Manager', portalAccountOwner1.Id, odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id, startDate, endDate, 150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Invoice_Frequency__c = 'Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;
            Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id, 300, startDate, endDate, string.valueOf(lastMonth), string.valueOf(lastYear));
            Timesheet__c insertTimeSheet1 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = startDate,Week_End_Date__c = startDate.addDays(6),Account_Services__c = accSrvc.Id);
            insert insertTimeSheet1;
            Time_Sheet_Details__c buildTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet1.Id, startDate.addDays(3));
            buildTS.Initiative_Billing_Type__c='Build';
            update buildTS;
            insertTimeSheet1.Status__c = 'Submitted';
            update insertTimeSheet1;
            Timesheet__c insertTimeSheet2 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = startDate.addDays(7),Week_End_Date__c = startDate.addDays(13),Account_Services__c = accSrvc.Id);
            insert insertTimeSheet2;
            Time_Sheet_Details__c adminTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet2.Id,  startDate.addDays(8));
            adminTS.Initiative_Billing_Type__c='Admin';
            update adminTS;
            Time_Sheet_Details__c consultingTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet2.Id,  startDate.addDays(9));
            consultingTS.Initiative_Billing_Type__c='Consulting';
            update consultingTS;
            insertTimeSheet2.Status__c = 'Saved';
            update insertTimeSheet2;
            
            
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
            //  User userId = [SELECT Id FROM User WHERE Name = 'Zeeshan Armar' and IsActive=true LIMIT 1];        
            //  User userId1 = [SELECT Id,Name FROM User WHERE Name = 'Selva Pandian' and IsActive=true LIMIT 1];
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=portalAccount1.Id,
                Project_Start_Date__c=system.today().addDays(-1),
                Project_End_Date__c=system.today().addDays(120),
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
            BC_TimesheetReminderMonthlyScheduler x = new BC_TimesheetReminderMonthlyScheduler();
            x.execute(null);
            Test.stopTest(); 
            
        }
    }
         static TestMethod void InsertTimeSheetDetailSemiMonthly_Test() {
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
            Integer day = today.day();
            Integer month = today.month();
            Integer year = today.year();
            Date startDate;
            Date endDate;
            if (day <= 15) {
                Date firstDayOfCurrentMonth = Date.newInstance(year, month, 1);
                Date lastDayOfPreviousMonth = firstDayOfCurrentMonth.addDays(-1);
                startDate = Date.newInstance(lastDayOfPreviousMonth.year(), lastDayOfPreviousMonth.month(), 16);
                endDate = lastDayOfPreviousMonth;
            } else {
                startDate = Date.newInstance(year, month, 1);
                endDate = Date.newInstance(year, month, 15);
            }
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id, 'Technical Account Manager', portalAccountOwner1.Id, odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id, startDate, endDate, 150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Invoice_Frequency__c = 'Semi-Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;
            Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id, 300, startDate, endDate, string.valueOf(month), string.valueOf(year));
            Timesheet__c insertTimeSheet1 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = startDate,Week_End_Date__c = startDate.addDays(6),Account_Services__c = accSrvc.Id);
            insert insertTimeSheet1;
            Time_Sheet_Details__c buildTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet1.Id, startDate.addDays(3));
            buildTS.Initiative_Billing_Type__c='Build';
            update buildTS;
            insertTimeSheet1.Status__c = 'Submitted';
            update insertTimeSheet1;
            Timesheet__c insertTimeSheet2 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = startDate.addDays(1),Week_End_Date__c = startDate.addDays(6),Account_Services__c = accSrvc.Id);
            insert insertTimeSheet2;
            Time_Sheet_Details__c adminTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet2.Id,  startDate.addDays(1));
            adminTS.Initiative_Billing_Type__c='Admin';
            update adminTS;
            Time_Sheet_Details__c consultingTS=ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet2.Id,  startDate.addDays(2));
            consultingTS.Initiative_Billing_Type__c='Consulting';
            update consultingTS;
            insertTimeSheet2.Status__c = 'Saved';
            update insertTimeSheet2;
            
            
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
            BC_TimesheetReminderSemiMonthlyScheduler x = new BC_TimesheetReminderSemiMonthlyScheduler();
            x.execute(null);
            Test.stopTest(); 
            
        }
    }
}