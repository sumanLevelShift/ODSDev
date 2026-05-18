@isTest
public class ODS_CaseScheduleTest {
@isTest
    Public static void Testone()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Chatter');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('Test','testuser@testmail.com','UTF-8','userTest',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id);   
        
        System.runAs (usrObj) {
            date dateField=date.Today();
            Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
			Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            //Date Startdte = date.parse('02/01/2021');
            //Date Enddte = date.parse('02/28/2021');
            Date Startdte=Date.newInstance(dateField.year(), dateField.month(), 1)-10;
            Date Enddte=lastDayOfMonth-7;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project');
            accObj.Force_com_Account_Status__c = '7: Customer';
            update accObj;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('Salesforce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET'); 
        
        	
            
                Case c  = new Case();
                c.Status = 'Not Started';
                c.Type = 'Release Update';
                c.Reason = 'Release Updates and Impact Analysis';
                c.Origin = 'Web';
                c.Subject = 'Release Update';
            	c.AccountId = accObj.Id;
                c.Account_Services__c = accSrvc.Id;
                c.Release__c = 'Spring \'23';
                c.Release_Date__c = 'Jan/Feb, 2023';
                insert c;
            
            Test.startTest();
            SchedulableContext scheldu = null;
            ODS_CaseScheduler testing = new ODS_CaseScheduler();
            // testing.execute(scheldu);  
            System.schedule('Test Scheduler Job', '0 48 * * * ?', testing);
            
            Test.stopTest();
        }
    }
    
    @isTest
    Public static void Testtwo()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Chatter');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('Test','testuser@testmail.com','UTF-8','userTest',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id);   
        
        System.runAs (usrObj) {
            date dateField=date.Today();
            Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
			Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            //Date Startdte = date.parse('02/01/2021');
            //Date Enddte = date.parse('02/28/2021');
            Date Startdte=Date.newInstance(dateField.year(), dateField.month(), 1)-10;
            Date Enddte=lastDayOfMonth-7;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project');
            accObj.Force_com_Account_Status__c = '7: Customer';
            update accObj;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('Salesforce','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET'); 
            
            Test.startTest();
            SchedulableContext scheldu = null;
            ODS_CaseScheduler testing = new ODS_CaseScheduler();
            testing.execute(scheldu);
            Test.stopTest();
        }
    }
}