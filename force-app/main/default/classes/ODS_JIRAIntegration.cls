/**
 * @author           Kirankumar
 * @version          1.0 
 * @date             08/08/2017
 * @Status           Developed
 * @description      This is the controller class to fetch sprint details from JIRA
 *
 */
public class ODS_JIRAIntegration
{  
    /// <OBJECTIVE>
    /// Send http request and return response.
    /// </OBJECTIVE>  
    public static HTTPResponse InvokeJiraApi(string Usrname, String Passwrd,String EndPointUrl)
    {
        HTTPResponse response = new HTTPResponse();
        try 
        {
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(EndPointUrl); 
            
            //Updated by Indhu on 28-Feb-2020 in order to include Named Credential for Demandblue JIRA authentication     
            if(!EndPointUrl.contains('callout:Jira_API')){
                Blob headerValue = Blob.valueOf(Usrname+ ':' + Passwrd);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                request.setHeader('Authorization', authorizationHeader);
            }
            
            system.debug('###request:' +request);
            Http http = new Http();
            response = http.send(request);
            system.debug('@@@'+response.getBody());
            
            string statusResponse = response.getStatus();
            system.debug('@@@statusResponse'+statusResponse);           
            
        }
        catch(Exception ex)    
        {
            system.debug('json Exception: '+ex);            
        }
        return response;
    }
    
