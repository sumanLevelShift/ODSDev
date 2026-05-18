@isTest
public class ODS_StatRepNotificationProcessor_Test {
    static TestMethod void StatRepNotificationProcessorMethodsTest() 
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id); 
        System.runAs (usrObj) 
        { 
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContactWithEmail('Test','McTesty', True, accObj.Id, 'testuser@test.com', 'Others', 'ODS Project');
            Contact_Account_Service__c cntAcntService = new Contact_Account_Service__c();
            cntAcntService.Account__c = accObj.Id;
            cntAcntService.ODS_Service__c = odsSrv.Id;
            cntAcntService.Contact__c = contact1.Id;
            cntAcntService.Is_Approver__c = True;
            Insert CntAcntService;
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User usrObj2 = ODS_DataFactory_Test_Utility.InsertUserWithContact('Allen','carrier@testmail.com','UTF-8','Institute',
                                                                              'en_US','en_US',portalProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                              'AllenT@testmail.com',contact1.Id, 'Customer');
            Status_Report__c objSR = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.Id,System.Today(),'Completed Development', 'Testing to be started', 'None','Submitted');
            string notificationName = 'New_Daily_Status_Report';
            ODS_StatusReportNotificationProcessor processor = new ODS_StatusReportNotificationProcessor(objSR.id,notificationName);
            processor.processNotificationRequest();
            
        }
    }

}