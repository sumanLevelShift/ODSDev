@isTest
public class EstimationSummaryDetailsPageContrlTest {
    @isTest
    Public static void CheckListTest(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        portalAccountOwner1.FirstName='Lokesh';
        portalAccountOwner1.LastName='Rekapalli';
        portalAccountOwner1.Delivery_Role__c='TPM/SME';
        
        update portalAccountOwner1;
        System.runAs (portalAccountOwner1) 
        {
            Hierarchy_Lookup__c hl=new Hierarchy_Lookup__c();
            hl.First_Name__c='Lokesh';
            hl.Last_Name__c='Rekapalli';
            hl.Email_Address__c='sfadmin@demandblue.com';
            hl.Delivery_Role__c='TPM/SME';
            insert hl;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            
            
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Customer__c=portalAccount1.id;
            es.Revenue_Region__c='US';
            es.Project_Billing_Type__c='Milestone';
            es.Created_By__c=hl.id;
            es.Work_Hours_Per_Day__c=5;
            insert es;
            
            Test.startTest();
            EstimationSummaryDetailsPageContrl.getCustomerNamedetails(es.Id);
            EstimationSummaryDetailsPageContrl.getEstimatedSummeryRecord(es.Id);
            EstimationSummaryDetailsPageContrl.getInitiativesList(portalAccount1.id, odsSrv.id);
            EstimationSummaryDetailsPageContrl.checkInventorySize(es.Id);
            system.assertEquals(es.Customer__c,portalAccount1.id);
            Test.stopTest();
        }
    }
    @isTest
    Public static void CheckListTestsession(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        portalAccountOwner1.FirstName='Lokesh';
        portalAccountOwner1.LastName='Rekapalli';
        portalAccountOwner1.Delivery_Role__c='TPM/SME';
        
        update portalAccountOwner1;
        System.runAs (portalAccountOwner1) 
        {
            Hierarchy_Lookup__c hl=new Hierarchy_Lookup__c();
            hl.First_Name__c='Lokesh';
            hl.Last_Name__c='Rekapalli';
            hl.Email_Address__c='sfadmin@demandblue.com';
            hl.Delivery_Role__c='TPM/SME';
            insert hl;
            Account acc=New Account();
            acc.Name='Test account';
            acc.Lead_Gen_Name__c = 'Others';
            insert acc;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Customer__c=acc.id;
            es.Revenue_Region__c='US';
            es.Project_Billing_Type__c='Milestone';
            es.Created_By__c=hl.id;
            es.Work_Hours_Per_Day__c=5;
            insert es;
            
            Test.startTest();
            EstimationSummaryDetailsPageContrl espc = new EstimationSummaryDetailsPageContrl();
            espc.updateSessionData();
            EstimationSummaryDetailsPageContrl.updateWithRisk(es.id, 0.7);
            system.assertEquals(portalAccountOwner1.Delivery_Role__c,'TPM/SME');
            Test.stopTest();
        }
    }
}