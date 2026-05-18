@isTest
public class EstimationReportControllerTest {
    @isTest
    public static void runReport(){
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id);    
        usrObj.FirstName='Lokesh';
        usrObj.LastName='Rekapalli';
        usrObj.Delivery_Role__c='TPM/SME';
        
        update usrObj;
        System.runAs (usrObj) 
        {       
            Hierarchy_Lookup__c hl=new Hierarchy_Lookup__c();
            hl.First_Name__c='Lokesh';
            hl.Last_Name__c='Rekapalli';
            hl.Email_Address__c='sfadmin@demandblue.com';
            hl.Delivery_Role__c='TPM/SME';
            insert hl;
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;            
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id); 
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Customer__c=accObj.id;
            es.Revenue_Region__c='US';
            es.Project_Billing_Type__c='Milestone';
            es.Created_By__c=hl.id;
            es.Work_Hours_Per_Day__c=5;
            insert es;
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Selva',accObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Re-evaluate');
            
            Estimation_Summary__c es1=new Estimation_Summary__c();
            es1.Customer__c=accObj.id;
            es1.Work_Hours_Per_Day__c=3;
            es1.Project_ID__c=initiative.id;
            es1.Revenue_Region__c='US';
            es1.Project_Billing_Type__c='Milestone';
            es1.Created_By__c=hl.id;
            //es1.Total_Base_Effort_Programming__c=1;
            insert es1;
            String recordTypeInventory = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            Estimation_Detail__c esd=new Estimation_Detail__c();
            esd.Platform__c = 'Force.com';
            esd.Entity_Type__c = '3rd Party Integration';
            esd.Effort_Type__c = 'Declarative';
            esd.Complexity__c = 'Simple';
            esd.Estimation_Summary__c = es1.id;
            esd.RecordTypeId=recordTypeInventory;
            esd.Project_Specfic_Effort__c=2;
            insert esd;
            
            String ComplexityRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Complexity Matrix').getRecordTypeId();
            Estimation_Detail__c esd1=new Estimation_Detail__c();
            esd1.Platform__c = 'Force.com';
            esd1.Entity_Type__c = '3rd Party Integration';
            esd1.Effort_Type__c = 'Declarative';
            esd1.Complexity__c = 'Simple';
            esd1.Estimation_Summary__c = es1.id;
            esd1.RecordTypeId = ComplexityRecordTypeID;
            insert esd1;
            
            Estimation_Checklist__c checklist1 = new Estimation_Checklist__c();
            checklist1.Remarks__c = 'test';
            checklist1.Check__c = true;
            checklist1.Activities__c ='new tests';
            checklist1.S_No__c= 1;
            checklist1.Status__c='Yes';
            checklist1.Estimation_Summary__c = es1.id;
            checklist1.Required__c =  True;
            insert checklist1;
            
            
            String SDLCPhaseEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('SDLC Phase Effort').getRecordTypeId();
            String OtherActivityEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('Other Activity Effort').getRecordTypeId();
            String ProjectSpecificActivityEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('Project Specific Activity Effort').getRecordTypeId();
            Effort_Calculation__c ecal=new Effort_Calculation__c();
            ecal.SLDC_Phase_Name__c='Requirements';
            ecal.Project_Specific__c=3.4;
            ecal.Person_Months__c=0.4;
            ecal.Remarks__c	='test';
            ecal.RecordTypeId=SDLCPhaseEffortRecordTypeId;
            ecal.ODS_Estimate__c=es1.id;
            insert ecal;
            
            Effort_Calculation__c ecal1=new Effort_Calculation__c();
            ecal1.Activity_Name__c='Project Management';
            ecal1.Applicable_SDLC_Phases__c='Requirement';
            ecal1.Project_Specific__c=1.6;
            ecal1.Person_Months__c=0.1;
            ecal1.Comments__c='Rationale';
            ecal1.RecordTypeId=OtherActivityEffortRecordTypeId;
            ecal1.ODS_Estimate__c=es1.Id;
            insert ecal1;
            
            Effort_Calculation__c ecal2=new Effort_Calculation__c();
            ecal2.Activity_Name__c='Activity';
            ecal2.Person_Months__c=2;
            ecal2.Comments__c='Rationale';
            ecal2.RecordTypeId=ProjectSpecificActivityEffortRecordTypeId;
            ecal2.ODS_Estimate__c=es1.Id;
            insert ecal2;
            PageReference pageRef = Page.EstimationReport; 
            pageRef.getParameters().put('AccountId', accObj.id);
            pageRef.getParameters().put('EstimationId', es1.Id);
            Test.setCurrentPage(pageRef);
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');
            EstimationReportController obj=new EstimationReportController();
        }
    }
}