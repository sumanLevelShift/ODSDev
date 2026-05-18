/*****************************************************************************************
* @date             05-04-2018
* @Status           Developed
* @Class Name       EZRE_Data_Utility_Test
* @description      This is test class for EZRE_Data_Utility Handler class.
******************************************************************************************
 Version     Date           Team                    Comments
******************************************************************************************
* 1         Apr 2018        Mani&Team                  Initial Creation
******************************************************************************************/
@isTest
public class EZRE_Data_Utility_Test
{    
    static testMethod void testRequirementData() {    
        Requirement__c req = new Requirement__c(Name='Developer',Duration__c='12',Min_Cost__c=100,Rate__c=1000,Max_Cost__c=500,
            Position_Type__c='FullTime',State__c='AB',Job_Category__c='Open',Status__c='Open',City__c='Chennai',
            Requirement_Type__c='FTE',Resumes_2__c=3,No_Of_Resumes__c=2);
        insert req;
        
        Requirement__c r1 = EZRE_Data_Utility.fetchReq(String.valueOf(req.Id));  
        Requirement__c r2 = EZRE_Data_Utility.fetchReqData(req.Id);
        Requirement__c r3 = EZRE_Data_Utility.reqRec(String.valueOf(req.Id));           
    }
    
    static testMethod void testCandidateData() {
        List<Id> lc = new List<Id>();
        Candidate__c can = new Candidate__c(Name='test',Last_Name__c='test1',Home_Phone_No__c='989898',Current_City__c='Chennai',
            Current_State__c='Florida',Email__c='sample@sample.com',Category__c='Open',Cost__c=1234,
            Interview_Contact_Phone__c='Home Phone',Contract_Type__c='W2',Visa_Type__c='Citizen',
            Resume_Source__c='Monster');
        
        lc.add(can.Id);    
            
        List<Candidate__c> lCand = EZRE_Data_Utility.fetchLstElgblCan(lc);
    }
    
    static testMethod void testRequirementAssignmentData() {
        User u1 = [SELECT Id,Name FROM User WHERE Profile.Name = 'LR Chatter Only User' AND isActive = true LIMIT 1];
        User u2 = [SELECT Id,Name FROM User WHERE Profile.Name = 'R Chatter Only User' AND isActive = true LIMIT 1];
        
        Requirement__c req = new Requirement__c(Name='Developer',Duration__c='12',Min_Cost__c=100,Rate__c=1000,Max_Cost__c=500,
            Position_Type__c='FullTime',State__c='AB',Job_Category__c='Open',Status__c='Open',City__c='Chennai',
            Requirement_Type__c='FTE',Resumes_2__c=3,No_Of_Resumes__c=2);
        insert req;
        
        RequirementAssignment__c ra = new RequirementAssignment__c();
        ra.Requirement__c = req.Id;
        ra.Lead_Recruiter__c = u1.Id;
        ra.Recruiter__c = u2.Id;        
        insert ra;
        
        RequirementAssignment__c ra1 = EZRE_Data_Utility.fetchReqAssgData(req.Id);
       // List<RequirementAssignment__c> lra1 = EZRE_Data_Utility.fetchAllReqAssgData(ra1.Id);
    }
    
    static testMethod void testSearchData() {
        List<List<SObject>> src = EZRE_Data_Utility.fetchSearchList('test');
    }
    
    static testMethod void testContactIns() {
        Contact c = EZRE_Data_Utility.insertContact(null,'sample@sample.com','testContact1');
    }
    
    static testMethod void testMailChimp() {        
        Mailchimp_Details__c md = EZRE_Data_Utility.getMCDtls('MCAccount');
    }
    
    static testMethod void testCandidateMap() { 
        Candidate__c can = new Candidate__c(Name='test',Last_Name__c='testOk',Home_Phone_No__c='9898989898',Current_City__c='Chennai',
            Current_State__c='Florida',Email__c='sample@sample.com',Category__c='Open',Cost__c=1234,
            Interview_Contact_Phone__c='Home Phone',Contract_Type__c='W2',Visa_Type__c='Citizen',
            Resume_Source__c='Monster');
        insert can;
        
        Requirement__c req = new Requirement__c(Name='Developer',Duration__c='12',Min_Cost__c=100,Rate__c=1000,Max_Cost__c=500,
            Position_Type__c='FullTime',State__c='AB',Job_Category__c='Open',Status__c='Open',City__c='Chennai',
            Requirement_Type__c='FTE',Resumes_2__c=3,No_Of_Resumes__c=2);
        insert req;
        
        List<Candidate_Mapping__c> cm = EZRE_Data_Utility.fetchCndtMppngLst(can.id,req.id);
    }
    /*
    static testMethod void testMCCandidate() { 
        MCCandidateList__c mc = EZRE_Data_Utility.CrtMCCndtLst('701p0000000E7dR','sample@sample.com');
        
        set<String> sEmail = new Set<String>();
        sEmail.add('sample@sample.com');
        List<MCCandidateList__c> lmc1 = EZRE_Data_Utility.lstMCCndtLst('701p0000000E7dR',sEmail);
        List<MCCandidateList__c> lmc2 = EZRE_Data_Utility.lstNewMCCndtLst();
        List<MCCandidateList__c> lmc3 = EZRE_Data_Utility.lstNewCndtLst('701p0000000E7dR');                
    }
    */
    static testMethod void testFetchContact() {
        List<String> lEml = new List<String>();
        lEml.add('sample@sample.com');
        List<Contact> lCon = EZRE_Data_Utility.fetchConRecs(lEml);
        Set<String> sEml = new Set<String>();
        sEml.add('sample@sample.com');
        List<Contact> lCon2 = EZRE_Data_Utility.fetchConRecords(sEml);
    }
    
