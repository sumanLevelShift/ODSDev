@isTest
public class ODS_SendReminderOnStatusReportBatchTest {
    @isTest
    Public static void sendReminderTest(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Chatter');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('Test','testuser@testmail.com','UTF-8','userTest',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id);   
      
        // User usrObj=[Select Id,ManagerId,Name From User where Id =: '00540000001CoL2AAK'];
        System.runAs (usrObj) 
        {
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            
            String campaignName =  System.Label.LeadInfo_Campaign_Name;
            List<Campaign> campaigns = [SELECT ID FROM Campaign WHERE Name =:campaignName]; 
            if(campaigns.size() <= 0 ){	
                Campaign camp = new Campaign();
                camp.Name = campaignName;
                insert camp;
            }
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET'); 
            Status_Report__c objSR = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.Id,System.Today()-1,'test 123', 'Testing to be started', 'Test 123','Saved');
            Status_Report__c objSR1 = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.Id,System.Today()-1,'test 123', 'Testing to be started', 'Test 123','Saved');
            
            
            Test.startTest();
            SchedulableContext sc = null;
            ODS_SendReminderOnStatusReportBatchSch x = new ODS_SendReminderOnStatusReportBatchSch();
            x.execute(sc);
            Test.stopTest();
            
            system.assertEquals('Saved', objSR.Status__c);
            system.assertEquals(system.today()-1, objSR.Status_Date__c);
        }
    }
}