/**
* @author           Kalaiselvi R
* @version          1.0 
* @date             09-Nov-2016
* @Status           In Development
* @description      This is the test class for Header Controller
*/

@isTest 
public class ODS_HeaderController_Test
{
    /// <OBJECTIVE>
    /// Test positive scenario if the page name is Dashboard
    /// </OBJECTIVE>
    static TestMethod void upsertSession_PositiveTest()
    {//fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //fetch system Customer community
        Profile communityProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer community');
        
        //Insert user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                            'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                            'test123@testmail.com','Practice Head', true);
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
        
        //Insert Account
        Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9343256654', 'Others', 'ODS Project'); 
        
        //Insert Contact
        Contact objContact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, accObj.Id,
                                                                        'Others', 'ODS Project');
        
        Attachment objAttach = ODS_DataFactory_Test_Utility.insertAttachment('Unit Test Con Attachment',objContact.Id);
        //Insert User Photo
        User_Photo__c objUsrPhoto = ODS_DataFactory_Test_Utility.insertUsrPhoto(usrObj.Id);
        ODS_DataFactory_Test_Utility.insertAttachment('Unit Test user Attachment', objUsrPhoto.Id);
        
        system.runas(usrObj)
        {
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            
            test.startTest();
            PageReference pageRef = Page.Dashboard;
            test.setCurrentPage(pageRef);
            ODS_HeaderController objHdr =  new ODS_HeaderController();   
            objHdr.GetLoggedUserAccountService();
            objHdr.getServiceDropdownValues();
            objHdr.GetAccountPicklistValues();
            objHdr.SetRelatedService();
            objHdr.searchKey = 'Test';
            objHdr.search();
            objHdr.AccountId = accObj.Id;
            objHdr.ServiceId = odsSrv.Id;
            objHdr.getuserPhoto(); 
            test.stopTest();
            
        }        
    }
    /// <OBJECTIVE>
    /// Test positive scenario if the page name is Not Dashboard
    /// </OBJECTIVE>
    static TestMethod void upsertSession_NegativeTest()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                            'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                            'test123@testmail.com','Practice Head', true);
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        //Insert Account
        Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,3000,'9234433454', 'Others', 'ODS Project'); 
        //Insert Contact
        Contact objContact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, accObj.Id,
                                                                        'Others', 'ODS Project');
        Attachment objAttach = ODS_DataFactory_Test_Utility.insertAttachment('Unit Test Con Attachment',objContact.Id);
        //Insert User Photo
        User_Photo__c objUsrPhoto = ODS_DataFactory_Test_Utility.insertUsrPhoto(usrObj.Id);
        ODS_DataFactory_Test_Utility.insertAttachment('Unit Test user Attachment', objUsrPhoto.Id);
        
        system.runas(usrObj)
        {
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            
            test.startTest();
            PageReference pageRef = Page.customer;
            test.setCurrentPage(pageRef);
            ODS_HeaderController objHdr =  new ODS_HeaderController();
            objHdr.GetLoggedUserAccountService();
            objHdr.getServiceDropdownValues();
            objHdr.GetAccountPicklistValues();
            objHdr.AccountId = 'All';
            objHdr.ServiceId = 'All';
            objHdr.searchKey = 'Test';
            objHdr.getuserPhoto(); 
            objHdr.getPhoto(); 
            test.stopTest();
        }   
    }
    static testMethod void customers_PositiveTest()
    {      
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                     UserInfo.getUserId(), True,3000,'9678554553', 'Others', 'ODS Project');     
        Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
        Attachment objAttach = ODS_DataFactory_Test_Utility.insertAttachment('Unit Test Con Attachment',contact1.Id);
        Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
        User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                        'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                        'test12345@test.com', contact1.Id,'Customer');
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert user
        User usrObj1 = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                             'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                             'test123@testmail.com','Practice Head', true); 
        
        ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
        User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',
                                                                             usrObj1.Id,odsSrv.Id);
        date strtDt =  Date.today();
        date endDt = strtDt.adddays(5);
        //Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
        //150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'JHCNET');
        Account_Services__c accSrvc1 = ODS_DataFactory_Test_Utility.insertAccountServicesWithEngagementType(portalAccount1.id,strtDt, endDt,
                                                                                                            150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'JHCNET','ODS');
        
        System.runAs (user1 ) 
        {                 
            test.startTest();
            PageReference pageRef = Page.Customer;
            Test.setCurrentPage(pageRef);
            ODS_HeaderController objHdr =  new ODS_HeaderController();
            objHdr.GetLoggedUserAccountService();
            objHdr.getServiceDropdownValues();
            objHdr.GetAccountPicklistValues();
            objHdr.AccountId = 'All';
            objHdr.ServiceId = 'All';
            objHdr.getCustomerPhoto(); 
            ODS_HeaderController.RedirectDashboardPage(portalAccount1.Id,odsSrv.Id);
            
            PageReference pageRef1 = Page.viewTimesheet;
            Test.setCurrentPage(pageRef1);
            ODS_HeaderController objHdr1 =  new ODS_HeaderController();
            objHdr1.GetLoggedUserAccountService();
            objHdr1.getServiceDropdownValues();
            objHdr1.GetAccountPicklistValues();
            objHdr1.AccountId = 'All';
            objHdr1.ServiceId = 'All';
            objHdr1.getCustomerPhoto(); 
            objHdr1.searchKey = 'Test';
            objHdr1.search();
            ODS_HeaderController.RedirectDashboardPage(portalAccount1.Id,odsSrv.Id);
            PageReference pageRef2 = Page.ODS_SearchResult;
            pageRef2.getParameters().put('custId', portalAccount1.Id);
            Test.setCurrentPage(pageRef2);
            PageReference pageRef3 = Page.InitiativePage;
            Test.setCurrentPage(pageRef3);
            pageRef2.getParameters().put('AccountId',portalAccount1.id);
            ODS_HeaderController objHdr2 =  new ODS_HeaderController();
            // objHdr2.search();
            test.stopTest();
        }                   
    }
    
    
    static testMethod void EngtType_SOWTest()
    {      
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                     UserInfo.getUserId(), True,3000,'9678554553', 'Others', 'ODS Project');     
        Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
        Attachment objAttach = ODS_DataFactory_Test_Utility.insertAttachment('Unit Test Con Attachment',contact1.Id);
        Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
        User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                        'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                        'test12345@test.com', contact1.Id,'Customer');
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert user
        User usrObj1 = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                             'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                             'test123@testmail.com','Practice Head', true); 
        
        ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
        User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',
                                                                             usrObj1.Id,odsSrv.Id);
        date strtDt =  Date.today();
        date endDt = strtDt.adddays(5);
        //Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
        //150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'JHCNET');
        Account_Services__c accSrvc1 = ODS_DataFactory_Test_Utility.insertAccountServicesWithEngagementType(portalAccount1.id,strtDt, endDt,
                                                                                                            150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'JHCNET','SOW');
        
        System.runAs (user1 ) 
        {                 
            test.startTest();
            PageReference pageRef = Page.Customer;
            Test.setCurrentPage(pageRef);
            ODS_HeaderController objHdr =  new ODS_HeaderController();
            objHdr.GetLoggedUserAccountService();
            objHdr.getServiceDropdownValues();
            objHdr.GetAccountPicklistValues();
            objHdr.AccountId = 'All';
            objHdr.ServiceId = 'All';
            objHdr.getCustomerPhoto(); 
            objHdr.searchKey = 'Tests';
            objHdr.search();
            ODS_HeaderController.RedirectDashboardPage(portalAccount1.Id,odsSrv.Id);                        
            test.stopTest();
        }                   
    }
    
    //Added by Mani and Team for Channel Partner requirement
    static TestMethod void partner_Test()
    {
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                     UserInfo.getUserId(), True,3000,'9678554553', 'Others', 'ODS Project');
        portalAccount1.isPartner__c = true;
        portalAccount1.Partner_Commission__c = 10;
        update portalAccount1;
        
        Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
        
        Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
        User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                        'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                        'test12345@test.com', contact1.Id,'Partner');
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert user
        User usrObj1 = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                             'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                             'test123@testmail.com','Practice Head', true); 
        
        ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
        
        date strtDt =  Date.today();
        date endDt = strtDt.addDays(5);
        
        //Custom settings for invoice related stories
        /*ODS_Invoice_EmailControl__c cst = new ODS_Invoice_EmailControl__c();
cst.name = 'sendInvoiceEmail';
cst.isAllowed__c = true;
insert cst;

ODS_Invoice_EmailControl__c cst1 = new ODS_Invoice_EmailControl__c();
cst1.name = 'ccPracticeHead';
cst1.isAllowed__c = false;
insert cst1;*/
        Account odsAcc1 = new Account();
        odsAcc1.Name = 'TestOdsAccount';
        odsAcc1.OwnerID = usrObj1.Id;
        odsAcc1.Is_Portal_Access__c = true;
        odsAcc1.AnnualRevenue = 3000000;
        odsAcc1.Phone = '9678554553';
        odsAcc1.Lead_Gen_Name__c = 'Others';
        odsAcc1.If_Others_Please_Specify__c = 'ODS Project';
        odsAcc1.NumberofEmployees = 100;
        odsAcc1.Industry = 'Technology';
        odsAcc1.Channel_Partner__c = portalAccount1.Id;
        odsAcc1.Channel_Partner_Contact__c = contact1.Id;
        insert odsAcc1;
        
        User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(odsAcc1.id,'Technical Account Manager',
                                                                             usrObj1.Id,odsSrv.Id);
        
        //Insert Account service
        Account_Services__c accSrvc1 = ODS_DataFactory_Test_Utility.insertAccountServicesWithEngagementType(odsAcc1.id,strtDt, endDt,
                                                                                                            150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'JHCNET','ODS');
        
        System.runAs (user1) 
        {                 
            test.startTest();
            PageReference pageRef = Page.Dashboard;
            Test.setCurrentPage(pageRef);
            ODS_HeaderController objHdr =  new ODS_HeaderController();
            objHdr.GetLoggedUserAccountService();
            objHdr.getServiceDropdownValues();
            objHdr.GetAccountPicklistValues();
            objHdr.AccountId = 'All';
            objHdr.ServiceId = 'All';
            objHdr.getCustomerPhoto(); 
            //ODS_HeaderController.RedirectDashboardPage(portalAccount1.Id,odsSrv.Id);
            
            PageReference pageRef1 = Page.viewTimesheet;
            Test.setCurrentPage(pageRef1);
            ODS_HeaderController objHdr1 =  new ODS_HeaderController();
            objHdr1.GetLoggedUserAccountService();
            objHdr1.getServiceDropdownValues();
            objHdr1.GetAccountPicklistValues();
            objHdr1.AccountId = 'All';
            objHdr1.ServiceId = 'All';
            objHdr1.getCustomerPhoto(); 
            //ODS_HeaderController.RedirectDashboardPage(portalAccount1.Id,odsSrv.Id);                                    
            test.stopTest();
        }        
    }
    
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
            
            
            
            test.startTest();
            
            ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
            PageReference pageRef4 = Page.ODS_SearchResult;
            Test.setCurrentPage(pageRef4);
            pageRef4.getParameters().put('accntId',accObj.id);
            
            cmnUtil.getCustomersByLoggedInUser('InitiativePage');
            ODS_Services__c odsSrv1 = ODS_DataFactory_Test_Utility.insertODSServices('ODSDOTNETTest','test',true);         
            ODS_Common_Utility.upsertSessionData(accObj.Id,odsSrv1.Id);
            list<ODS_SessionData__c> lSession = ODS_Common_Utility.fetchSessionData(UserInfo.getUserId());
            PageReference pageRef2 = Page.InitiativePage;
            Test.setCurrentPage(pageRef2);
            pageRef2.getParameters().put('AccountId',accObj.id);
            ODS_HeaderController objHdr1 =  new ODS_HeaderController();
            objHdr1.GetLoggedUserAccountService();
            
            PageReference pageRef3 = Page.viewtimesheet;
            Test.setCurrentPage(pageRef3);
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, accObj.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = accObj.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            objHdr1.getServiceDropdownValues();
            objHdr1.GetAccountPicklistValues();
            
            objHdr1.AccountId='All';
            objHdr1.SetRelatedService();
            test.stopTest();
            
            
        }        
    }
    @isTest
    Public Static void customerUser(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                     UserInfo.getUserId(), True,3000,'9678554553', 'Others', 'ODS Project');     
        Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
        Attachment objAttach = ODS_DataFactory_Test_Utility.insertAttachment('Unit Test Con Attachment',contact1.Id);
        Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
        User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                        'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                        'test12345@test.com', contact1.Id,'Customer');
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert user
        User usrObj1 = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                                                                             'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                             'test123@testmail.com','Practice Head', true); 
        
        ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
        User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',
                                                                             usrObj1.Id,odsSrv.Id);
        date strtDt =  Date.today();
        date endDt = strtDt.adddays(5);
        //Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
        //150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'JHCNET');
        Account_Services__c accSrvc1 = ODS_DataFactory_Test_Utility.insertAccountServicesWithEngagementType(portalAccount1.id,strtDt, endDt,
                                                                                                            150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'JHCNET','SOW');
        
        System.runAs (user1 ) 
        {   Test.startTest();
         ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
         cmnUtil.getCustomersByLoggedInUser('InitiativePage');
         ODS_Services__c odsSrv1 = ODS_DataFactory_Test_Utility.insertODSServices('ODSDOTNETTest','test',true);         
         ODS_Common_Utility.upsertSessionData(portalAccount1.Id,odsSrv1.Id);
         list<ODS_SessionData__c> lSession = ODS_Common_Utility.fetchSessionData(UserInfo.getUserId());
         PageReference pageRef2 = Page.InitiativePage;
         Test.setCurrentPage(pageRef2);
         pageRef2.getParameters().put('AccountId',portalAccount1.id);
         ODS_HeaderController objHdr1 =  new ODS_HeaderController();
         objHdr1.GetLoggedUserAccountService();
         
         PageReference pageRef3 = Page.viewTimesheet;
         Test.setCurrentPage(pageRef3);
         contact1.Is_Approver__c = True;
         update contact1;
         Contact_Account_Service__c cas = new Contact_Account_Service__c();
         cas.Account__c = portalAccount1.Id;
         cas.Contact__c = contact1.Id;
         cas.Is_Approver__c = true;
         cas.ODS_Service__c = odsSrv.Id;
         cas.Type_of_Engagement__c = 'ODS';
         insert cas; 
         objHdr1.getServiceDropdownValues();
         objHdr1.GetAccountPicklistValues();
         objHdr1.isCustomer=true;
         objHdr1.getPhoto();
         objHdr1.getUserPhoto();
         objHdr1.getCustomerPhoto(); 
         objHdr1.searchKey = 'Test';
         objHdr1.search();
         objHdr1.AccountId='All';
         objHdr1.SetRelatedService();
         test.stopTest();
        }
    }
    @istest
    public Static void odsService(){
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
            
            
            
            test.startTest();
            
            ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
            
            
            cmnUtil.getCustomersByLoggedInUser('ODS_SearchResult');
            
            ODS_Services__c odsSrv1 = ODS_DataFactory_Test_Utility.insertODSServices('ODSDOTNETTest','test',true);         
            ODS_Common_Utility.upsertSessionData(accObj.Id,odsSrv1.Id);
            list<ODS_SessionData__c> lSession = ODS_Common_Utility.fetchSessionData(UserInfo.getUserId());
            PageReference pageRef5 = Page.ODS_SearchResult;
            Test.setCurrentPage(pageRef5);
            pageRef5.getParameters().put('accntId',accObj.id);
            ODS_HeaderController objHdr1 =  new ODS_HeaderController();
            
            objHdr1.GetLoggedUserAccountService();
            
            objHdr1.getServiceDropdownValues();
            objHdr1.GetAccountPicklistValues();
            
            objHdr1.AccountId='All';
            objHdr1.SetRelatedService();
            test.stopTest();
            
            
        }   
    }
}