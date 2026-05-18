@isTest
public class ODS_EditUploadInvoicecontroller_Test {
    static testMethod void EditUploadInvoice_PositiveTestV1(){
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        System.runAs (portalAccountOwner){
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others'); 
            System.debug('account : '+account);
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            System.debug('odsServices : '+odsServices);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            System.debug('accountServices : '+accountServices);
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            System.debug('contact : '+contact);
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            System.debug('Invoice : '+Invoice);
            Invoice.Comments__c = 'abc';
            Invoice.Status__c = 'Submitted';
            Invoice.Billing_Start_Date__c=system.today();
            Invoice.Billing_End_Date__c=system.today()+5;
            Update Invoice;
            //Contact_Account_Service__c InsertContactAccountService = new Contact_Account_Service__c ();            
            Contact_Account_Service__c InsertContactAccountService = ODS_DataFactory_Test_Utility.InsertContactAccountService(contact.Id,account.Id,odsServices.Id,True,True,false);             
            
            System.debug('InsertContactAccountService : '+InsertContactAccountService);
            Date InvoiceStartDate= date.parse('11/01/2016');
            Date InvoiceEndDate = date.parse('11/30/2016'); 
            ODS_EditUploadInvoicecontroller.wrapAttachment wrap = new ODS_EditUploadInvoicecontroller.wrapAttachment('abc','cghj','timesheet');
            
            //  userSession =  ODSInvoiceSessionData__c.getValues( userInfo.getUserId() );
            ODSInvoiceSessionData__c userSession = new ODSInvoiceSessionData__c();
            system.debug('userSession:'+userSession);
            userSession.UserBillingStartDate__c = Invoice.Billing_Start_Date__c;
            userSession.UserBillingEndDate__c = Invoice.Billing_End_Date__c;
            insert userSession;
            Candidate__c objCand=EZRE_DataFactory_Test_Utility1.CreateCandidateWithPosition('TestCandidateName','TestCandidateLastName',
                                                                                            'Irvine','Arizona','Male','Test Employee','test@testmail.com','Mobile Phone',
                                                                                            'Corp to Corp','H1 B',100,'9988776655','test@testmail.com','Test Contact Name',
                                                                                            '9443322110','Test Emp Name','9011223344','Test Skill','Area Manager');  
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accountServices.Id,300,Invoice.Billing_Start_Date__c,Invoice.Billing_End_Date__c,'05','2021');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,Invoice.Billing_Start_Date__c,Invoice.Billing_End_Date__c);
            insertTimeSheet.Account_Services__c=accountServices.id;
            update insertTimeSheet;
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            cv.Type__c='Invoice';
            cv.Candidate_ID__c=objCand.id;
            Insert cv;
            
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = Invoice.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;
            
            Attachment att=new Attachment();
            att.Body=Blob.valueOf('ss');
            att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att.parentId=Invoice.id;
            insert att;
            
            Attachment att1=new Attachment();
            att1.Body=Blob.valueOf('ss');
            att1.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att1.parentId=Invoice.id;
            insert att1;
            test.startTest();
            
            PageReference pageRef = Page.EditUploadInvoice;
            //PageReference pageRef1 = Page.DeleteAttachment;
            ApexPages.currentPage().getParameters().put('filename','monthly');
            ApexPages.currentPage().getParameters().put('blobBody','data:application/pdf;base64,JVBERi0xLjQKJeLjz9MKMyAwIG9iaiA8PC9Db2xvclNwYWNlL0RldmljZUdyYXkvU3VidHlwZS9JbWFnZS9IZWlnaHQgODUvRmlsdGVyL0ZsYXR');
            ApexPages.currentPage().getParameters().put('AccServiceId',accountServices.id);
            ApexPages.currentPage().getParameters().put('CurrenInvoiceId',Invoice.id);
            //ApexPages.currentPage().getParameters().put('BillingStartDate',InvoiceStartDate);
            //ApexPages.currentPage().getParameters().put('BillingEndDate',InvoiceEndDate);
            ODS_EditUploadInvoicecontroller EditUploadController = new ODS_EditUploadInvoicecontroller();
            EditUploadController.GetAccountServices();
            EditUploadController.getYears();
            EditUploadController.redirectToInvoice();
            EditUploadController.redirectToInvoiceList();
            EditUploadController.AttachmentToDelete=cv.id;
            EditUploadController.filename='test';
            EditUploadController.AttachmentType='invoice';
            EditUploadController.attachFile();
            EditUploadController.attachTimeSheet();
            EditUploadController.DeleteAttachment();
            // EditUploadController.commentHistoryDetails();
            //ODS_EditUploadInvoicecontroller.ValidateUploadInvoice(account.id,odsServices.id,Invoice.id,'abc');
            
