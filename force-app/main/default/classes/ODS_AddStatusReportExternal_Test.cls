@isTest
public class ODS_AddStatusReportExternal_Test {
    public static testmethod void AddStatusReportExternal_Methods(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','sfadmin@demandblue.com','UTF-8','Indumathi',
                                                                          'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                          'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        System.runAs (usrObj){
        	Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True, 1000, '8996554389', 'Others', 'ODS Project');    
 			ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
			Date SRdt = Date.parse('12/19/2016');
            Date SRdte = Date.parse('12/18/2016');
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCSFDC');            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            initiative.Jira_Id__c = 'UPC-1, 2 & 3, 4 & 6';
            List<Initiatives__c> initi = new List<Initiatives__c>();
            initi.add(initiative);
			Initiatives__c initiative1 = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative1', accSrvc.Id, 'Initiative Approved');
            initiative1.Jira_Id__c = 'UPC-1,2,3 to 6'; 
            initi.add(initiative1);
			Update initi;
			Status_Report__c objSRT = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.id,SRdte ,'Development In Progress', 'Testing to be started', 'None','Saved');
            objSRT.Status__c = 'Approved';
			test.StartTest();
            ODS_AddStatusReportExternal.addOnStatus(accSrvc.id,objSRT.id);
            ODS_AddStatusReportExternal.sortJira(initi);
            ODS_AddStatusReportExternal.excludeJiraReport();
            test.stopTest();
            
        } 
    }
}