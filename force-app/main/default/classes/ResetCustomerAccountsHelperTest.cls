@isTest
public class ResetCustomerAccountsHelperTest {
    
    @isTest
    static void resetCustomerDetailsTest() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account acc = new Account();
            acc.Name = 'Test';
            acc.BillingCity = 'California';
            acc.Is_Portal_Access__c = true;
            acc.AnnualRevenue = 2000;
            acc.Phone = '9433578865';
            acc.Lead_Gen_Name__c = 'Others';
            acc.If_Others_Please_Specify__c = 'ODS Project';
            acc.NumberofEmployees = 100;
            acc.Industry = 'Technology';
            acc.Force_com_Account_Status__c = '7a: Customer - No Longer';
            insert acc;            
            
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, acc.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = acc.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas;
            acc.Force_com_Account_Status__c = '7: Customer';
            update acc;
        }        
    }
}