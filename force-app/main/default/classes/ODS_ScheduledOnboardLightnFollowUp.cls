/*
Author: Mani & Team
Story: CP-20, 21
Purpose: Once Environment access is completed, if onboarding doc not given within 10 days and lightning readiness not checked within 3 days
----send escalation/followup email
*/
global class ODS_ScheduledOnboardLightnFollowUp implements Schedulable {
    global void execute(SchedulableContext sc) {
        //On-boarding document batch class
        String onboardQry = 'SELECT Id,Name,User__c,User__r.Email,Primary_Customer_Contact__c,Primary_Customer_Contact__r.Email '+ 
                            ' FROM Account '+
                            ' WHERE Customer_Engagement_Type__c = \'ODS\' AND '+
                                ' SOW__c = \'Fully Executed\' AND '+
                                ' (Account_Status__c = \'Customer\' OR Account_Status__c = \'Active Customer\') AND '+
                                ' (Kickoff__c = \'Completed\' OR Kickoff__c = \'Email Sent\') AND '+
                                ' User__c != null AND '+
                                ' Primary_Customer_Contact__c != null AND '+
                                ' IsEnvironmentAccessEmail__c = true AND '+
                                ' Environment_Access__c = \'Completed\' AND '+
                                ' Onboarding_Document__c != \'Approved\' AND '+
                                ' EnviAcc_Number_Of_Days__c >= 10 AND '+
                                ' isFollowedOnboardDoc__c = false';
        String onboardFld = 'onboardingDoc';                        
        
        ODS_OnboardLightnFollowUpEmailBacth onBoard = new ODS_OnboardLightnFollowUpEmailBacth(onboardQry,onboardFld); 
        database.executebatch(onBoard);
        
        //Lightning readiness batch class
        String lightnQry = 'SELECT Id,Name,User__c,User__r.Email,Primary_Customer_Contact__c,Primary_Customer_Contact__r.Email '+ 
                            ' FROM Account '+
                            ' WHERE Customer_Engagement_Type__c = \'ODS\' AND '+
                                ' SOW__c = \'Fully Executed\' AND '+
                                ' (Account_Status__c = \'Customer\' OR Account_Status__c = \'Active Customer\') AND '+
                                ' (Kickoff__c = \'Completed\' OR Kickoff__c = \'Email Sent\') AND '+
                                ' User__c != null AND '+
                                ' Primary_Customer_Contact__c != null AND '+
                                ' IsEnvironmentAccessEmail__c = true AND '+
                                ' Environment_Access__c = \'Completed\' AND '+
                                ' Lightning_Readiness_Check__c != \'Completed\' AND '+
                                ' EnviAcc_Number_Of_Days__c >= 3 AND '+
                                ' isFollowedLightnReady__c = false';                               
        String lightnFld = 'lightningReadiness';                        
        
        ODS_OnboardLightnFollowUpEmailBacth lightn = new ODS_OnboardLightnFollowUpEmailBacth(lightnQry,lightnFld);
        database.executebatch(lightn);
    }
}