@isTest
public class ODS_CustomerInfoControllerLWCTest {
    @isTest
    public static void Test_Account(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    
        System.runAs (usrObj) 
        {        
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
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
            string queueDeveloperName = system.label.SF_Incidents_Queue_Name;
            group Queue = [Select Id, Name from Group where Type = 'Queue' AND DeveloperName = :queueDeveloperName limit 1];
            
            Case c = new Case();
            C.Status = 'New';
            C.Origin = 'Email';
            c.Priority = 'Medium';
            c.subject='UPDATED - Incident 6173 - Performance Degradation - Asynchronous Processing';
            c.SuppliedEmail = 'alerts@mail.salesforce.com';
            c.Description = 'Incident Information Impacted Instances: NA73\n'+ 'Impacted Services: Core Service ';
            c.OwnerId=Queue.id;
            c.Instance_Names__c=testaccount.Instance_Name__c;
            insert c; 
            
            schema.EmailMessage email = new schema.EmailMessage();
            email.FromAddress = 'alerts@mail.salesforce.com';
            email.Incoming = True;
            email.ToAddress= 'sfadmin@8k8jcgqmr32e6fxp9jwf271eh7bztieom1n3z9a8rf3qvg56b.3d-9tbzuau.cs70.case.sandbox.salesforce.com';
            email.Subject = 'UPDATED - Incident 6173 - Performance Degradation - Asynchronous Processing';
            email.HtmlBody = '<html> <head> <title></title> </head> <body>Description<br /> We are working urgently to resolve this issue. For the latest information please see:<br /> <br /> View Incident Detail<br /> <br /> Thank You<br /> Salesforce Incident Management Team<br /> Incident Information<br /> <br /> Impacted Instances:<br /> NA99<br /> <br /> Impacted Services:<br /> Live Agent<br /> <br /> Incident Impact Type:<br /> Feature Disruption<br /> During a feature disruption, end users are unable to access certain aspects of the service.<br /> <br /> In order to show timely and accurate status information some content may not be translated.<br /> Please take 1 minute to provide feedback so that we can make Trust Notifications even better! Feedback<br /> You are receiving this email because you are subscribed to Salesforce Trust Notifications. Notification Center<img src="https://demandblue--lexcomm.my.salesforce.com/servlet/servlet.ImageServer?oid=00D8G0000004dBA&esid=0188G000000Ff8d&from=int"><br><br>ref:_00D8G4dBA._5008G1Btvk:ref</body> </html>';
            email.ParentId = c.Id; 
            insert email;
            
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(testaccount.Id,strtDt, endDt,150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET'); 
            
            Case Ca = new Case();
            Ca.Status = 'Not Started';
            Ca.Origin = 'Web';
            Ca.Priority = 'Medium';
            Ca.subject='Release Updates and Impact Analysis';
            Ca.SuppliedEmail = 'alerts@mail.salesforce.com';
            Ca.Description = 'Incident Information Impacted Instances: NA73\n'+ 'Impacted Services: Core Service ';
            Ca.AccountId = testaccount.Id;
            Ca.Account_Services__c = accSrvc.Id;
            insert Ca; 
            List<Case> newCaseList = new List<Case>();
            string draft='[{"orgId":"1234","salesforceProduct":"Sales Cloud","appexchangeApps":"Test","CustomerProtalAccess":"Not Started","customerPortalAccessStatusDate":"2023-02-08","CPQProduct":"Dev1","SetupWeeklyMonthlyMeeting":"Not Started","Marketing":"1","setupWeeklyMonthlyMeetingDate":"2023-02-08","Middleware":"3","EnvironmentAccess":"Not Started","ERP":"","EnvironmentAccessStatusDate":"2023-02-08","OnboardingDocument":"Not Started","ExternalStorage":"","OnboardingDocumentStatusDate":"2023-02-08","LightningReadinessCheck":"Not Started","Analytics":"","Backup":"","InstanceName":"odsdev","ProjectManagement":"","MarketingCloudInstanceName":"odsdev1","DevelopmentTools":"Ant","hasCommunities":false,"CustomerEnagementScore":"2 - Regular Engagement","BusinessOverview":"1","ProductServicesOffered":"2","Customers":"3","CollaboratorsPartners":"5","ComplianceRequirements":"6","KeyCompetitors":"4","SalesforceRoadMap":"7","ProductBacklog":"8","CurrentPainpoints":"90"}]';
            
            Test.startTest();
            ODS_CustomerInfoControllerLWC.getCurrentAccount(testaccount.id);
            ODS_CustomerInfoControllerLWC.updateCustomerInfo(draft,testaccount.id,'Daily','Immediate action required','Immediate action required','Immediate action required','Immediate action required',true);
            ODS_CustomerInfoControllerLWC.getAccountService(testaccount.id);
            ODS_CustomerInfoControllerLWC.getAccountIncidents(testaccount.id);
            // ODS_CustomerInfoControllerLWC.updateStatusReportFrequency(testaccount.id, 'Daily',true);
            ODS_CustomerInfoControllerLWC.getEmail(email.id);
            // ODS_CustomerInfoControllerLWC.getCustomerEngagementValue(testaccount.Id);
            ODS_CustomerInfoControllerLWC.getSalesforceAFDetails(testaccount.Id);
            // ODS_CustomerInfoControllerLWC.getCustomerEngagementScorePicklist();
            ODS_CustomerInfoControllerLWC.updateSessionData(testaccount.Id,odsSrv.id);
            ODS_CustomerInfoControllerLWC.getCases(testaccount.Id,odsSrv.id);
            ODS_CustomerInfoControllerLWC.updateCases(newCaseList);
            
                        
            Test.setMock(HttpCalloutMock.class, new UpdateKickOffMockHttp());
            
            ODS_CustomerInfoControllerLWC.updateKickoffStatus(Date.today(),testaccount.id);
            
            Test.stopTest();
        } 
    }
  public class UpdateKickOffMockHttp implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint('callout:ODS_Org/services/apexrest/kickoff');
            request.setHeader('Content-Type','application/json');
            res.setBody('{"completedDate":"2023-07-03","kickoffStatus":"Completed","accountId":"0018M00000JTlEBQA1"}');
            res.setStatusCode(200);
            return res;
            
        }
    }
}