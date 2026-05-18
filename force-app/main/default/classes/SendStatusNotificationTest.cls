@isTest
public class SendStatusNotificationTest {
    static testmethod void sendInitiativeApprovalNotification()
    {
        String recordId;
        String odsNotificationCategory;
        String odsCustomNotificationName;
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();        
        
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');        
        
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id); 
        System.runAs (usrObj) 
        { 
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);

            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);

            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Saved');
            Contact initiativeClientContact = new Contact();
            initiativeClientContact.FirstName = 'Test Name12';
            initiativeClientContact.LastName ='Test Name123';
            initiativeClientContact.Email = 'xyz@gmail.com';
            Insert initiativeClientContact;
            initiative.Client_side_Contact__c = initiativeClientContact.Id;
            initiative.Status__c = 'Initiative Submitted';
            initiative.Approval_Notification_Sent__c = True;
            update initiative;
            usrObj.ContactId = initiativeClientContact.Id;
            // update usrObj;
            odsNotificationCategory = 'Initiative';
            recordId =initiative.id;
            odsCustomNotificationName='New_Initiative';  
            
            List<SendStatusNotification.NotifyRequest> nr=new List<SendStatusNotification.NotifyRequest>();
            SendStatusNotification.NotifyRequest n=new SendStatusNotification.NotifyRequest();
            n.recordId = recordId;
            n.odsNotificationCategory = 'Initiative';
            n.odsCustomNotificationName = 'New_Initiative';
            nr.add(n);
            
            Test.startTest();            
            SendStatusNotification.sendNotification(nr);            
            Test.stopTest();
        }
    }
     static testmethod void sendTimeSheetApprovalNotification()
    {
        String recordId;        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();        
        
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');        
        
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id); 
        System.runAs (usrObj) 
        { 
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,Startdte,Enddte,'11','2016');
            Timesheet__c timeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,date.parse('11/07/2016'),date.parse('11/13/2016'));
            timeSheet.Account_Services__c = accSrvc.Id;
            update timeSheet;
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContactWithEmail('Test','McTesty', True, accObj.Id, 'testuser@test.com', 'Others', 'ODS Project');
            Contact_Account_Service__c cntAcntService = new Contact_Account_Service__c();
            cntAcntService.Account__c = accObj.Id;
            cntAcntService.ODS_Service__c = odsSrv.Id;
            cntAcntService.Contact__c = contact1.Id;
            cntAcntService.Is_Approver__c = True;
            Insert CntAcntService;
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User usrObj2 = ODS_DataFactory_Test_Utility.InsertUserWithContact('Allen','carrier@testmail.com','UTF-8','Institute',
                                                                      'en_US','en_US',portalProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'AllenT@testmail.com',contact1.Id, 'Customer');
            recordId =timeSheet.id;  
            List<SendStatusNotification.NotifyRequest> nr=new List<SendStatusNotification.NotifyRequest>();
            SendStatusNotification.NotifyRequest n=new SendStatusNotification.NotifyRequest();
            n.recordId = recordId;
            n.odsNotificationCategory = 'Timesheet';
            n.odsCustomNotificationName = 'New_Timesheet';
            nr.add(n);
            Test.startTest();            
            SendStatusNotification.sendNotification(nr);            
            Test.stopTest();
        }
    }
     static testmethod void sendStatusReportApprovalNotification()
    {
        String recordId;        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User usrObj = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                      'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                      'test123@testmail.com','Technical Account Manager', true,portalRole.Id); 
        System.runAs (usrObj) 
        { 
            Account accObj = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',usrObj.Id, True,1500,'9866857745', 'Others', 'ODS Project'); 
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(accObj.id,'Technical Account Manager',usrObj.Id,odsSrv.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(accObj.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', usrObj.Id, 'WEDCNET');            
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContactWithEmail('Test','McTesty', True, accObj.Id, 'testuser@test.com', 'Others', 'ODS Project');
            Contact_Account_Service__c cntAcntService = new Contact_Account_Service__c();
            cntAcntService.Account__c = accObj.Id;
            cntAcntService.ODS_Service__c = odsSrv.Id;
            cntAcntService.Contact__c = contact1.Id;
            cntAcntService.Is_Approver__c = True;
            Insert CntAcntService;
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User usrObj2 = ODS_DataFactory_Test_Utility.InsertUserWithContact('Allen','carrier@testmail.com','UTF-8','Institute',
                                                                              'en_US','en_US',portalProfile.Id,'America/Chicago',System.now().millisecond() + 
                                                                              'AllenT@testmail.com',contact1.Id, 'Customer');
            Status_Report__c objSR = ODS_DataFactory_Test_Utility.InsertSR(accSrvc.Id,System.Today(),'Completed Development', 'Testing to be started', 'None','Submitted');
           	recordId =objSR.id;  
            List<SendStatusNotification.NotifyRequest> nr=new List<SendStatusNotification.NotifyRequest>();
            SendStatusNotification.NotifyRequest n=new SendStatusNotification.NotifyRequest();
            n.recordId = recordId;
            n.odsNotificationCategory = 'DailyStatusReport';
            n.odsCustomNotificationName = 'New_Daily_Status_Report';
            nr.add(n);
            Test.startTest();            
            SendStatusNotification.sendNotification(nr);            
            Test.stopTest();
        }
    }
    
    static testmethod void sendInvalidCategoryNotification()
    {
        List<SendStatusNotification.NotifyRequest> nr=new List<SendStatusNotification.NotifyRequest>();
        SendStatusNotification.NotifyRequest n=new SendStatusNotification.NotifyRequest();
        n.recordId = '';
        n.odsNotificationCategory = 'Invalid_Category';
        n.odsCustomNotificationName = 'Invalid_Notification';
        nr.add(n);
        
        Test.startTest();            
        SendStatusNotification.sendNotification(nr);            
        Test.stopTest();        
    }
}