    static testMethod void testFetchCandidate() {
        Set<String> sEml = new Set<String>();
        sEml.add('sample@sample.com');
        List<Candidate__c> lCon = EZRE_Data_Utility.fetchLstcan(sEml);
    }
    
    static testMethod void testCronTrigger() {
        //CronTrigger ct = EZRE_Data_Utility.getCronTriggewrDetails('1234');
    }
    
    static testMethod void testFetchOpty() {
        /*Id accId = [SELECT Id FROM Account LIMIT 1].Id;*/
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('mytest','testuser@testmail.com', 
            'UTF-8','Indumathi6', 'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
            'ezre@preludesys.com','Practice Head', true);
        Account acc = ODS_DataFactory_Test_Utility.InsertAccountforIntroAndKickoffMail('TestAccount',usrObj.id,
            'Sent',system.today(),10000,'7665233156','Others','ODS Project',True, 'Customer',True,false);
        Opportunity opp = new Opportunity(Name='TestOpty',AccountId=acc.id,Follow_up_Date__c=system.today(),
            CloseDate=system.today().addDays(5),stageName='Prospecting');
        
        insert opp;
               
        List<Opportunity> lopty1 = EZRE_Data_Utility.fetchOppList(acc.Id);
        //List<Opportunity> lopty2 = EZRE_Data_Utility.getOppList(String.valueOf(acc.Id),'Prospecting','Ramesh');
        Opportunity opp2 = EZRE_Data_Utility.fetchOpp(opp.Id);
    }
    
    static testMethod void testFecthEvent() {
        /*Id accId = [SELECT Id FROM Account LIMIT 1].Id;*/
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('mytest','testuser@testmail.com', 
            'UTF-8','Indumathi6', 'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
            'ezre@preludesys.com','Practice Head', true);
        Account acc = ODS_DataFactory_Test_Utility.InsertAccountforIntroAndKickoffMail('TestAccount',usrObj.id,
            'Sent',system.today(),10000,'7665233156','Others','ODS Project',True, 'Customer',True,false);
        Event e = new Event(WhatId=acc.id,OwnerId=userInfo.getUserId(),Subject='Test',StartDateTime=system.now(),
            EndDateTime=system.now().addDays(5),ActivityDateTime=system.now());
        insert e;
        
        List<Event> lEv = EZRE_Data_Utility.fetchEventList(acc.Id);
    }
    
    static testMethod void testFecthTask() {
        /*Id accId = [SELECT Id FROM Account LIMIT 1].Id;*/
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('mytest','testuser@testmail.com', 
            'UTF-8','Indumathi6', 'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
            'ezre@preludesys.com','Practice Head', true);
        Account acc = ODS_DataFactory_Test_Utility.InsertAccountforIntroAndKickoffMail('TestAccount',usrObj.id,
            'Sent',system.today(),10000,'7665233156','Others','ODS Project',True, 'Customer',True,false);
        Contact con = ODS_DataFactory_Test_Utility.InsertContactforcreatechilds('Test','Contact','1: Calling',acc.Id,'sample@sample.com');    
        Task t = new task(WhatId=acc.Id,OwnerId=userInfo.getUserId(),Subject='Send Email',Status='Completed',
            Priority='Normal',ActivityDate=system.today(),whoid=con.id);
        insert t;
        
        List<Task> lTsk = EZRE_Data_Utility.fetchTaskList(acc.Id);
        Set<Id> sCon = new Set<Id>();
        sCon.add(con.Id);
        List<Task> ltsk2 = EZRE_Data_Utility.fetchTaskRcrds(sCon);
        List<Task> ltsk3 = EZRE_Data_Utility.fetchTaskRecs(con);
        
        Task t2 = EZRE_Data_Utility.createTask('TestTaskSubj',String.valueOf(acc.Id),String.valueOf(con.id),'Completed','Normal');
        Task t3 = EZRE_Data_Utility.createAccountTask('TestTaskSubj',String.valueOf(acc.Id),'Completed','Normal');
    }
    
