@isTest
public class CreateEstimationInventoryControllerTest {
    @isTest
    public static void ComplexityMatrixListTest(){
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
            es.Status__c='Ready for Approval';
            insert es;
            
            Estimation_Detail__c esd=new Estimation_Detail__c();
            esd.Platform__c = 'Force.com';
            esd.Entity_Type__c = '3rd Party Integration';
            esd.Effort_Type__c = 'Declarative';
            esd.Complexity__c = 'Simple';
            esd.Estimation_Summary__c = es.id;
            insert esd;
            
            list<Estimation_Detail__c> getEstimationDetail=[SELECT Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Recommended_Effort__c,RecordTypeId 
                                                            FROM Estimation_Detail__c WHERE Platform__c=:esd.Platform__c AND Entity_Type__c=:esd.Entity_Type__c AND Effort_Type__c=:esd.Effort_Type__c AND Complexity__c=:esd.Complexity__c AND RecordTypeId=:esd.RecordTypeId and Estimation_Summary__c=:es.Id and Project_Specfic_Effort__c !=null LIMIT 1];
            string res = JSON.serialize(getEstimationDetail);
            
            List<object> objList = (List<object>)json.deserializeUntyped('[{"PlatformValue":"Force.com","EntityTypeValue":"Dashboard","EffortTypeValue":"Programming","ComplexityValue":"Complex","RecommendedEffortValue":"2.0","QuantityValue":"1"},{"PlatformValue":"Force.com","EntityTypeValue":"Dashboard","EffortTypeValue":"Programming","ComplexityValue":"Complex","QuantityValue":"1"}]');
            string ress = JSON.serialize(objList);
            
            Test.startTest();
            CreateEstimationInventoryController.getComplexityPickListValue();
            CreateEstimationInventoryController.getEffortTypePickListValue();
            CreateEstimationInventoryController.getExistEstimationDetailForInventory(es.id);
            CreateEstimationInventoryController.getRecommendedEffortHours(esd.Platform__c, esd.Entity_Type__c,esd.Effort_Type__c, esd.Complexity__c, esd.Estimation_Summary__c);
            CreateEstimationInventoryController.insertInventoryRecords(ress, es.Id);
            CreateEstimationInventoryController.getRecordTypeIdForInventory();
            CreateEstimationInventoryController.checkExistRecordCount(es.Id);
            CreateEstimationInventoryController.checkEstimationIsApproved(es.Id);
            CreateEstimationInventoryController.getStatusResult(es.Id);
            system.assertEquals( es.Status__c,'Ready for Approval');
            Test.stopTest();
        }
    }
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
            initiative.Technical_Project_Manager__c='Lokesh Rekapalli';
            update initiative;
            system.debug('usrObj-'+usrObj.Name);
            
            Estimation_Summary__c es1=new Estimation_Summary__c();
            es1.Customer__c=accObj.id;
            es1.Work_Hours_Per_Day__c=3;
            es1.Project_ID__c=initiative.id;
            es1.Revenue_Region__c='US';
            es1.Project_Billing_Type__c='Milestone';
            es1.Created_By__c=hl.id;
            es1.Technical_Project_Manager__c=hl.id;
            insert es1;
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
            insert es2;
            
            CreateEstimationInventoryController.validationForApproverButton(es2.Id);
            system.assertEquals( es1.Technical_Project_Manager__c,hl.id);

        }
    }
}