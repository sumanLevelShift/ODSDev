/**
 * @author           Gnanaprakasam G
 * @version          1.0 
 * @date             14-Nov-2016
 * @Status           Developed
 * @description      This is the test class for Login Controller.
 * @Updated By       Indhu G
 * @Updated On       29-Oct-2018
 * @Description      Increased code coverage due to coverage failure
 */
@isTest
private class ODSLoginController_Test
{
    // Test method for constructor
    private static TestMethod void Constructor_Test()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        loginCtrl.username = 'testuserindhu@demandblue.com';
        loginCtrl.password = 'Demandblue@123';
    }
    
    
    // Test method for ForgotPassword method
    private static TestMethod void ForgotPassword_Test()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        loginCtrl.ForgotPassword();
    }
    
    // Test method for getPortalAccess method with invalid user credentials
    private static TestMethod void getPortalAccess_InvalidUserTest()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        loginCtrl.username = 'testuserindhu@demandblue.com';
        loginCtrl.password = 'Demandblue@123';
        loginCtrl.getPortalAccess();
    }
    
    // Test method for getPortalAccess method with no access
    private static TestMethod void getPortalAccess_NoAccessTest()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('Indhu','testuserindhu12@demandblue.com','UTF-8','GnanaPrakash',
                    'en_US','en_US',profile1.Id,'America/Chicago', 'testuserindhu@demandblue.com','Customer', false, portalRole.Id);
        loginCtrl.username = portalAccountOwner1.Username;
        loginCtrl.password = 'Demandblue@123';
        
        loginCtrl.getPortalAccess();
    }
    
    // Test method for getPortalAccess method with access enabled
    private static TestMethod void getPortalAccess_AccessEnabledTest()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('Indhu','testuserindhu@demandblue.com','UTF-8','GnanaPrakash',
                    'en_US','en_US',profile1.Id,'America/Chicago', 'testuserindhu12@demandblue.com','Customer', true, portalRole.Id);
        loginCtrl.username = portalAccountOwner1.Username;
        loginCtrl.password = 'Demandblue@123';
        loginCtrl.getPortalAccess();
    }
    
    // Test method for login method with invalid credentials
    private static TestMethod void login_InvalidCredentialsTest()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        loginCtrl.username = 'testuserindhu@demandblue.com';
        loginCtrl.password = 'Demandblue@123';        
        loginCtrl.login();
    }
    
    // Test method for login method with no access
    private static TestMethod void login_NoAccessTest()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        loginCtrl.username = 'testuserindhu@demandblue.com';
        loginCtrl.password = 'Demandblue@123';
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('Indhu','testuserindhu12@demandblue.com','UTF-8','GnanaPrakash',
                    'en_US','en_US',profile1.Id,'America/Chicago', 'testuserindhu@demandblue.com','Customer', false, portalRole.Id);
        loginCtrl.username = portalAccountOwner1.Username;
        Test.setCurrentPageReference(new PageReference('Page.Login_Page')); 
        System.currentPageReference().getParameters().put('g-recaptcha-response', 'Valid Captcha');
        loginCtrl.login();
    }
    
    // Test method for login method with access enabled
    private static TestMethod void login_AccessEnabledTest()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        loginCtrl.username = 'testuserindhu@demandblue.com';
        loginCtrl.password = 'Demandblue@123';
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('Indhu','testuserindhu@demandblue.com','UTF-8','GnanaPrakash',
                    'en_US','en_US',profile1.Id,'America/Chicago', 'testuserindhu@demandblue.com','Customer', true, portalRole.Id);
        loginCtrl.username = portalAccountOwner1.Username;        
        Test.setCurrentPageReference(new PageReference('Page.Login_Page')); 
        System.currentPageReference().getParameters().put('g-recaptcha-response', 'Valid Captcha');
        loginCtrl.login();
    }
    
    // Test method for login method with captach unavailable
    private static TestMethod void login_CaptachUnavailableTest()
    {
        ODSLoginController loginCtrl = new ODSLoginController();
        loginCtrl.username = 'testuserindhu@demandblue.com';
        loginCtrl.password = 'Demandblue@123';
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('Indhu','testuserindhu@demandblue.com','UTF-8','GnanaPrakash',
                    'en_US','en_US',profile1.Id,'America/Chicago', 'testuserindhu@demandblue.com','Customer', true, portalRole.Id); 
        loginCtrl.username = portalAccountOwner1.Username;
        
        loginCtrl.login();
    }
    
}