/*******************************************************************************************
* @author           Prasanna
* @version          1.0 
* @Status           Development Completed
* @Class Name       ODS_SearchResultController_Test
* @description      This is the Testclass For ODS_SearchResultController Page
*********************************************************************************************
Version     Date          Team          Comments
*********************************************************************************************
* 1          10 SEP 2020      DemandBlue     Initial Development
*********************************************************************************************/

@isTest
public class ODS_SearchResultController_Test {
    @isTest static void TestAccountRecordforPagination(){
        
        List<Account> acclist = new List<Account>();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCity = 'Test Billing city';
        acc.AnnualRevenue = 100;
        acc.Phone = '100000';
        acc.If_Others_Please_Specify__c = 'specifyOthers';
        acc.NumberofEmployees = 100;
        acc.Industry = 'Technology';
        insert acc;
        acclist.add(acc);
        
        test.startTest();
        PageReference pageRef = Page.ODS_SearchResult;
        Test.setCurrentPage(pageRef);
        ODS_SearchResultController srContrlr = new ODS_SearchResultController(); 
        srContrlr.AccountId = 'All';
        srContrlr.ServiceId = 'All';
        srContrlr.searchString = 'Test';
        srContrlr.CurrentPage = 0; 
        srContrlr.PageNumber = 1; 
        srContrlr.PageSize = integer.valueof(System.Label.PageSize);
        srContrlr.TotalRecords = acclist.size();
        
        srContrlr.getSearchResult();
        srContrlr.showPrevious();
        srContrlr.showNext();
        srContrlr.showFirst();
        srContrlr.showLast();
        srContrlr.enableDisablePaginationLinks();
        test.stopTest();
    }
    
    @isTest static void TestContactRecordforPagination(){
        
        List<Account> acclist = new List<Account>();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCity = 'Test Billing city';
        acc.AnnualRevenue = 100;
        acc.Phone = '100000';
        acc.If_Others_Please_Specify__c = 'specifyOthers';
        acc.NumberofEmployees = 100;
        acc.Industry = 'Technology';
        insert acc;
        
        List<contact> conlist = new List<contact>();
        Contact con = new Contact();
        con.FirstName = ' Test firstName';
        con.LastName = 'TestlastName';
        con.AccountId = Acc.id;
        con.If_Others_Please_Specify__c = 'Test specifyOthers';
        insert con;
        conlist.add(con);
        
        test.startTest();
        PageReference pageRef = Page.ODS_SearchResult;
        Test.setCurrentPage(pageRef);
        ODS_SearchResultController srContrlr = new ODS_SearchResultController(); 
        srContrlr.AccountId = 'All';
        srContrlr.ServiceId = 'All';
        srContrlr.searchString = 'Test';
        srContrlr.ConCurrentPage = 0; 
        srContrlr.conPageNumber = 1; 
        srContrlr.PageSize = integer.valueof(System.Label.PageSize);
        srContrlr.conTotalRecords = conlist.size();
        
        srContrlr.getSearchResult();
        srContrlr.conshowPrevious();
        srContrlr.conshowNext();
        srContrlr.conshowFirst();
        srContrlr.conshowLast();
        srContrlr.conenableDisablePaginationLinks();
        test.stopTest();
    }
    
    
    @isTest static void TestInitiativeRecordforPagination(){
        
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                            'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                            'test123@testmail.com','Practice Head', true);           
        
        System.runAs (usrObj) 
        {       
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9885443543',
                                                                                 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');
            List<Initiatives__c> InitList = new List<Initiatives__c>();
            Initiatives__c initiative = new Initiatives__c();
            initiative.Name = 'Test InitiativeName';
            initiative.Account_Service__c = accSrvc.id;
            initiative.Status__c = 'Initiative Submitted';
            insert initiative;
            InitList.add(initiative);
            
            test.startTest();
            PageReference pageRef = Page.ODS_SearchResult;
            Test.setCurrentPage(pageRef);
            ODS_SearchResultController srContrlr = new ODS_SearchResultController(); 
            srContrlr.AccountId = 'All';
            srContrlr.ServiceId = 'All';
            srContrlr.searchString = 'Test';
            srContrlr.InitCurrentPage = 0; 
            srContrlr.InitPageNumber = 1; 
            srContrlr.PageSize = integer.valueof(System.Label.PageSize);
            srContrlr.InitTotalRecords = InitList.size();
            
            srContrlr.getSearchResult();
            srContrlr.InitshowPrevious();
            srContrlr.InitshowNext();
            srContrlr.InitshowFirst();
            srContrlr.InitshowLast();
            srContrlr.InitenableDisablePaginationLinks();
            test.stopTest();
            
        }
        
    }
    
