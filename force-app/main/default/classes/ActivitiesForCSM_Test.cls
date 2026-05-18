/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       ActivitiesForCSM_Test
* @description      This is the Testclass For ActivitiesForCSM
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	11-FEB-2021    	DemandBlue 		Initial Development
*********************************************************************************************/
@isTest
public class ActivitiesForCSM_Test {
    static testMethod void testActivities() {        
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('mytest','testuser@testmail.com', 
                                                                            'UTF-8','Indumathi6', 'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                            'ezre@preludesys.com','Practice Head', true);
        Account acc = ODS_DataFactory_Test_Utility.InsertAccountforIntroAndKickoffMail('TestAccount',usrObj.id,
                                                                                       'Sent',system.today(),10000,'7665233156','Others','ODS Project',True, 'Customer',True,false);        
        Opportunity oppObj = EZRE_OppRprt_DataFactory_Test_Utility.createOpp('Opp4',acc.Id,'Resume Submitted');
        //Insert Task
        Task objTsk = EZRE_OppRprt_DataFactory_Test_Utility.createTask('Call',oppObj.Id,UserInfo.getUserId(),Date.Today()+3, 'Not Started' );    
        Task objTsk1 = EZRE_OppRprt_DataFactory_Test_Utility.createTask('Send Email',oppObj.Id,UserInfo.getUserId(),Date.Today()-4, 'In Progress' ); 
        //Insert Event
        Event objEvnt = EZRE_OppRprt_DataFactory_Test_Utility.createEvent('Call',oppObj.Id,UserInfo.getUserId(),Date.Today()+3);
        Event objEvnt1 = EZRE_OppRprt_DataFactory_Test_Utility.createEvent('Call',oppObj.Id,UserInfo.getUserId(),Date.Today()-10);         
        test.startTest();
        ActivitiesForCSM.getActivities(String.valueOf(acc.Id));
        test.stopTest();
    }    
}