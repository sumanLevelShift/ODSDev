@isTest
public class ODS_CustomerInfoControllerTest {
    
    static testMethod void testMethod1()
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
            //  Account testaccount = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            
            Account testaccount = new account();
            testaccount.Name = 'Test Account';    
            testaccount.OwnerId = usrObj.Id;
            testaccount.Is_Portal_Access__c = True;
            testaccount.AnnualRevenue = 1500;
            testaccount.Lead_Gen_Name__c = 'Others';
            testaccount.phone = '9999900000';
            testaccount.NumberofEmployees = 100;
            testaccount.Industry = 'Technology';
            testaccount.If_Others_Please_Specify__c = 'ODS Project';
            testaccount.Customer_Portal_Access__c = 'Not Started' ; 
            testaccount.Customer_Engagement_Score__c = 'None' ;   
            testaccount.Setup_Weekly_Monthly_Meeting__c = 'Completed' ;
            testaccount.Environment_Access__c =  'Completed';
            testaccount.Onboarding_Document__c = 'Approved' ;
            testaccount.Lightning_Readiness_Check__c ='Not Started'  ;
            testaccount.Instance_Name__c = 'cs28' ;
            testaccount.Organization_ID__c = '123456789987' ;
            testaccount.Salesforce_Products__c ='New'  ;
            testaccount.Business_Overview__c ='Test1'  ;
            testaccount.Customers__c ='Test1New'  ;
            testaccount.Key_Competitors__c ='Test11New'  ;
            testaccount.Collaborators_Partners__c ='Test2New'  ;
            testaccount.Compliance_Requirements__c ='Test3New'  ;
            testaccount.Current_Painpoints__c ='Test4New'  ;
            testaccount.Product_Backlog__c ='Test5New'  ;
            testaccount.Products_Services_Offered__c ='Test6New'  ;
            testaccount.Salesforce_Roadmap__c ='Test7New'  ;
            testaccount.Appexchange_Apps__c = 'Latest Apps' ;
            testaccount.Customer_Service__c = 'Not available' ;
            testaccount.CPQ_Product__c = 'No' ;
            testaccount.Marketing__c = 'New Market' ;
            testaccount.Middleware__c = 'No' ;
            testaccount.Has_Communities__c = True;
            testaccount.Marketing_Cloud_Instance_Name__c ='DB67';
            testaccount.ERP__c = 'Yes' ;
            testaccount.Document_Generation__c = 'Not Needed' ;
            testaccount.External_Storage__c = 'Available' ;
            testaccount.Digital_Signature__c = 'Pratyush' ;
            testaccount.Analytics__c = 'Needed' ;
            testaccount.Backup__c = 'Not available' ;
            testaccount.Project_Management__c = 'z' ;
            testaccount.Development_Tools__c =  'LWC';
            testaccount.Customer_Portal_Access_Status_Date__c = system.today() ;
            testaccount.Setup_Weekly_MonthlyMeeting_Date__c = system.today() ;
            testaccount.Environment_Access_Status_Date__c =  system.today();
            testaccount.Onboarding_Document_Status_Date__c = system.today();
            testaccount.Lightning_Readiness_Check_Status_Date__c = system.today() ;
            Insert testaccount;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(testaccount.Id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',testaccount.Id,odsSrv.Id);
            
            Case c = new Case();
            C.Status = 'New';
            C.Origin = 'Email';
            c.Priority = 'Medium';
            c.subject='UPDATED - Incident 6173 - Performance Degradation - Asynchronous Processing';
            c.SuppliedEmail = 'alerts@mail.salesforce.com';
            c.Description = 'Incident Information Impacted Instances: NA73\n'+ 'Impacted Services: Core Service ';
            insert c; 
            schema.EmailMessage email = new schema.EmailMessage();
            email.FromAddress = 'alerts@mail.salesforce.com';
            email.Incoming = True;
            email.ToAddress= 'sfadmin@8k8jcgqmr32e6fxp9jwf271eh7bztieom1n3z9a8rf3qvg56b.3d-9tbzuau.cs70.case.sandbox.salesforce.com';
            email.Subject = 'UPDATED - Incident 6173 - Performance Degradation - Asynchronous Processing';
            email.HtmlBody = 'Test email body';
            email.ParentId = c.Id; 
            insert email;
        
              
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(testaccount.Id,strtDt, endDt,150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET'); 
            accSrvc.Status_Report_Frequency__c = 'Daily';
            Update accSrvc;
            ApexPages.currentPage().getParameters().put('SelectedAccountId',testaccount.Id);
            ApexPages.currentPage().getParameters().put('SelectedServiceID',accSrvc.ODS_Service_Name__c);
            ApexPages.currentPage().getParameters().put('emailId',email.Id);
            //ApexPages.currentPage().getParameters().put(DatatoSaveJSON);
            ODS_CustomerInfoController test = new ODS_CustomerInfoController();
            List<SelectOption> optionValues1 = test.getCustomerPortalAccessPicklist;  
            List<SelectOption> optionValues2 = test.getWeeklyMonthlyMeetingPicklist; 
            List<SelectOption> optionValues3 = test.getEnvironmentAccessPicklist;  
            List<SelectOption> optionValues4 = test.getOnboardingDocumentPicklist;
            List<SelectOption> optionValues5 = test.getLRCPicklist; 
            List<SelectOption> optionValues6 = test.getCustomerEngagementScorePicklist;
            List<SelectOption> optionValues7 = test.getStatusReportPickList;

            
            test.AccountToSaveData = testaccount.Id;
            test.DatatoSaveJSON =  '{"Org_Id":"555","Customer_Portal_Access":"Approved", "Customer_Engagement_Score":"Regular Engagement","Customer_Portal_Access_Status_Date":"2020-08-13","Weekly_Monthly_Meeting":"Completed","Setup_Weekly_Monthly_Meeting_Date":"2020-08-13","Environment_Access":"Completed","Onboarding_Document":"Approved","Onboarding_Document_Status_Date":"2020-08-13","LRC":"Not Started","LRC_Status_Date":"2020-08-13","Instance_Name":"5","Salesforce_Products":"New","Appexchange_Apps":"All","Customer_Service":"Available","CPQ_Product":"no","Marketing":"no","Middleware":"yes","ERP":"Required","Document_Generation":"needed","External_Storage":"not required","Digital_Signature":"Zigsy","Analytics":"Einstein","Backup":"Not Available","Project_Management":"alloted","Development_Tools":"lwc"}';
            
            test.getAccountServiceId();
            test.SaveCustomerInfo();
            test.cancelChanges();
            test.closePopup();
            test.showPopup();
        }
    }
}