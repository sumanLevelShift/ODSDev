@isTest
public class oDSEstimationSummaryViewPage_Test {
    @isTest
    public static void estimateSummaryTest(){
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
            
            Estimation_Summary__c es1=new Estimation_Summary__c();
            es1.Customer__c=acc.id;
            es1.Revenue_Region__c='US';
            es1.Project_Billing_Type__c='Milestone';
            es1.Created_By__c=hl.id;
            es1.Work_Hours_Per_Day__c=5;
            insert es1;
            
            Estimation_Summary__c es2=new Estimation_Summary__c();
            es2.Customer__c=acc.id;
            es2.Revenue_Region__c='US';
            es2.Project_Billing_Type__c='Milestone';
            es2.Created_By__c=hl.id;
            es2.Work_Hours_Per_Day__c=5;
            insert es2;
            
            Estimation_Summary__c es3=new Estimation_Summary__c();
            es3.Customer__c=acc.id;
            es3.Revenue_Region__c='US';
            es3.Project_Billing_Type__c='Milestone';
            es3.Created_By__c=hl.id;
            es3.Work_Hours_Per_Day__c=5;
            insert es3;
            
            Test.startTest();
            oDSEstimationSummaryViewPageController.getEstimationSummaryRecords(acc.id,1,1);
            oDSEstimationSummaryViewPageController.updateSessionData(acc.id,odsSrv.id );
            oDSEstimationSummaryViewPageController.deleteEstimationSummaryRecords(es.id);
            oDSEstimationSummaryViewPageController.getcurrentUserAccessForEstimation();
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');
            Test.stopTest();
        }
    }
}