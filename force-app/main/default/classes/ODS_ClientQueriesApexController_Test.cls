/* @description      This is the test class for LWC migraton of client Query controller.
	 */
@isTest
public class ODS_ClientQueriesApexController_Test {
    static testMethod void fetchQueryBySlctdId_PositiveTest(){
        Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
								UserInfo.getUserId(), True, 1000, '9665344778', 'Others', 'ODS Project');     
			Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
			Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
			//fetch system admin profile
			Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
			User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty', 
							'en_US', 'en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
							'test12345@test.com', contact1.Id, 'Customer');
			//Insert user
			User usrObj1 = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
						'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
						'test123@testmail.com','Practice Head', true); 
			
			ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
			User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',
														usrObj1.Id,odsSrv.Id);
			date strtDt =  Date.today();
			date endDt = strtDt.adddays(5);
			Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt, 150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'DYDOTNET');
							
				
			ClientQueries__c objClientQueries  = ODS_DataFactory_Test_Utility.insertClientQueries(portalAccount1.Id, 
										accSrvc.Id, user1.Email,  user1.Name, 'What are new services available?',
										system.Today(), odsSrv.Id, accSrvc.Technical_Account_manager__r.Email,
										accSrvc.Technical_Account_manager__c );
			
			//Insert an internal user
			User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
						'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
						'test123@testmail.com','Practice Head', true); 
        
        
        	System.runAs (usrObj) 
			{        
				test.startTest();
                //date strDt =  Date.today();
				PageReference pageRef = Page.clientQuery;
				Test.setCurrentPage(pageRef);
				pageRef.getParameters().put('AccountId', portalAccount1.Id);
				pageRef.getParameters().put('ServiceId', odsSrv.Id);

				ODS_ClientQueriesApexController objclientQuery = new ODS_ClientQueriesApexController();
				objclientQuery.AccountId = portalAccount1.Id;
				objclientQuery.ServiceId = odsSrv.Id;
				ODS_ClientQueriesApexController.GetAllAccounts();
                ODS_ClientQueriesApexController.GetAllServices();
                ODS_ClientQueriesApexController.formatDate('2021-10-01');
                ODS_ClientQueriesApexController.GetQueriesByUserId(portalAccount1.Id, odsSrv.Id, '2021-10-01', '2021-11-01');
                ODS_ClientQueriesApexController.updateSessionData(portalAccount1.Id, odsSrv.Id);
				test.stopTest();
			} 
    }
    
    
    static testMethod void fetchQuery_PositiveTest()
		{
			Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
								UserInfo.getUserId(), True, 2000, '8866466894', 'Others', 'ODS Project');     
			Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
			Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
			User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
							'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
							'test12345@test.com', contact1.Id,'Customer');
			//fetch system admin profile
			Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
			
			//Insert user
			User usrObj1 = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
						'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
						'test123@testmail.com','Practice Head', true);  
			
			ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
			User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager', usrObj1.Id,odsSrv.id);
			date strtDt =  Date.today();
			date endDt = strtDt.adddays(5);
			Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt, 150.0, odsSrv.id, 1000, 'Monthly', usrAcc.user__C, 'PCDOTNET');
							
				
			ClientQueries__c objClientQueries  = ODS_DataFactory_Test_Utility.insertClientQueries(portalAccount1.Id, accSrvc.Id, user1.Email,  user1.Name, 'What are new services available?',
										system.Today(), odsSrv.Id, accSrvc.Technical_Account_manager__r.Email,
										accSrvc.Technical_Account_manager__c );
			ClientQueries__c objClientQueries2  = ODS_DataFactory_Test_Utility.insertClientQueries(portalAccount1.Id, 
										accSrvc.Id, user1.Email,  user1.Name, 'How status reports are sending to TAM?',
										system.Today(), odsSrv.Id, accSrvc.Technical_Account_manager__r.Email,
										accSrvc.Technical_Account_manager__c );       
			
			//Insert an internal user
			User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
						'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
						'test123@testmail.com','Practice Head', true); 
			System.runAs (usrObj) 
			{        
				test.startTest();
				PageReference pageRef = Page.clientQuery;
				Test.setCurrentPage(pageRef);
				pageRef.getParameters().put('AccountId', 'All');
				pageRef.getParameters().put('ServiceId', 'All');

				ODS_ClientQueryController objclientQuery = new ODS_ClientQueryController();
				//objclientQuery.AccountId = 'All';
				//objclientQuery.ServiceId = 'All';
                ODS_ClientQueriesApexController.GetQueriesByUserId('All','All', '2021-10-01', '2021-11-01');
				

				test.stopTest();
			}                   
		}

}