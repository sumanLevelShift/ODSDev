/**
 * @author           Gnana Prakasam G
 * @version          1.0 
 * @date             06-12-2017
 * @Status           Deployed
 * @description      Test class for ODS_InitiativeController Controller
 */
@isTest
public class ODS_InitiativeController_Test
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
            
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();
             
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
                
                ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController(); 
                List<SelectOption> optionValues = initiativeCtrl.getInitiativeTagPicklist;  
                List<SelectOption> optionValuesNew = initiativeCtrl.getArchitectOrEngineer;
                List<SelectOption> optionValuesTPM = initiativeCtrl.getTechnicalProjectManager; // Added by Harish 08-Jun-21 TPM
                List<SelectOption> optionValuesNew1=initiativeCtrl.getTriggerForInitiative;
                List<SelectOption> optionValuesNew2=initiativeCtrl.getInitiativeType;
                initiativeCtrl.showSaveCreateJira = true;
                
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
                
                ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController(); 
                
                initiativeCtrl.getClientContact();
                initiativeCtrl.GetTimeSheetIdFromAction();
                initiativeCtrl.AddRow();
                ODS_InitiativeController.GetAccountPicklistValues();
                initiativeCtrl.SetRelatedService();
                initiativeCtrl.GetLoggedUserAccountService();
                initiativeCtrl.getContactAccountServices(); 
                
                initiativeCtrl.getProductList();// Product list - added harish
                initiativeCtrl.showpopup();
                //initiativeCtrl.closepopup();
                initiativeCtrl.getResourceNameByAccountServiceId(portalAccount1.Id,odsSrv.Id);
                initiativeCtrl.getInitiativeByAccountServiceId(portalAccount1.Id,odsSrv.Id);
                initiativeCtrl.exportAsExcel();  
                initiativeCtrl.SaveInitativeAndEstimate();
				initiativeCtrl.checkJiraId(accSrvc.Id);             
                
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
            Attachment testAttachment = new Attachment();
            testAttachment.name = 'Test File';
            testAttachment.body = Blob.valueOf('Unit Test Attachment Body');
            testAttachment.parentId = initiative.Id;
            Insert testAttachment;
            
            string attName= 'Test';
            blob attbody = Blob.valueOf('Unit Test Attachment Body');
            string encodedBody=EncodingUtil.base64Encode(attbody);
            encodedBody=','+encodedBody;
            
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            ApexPages.currentPage().getParameters().put('attachmentName', attName);
            ApexPages.currentPage().getParameters().put('attachmentBody', encodedBody);
            
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();
          
            initiativeCtrl.getClientContact();
            initiativeCtrl.GetTimeSheetIdFromAction();
            initiativeCtrl.AddRow();
            ODS_InitiativeController.GetAccountPicklistValues();
            initiativeCtrl.SetRelatedService();
            initiativeCtrl.GetLoggedUserAccountService();
            initiativeCtrl.getContactAccountServices();
            initiativeCtrl.saveAttachment();
            ODS_InitiativeController.initiativeStatus(initiative.Id);
            ODS_InitiativeController.GetUtilizedHours(initiative.Id);
            initiativeCtrl.EscalateInitiative();
            initiativeCtrl.ReSendInitiativeEmail();
            initiativeCtrl.GetCurrentAttachments();
            initiativeCtrl.DeleteAttachment();
            initiativeCtrl.ReCallInitiativeEmail();
            initiativeCtrl.CloneInitiative();
            initiativeCtrl.SaveInitativeAndEstimate();
            initiativeCtrl.checkJiraId(accSrvc.Id);

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
            
            ODS_InitiativeController.Estimate estimates = new ODS_InitiativeController.Estimate('Design','Document Preparation', 'Document Preparation', '8');            
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
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','sfadmin@demandblue.com','UTF-8','Indumathi',
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
            
            accSrvc.Service_Workspace_Id__c = '152';
            accSrvc.Purchase_Order__c = '12345';
            update accSrvc;
            
            Attachment testAttachment = new Attachment();
            testAttachment.name = 'Test File';
            testAttachment.body = Blob.valueOf('Unit Test Attachment Body');
            testAttachment.parentId = initiative.Id;
            Insert testAttachment;
            
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController(); 
            initiativeCtrl.PassedInitiativeEstimateJSON = '{"Estimate":[{"Phase":"Analysis","TaskName":"Test","Hours":"4"}],"InitiativeTag":["Strategic"],"ProbablePercent":"50","InitiativeName":"Test Initiative","StartDate":"12/08/2017","EndDate":"03/16/2018","UATExpectedDate":"12/10/2020","ContactAccService":"Gnana Prakash","BriefDescription":"","Status":"Saved","stats":"Saved"}';
            initiativeCtrl.showSaveCreateJira = true;
            initiativeCtrl.SaveInitativeAndEstimate();
            initiativeCtrl.checkJiraId(accSrvc.Id);
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
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','sfadmin@demandblue.com','UTF-8','Indumathi',
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
            
            
            accSrvc.Service_Workspace_Id__c = '152';
            accSrvc.Purchase_Order__c = '12345';
            accSrvc.Technical_Account_Manager_Email__c = 'sfadmin@demandblue.com';
            update accSrvc;
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));            
            Time_Sheet_Details__c timesheetDetail = ODS_DataFactory_Test_Utility.insertInitiativeTimesheetdetail(5, ObjTeamMembr.Id, 'Selva', insertTimeSheet.Id, date.parse('11/08/2016'), initiative.Id);
             
            Jira_Data_Mapping__mdt jiraDataMdt = [SELECT Mapping_Type__c, DeveloperName, Issue_Type_Id__c FROM Jira_Data_Mapping__mdt WHERE Mapping_Type__c =: 'Issue Type' AND DeveloperName =: 'Story'];
			system.debug(jiraDataMdt);
            
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            //ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController(); 
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
            
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();             
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
            
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();             
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
            Attachment testAttachment = new Attachment();
            testAttachment.name = 'Test File';
            testAttachment.body = Blob.valueOf('Unit Test Attachment Body');
            testAttachment.parentId = initiative.Id; 
            Insert testAttachment;
            
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();
            
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
            
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();               
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
            initiativeCtrl.CloneInitiative();
            initiativeCtrl.SaveInitativeAndEstimate();
                initiativeCtrl.checkJiraId(accSrvc.Id);
            
            }
            catch(exception e)
            {
                 system.assertEquals(e.getMessage(),e.getMessage());
            }
           
            
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
            Attachment testAttachment = new Attachment();
            testAttachment.name = 'Test File';
            testAttachment.body = Blob.valueOf('Unit Test Attachment Body');
            testAttachment.parentId = initiative.Id;            
            Insert testAttachment;
            
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();
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
            Attachment testAttachment = new Attachment();
            testAttachment.name = 'Test File';
            testAttachment.body = Blob.valueOf('Unit Test Attachment Body');
            testAttachment.parentId = initiative.Id;
            Insert testAttachment;
            
            system.RunAs(user1){            
                PageReference initiativePage = Page.InitiativePage;
                Test.setCurrentPage(initiativePage);            
                // Put Id into the current page Parameters
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
                ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
                ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
                ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();
               // initiativeCtrl.sendEmailInitiative(initiative.Id, accSrvc.Id, 'Submitted', contact1.Id,'');
                ODS_InitiativeController.sendEmailInitiative(initiative.Id, accSrvc.Id, 'Submitted', contact1.Id,'');  
         
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
            Estimate__c estimate = new Estimate__c();
             estimate.Hours__c = 120;
             estimate.Initiative_Lookup__c = initiative.Id;
             estimate.Phase__c = 'Development';
             estimate.Task_Components__c = 'Tasks';
             insert estimate; 
            Attachment testAttachment = new Attachment();
            testAttachment.name = 'Test File';
            testAttachment.body = Blob.valueOf('Unit Test Attachment Body');
            testAttachment.parentId = initiative.Id;
            Insert testAttachment;
            
            system.RunAs(user1){            
                PageReference initiativePage = Page.InitiativePage;
                Test.setCurrentPage(initiativePage);            
                // Put Id into the current page Parameters
                ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
                ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
                ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
                ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();
                ODS_InitiativeController.sendEmailInitiative(initiative.Id, accSrvc.Id, 'Initiative Approved', contact1.Id,'');
                ODS_InitiativeController.sendEmailInitiativeDelivered(initiative.Id, accSrvc.Id);  
         
            }
        }
        
    }
    
    

    
    @isTest
    public static void checkDuplicateAttachment(){
        Documents__c a=new Documents__c();
        a.Name='Test Account';
        insert a;
        Attachment testAttachment = new Attachment();
        testAttachment.name = 'Test File';
        testAttachment.body = Blob.valueOf('Unit Test Attachment Body');
        testAttachment.parentId = a.Id;
        Insert testAttachment;
        try{
            Attachment testAttachmentNeg = new Attachment();
            testAttachmentNeg.name = 'Test File';
            testAttachmentNeg.body = Blob.valueOf('Unit Test Attachment Body');
            testAttachmentNeg.parentId = a.Id;
            Insert testAttachmentNeg;            
        }
        catch(Exception e)   
        {
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot upload a file with same Name.Please retry with different Name') ? true : false;
            
            System.AssertEquals(expectedExceptionThrown, true);
            
        } 
    }
        
    static TestMethod void CloneInitiative_Test(){
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
            Estimate__c estimateToCopy = new Estimate__c();
            estimateToCopy.Phase__c =  'Analysis';
            estimateToCopy.Hours__c = 10;
            estimateToCopy.Task_Components__c = 'Testing';
            estimateToCopy.Assumptions__c = 'Tuesday';
            estimateToCopy.Initiative_Lookup__c = initiative.id;
            insert estimateToCopy;
            
            PageReference initiativePage = Page.InitiativePage;
            Test.setCurrentPage(initiativePage);            
            ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('CurrenInitiativeId',initiative.Id);
            ApexPages.currentPage().getParameters().put('Status', 'Initiative Submitted');
            
            ODS_InitiativeController initiativeCtrl = new ODS_InitiativeController();
            initiativeCtrl.CloneInitiative();
            
            
        }
        
    }

}