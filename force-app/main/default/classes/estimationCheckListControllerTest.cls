@isTest
public class estimationCheckListControllerTest {
    
    @isTest
    Public static void CheckListTest(){
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
            
            Estimation_Summary__c es1=new Estimation_Summary__c();
            es1.Customer__c=acc.id;
            es1.Revenue_Region__c='India';
            es1.Project_Billing_Type__c='T&M';
            es1.Created_By__c=hl.id;
            es1.Work_Hours_Per_Day__c=8;
            insert es1;
            
            Estimation_Checklist__c checklist = new Estimation_Checklist__c();
            checklist.Remarks__c = 'test';
            checklist.Check__c = true;
            checklist.Activities__c ='new test';
            checklist.S_No__c= 1;
            checklist.Status__c='Yes';
            checklist.Estimation_Summary__c = es.id;
            checklist.Required__c =  True;
            insert checklist;
            
            Estimation_Checklist__c checklist1 = new Estimation_Checklist__c();
            checklist1.Remarks__c = 'test';
            checklist1.Check__c = true;
            checklist1.Activities__c ='new tests';
            checklist1.S_No__c= 1;
            checklist1.Status__c='Yes';
            checklist1.Estimation_Summary__c = es1.id;
            checklist1.Required__c =  True;
            insert checklist1;
            
            List<Estimation_Checklist_REF__mdt > getcList=[SELECT Active__c,Activities__c,DeveloperName,Entity_Type__c,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM Estimation_Checklist_REF__mdt where Active__c=true];
            system.debug('getcList'+getcList);
            // List<object> objList = (List<object>)json.deserializeUntyped('[{"CHECK":true,"CHECKLISTID":"'+getcList[0].id+'","STATUS":"No","REMARKS":"Test","sno":"Yes","sno":"Yes"},{"CHECK":false,"CHECKLISTID":"'+getcList[1].id+'","STATUS":"Yes","REMARKS":"Test","Activities":"'+getcList[1].Activities__c+'"},{"CHECK":false,"CHECKLISTID":"'+getcList[2].id+'","STATUS":"Yes","REMARKS":"Test","sno":"Yes","Activities":"'+getcList[1].Activities__c+'"}]');
            //string ress = JSON.serialize(objList);
            
            string res='[{"CheckListIdCM":"'+getcList[0].id+'","SNO":2,"Status":true,"RemarkTextArea":"Test","CHECKLISTID":"'+getcList[1].Id+'"},{"CheckListIdCM":"'+getcList[0].id+'","SNO":4,"Status":true,"RemarkTextArea":"Tests","CHECKLISTID":"'+getcList[2].Id+'"}]';
            Test.startTest();
            
            estimationCheckListController.insertInsertCheckList(res, es.id);
            system.assertEquals(checklist1.Status__c,'Yes');
            
            Test.stopTest();
        }
    }
    @isTest
    Public static void CheckListTestinsert(){
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
            
            Estimation_Summary__c es1=new Estimation_Summary__c();
            es1.Customer__c=acc.id;
            es1.Revenue_Region__c='India';
            es1.Project_Billing_Type__c='T&M';
            es1.Created_By__c=hl.id;
            es1.Work_Hours_Per_Day__c=8;
            insert es1;
            
            Estimation_Checklist__c checklist = new Estimation_Checklist__c();
            checklist.Remarks__c = 'test';
            checklist.Check__c = true;
            checklist.Activities__c ='new test';
            checklist.S_No__c= 1;
            checklist.Status__c='Yes';
            checklist.Estimation_Summary__c = es.id;
            checklist.Required__c =  True;
            insert checklist;
            Estimation_Checklist__c checklist1 = new Estimation_Checklist__c();
            checklist1.Remarks__c = 'testssdwde';
            checklist1.Check__c = true;
            checklist1.Activities__c ='new testcscs';
            checklist1.S_No__c= 2;
            checklist1.Status__c='Yes';
            checklist1.Estimation_Summary__c = es.id;
            checklist1.Required__c =  True;
            insert checklist1;
            List<Estimation_Checklist__c > getcList=[SELECT Activities__c,Check__c,CreatedById,CreatedDate,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Remarks__c,Required__c,Status__c,SystemModstamp,S_No__c FROM Estimation_Checklist__c where Estimation_Summary__c =: es.id];
            system.debug('getcList!!!'+getcList);
            List<Estimation_Checklist_REF__mdt > getecList=[SELECT Active__c,Activities__c,DeveloperName,Entity_Type__c,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM Estimation_Checklist_REF__mdt where Active__c=true];
            
            string res='[{"CheckListId":"'+checklist1.id+'","Status":true,"RemarkTextArea":"new test","CHECKLISTID":"'+checklist1.Id+'"},{"CheckListId":"'+checklist.id+'","Status":true,"RemarkTextArea":"Tested","CHECKLISTID":"'+checklist.Id+'"}]';
            
            Test.startTest();
            
            estimationCheckListController.updateCheckList(res, es.id);
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');
            
            Test.stopTest();
        }
    }
    @isTest
    Public static void CheckListTestv1(){
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
            Estimation_Checklist__c checklist1 = new Estimation_Checklist__c();
            checklist1.Remarks__c = 'Have you considered all the impacts of existing data due to data migration or data update?';
            checklist1.Check__c = true;
            checklist1.Activities__c ='Have you considered all the impacts of existing data due to data migration or data update?';
            checklist1.S_No__c= 2;
            checklist1.Status__c='Yes';
            checklist1.Estimation_Summary__c = es.id;
            checklist1.Required__c =  True;
            insert checklist1;
            //List<Estimation_Checklist_REF__mdt > getcList=[SELECT Active__c,Activities__c,DeveloperName,Entity_Type__c,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM Estimation_Checklist_REF__mdt where Active__c=true];
            // string erd = JSON.serialize(getcList);
            // string res='[{"CHECK":true,"CHECKLISTID":"'+getcList[0].id+'","STATUS":"No","REMARKS":"Test"},{"CHECK":false,"CHECKLISTID":"'+getcList[1].id+'","STATUS":"Yes","REMARKS":"Test"},{"CHECK":false,"CHECKLISTID":"'+getcList[2].id+'","STATUS":"Yes","REMARKS":"Test"}]';
            Test.startTest();
            estimationCheckListController.getCheckListRecord(es.id);
            estimationCheckListController.getCheckList(es.id);
            system.assertEquals(es.Created_By__c,hl.id);
            Test.stopTest();
        }
    }
    
}