/**************************************************************************************
* @Author       : Mani & Team
* @Status       : Deployed
* @Class Name   : ODS_ScheduledFollowupEmailBatch_Test
* @Description  : Test class for Follow up emails.            
***************************************************************************************
 Version     Date           Team                    Comments
***************************************************************************************
* 1          Apr 2018       Mani&Team               Initial Creation
***************************************************************************************/

@isTest(SeeAllData=true)
public class ODS_ScheduledFollowupEmailBatch_Test
{   
    public static testMethod void testOnBoarding() {
        String onboardQry = 'SELECT Id,Name,User__c,User__r.Email,Primary_Customer_Contact__c,Primary_Customer_Contact__r.Email'+ 
                            ' FROM Account WHERE Name =\'Test Account Mani and Team\'';
                            
        String onboardFld = 'onboardingDoc';
        
        Test.StartTest();
        ODS_OnboardLightnFollowUpEmailBacth onBoard = new ODS_OnboardLightnFollowUpEmailBacth(onboardQry,onboardFld); 
        ID batchprocessid = Database.executebatch(onBoard); 
        Test.StopTest();
                
       // Account updAcc = [SELECT Id,Name,isFollowedOnboardDoc__c FROM Account WHERE Name = :'Test Account Mani and Team'];
        //System.assertEquals(true, updAcc.isFollowedOnboardDoc__c, 'Email not sent');
    }
    
    public static testMethod void testLightnReady() {
        String lightnQry = 'SELECT Id,Name,User__c,User__r.Email,Primary_Customer_Contact__c,Primary_Customer_Contact__r.Email'+ 
                            ' FROM Account WHERE Name =\'Test Account Mani and Team\'';
                            
        String lightnFld = 'lightningReadiness';
        
        Test.StartTest();
        ODS_OnboardLightnFollowUpEmailBacth lightn = new ODS_OnboardLightnFollowUpEmailBacth(lightnQry,lightnFld);
        database.executebatch(lightn); 
        Test.StopTest();
                
        //Account updAcc = [SELECT Id,Name,isFollowedLightnReady__c FROM Account WHERE Name = :'Test Account Mani and Team'];
        //System.assertEquals(true, updAcc.isFollowedLightnReady__c, 'Email not sent');
    }
          
    public static testMethod void testEnvironAccess() {
        String EnvQry = 'SELECT Id,Name,User__c,User__r.Email,Primary_Customer_Contact__c,Primary_Customer_Contact__r.Email'+ 
                            ' FROM Account WHERE Name =\'Test Account Mani and Team\'';
                                         
        Test.StartTest();
        ODS_EnvironmentFollowUpEmailBacth b = new ODS_EnvironmentFollowUpEmailBacth(EnvQry); 
        database.executebatch(b); 
        Test.StopTest();
                
        //Account updAcc = [SELECT Id,Name,isFollowedEnvironmentAccess__c  FROM Account WHERE Name = :'Test Account Mani and Team'];
        //System.assertEquals(true, updAcc.isFollowedEnvironmentAccess__c, 'Email not sent');
    }
    
   /* public static testMethod void testInitEstimate() {
        String InitQry = 'SELECT Id,Name,Account_Service__r.Account__r.User__c,Account_Service__r.Account__r.User__r.Email,Account_Service__r.Account__r.Primary_Customer_Contact__c,'+
                            'Account_Service__r.Account__r.Primary_Customer_Contact__r.Email '+ 
                            ' FROM Initiatives__c WHERE Name =\'Test Initiative Mani and Team\'';
                                         
        Test.StartTest();
        ODS_InitEstFollowUpEmailBacth  b = new ODS_InitEstFollowUpEmailBacth(Initqry); 
        database.executebatch(b); 
        Test.StopTest();
                
        //Initiatives__c updInit = [SELECT Id,Name,isFollowedInitEstimate__c FROM Initiatives__c WHERE Name = :'Test Initiative Mani and Team'];
        //System.assertEquals(true, updInit.isFollowedInitEstimate__c , 'Email not sent');
    }*/
    
    public static testMethod void testSchedulers() {
        String sch = '0 0 23 * * ?';
        ODS_ScheduledInitEstFollowUp init = new ODS_ScheduledInitEstFollowUp();
        system.schedule('Test init check',sch,init); 
        
        ODS_ScheduledEnvironmentFollowUp env = new ODS_ScheduledEnvironmentFollowUp();
        system.schedule('Test env check',sch,env);
        
        ODS_ScheduledOnboardLightnFollowUp onb = new ODS_ScheduledOnboardLightnFollowUp();
        system.schedule('Test onboard check',sch,onb); 
    }
}