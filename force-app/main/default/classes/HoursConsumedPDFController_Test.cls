@isTest
public class HoursConsumedPDFController_Test {
    static TestMethod void GetTimeSheetDetails_PositiveTest()
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
            
            Time_Sheet_Cost__c timeshecost = new Time_Sheet_Cost__c();
            timeshecost.Account_Services__c = accSrvc.Id ;
            timeshecost.Month__c = '7';
            timeshecost.ODS_Hours__c = 12;
            timeshecost.Year__c = '2021';
            insert timeshecost;
            
            Time_Sheet_Cost__c timeshecost1 = new Time_Sheet_Cost__c();
            timeshecost1.Account_Services__c = accSrvc.Id ;
            timeshecost1.Month__c = '6';
            timeshecost.ODS_Hours__c = 112;
            timeshecost1.Year__c = '2021';
            insert timeshecost1;
            
            Time_Sheet_Cost__c timeshecost2 = new Time_Sheet_Cost__c();
            timeshecost2.Account_Services__c = accSrvc.Id ;
            timeshecost2.Month__c = '1';
            timeshecost.ODS_Hours__c = 23;
            timeshecost2.Year__c = '2021';
            insert timeshecost2;
            
            
            Time_Sheet_Cost__c timeshecost3 = new Time_Sheet_Cost__c();
            timeshecost3.Account_Services__c = accSrvc.Id ;
            timeshecost3.Month__c = '2';
            timeshecost.ODS_Hours__c = 32;
            timeshecost3.Year__c = '2022';
            insert timeshecost3;
            
            system.RunAs(user1){
                
                HoursConsumedPDFController ExptPdfRep = new HoursConsumedPDFController();
                //HoursConsumedPDFController.generateTimesheetDetails();
                
                
            }
        }
    }
    static TestMethod void GetTimeSheetDetails_PositiveTest1()
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
            Time_Sheet_Cost__c timeshecost = new Time_Sheet_Cost__c();
            timeshecost.Account_Services__c = accSrvc.Id ;
            timeshecost.Month__c = '7';
            timeshecost.ODS_Hours__c = 12;
            timeshecost.Year__c = '2021';
            insert timeshecost;
            
            Time_Sheet_Cost__c timeshecost1 = new Time_Sheet_Cost__c();
            timeshecost1.Account_Services__c = accSrvc.Id ;
            timeshecost1.Month__c = '6';
            timeshecost.ODS_Hours__c = 112;
            timeshecost1.Year__c = '2021';
            insert timeshecost1;
            
            Time_Sheet_Cost__c timeshecost2 = new Time_Sheet_Cost__c();
            timeshecost2.Account_Services__c = accSrvc.Id ;
            timeshecost2.Month__c = '1';
            timeshecost.ODS_Hours__c = 23;
            timeshecost2.Year__c = '2021';
            insert timeshecost2;
            
            
            Time_Sheet_Cost__c timeshecost3 = new Time_Sheet_Cost__c();
            timeshecost3.Account_Services__c = accSrvc.Id ;
            timeshecost3.Month__c = '2';
            timeshecost.ODS_Hours__c = 32;
            timeshecost3.Year__c = '2022';
            insert timeshecost3;
            
            system.RunAs(user1){
                Test.startTest();   
                PageReference pageRef = Page.HoursConsumedPdf;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('accountId',portalAccount1.Id);
                ApexPages.currentPage().getParameters().put('serviceId','All');
             
                HoursConsumedPDFController HoursCons = new HoursConsumedPDFController();
               // HoursConsumedPDFController.accountName = portalAccount1.Name;
                HoursConsumedPDFController.serviceName = accSrvc.Name;
                Test.StopTest();
                
            }
        }
    }
    
}