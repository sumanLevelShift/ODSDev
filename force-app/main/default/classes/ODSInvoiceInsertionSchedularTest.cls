@isTest
public without sharing class ODSInvoiceInsertionSchedularTest {
    @isTest
    public static void insertInvoiceAttach(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount', 'California', True, 2000, '9433578865', 'Others', 'ODS Project');
            portalAccount1.Customer_Type__c='ABC Type';
            Update portalAccount1;
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test', 'McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@test.com';
            update contact1;
            portalAccount1.ODS_Invoice_Account_Number__c = 'C45';
            portalAccount1.Invoice_Type__c = 'Paper';
            portalAccount1.Primary_Customer_Contact__c = contact1.Id;
            portalAccount1.InvoiceContact__c = contact1.Id;
            portalAccount1.BillingCity = 'Chennai';
            portalAccount1.BillingStreet = 'Siruseri';
            portalAccount1.BillingState = 'Tamilnadu';
            portalAccount1.BillingCountry = 'India';
            portalAccount1.BillingPostalcode = '640000';
            portalAccount1.ODS_Invoice_Count__c = 10;
            update portalAccount1;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet', 'test', true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', portalAccount1.Id, odsSrv.Id);
            date strtDt = date.parse('11/28/2016');
            date endDt = date.parse('12/04/2016');
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id, 'Technical Account Manager', portalAccountOwner1.Id, odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id, strtDt, endDt, 150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Contract_Term__c = 'Net 30';
            accSrvc.Invoice_Frequency__c = 'Weekly';
            update accSrvc;
            UserRole testRole = [SELECT Id FROM UserRole WHERE Name = 'Vice President Sales'];
            User testUser = new User(
                Username = 'testuser@example.comVPS',
                FirstName = 'Test',
                LastName = 'User',
                Email = 'testuser@example.com',
                Alias = 'testusr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = UserInfo.getProfileId(),
                LanguageLocaleKey = 'en_US',
                UserRoleId = testRole.Id
            );
            insert testUser;
            
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=portalAccount1.Id,
                Project_Start_Date__c=date.parse('11/01/2016'),
                Project_End_Date__c=date.parse('12/31/2016'),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
                Bill_Rate__c =120000,
                Annual_Salary__c=25000,
                PERDIEM__c=920,
                Business_Unit__c='DemandBlue',
                Project_Name__c='TestProject',
                LCA_Required__c=false,
                Minumim_Billable_Hours_Per_Month__c=8,
                Bill_Rate_Type__c='One Time',
                Initial_Gross_Margin__c=77.8,
                Payment_Terms_Projects__c='Net 30',
                PO_Number__c='4578',
                Project_Code__c='DEMANDSF',
                Contact_for_Payment_followUp__c=contact1.Id,
                TIPS_CNSMP_WO_ID__c='1234',
                TIPS_Admin_CNSMP_WO_ID__c='0987',
                TIPS_Consulting_CNSMP_WO_ID__c='6789',
                Same_as_the_Invoice_Contact__c=true
            );
            insert workorderObject2;
            
            Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id, 300, Startdte, Enddte, '11', '2016');
            Timesheet__c insertTimeSheet1 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = date.parse('11/21/2016'),Week_End_Date__c = date.parse('11/27/2016'),Account_Services__c = accSrvc.Id);
            insert insertTimeSheet1;
            ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet1.Id, date.parse('11/22/2016'));
            insertTimeSheet1.Status__c = 'Submitted';
            update insertTimeSheet1;
            
            
            ContentVersion content=new ContentVersion(); 
            content.Title='1234 Test.pdf'; 
            content.PathOnClient='1234 Test.pdf'; 
            content.VersionData=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.origin = 'H';
            insert content;
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=insertTimeSheet1.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
            
            ContentVersion content1=new ContentVersion(); 
            content1.Title='0987 Test.pdf'; 
            content1.PathOnClient='0987 Test.pdf'; 
            content1.VersionData=Blob.valueOf('Unit Test ContentVersion Body'); 
            content1.origin = 'H';
            insert content1;
            ContentDocumentLink contentlink1=new ContentDocumentLink();
            contentlink1.LinkedEntityId=insertTimeSheet1.id;
            contentlink1.contentdocumentid=[select contentdocumentid from contentversion where id =: content1.id].contentdocumentid;
            contentlink1.ShareType = 'I';
            contentlink1.Visibility = 'AllUsers'; 
            insert contentlink1;
            
            ContentVersion content2=new ContentVersion(); 
            content2.Title='6789 Test.pdf'; 
            content2.PathOnClient='6789 Test.pdf'; 
            content2.VersionData=Blob.valueOf('Unit Test ContentVersion Body'); 
            content2.origin = 'H';
            insert content2;
            ContentDocumentLink contentlink2=new ContentDocumentLink();
            contentlink2.LinkedEntityId=insertTimeSheet1.id;
            contentlink2.contentdocumentid=[select contentdocumentid from contentversion where id =: content2.id].contentdocumentid;
            contentlink2.ShareType = 'I';
            contentlink2.Visibility = 'AllUsers'; 
            insert contentlink2;
            
            Date billingStartDate=date.parse('11/01/2016');
            Date billingEndDate=date.parse('12/31/2016');
            TIPS_Invoice_Staging__c invoiceStaging=new TIPS_Invoice_Staging__c(Consumption_WO_ID__c='1234', Invoice_Start_Date__c=billingStartDate,
                                                                               Invoice_End_Date__c=billingEndDate,Invoice_PDF__c='Test',File_Name__c='test.pdf');
            insert invoiceStaging;
            TIPS_Invoice_Staging__c invoiceStaging1=new TIPS_Invoice_Staging__c(Consumption_WO_ID__c='1234', Invoice_Start_Date__c=billingStartDate,
                                                                               Invoice_End_Date__c=billingEndDate,Email_To__c='test@test.com',Email_CC__c='test@test.com',Email_Body__c='test',Subject__c='test',Is_Email_Info__c=true);
            insert invoiceStaging1;
            Test.startTest();
            ODSInvoiceInsertionSchedular invoiceSt=new ODSInvoiceInsertionSchedular();
            invoiceSt.execute(null);
            
            Test.stopTest();
        }
    }
       @isTest
    public static void invoiceBatch(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount', 'California', True, 2000, '9433578865', 'Others', 'ODS Project');
            portalAccount1.Customer_Type__c='ABC Type';
            Update portalAccount1;
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test', 'McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@test.com';
            update contact1;
            portalAccount1.ODS_Invoice_Account_Number__c = 'C45';
            portalAccount1.Invoice_Type__c = 'Paper';
            portalAccount1.Primary_Customer_Contact__c = contact1.Id;
            portalAccount1.InvoiceContact__c = contact1.Id;
            portalAccount1.BillingCity = 'Chennai';
            portalAccount1.BillingStreet = 'Siruseri';
            portalAccount1.BillingState = 'Tamilnadu';
            portalAccount1.BillingCountry = 'India';
            portalAccount1.BillingPostalcode = '640000';
            portalAccount1.ODS_Invoice_Count__c = 10;
            update portalAccount1;
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet', 'test', true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', portalAccount1.Id, odsSrv.Id);
            date strtDt = date.parse('11/28/2016');
            date endDt = date.parse('12/04/2016');
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id, 'Technical Account Manager', portalAccountOwner1.Id, odsSrv.Id);
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id, strtDt, endDt, 150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Contract_Term__c = 'Net 30';
            accSrvc.Invoice_Frequency__c = 'Weekly';
            update accSrvc;
            UserRole testRole = [SELECT Id FROM UserRole WHERE Name = 'Vice President Sales'];
            User testUser = new User(
                Username = 'testuser@example.comVPS',
                FirstName = 'Test',
                LastName = 'User',
                Email = 'testuser@example.com',
                Alias = 'testusr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = UserInfo.getProfileId(),
                LanguageLocaleKey = 'en_US',
                UserRoleId = testRole.Id
            );
            insert testUser;
            
            Work_Order__c workorderObject2= new Work_Order__c(
                Client_Name__c=portalAccount1.Id,
                Project_Start_Date__c=date.parse('11/01/2016'),
                Project_End_Date__c=date.parse('12/31/2016'),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandBlue-Subscription',
                Pay_Rate__c=85,
                Billing_Frequency__c='Monthly',
                Bill_Rate__c =120000,
                Annual_Salary__c=25000,
                PERDIEM__c=920,
                Business_Unit__c='DemandBlue',
                Project_Name__c='TestProject',
                LCA_Required__c=false,
                Minumim_Billable_Hours_Per_Month__c=8,
                Bill_Rate_Type__c='One Time',
                Initial_Gross_Margin__c=77.8,
                Payment_Terms_Projects__c='Net 30',
                PO_Number__c='4578',
                Project_Code__c='DEMANDSF',
                Contact_for_Payment_followUp__c=contact1.Id,
                TIPS_CNSMP_WO_ID__c='1234',
                TIPS_Admin_CNSMP_WO_ID__c='0987',
                TIPS_Consulting_CNSMP_WO_ID__c='6789',
                Same_as_the_Invoice_Contact__c=true
            );
            insert workorderObject2;
            
            Time_Sheet_Cost__c objTmeShtCst1 = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id, 300, Startdte, Enddte, '11', '2016');
            Timesheet__c insertTimeSheet1 = new Timesheet__c(Name = 'TestName',Time_Sheet_Cost__c = objTmeShtCst1.Id,Week_Start_Date__c = date.parse('11/21/2016'),Week_End_Date__c = date.parse('11/27/2016'),Account_Services__c = accSrvc.Id);
            insert insertTimeSheet1;
            ODS_DataFactory_Test_Utility.insertTimesheetdetail(5, ObjTeamMembr.Id, 'Test Res', insertTimeSheet1.Id, date.parse('11/22/2016'));
            insertTimeSheet1.Status__c = 'Submitted';
            update insertTimeSheet1;
            
            
            ContentVersion content=new ContentVersion(); 
            content.Title='1234 Test.pdf'; 
            content.PathOnClient='1234 Test.pdf'; 
            content.VersionData=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.origin = 'H';
            insert content;
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=insertTimeSheet1.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
            
            ContentVersion content1=new ContentVersion(); 
            content1.Title='0987 Test.pdf'; 
            content1.PathOnClient='0987 Test.pdf'; 
            content1.VersionData=Blob.valueOf('Unit Test ContentVersion Body'); 
            content1.origin = 'H';
            insert content1;
            ContentDocumentLink contentlink1=new ContentDocumentLink();
            contentlink1.LinkedEntityId=insertTimeSheet1.id;
            contentlink1.contentdocumentid=[select contentdocumentid from contentversion where id =: content1.id].contentdocumentid;
            contentlink1.ShareType = 'I';
            contentlink1.Visibility = 'AllUsers'; 
            insert contentlink1;
            
            ContentVersion content2=new ContentVersion(); 
            content2.Title='6789 Test.pdf'; 
            content2.PathOnClient='6789 Test.pdf'; 
            content2.VersionData=Blob.valueOf('Unit Test ContentVersion Body'); 
            content2.origin = 'H';
            insert content2;
            ContentDocumentLink contentlink2=new ContentDocumentLink();
            contentlink2.LinkedEntityId=insertTimeSheet1.id;
            contentlink2.contentdocumentid=[select contentdocumentid from contentversion where id =: content2.id].contentdocumentid;
            contentlink2.ShareType = 'I';
            contentlink2.Visibility = 'AllUsers'; 
            insert contentlink2;
            
            Date billingStartDate=date.parse('11/01/2016');
            Date billingEndDate=date.parse('12/31/2016');
            TIPS_Invoice_Staging__c invoiceStaging=new TIPS_Invoice_Staging__c(Consumption_WO_ID__c='1234', Invoice_Start_Date__c=billingStartDate,
                                                                               Invoice_End_Date__c=billingEndDate,Invoice_PDF__c='Test',File_Name__c='test.pdf');
            insert invoiceStaging;
    
            Test.startTest();
            database.executebatch(new ODSInvoiceInsertionBatch());
            try{
              integer i=1/0;  
            }catch(Exception e)    
            {
                ODSInvoiceInsertionController.sendMailForFailureInvoice(e);
            }
            Test.stopTest();
        }
    }
}