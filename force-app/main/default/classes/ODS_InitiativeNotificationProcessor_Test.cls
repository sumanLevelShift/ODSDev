@isTest
public class ODS_InitiativeNotificationProcessor_Test {
    
    static TestMethod void InitiativeNotificationProcessorMethodsTest()
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
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Date UATdte = date.parse('11/10/2020');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContactWithEmail('Test','McTesty', True, accObj.Id, 'testuser@test.com', 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User usrObj2 = ODS_DataFactory_Test_Utility.InsertUserWithContact('Allen','carrier@testmail.com','UTF-8','Institute',
                                                                      'en_US','en_US',portalProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'AllenT@testmail.com',contact1.Id, 'Customer');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            initiative.Client_side_Contact__c = contact1.Id;
            update initiative;
            string notificationName = 'New_Initiative';
            ODS_InitiativeNotificationProcessor processor = new ODS_InitiativeNotificationProcessor(initiative.id,notificationName);
      
            processor.processNotificationRequest();
        }  
    }
}