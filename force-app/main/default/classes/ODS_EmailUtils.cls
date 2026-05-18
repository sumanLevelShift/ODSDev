/**************************************************************************************
* @Author       : Mani & Team
* @Status       : Deployed
* @Class Name   : emailUtils
* @Description  : Supply data for all Email escalation classes
***************************************************************************************
 Version     Date           Team                    Comments
***************************************************************************************
* 1          Apr 2018       Mani&Team               Initial Creation
***************************************************************************************/

public class ODS_EmailUtils
{
    //method to get list of Head of Delivery (PracticeHead) users.
    public static List<User> getPracticeHeadEmail() 
    {
        return [SELECT Id,Name,Email,IsActive From User WHERE Email != null AND PortalUserRole__c = 'Practice Head' AND Management__c = 'Practice Head'];
    }
    
    //method to get OWA Address for SF Admin email
    public static List<OrgWideEmailAddress> getSFAdminEmail()
    {
        return [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Salesforce Admin'];
              
    }
    
    //method to get OWA Address for Invoice Team email
    public static List<OrgWideEmailAddress> getInvoiceTeamEmail()
    {
        return [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Invoice Team'];
              
    }
}