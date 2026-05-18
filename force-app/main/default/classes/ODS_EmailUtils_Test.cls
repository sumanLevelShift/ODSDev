/**************************************************************************************
* @Author       : Mani & Team
* @Status       : Deployed
* @Class Name   : emailUtils_Test
* @Description  : Test class for Email Utils
***************************************************************************************
 Version     Date           Team                    Comments
***************************************************************************************
* 1          Apr 2018       Mani&Team               Initial Creation
***************************************************************************************/

@isTest
public class ODS_EmailUtils_Test
{
    public static testMethod void testReturnData() {        
        List<User> usr = ODS_EmailUtils.getPracticeHeadEmail();
        List<OrgWideEmailAddress> owa = ODS_EmailUtils.getSFAdminEmail();
        List<OrgWideEmailAddress> owa2 = ODS_EmailUtils.getInvoiceTeamEmail();
    }
}