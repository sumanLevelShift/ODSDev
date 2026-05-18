@isTest
public class ODS_DownloadTimsheetControllerTest {
 static TestMethod void GetTimeSheetExcel_PositiveTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {       
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                            portalAccountOwner1.Id, True,2000,'9433578865', 'Others', 'ODS Project');     
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
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'PCJAVA');

            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,strtDt,endDt,string.valueOf(strtDt.Month()),string.valueOf(strtDt.Year()));
                Timesheet__c insertTimeSheet = ODS_DataFactory_Test_Utility.insertTimesheetWithCost('testName',accSrvc.id,aprveDt,
                                   portalAccountOwner1.id,'TestComments','submitted',system.today(),strtDt,endDt,objTmeShtCst.Id);
          
            system.RunAs(user1){
                PageReference pageRef = Page.ODS_ExportTimesheet;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Weekfromdate',strtDt.format());
                ApexPages.currentPage().getParameters().put('Weektodate',endDt.format());
                ApexPages.currentPage().getParameters().put('Accountservice',accSrvc.Id);
                ODS_DownloadTimsheetController ExptTmeSht = new ODS_DownloadTimsheetController();

                            
            }
        }
    }
}