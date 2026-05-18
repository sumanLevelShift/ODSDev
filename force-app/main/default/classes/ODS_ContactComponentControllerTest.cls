@isTest
public class ODS_ContactComponentControllerTest {
    public static testMethod void testContact() {
        
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
            Contact con = new Contact();
            con.FirstName = 'Test firstName';
            con.LastName = 'TestlastName';
            con.AccountId = accObj.id;
            con.Title = 'Developer';
            con.MailingStreet = 'MailingStreet';
            con.MailingCity = 'MailingCity';
            con.MailingState = 'MS';
            con.MailingPostalCode = '98304';
            con.MailingCountry = 'MailingCountry';
            con.MobilePhone = '9876543210';
            con.If_Others_Please_Specify__c = 'Test specifyOthers';
            con.Email = 'test123@testmail.com';
            insert con;
            accObj.Primary_Customer_Contact__c = con.id;
            update accObj;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(string.valueOf(accObj.id),strtDt, endDt,
                                                                                             150.0, string.valueOf(odsSrv.id), 1000.0, 'Monthly', string.valueOf(usrObj.Id), 'WEDCNET');            
            
            Contact newContact = new Contact();
            newContact.FirstName = 'Test firstName';
            newContact.LastName = 'LastName Test';
            newContact.AccountId = accObj.id;
            newContact.Title = 'Developer';
            newContact.MailingStreet = 'MailingStreet';
            newContact.MailingCity = 'MailingCity';
            newContact.MailingState = 'MS';
            newContact.MailingPostalCode = '98304';
            newContact.MailingCountry = 'MailingCountry';
            newContact.MobilePhone = '9876543210';
            newContact.If_Others_Please_Specify__c = 'Test specifyOthers';
            newContact.Email = 'test123@testmail.com';
            insert newContact;
            
            Test.startTest();
            ODS_ContactComponentController testContact =  new ODS_ContactComponentController();
            ODS_ContactComponentController.GetContacts(accObj.Id,accSrvc.Id);   
            ODS_ContactComponentController.AccountId = accObj.id;
            ODS_ContactComponentController.ServiceId = accSrvc.id;
            ODS_ContactComponentController.GetAccountPicklistValues();
            ODS_ContactComponentController.getCurrentContact(newContact.Id);
            ODS_ContactComponentController.updateSelectedContact(newContact.Id,newContact.ReportsToId ,newContact.MailingState,accObj.Id,newContact.OtherState,newContact.MailingPostalCode,newContact.OtherPostalCode,newContact.MobilePhone);
           // ODS_ContactComponentController.updateSelectedContact(newContact.Id,newContact.ReportsToId , accObj.Id);
            ODS_ContactComponentController.updateSessionData(accObj.id, accSrvc.id);
            ODS_ContactComponentController.getReportId(accObj.id);
            ODS_ContactComponentController.getAccountList();
            ODS_ContactComponentController.getODSDotNetStatusPickListValue();
            ODS_ContactComponentController.getStatusPickListValue();
            Test.stopTest();
            
        }     
    }
}