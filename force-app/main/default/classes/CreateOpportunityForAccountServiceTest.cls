/**
* @author           Harish Sankaran
* @version          1.0 
* @date             13-April-2021
* @Status           Inprogress
* @description      This Test class for creating an Renewal Opportunity for the accounts
60 days before the contract end date and also creating a task 
*
*/


@isTest
public class CreateOpportunityForAccountServiceTest 
{


    static testMethod void test() 
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);  
        User portalAccountOwner2 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','TestAccount',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test1234@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            string getcontractRenewalDays = label.Contract_Renewal_Days;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                         portalAccountOwner1.Id, True,1000,'95543567654','Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            //Insert Project Team Member
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            
            date strtDt =  Date.today();
            
            date endDt = strtDt.adddays(integer.valueOf(getcontractRenewalDays));
            date aprveDt = strtDt.adddays(6);

            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'PCSQL');
            
            
            Test.startTest();
            CreateOpportunityForAccountService obj = new CreateOpportunityForAccountService();
            DataBase.executeBatch(obj);
            Account_Services__c aService=[SELECT CRRDays__c,Id FROM Account_Services__c WHERE ID=:accSrvc.id];
           	system.assertEquals(aService.CRRDays__c,integer.valueOf(getcontractRenewalDays));
            Test.stopTest();

        }
    }
}