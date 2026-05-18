/**
 * @author           Indumathi.V
 * @version          1.0 
 * @date             14-Oct-2016
 * @Status           Developed
 * @description      This is the test class for ODS Status Report Controller Class.
 */
 
@isTest 
public class ODS_StatusReportControllerMobile_Test
{
    
    ///<OBJECTIVE>
    ///Test method to test controller method with Portal Account Owner
    ///</OBJECTIVE>
    public static testmethod void Constructor_PortalOwner()
    {
        
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Practice Head', true);            

        System.runAs (usrObj) 
        {     
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,2000,'9432466765', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);

            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCSFDC');
            
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, accObj.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
           
            Status_Report__c objSR = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.Id,System.Today(),'Completed Development', 'Testing to be started', 'None','Submitted');
            PageReference pageRef = Page.StatusReport;
            
            Test.setCurrentPage(pageRef);
            ODS_StatusReportControllerMobile objCntrllr = new ODS_StatusReportControllerMobile(); 

            ODS_StatusReportControllerMobile.GetStatusPicklistValues();
            objCntrllr.hide();
            objCntrllr.show();
            
            
        }
    }

}