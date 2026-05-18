/**************************************************************************************
* @Author       : Mani & Team
* @Status       : Deployed
* @Class Name   : ODS_ScheduledEnvironmentFollowUp
* @Description  : If Environment access not given after 5 days of KickOff completed, send escalation email - scheduler        
***************************************************************************************
 Version     Date           Team                    Comments
***************************************************************************************
* 1          Apr 2018       Mani&Team               Initial Creation
***************************************************************************************/

global class ODS_ScheduledEnvironmentFollowUp implements Schedulable {
    global void execute(SchedulableContext sc) {
        String qry = 'SELECT Id,Name,User__c,User__r.Email,Primary_Customer_Contact__c,Primary_Customer_Contact__r.Email'+
                    ' FROM Account '+
                    ' WHERE Customer_Engagement_Type__c = \'ODS\' AND '+
                        'SOW__c = \'Fully Executed\' AND '+
                        ' (Account_Status__c = \'Customer\' OR Account_Status__c = \'Active Customer\') AND '+
                        ' Kickoff__c = \'Completed\' AND '+
                        ' User__c != null AND '+
                        ' Primary_Customer_Contact__c != null AND '+
                        ' isSentIntroductionMail__c = true AND '+
                        ' TriggerKickoffMail__c = true AND '+
                        ' IsEnvironmentAccessEmail__c = true AND '+
                        ' Environment_Access__c != \'Completed\' AND '+
                        ' isFollowedEnvironmentAccess__c = false AND '+
                        ' KickOff_Number_Of_Days__c >= 5';
                        
        ODS_EnvironmentFollowUpEmailBacth b = new ODS_EnvironmentFollowUpEmailBacth(qry); 
        database.executebatch(b);
    }
}