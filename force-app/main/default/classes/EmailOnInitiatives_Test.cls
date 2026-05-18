/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       EmailOnInitiatives_Test
* @description      This is the Testclass For EmailOnInitiatives
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	30-DEC-2020    	DemandBlue 		Initial Development
*********************************************************************************************/
@isTest
public class EmailOnInitiatives_Test {
    
    static TestMethod void EmailOnInitiativesTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Testuser',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');
            portalAccount1.Industry = 'Nonprofit Organization';
            update portalAccount1;
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
            Date Startdte = date.parse('12/01/2020');
            Date Enddte = date.parse('12/31/2020');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',portalAccount1.Id,odsSrv.Id);
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'12','2020');
            Account portalAccount11 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            initiative.Probable_Start_Date__c = Startdte;
            initiative.Probable_End_Date__c = Enddte;
            initiative.UAT_Expected_Date__c = Enddte;
            update initiative;
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('12/21/2020'),date.parse('12/27/2020'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('12/22/2020'), initiative.Id);
            ODS_DataFactory_Test_Utility.exportEstimates(120.1,initiative.Id,'Analysis','Task1');
            initiative.Submitted_Hours__c = 109;            
            update initiative;
            
            system.RunAs(user1){            
                List<string> InitiativeId = new List<string>();
                InitiativeId.add(initiative.Id);
                EmailOnInitiatives.SendInitiativeEmail(InitiativeId); 
            }
        }
    }
}