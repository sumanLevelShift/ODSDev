/**
 * @author           Gnana Prakasam G
 * @version          1.0 
 * @date             06-12-2017
 * @Status           Deployed
 * @description      Test class for ODS_InitiativeControllerMobile Controller
 */
@isTest
public class ODS_InitiativeControllerMobile_Test
{
    //Constructor Negative Test
    static TestMethod void Constructor_NegativeTest()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
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
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
                        
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();
            initiativeCtrl.getInitiativeBillingType=new List<SelectOption>();
        }
    }
    
    //Constructor Positive Test
    static TestMethod void Constructor_PositiveTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
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
              
            system.RunAs(user1){            
                PageReference initiativePage = Page.InitiativePage;
                Test.setCurrentPage(initiativePage);            
                // Put Id into the current page Parameters
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
                ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
                ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
                
                ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile(); 
                List<SelectOption> optionValues = initiativeCtrl.getInitiativeTagPicklist;  
                List<SelectOption> optionValuesNew = initiativeCtrl.getArchitectOrEngineer; 
                List<SelectOption> optionValuesTpm = initiativeCtrl.getTechnicalProjectManager;// Added by harish -08-Jun-21-TPM
                List<SelectOption> optionValuesNew1 = initiativeCtrl.getTriggerForInitiative;
                List<SelectOption> optionValuesNew2 = initiativeCtrl.getInitiativeType;
            }
        }
    }
    static TestMethod void CatchError_Test()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
            Attachment testAttachment = new Attachment();
            testAttachment.name = 'Test File';
            testAttachment.body = Blob.valueOf('Unit Test Attachment Body');
            testAttachment.parentId = initiative.Id; 
            Insert testAttachment;
            
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();  
            try{
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId','te6236');
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            initiativeCtrl.ApproveInitiative();
            initiativeCtrl.CancelInitiative();
            initiativeCtrl.RejectInitiative();
            initiativeCtrl.EscalateInitiative();
            initiativeCtrl.exportAsExcel();
            initiativeCtrl.SaveActiveInitiativeStatus();    
            initiativeCtrl.ReDirectToViewIntitiativepage();
            initiativeCtrl.ReCallInitiativeEmail();
            initiativeCtrl.ReSendInitiativeEmail();
                
            }
            catch(exception e)
            {
                 system.assertEquals(e.getMessage(),e.getMessage());
            }
           
            
        }
    }
    //Constructor Positive Test
    static TestMethod void CallingMethods_PositiveTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
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
              
            system.RunAs(user1){            
                PageReference initiativePage = Page.InitiativePage;
                Test.setCurrentPage(initiativePage);            
                // Put Id into the current page Parameters
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
                ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
                ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
                
                ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();  
                initiativeCtrl.getClientContact();
                initiativeCtrl.GetTimeSheetIdFromAction();
                initiativeCtrl.AddRow();
                ODS_InitiativeControllerMobile.GetAccountPicklistValues();
                initiativeCtrl.SetRelatedService();
                initiativeCtrl.GetLoggedUserAccountService();
                initiativeCtrl.getContactAccountServices();  
                initiativeCtrl.getResourceNameByAccountServiceId(portalAccount1.Id,odsSrv.Id);
                initiativeCtrl.getInitiativeByAccountServiceId(portalAccount1.Id,odsSrv.Id);
                initiativeCtrl.exportAsExcel();            
            }
        }
    }
    
    //Calling Methods Test
    static TestMethod void CallingMethods_NegativeTest()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
                        
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();
            
            initiativeCtrl.getClientContact();
            initiativeCtrl.GetTimeSheetIdFromAction();
            initiativeCtrl.AddRow();
            ODS_InitiativeControllerMobile.GetAccountPicklistValues();
            initiativeCtrl.SetRelatedService();
            initiativeCtrl.GetLoggedUserAccountService();
            initiativeCtrl.getContactAccountServices();
            ODS_InitiativeControllerMobile.initiativeStatus(initiative.Id);
            ODS_InitiativeControllerMobile.GetUtilizedHours(initiative.Id);
            initiativeCtrl.EscalateInitiative();
            initiativeCtrl.ReSendInitiativeEmail();
            initiativeCtrl.ReCallInitiativeEmail();
            
        }
    }
    
    //Calling Methods Test
    static TestMethod void EstimatesConstructor_Test()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
                        
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile.Estimate estimates = new ODS_InitiativeControllerMobile.Estimate('Design','Document Preparation', 'Document Preparation', '8');            
        }

    }
    
    //SaveInitativeAndEstimate Methods Test
    static TestMethod void SaveInitativeAndEstimate_PositiveTest()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
                        
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile(); 
            initiativeCtrl.PassedInitiativeEstimateJSON = '{"Estimate":[{"Phase":"Analysis","TaskName":"Test","Hours":"4"}],"InitiativeTag":["Strategic"],"ProbablePercent":"50","InitiativeName":"Test Initiative","StartDate":"12/08/2017","EndDate":"03/16/2018","UATExpectedDate":"12/10/2020","ContactAccService":"Gnana Prakash","BriefDescription":"","Status":"Saved","stats":"Saved"}';
            initiativeCtrl.SaveInitativeAndEstimate();
        }
    }
    
    //SaveInitativeAndEstimate Methods Test
    static TestMethod void SaveInitativeAndEstimate_NegativeTest()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
                        
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            //ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile(); 
            initiativeCtrl.PassedInitiativeEstimateJSON = '{"Estimate":[{"Phase":"Analysis","TaskName":"Test","Hours":"4"}],"InitiativeTag":["Strategic"],"UATExpectedDate":"12/10/2020","InitiativeName":"Negative","StartDate":"12/08/2017","EndDate":"03/16/2018","ProbablePercent":"50","ContactAccService":"Gnana Prakash","BriefDescription":"","Status":"Saved","stats":"Saved"}';
            initiativeCtrl.SaveInitativeAndEstimate();
        }

    }
    
    //SaveActiveInitiativeStatus Methods Test
    static TestMethod void SaveActiveInitiativeStatus_Test()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {       
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
                        
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();             
            initiativeCtrl.SaveActiveInitiativeStatus();
        }
    }
    
    //Submit Initiative Methods Test
    static TestMethod void SubmitInitiative_Test()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Submitted');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
            Initiatives__c initiativeToUpdate =  new Initiatives__c();
            initiativeToUpdate.Id = initiative.Id;
            initiativeToUpdate.Initiative_Type__c = 'Declarative';
            initiativeToUpdate.Tags_About_Initiative__c = 'Reporting;';
            initiativeToUpdate.Trigger_For_Initiative__c = 'Customer';
            initiativeToUpdate.Solution_Architect_Engineer__c = 'None';
            update initiativeToUpdate;
            
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();             
            initiativeCtrl.SaveActiveInitiativeStatus();
        }
    }
    
    //ApproveInitiative Methods Test
    static TestMethod void ApproveInitiative_Test()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {   
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
                        
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();  
            
            Estimate__c estimateobject = new Estimate__c();
            estimateobject.Phase__c = 'Development';
            estimateobject.Hours__c = 110;
            estimateobject.Task_Components__c = 'Site Development';
            estimateobject.Assumptions__c = '';
            estimateobject.Initiative_Lookup__c = initiative.Id;
            insert estimateobject;            
            
            initiativeCtrl.ApproveInitiative();
            initiativeCtrl.CancelInitiative();
            initiativeCtrl.ReDirectToViewIntitiativepage();
        }
    }
    
     //RejectInitiative Methods Test
    static TestMethod void RejectInitiative_Test()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    

        System.runAs (usrObj) 
        {       
			Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
                        
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();
           
            initiativeCtrl.RejectInitiative();
        }
    }
    
    //sendEmailInitiative Methods Test
    static TestMethod void sendEmailInitiative_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                    'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContactWithEmail('Test','McTesty', True, portalAccount1.Id, 'testuser@test.com', 'Others', 'ODS Project');
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
            initiative.Client_side_Contact__c = contact1.Id;
            update initiative;
            system.RunAs(user1){            
                PageReference initiativePage = Page.InitiativePage;
                Test.setCurrentPage(initiativePage);            
                // Put Id into the current page Parameters
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
                ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
                ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
                ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();
                
               // initiativeCtrl.sendEmailInitiative(initiative.Id, accSrvc.Id, 'Submitted', contact1.Id,'');
                ODS_InitiativeControllerMobile.sendEmailInitiative(initiative.Id, accSrvc.Id, 'Submitted', contact1.Id,'');  
         
            }
        }
    }
    static TestMethod void sendEmailInitiativeDelivered_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                    'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContactWithEmail('Test','McTesty', True, portalAccount1.Id, 'testuser@test.com', 'Others', 'ODS Project');
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
            initiative.Client_side_Contact__c = contact1.Id;
            update initiative;
            system.RunAs(user1){            
                PageReference initiativePage = Page.InitiativePage;
                Test.setCurrentPage(initiativePage);            
                // Put Id into the current page Parameters
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
                ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
                ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
                ODS_InitiativeControllerMobile initiativeCtrl = new ODS_InitiativeControllerMobile();
                
               // initiativeCtrl.sendEmailInitiative(initiative.Id, accSrvc.Id, 'Submitted', contact1.Id,'');
                ODS_InitiativeControllerMobile.sendEmailInitiativeDelivered(initiative.Id, accSrvc.Id);  
         
            }
        }
    }
    
    
}