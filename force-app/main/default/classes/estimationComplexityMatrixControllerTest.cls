@isTest
public class estimationComplexityMatrixControllerTest {
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
            
            insert es;
            
            Estimation_Detail__c esd=new Estimation_Detail__c();
            esd.Platform__c = 'Force.com';
            esd.Entity_Type__c = '3rd Party Integration';
            esd.Effort_Type__c = 'Declarative';
            esd.Complexity__c = 'Simple';
            esd.Estimation_Summary__c = es.id;
            
            insert esd;
            
            Estimation_Detail__c esd1=new Estimation_Detail__c();
            esd1.Platform__c = 'Force.com';
            esd1.Entity_Type__c = '3rd Party Integration';
            esd1.Effort_Type__c = 'Declarative';
            esd1.Complexity__c = 'Simple';
            esd1.Estimation_Summary__c = es.id;
            
            insert esd1;
            //List<Estimation_Detail__c> getEsDetailList=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,CreatedById,CreatedDate,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Platform__c,Project_Specfic_Effort__c,Quantity__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,SystemModstamp,S_No__c FROM Estimation_Detail__c];
            List<Estimation_Complexity_Matrix_REF__mdt> getECMList=[SELECT Complexity_Definition__c,Complexity__c,DeveloperName,Entity_Type__c,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM Estimation_Complexity_Matrix_REF__mdt ];
            List<Estimation_Detail__c> getEDList=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,CreatedById,CreatedDate,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Platform__c,Project_Specfic_Effort__c,Quantity__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,SystemModstamp,S_No__c FROM Estimation_Detail__c];
            string res='[{"ComplexityMatrixId":"'+getECMList[0].ID+'","SNO":1,"RevisedEffortValue":"2","RationalIfDifferentValue":"Tests","ComplexityId":"'+getECMList[0].Id+'"},{"ComplexityMatrixId":"'+getECMList[1].ID+'","SNO":2,"RevisedEffortValue":"3","RationalIfDifferentValue":"Tests","ComplexityId":"'+getECMList[1].Id+'"}]';
            
            Test.startTest();
            estimationComplexityMatrixController.getComplexityMatrixList(25,0);
            estimationComplexityMatrixController.getRecommendedEffortHour(esd.Platform__c, esd.Entity_Type__c,esd.Effort_Type__c, esd.Complexity__c, esd.Estimation_Summary__c);
            estimationComplexityMatrixController.getExistEstimationDetailForComplexityMatrix(es.Id,25,0);  
            
            //  estimationComplexityMatrixController.wrapComplexityMatrixList(es.id,'3rd Party Integration','Simple','test',2.1,3.1,1.2);
            estimationComplexityMatrixController.insertComplexityMatrix(res, es.Id);
            system.assertEquals(es.Created_By__c,hl.id);
            Test.stopTest();
        }
    }
    @isTest
    public static void ComplexityMatrixListTestinsert(){
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
            
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Customer__c=acc.id;
            es.Revenue_Region__c='US';
            es.Project_Billing_Type__c='Milestone';
            es.Created_By__c=hl.id;
            es.Work_Hours_Per_Day__c=5;
            
            insert es;
            String inventoryRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            
            Estimation_Detail__c esd=new Estimation_Detail__c();
            esd.Platform__c = 'Force.com';
            esd.Entity_Type__c = '3rd Party Integration';
            esd.Effort_Type__c = 'Declarative';
            esd.Complexity__c = 'Simple';
            esd.Estimation_Summary__c = es.id;
            esd.S_No__c = 1.0;
            esd.RecordTypeId = inventoryRecordTypeID;
            esd.Recommended_Effort__c = 2.0;
            insert esd;
            String inventoryRecordTypeID1 = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            
            Estimation_Detail__c esd1=new Estimation_Detail__c();
            esd1.Platform__c = 'Force.com';
            esd1.Entity_Type__c = '3rd Party Integration';
            esd1.Effort_Type__c = 'Declarative';
            esd1.Complexity__c = 'Simple';
            esd1.Estimation_Summary__c = es.id;
            esd1.S_No__c = 2.0;
            esd.Recommended_Effort__c = 1.5;
            esd1.RecordTypeId = inventoryRecordTypeID1;
            
            insert esd1;
            //List<Estimation_Detail__c> getEsDetailList=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,CreatedById,CreatedDate,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Platform__c,Project_Specfic_Effort__c,Quantity__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,SystemModstamp,S_No__c FROM Estimation_Detail__c];
            List<Estimation_Complexity_Matrix_REF__mdt> getECMList=[SELECT Platform__c,Complexity_Definition__c,Complexity__c,DeveloperName,Entity_Type__c,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM Estimation_Complexity_Matrix_REF__mdt ];
            List<Estimation_Detail__c> getEDList=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,CreatedById,CreatedDate,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Platform__c,Project_Specfic_Effort__c,Quantity__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,SystemModstamp,S_No__c FROM Estimation_Detail__c];
            
            string res='[{"ComplexityMatrixId":"'+getECMList[0].ID+'","SNO":1,"RevisedEffortValue":"2","RationalIfDifferentValue":"Tests","ComplexityId":"'+getECMList[0].Id+'"},{"ComplexityMatrixId":"'+getECMList[1].ID+'","SNO":2,"RevisedEffortValue":"3","RationalIfDifferentValue":"Tests","ComplexityId":"'+getECMList[1].Id+'"}]';
            
            Test.startTest();
            estimationComplexityMatrixController.getFilterComplexityMatrixFromcustomMetadata(getECMList[0].Entity_Type__c, getECMList[0].Platform__c,25,0);
            estimationComplexityMatrixController.getFilterComplexityMatrixFromcustomMetadata(null, getECMList[0].Platform__c,25,0);
            estimationComplexityMatrixController.getFilterComplexityMatrixFromcustomMetadata(null, null,25,0);
            estimationComplexityMatrixController.insertComplexityMatrix(res, es.Id);
            estimationComplexityMatrixController.getFilterComplexityMatrixFromEstDetails(es.Id, getECMList[0].Entity_Type__c, getECMList[0].Platform__c,25,0);
            estimationComplexityMatrixController.getFilterComplexityMatrixFromEstDetails(es.Id, null,null,25,0);
            estimationComplexityMatrixController.getFilterComplexityMatrixFromEstDetails(es.Id, null, getECMList[0].Platform__c,25,0);
            
            system.assertEquals(esd.RecordTypeId , inventoryRecordTypeID);

            Test.stopTest();
        }
    }
    @isTest
    public static void ComplexityMatrixListUpdateTest(){
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
            
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Customer__c=acc.id;
            es.Revenue_Region__c='US';
            es.Project_Billing_Type__c='Milestone';
            es.Created_By__c=hl.id;
            es.Work_Hours_Per_Day__c=5;
            insert es;
            
            String inventoryRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            
            Estimation_Detail__c inevntory=new Estimation_Detail__c();
            inevntory.Platform__c = 'Force.com';
            inevntory.Entity_Type__c = '3rd Party Integration';
            inevntory.Effort_Type__c = 'Declarative';
            inevntory.Complexity__c = 'Simple';
            inevntory.Estimation_Summary__c = es.id;
            inevntory.RecordTypeId = inventoryRecordTypeID;
            insert inevntory;
            
            String ComplexityRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Complexity Matrix').getRecordTypeId();
            
            
            Estimation_Detail__c esd=new Estimation_Detail__c();
            esd.Platform__c = 'Force.com';
            esd.Entity_Type__c = '3rd Party Integration';
            esd.Effort_Type__c = 'Declarative';
            esd.Complexity__c = 'Simple';
            esd.Estimation_Summary__c = es.id;
            esd.RecordTypeId = ComplexityRecordTypeID;
            
            insert esd;
            
            Estimation_Detail__c esd1=new Estimation_Detail__c();
            esd1.Platform__c = 'Force.com';
            esd1.Entity_Type__c = '3rd Party Integration';
            esd1.Effort_Type__c = 'Declarative';
            esd1.Complexity__c = 'Simple';
            esd1.Estimation_Summary__c = es.id;
            esd.RecordTypeId = ComplexityRecordTypeID;
            insert esd1;
            
            List<Estimation_Complexity_Matrix_REF__mdt> getECMList=[SELECT Complexity_Definition__c,Complexity__c,DeveloperName,Entity_Type__c,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM Estimation_Complexity_Matrix_REF__mdt ];
            List<Estimation_Detail__c> getEDList=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,CreatedById,CreatedDate,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Platform__c,Project_Specfic_Effort__c,Quantity__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,SystemModstamp,S_No__c FROM Estimation_Detail__c];
            string res='[{"EstimationDetailId":"'+esd.ID+'","RevisedEffortValue":"2","RationalIfDifferentValue":"Test"},{"EstimationDetailId":"'+esd1.ID+'","RevisedEffortValue":"2","RationalIfDifferentValue":"Tests"}]';
            
            Test.startTest();
            estimationComplexityMatrixController.updateComplexityMatrix(res, es.Id);
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');

            Test.stopTest();
        }
    }
    
}