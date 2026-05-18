/*
Author: Mani & Team
Story: CP-24
Purpose: If Initiative Estimate not given after 10 days of KickOff completed, send escalation email - scheduler
Updated by Indhu on 30-Mar-2020
Purpose : DL-42: (Bug) Incorrect logic on Initiative Estimate Email
Logic:  When initiative is not approved after 5 days of submission an escalation email is schedule
*/
global class ODS_ScheduledInitEstFollowUp implements Schedulable {
   global void execute(SchedulableContext sc) {
       String qry = 'SELECT Id,Name,Account_Service__r.Account__r.User__c,Account_Service__r.Account__r.User__r.Email,'+
                        'Account_Service__r.Account__r.Primary_Customer_Contact__c,'+
                        'Account_Service__r.Account__r.Primary_Customer_Contact__r.Email '+
                    ' FROM Initiatives__c '+
                    ' WHERE Account_Service__r.Account__r.Customer_Engagement_Type__c = \'ODS\' AND '+
                        ' Account_Service__r.Account__r.SOW__c = \'Fully Executed\' AND '+
                        ' (Account_Service__r.Account__r.Account_Status__c = \'Customer\' OR '+
                        ' Account_Service__r.Account__r.Account_Status__c = \'Active Customer\') AND '+
                        ' (Account_Service__r.Account__r.Kickoff__c = \'Completed\' OR '+
                        ' Account_Service__r.Account__r.Kickoff__c = \'Email Sent\') AND '+
                        ' Account_Service__r.Account__r.User__c != null AND '+
                        ' Account_Service__r.Account__r.Primary_Customer_Contact__c != null AND '+
                        ' Initiative_Submitted_Days__c >= 5 AND '+
                        ' isFollowedInitEstimate__c = false AND '+
                        ' (status__c = \'Initiative Submitted\')';
                        
      ODS_InitEstFollowUpEmailBacth  b = new ODS_InitEstFollowUpEmailBacth(qry); 
      database.executebatch(b);
   }
}