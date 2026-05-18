@isTest
public class ODS_TimesheetController_Test
{
    static TestMethod void Constructor_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {    
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            insertTimeSheet.Account_Services__c=accSrvc.id;
            update insertTimeSheet;
            string strAcntId = string.valueOf(portalAccount1.Id);
            string strSrvId = string.valueOf(odsSrv.Id);
            string strTimeSheetId = string.valueof(insertTimeSheet.Id);
            ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
            objTmeShtCntlr.CurrenTimesheetId = insertTimeSheet.id;
            objTmeShtCntlr.AccountId = portalAccount1.id;
            objTmeShtCntlr.ServiceId = odsSrv.id;
            objTmeShtCntlr.GetTimesheetDetails(strTimeSheetId);
            List<string> optionValuesTPM = objTmeShtCntlr.getTechnicalProjectManager;
            objTmeShtCntlr.initId = initiative.id;
            objTmeShtCntlr.selectedInitiativeRecord();
            //objTmeShtCntlr.TimesheetTable();
            objTmeShtCntlr.AssignPassedAccountService();
            ODS_TimesheetController.GetAccountPicklistValues();
            objTmeShtCntlr.GetLoggedUserAccountService();
            objTmeShtCntlr.GetAccountServiceChanges();
            objTmeShtCntlr.redirectToTimeSheet();
            
            objTmeShtCntlr.CurrentAccServiceId = accSrvc.Id;
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"Development","Mon":"1","Tue":"3","Wed":"","Thu":"0.5","Fri":"0.5","Sat":"","Sun":""},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"Code Coverage","Mon":"2","Tue":"1","Wed":"4","Thu":"3","Fri":"2","Sat":"1","Sun":"0.5"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"Development","Mon":"1","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"DevelopmentV1","Mon":"1","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"Development","Mon":"1","Tue":"3","Wed":"","Thu":"0.5","Fri":"0.5","Sat":"","Sun":""}]';
            objTmeShtCntlr.getInitList();
            //objTmeShtCntlr.selectedInitiativeRecord;
            objTmeShtCntlr.objTimesheetCost = objTmeShtCst ;
            objTmeShtCntlr.UpdateODSHoursAndResCountInCost(insertTimeSheet);
            objTmeShtCntlr.DeleteExistingTimesheetDetail(strTimeSheetId );
            objTmeShtCntlr.getInitiativeBillingType=new list<string>();
        }
    }
    
    static TestMethod void GetTimeSheetDetails_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {     
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'PCPHP');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            string strTimeSheetId = string.valueof(insertTimeSheet.Id);
            ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
            objTmeShtCntlr.CurrenTimesheetId = insertTimeSheet.id;
            objTmeShtCntlr.GetTimesheetDetails(strTimeSheetId);
            objTmeShtCntlr.FetchExistingTimesheetDetails(strTimeSheetId);
        }
    }
    
    static TestMethod void GetTimeSheetDetails_PositiveTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {    
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSSFDC');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
           
            portalAccount1.User__c=user1.id;
            portalAccount1.Backup_CSM__c=user1.id;
            update portalAccount1;
            UserRole testRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Vice_President_Sales'];
            User testUser = new User(Username = 'testuser@example.comVPS',FirstName = 'Test',LastName = 'User', Email = 'testuser@example.com',Alias = 'testusr',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = UserInfo.getProfileId(),LanguageLocaleKey = 'en_US',UserRoleId = testRole.Id );
            insert testUser;
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=portalAccount1.Id,
                Project_Start_Date__c=system.today().addDays(-1),
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
                Contact_for_Payment_followUp__c=contact1.Id,
                TIPS_CNSMP_WO_ID__c='1234',
                TIPS_Admin_CNSMP_WO_ID__c='0987',
                TIPS_Consulting_CNSMP_WO_ID__c='6789',
                Same_as_the_Invoice_Contact__c=true
            );
            
            insert workorderObject2;
           
            PageReference pageRef = Page.TimesheetPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',insertTimeSheet.id);
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
            ApexPages.currentPage().getParameters().put('Status','Submitted');
            ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
            ODS_TimesheetController.sendMailWOExpired(insertTimeSheet);
        }
    }
    
    static TestMethod void GetTimeSheetDetails_NegativeTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName', objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            
            system.RunAs(user1){
                PageReference pageRef = Page.TimesheetPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id',insertTimeSheet.id);
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
                ApexPages.currentPage().getParameters().put('Status','Submitted');
                ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
                objTmeShtCntlr.GetTimesheetDetails(insertTimeSheet.id);
            }
        }
    }
    
    static TestMethod void GetLoggedUserAccountService_PositiveTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'PCSFDC');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            
            system.RunAs(user1){
                PageReference pageRef = Page.TimesheetPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id',insertTimeSheet.id);
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
                ApexPages.currentPage().getParameters().put('Status','Submitted');
                ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
                objTmeShtCntlr.GetTimesheetDetails(insertTimeSheet.id);                
                objTmeShtCntlr.GetLoggedUserAccountService();
            }
        }
    }
    
    static TestMethod void SetRelatedService_PositiveTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSNET');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            
            system.RunAs(user1){
                PageReference pageRef = Page.TimesheetPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id',insertTimeSheet.id);
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
                ApexPages.currentPage().getParameters().put('Status','Submitted');
                ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
                objTmeShtCntlr.GetTimesheetDetails(insertTimeSheet.id);                
                objTmeShtCntlr.GetLoggedUserAccountService();
                objTmeShtCntlr.SetRelatedService();
            }
        }
    }
    
    static TestMethod void ApproveTimesheet_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);  
        User portalAccountOwner2 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','TestAccount',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test1234@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654','Others', 'ODS Project');    
            portalAccount1.Customer_Type__c='ABC Type';
            update portalAccount1;
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            //Insert Project Team Member
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'PCSQL');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            
            test.startTest();            
            Date dtStatus = date.parse('11/10/2016');
            Date WeekStartdt= date.parse('11/07/2016');
            Date WeekEndDt = date.parse('11/13/2016');
            Timesheet__c objTmeSht = new Timesheet__c (Name = 'Test1',Time_Sheet_Cost__c = objTmeShtCst.Id,Approver_Name__c = portalAccountOwner1.Id,Approver_Email__c = 'TestApprvEmail@gmail.com',Comments__c = 'Test', Status_Date__c = dtStatus, Week_Start_Date__c = WeekStartdt, Week_End_Date__c=WeekEndDt, Account_Services__c=accSrvc.Id,Status__c = 'Approved');
            insert objTmeSht;
            User_Account__c objUsrPht = new User_Account__c(Account__c=portalAccount1.Id,Role_in_Account__c='Technical Account Manager',User__c=portalAccountOwner2.Id);
            insert objUsrPht;
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            string strTimeSheetId = string.valueof(objTmeSht.Id);
            PageReference pageRef = Page.TimesheetPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',strTimeSheetId);
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
            ApexPages.currentPage().getParameters().put('Status','Submitted');
            ApexPages.currentPage().getParameters().put('WeekStart', strtDt.format());
            ApexPages.currentPage().getParameters().put('WeekEnd', endDt.format());
            string JSONValue = '{"WeekStartDate":"' + strtDt.format() +'","WeekEndDate":"' + endDt.format() +'","Status":"Submitted","TimesheetDtls":[{"RowNo":1,"TaskName":"test","ResourceName":"Arun","TDate":"11/7/2016","Hrs":"2","ResourceId":"'+strPrjtTeaMbId+'"},{"RowNo":1,"TaskName":"test","ResourceName":"test","TDate":"11/8/2016","Hrs":"8","ResourceId":"'+strPrjtTeaMbId+'"}],"TotalHours":10}';
            ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
            objTmeShtCntlr.PassedTimesheetJSON = JSONValue ;
            objTmeShtCntlr.ApproveTimesheet();      
        }
    }
    
    static TestMethod void RejectTimesheet_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);  
        User portalAccountOwner2 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','TestAccount',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test1234@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {    
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'PCNET');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            
            test.startTest();            
            Date dtStatus = date.parse('11/10/2016');
            Date WeekStartdt= date.parse('11/07/2016');
            Date WeekEndDt = date.parse('11/13/2016');
            Timesheet__c objTmeSht = new Timesheet__c (Name = 'Test1',Time_Sheet_Cost__c = objTmeShtCst.Id,Approver_Name__c = portalAccountOwner1.Id,Approver_Email__c = 'TestApprvEmail@gmail.com',Comments__c = 'Test', Status_Date__c = dtStatus, Week_Start_Date__c = WeekStartdt, Week_End_Date__c=WeekEndDt, Account_Services__c=accSrvc.Id,Status__c = 'Approved');
            insert objTmeSht;
            User_Account__c objUsrPht = new User_Account__c(Account__c=portalAccount1.Id,Role_in_Account__c='Technical Account Manager',User__c=portalAccountOwner2.Id);
            insert objUsrPht;
            
            string strTimeSheetId = string.valueof(objTmeSht.Id);
            PageReference pageRef = Page.TimesheetPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',strTimeSheetId);
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
            ApexPages.currentPage().getParameters().put('Status','Submitted');
            ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
            objTmeShtCntlr.RejectTimesheet();            
        }
    }
    
    static TestMethod void SaveTimesheet_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');
            portalAccount1.Customer_Type__c='ABC Type';
            update portalAccount1;
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email='test@demandblue.com';
            update contact1;
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Invoice_Frequency__c='Weekly';
            update accSrvc;
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            insertTimeSheet.Account_Services__c=accSrvc.id;
            insertTimeSheet.Approver_Name__c=user1.id;
            update insertTimeSheet;
            system.RunAs(user1){
                PageReference pageRef = Page.TimesheetPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id',insertTimeSheet.id);
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
                ApexPages.currentPage().getParameters().put('Status','Submitted');
                ApexPages.currentPage().getParameters().put('WeekStart', strtDt.format());
                ApexPages.currentPage().getParameters().put('WeekEnd', endDt.format());
                string JSONValue = '{"WeekStartDate":"' + strtDt.format() +'","WeekEndDate":"' + endDt.format() +'","Status":"Saved","TimesheetDtls":[{"RowNo":1,"TaskName":"test","ResourceName":"Arun","TDate":"11/7/2016","Hrs":"2","ResourceId":"'+strPrjtTeaMbId+'"},{"RowNo":1,"TaskName":"test","ResourceName":"test","TDate":"11/8/2016","Hrs":"8","ResourceId":"'+strPrjtTeaMbId+'"}],"TotalHours":10}';
                ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
                objTmeShtCntlr.ClientContact=contact1.id;
                objTmeShtCntlr.hdnActionValue='Submitted';
                objTmeShtCntlr.PassedTimesheetJSON = JSONValue ;
                ODS_TimesheetController.sendSubmittedTimesheetEmail(insertTimeSheet.id);
                //objTmeShtCntlr.SaveTimesheet();
                objTmeShtCntlr.exportAsPDF();
                objTmeShtCntlr.exportAsExcel();
                //  objTmeShtCntlr.selectedInitiativeRecord();
                objTmeShtCntlr.getInitList();
                
                //objTmeShtCntlr.TimesheetTable();
            }
        }
    }
    static TestMethod void CatchError_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
            objTmeShtDtl.Hours_Worked__c = 2;
            objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
            objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
            objTmeShtDtl.Timesheet__c = insertTimeSheet.Id;
            objTmeShtDtl.Timesheet_Date__c = date.parse('11/29/2016'); 
            objTmeShtDtl.Intiative__c=initiative.id;
            insert objTmeShtDtl;
            Time_Sheet_Details__c objTmeShtDtl1 = new Time_Sheet_Details__c();
            objTmeShtDtl1.Hours_Worked__c = 2;
            objTmeShtDtl1.Resource_Id__c = ObjTeamMembr.Id;
            objTmeShtDtl1.Resource__c = ObjTeamMembr.Resource_Name__c  ;
            objTmeShtDtl1.Timesheet__c = insertTimeSheet.Id;
            objTmeShtDtl1.Timesheet_Date__c = date.parse('11/28/2016'); 
            objTmeShtDtl1.Intiative__c=initiative.id;
            insert objTmeShtDtl1;
            string strTimeSheetId = string.valueof(insertTimeSheet.Id);
            system.RunAs(user1){
                PageReference pageRef = Page.TimesheetPage;
                Test.setCurrentPage(pageRef);
                ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
                try{
                    ApexPages.currentPage().getParameters().put('Id',insertTimeSheet.id);
                    ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
                    ApexPages.currentPage().getParameters().put('CurrenTimesheetId',insertTimeSheet.id);
                    ApexPages.currentPage().getParameters().put('Status','Submitted');
                    
                    ApexPages.currentPage().getParameters().put('WeekStart', strtDt.format());
                    ApexPages.currentPage().getParameters().put('WeekEnd', endDt.format());
                    string JSONValue = '{"WeekStartDate":"'+'","WeekEndDate":"' + endDt.format() +'","Status":"Saved","TimesheetDtls":[{"RowNo":1,"TaskName":"test","ResourceName":"Arun","TDate":"11/7/2016","Hrs":"2","IntiativeId" : "'+initiative.Id+'", "IntiativeName": "Test Initiative","ResourceId":"'+strPrjtTeaMbId+'"},{"RowNo":1,"TaskName":"test","ResourceName":"test","TDate":"11/8/2016","Hrs":"8","ResourceId":"'+strPrjtTeaMbId+'"}],"TotalHours":10}'+'{';
                    objTmeShtCntlr.PassedTimesheetJSON = JSONValue ;
                    //  objTmeShtCntlr.CurrenTimesheetId = insertTimeSheet.id;
                    objTmeShtCntlr.AccountId = 'Test23';
                    objTmeShtCntlr.ServiceId = 'DummyID34';
                    objTmeShtCntlr.DeleteExistingTimesheetDetail(strTimeSheetId );
                    
                    objTmeShtCntlr.GetTimesheetDetails(strTimeSheetId);
                    objTmeShtCntlr.AssignPassedAccountService();
                    ODS_TimesheetController.GetAccountPicklistValues();
                    objTmeShtCntlr.GetLoggedUserAccountService();
                    List<string> optionValuesTPM = objTmeShtCntlr.getTechnicalProjectManager;
                    objTmeShtCntlr.initId = initiative.id;
                    objTmeShtCntlr.selectedInitiativeRecord();
                    objTmeShtCntlr.GetAccountServiceChanges();
                    objTmeShtCntlr.redirectToTimeSheet();
                    objTmeShtCntlr.getInitList();
                    // objTmeShtCntlr.selectedInitiativeRecord();
                    objTmeShtCntlr.GetWeeklyTimesheet();
                    objTmeShtCntlr.SaveTimesheet();
                    objTmeShtCntlr.GetTimesheetByAccountServiceID();
                    objTmeShtCntlr.ReDirectToViewTimesheet();
                    objTmeShtCntlr.RejectTimesheet();
                    objTmeShtCntlr.ApproveTimesheet();  
                    objTmeShtCntlr.exportAsPDF();
                    objTmeShtCntlr.exportAsExcel();
                    objTmeShtCntlr.GetTimeSheetIdFromAction();
                    objTmeShtCntlr.AddRow();
                    
                    
                    // objTmeShtCntlr.CurrentAccServiceId = accSrvc.Id;
                    //  objTmeShtCntlr.objTimesheetCost = objTmeShtCst ;
                    objTmeShtCntlr.UpdateODSHoursAndResCountInCost(insertTimeSheet);
                    
                }
                catch(exception e)
                {
                    system.assertEquals(e.getMessage(),e.getMessage());
                }
                
            }
        }
    }
    
    static TestMethod void SaveTimesheetWithInitiative_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            
            system.RunAs(user1){
                PageReference pageRef = Page.TimesheetPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id',insertTimeSheet.id);
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
                ApexPages.currentPage().getParameters().put('Status','Submitted');
                ApexPages.currentPage().getParameters().put('WeekStart', strtDt.format());
                ApexPages.currentPage().getParameters().put('WeekEnd', endDt.format());
                string JSONValue = '{"WeekStartDate":"' + strtDt.format() +'","WeekEndDate":"' + endDt.format() +'","Status":"Saved","TimesheetDtls":[{"RowNo":1,"TaskName":"test","ResourceName":"Arun","TDate":"11/7/2016","Hrs":"2","IntiativeId" : "'+initiative.Id+'", "IntiativeName": "Test Initiative","ResourceId":"'+strPrjtTeaMbId+'"},{"RowNo":1,"TaskName":"test","ResourceName":"test","TDate":"11/8/2016","Hrs":"8","ResourceId":"'+strPrjtTeaMbId+'"}],"TotalHours":10}';
                ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
                objTmeShtCntlr.PassedTimesheetJSON = JSONValue ;
                objTmeShtCntlr.SaveTimesheet();
                
            }
        }
    }
    
    static TestMethod void GetWeeklyTimesheet_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8', 'Indumathi',
                                                                                   'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 
                                                                                   'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {    
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSSQL');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            string WeekSrtDt = '11/07/2016';
            string WeekEdDt = '11/13/2016';
            ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
            objTmeShtCntlr.CurrenTimesheetId = insertTimeSheet.id;
            objTmeShtCntlr.PassedWeekFromDate = WeekSrtDt;
            objTmeShtCntlr.PassedWeekToDate = WeekEdDt;
            objTmeShtCntlr.CurrentAccServiceId = WeekEdDt;
            objTmeShtCntlr.GetWeeklyTimesheet();
            objTmeShtCntlr.GetTimesheetByAccountServiceID();
            objTmeShtCntlr.ReDirectToViewTimesheet();
            
        }
    }
    
    static TestMethod void InsertTimeSheetDetail_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');                             
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@demandblue.com';
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
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Invoice_Frequency__c = 'Weekly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;                             
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 50;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate;  
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas;
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            ODS_Invoice_EmailControl__c cst = new ODS_Invoice_EmailControl__c();
            cst.name = 'ccPracticeHead';
            cst.isAllowed__c = false;
            insert cst;
            Integer mNumb = System.Today().month();
            String mName = '';
            if(mNumb==1)mName='January';else if(mNumb==2)mName='February';
            else if(mNumb==3)mName='March';else if(mNumb==4)mName='April';
            else if(mNumb==5)mName='May';else if(mNumb==6)mName='June';
            else if(mNumb==7)mName='July';else if(mNumb==8)mName='August';
            else if(mNumb==9)mName='September';else if(mNumb==10)mName='October';
            else if(mNumb==11)mName='November';else mName='December';
            ODS_Invoice_Month__c invm = new ODS_Invoice_Month__c();
            invm.name=String.valueOf(System.Today().month());
            invm.MonthName__c=mName; 
            insert invm;         
            system.RunAs(user1){
                PageReference pageRef = Page.TimesheetPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id',insertTimeSheet.id);
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
                ApexPages.currentPage().getParameters().put('Status','Submitted');
                ApexPages.currentPage().getParameters().put('WeekStart', strtDt.format());
                ApexPages.currentPage().getParameters().put('WeekEnd', endDt.format());
                string JSONValue = '{"WeekStartDate":"' + strtDt.format() +'","WeekEndDate":"' + endDt.format() +'","Status":"Saved","TimesheetDtls":[{"RowNo":1,"TaskName":"test","ResourceName":"Arun","TDate":"11/7/2016","Hrs":"2","IntiativeId" : "'+initiative.Id+'", "IntiativeName": "Test Initiative","ResourceId":"'+strPrjtTeaMbId+'"},{"RowNo":1,"TaskName":"test","ResourceName":"test","TDate":"11/8/2016","Hrs":"8","ResourceId":"'+strPrjtTeaMbId+'"}],"TotalHours":10}';
                ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
                objTmeShtCntlr.PassedTimesheetJSON = JSONValue;
                objTmeShtCntlr.hdnActionValue = 'Submitted';
                //objTmeShtCntlr.SaveTimesheet();
                objTmeShtCntlr.getResourceNameByAccountServiceId('test','');
                objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"Development","Mon":"1","Tue":"3","Wed":"","Thu":"0.5","Fri":"0.5","Sat":"","Sun":""},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"Code Coverage","Mon":"2","Tue":"1","Wed":"4","Thu":"3","Fri":"2","Sat":"1","Sun":"0.5"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"Development","Mon":"1","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"DevelopmentV1","Mon":"1","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"Development","Mon":"1","Tue":"3","Wed":"","Thu":"0.5","Fri":"0.5","Sat":"","Sun":""}]';
                objTmeShtCntlr.getInitList();
                //objTmeShtCntlr.selectedInitiativeRecord();
                
                Date Startdte1 = date.parse('10/30/2016');
                Date Enddte1 = date.parse('11/07/2016');
                // Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte1,Enddte1,'11','2016');
                //Timesheet__c insertTimeSheet1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst1.Id,date.parse('10/30/2016'),date.parse('11/07/2016'));
                //objTmeShtCntlr.UpdateODSHoursAndResCountInCost(insertTimeSheet1);
            }
        }
    }   
    
    @isTest
    public static void FetchExistingTimesheetDetailsTest(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        
        Account portalAccount1 = new Account();
        portalAccount1.Name = 'TestAccount';
        portalAccount1.OwnerID = UserInfo.getUserId();
        portalAccount1.Is_Portal_Access__c = true;
        portalAccount1.AnnualRevenue = 3000000;
        portalAccount1.Phone = '9678554553';
        portalAccount1.Lead_Gen_Name__c = 'Others';
        portalAccount1.If_Others_Please_Specify__c = 'ODS Project';
        portalAccount1.NumberofEmployees = 100;
        portalAccount1.Industry = 'Technology';
        portalAccount1.isPartner__c = true;
        portalAccount1.Partner_Commission__c = 10;
        insert portalAccount1;
        
        Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
        
        Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
        User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                        'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                        'test12345@test.com', contact1.Id,'Partner');
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert user
        User usrObj1 = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                             'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                             'test123@testmail.com','Practice Head',true, true); 
        
        Account odsAcc1 = new Account();
        odsAcc1.Name = 'TestOdsAccount';
        odsAcc1.OwnerID = usrObj1.Id;
        odsAcc1.Is_Portal_Access__c = true;
        odsAcc1.AnnualRevenue = 3000000;
        odsAcc1.Phone = '9678554553';
        odsAcc1.Lead_Gen_Name__c = 'Others';
        odsAcc1.If_Others_Please_Specify__c = 'ODS Project';
        odsAcc1.NumberofEmployees = 100;
        odsAcc1.Industry = 'Technology';
        odsAcc1.Channel_Partner__c = portalAccount1.Id;
        odsAcc1.Channel_Partner_Contact__c = contact1.Id;
        insert odsAcc1;
        
        Contact odsCont1 = ODS_DataFactory_Test_Utility.InsertContact('TestOds','McTesty1', True, odsAcc1.Id, 'Others', 'ODS Project');
        
        ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
        
        Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',odsAcc1.Id,odsSrv.Id);
        
        User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(odsAcc1.id,'Technical Account Manager',
                                                                             usrObj1.Id,odsSrv.Id);
        
        //Custom settings for invoice related stories
        ODS_Invoice_EmailControl__c cst = new ODS_Invoice_EmailControl__c();
        cst.name = 'sendInvoiceEmail';
        cst.isAllowed__c = true;
        insert cst;
        
        ODS_Invoice_EmailControl__c cst1 = new ODS_Invoice_EmailControl__c();
        cst1.name = 'ccPracticeHead';
        cst1.isAllowed__c = false;
        insert cst1;
        
        Contact_Account_Service__c cas = new Contact_Account_Service__c();
        cas.Account__c = portalAccount1.Id;
        cas.Contact__c = contact1.Id;
        cas.Is_Approver__c = true;
        cas.ODS_Service__c = odsSrv.Id;
        cas.Type_of_Engagement__c = 'ODS';
        insert cas;
        
        Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
        cas1.Account__c = portalAccount1.Id;
        cas1.Contact__c = contact1.Id;
        cas1.Is_Approver__c = true;
        cas1.ODS_Service__c = odsSrv.Id;
        cas1.Type_of_Engagement__c = 'ODS';
        insert cas1;
        
        string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
        date strtDt =  System.Today().addYears(-1);
        date endDt = System.Today().addYears(2);
        Date Startdte = System.Today().addYears(-1);
        Date Enddte = System.Today().addYears(2);
        Date thisMonthStart = System.Today().toStartOfMonth();
        Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
        Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
        
        Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(odsAcc1.id,strtDt, endDt,
                                                                                         150.0, odsSrv.id, 100000000, 'Monthly', usrObj1.Id, 'Salesforce');
        accSrvc.Invoice_Frequency__c = 'Weekly';
        accSrvc.Contract_Term__c = 'Net 30';
        update accSrvc;
        
        Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
        
        Estimate__c estimate = new Estimate__c();
        estimate.Hours__c = 50;
        estimate.Initiative_Lookup__c = initiative.Id;
        estimate.Phase__c = 'Analysis';
        estimate.Task_Components__c = 'Test';
        insert estimate;  
        
        Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
        
        Date startOfWeek1 = thisMonthStart.toStartOfWeek();
        Date endOfWeek1 = startOfWeek1.addDays(7);
        Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
        insertTimeSheetWeek1.Status__c = 'Submitted';
        insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
        insertTimeSheetWeek1.Approver_Name__c=user1.id;
        update insertTimeSheetWeek1;
        
        Date startOfWeek2 = endOfWeek1.addDays(1);
        Date endOfWeek2 = startOfWeek2.addDays(7);
        Timesheet__c insertTimeSheetWeek2 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName2',objTmeShtCst.Id,startOfWeek2,endOfWeek2);
        insertTimeSheetWeek2.Status__c = 'Submitted';
        insertTimeSheetWeek2.Account_Services__c = accSrvc.Id;
        update insertTimeSheetWeek2;
        Date startOfWeek3 = endOfWeek2.addDays(1);
        Date endOfWeek3 = startOfWeek3.addDays(7);
        Timesheet__c insertTimeSheetWeek3 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName3',objTmeShtCst.Id,startOfWeek3,endOfWeek3);
        insertTimeSheetWeek3.Status__c = 'Submitted';
        insertTimeSheetWeek3.Account_Services__c = accSrvc.Id;
        update insertTimeSheetWeek3;
        Date startOfWeek4 = endOfWeek3.addDays(1);
        Date endOfWeek4 = startOfWeek4.addDays(7);
        Timesheet__c insertTimeSheetWeek4 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName4',objTmeShtCst.Id,startOfWeek4,endOfWeek4);
        insertTimeSheetWeek4.Status__c = 'Submitted';
        insertTimeSheetWeek4.Account_Services__c = accSrvc.Id;
        update insertTimeSheetWeek4;
        Date startOfWeek5 = endOfWeek4.addDays(1);
        Date endOfWeek5 = startOfWeek5.addDays(7);
        Timesheet__c insertTimeSheetWeek5 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName5',objTmeShtCst.Id,startOfWeek5,endOfWeek5);
        insertTimeSheetWeek5.Status__c = 'Submitted';
        insertTimeSheetWeek5.Account_Services__c = accSrvc.Id;
        update insertTimeSheetWeek5;
        
        
        Date tdsStart1 = startOfWeek1.addDays(-1);
        
        Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
        objTmeShtDtl.Hours_Worked__c = 2;
        objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
        objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
        objTmeShtDtl.Timesheet__c = insertTimeSheetWeek1.Id;
        objTmeShtDtl.Timesheet_Date__c = tdsStart1.addDays(1); 
        objTmeShtDtl.Timesheet__c=insertTimeSheetWeek5.id;
        objTmeShtDtl.Intiative__c=initiative.id;
        insert objTmeShtDtl;
        ODS_TimesheetController objTmeShtCntlr = new ODS_TimesheetController();
        objTmeShtCntlr.FetchExistingTimesheetDetails(insertTimeSheetWeek5.id);
        //objTmeShtCntlr.DeleteExistingTimesheetDetail(insertTimeSheetWeek5.id);
        ODS_TimesheetController.sendWeeklyEmail(insertTimeSheetWeek2.id);
        /*Date startOfWeek6 = date.newinstance(2021, 9, 29);
Date endOfWeek6 = startOfWeek6.addDays(7);
Timesheet__c insertTimeSheetWeek6 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName5',objTmeShtCst.Id,startOfWeek6,endOfWeek6);
insertTimeSheetWeek6.Status__c = 'Submitted';
insertTimeSheetWeek6.Account_Services__c = accSrvc.Id;
update insertTimeSheetWeek6;
objTmeShtCntlr.UpdateODSHoursAndResCountInCost(insertTimeSheetWeek6);*/
    }
}