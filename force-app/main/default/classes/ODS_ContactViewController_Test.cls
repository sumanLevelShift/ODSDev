/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       ODS_ContactViewController_Test
* @description      This is the test class For ODS_ContactViewController Page
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	25-MAR-2021    	DemandBlue 		Initial Development
*********************************************************************************************/
@isTest
public class ODS_ContactViewController_Test {
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
            //insert newContact;
            
            Test.startTest();
            PageReference pageRef = Page.ViewContact;            
            pageRef.getParameters().put('CurrentAccountId',accObj.id);
            pageRef.getParameters().put('CurrentContactId',con.id);            
            Test.setCurrentPage(pageRef);
            ODS_ContactViewController testContact =  new ODS_ContactViewController();            
            testContact.AccountId = accObj.id;
            //testContact.GetLoggedUserAccountService();                   
            testContact.GetAccountServices();                                
            testContact.GetTimesheetByAccountServiceID();            
            testContact.getAccounts();
            testContact.getReportsToId();
            testContact.getRoleLevels();
            testContact.getForceComStatus();
            testContact.getODSDotNetStatus();
            testContact.newContact = newContact;
            Test.setMock(HttpCalloutMock.class, new RestMock());
            testContact.saveContact();
            testContact.redirectToContact();
            Test.stopTest();
        }     
    }
      public class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Json Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}