    //To get the Average Sprint
    public static Decimal GetAverageSprintGap (string Usrname,string Passwrd,String BoardId, String DomainName)
    {
        Decimal averageSprintGap=0;
        string responseJson='';
        HTTPResponse response = new HTTPResponse();
        try
        {
             
                String apiUrl = '';
                string jiraResponse = '';
                Map<String,Object> Result = new Map<String,Object>();
                List<sprint> sprintlist = new List<sprint>();
                //Url forming to fetch the list of sprints
                //apiUrl ='https://'+DomainName+'.atlassian.net/rest/agile/1.0/board/'+BoardId+'/sprint';
                
                //Updated by Indhu on 19-Feb-2020 in order to include named credential
                system.debug('@@@@@@@DomainNmae:'+ DomainName);
                system.debug('@@@@@@@Label:'+Label.ODS_Demandblue_JIRA_URL);
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl ='https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/sprint';
                    system.debug('@@@@ifloop');
                }
                else{
                    system.debug('@@@@elseloop');
                    apiUrl ='callout:Jira_API/rest/agile/1.0/board/'+BoardId+'/sprint';
                }
                
                // if it is a test class, then it will go to the else loop
                if(!Test.isRunningTest())
                {
                    response = InvokeJiraApi(Usrname,Passwrd,apiUrl);
                    responseJson = response.getBody();
                    system.debug('^^^responseJson'+responseJson);
                }
                
                else
                {
                    response.setStatusCode(200);
                    responseJson = '{"maxResults": 50,"startAt": 0,"isLast": true,"values": [{"id": 8,"self": "https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/8","state": "closed","name": "WEDC Sprint 1","startDate": "2017-07-01T10:05:25.211Z","endDate": "2017-07-15T10:05:00.000Z","completeDate": "2017-08-24T10:08:54.581Z","originBoardId": 3,"goal": ""}, {"id": 9,"self": "https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/9","state": "closed","name": "WEDC Sprint 2","startDate": "2017-07-23T10:09:00.000Z","endDate": "2017-07-31T10:09:00.000Z","completeDate": "2017-08-24T10:17:54.702Z","originBoardId": 3,"goal": ""}, {"id": 10,"self": "https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/10","state": "active","name": "WEDC Sprint 3","startDate": "2017-08-13T10:18:35.631Z","endDate": "2017-08-31T10:18:00.000Z","originBoardId": 3,"goal": ""}]}';
                }
            
                if(response.getStatusCode() != 200) //responseJson.contains('Unauthorized') || responseJson.contains('board cannot be viewed'))
                {
                    jiraResponse = 'error';
                    ODS_DashboardController.SetJiraResponse(jiraResponse);
                }
                else
                {
                     jiraResponse = 'success';
                     ODS_DashboardController.SetJiraResponse(jiraResponse);
                     
                
                Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(responseJson);
                List<Object> responseResultLst = (List<Object>)jsonResponse.get('values');
                //To get the sprint start date and end date for the sprints
                for(Object obj : responseResultLst)
                {
                    Result=(Map<String,Object>) obj;
                    sprint Sprints = new sprint();
                    string stDate = (string)Result.get('startDate');
                    string edDate = (string)Result.get('endDate');
                    if(stDate != null && edDate != null)
                    {
                        Sprints.sprintName = (string)Result.get('name');
                        Sprints.startDate = date.valueof(StDate);
                        Sprints.endDate = date.valueof(EdDate);
                        sprintlist.add(Sprints);  
                    }
                }
                system.debug('##sprintlist'+sprintlist);
                Integer totalNumberOfDays = 0;
                Integer totalSprints = 0;
                Integer totalNoOfDaysExcludingWeekends=0;
                //Calculate number of weekends and remove it from the total number of days
                if(sprintlist.size() > 1)
                {
                    for(integer i=0; i<sprintlist.size()-1; i++)
                    {
                         Date currentSprintEndDt = sprintlist[i].endDate;
                         Date NextSprintStartDt = sprintlist[i+1].startDate;
                         DateTime CurrentSprintEndDateTime = DateTime.newInstance(currentSprintEndDt.Year(),currentSprintEndDt.Month(),currentSprintEndDt.Day());
                         DateTime nextSprintStartDateTime = DateTime.newInstance(NextSprintStartDt.Year(),NextSprintStartDt.Month(),NextSprintStartDt.Day());
                         totalNumberOfDays = currentSprintendDt.daysBetween(NextSprintstartDt);
                         Integer NoofWeekEndsDays =  ODS_DateUtility.calculateWeekends(CurrentSprintEndDateTime, nextSprintStartDateTime );
                         Integer workingDays = (totalNumberOfDays - NoofWeekEndsDays );
                         totalNoOfDaysExcludingWeekends += workingDays;
                         totalSprints = totalSprints + 1;
                         if(totalNoOfDaysExcludingWeekends < 0)
                         {
                            totalNoOfDaysExcludingWeekends = 0;
                         }
                    }
                }
                else
                {
                    totalNoOfDaysExcludingWeekends = 0;
                    system.debug('totalNoOfDaysExcludingWeekends '+totalNoOfDaysExcludingWeekends);
                }
                system.debug(' ^^^totalNoOfDaysExcludingWeekends  '+totalNoOfDaysExcludingWeekends );
                system.debug(' ^^^totalSprints '+(totalSprints+1));
                //averageSprintGap = totalNoOfDaysExcludingWeekends / (totalSprints+1);
                averageSprintGap = decimal.valueof(totalNoOfDaysExcludingWeekends).divide((totalSprints+1), 1);
                
                }
                system.debug(' ^^^averageSprintGap '+averageSprintGap);  
            
            
            
        }
        catch(Exception ex)    
        {
            system.debug(ex);
        }
        return averageSprintGap;
    }
    
    //To get the Count of the Completed User Stories for life time
    public static Integer GetCompletedUserstoriesTillDate(String userName, String password, String BoardId,string domainName, string CompletedCriteria)
    {
        String apiUrl = '';
        string USCompletedResBody = '';
        Integer completedUserStories = 0;
        string jiraResponse = '';
        string statusValues = ''; 
        boolean isMultipleStats = false;
        HTTPResponse response = new HTTPResponse();
        
        try   
        {
            string projectKey = getProjectKey(BoardId);
            //Url forming to get the Completed user stories
            //Updated by Indhu on 19-Feb-2020 in order to include named credential
            if(DomainName == Label.ODS_Demandblue_JIRA_URL){
                if((Label.ODS_JIRA_Completed_Criteria).contains(';')){
                    statusValues = getEncodedMultiplesStatuses(Label.ODS_JIRA_Completed_Criteria, ';');
                    isMultipleStats = True;
                }
                else{
                    statusValues = getEncodedSingleStatus(Label.ODS_JIRA_Completed_Criteria);
                    isMultipleStats = False;
                }
            }
            else if(CompletedCriteria != null || CompletedCriteria != ''){
                if(CompletedCriteria.contains(',')){
                    statusValues = getEncodedMultiplesStatuses(CompletedCriteria, ',');
                    isMultipleStats = True;
                }
                else{
                    statusValues = getEncodedSingleStatus(CompletedCriteria);
                    isMultipleStats = False;
                }
            }
            
            //if(CompletedCriteria == null || CompletedCriteria == ''){
                //apiUrl = 'https://'+DomainName+'.atlassian.net/rest/agile/1.0/board/'+BoardId+'/issue?jql=%20sprint%20!=%20null%20and%20issueType=Story%20and%20status%20=%20Done%20and%20sprint%20in%20(OpenSprints()%20,%20ClosedSprints())';
              
            if(!isMultipleStats){    
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl = 'https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/issue?jql=%20sprint%20!=%20null%20and%20issueType=Story%20and%20status%20=%20' + statusValues + '%20and%20sprint%20in%20(OpenSprints()%20,%20ClosedSprints())';
                }
                else{
                    apiUrl = 'callout:Jira_API/rest/api/3/search?jql=project%20=%20'+projectKey+'%20and%20issuetype=story%20and%20status%20=%20'+statusValues;
                }
                
            }
            else{            
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl = 'https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/issue?jql=%20sprint%20!=%20null%20and%20issueType=Story%20and%20status%20IN%20(' + statusValues +')%20and%20sprint%20in%20(OpenSprints()%20,%20ClosedSprints())';
                }
                else{
                    apiUrl = 'callout:Jira_API/rest/api/3/search?jql=project%20=%20'+projectKey+'%20and%20issuetype%20=%20story%20and%20status%20IN%20('+statusValues +')';
                }
            }
            system.debug('###Life Time Completed User story apiUrl :' +apiUrl);
            
            // if it is a test class, then it will go to the else loop
            if(!Test.isRunningTest())
            {
                response = InvokeJiraApi(userName, password,apiUrl);
                USCompletedResBody = response.getBody();
                system.debug('$$$USCompletedResBody'+USCompletedResBody );
            }
            
            else
            {
                response.setStatusCode(200);
                USCompletedResBody  = '{"expand": "schema,names","startAt": 0,"maxResults": 50,"total": 4,"issues": [{"expand": "operations,versionedRepresentations,editmeta,changelog,renderedFields","id": "10000","fields": {"issuetype": {"self": "https://preludesysindia.atlassian.net/rest/api/2/issuetype/10001","id": "10001","description": "A user story. Created by JIRA Software - do not edit or delete.","iconUrl": "https://preludesysindia.atlassian.net/images/icons/issuetypes/story.svg","name": "Story","subtask": false},"sprint": null,"project": {"self": "https://preludesysindia.atlassian.net/rest/api/2/project/10001","id": "10001","key": "DN","name": "Dot Net",},"resolution": {"self": "https://preludesysindia.atlassian.net/rest/api/2/resolution/10000","id": "10000","description": "Work has been completed on this issue.","name": "Done"},"resolutiondate": "2017-08-10T12:47:36.375+0530","workratio": -1,"lastViewed": "2017-08-10T12:49:17.542+0530","created": "2017-08-09T15:28:49.873+0530","epic": null,"labels": [],"updated": "2017-08-10T12:47:36.390+0530","status": {"self": "https://preludesysindia.atlassian.net/rest/api/2/status/10001","description": "","iconUrl": "https://preludesysindia.atlassian.net/","name": "Done","id": "10001","statusCategory": {"self": "https://preludesysindia.atlassian.net/rest/api/2/statuscategory/3","id": 3,"key": "done","colorName": "green","name": "Done"}},"summary": "Design Document",}}]}';
            }   
                
            if(response.getStatusCode() != 200) //USCompletedResBody.contains('Unauthorized') || USCompletedResBody.contains('board cannot be viewed'))
            {
                jiraResponse = 'error';
                ODS_DashboardController.SetJiraResponse(jiraResponse);
                system.debug('$$$jiraResponse'+jiraResponse);
            }
            
            else
            {
                jiraResponse = 'success';
                ODS_DashboardController.SetJiraResponse(jiraResponse);
                Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(USCompletedResBody);
                object completedUserStoriesobj = jsonResponse.get('total');
                completedUserStories = integer.valueOf(completedUserStoriesobj);
                system.debug('%%%completedUserStories'+completedUserStories);
            }
        }
        catch(Exception ex)    
        {
            system.debug(ex);
        }
        return completedUserStories;
    
    }    
    
    public static Integer GetMonthlyCompletedUserStories(String userName, String password, String BoardId,string domainName,string Month,string year, string CompletedCriteria) 
    {
        string apiUrl = '';
        string USMonthlyCompletedResBody = '';
        Integer monthlyCompletedSprintCount = 0;
        Integer completedUserStories = 0;
        string jiraResponse='';
        string statusValues = '';
        boolean isMultipleStats = false;
        HTTPResponse response = new HTTPResponse();
        
        Map<Date,Integer> mapCompletedUserstoriesDate = new Map<Date,Integer>(); 
        try
        {
            string projectKey = getProjectKey(BoardId);
            //Updated by Indhu on 19-Feb-2020 in order to include named credential
            if(DomainName == Label.ODS_Demandblue_JIRA_URL){
                if((Label.ODS_JIRA_Completed_Criteria).contains(';')){
                    statusValues = getEncodedMultiplesStatuses(Label.ODS_JIRA_Completed_Criteria, ';');
                    isMultipleStats = True;
                }
                else{
                    statusValues = getEncodedSingleStatus(Label.ODS_JIRA_Completed_Criteria);
                    isMultipleStats = False;
                }
            }
            else if(CompletedCriteria != null || CompletedCriteria != ''){
                if(CompletedCriteria.contains(',')){
                    statusValues = getEncodedMultiplesStatuses(CompletedCriteria, ',');
                    isMultipleStats = True;
                }
                else{
                    statusValues = getEncodedSingleStatus(CompletedCriteria);
                    isMultipleStats = False;
                }
            }

            string monthYearJql = getMonthYearJql(Month, year);
            
            if(!isMultipleStats){
                //apiUrl = 'https://'+DomainName+'.atlassian.net/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(%20OpenSprints(),ClosedSprints())%20and%20status%20=%20done';
                //Updated by Indhu on 19-Feb-2020 in order to include named credential
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl = 'https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(%20OpenSprints(),ClosedSprints())%20and%20status%20=%20' + statusValues+monthYearJql;
                }
                else{
                    apiUrl = 'callout:Jira_API/rest/api/3/search?maxResults=200&jql=project%20=%20'+projectKey+'%20and%20issuetype=story%20and%20status%20=%20'+statusValues+monthYearJql;
                }
            }
            else{
                system.debug('##Contains Criteria');                
                //Updated by Indhu on 19-Feb-2020 in order to include named credential
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl = 'https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(%20OpenSprints(),ClosedSprints())%20and%20status%20IN%20('+statusValues +')'+monthYearJql;
                }
                else{
                    apiUrl = 'callout:Jira_API/rest/api/3/search?maxResults=200&jql=project%20=%20'+projectKey+'%20and%20issuetype=story%20and%20status%20IN%20('+statusValues +')'+monthYearJql;
                }
            }
            system.debug('###Completed User story apiUrl :' +apiUrl);
             if(!Test.isRunningTest())
             {
                response = InvokeJiraApi(userName, password,apiUrl);                
                USMonthlyCompletedResBody = response.getBody();
                system.debug('^^^USMonthlyCompletedResBody '+USMonthlyCompletedResBody);
             }             
             else
             {
                 response.setStatusCode(200);
                 USMonthlyCompletedResBody = '{"expand":"schema,names","startAt":0,"maxResults":50,"total":4,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"10000","self":"https://preludesysindia.atlassian.net/rest/agile/1.0/issue/10000","key":"DN-1","fields":{"issuetype":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issuetype/10001","id":"10001","description":"A user story. Created by JIRA Software - do not edit or delete.","iconUrl":"https://preludesysindia.atlassian.net/images/icons/issuetypes/story.svg","name":"Story","subtask":false},"timespent":null,"sprint":null,"project":{"self":"https://preludesysindia.atlassian.net/rest/api/2/project/10001","id":"10001","key":"DN","name":"Dot Net","avatarUrls":{"48x48":"https://preludesysindia.atlassian.net/secure/projectavatar?avatarId=10324","24x24":"https://preludesysindia.atlassian.net/secure/projectavatar?size=small&avatarId=10324","16x16":"https://preludesysindia.atlassian.net/secure/projectavatar?size=xsmall&avatarId=10324","32x32":"https://preludesysindia.atlassian.net/secure/projectavatar?size=medium&avatarId=10324"}},"fixVersions":[],"aggregatetimespent":null,"resolution":{"self":"https://preludesysindia.atlassian.net/rest/api/2/resolution/10000","id":"10000","description":"Work has been completed on this issue.","name":"Done"},"resolutiondate":"2017-08-10T12:47:36.375+0530","workratio":-1,"lastViewed":"2017-08-10T12:49:17.542+0530","watches":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-1/watchers","watchCount":1,"isWatching":true},"created":"2017-08-09T15:28:49.873+0530","epic":null,"priority":{"self":"https://preludesysindia.atlassian.net/rest/api/2/priority/3","iconUrl":"https://preludesysindia.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"labels":[],"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2017-08-10T12:47:36.390+0530","status":{"self":"https://preludesysindia.atlassian.net/rest/api/2/status/10001","description":"","iconUrl":"https://preludesysindia.atlassian.net/","name":"Done","id":"10001","statusCategory":{"self":"https://preludesysindia.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}},"components":[],"customfield_10050":null,"customfield_10051":null,"timeoriginalestimate":null,"customfield_10052":null,"description":null,"customfield_10053":null,"customfield_10054":null,"customfield_10010":["com.atlassian.greenhopper.service.sprint.Sprint@1ce79a[id=1,rapidViewId=2,state=CLOSED,name=Sprint 1,goal=,startDate=2017-08-10T09:04:45.869Z,endDate=2017-08-24T09:04:00.000Z,completeDate=2017-08-16T06:41:51.863Z,sequence=1]"],"customfield_10055":null,"customfield_10011":"0&#124;hzzzzz:","customfield_10012":null,"customfield_10013":"3_*:*_1_*:*_198397_*&#124;*_10000_*:*_1_*:*_76528122_*&#124;*_10001_*:*_1_*:*_0","timetracking":{},"customfield_10049":null,"customfield_10008":null,"attachment":[],"customfield_10009":null,"aggregatetimeestimate":null,"flagged":false,"summary":"Design Document","creator":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"subtasks":[],"reporter":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"customfield_10000":"{}","aggregateprogress":{"progress":0,"total":0},"customfield_10001":null,"customfield_10046":null,"customfield_10002":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"closedSprints":[{"id":1,"self":"https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/1","state":"closed","name":"Sprint 1","startDate":"2017-08-10T09:04:45.869Z","endDate":"2017-08-24T09:04:00.000Z","completeDate":"2017-08-16T06:41:51.863Z","originBoardId":2,"goal":""}],"progress":{"progress":0,"total":0},"comment":{"comments":[],"maxResults":0,"total":0,"startAt":0},"votes":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-1/votes","votes":0,"hasVoted":false},"worklog":{"startAt":0,"maxResults":20,"total":0,"worklogs":[]}}},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"10001","self":"https://preludesysindia.atlassian.net/rest/agile/1.0/issue/10001","key":"DN-2","fields":{"issuetype":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issuetype/10001","id":"10001","description":"A user story. Created by JIRA Software - do not edit or delete.","iconUrl":"https://preludesysindia.atlassian.net/images/icons/issuetypes/story.svg","name":"Story","subtask":false},"timespent":null,"sprint":null,"project":{"self":"https://preludesysindia.atlassian.net/rest/api/2/project/10001","id":"10001","key":"DN","name":"Dot Net","avatarUrls":{"48x48":"https://preludesysindia.atlassian.net/secure/projectavatar?avatarId=10324","24x24":"https://preludesysindia.atlassian.net/secure/projectavatar?size=small&avatarId=10324","16x16":"https://preludesysindia.atlassian.net/secure/projectavatar?size=xsmall&avatarId=10324","32x32":"https://preludesysindia.atlassian.net/secure/projectavatar?size=medium&avatarId=10324"}},"fixVersions":[],"aggregatetimespent":null,"resolution":{"self":"https://preludesysindia.atlassian.net/rest/api/2/resolution/10000","id":"10000","description":"Work has been completed on this issue.","name":"Done"},"resolutiondate":"2017-08-16T11:58:21.559+0530","workratio":-1,"lastViewed":"2017-08-16T11:58:21.529+0530","watches":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-2/watchers","watchCount":1,"isWatching":true},"created":"2017-08-09T15:29:17.008+0530","epic":null,"priority":{"self":"https://preludesysindia.atlassian.net/rest/api/2/priority/3","iconUrl":"https://preludesysindia.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"labels":[],"aggregatetimeoriginalestimate":null,"timeestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2017-08-16T11:58:21.566+0530","status":{"self":"https://preludesysindia.atlassian.net/rest/api/2/status/10001","description":"","iconUrl":"https://preludesysindia.atlassian.net/","name":"Done","id":"10001","statusCategory":{"self":"https://preludesysindia.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}},"components":[],"customfield_10050":null,"customfield_10051":null,"timeoriginalestimate":null,"customfield_10052":null,"description":null,"customfield_10053":null,"customfield_10054":null,"customfield_10010":["com.atlassian.greenhopper.service.sprint.Sprint@1ce79a[id=1,rapidViewId=2,state=CLOSED,name=Sprint 1,goal=,startDate=2017-08-10T09:04:45.869Z,endDate=2017-08-24T09:04:00.000Z,completeDate=2017-08-16T06:41:51.863Z,sequence=1]"],"customfield_10055":null,"customfield_10011":"0&#124;i00007:","customfield_10012":null,"customfield_10013":"3_*:*_1_*:*_515168169_*&#124;*_10000_*:*_1_*:*_76976396_*&#124;*_10001_*:*_1_*:*_0","timetracking":{},"customfield_10049":null,"customfield_10008":null,"aggregatetimeestimate":null,"customfield_10009":null,"attachment":[],"flagged":false,"summary":"Understanding Document","creator":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"subtasks":[],"reporter":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"aggregateprogress":{"progress":0,"total":0},"customfield_10000":"{}","customfield_10001":null,"customfield_10046":null,"customfield_10002":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"closedSprints":[{"id":1,"self":"https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/1","state":"closed","name":"Sprint 1","startDate":"2017-08-10T09:04:45.869Z","endDate":"2017-08-24T09:04:00.000Z","completeDate":"2017-08-16T06:41:51.863Z","originBoardId":2,"goal":""}],"progress":{"progress":0,"total":0},"comment":{"comments":[],"maxResults":0,"total":0,"startAt":0},"votes":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-2/votes","votes":0,"hasVoted":false},"worklog":{"startAt":0,"maxResults":20,"total":0,"worklogs":[]}}}]}';
             }
            
            if(response.getStatusCode() != 200) //USMonthlyCompletedResBody.contains('Unauthorized') ||  USMonthlyCompletedResBody.contains('board cannot be viewed'))
            {
                jiraResponse = 'error';
                ODS_DashboardController.SetJiraResponse(jiraResponse);
                system.debug('$$$jiraResponse'+jiraResponse);
            }            
            else
            {
                jiraResponse = 'success';
                ODS_DashboardController.SetJiraResponse(jiraResponse);
                system.debug(USMonthlyCompletedResBody);
                Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(USMonthlyCompletedResBody);
                List<Object> responseResultLst = (List<Object>)jsonResponse.get('issues');
                object completedUserStoriesobj = jsonResponse.get('total');
                completedUserStories = integer.valueOf(completedUserStoriesobj);
                monthlyCompletedSprintCount = completedUserStories;
            }
        } 
        catch(Exception ex)    
        {
            system.debug(ex);
        }        
        return monthlyCompletedSprintCount;
    }
    
    public static Integer GetMonthlyInProgressUS(String userName, String password, String BoardId,string domainName,string Month,string year, string InProgressCriteria)
    {
        string apiUrl = '';
        string USMonthlyInProgressResBody = '';
        Integer monthlyInProgressSprintCount = 0;
        string jiraResponse = '';
        string statusValues = ''; 
        boolean isMultipleStats = False;
        HTTPResponse response = new HTTPResponse();
        Integer inProgressUserStories = 0;
        Boolean useTotalAttribute = false;
        try
        {
            string projectKey = getProjectKey(BoardId);
            //Updated by Indhu on 19-Feb-2020 in order to include named credential
            if(DomainName == Label.ODS_Demandblue_JIRA_URL){
                if((Label.ODS_JIRA_Inprogress_Criteria).contains(';')){
                    statusValues = getEncodedMultiplesStatuses(Label.ODS_JIRA_Inprogress_Criteria, ';');
                    isMultipleStats = True;
                }
                else{
                    statusValues = getEncodedSingleStatus(Label.ODS_JIRA_Inprogress_Criteria);
                    isMultipleStats = False;
                }
            }
            else if(InProgressCriteria != null || InProgressCriteria != ''){
                if(InProgressCriteria.contains(',')){
                    statusValues = getEncodedMultiplesStatuses(InProgressCriteria, ',');
                    isMultipleStats = True;
                }
                else{
                    statusValues = getEncodedSingleStatus(InProgressCriteria);
                    isMultipleStats = False;
                }
            }

            string monthYearJql = getMonthYearJql(Month, year);
            
            if(!isMultipleStats){
            //apiUrl = 'https://'+DomainName+'.atlassian.net/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(OpenSprints())%20and%20status%20=%20%27In%20Progress%27';
            //if(InProgressCriteria == null || InProgressCriteria == ''){                
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl = 'https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(OpenSprints())%20and%20status%20=%20%27' + statusValues + '%27'+monthYearJql;
                }
                else{
                    apiUrl = 'callout:Jira_API/rest/api/3/search?maxResults=200&jql=project%20=%20'+projectKey+'%20and%20issuetype=story%20and%20status%20=%20'+statusValues+monthYearJql;
                }
            }
            else{                
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl = 'https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(OpenSprints())%20and%20status%20IN%20('+statusValues +')'+monthYearJql;
                }
                else{
                    apiUrl = 'callout:Jira_API/rest/api/3/search?maxResults=200&jql=project%20=%20'+projectKey+'%20and%20issuetype=story%20and%20status%20IN%20('+statusValues +')'+monthYearJql;
                }
            }
            system.debug('###In progress API URL:' +apiUrl);
            if(!Test.isRunningTest())
            {
                response = InvokeJiraApi(userName, password,apiUrl);                             
                USMonthlyInProgressResBody = response.getBody();
                system.debug('^^^USMonthlyInProgressResBody '+USMonthlyInProgressResBody);
            }            
            else
            {
                response.setStatusCode(200);
                USMonthlyInProgressResBody  = '{"expand":"schema,names","startAt":0,"maxResults":50,"total":2,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"10005","self":"https://preludesysindia.atlassian.net/rest/agile/1.0/issue/10005","key":"DN-6","fields":{"issuetype":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issuetype/10001","id":"10001","description":"A user story. Created by JIRA Software - do not edit or delete.","iconUrl":"https://preludesysindia.atlassian.net/images/icons/issuetypes/story.svg","name":"Story","subtask":false},"timespent":null,"sprint":{"id":3,"self":"https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/3","state":"active","name":"Sprint 3","startDate":"2017-09-11T06:47:00.000Z","endDate":"2017-09-29T06:47:00.000Z","originBoardId":2,"goal":""},"project":{"self":"https://preludesysindia.atlassian.net/rest/api/2/project/10001","id":"10001","key":"DN","name":"Dot Net","avatarUrls":{"48x48":"https://preludesysindia.atlassian.net/secure/projectavatar?avatarId=10324","24x24":"https://preludesysindia.atlassian.net/secure/projectavatar?size=small&avatarId=10324","16x16":"https://preludesysindia.atlassian.net/secure/projectavatar?size=xsmall&avatarId=10324","32x32":"https://preludesysindia.atlassian.net/secure/projectavatar?size=medium&avatarId=10324"}},"fixVersions":[],"aggregatetimespent":null,"resolution":null,"resolutiondate":null,"workratio":-1,"lastViewed":"2017-08-22T12:29:31.519+0530","watches":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-6/watchers","watchCount":1,"isWatching":true},"created":"2017-08-09T15:30:40.791+0530","epic":null,"priority":{"self":"https://preludesysindia.atlassian.net/rest/api/2/priority/3","iconUrl":"https://preludesysindia.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"labels":[],"timeestimate":null,"aggregatetimeoriginalestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2017-08-22T17:53:03.329+0530","status":{"self":"https://preludesysindia.atlassian.net/rest/api/2/status/3","description":"This issue is being actively worked on at the moment by the assignee.","iconUrl":"https://preludesysindia.atlassian.net/images/icons/statuses/inprogress.png","name":"In Progress","id":"3","statusCategory":{"self":"https://preludesysindia.atlassian.net/rest/api/2/statuscategory/4","id":4,"key":"indeterminate","colorName":"yellow","name":"In Progress"}},"components":[],"customfield_10050":null,"customfield_10051":null,"timeoriginalestimate":null,"customfield_10052":null,"description":null,"customfield_10053":null,"customfield_10054":null,"customfield_10010":["com.atlassian.greenhopper.service.sprint.Sprint@4ff49014[id=3,rapidViewId=2,state=ACTIVE,name=Sprint 3,goal=,startDate=2017-09-11T06:47:00.000Z,endDate=2017-09-29T06:47:00.000Z,completeDate=<null>,sequence=3]"],"customfield_10011":"0&#124;i00013:","customfield_10055":null,"customfield_10012":null,"customfield_10013":null,"timetracking":{},"customfield_10049":null,"customfield_10008":null,"attachment":[],"customfield_10009":null,"aggregatetimeestimate":null,"flagged":false,"summary":"Deployment Document","creator":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"subtasks":[],"reporter":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"customfield_10000":"{}","aggregateprogress":{"progress":0,"total":0},"customfield_10001":null,"customfield_10046":null,"customfield_10002":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"progress":{"progress":0,"total":0},"votes":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-6/votes","votes":0,"hasVoted":false},"comment":{"comments":[],"maxResults":0,"total":0,"startAt":0},"worklog":{"startAt":0,"maxResults":20,"total":0,"worklogs":[]}}}]}';
            }
            
            if(response.getStatusCode() != 200) //USMonthlyInProgressResBody.contains('Unauthorized') || USMonthlyInProgressResBody.contains('board cannot be viewed'))
            {
                jiraResponse = 'error';
                ODS_DashboardController.SetJiraResponse(jiraResponse);
                system.debug('$$$jiraResponse'+jiraResponse);
            }            
            else
            {
                jiraResponse = 'success';
                ODS_DashboardController.SetJiraResponse(jiraResponse);
                Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(USMonthlyInProgressResBody);
                object inProgressUserStoriesobj = jsonResponse.get('total');
                inProgressUserStories = integer.valueOf(inProgressUserStoriesobj);
                monthlyInProgressSprintCount = inProgressUserStories;

                system.debug('###monthlyInProgressSprintCount'+monthlyInProgressSprintCount);
            }
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
        return monthlyInProgressSprintCount;
    }
    
    public static Map<string,Integer> GetTotalCompletedUSWithDate(String userName, String password, String BoardId,string domainName,string Month,string year, string CompletedCriteria) 
    {
        string apiUrl = '';
        string USMonthlyCompletedResBody = '';
        Integer monthlyCompletedSprintCount = 0;
        Map<string,Integer> mapCompletedUserstoriesDte = new Map<string,Integer>(); 
        string jiraResponse = '';
        string statusValues = ''; 
        boolean isMultipleStats = False;
        HTTPResponse response = new HTTPResponse();
        Integer completedUserStories = 0;
        Boolean useTotalAttribute = false;
        Map<string,Date> sptintIdWithResolutionDate = new Map<string,Date>();

        try
        {
            string projectKey = getProjectKey(BoardId);
            if(DomainName == Label.ODS_Demandblue_JIRA_URL){
                if((Label.ODS_JIRA_Completed_Criteria).contains(';')){
                    statusValues = getEncodedMultiplesStatuses(Label.ODS_JIRA_Completed_Criteria, ';');
                    isMultipleStats = True;
                }
                else{
                    statusValues = getEncodedSingleStatus(Label.ODS_JIRA_Completed_Criteria);
                    isMultipleStats = False;
                }
            }
            else if(CompletedCriteria != null || CompletedCriteria != ''){
                if(CompletedCriteria.contains(',')){
                    statusValues = getEncodedMultiplesStatuses(CompletedCriteria, ',');
                    isMultipleStats = True;
                }
                else{
                    statusValues = getEncodedSingleStatus(CompletedCriteria);
                    isMultipleStats = False;
                }
            }

            string monthYearJql = getMonthYearJql(Month, year);
            
            if(!isMultipleStats){
                //apiUrl = 'https://'+DomainName+'.atlassian.net/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(%20OpenSprints(),ClosedSprints())%20and%20status%20=%20done';
                //Updated by Indhu on 19-Feb-2020 in order to include named credential
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl = 'https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(%20OpenSprints(),ClosedSprints())%20and%20status%20=%20' + statusValues;
                }
                else{
                    apiUrl = 'callout:Jira_API/rest/api/3/search?maxResults=100&jql=project%20=%20'+projectKey+'%20and%20issuetype=story%20and%20status%20=%20'+statusValues;
                    useTotalAttribute = true;
                }
            }
            else{                
                //Updated by Indhu on 19-Feb-2020 in order to include named credential
                if(DomainName != Label.ODS_Demandblue_JIRA_URL){
                    apiUrl = 'https://'+DomainName+'/rest/agile/1.0/board/'+BoardId+'/issue?jql=issuetype%20=%20story%20and%20sprint%20in%20(%20OpenSprints(),ClosedSprints())%20and%20status%20IN%20('+statusValues +')';
                }
                else{
                    apiUrl = 'callout:Jira_API/rest/api/3/search?maxResults=100&jql=project%20=%20'+projectKey+'%20and%20issuetype=story%20and%20status%20IN%20('+statusValues +')';
                    useTotalAttribute = true;
                }
            }
            system.debug('###TotalCompleted User story apiUrl :' +apiUrl);           
            
            
            if(!Test.isRunningTest())
            {
                response = InvokeJiraApi(userName, password,apiUrl);                                           
                USMonthlyCompletedResBody = response.getBody();
                system.debug('^^^USMonthlyCompletedResBody '+USMonthlyCompletedResBody );
            }
            
            else
            {
                response.setStatusCode(200);
                USMonthlyCompletedResBody  = '{"expand":"schema,names","startAt":0,"maxResults":100,"total":150,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"10000","self":"https://preludesysindia.atlassian.net/rest/agile/1.0/issue/10000","key":"DN-1","fields":{"issuetype":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issuetype/10001","id":"10001","description":"A user story. Created by JIRA Software - do not edit or delete.","iconUrl":"https://preludesysindia.atlassian.net/images/icons/issuetypes/story.svg","name":"Story","subtask":false},"timespent":null,"statuscategorychangedate":"2017-08-10T12:47:36.375+0530","sprint":null,"project":{"self":"https://preludesysindia.atlassian.net/rest/api/2/project/10001","id":"10001","key":"DN","name":"Dot Net","avatarUrls":{"48x48":"https://preludesysindia.atlassian.net/secure/projectavatar?avatarId=10324","24x24":"https://preludesysindia.atlassian.net/secure/projectavatar?size=small&avatarId=10324","16x16":"https://preludesysindia.atlassian.net/secure/projectavatar?size=xsmall&avatarId=10324","32x32":"https://preludesysindia.atlassian.net/secure/projectavatar?size=medium&avatarId=10324"}},"fixVersions":[],"aggregatetimespent":null,"resolution":{"self":"https://preludesysindia.atlassian.net/rest/api/2/resolution/10000","id":"10000","description":"Work has been completed on this issue.","name":"Done"},"resolutiondate":"2017-08-10T12:47:36.375+0530","workratio":-1,"watches":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-1/watchers","watchCount":1,"isWatching":true},"lastViewed":"2017-08-10T12:49:17.542+0530","created":"2017-08-09T15:28:49.873+0530","epic":null,"priority":{"self":"https://preludesysindia.atlassian.net/rest/api/2/priority/3","iconUrl":"https://preludesysindia.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"labels":[],"timeestimate":null,"aggregatetimeoriginalestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2017-08-10T12:47:36.390+0530","status":{"self":"https://preludesysindia.atlassian.net/rest/api/2/status/10001","description":"","iconUrl":"https://preludesysindia.atlassian.net/","name":"Done","id":"10001","statusCategory":{"self":"https://preludesysindia.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}},"components":[],"customfield_10050":null,"customfield_10051":null,"timeoriginalestimate":null,"customfield_10052":null,"description":null,"customfield_10053":null,"customfield_10054":null,"customfield_10010":["com.atlassian.greenhopper.service.sprint.Sprint@2fed2de5[id=1,rapidViewId=2,state=CLOSED,name=Sprint 1,goal=,startDate=2017-08-10T09:04:45.869Z,endDate=2017-08-24T09:04:00.000Z,completeDate=2017-08-16T06:41:51.863Z,sequence=1]"],"customfield_10055":null,"customfield_10011":"0&#124;hzzzzz:","customfield_10012":null,"customfield_10013":"3_*:*_1_*:*_198397_*&#124;*_10000_*:*_1_*:*_76528122_*&#124;*_10001_*:*_1_*:*_0","timetracking":{},"customfield_10049":null,"customfield_10008":null,"aggregatetimeestimate":null,"customfield_10009":null,"attachment":[],"flagged":false,"summary":"Design Document","creator":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"subtasks":[],"reporter":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"aggregateprogress":{"progress":0,"total":0},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10046":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"closedSprints":[{"id":1,"self":"https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/1","state":"closed","name":"Sprint 1","startDate":"2017-08-10T09:04:45.869Z","endDate":"2017-08-24T09:04:00.000Z","completeDate":"2017-08-16T06:41:51.863Z","originBoardId":2,"goal":""}],"progress":{"progress":0,"total":0},"votes":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-1/votes","votes":0,"hasVoted":false},"comment":{"comments":[],"maxResults":0,"total":0,"startAt":0},"worklog":{"startAt":0,"maxResults":20,"total":0,"worklogs":[]}}}]}';
            }
             
            if(response.getStatusCode() != 200) //USMonthlyCompletedResBody.contains('Unauthorized') || USMonthlyCompletedResBody.contains('board cannot be viewed'))
            {
                jiraResponse = 'error';
                ODS_DashboardController.SetJiraResponse(jiraResponse);
                system.debug('$$$jiraResponse'+jiraResponse);
            }
            
            else
            {
                jiraResponse = 'success';
                ODS_DashboardController.SetJiraResponse(jiraResponse);
                Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(USMonthlyCompletedResBody);
                List<Object> responseResultLst = (List<Object>)jsonResponse.get('issues');
                object completedUserStoriesobj = jsonResponse.get('total');
                completedUserStories = integer.valueOf(completedUserStoriesobj);            
                Map<String,Object> Result = new Map<String,Object>();
                Map<String,Object> FieldsResult = new Map<String,Object>();
                string timestring = 'T00:00:00.000Z';
                for(Object responseResult: responseResultLst)
                {
                    Result=(Map<String,Object>) responseResult;
                    string SprintId = string.valueof(Result.get('id'));
                    FieldsResult = (Map<String,Object>)Result.get('fields');
                    string ReslDate = string.valueOf(FieldsResult.get('statuscategorychangedate'));
                    List<string> FormattedDate = ReslDate.split('T');
                    sptintIdWithResolutionDate.put(SprintId,getFormattedDate(FormattedDate[0].split('-')));
                }

                if(useTotalAttribute && completedUserStories > 100){
                    Integer startAt = 100;
                    while (startAt < completedUserStories){
                        apiUrl = 'callout:Jira_API/rest/api/3/search?startAt='+startAt+'&maxResults=100&jql=project%20=%20'+projectKey+'%20and%20issuetype=story%20and%20';
                        if(!isMultipleStats){
                            apiUrl += 'status%20=%20'+statusValues;
                        }else{                
                            apiUrl += 'status%20IN%20('+statusValues +')';
                        }
                        //apiUrl += monthYearJql;

                        if(!Test.isRunningTest())
                        {
                            response = InvokeJiraApi(userName, password,apiUrl);                                           
                            USMonthlyCompletedResBody = response.getBody();
                            system.debug('^^^USMonthlyCompletedResBody '+USMonthlyCompletedResBody );
                        }else{
                            response.setStatusCode(200);
                            USMonthlyCompletedResBody  = '{"expand":"schema,names","startAt":0,"maxResults":50,"total":4,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"10000","self":"https://preludesysindia.atlassian.net/rest/agile/1.0/issue/10000","key":"DN-1","fields":{"issuetype":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issuetype/10001","id":"10001","description":"A user story. Created by JIRA Software - do not edit or delete.","iconUrl":"https://preludesysindia.atlassian.net/images/icons/issuetypes/story.svg","name":"Story","subtask":false},"timespent":null,"statuscategorychangedate":"2017-08-10T12:47:36.375+0530","sprint":null,"project":{"self":"https://preludesysindia.atlassian.net/rest/api/2/project/10001","id":"10001","key":"DN","name":"Dot Net","avatarUrls":{"48x48":"https://preludesysindia.atlassian.net/secure/projectavatar?avatarId=10324","24x24":"https://preludesysindia.atlassian.net/secure/projectavatar?size=small&avatarId=10324","16x16":"https://preludesysindia.atlassian.net/secure/projectavatar?size=xsmall&avatarId=10324","32x32":"https://preludesysindia.atlassian.net/secure/projectavatar?size=medium&avatarId=10324"}},"fixVersions":[],"aggregatetimespent":null,"resolution":{"self":"https://preludesysindia.atlassian.net/rest/api/2/resolution/10000","id":"10000","description":"Work has been completed on this issue.","name":"Done"},"resolutiondate":"2017-08-10T12:47:36.375+0530","workratio":-1,"watches":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-1/watchers","watchCount":1,"isWatching":true},"lastViewed":"2017-08-10T12:49:17.542+0530","created":"2017-08-09T15:28:49.873+0530","epic":null,"priority":{"self":"https://preludesysindia.atlassian.net/rest/api/2/priority/3","iconUrl":"https://preludesysindia.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"labels":[],"timeestimate":null,"aggregatetimeoriginalestimate":null,"versions":[],"issuelinks":[],"assignee":null,"updated":"2017-08-10T12:47:36.390+0530","status":{"self":"https://preludesysindia.atlassian.net/rest/api/2/status/10001","description":"","iconUrl":"https://preludesysindia.atlassian.net/","name":"Done","id":"10001","statusCategory":{"self":"https://preludesysindia.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}},"components":[],"customfield_10050":null,"customfield_10051":null,"timeoriginalestimate":null,"customfield_10052":null,"description":null,"customfield_10053":null,"customfield_10054":null,"customfield_10010":["com.atlassian.greenhopper.service.sprint.Sprint@2fed2de5[id=1,rapidViewId=2,state=CLOSED,name=Sprint 1,goal=,startDate=2017-08-10T09:04:45.869Z,endDate=2017-08-24T09:04:00.000Z,completeDate=2017-08-16T06:41:51.863Z,sequence=1]"],"customfield_10055":null,"customfield_10011":"0&#124;hzzzzz:","customfield_10012":null,"customfield_10013":"3_*:*_1_*:*_198397_*&#124;*_10000_*:*_1_*:*_76528122_*&#124;*_10001_*:*_1_*:*_0","timetracking":{},"customfield_10049":null,"customfield_10008":null,"aggregatetimeestimate":null,"customfield_10009":null,"attachment":[],"flagged":false,"summary":"Design Document","creator":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"subtasks":[],"reporter":{"self":"https://preludesysindia.atlassian.net/rest/api/2/user?username=admin","name":"admin","key":"admin","accountId":"557058:1c7f9ba7-1bc9-4322-842f-0224c2688cce","emailAddress":"gnanaprakasam_g@preludesys.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/c5b3d85ce720897ecc873dfa6b436daf?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fc5b3d85ce720897ecc873dfa6b436daf%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"},"displayName":"Preludesys India","active":true,"timeZone":"Asia/Kolkata"},"aggregateprogress":{"progress":0,"total":0},"customfield_10000":"{}","customfield_10001":null,"customfield_10002":null,"customfield_10046":null,"customfield_10003":null,"customfield_10004":null,"environment":null,"duedate":null,"closedSprints":[{"id":1,"self":"https://preludesysindia.atlassian.net/rest/agile/1.0/sprint/1","state":"closed","name":"Sprint 1","startDate":"2017-08-10T09:04:45.869Z","endDate":"2017-08-24T09:04:00.000Z","completeDate":"2017-08-16T06:41:51.863Z","originBoardId":2,"goal":""}],"progress":{"progress":0,"total":0},"votes":{"self":"https://preludesysindia.atlassian.net/rest/api/2/issue/DN-1/votes","votes":0,"hasVoted":false},"comment":{"comments":[],"maxResults":0,"total":0,"startAt":0},"worklog":{"startAt":0,"maxResults":20,"total":0,"worklogs":[]}}}]}';
                        }

                        if(response.getStatusCode() != 200) //USMonthlyCompletedResBody.contains('Unauthorized') || USMonthlyCompletedResBody.contains('board cannot be viewed'))
                        {
                            jiraResponse = 'error';
                            ODS_DashboardController.SetJiraResponse(jiraResponse);
                            system.debug('$$$jiraResponse'+jiraResponse);
                            return mapCompletedUserstoriesDte;
                        }                        
                        else
                        {
                            jiraResponse = 'success';
                            ODS_DashboardController.SetJiraResponse(jiraResponse);
                            jsonResponse = (Map<string,object>)JSON.deserializeUntyped(USMonthlyCompletedResBody);
                            responseResultLst = (List<Object>)jsonResponse.get('issues');
                            Result = new Map<String,Object>();
                            FieldsResult = new Map<String,Object>();
                            timestring = 'T00:00:00.000Z';
                            for(Object responseResult: responseResultLst)
                            {
                                Result=(Map<String,Object>) responseResult;
                                string SprintId = string.valueof(Result.get('id'));
                                FieldsResult = (Map<String,Object>)Result.get('fields');
                                string ReslDate = string.valueOf(FieldsResult.get('statuscategorychangedate'));
                                List<string> FormattedDate = ReslDate.split('T');
                                sptintIdWithResolutionDate.put(SprintId,getFormattedDate(FormattedDate[0].split('-')));
                            }                        
                        }
                        startAt += 100;
                    }
                }

                system.debug('$$$sptintIdWithResolutionDate'+sptintIdWithResolutionDate);
                Date startDate;
                Date lastDayOfMonth;
                if(Month == '0')
                {
                    startDate = Date.newInstance(integer.valueOf(year), 1, 1);
                    lastDayOfMonth = Date.newInstance(startDate.year(), 12, 31);
                }
                else
                {
                    startDate = Date.newInstance(integer.valueOf(year), integer.valueOf(Month), 1);
                    Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
                    lastDayOfMonth = Date.newInstance(startDate.year(), startDate.month(), numberOfDays);
                }
            
                string formattedMonthfirstDate = String.valueOf(startDate.toStartOfMonth())+timestring ;
                string formattedMonthLastDate = String.valueOf(lastDayOfMonth )+timestring;            
            
                Integer count = 0;
                for(Date ResolutionDt : sptintIdWithResolutionDate.values())
                {
                    string dateValue = string.valueOf(ResolutionDt);
                    system.debug('###dateValue'+dateValue);
                    List<String> CompletedDateSplitted = dateValue.split('-');
                    system.debug('###CompletedDateSplitted '+CompletedDateSplitted );
                    string creationYearMonthKey = CompletedDateSplitted[0]+CompletedDateSplitted[1]+CompletedDateSplitted[2];
                    system.debug('%%%creationYearMonthKey '+creationYearMonthKey );
                    if(mapCompletedUserstoriesDte.containskey(creationYearMonthKey ))
                    {
                        count = mapCompletedUserstoriesDte.get(creationYearMonthKey)+1;
                    }
                    else
                    {
                        count = 0;
                        count = count + 1;                        
                    }
                    mapCompletedUserstoriesDte.put(creationYearMonthKey,count);
                }
            }
            system.debug('###$monthlyCompletedSprint'+monthlyCompletedSprintCount);
            system.debug('###$mapCompletedUserstoriesDte'+mapCompletedUserstoriesDte);
        } 
        catch(Exception ex)    
        {
            system.debug(ex);
        }        
        return mapCompletedUserstoriesDte;
    }
    
    //Wrapper Class
    Public class sprint
    {
        public string sprintName{get;set;}
        public date startDate{get;set;}
        public date endDate{get;set;}
    }
    
    @Future(callout=True)               
    public static void postCalloutToJira(String techAccMgrEmail,String boardId, Id currInitId, String issueTypeId){
        string jiraId;
        try{     
        Http http = new Http();
        string responseJson='';
        HttpRequest request = new HttpRequest();  
        request.setMethod('POST');
        request.setEndpoint('callout:Jira_API/rest/api/2/issue/'); 
        request.setHeader('Content-Type','application/json');
        request.setHeader('accept','application/json');
                    
        Initiatives__c init = [SELECT Id, Name, Estimated_hours__c, Brief_Description__c FROM Initiatives__c WHERE Id =: currInitId];
        String reportId = getUserAccountId(techAccMgrEmail);
        Integer projectId = getProjectId(boardId);
        String CreateIssueJsonJira = '{"fields":{"project":{"id":"' + projectId + '"},"reporter":{"id":"' + reportId + '"},"summary": "' + init.Name + '","timetracking":{"remainingEstimate":"' + init.Estimated_hours__c + '","originalEstimate":"' + init.Estimated_hours__c  + '"},"issuetype":{"id":"' + issueTypeId  + '"}}}';           
        request.setBody(CreateIssueJsonJira);
            
        HTTPResponse res = http.send(request);      
        system.debug(res);
        responseJson = res.getBody();
        Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(responseJson);
        system.debug('Mapped Response:' + jsonResponse);
        jiraId = (string)jsonResponse.get('key');
        system.debug('JIRA Id' + jiraId);
            if(String.isNotEmpty(jiraId)){
                
                Initiatives__c ins = new Initiatives__c();
                ins.Id = currInitId;
                ins.JIRA_ID__c  =  jiraId;                 
                update ins;                      
           // Jiraupdate(jiraId,currInitId);
            }                
        }
        catch(Exception e)    
        {
            system.debug('Error --> '+e.getLineNumber());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
                             
    }
    
    public static string getUserAccountId(String techAccMgrEmail){
        String accId = '';
        try{
         Http http = new Http();
         String responseJson = '';
         HttpRequest request = new HttpRequest();
         request.setMethod('GET');
         
         request.setEndpoint('callout:Jira_API/rest/api/2/user/search?query=' + techAccMgrEmail + '');
         request.setHeader('Content-Type','application/json'); 
         HttpResponse res = http.send(request);
         System.debug('JSON Response get: ' + res.getBody());
         responseJson = res.getBody();
                  system.debug('List Response:' +JSON.deserializeUntyped(responseJson));
               
         List<object> jsonResponse = (List<object>)JSON.deserializeUntyped(responseJson);
         system.debug('List Response:' + jsonResponse);
                 
         for(object responseItem : jsonResponse){
            Map<String, Object> userInfo = (Map<String, Object>) responseItem; 
            system.debug(userInfo);
            accId = (String)userInfo.get('accountId');
            System.debug(accId);
         }
        }
        catch(Exception e)    
        {
            system.debug(e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
            return accId;
    }
    
    public static Integer getProjectId(String boardId){  
        Integer projectId;
        try{        
         Http http = new Http();
         String responseJson = '';
         HttpRequest request = new HttpRequest();
         request.setMethod('GET');        
         request.setEndpoint('callout:Jira_API/rest/agile/latest/board/'+boardId+'/');
                     request.setHeader('Content-Type','application/json'); 

         HttpResponse res = http.send(request);
         System.debug('Board Ids Response: ' + res.getBody());
         responseJson = res.getBody();
         Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(responseJson);
         System.debug('Project id:' + jsonResponse );
         
         Map<String,Object> locationMap = (Map<String,Object>)jsonResponse.get('location');
         system.debug('Location : ' + locationMap);
         projectId = (Integer)locationMap.get('projectId');
         System.debug('Project Id : ' + projectId);
        }
        
        catch(Exception e)    
        {
            system.debug(e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }              
         return projectId;
    }

    public static String getProjectKey(String boardId){  
        string projectKey;
        try{        
            Http http = new Http();
            String responseJson = '';
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');        
            request.setEndpoint('callout:Jira_API/rest/agile/latest/board/'+boardId+'/');
            request.setHeader('Content-Type','application/json'); 

            HttpResponse res = http.send(request);
            responseJson = res.getBody();
            Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(responseJson);
            Map<String,Object> locationMap = (Map<String,Object>)jsonResponse.get('location');
            System.debug('Location : ' + locationMap);
            projectKey = (string)locationMap.get('projectKey');
            System.debug('Project Key: ' + projectKey);
        }        
        catch(Exception e)    
        {
            system.debug(e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }              
        return projectKey;
    }
    
    @Future(callout=True)
    public static void callOutToJira(List<String> lstJira,Id lstNxtSRId){
        
    //    Map<String,String> statRec = new Map<String,String>();
        Map<String,String> descRec = new Map<String,String>();
        Set<String> stat = new Set<String>();
        String srValue;        
        String Key;
        for(String str : lstJira){
            try{                     
                Key=str;
                Http http = new Http();
                String responseJson = '';        
                HttpRequest request = new HttpRequest();
                
                request.setMethod('GET');        
                request.setEndpoint('callout:Jira_API/rest/api/3/issue/' + Key + '?fields=status,summary');
                request.setHeader('Content-Type','application/json');
                
                HttpResponse res = http.send(request);
                System.debug('JSON Response get: ' + res.getBody());
                responseJson = res.getBody();
                
                if(responseJson.contains('errorMessages')){
                    continue;
                }
                
                Map<string,object> jsonResponse = (Map<string,object>)JSON.deserializeUntyped(responseJson);
                System.debug('String :' + jsonResponse );
                
                Map<String,Object> fieldMap = (Map<String,Object>)jsonResponse.get('fields');
                if(fieldMap != null){
                    system.debug('field : ' + fieldMap);
                    
                    Map<String,Object> statusMap = (Map<String,Object>)fieldMap.get('status');
                    system.debug('status : ' + statusMap);
                    
                    String summary = (String)fieldMap.get('summary');
                    System.debug('Summary : '+summary);
                    
                    String statuss = (String)statusMap.get('name');
                    
                    system.debug('Status of Key : ' + statuss); 
                    stat.add(statuss);
               //     statRec.put(Key,statuss); 
                    String keyValuePair = statuss +':'+ summary;
                    descRec.put(Key,keyValuePair);
                }
            }
            catch(Exception e)    
            {
                system.debug(e.getMessage());
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            }
            
        }
        
        displayJiraReport(lstNxtSRId,descRec,stat);
        

    } 
    
    public static void displayJiraReport(Id lstNxtSRId,Map<String,String> descRec,Set<String> stat){
        if(!descRec.isEmpty()){

            String strSummary;
            String strStat, pair;
            system.debug('descRec.keySet : '+ descRec.keySet());
            
            Map<String,list<String>> keyMap= new Map<String,list<String>>(); //use
            try{       
                for(String s : stat){
                        list<String> keydes= new list<String>();
                        for(String keys  : descRec.keySet()){
                            strstat = descRec.get(keys).substringBefore(':');
                            strSummary = descRec.get(keys).substringAfter(':');
                            if(s==strstat){
                                pair = keys +' : ' + strSummary + '<br/>';
                                keydes.add(pair);
                            }    
                        } 
                        keyMap.put(s,keydes);
                }            
                    
                system.debug('keyMap : '+keyMap);
                String finalVal='';

                for(String k : keyMap.keySet()){             
                    String val='<ul>';
                    for(String str : keyMap.get(k)){
                        val=val +'<li>'+str+'</li>';                
                    }
                    system.debug('str : '+val);
                    finalVal=finalVal+'<p>'+k +':'+'</p>'+val+'</ul>';
                    system.debug('k1 : '+finalVal);             

                }                   
                    
                Status_Report__c lstNxtDySR = [Select id, Work_for_the_day__c from Status_Report__c where id =: lstNxtSRId];
                lstNxtDySR.Work_for_the_day__c = lstNxtDySR.Work_for_the_day__c + '<p>The statuses of active initiatives in Jira are provided below:' +'<br/>'+finalVal;
                Update lstNxtDySR;
        
            }  
            catch(Exception e)    
            {
                    system.debug(e.getMessage());
                    ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            }   
        }        
    }

    private static string getEncodedMultiplesStatuses(string criteria, string splitter){
        string statusValues = '';
        for(string eachStats: (criteria).split(splitter)){
            if(eachStats.contains(' ')){
                eachStats = eachStats.replace(' ', '%20');
                eachStats = '%27' + eachStats + '%27';
            }
            statusValues += eachStats + '%2C%20';
        }
        statusValues = statusValues.Substring(0,statusValues.length()-6);
        return statusValues;     
    }    

    private static string getEncodedSingleStatus(string criteria){
        string statusValues = '';
        if(criteria.contains(' ')){
            statusValues = (criteria).replace(' ', '%20');
        }
        else{
            statusValues = criteria;
        }
        return statusValues;     
    }

    private static Date getFormattedDate(List<string> dateUnformatted){
        Integer tmpDate = integer.valueOf(dateUnformatted[0]);
        Integer tmpMonth = integer.valueOf(dateUnformatted[1]);
        Integer tmpYear = integer.valueOf(dateUnformatted[2]);
        Date resolutionDate = Date.newInstance(tmpDate,tmpMonth,tmpYear);
        return resolutionDate;         
    }

    private static string getMonthYearJql(string month, string year){
        string monthYearJql = '';
        if(month != '0'){
            string lastDay = string.valueOf(date.daysInMonth(Integer.valueOf(year),Integer.valueOf(month)));
            monthYearJql = '%20and%20statusCategoryChangedDate%20%3E%3D%20%27' + string.valueOf(year) + '%2F' + string.valueOf(month) + '%2F1%2000%3A00%27';
            monthYearJql += '%20and%20statusCategoryChangedDate%20%3C%3D%20%27' + string.valueOf(year) + '%2F' + month + '%2F' + lastDay + '%2023%3A59%27';
        }else{
            monthYearJql = '%20and%20statusCategoryChangedDate%20%3E%3D%20%27' + string.valueOf(year) + '%2F1%2F1%2000%3A00%27';
            monthYearJql += '%20and%20statusCategoryChangedDate%20%3C%3D%20%27' + string.valueOf(year) + '%2F12%2F31%2023%3A59%27';
        }
        System.debug(monthYearJql);        
        return monthYearJql;
    }
    
}