@isTest
public class ODS_TimeSheeetReminderBatchTest {
    @isTest
    Public static void Testone()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Chatter');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('Test','testuser@testmail.com','UTF-8','userTest',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id);   
        
        System.runAs (usrObj) 
        {
            date dateField=date.Today();
            Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
			Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            //Date Startdte = date.parse('02/01/2021');
            //Date Enddte = date.parse('02/28/2021');
            Date Startdte=Date.newInstance(dateField.year(), dateField.month(), 1)-10;
            Date Enddte=lastDayOfMonth-7;
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET'); 
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'02','2021');
            Timesheet__c tsObj = new Timesheet__c();
            tsObj.Name = 'TestName';
            tsObj.Time_Sheet_Cost__c = objTmeShtCst.Id;   
            tsObj.Week_Start_Date__c =  Date.today()-7;
            tsObj.Week_End_Date__c = Date.today()-7;
            tsObj.Status__c='Saved';
            tsObj.Account_Services__c=accSrvc.id;
            insert tsObj;

            Timesheet__c tsObj1 = new Timesheet__c();
            tsObj1.Name = 'TestName';
            tsObj1.Time_Sheet_Cost__c = objTmeShtCst.Id;   
            tsObj1.Week_Start_Date__c =  Date.today()-7;
            tsObj1.Week_End_Date__c = Date.today()-7;
            tsObj1.Status__c='Saved';
            tsObj1.Account_Services__c=accSrvc.id;
            insert tsObj1;
            
            Test.startTest();
            SchedulableContext scheldu = null;
            ODS_TimeSheeetReminderBatchscheduler testing = new ODS_TimeSheeetReminderBatchscheduler();
            testing.execute(scheldu);
            Test.stopTest();
            system.assertEquals(tsObj1.Status__c, 'Saved');
            
            
        }
    }
    
}