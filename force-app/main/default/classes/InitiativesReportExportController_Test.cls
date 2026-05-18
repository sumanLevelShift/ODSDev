@isTest
public class InitiativesReportExportController_Test {

    static TestMethod void Initiative_PositiveTest1()
    {
        List<Account> acclist = new List<Account>();
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
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
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',portalAccount1.Id,odsSrv.Id);
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
            acclist.add(portalAccount1);
            system.RunAs(user1){            
                Test.startTest();   
                string iniStatus='Initiative Approved';
                PageReference pageRef = Page.HoursConsumedPdf;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('accountId',portalAccount1.Id);
                ApexPages.currentPage().getParameters().put('serviceId',odsSrv.Id);
                ApexPages.currentPage().getParameters().put('initiativeStatusList',iniStatus);
                Test.StopTest();
                InitiativesReportExportController getInitiatives = new InitiativesReportExportController();
                InitiativesReportExportController.accountName = portalAccount1.Name;
                InitiativesReportExportController.serviceName = accSrvc.Name;
            }
        }
    }
    
}