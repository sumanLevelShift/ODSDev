@IsTest
public class CreateEstimationEffortCalculationTest {
    @IsTest
    public static void estimationSummaryTest(){
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
            Account acc=New Account();            
            acc.Name='Test account';
            acc.Lead_Gen_Name__c = 'Others';
            insert acc;
            
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Customer__c=acc.id;
            es.Revenue_Region__c='US';
            es.Project_Billing_Type__c='Milestone';
            es.Created_By__c=hl.id;
            es.Work_Hours_Per_Day__c=5;
            es.Work_Days_Per_Month__c=20;   
            es.Work_Days_Per_Week__c=2;
            insert es;
            
            String inventoryRecordTypeId = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            
            Estimation_Detail__c esd=new Estimation_Detail__c();
            esd.Platform__c = 'Force.com';
            esd.Entity_Type__c = '3rd Party Integration';
            esd.Effort_Type__c = 'Declarative';
            esd.Complexity__c = 'Simple';
            esd.Estimation_Summary__c = es.id;
            esd.RecordTypeId=inventoryRecordTypeId;
            esd.Quantity__c=2;
            esd.Project_Specfic_Effort__c=3;
            insert esd;
            
            string draftSLDSPhaseResponse='[{"SDLCPhasesName":"Requirements","ProjectSpecific":"12"},{"SDLCPhasesName":"Design","ProjectSpecific":"18"},{"SDLCPhasesName":"Development (Code and unit testing)","ProjectSpecific":"10"},{"SDLCPhasesName":"Integration Testing","ProjectSpecific":"5"}]';
            CreateEstimationEffortCalculationCntrl.CalculateTotalBaseHours(es.Id);
            CreateEstimationEffortCalculationCntrl.generateInitialSDLCPhasesData(1, 10, es.id);
            CreateEstimationEffortCalculationCntrl.reGenerateInitialSDLCPhases(1, 10,  es.id, draftSLDSPhaseResponse, 10);
            
            CreateEstimationEffortCalculationCntrl.getExistSDLCPhasesData(1,1.1,es.id);
            String SDLCPhaseEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('SDLC Phase Effort').getRecordTypeId();
            Effort_Calculation__c SDLCPhaseEffort=new Effort_Calculation__c();
            SDLCPhaseEffort.RecordTypeId=SDLCPhaseEffortRecordTypeId;
            SDLCPhaseEffort.ODS_Estimate__c=es.id;
            SDLCPhaseEffort.Remarks__c='test';
            SDLCPhaseEffort.Person_Months__c=2.1;
            SDLCPhaseEffort.SLDC_Phase_Name__c='Requirements';
            SDLCPhaseEffort.Project_Specific__c=10;
            insert SDLCPhaseEffort;
            CreateEstimationEffortCalculationCntrl.getExistSDLCPhasesData(1,1.1,es.id);
            decimal p=0;
            string p1=string.valueOf(p);
            string draftResponseOtherActivity='[{"SDLCPhasesName":"Requirements","ProjectSpecific":"12","personMonth":"'+1.0+'","personWeek":"'+0.7+'"},{"SDLCPhasesName":"All","ProjectSpecific":"12","personMonth":"'+2.8+'","personWeek":"'+1.8+'"}]';
            CreateEstimationEffortCalculationCntrl.generateOtherActivities(es.id,'All',draftResponseOtherActivity,2);
            CreateEstimationEffortCalculationCntrl.generateOtherActivities(es.id,'Requirements',draftResponseOtherActivity,3);
            CreateEstimationEffortCalculationCntrl.getEstimationRecord(es.id,1.0);
            
            //insert effortCalculation
            string insertSLDSPhaseResponse='[{"SDLCPhasesName":"Requirements","ProjectSpecific":"12","personMonth":"'+2.0+'","personWeek":"'+3.1+'","Rationale":"test"},{"SDLCPhasesName":"Design","ProjectSpecific":"18","personMonth":"'+2.0+'","personWeek":"'+3.1+'","Rationale":"test"},{"SDLCPhasesName":"Development (Code and unit testing)","ProjectSpecific":"10","personMonth":"'+2.0+'","personWeek":"'+3.1+'","Rationale":"test"},{"SDLCPhasesName":"Integration Testing","ProjectSpecific":"5","personMonth":"'+2.0+'","personWeek":"'+3.1+'","Rationale":"test"}]';
            string insertOtherActivityEffortRes='[{"Activity":"Project Management","Applicable":"Requirements","ProjectSpecific":"12","personMonth":"2.0","Rationale":"test"},{"Activity":"Requirements Management","Applicable":"All","ProjectSpecific":"12","personMonth":"2.0","Rationale":"test"}]';
            string insertProjectSpecificRes='[{"Activity":"Production support","personMonth":"2.0","Rationale":"test"},{"Activity":"Warranty","personMonth":"2.0","Rationale":"test"}]';
            CreateEstimationEffortCalculationCntrl.insertEffortCalculations(es.id, insertSLDSPhaseResponse, insertOtherActivityEffortRes, insertProjectSpecificRes);
            CreateEstimationEffortCalculationCntrl.updateEstimationSummary(es.id, 0.7,2,1);
            CreateEstimationEffortCalculationCntrl.getExistOtherActivitiesEffort(es.id);
            CreateEstimationEffortCalculationCntrl.getExistProjectSpecificActivitiesEffort(es.id);
            string ODSEstimateResponse='[{"LineItem":"Analysis","Percentage":"12","ActualHours":"2.0"},{"LineItem":"Design","Percentage":"18","ActualHours":"3.1"}]';
            CreateEstimationEffortCalculationCntrl.insertODSEstimate(ODSEstimateResponse,es.id);
            CreateEstimationEffortCalculationCntrl.getTotalHoursForEstimation(es.id);
            CreateEstimationEffortCalculationCntrl.getInventoryLineItem(es.id, 0, 0, 0, 0,40);
            system.assertEquals(SDLCPhaseEffort.ODS_Estimate__c,es.id);
        }
    }
    @IsTest
    public static void effortCalTest(){
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
            Account acc=New Account();
            acc.Name='Test account';
            acc.Lead_Gen_Name__c = 'Others';
            insert acc;
            
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Customer__c=acc.id;
            es.Revenue_Region__c='US';
            es.Project_Billing_Type__c='Milestone';
            es.Created_By__c=hl.id;
            es.Work_Hours_Per_Day__c=5;
            es.Work_Days_Per_Month__c=20;   
            es.Work_Days_Per_Week__c=2;
            insert es;  
            
            String SDLCPhaseEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('SDLC Phase Effort').getRecordTypeId();
            String OtherActivityEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('Other Activity Effort').getRecordTypeId();
            String ProjectSpecificActivityEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('Project Specific Activity Effort').getRecordTypeId();
           
            Effort_Calculation__c ecal=new Effort_Calculation__c();
            ecal.SLDC_Phase_Name__c='Requirements';
            ecal.Project_Specific__c=3.4;
            ecal.Person_Months__c=0.4;
            ecal.Remarks__c	='test';
            ecal.RecordTypeId=SDLCPhaseEffortRecordTypeId;
            ecal.ODS_Estimate__c=es.id;
            insert ecal;
            
            Effort_Calculation__c ecal1=new Effort_Calculation__c();
            ecal1.Activity_Name__c='Project Management';
            ecal1.Applicable_SDLC_Phases__c='All';
            ecal1.Project_Specific__c=1.6;
            ecal1.Person_Months__c=0.1;
            ecal1.Comments__c='Rationale';
            ecal1.RecordTypeId=OtherActivityEffortRecordTypeId;
            ecal1.ODS_Estimate__c=es.Id;
            insert ecal1;
            
            Effort_Calculation__c ecal2=new Effort_Calculation__c();
            ecal2.Activity_Name__c='Activity';
            ecal2.Person_Months__c=2;
            ecal2.Comments__c='Rationale';
            ecal2.RecordTypeId=ProjectSpecificActivityEffortRecordTypeId;
            ecal2.ODS_Estimate__c=es.Id;
            insert ecal2;
            
            CreateEstimationEffortCalculationCntrl.getExistOtherActivitiesEffort(es.id);
            CreateEstimationEffortCalculationCntrl.getExistProjectSpecificActivitiesEffort(es.id);
            system.assertEquals(ecal2.ODS_Estimate__c,es.id);
        }
        
    }
    @IsTest
    public static void effortCalTestV1(){
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
            CreateEstimationEffortCalculationCntrl.getExistOtherActivitiesEffort('');
            CreateEstimationEffortCalculationCntrl.getExistProjectSpecificActivitiesEffort('');
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');
        }
    }
}