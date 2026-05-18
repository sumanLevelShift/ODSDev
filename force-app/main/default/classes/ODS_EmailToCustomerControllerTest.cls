/*******************************************************************************************
* @author           Gireesh and Vignesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       ODS_EmailToCustomerControllerTest
* @description      This is the test class For ODS_EmailToCustomer Page
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	13 OCT 2020    	DemandBlue 		Initial Development
*********************************************************************************************/
@isTest
public class ODS_EmailToCustomerControllerTest {
    public static testMethod void testAllcustomer() {
        
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
            
            List<DraftEmail__c> DraftEmailList = new List<DraftEmail__c>();
            DraftEmail__c Des = new DraftEmail__c();
            //Des.Name = 'emails';
            Des.EmailBody__c = 'All test';
            Des.EmailSubject__c ='Test';
            Des.EmailStatus__c = 'Draft';
            Des.OwnerId = UserInfo.getUserId();
            //Des.IsDeleted__c = true	;
            insert Des;
            DraftEmailList.add(Des);            
            List<SelectOption> lstSlctOptn = new list<SelectOption> ();
            lstSlctOptn.add(new SelectOption(accObj.Id, accObj.Name));
            ODS_Common_Utility objUtility = new  ODS_Common_Utility();
            objUtility.getCustomersByLoggedInUser('Partner');
            Attachment att=new Attachment();
            Test.startTest();
            ODS_EmailToCustomerController  tests =  new ODS_EmailToCustomerController() ;
            tests.selectedCustomers = lstSlctOptn;
            tests.attachment1 = att;
            tests.attachment2 = att;
            tests.selectedCustomers = lstSlctOptn ;
            DraftEmail__c draftEmail = new DraftEmail__c();           
            draftEmail.EmailBody__c = 'All test';
            draftEmail.EmailSubject__c ='Test';
            draftEmail.EmailStatus__c = 'Draft';
            draftEmail.OwnerId = UserInfo.getUserId();
            tests.draftEmail = draftEmail;
            insert draftEmail;
            tests.saveDraftEmail();
            List<String> EmailAddressTemp = new List<String>{'gireesh_k@preludesys.com','gireesh_k@preludesys.com'};         
            tests.sendEmails();
            tests.getSelectedCustomers();
            ODS_EmailToCustomerController.getCustomerNames(string.valueOf(accObj.id));
            tests.getSendEmail(EmailAddressTemp, EmailAddressTemp, 'EmailSubject', 'EmailBody', '124');
            PageReference pageRef = Page.ODS_EmailToCustomer;            
            pageRef.getParameters().put('DraftEmailId',Des.id);
            Test.setCurrentPage(pageRef);            
            tests.deleteDraftEmail();
            tests.CurrentPage = 0; 
            tests.PageNumber = 1; 
            tests.PageSize = integer.valueof(System.Label.PageSize);
            tests.TotalRecords = DraftEmailList.size();            
            tests.getDraftEmails();
            tests.showPrevious();
            tests.showNext();
            tests.showFirst();
            tests.showLast();
            tests.enableDisablePaginationLinks();
            
            
            Test.stopTest();
            
        }     
    }
    
}