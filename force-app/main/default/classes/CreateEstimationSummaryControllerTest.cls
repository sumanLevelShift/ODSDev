@isTest
public class CreateEstimationSummaryControllerTest {
    @isTest
    public static void estimationSummaryTest1(){
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
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id); 
            Estimation_Summary__c es=new Estimation_Summary__c();
            /*  es.Customer__c=accObj.id;
es.Revenue_Region__c='US';
es.Project_Billing_Type__c='Milestone';
es.Created_By__c='Test User';
es.Work_Hours_Per_Day__c=5;
insert es;*/
            
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
            initiative.Technical_Project_Manager__c='Lokesh Rekapalli';
            update initiative;
            system.debug('usrObj-'+usrObj.Name);
            
            Hierarchy_Lookup__c hl=new Hierarchy_Lookup__c();
            hl.First_Name__c='Lokesh';
            hl.Last_Name__c='Rekapalli';
            hl.Email_Address__c='sfadmin@demandblue.com';
            hl.Delivery_Role__c='TPM/SME';
            insert hl;
            
            Estimation_Summary__c es1=new Estimation_Summary__c();
            es1.Customer__c=accObj.id;
            es1.Work_Hours_Per_Day__c=3;
            es1.Project_ID__c=initiative.id;
            es1.Revenue_Region__c='US';
            es1.Project_Billing_Type__c='Milestone';
            es1.Created_By__c=hl.id;
            es1.Technical_Project_Manager__c=hl.id;
            es1.Acceptance_Criteria__c='1';
            es1.Assumptions__c='1';
            es1.Out_of_Scope__c='1';
            es1.Scope__c='1';
            insert es1;
            
            Estimation_Summary__c esApproved=new Estimation_Summary__c();
            esApproved.Customer__c=accObj.id;
            esApproved.Work_Hours_Per_Day__c=3;
            esApproved.Project_ID__c=initiative.id;
            esApproved.Revenue_Region__c='US';
            esApproved.Project_Billing_Type__c='Milestone';
            esApproved.Created_By__c=hl.id;
            esApproved.Technical_Project_Manager__c=hl.id;
            esApproved.Acceptance_Criteria__c='1';
            esApproved.Assumptions__c='1';
            esApproved.Out_of_Scope__c='1';
            esApproved.Scope__c='1';
            esApproved.Status__c='Approved';
            insert esApproved;
            
            String recordTypeInventory = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            Estimation_Detail__c esd=new Estimation_Detail__c();
            esd.Platform__c = 'Force.com';
            esd.Entity_Type__c = '3rd Party Integration';
            esd.Effort_Type__c = 'Declarative';
            esd.Complexity__c = 'Simple';
            esd.Estimation_Summary__c = es1.id;
            esd.RecordTypeId=recordTypeInventory;
            insert esd;
            
            Estimation_Summary__c es2=new Estimation_Summary__c();
            es2.Customer__c=accObj.id;
            es2.Work_Hours_Per_Day__c=3;
            es2.Project_ID__c=initiative.id;
            es2.Revenue_Region__c='US';
            es2.Project_Billing_Type__c='Milestone';
            es2.Created_By__c=hl.id;
            es2.Technical_Project_Manager__c=hl.id;
            es2.Status__c='Ready for Approval';
            es2.SME_Vertical__c=hl.id;
            es2.Approved_User_Track__c=hl.Full_Name__c;
            es2.Acceptance_Criteria__c='1';
            es2.Assumptions__c='1';
            es2.Out_of_Scope__c='1';
            es2.Scope__c='1';
            insert es2;
            
            CreateEstimationSummaryController.checkExistRecordsOnRelated(es1.id);
            CreateEstimationSummaryController.getReEvaluateInitiatives(es1.id);
            //CreateEstimationSummaryController.getProgramManagerUsers('Lokesh Rekapalli');
           // CreateEstimationSummaryController.getSEMVerticalUsers();
           // CreateEstimationSummaryController.getTPMValidations(es1.id);
            CreateEstimationSummaryController.getStatusPickListValue(es1.id);
            CreateEstimationSummaryController.validationForApproverButton(es2.id);
            CreateEstimationSummaryController.approveTheEstimation(es1.id,'Lokesh Rekapalli');
            CreateEstimationSummaryController.getHierarchyLookupList();
            CreateEstimationSummaryController.updateHours(es1.id,2,2,2);
            CreateEstimationSummaryController.getNotApproverUser(es2.id);
            CreateEstimationSummaryController.getTPMDetails(hl.Full_Name__c);
            CreateEstimationSummaryController.getcurrentUserAccessForEstimation();
            CreateEstimationSummaryController.getHierarchyLookupList();
            CreateEstimationSummaryController.updateHours(es1.id,2,4,2);
			CreateEstimationSummaryController.getcurrentUserPM(esApproved.id);
            CreateEstimationSummaryController.sendEstimationReadyForApproval(esApproved.id);
            CreateEstimationSummaryController.validationOnEffortCalculation(esApproved.id);
            CreateEstimationSummaryController.validationOnInventory(esApproved.id);
            CreateEstimationSummaryController.validationOnComplexity(esApproved.id);
            CreateEstimationSummaryController.updateApproverUserTrack(esApproved.id);