    static testMethod void testFecthContact() {
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('mytest','testuser@testmail.com', 
            'UTF-8','Indumathi6', 'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
            'ezre@preludesys.com','Practice Head', true);
        Account acc = ODS_DataFactory_Test_Utility.InsertAccountforIntroAndKickoffMail('TestAccount',usrObj.id,
            'Sent',system.today(),10000,'7665233156','Others','ODS Project',True, 'Customer',True,false);
        
        Set<Id> sAcc = new Set<Id>();
        sAcc.add(acc.Id);
        List<Account> lAcc3 = EZRE_Data_Utility.fetchAccounts(sAcc);
            
        Contact con = ODS_DataFactory_Test_Utility.InsertContactforcreatechilds('Test','Contact','1: Calling',acc.Id,'sample@sample.com');     
        
        List<Contact> con1 = EZRE_Data_Utility.fetchCntctList(acc.id);
        EZRE_Data_Utility.updateContactsList(con1);
        
        Set<Id> sCon = new Set<Id>();
        sCon.add(con.Id);
        List<Contact> lCon2 = EZRE_Data_Utility.fetchContacts(sCon);
        
        Set<String> sCon2 = new Set<String>{'sample@sample.com'};
        List<Contact> lCon3 = EZRE_Data_Utility.fetchContRec(sCon2);
    }
    
    static testMethod void testFecthUserrole() {
        userRole ur = EZRE_Data_Utility.fetchUserRole();
        List<User> usr = EZRE_Data_Utility.fetchUsersList(ur.Id);
        User u = EZRE_Data_Utility.fetchUser(UserInfo.getuserId());
    }
    
    static testMethod void testFecthWorkAlloc() { 
        Work_Allocation__c wa = new Work_Allocation__c(name='Test'); 
        List<Work_Allocation__c> lWa = new List<Work_Allocation__c>();
        lWa.add(wa); 
        EZRE_Data_Utility.insertWorkAllocationList(lWa);     
        List<Work_Allocation__c> wa1 = EZRE_Data_Utility.fetchWorkAllocationList();
        EZRE_Data_Utility.updateWorkAllocationList(wa1);
        List<String> repName = new List<String>{wa.name};
        List<Work_Allocation__c> wa2 = EZRE_Data_Utility.fetchWrkAllctnLstOrderbyTimezone(repName);
        EZRE_Data_Utility.deleteWorkAllocationList(wa1);                      
    }
    
    static testMethod void testFecthWorkAlloc2() {
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('mytest','testuser@testmail.com', 
            'UTF-8','Indumathi6', 'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
            'ezre@preludesys.com','Practice Head', true);
        Account acc = ODS_DataFactory_Test_Utility.InsertAccountforIntroAndKickoffMail('TestAccount',usrObj.id,
            'Sent',system.today(),10000,'7665233156','Others','ODS Project',True, 'Customer',True,false);
            
        Contact con = ODS_DataFactory_Test_Utility.InsertContactforcreatechilds('Test','Contact','1: Calling',acc.Id,'sample@sample.com');              
        Set<Id> sCon = new Set<Id>();
        sCon.add(con.Id);        
        Work_Allocation__c wa = new Work_Allocation__c(name='Test',Contact__c=con.Id);
        List<Work_Allocation__c> lwa2 = EZRE_Data_Utility.fetchWorkAllctnCaledList(sCon,system.now(),system.now());
    }
    
    static testMethod void testFecthSalesStage() {
        Sales_Coach_Stage__c ss = new Sales_Coach_Stage__c(Name='test_ss',active__c=true);
        insert ss;
        
        Sales_Coach_Stage__c ss1 = EZRE_Data_Utility.fetchSalesCoach(ss.Name);
        Sales_Coach_Stage__c[] ss2 = EZRE_Data_Utility.fetchSalesCoachstage(ss.Name);
        
        Sales_Coach_Section__c scs = new Sales_Coach_Section__c(Section_Name__c='Test_scs',Sales_Coach_Stage__c=ss.Id);
        insert scs;
        
        List<Sales_Coach_Section__c> scs1 = EZRE_Data_Utility.fetchlstSalesCoach(ss.id);
        List<Sales_Coach_Section__c> scs2 = EZRE_Data_Utility.fetchlstSalesCoachSection(scs.Section_Name__c);
        Sales_Coach_Section__c  scs3 = EZRE_Data_Utility.getSalesCoachSect(scs.id);
        List<Sales_Coach_Section__c> scs5 = EZRE_Data_Utility.getSalesCoachSection(ss.id);
        
        Sales_Coach_Activity__c sca = new Sales_Coach_Activity__c(Sales_Coach_Stage__c=ss.id,Ordering_Number__c=10);
        insert sca;
        
        List<Sales_Coach_Activity__c> sca1= EZRE_Data_Utility.fetchlstSalesCoachActvty(ss.id);
        List<Sales_Coach_Activity__c> sca2= EZRE_Data_Utility.fetchSalesCoachActy(ss.id);
        Sales_Coach_Activity__c sca3 = EZRE_Data_Utility.getSalesCoachActy(sca.id);
        
        Sales_Coach_Section_Item__c sci = new Sales_Coach_Section_Item__c(Sales_Coach_Section__c=scs.id,Item_Name__c='Test_sci');
        insert sci;
        
        Sales_Coach_Section_Item__c sci1 = EZRE_Data_Utility.getSalesCoachItem(sci.id);
        
        Sales_Coach_Stage__c scs4 = EZRE_Data_Utility.InsertSalesCoachSect('Test_SCS4');
    }
    
}