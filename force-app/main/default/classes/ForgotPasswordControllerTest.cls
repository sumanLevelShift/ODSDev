/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest public without sharing class ForgotPasswordControllerTest {
  	 @IsTest(SeeAllData=true) public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
    
    private static TestMethod void testForgotPasswordControllerCancle()
    {
        ForgotPasswordController loginCtrl = new ForgotPasswordController();
        loginCtrl.cancel();
    }
    
    private static TestMethod void testForgotPasswordControllerCancle_AccessEnabledTest()
    {
        ForgotPasswordController loginCtrl = new ForgotPasswordController();
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('Indhu','testuserindhu@demandblue.com','UTF-8','GnanaPrakash',
                    'en_US','en_US',profile1.Id,'America/Chicago', 'testuserindhu12@demandblue.com','Customer', true, portalRole.Id);
        loginCtrl.username = portalAccountOwner1.Username;
       
        loginCtrl.forgotPassword();
    }
}