            system.assertEquals( es2.Status__c,'Ready for Approval');
            
        }
    }
    @isTest
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
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id); 
            
            Hierarchy_Lookup__c hl=new Hierarchy_Lookup__c();
            hl.First_Name__c='Lokesh';
            hl.Last_Name__c='Rekapalli';
            hl.Email_Address__c='sfadmin@demandblue.com';
            hl.Delivery_Role__c='TPM/SME';
            insert hl;
            
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Customer__c=accObj.id;
            es.Revenue_Region__c='US';
            es.Project_Billing_Type__c='Milestone';
            es.Created_By__c=hl.id;
            es.Work_Hours_Per_Day__c=5;
            es.Acceptance_Criteria__c='1';
            es.Assumptions__c='1';
            es.Out_of_Scope__c='1';
            es.Scope__c='1';
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
            es1.Created_By__c=hl.id;
            es1.Project_ID__c=initiative.id;
            es1.Revenue_Region__c='US';
            es1.Project_Billing_Type__c='Milestone';
            es1.Acceptance_Criteria__c='1';
            es1.Assumptions__c='1';
            es1.Out_of_Scope__c='1';
            es1.Scope__c='1';
            insert es1;
            
            List<Estimation_Risk_Description__c> estimationRDList= [SELECT CreatedById,CreatedDate,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Risk_Boundary__c,Risk_Description__c,SystemModstamp FROM Estimation_Risk_Description__c];
            
            string erd = '[{"RiskDescription":"Test","RiskBoundary":"Internal"}]';
            
            Estimation_Checklist__c ec=new Estimation_Checklist__c();
            ec.Estimation_Summary__c=es1.id;
            ec.Status__c='No';
            ec.Activities__c='Test Act';
            insert ec;
            
            
            Estimation_Summary__c es2=new Estimation_Summary__c();
            es2.Customer__c=accObj.id;
            es2.Work_Hours_Per_Day__c=3;
            es2.Project_ID__c=initiative.id;
            es2.Revenue_Region__c='US';
            es2.Project_Billing_Type__c='Milestone';
            es2.Created_By__c=hl.id;
            es2.Technical_Project_Manager__c=hl.id;
            es2.Status__c='Ready for Approval';
            es2.SME_Vertical__c=hl.id;
            es2.Approved_User_Track__c=hl.Full_Name__c;
            es2.Acceptance_Criteria__c='1';
            es2.Assumptions__c='1';
            es2.Out_of_Scope__c='1';
            es2.Scope__c='1';
            insert es2;
            
            //String replaceIllegal= res.getbody().replaceAll('\n','').replaceAll('\r','');
            //Map<String,Object> responsemap = (Map<String,Object>)JSON.deserializeUntyped(replaceIllegal);
            Test.startTest();
            CreateEstimationSummaryController.getNotApproverUser(es2.id);
            CreateEstimationSummaryController.getCSMNameList(accObj.id,odsSrv.id);
            CreateEstimationSummaryController.getCustomerList();
            //CreateEstimationSummaryController.getValidationForApprovedBy(es1.id);
            //CreateEstimationSummaryController.getCurrentLoggedUser(es1.id);
            CreateEstimationSummaryController.getInitiativesList(accObj.id, odsSrv.id);
            CreateEstimationSummaryController.getSummaryCreatedDate(es1.id);
            CreateEstimationSummaryController.getInitiativeDetails(initiative.id);
            CreateEstimationSummaryController.getRiskBoundaryPickListValue();
            CreateEstimationSummaryController.getEstimatedSummeryRecord(es1.id);
            CreateEstimationSummaryController.insertInsertRDList(erd, es1.id);
            CreateEstimationSummaryController.getRiskDescriptionList(es1.id); 
            CreateEstimationSummaryController.clearStatusToMakeEdit(es1.id);
            CreateEstimationSummaryController.validationOnCheckList(es1.id);
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');
            
            
            Test.stopTest();
        }
    }
}