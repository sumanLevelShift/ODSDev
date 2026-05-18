@isTest
public class UploadBulkTimeSheetBatchTest {
    @isTest
    public static void timesheetDetailsValidationIfLoop1(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"Test Initiativse23","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"90","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop2(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"Test Initiativse23","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"90","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop3(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"Test Initiativse223","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"90","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 5","TPM":"TestTPM","Mon":"","Tue":"1","Wed":"1","Thu":"","Fri":"","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop4(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"Test Initiativse223","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"90","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 5","TPM":"TestTPM","Mon":"","Tue":"1","Wed":"1","Thu":"","Fri":"","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop5(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"Test Initiativse223","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 5","TPM":"TestTPM","Mon":"","Tue":"1","Wed":"1","Thu":"","Fri":"","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop6(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"90","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 5","TPM":"TestTPM","Mon":"","Tue":"1","Wed":"1","Thu":"","Fri":"","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop7(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"test Ini","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 5","TPM":"TestTPM","Mon":"","Tue":"1","Wed":"1","Thu":"","Fri":"","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop8(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"test Ini","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    }
    @isTest
    public static void timesheetDetailsValidationIfLoop9(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"90","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 5","TPM":"TestTPM","Mon":"","Tue":"1","Wed":"1","Thu":"","Fri":"","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop10(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"90","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    public static void timesheetDetailsValidationIfLoop11(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy1","Mon":"2","Tue":"1","Wed":"0","Thu":"1","Fri":"0","Sat":"0","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
        }
    } 
    @isTest
    Public static void createTimesheetV6(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=30;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 30;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"Test Initiative","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"2","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
            Test.setCurrentPageReference(new PageReference('Page.ODS_DownloadTimeSheetAsExcelForToolPage')); 
            System.currentPageReference().getParameters().put('startDate', '11/8/2021');
            ODS_TimeSheetExcelToolPageController objTimeSheetExcel=new ODS_TimeSheetExcelToolPageController();
            map<string,list<string>> invalidInitiatives=new map<string,list<string>>();
            list<string> initiativeList=new List<string>();
            initiativeList.add('testI');
            initiativeList.add('testIs');
            invalidInitiatives.put(portalAccount1.Name,initiativeList);
            
            map<string,List<TimesheetTable>> tpmNotAvailable=new map<string,List<TimesheetTable>>();
            List<TimesheetTable> ttList=new list<TimesheetTable>();
            ttList.add(new TimesheetTable(initiative.id,initiative.Name,'s.Description','s.TPM','1','1','1','1','1','1','1','',''));
            tpmNotAvailable.put(portalAccount1.Name,ttList);
            
            UploadBulkTimeSheetHelper helper=new UploadBulkTimeSheetHelper();
            //helper.forMismatchInitiatives(invalidInitiatives,date.parse(string.valueOf('11/8/2021')),portalAccount1.Name,tpmNotAvailable);
            list<Initiatives__c> initiativesList=new List<Initiatives__c>();
            initiativesList.add(initiative);
            list<TimesheetTable> TimesheetTableList=new list<TimesheetTable>();
            string hours=string.valueOf(24);
            //helper.sendMailForExitHours(portalAccount1.Name, initiativesList,date.parse(string.valueOf('11/8/2021')),tpmNotAvailable);
            set<string> accNameList=new set<string>();
            accNameList.add(portalAccount1.Name);
            ODS_TimeSheetToolPageController contr=new ODS_TimeSheetToolPageController();
            contr.WeekStartDate=date.parse(string.valueOf('11/8/2021'));
            contr.WeekEndDate=date.parse(string.valueOf('11/14/2021'));
            contr.sendMailForNotFutureWeek(accNameList);
            try{
                integer i=1/0;
                
            }catch(Exception e){
                objTmeShtCntlr.sendMailForException(e);
            }
        }
    }
    @isTest
    Public static void createTimesheet(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('test','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            /*User1.Signature__c ='Thankls';*/
            update User1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('SalesForce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            //Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test Initiative';
            initiative.Account_Service__c = accSrvc.Id;
            initiative.Status__c = 'Initiative Approved';
            initiative.Consumed_Hours__c=130;
            initiative.Submitted_Hours__c=10;
            insert initiative;
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 1000;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate; 
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            Contact_Account_Service__c cas1 = new Contact_Account_Service__c();
            cas1.Account__c = portalAccount1.Id;
            cas1.Contact__c = contact1.Id;
            cas1.Is_Approver__c = true;
            cas1.ODS_Service__c = odsSrv.Id;
            cas1.Type_of_Engagement__c = 'ODS';
            insert cas1;
            
            ODS_TimeSheetToolPageController objTmeShtCntlr = new ODS_TimeSheetToolPageController();
            objTmeShtCntlr.initiativeNameList='[{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Bharathi Chinnapparaj","Mon":"1","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"25","Tue":"24","Wed":"24","Thu":"24","Fri":"24","Sat":"24","Sun":"24","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"","Description":"test 1","TPM":"Bharathi Chinnapparaj","Mon":"1","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 2","TPM":"Krishnadas Ramaswamy","Mon":"1","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"ttt","Description":"test 1","TPM":"Krishnadas Ramaswamy","Mon":"1","Tue":"1","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"},{"AccountName":"'+portalAccount1.Name+'","Initiative":"'+initiative.Name+'","Description":"test 3","TPM":"Krishnadas Ramaswamy","Mon":"1","Tue":"21","Wed":"1","Thu":"1","Fri":"1","Sat":"1","Sun":"1","StartWeekDate":"11/8/2021","EndWeekDate":"11/14/2021"}]';
            objTmeShtCntlr.exportAsExcel();
            objTmeShtCntlr.getInitList();
            Test.setCurrentPageReference(new PageReference('Page.ODS_DownloadTimeSheetAsExcelForToolPage')); 
            System.currentPageReference().getParameters().put('startDate', '11/8/2021');
            ODS_TimeSheetExcelToolPageController objTimeSheetExcel=new ODS_TimeSheetExcelToolPageController();
            map<string,list<string>> invalidInitiatives=new map<string,list<string>>();
            list<string> initiativeList=new List<string>();
            initiativeList.add('testI');
            initiativeList.add('testIs');
            invalidInitiatives.put(portalAccount1.Name,initiativeList);
            map<string,List<TimesheetTable>> tpmNotAvailable=new map<string,List<TimesheetTable>>();
            List<TimesheetTable> ttList=new list<TimesheetTable>();
            ttList.add(new TimesheetTable(initiative.id,initiative.Name,'s.Description','s.TPM','1','1','1','1','1','1','1','',''));
            tpmNotAvailable.put(portalAccount1.Name,ttList);
            
            UploadBulkTimeSheetHelper helper=new UploadBulkTimeSheetHelper();
            //helper.forMismatchInitiatives(invalidInitiatives,date.parse(string.valueOf('11/8/2021')),portalAccount1.Name,tpmNotAvailable);
            list<Initiatives__c> initiativesList=new List<Initiatives__c>();
            initiativesList.add(initiative);
            list<TimesheetTable> TimesheetTableList=new list<TimesheetTable>();
            string hours=string.valueOf(24);
            //TimesheetTableList.add(new TimesheetTable(initiative.id,initiative.Name,'test',hours,hours,hours,hours,hours,hours,hours,initiative.Account_Service__c,initiative.Account_Service__r.Account__c));
            //helper.sendMailForExitHours(portalAccount1.Name, initiativesList,date.parse(string.valueOf('11/8/2021')),tpmNotAvailable);
            //helper.sendMailForGrether24Hours(TimesheetTableList,System.now().date(),null,initiative.Account_Name__c,null);
            try{
                integer i=1/0;
                
            }catch(Exception e){
                objTmeShtCntlr.sendMailForException(e);
            }
        }
    }
    
}