@isTest
public class onboardingWordDocControllerTest {
    @isTest
    public static void batchJob(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account accountObject = new Account(
            Name ='Demand Blue CLient1',
            Lead_Gen_Name__c = 'Others',             
            Industry = 'Hospitality',
            Onboarding_Document__c='Not Started'
        );
        insert accountObject;
        onboardingWordDocController.getExternalData(accountObject.id);
        
    }
    @isTest
    public static void onBoardingMethod(){
        
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            ODS_Data_Utility odsUtil = new ODS_Data_Utility(null);
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('Salesforce','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Partner';            
            update usrAcc;
            
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            
            
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'Salesforce');
            accSrvc.Invoice_Frequency__c = 'Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;
            OBD_External_Data__c od=new OBD_External_Data__c();
            od.Account__c=portalAccount1.id;
            od.API_Response__c='{"totalSize":0,"done":true,"records":[]}';
            od.Section_Name__c='Lead Assignment Rules';
            insert od;
            String base64Content = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
            
            Test.startTest();
            onboardingWordDocController.getCurrentAccount(portalAccount1.id);
            onboardingWordDocController.getExternalData(portalAccount1.id);
            onboardingWordDocController.uploadFile(base64Content, portalAccount1.Name+'_OnBoarding_Document', portalAccount1.id);
            onboardingWordDocController.uploadFile(base64Content, portalAccount1.Name+'_OnBoarding_Document', portalAccount1.id);
            onboardingWordDocController.checkActiveAccount(portalAccount1.Id);
            Test.stopTest();
        }
    }
}