            List<SelectOption> optionValuesNew = EditUploadController.getInvoiceStatus; 
            List<SelectOption> optionValuesNew1 = EditUploadController.getContentVersionType;
            
            //List<SelectOption> optionValuesNew = EditUploadController.getInvoiceStatus;  
            EditUploadController.BillingStartDate = InvoiceStartDate;
            EditUploadController.BillingEndDate = InvoiceEndDate;
            EditUploadController.InsertUpdateInvoice();
            ODS_EditUploadInvoicecontroller.getInvoiceSessionDetails(); 
            
            test.stopTest();
            ODSInvoiceSessionData__c userSession1 = ODSInvoiceSessionData__c.getValues(portalAccountOwner.Id);
            System.assertEquals(userSession1.UserBillingStartDate__c,InvoiceStartDate);
            
        }                        
    }
    static testMethod void EditUploadInvoice_PositiveTest(){
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        System.runAs (portalAccountOwner){
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others'); 
            System.debug('account : '+account);
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            System.debug('odsServices : '+odsServices);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            System.debug('accountServices : '+accountServices);
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            System.debug('contact : '+contact);
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            System.debug('Invoice : '+Invoice);
            Invoice.Comments__c = 'abc';
            Invoice.Status__c = 'Submitted';
            Invoice.Billing_Start_Date__c=system.today();
            Invoice.Billing_End_Date__c=system.today()+5;
            Update Invoice;
            //Contact_Account_Service__c InsertContactAccountService = new Contact_Account_Service__c ();            
            Contact_Account_Service__c InsertContactAccountService = ODS_DataFactory_Test_Utility.InsertContactAccountService(contact.Id,account.Id,odsServices.Id,True,True,false);             
            
            System.debug('InsertContactAccountService : '+InsertContactAccountService);
            Date InvoiceStartDate= date.parse('11/01/2016');
            Date InvoiceEndDate = date.parse('11/30/2016'); 
            ODS_EditUploadInvoicecontroller.wrapAttachment wrap = new ODS_EditUploadInvoicecontroller.wrapAttachment('abc','cghj','timesheet');
            
            //  userSession =  ODSInvoiceSessionData__c.getValues( userInfo.getUserId() );
            ODSInvoiceSessionData__c userSession = new ODSInvoiceSessionData__c();
            system.debug('userSession:'+userSession);
            userSession.UserBillingStartDate__c = Invoice.Billing_Start_Date__c;
            userSession.UserBillingEndDate__c = Invoice.Billing_End_Date__c;
            insert userSession;
            Candidate__c objCand=EZRE_DataFactory_Test_Utility1.CreateCandidateWithPosition('TestCandidateName','TestCandidateLastName',
                                                                                            'Irvine','Arizona','Male','Test Employee','test@testmail.com','Mobile Phone',
                                                                                            'Corp to Corp','H1 B',100,'9988776655','test@testmail.com','Test Contact Name',
                                                                                            '9443322110','Test Emp Name','9011223344','Test Skill','Area Manager');
            
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accountServices.Id,300,Invoice.Billing_Start_Date__c,Invoice.Billing_End_Date__c,'05','2021');
            Timesheet__c insertTimeSheet =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName',objTmeShtCst.Id,Invoice.Billing_Start_Date__c,Invoice.Billing_End_Date__c);
            insertTimeSheet.Account_Services__c=accountServices.id;
            update insertTimeSheet;
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            cv.Type__c='Invoice';
            cv.Candidate_ID__c=objCand.id;
            Insert cv;
            
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = Invoice.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;
            Attachment att=new Attachment();
            att.Body=Blob.valueOf('ss');
            att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att.parentId=Invoice.id;
            insert att;
            
            Attachment att1=new Attachment();
            att1.Body=Blob.valueOf('ss');
            att1.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att1.parentId=Invoice.id;
            insert att1;
            test.startTest();
            
            PageReference pageRef = Page.EditUploadInvoice;
            ApexPages.currentPage().getParameters().put('filename','monthly');
            ApexPages.currentPage().getParameters().put('blobBody','data:application/pdf;base64,JVBERi0xLjQKJeLjz9MKMyAwIG9iaiA8PC9Db2xvclNwYWNlL0RldmljZUdyYXkvU3VidHlwZS9JbWFnZS9IZWlnaHQgODUvRmlsdGVyL0ZsYXR');
            //PageReference pageRef1 = Page.DeleteAttachment;
            ApexPages.currentPage().getParameters().put('AccServiceId',accountServices.id);
            ApexPages.currentPage().getParameters().put('CurrenInvoiceId',Invoice.id);
            //ApexPages.currentPage().getParameters().put('BillingStartDate',InvoiceStartDate);
            //ApexPages.currentPage().getParameters().put('BillingEndDate',InvoiceEndDate);
            ODS_EditUploadInvoicecontroller EditUploadController = new ODS_EditUploadInvoicecontroller();
            EditUploadController.GetAccountServices();
            EditUploadController.getYears();
            EditUploadController.redirectToInvoice();
            EditUploadController.redirectToInvoiceList();
            EditUploadController.AttachmentToDelete=att.id;
            EditUploadController.filename='test';
            EditUploadController.attachFile();
            EditUploadController.attachTimeSheet();
            EditUploadController.DeleteAttachment();
            // EditUploadController.commentHistoryDetails();
            //ODS_EditUploadInvoicecontroller.ValidateUploadInvoice(account.id,odsServices.id,Invoice.id,'abc');
            
            List<SelectOption> optionValuesNew = EditUploadController.getInvoiceStatus; 
            List<SelectOption> optionValuesNew1 = EditUploadController.getContentVersionType;
            
            //List<SelectOption> optionValuesNew = EditUploadController.getInvoiceStatus;  
            EditUploadController.BillingStartDate = InvoiceStartDate;
            EditUploadController.BillingEndDate = InvoiceEndDate;
            EditUploadController.InsertUpdateInvoice();
            ODS_EditUploadInvoicecontroller.getInvoiceSessionDetails(); 
            
            test.stopTest();
            ODSInvoiceSessionData__c userSession1 = ODSInvoiceSessionData__c.getValues(portalAccountOwner.Id);
            System.assertEquals(userSession1.UserBillingStartDate__c,InvoiceStartDate);
            
        }                        
    }
    
    static testMethod void EditUploadInvoice_NegativeTest(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);         
        System.runAs (portalAccountOwner) 
        {          
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;            
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others'); 
            System.debug('account : '+account);
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            System.debug('odsServices : '+odsServices);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            System.debug('accountServices : '+accountServices);
            // Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            //System.debug('contact : '+contact);
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            System.debug('Invoice : '+Invoice);
            
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = 'PassAccountName'+ ' ' +system.today() + ' - ' +system.today() +'.pdf'; 
            conVer.Title = 'PassAccountName'+ ' ' +system.today() + '--' +system.today()+'.pdf'; 
            conVer.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8')); 
            conVer.Type__c = 'Supporting Document';            
            insert conVer;              
            System.debug('ContentVersion : '+ conVer);
            
            /*    Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
system.debug('ContentVersion docid :' +conDocId);

ContentDocumentLink cdl = new ContentDocumentLink();

cdl.LinkedEntityId = Invoice.Id;
cdl.ShareType = 'V';
cdl.Visibility = 'AllUsers';
cdl.ContentDocumentId = conDocId;
insert cdl;
system.debug('cdlcdlcdl :'+cdl); */
            
            test.startTest();
            ODS_EditUploadInvoicecontroller EditUploadController = new ODS_EditUploadInvoicecontroller();
            //ODS_EditUploadInvoicecontroller.validateOnSubmit(Invoice.Id);
            ODS_EditUploadInvoicecontroller.validateOnSubmitUpdated(Invoice.Id);
            
            test.stopTest();
        }
        
    } 
    
    static testMethod void Upload_PositiveTest()
    {
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        System.runAs (portalAccountOwner){
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others'); 
            System.debug('account : '+account);
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            System.debug('odsServices : '+odsServices);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            System.debug('accountServices : '+accountServices);
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            System.debug('contact : '+contact);
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            Invoice.Billing_End_Date__c = system.today() + 7;
            Invoice.Billing_Start_Date__c = system.today();
            Invoice.Status__c = '';
            update Invoice;
            System.debug('Invoice : '+Invoice);
            
            Contact_Account_Service__c InsertContactAccountService = ODS_DataFactory_Test_Utility.InsertContactAccountService(contact.Id,account.Id,odsServices.Id,True,True,false);             
            
            System.debug('InsertContactAccountService : '+InsertContactAccountService);
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            Date Startdte = System.Today().addYears(-1);
            //  Date Enddte = System.Today().addYears(2);
            Date thisMonthStart = System.Today().toStartOfMonth();
            Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
            Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
            ODS_EditUploadInvoicecontroller.wrapAttachment wrap = new ODS_EditUploadInvoicecontroller.wrapAttachment('abc','cghj','timesheet');
            //ODSInvoiceSessionData__c userSession = ODSInvoiceSessionData__c.getValues( userInfo.getUserId() );
            Attachment attachment =  ODS_DataFactory_Test_Utility.InsertAttachment('Invoice', 'Invoice for the month of june',Invoice.Id);            
            System.debug('attachment : '+ attachment);
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accountServices.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            
            update objTmeShtCst;          
            System.debug('objTmeShtCst : '+ objTmeShtCst);
            
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,Invoice.Billing_Start_Date__c, Invoice.Billing_End_Date__c);
            // insertTimeSheetWeek1.Status__c = 'Submitted';            
            insertTimeSheetWeek1.Account_Services__c = accountServices.Id;
            update insertTimeSheetWeek1;
            System.debug('insertTimeSheetWeek1 : '+ insertTimeSheetWeek1);
            
            
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = 'PassAccountName'+ ' ' +system.today() + ' - ' +system.today() +'.pdf'; 
            conVer.Title = 'PassAccountName'+ ' ' +system.today() + '--' +system.today()+'.pdf'; 
            conVer.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8')); 
            conVer.Type__c = 'Timesheet';            
            insert conVer;              
            System.debug('ContentVersion : '+ conVer);  
            /*       
Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
system.debug('ContentVersion docid :' +conDocId);
Id conVerId = [SELECT Id FROM ContentVersion WHERE Id =: conVer.Id].Id;
system.debug('con ver id :'+conVerId );
//EZRE_ContentVersionTrigClass.updateCandtContent(conVerId);

ContentDocumentLink cdl = new ContentDocumentLink();

cdl.LinkedEntityId = Invoice.Id;
cdl.ShareType = 'V';
cdl.Visibility = 'AllUsers';
cdl.ContentDocumentId = conDocId;
insert cdl; 
system.debug('cdlcdlcdl :'+cdl); */
            
            ODSInvoiceSessionData__c userSession = ODSInvoiceSessionData__c.getValues( userInfo.getUserId() );
            system.debug('userSession :' + userSession);
            
            test.startTest();
            PageReference pageRef = Page.EditUploadInvoice;
            ApexPages.currentPage().getParameters().put('AccServiceId',accountServices.id);
            ApexPages.currentPage().getParameters().put('CurrenInvoiceId',Invoice.id);
            
            ODS_EditUploadInvoicecontroller EditUploadController = new ODS_EditUploadInvoicecontroller();
            EditUploadController.filename = System.today() +'filename';            
            EditUploadController.documentSuffix = accountServices.Document_Suffix__c;
            
            EditUploadController.attachFile();            
            EditUploadController.attachTimeSheet();
            EditUploadController.InsertUpdateInvoice();
            EditUploadController.GetLoggedUserAccountService();
            test.stopTest();
            
        }      
    }
    
    static testMethod void ValidateSubmit(){
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        System.runAs (portalAccountOwner){
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others'); 
            System.debug('account : '+account);
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            System.debug('odsServices : '+odsServices);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            System.debug('accountServices : '+accountServices);
            // Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            //System.debug('contact : '+contact);
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            System.debug('Invoice : '+Invoice);
            
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            Date Startdte = System.Today().addYears(-1);
            //  Date Enddte = System.Today().addYears(2);
            Date thisMonthStart = System.Today().toStartOfMonth();
            Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
            Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
            
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = 'PassAccountName'+ ' ' +system.today() + ' - ' +system.today() +'.pdf'; 
            conVer.Title = 'PassAccountName'+ ' ' +system.today() + '--' +system.today()+'.pdf'; 
            conVer.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8')); 
            conVer.Type__c = 'Timesheet';            
            insert conVer;              
            System.debug('ContentVersion : '+ conVer);
            
            
            
            /*   Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
system.debug('ContentVersion docid :' +conDocId);
// Id conVerId = [SELECT Id FROM ContentVersion WHERE Id =: conVer.Id].Id;
// system.debug('con ver id :'+conVerId );
// EZRE_ContentVersionTrigClass.updateCandtContent(conVerId);

ContentDocumentLink cdl = new ContentDocumentLink();

cdl.LinkedEntityId = Invoice.Id;
cdl.ShareType = 'V';
cdl.Visibility = 'AllUsers';
cdl.ContentDocumentId = conDocId;
insert cdl;
system.debug('cdlcdlcdl :'+cdl); */
            
            ContentVersion conVer1 = new ContentVersion();
            conVer1.ContentLocation = 'S'; 
            conVer1.PathOnClient = 'PassAccountName'+ ' ' +system.today() + ' - ' +system.today() +'.pdf'; 
            conVer1.Title = 'PassAccountName'+ ' ' +system.today() + '--' +system.today()+'.pdf'; 
            conVer1.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8')); 
            conVer1.Type__c = 'Invoice';            
            insert conVer1;              
            System.debug('ContentVersion : '+ conVer1);
            
            
            
            Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer1.Id].ContentDocumentId;
            system.debug('ContentVersion docid :' +conDocId1);
            
            
            /*   ContentDocumentLink cdl1 = new ContentDocumentLink();

cdl1.LinkedEntityId = Invoice.Id;
cdl1.ShareType = 'I';
cdl1.Visibility = 'AllUsers';
cdl1.ContentDocumentId = conDocId1;
insert cdl1;
system.debug('cdlcdlcdl :'+cdl1);  */
            
            ApexPages.currentPage().getParameters().put('CurrenInvoiceId',Invoice.id);
            test.startTest();
            ODS_EditUploadInvoicecontroller EditUploadController = new ODS_EditUploadInvoicecontroller();
            //  ODS_EditUploadInvoicecontroller.validateOnSubmit(Invoice.Id);
            ODS_EditUploadInvoicecontroller.validateOnSubmitUpdated(Invoice.Id);
            EditUploadController.attachTimeSheet();
            test.stopTest();
        }
    }
    
    static testMethod void attachFile(){
        //fetch user role where portal type is none
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        //fetch system admin profile
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert an internal user
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        System.runAs (portalAccountOwner){
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others'); 
            System.debug('account : '+account);
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            System.debug('odsServices : '+odsServices);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            System.debug('accountServices : '+accountServices);
            
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            System.debug('Invoice : '+Invoice);
            
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            System.debug('contact : '+contact);
            // Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            // System.debug('Invoice : '+Invoice);
            Invoice.Comments__c = 'abc';
            Invoice.Status__c = 'Saved';
            Update Invoice;
            Contact_Account_Service__c InsertContactAccountService = ODS_DataFactory_Test_Utility.InsertContactAccountService(contact.Id,account.Id,odsServices.Id,True,True,false);             
            
            
            ApexPages.currentPage().getParameters().put('filename','abc');
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = 'PassAccountName'+ ' ' +system.today() + ' - ' +system.today() +'.pdf'; 
            conVer.Title = 'PassAccountName'+ ' ' +system.today() + '--' +system.today()+'.pdf'; 
            conVer.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8')); 
            conVer.Type__c = 'Invoice';            
            
            System.debug('ContentVersion : '+ conVer);
            insert conver;
            
            /*  Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
system.debug('ContentVersion docid :' +conDocId);

ContentDocument contdocdelete = new ContentDocument();
contdocdelete = [Select id from ContentDocument where id =: conDocId];

ContentDocumentLink cdl = new ContentDocumentLink();

cdl.LinkedEntityId = Invoice.Id;
cdl.ShareType = 'I';
cdl.Visibility = 'AllUsers';
cdl.ContentDocumentId = conDocId;
insert cdl;
system.debug('cdlcdlcdl :'+cdl); */
            Attachment attachment1 =  ODS_DataFactory_Test_Utility.InsertAttachment('Invoice', 'Invoice for the month of june',Invoice.Id);
            test.startTest();
            PageReference pageRef = Page.EditUploadInvoice;
            ApexPages.currentPage().getParameters().put('AccServiceId',accountServices.id);
            ApexPages.currentPage().getParameters().put('CurrenInvoiceId',Invoice.id);
            
            ODS_EditUploadInvoicecontroller EditUploadController = new ODS_EditUploadInvoicecontroller();
            EditUploadController.filename = System.today() +'filename';
            EditUploadController.attachFile();
            string attachid = attachment1.id;
            EditUploadController.AttachmentToDelete = attachid;
            EditUploadController.AttachmentType = '';
            EditUploadController.DeleteAttachment();
            test.stopTest();
        }
    }
    
    
    static testMethod void EditUploadInvoiceReject(){
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        System.runAs (portalAccountOwner){
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others'); 
            System.debug('account : '+account);
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            System.debug('odsServices : '+odsServices);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            userAccount.Role_in_Account__c = 'Account Manager';
            update userAccount;
            system.debug('userAccount :' + userAccount);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            System.debug('accountServices : '+accountServices);
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            System.debug('Invoice : '+Invoice);
            Invoice.Status__c = 'Submitted';
            Invoice.Invoice_ID__c = Invoice.Id;
            Invoice.Comments__c = 'Demandblue testing';
            Update Invoice;
            
            
            
            Attachment attachment1 = new Attachment();
            attachment1.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attachment1.body=bodyBlob;
            attachment1.parentId=Invoice.id;
            insert attachment1;
            
            
            Contact_Account_Service__c InsertContactAccountService = ODS_DataFactory_Test_Utility.InsertContactAccountService(contact.Id,account.Id,odsServices.Id,True,True,false);             
            
            System.debug('InsertContactAccountService : '+InsertContactAccountService);
            
            ODSInvoiceSessionData__c userSession = ODSInvoiceSessionData__c.getValues( userInfo.getUserId() );
            test.startTest();
            PageReference pageRef = Page.EditUploadInvoice;
            ApexPages.currentPage().getParameters().put('AccServiceId',accountServices.id);
            ApexPages.currentPage().getParameters().put('CurrenInvoiceId',Invoice.id);
            ODS_EditUploadInvoicecontroller EditUploadController = new ODS_EditUploadInvoicecontroller();
            
            ODS_EditUploadInvoicecontroller.getInvoiceSessionDetails();   
            //EditUploadController.InsertUpdateInvoice();
            ODS_EditUploadInvoicecontroller.sendEmail(Invoice.Id, 'phariom@demandblue.com','');
            test.stopTest();
            
        }                        
    }
    
    static testMethod void GetLoggedUserAccountService_Test(){
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        
        
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Customer', true,portalRole.Id);
        
        System.runAs (portalAccountOwner){
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others'); 
            System.debug('account : '+account);
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            System.debug('odsServices : '+odsServices);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            
            
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            System.debug('contact : '+contact);
            Contact_Account_Service__c InsertContactAccountService = ODS_DataFactory_Test_Utility.InsertContactAccountService(contact.Id,account.Id,odsServices.Id,True,True,false);             
            
            
            test.startTest();
            ODS_EditUploadInvoicecontroller EditUploadController = new ODS_EditUploadInvoicecontroller();
            EditUploadController.GetLoggedUserAccountService();            
            test.stopTest();
            
        }
        
        
    }
}