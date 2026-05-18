/**
* @author           Gnana Prakash
* @version          1.0 
* @date             17-Apr-2018
* @Status           Developed
* @description      This is the test class for ODS_JIRAIntegration class
*/

@isTest 
public class ODS_JIRAIntegration_Test
{
    /// <OBJECTIVE>
    /// Test dashboard functionality such as cost saving, TAM and Chart with positive flow.
    /// </OBJECTIVE>  
    public static testMethod void createJiraIssueMethods_Test()
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
            
            List<String> jiraTest = new List<String>();
            jiraTest.add('Tes-12');
            accSrvc.Service_Workspace_Id__c = '152';
            accSrvc.Purchase_Order__c = '12345';
            accSrvc.Technical_Account_Manager_Email__c = 'sfadmin@demandblue.com';
            update accSrvc;
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            Status_Report__c statReport = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.Id,strtDt,'TEST-12','TEST-12','abc','Active Initiative');
            test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new MockHttpNewJiraIssueResponse());           
            ODS_JIRAIntegration.getUserAccountId('sfadmin@demandblue.com');            
            ODS_JIRAIntegration.getProjectId('152');            
            ODS_JIRAIntegration.postCalloutToJira('sfadmin@demandblue.com','152',initiative.id,'10001');
            ODS_JIRAIntegration.callOutToJira(jiraTest,statReport.id);

            test.stopTest();
        }             
    }
    
    public class MockHttpNewJiraIssueResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('/rest/agile/latest/board/')){
                response.setBody('{"location":{"projectId":10112,"displayName":"Test (TEST)","projectName":"Test","projectKey":"TEST","projectTypeKey":"software"}}');
            }else if(request.getEndpoint().contains('/rest/api/2/user/search')){
                response.setBody('[{"self":"https://demandblue.atlassian.net/rest/api/2/user?accountId=5a987e6a0f36f12a6c56ad8f","accountId":"5a987e6a0f36f12a6c56ad8f","accountType":"atlassian","emailAddress":"sfmanagers@demandblue.com","avatarUrls":{"48x48":"https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/5a987e6a0f36f12a6c56ad8f/d7d8d84b-6bf6-4f9c-98e1-491e1a8da1ae/48","location":{"projectId":10112,"displayName":"Test (TEST)","projectName":"Test","projectKey":"TEST"}}}]');
            }else if(request.getEndpoint().contains('/rest/api/2/issue/')){
                response.setBody('{"id":"19909", "key":"TEST-13", "self":"https://demandblue.atlassian.net/rest/api/2/issue/19909"}');            
            }else if(request.getEndpoint().contains('/rest/api/3/issue/')){
                response.setBody('{"expand":"renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations","id":"20257","self":"https://demandblue.atlassian.net/rest/api/3/issue/20257","key":"TEST-28","fields":{"status":{"self":"https://demandblue.atlassian.net/rest/api/3/status/1"}}}');
            }
            response.setStatusCode(200);
            return response;
        }
    }
    
    public class TestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('id={fields={aggregateprogress={progress=0, total=0}, aggregatetimeestimate=null, aggregatetimeoriginalestimate=null, aggregatetimespent=null, assignee=null, attachment=(), closedSprints=({completeDate=2017-08-16T06:41:51.863Z, endDate=2017-08-24T09:04:00.000Z, goal=, id=1, name=Sprint 1, originBoardId=2, self=https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/1, startDate=2017-08-10T09:04:45.869Z, state=closed}), comment={comments=(), maxResults=0, startAt=0, total=0}, components=(), statuscategorychangedate=2017-08-10T09:04:45.869Z }}');
            response.setStatusCode(200);
            return response; 
        }
    }
    /// <OBJECTIVE>
    /// Test dashboard functionality such as cost saving, TAM and Chart with positive flow.
    /// </OBJECTIVE>  
    public static testMethod void JIRAMethods_Test()
    {
        Test.setMock(HttpCalloutMock.class, new TestMock());  
        ODS_JIRAIntegration.InvokeJiraApi('gnanaprakasam_g@preludesys.com', 'Prelude@123','https://preludesysindia.atlassian.net/');
        ODS_JIRAIntegration.GetAverageSprintGap('gnanaprakasam_g@preludesys.com', 'Prelude@123', '32', 'https://preludesysindia.atlassian.net/');
        ODS_JIRAIntegration.GetAverageSprintGap('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', Label.ODS_Demandblue_JIRA_URL);
        ODS_JIRAIntegration.GetCompletedUserstoriesTillDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'demandblue.atlassian.net', 'CLOSED');
        ODS_JIRAIntegration.GetCompletedUserstoriesTillDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'https://preludesysindia.atlassian.net/', 'CLOSED');
        ODS_JIRAIntegration.GetMonthlyInProgressUS('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'demandblue.atlassian.net', '8', '2018', 'IN PROGRESS');
        
        ODS_JIRAIntegration.GetTotalCompletedUSWithDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'https://preludesysindia.atlassian.net/', '8', '2018', 'CLOSED');
        ODS_JIRAIntegration.GetTotalCompletedUSWithDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'demandblue.atlassian.net', '8', '2018', 'CLOSED');
        ODS_JIRAIntegration.GetTotalCompletedUSWithDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', ' ', '8', '2018', 'IN PROGRESS, CLOSED');
        ODS_JIRAIntegration.GetTotalCompletedUSWithDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', ' ', '0', '2018', ' CLOSED');
        
        ODS_JIRAIntegration.GetMonthlyCompletedUserStories('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'https://preludesysindia.atlassian.net/', '8', '2018', 'CLOSED');
        ODS_JIRAIntegration.GetMonthlyCompletedUserStories('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'demandblue.atlassian.net', '8', '2018', 'CLOSED');
        ODS_JIRAIntegration.GetMonthlyCompletedUserStories('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', ' ', '0', '2018', 'IN PROGRESS, CLOSED');
        ODS_JIRAIntegration.GetMonthlyCompletedUserStories('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', ' ', '8', '2018', ' CLOSED');
        
        ODS_JIRAIntegration.GetMonthlyInProgressUS('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'demandblue.atlassian.net', '8', '2018', 'IN PROGRESS');
        ODS_JIRAIntegration.GetMonthlyInProgressUS('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', ' ', '8', '2018', 'IN PROGRESS, CLOSED');
        ODS_JIRAIntegration.GetMonthlyInProgressUS('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', ' ', '0', '2018', ' CLOSED');
        
        ODS_JIRAIntegration.GetCompletedUserstoriesTillDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', '', 'CLOSED');
        ODS_JIRAIntegration.GetCompletedUserstoriesTillDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'demandblue.atlassian.net', 'CLOSED');
        ODS_JIRAIntegration.GetCompletedUserstoriesTillDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', 'https://preludesysindia.atlassian.net/', 'CLOSED');
        ODS_JIRAIntegration.GetCompletedUserstoriesTillDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', ' ', 'CLOSED, IN PROGRESS');
        ODS_JIRAIntegration.GetCompletedUserstoriesTillDate('gnanaprakasam_g@preludesys.com', 'Prelude@123', '33', ' ', ' IN PROGRESS');
    }   
}