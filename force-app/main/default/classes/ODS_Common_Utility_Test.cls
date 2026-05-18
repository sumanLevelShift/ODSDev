/*
--Author: Mani and Team
--Purpose: Unit test for ODS_Common_Utility
--Created on: 28/Jun/2018
*/
@isTest
public class ODS_Common_Utility_Test
{
    
    public static testMethod void testAllQueries() {
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                            'California', True,2000,'9433578865', 'Others', 'ODS Project');
        ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('ODSDOTNETTest','test',true);                                  
        
        ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
        cmnUtil.getCustomersByLoggedInUser();
        cmnUtil.getCustomersQueryByLoggedInUser();
        cmnUtil.getAllAccountIDByLoggedInUser();
        cmnUtil.getCustomersByLoggedInUser('Dashboard');
        cmnUtil.getCustomersByLoggedInUser('viewTimesheet');
        
        ODS_Common_Utility.upsertSessionData(portalAccount1.Id,odsSrv.Id);
        list<ODS_SessionData__c> lSession = ODS_Common_Utility.fetchSessionData(UserInfo.getUserId());
        ODS_Common_Utility.upsertSessionData(portalAccount1.Id,odsSrv.Id);
                ODS_Common_Utility.generateProjectCodeforAccount(portalAccount1.Name);

    }
    
    public static testMethod void testAllQueriesAsPartner() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account acc = new Account();
        acc.Name = 'Test partner Acc123';
        acc.OwnerID = UserInfo.getUserId();
        acc.Is_Portal_Access__c = true;
        acc.AnnualRevenue = 2000;
        acc.Phone = '98989898';
        acc.Lead_Gen_Name__c = 'Others';
        acc.If_Others_Please_Specify__c = 'something';
        acc.NumberofEmployees = 100;
        acc.Industry = 'Technology';
        acc.isPartner__c = true;
        acc.Project_Code__c ='AAA';
        acc.Partner_Commission__c = 10;
        insert acc;
        
           Account acc1 = new Account();
        acc1.Name = 'Test partner Acc123';
        acc1.OwnerID = UserInfo.getUserId();
        acc1.Is_Portal_Access__c = true;
        acc1.AnnualRevenue = 2000;
        acc1.Phone = '98989898';
        acc1.Lead_Gen_Name__c = 'Others';
        acc1.If_Others_Please_Specify__c = 'something';
        acc1.NumberofEmployees = 100;
        acc1.Industry = 'Technology';
        acc1.isPartner__c = true;
        acc1.Project_Code__c ='AAA';
        acc1.Partner_Commission__c = 10;
        insert acc1;
        
        Contact contactPartner = ODS_DataFactory_Test_Utility.InsertContact('TestPartner','McTesty', True, acc.Id, 'Others', 'ODS Project');
        contactPartner.Email = 'testPartner@test.com';
        update contactPartner;
        
        User usr = new user();
        usr.Alias = 'india';
        usr.Email= 'testPartner@test.com';          
        usr.EmailEncodingKey='UTF-8';
        usr.LastName='testPartner';
        usr.LanguageLocaleKey='en_US'; 
        usr.LocaleSidKey='en_US';
        usr.ProfileId = profile1.Id;
        usr.ContactId = contactPartner.Id; 
        usr.TimeZoneSidKey='America/Chicago';
        usr.UserName=System.now().millisecond()+'test123@testmail.com';
        usr.PortalUserRole__c = 'Partner';
        usr.Is_Portal_Access__c = true;
        usr.isActive = true;
        //usr.UserRoleId = portalRole.Id;
        
        insert usr;
        
        /*   Account_Services__c accService = new Account_Services__c();
accService.Account__c = acc.Id;
accService.Contract_Start_Date__c = system.today();
accService.Contract_End_Date__c = system.today() + 10;
accService.Timesheet_Start_Date__c = system.today()-20;
accService.Technical_Account_manager__c = usr.id;
accService.Timesheet_Start_Date__c = system.today();
accService.Document_Suffix__c = '_ATA';
accService.Contract_Term__c = 'Net 15';
accService.Purchase_Order__c = 'None';
insert accService;
*/
        System.runAs(usr) {
            ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
            cmnUtil.getCustomersByLoggedInUser();
            cmnUtil.getCustomersByLoggedInUser('Dashboard');
            cmnUtil.getCustomersByLoggedInUser('viewTimesheet');
            cmnUtil.getAllAccountIDByLoggedInUser();     
            ODS_Common_Utility.generateProjectCodeforAccount(acc.Name);
            
        }
    }
    
    public static testMethod void testAllQueriesAsCustomer() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account acc = new Account();
        acc.Name = 'Test partner Acc123';
        acc.OwnerID = UserInfo.getUserId();
        acc.Is_Portal_Access__c = true;
        acc.AnnualRevenue = 2000;
        acc.Phone = '98989898';
        acc.Lead_Gen_Name__c = 'Others';
        acc.If_Others_Please_Specify__c = 'something';
        acc.NumberofEmployees = 100;
        acc.Industry = 'Technology';
        acc.isPartner__c = true;
        acc.Project_Code__c ='AAA';
        acc.Partner_Commission__c = 10;
        insert acc;
        
        Contact contactPartner = ODS_DataFactory_Test_Utility.InsertContact('TestPartner','McTesty', True, acc.Id, 'Others', 'ODS Project');
        contactPartner.Email = 'testPartner@test.com';
        update contactPartner;
        
        User usr = new user();
        usr.Alias = 'india';
        usr.Email= 'testPartner@test.com';          
        usr.EmailEncodingKey='UTF-8';
        usr.LastName='testPartner';
        usr.LanguageLocaleKey='en_US'; 
        usr.LocaleSidKey='en_US';
        usr.ProfileId = profile1.Id;
        usr.ContactId = contactPartner.Id; 
        usr.TimeZoneSidKey='America/Chicago';
        usr.UserName=System.now().millisecond()+'test123@testmail.com';
        usr.PortalUserRole__c = 'Customer';
        usr.Is_Portal_Access__c = true;
        usr.isActive = true;
        //usr.UserRoleId = portalRole.Id;
        
        insert usr;
        
        System.runAs(usr) {            
            ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
            cmnUtil.getCustomersByLoggedInUser();
            cmnUtil.getCustomersByLoggedInUser('Dashboard');
            cmnUtil.getCustomersByLoggedInUser('viewTimesheet');
            cmnUtil.getAllAccountIDByLoggedInUser(); 
             ODS_Common_Utility.generateProjectCodeforAccount(acc.Name);
        }
        
        
    }
    
    @isTest(SeeAllData=true)
    public static void testAllQueriesAsPracticeHead() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Practice Head', true,portalRole.Id);  
        
        portalAccountOwner1.Management__c = 'Practice Head';
        update portalAccountOwner1;
        
        System.runAs(portalAccountOwner1) {            
            ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
            cmnUtil.getCustomersByLoggedInUser();
            cmnUtil.getCustomersByLoggedInUser('Dashboard');
            cmnUtil.getCustomersByLoggedInUser('viewTimesheet');        
        }
    }
    
     @isTest(SeeAllData=true)
    public static void testAllQueriesAsPracticeHead1() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Practice Head', true,portalRole.Id);  
        
        portalAccountOwner1.Management__c = 'Practice Head';
        update portalAccountOwner1;
        
        System.runAs(portalAccountOwner1) {            
            ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
            cmnUtil.getCustomersByLoggedInUser();
            
            cmnUtil.getCustomersByLoggedInUser('viewTimesheet');        
        }
    }
    
    
    @isTest(SeeAllData=true)
    public static void testAllQueriesAsTechAccMngr() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);  
        
        System.runAs(portalAccountOwner1) {            
            ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
            //cmnUtil.getCustomersByLoggedInUser();
            cmnUtil.getCustomersByLoggedInUser('Dashboard');
            cmnUtil.getCustomersByLoggedInUser('viewTimesheet');        
        }
    }        
    
    @isTest(SeeAllData=true)
    public static void testAllQueriesAsdirectorcsm() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRoleDirector();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);  
        system.debug('portalAccountOwner1====>'+portalAccountOwner1);
        System.runAs(portalAccountOwner1) {            
            ODS_Common_Utility cmnUtil = new ODS_Common_Utility();
            //cmnUtil.getCustomersByLoggedInUser();
            cmnUtil.getCustomersByLoggedInUser('Dashboard');
            cmnUtil.getCustomersByLoggedInUser('viewTimesheet');    
            string emailSign=ODS_Common_Utility.getEmailSignature(portalAccountOwner1.Name,'CSM','1234567890',portalAccountOwner1.Email);
            ODS_Common_Utility.getEmailMessage('Hi Team',emailSign);
        }
    }  
}