@isTest
public class ExportToInitiativeControllerTest {
    @isTest
    public static void ETITest(){
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
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Saved');
            
            Estimation_Summary__c es1=new Estimation_Summary__c();
            es1.Customer__c=accObj.id;
            es1.Work_Hours_Per_Day__c=3;
            es1.Project_ID__c=initiative.id;
            es1.Revenue_Region__c='US';
            es1.Project_Billing_Type__c='Milestone';
            es1.Created_By__c=hl.id;
            es1.Work_Days_Per_Week__c=2;
            es1.Work_Days_Per_Month__c=2;
            insert es1;
            
            String odsEstimateRecordTypeID = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('ODS Estimate').getRecordTypeId();
            
            Effort_Calculation__c ec=new Effort_Calculation__c();
            ec.SLDC_Phase_Name__c='Analysis';
            ec.RecordTypeId=odsEstimateRecordTypeID;
            ec.ODS_Estimate__c=es1.id;
            ec.Project_Specific_Effort_Hours__c=2;
            insert ec;
            String InventoryRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            
            Estimation_Detail__c ed=new Estimation_Detail__c();
            ed.Platform__c='Force.com';
            ed.Entity_Type__c='Action';
            ed.RecordTypeId=InventoryRecordTypeID;
            ed.Estimation_Summary__c=es1.id;
            ed.Project_Specfic_Effort__c=2;
            ed.Estimation_Element__c='dev';
            ed.Complexity__c='Simple';
            ed.Quantity__c=1;
            insert ed;
            
            ExportToInitiativeController.CheckInitiativeIsSavedOrNot(es1.id);
            ExportToInitiativeController.createEstimationElement(es1.id);
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');
        }
    }
}