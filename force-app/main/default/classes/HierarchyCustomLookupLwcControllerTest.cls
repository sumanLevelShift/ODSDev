@isTest
public class HierarchyCustomLookupLwcControllerTest {
    @isTest
    public static void customLookupCreateBy(){
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
        usrObj.Delivery_Role__c='Developer';
        update usrObj;
        
        System.runAs (usrObj) 
        {   
            Hierarchy_Lookup__c hl=new Hierarchy_Lookup__c();
            hl.First_Name__c='Lokesh';
            hl.Last_Name__c='Rekapalli';
            hl.Email_Address__c='sfadmin@demandblue.com';
            hl.Delivery_Role__c='TPM/SME';
            hl.IsActive__c=true;
            insert hl;
            Hierarchy_Lookup__c h2=new Hierarchy_Lookup__c();
            h2.First_Name__c='Vinoth';
            h2.Last_Name__c='Kanna';
            h2.Email_Address__c='sfadmin@demandblue.com';
            h2.Delivery_Role__c='Program Manager';
            h2.IsActive__c=true;
            insert h2;
            HierarchyCustomLookupLwcController.fetchLookupData('Lokesh', 'Hierarchy_Lookup__c', 'createBy');

            
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');
        }
    }
    @isTest
    public static void customLookup(){
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
            hl.IsActive__c=true;
            insert hl;
            Hierarchy_Lookup__c h2=new Hierarchy_Lookup__c();
            h2.First_Name__c='Vinoth';
            h2.Last_Name__c='Kanna';
            h2.Email_Address__c='sfadmin@demandblue.com';
            h2.Delivery_Role__c='Program Manager';
            h2.IsActive__c=true;
            insert h2;
            HierarchyCustomLookupLwcController.fetchLookupData('Lok', 'Hierarchy_Lookup__c', 'TPM/SME');
            HierarchyCustomLookupLwcController.fetchLookupData('Vino', 'Hierarchy_Lookup__c', 'PM');
            
            HierarchyCustomLookupLwcController.fetchDefaultRecord(hl.id, 'Hierarchy_Lookup__c');
            HierarchyCustomLookupLwcController.fetchDefaultRecord('', 'Hierarchy_Lookup__c');
            
            system.assertEquals(hl.Delivery_Role__c,'TPM/SME');
        }
    }
}