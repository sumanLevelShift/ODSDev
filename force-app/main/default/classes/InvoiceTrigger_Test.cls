@isTest
public class InvoiceTrigger_Test
{    
    static TestMethod void InsertInvoice_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8', 'Indumathi',
                    'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 
                    'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {       
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                            portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSSQL');
            //first loop                 
            Invoice__c inv1 = new  Invoice__c();
                inv1.Account_Services__c = accSrvc.Id;
                inv1.Attachment_File__c = 'testing1';
                inv1.Attachment_Id__c = 'xyz';
                inv1.Comments__c = 'testing1';                
                inv1.Invoice_ID__c = 'something';
                //inv1.Invoice_Number__c //Populated by trigger
                inv1.Year__c = system.today().year();
             
            insert inv1;
            
            //second loop
            portalAccount1.ODS_Invoice_Mth__c = system.today().month();
            Invoice__c inv2 = new  Invoice__c();
                inv2.Account_Services__c = accSrvc.Id;
                inv2.Attachment_File__c = 'testing2';
                inv2.Attachment_Id__c = 'xyz';
                inv2.Comments__c = 'testing2';                
                inv2.Invoice_ID__c = 'something';
                inv2.Year__c = system.today().year();
             
            insert inv2;
            
            //third loop
            portalAccount1.ODS_Invoice_Mth__c = system.today().month()-1;
            Invoice__c inv3 = new  Invoice__c();
                inv3.Account_Services__c = accSrvc.Id;
                inv3.Attachment_File__c = 'testing3';
                inv3.Attachment_Id__c = 'xyz';
                inv3.Comments__c = 'testing3';                
                inv3.Invoice_ID__c = 'something';
                inv3.Year__c = system.today().year();
             
            insert inv3;
        }
    } 
}