    @isTest static void TestStatusReportRecforPagination(){
        
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
            
            List<Status_Report__c> srList = new List<Status_Report__c>();
            Status_Report__c objSR = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.id,System.Today(),'Completed Development', 'Testing to be started', 'None','Submitted');
            srList.add(objSR);
            
            test.startTest();
            PageReference pageRef = Page.ODS_SearchResult;
            Test.setCurrentPage(pageRef);
            ODS_SearchResultController srContrlr = new ODS_SearchResultController(); 
            srContrlr.AccountId = 'All';
            srContrlr.ServiceId = 'All';
            srContrlr.searchString = 'Test';
            srContrlr.SrCurrentPage = 0; 
            srContrlr.SrPageNumber = 1; 
            srContrlr.PageSize = integer.valueof(System.Label.PageSize);
            srContrlr.SrTotalRecords = srList.size();
            
            srContrlr.getSearchResult();
            srContrlr.SrshowPrevious();
            srContrlr.SrshowNext();
            srContrlr.SrshowFirst();
            srContrlr.SrshowLast();
            srContrlr.SrenableDisablePaginationLinks();
            test.stopTest();
        }
    }
    
    @isTest static void TestTimesheetRecforPagination(){
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
            
            Time_Sheet_Cost__c objTmeShtCst = new Time_Sheet_Cost__c();
            objTmeShtCst.Account_Services__c = accSrvc.Id;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            objTmeShtCst.Start_Date_of_Month__c = Startdte;
            objTmeShtCst.End_Date_of_Month__c =  Enddte;
            objTmeShtCst.Month__c = 'Month';
            objTmeShtCst.Year__c = 'Year';
            insert objTmeShtCst;
            
            List<Timesheet__c>TsList = new List<Timesheet__c>();
            Timesheet__c tsObj = new Timesheet__c();
            tsObj.Name = 'Test TsName';
            tsObj.Account_Services__c = accSrvc.id;          
            tsObj.Approved_Date__c = aprveDt;
            tsObj.Comments__c = 'cmts';
            tsObj.Status__c = 'Submitted';
            tsObj.Status_Date__c = strtDt;
            tsObj.Week_Start_Date__c = strtDt;
            tsObj.Week_End_Date__c = endDt ;
            tsObj.Time_Sheet_Cost__c = objTmeShtCst.id;
            
            insert tsObj;
            TsList.add(tsObj);
            
            test.startTest();
            PageReference pageRef = Page.ODS_SearchResult;
            Test.setCurrentPage(pageRef);
            ODS_SearchResultController srContrlr = new ODS_SearchResultController(); 
            srContrlr.AccountId = 'All';
            srContrlr.ServiceId = 'All';
            srContrlr.searchString = 'Test';
            srContrlr.TsCurrentPage = 0; 
            srContrlr.TsPageNumber = 1; 
            srContrlr.PageSize = integer.valueof(System.Label.PageSize);
            srContrlr.TsTotalRecords = TsList.size();
            
            srContrlr.getSearchResult();
            srContrlr.TsshowPrevious();
            srContrlr.TsshowNext();
            srContrlr.TsshowFirst();
            srContrlr.TsshowLast();
            srContrlr.TsenableDisablePaginationLinks();
            test.stopTest();
        }
    }
    @isTest static void TestTaskforPagination(){
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
            List<Task> Tasklist = new list<Task>();
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            Task T = new Task();
            T.Type = 'Email';
            T.Description = 'Test Task'; 
            T.OwnerId = usrObj.id; 
            T.WhatId = accObj.Id; 
            insert T; 
            Tasklist.add(T);
            
            test.startTest();
            PageReference pageRef = Page.ODS_SearchResult;
            Test.setCurrentPage(pageRef);
            ODS_SearchResultController srContrlr = new ODS_SearchResultController(); 
            srContrlr.AccountId = 'All';
            srContrlr.ServiceId = 'All';
            srContrlr.searchString = 'Test';
            srContrlr.TaskCurrentPage = 0; 
            srContrlr.TaskPageNumber = 1; 
            srContrlr.PageSize = integer.valueof(System.Label.PageSize);
            srContrlr.TaskTotalRecords = Tasklist.size();
            
            srContrlr.getSearchResult();
            srContrlr.TaskshowPrevious();
            srContrlr.TaskshowNext();
            srContrlr.TaskshowFirst();
            srContrlr.TaskshowLast();
            srContrlr.TaskenableDisablePaginationLinks();
            test.stopTest();
        }
    }
    
    @isTest static void ViewTimesheet_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                    
        System.runAs (portalAccountOwner1) 
        {       
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1500,'9866857745', 'Others', 'ODS Project');     
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
            Date WeekStartdt= date.parse('11/07/2016');
            Date WeekEndDt = date.parse('11/13/2016');
            Date dtStatus = date.parse('11/10/2016');
            
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'WEDC');
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c objTmeSht = new Timesheet__c (Name = 'Test1',Time_Sheet_Cost__c = objTmeShtCst.Id,Approver_Name__c = portalAccountOwner1.Id,Approver_Email__c = 'TestApprvEmail@gmail.com',Comments__c = 'Test', Status_Date__c = dtStatus, Week_Start_Date__c = WeekStartdt, Week_End_Date__c=WeekEndDt, Account_Services__c=accSrvc.Id,Status__c = 'Approved');
            insert objTmeSht;
            test.startTest();
            
            PageReference pageRef = Page.ODS_SearchResult;
            Test.setCurrentPage(pageRef);
            ODS_SearchResultController viewTimshtontrlr = new ODS_SearchResultController(); 
            viewTimshtontrlr.CurrenTimesheetId = objTmeSht.Id;   
            viewTimshtontrlr.reDirecttoviewTimesheet();
            test.stopTest();
        }
    }
    //ViewInitiative Methods Test
    @isTest static void ViewInitiative_Test()
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
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            PageReference initiativePage = Page.ODS_SearchResult;
            Test.setCurrentPage(initiativePage);            
            
            ODS_SearchResultController initiativeCtrl = new ODS_SearchResultController();
            initiativeCtrl.CurrenInitiativeId = initiative.Id;
            initiativeCtrl.reDirecttoViewInitiative();                
        }
    }
    
    
    @isTest Static void EditStatusReport_Test()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                            'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                            'test123@testmail.com','Practice Head', true);           
        
        System.runAs (usrObj) {       
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9885443543','Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');
            
            Status_Report__c objSR = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.id,System.Today(),'Completed Development', 'Testing to be started', 'None','Submitted');
            PageReference pageRef = Page.ODS_SearchResult;
            pageRef.getParameters().put('editSRId', objSR.Id);
            Test.setCurrentPage(pageRef);
            
            ODS_SearchResultController objCntrllr = new ODS_SearchResultController();
            objCntrllr.reDirecttoStatusReport();     
        }                   
    }
    
    @isTest static void TestreDirecttoCustomer(){
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                            'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                            'test123@testmail.com','Practice Head', true);           
        
        System.runAs (usrObj) {       
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9885443543','Others', 'ODS Project'); 
            PageReference pageRef = Page.ODS_SearchResult;
            pageRef.getParameters().put('custId', accObj.Id);
            Test.setCurrentPage(pageRef);
            
            ODS_SearchResultController objCntrllr = new ODS_SearchResultController();
            objCntrllr.reDirecttoCustomer(); 
        }
    }
    
}