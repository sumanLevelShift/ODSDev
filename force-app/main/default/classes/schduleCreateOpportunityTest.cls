/**
* @author           Harish Sankaran
* @version          1.0 
* @date             13-April-2021
* @Status           Inprogress
* @description      This Test class for creating an Renewal Opportunity Schedule 
*
*/
@isTest
global class schduleCreateOpportunityTest {
   
    public static testMethod void testRunAs() 
    {
        Test.startTest();
        schduleCreateOpportunity sh1 = new schduleCreateOpportunity();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
}