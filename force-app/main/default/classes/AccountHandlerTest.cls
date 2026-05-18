@isTest(seeAllData=true)
public class AccountHandlerTest {
   public static testMethod void testIntroMailSB()
    {
        test.startTest();
        Account acc = [SELECT Id,Name,isSentIntroductionMail__c,Industry,CheckIntroDuplicate__c, TriggerKickoffMail__c,IsInitialEstEmailSent__c,Small_Business__c FROM Account WHERE Name = :'Demandblue Deployment Record'];
        acc.isSentIntroductionMail__c=false;
        acc.CheckIntroDuplicate__c=false;
        acc.TriggerKickoffMail__c=false;
        acc.IsInitialEstEmailSent__c=false;
        acc.Small_Business__c=true;
        update acc;
        test.stopTest();  
    } 
    public static testMethod void testIntroMail()
    {
        test.startTest();
        Account acc = [SELECT Id,Name,isSentIntroductionMail__c,Industry,CheckIntroDuplicate__c, TriggerKickoffMail__c,IsInitialEstEmailSent__c FROM Account WHERE Name = :'Demandblue Deployment Record'];
        acc.isSentIntroductionMail__c=false;
        acc.CheckIntroDuplicate__c=false;
        acc.TriggerKickoffMail__c=false;
        acc.IsInitialEstEmailSent__c=false;
        update acc;
        test.stopTest();  
    }
    
	public static testMethod void testIntroMailSentKickoff()
    {
        test.startTest();
        Account acc = [SELECT Id,Name,Industry,kickoff__c,IsEnvironmentAccessEmail__c,IsInitialEstEmailSent__c,isSentIntroductionMail__c,CheckIntroDuplicate__c,TriggerKickoffMail__c FROM Account WHERE Name = :'Demandblue Deployment Record'];
        acc.isSentIntroductionMail__c=true;
        acc.CheckIntroDuplicate__c=false;
        acc.TriggerKickoffMail__c=true;
        acc.IsEnvironmentAccessEmail__c = false;
        acc.IsInitialEstEmailSent__c = false;
        acc.Kickoff__c = 'Completed';
        update acc;
        test.stopTest();  
    }
    
    public static testMethod void testEnvironmentalAccess()
    {
        test.startTest();
        Account acc = [SELECT Id,Name,kickoff__c,Industry,Environment_Access__c, IsEnvironmentAccessEmail__c,IsInitialEstEmailSent__c, isOnboardingDocumentationEmailSent__c FROM Account WHERE Name = :'Demandblue Deployment Record'];
        acc.IsEnvironmentAccessEmail__c = false;
        acc.IsInitialEstEmailSent__c=false;
        acc.Kickoff__c='Completed';
        update acc;
        test.stopTest();   
    }
    
    public static testMethod void testOnboardingAccess()
    {
        test.startTest();
        Account acc = [SELECT Id,Name,kickoff__c,Industry,Environment_Access__c, IsEnvironmentAccessEmail__c,IsInitialEstEmailSent__c, isOnboardingDocumentationEmailSent__c FROM Account WHERE Name = :'Demandblue Deployment Record'];
        acc.Environment_Access__c='Completed';
        acc.IsEnvironmentAccessEmail__c = true;
        acc.IsInitialEstEmailSent__c=true;
        acc.Kickoff__c='Completed';
        update acc;
        test.stopTest();   
    }    
    
    public static testMethod void testLightningReadinessAccess()
    {
        date startDate=date.today();
        test.startTest();
        Account acc = [SELECT Id,Name,kickoff__c,Account_Status__c, Environment_Access__c, IsEnvironmentAccessEmail__c,IsInitialEstEmailSent__c, isOnboardingDocumentationEmailSent__c, Onboarding_Document__c FROM Account WHERE Name = :'Demandblue Deployment Record'];
        Account_Services__c Accser =[SELECT Timesheet_Start_Date__c,ID,Contract_Start_Date__c,Technical_Account_manager__r.Name,Account__c,Account__r.Kickoff__c,Account__r.KickOff_Completed_Date__c,Account__r.Name from Account_Services__c  Where Account__c = :Acc.Id];
        Accser.Contract_Start_Date__c=startDate.addDays(-5);
        Accser.Timesheet_Start_Date__c=startDate.addDays(-5);
        update Accser;
        acc.Environment_Access__c='Completed';
        acc.IsEnvironmentAccessEmail__c = true;
        acc.IsInitialEstEmailSent__c=true;
        acc.Kickoff__c='Completed';
        acc.isOnboardingDocumentationEmailSent__c=true;
        acc.Onboarding_Document__c='Approved';
        update acc;
        test.stopTest();     
    }
    

}