/*****************************************************************************************
* @date             27-DEC-2017
* @Status           Developed
* @Class Name       AccountHandler_Test
* @description      This is test class for Account Handler class.
******************************************************************************************
 Version     Date           Team                    Comments
******************************************************************************************
* 1         Apr 2018        Mani&Team                  Initial Creation
******************************************************************************************/

/*@isTest
public class AccountHandler_Test 

{
    
    public static testMethod void testIntroMail()
    {
        test.startTest();
       
        
        Account acc = [SELECT Id,Name,isSentIntroductionMail__c, CheckIntroDuplicate__c, TriggerKickoffMail__c FROM Account WHERE Name = :'DemandBlue Customer Success Manager' ];
        acc.isSentIntroductionMail__c=false;
        acc.CheckIntroDuplicate__c=false;
        acc.TriggerKickoffMail__c=false;
        update acc;
        test.stopTest();  
    }
    
    public static testMethod void testEnvironmentalAccess()
    {
        test.startTest();
        
        Account acc = [SELECT Id,Name,kickoff__c FROM Account WHERE Name = :'DemandBlue Customer Success Manager'];
        acc.Kickoff__c='Completed';
        update acc;
        test.stopTest();  
    }
    
    public static testMethod void testOnboardingAccess()
    {
        test.startTest();
        
        Account acc = [SELECT Id,Name,kickoff__c, Environment_Access__c, IsEnvironmentAccessEmail__c,IsInitialEstEmailSent__c, isOnboardingDocumentationEmailSent__c FROM Account WHERE Name = :'DemandBlue Customer Success Manager'];
        acc.Environment_Access__c='Completed';
        acc.IsEnvironmentAccessEmail__c = true;
        acc.IsInitialEstEmailSent__c=true;
        acc.Kickoff__c='Completed';
        acc.isOnboardingDocumentationEmailSent__c=false;
        update acc;
        test.stopTest();   
    }
    
    public static testMethod void testLightningReadinessAccess()
    {
        test.startTest();
       
        Account acc = [SELECT Id,Name,kickoff__c, Environment_Access__c, IsEnvironmentAccessEmail__c,IsInitialEstEmailSent__c, isOnboardingDocumentationEmailSent__c, Onboarding_Document__c FROM Account WHERE Name = :'DemandBlue Customer Success Manager'];
        acc.Environment_Access__c='Completed';
        acc.IsEnvironmentAccessEmail__c = true;
        acc.IsInitialEstEmailSent__c=true;
        acc.Kickoff__c='Completed';
        acc.isOnboardingDocumentationEmailSent__c=true;
        acc.Onboarding_Document__c='Approved';
        update acc;
        test.stopTest();     
    }
    }*/
    
    
    
    
@isTest
public class AccountHandler_Test 
{
  public static testMethod void positivetest(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');

       User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('mytest','testuser@testmail.com', 'UTF-8','Indumathi6', 'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'ezre@preludesys.com','Practice Head', true);
user u = new user(lastname = 'test787');
        Account acc = ODS_DataFactory_Test_Utility.InsertAccountforIntroAndKickoffMailHandler('TesttoAccount',usrObj.id,'Fully Executed',system.today(),10000,'7665233156','Others','ODS Project',True, 'Customer',True,'Completed',false,'Completed',True,True,false,'In Progress',false,false,'ODS');
       
        Contact con = ODS_DataFactory_Test_Utility.InsertContactforcreatechilds('Test','Contact','1: Calling',acc.Id,'Maharaja0393@gmail.com'); 
        acc.Primary_Customer_Contact__c = con.id;
        //acc.isSentIntroductionMail__c=false;
    
        ODS_Services__c ods = new ODS_Services__c(Name__c = 'Salesforce', Description__c = 'Test salesforce' , Active__c = true);
        insert ods; 
        
        
        /*acc.isSentIntroductionMail__c=false;
        acc.CheckIntroDuplicate__c=false;
        acc.TriggerKickoffMail__c=false;
        update acc;
        acc.SOW__c = 'Fully Executed';
        acc.Primary_Customer_Contact__c = con.id;
        acc.CheckIntroDuplicate__c= false;
        acc.User__c=usrObj.id;
        acc.isSentIntroductionMail__c= false;
        acc.TriggerKickoffMail__c= false;
        acc.Customer_Engagement_Type__c='ODS';
        acc.Account_Status__c ='Customer';
        update acc;*/
        
         Account acct = ODS_DataFactory_Test_Utility.Fetchaccounthandler(acc.Name);
        acct.SOW__c = 'Fully Executed';
        acct.Primary_Customer_Contact__c = con.id;
        acct.CheckIntroDuplicate__c= false;
        acct.User__c=usrObj.id;
        acct.isSentIntroductionMail__c= false;
        acct.TriggerKickoffMail__c= false;
        acct.Customer_Engagement_Type__c='ODS';
        acct.Account_Status__c ='Customer';
        system.debug('%%%%%%%%%%%%'+acct);
        update acct;
}
}