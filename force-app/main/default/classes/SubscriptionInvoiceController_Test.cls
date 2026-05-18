@isTest
public class SubscriptionInvoiceController_Test {
    static testMethod void FetchAccSer_PositiveTest()
    {
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                                     
        System.runAs (portalAccountOwner) 
        {                      
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others');   
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
                 // Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
           // System.debug('Invoice : '+Invoice);
            Invoice__c Invoicetest = new Invoice__c();
            Invoicetest.Account_Services__c = accountServices.Id;
            Invoicetest.Month__c = 'January';
            Invoicetest.Year__c = 2022;
            Invoicetest.Paid_unpaid__c = true;
           // Invoicetest.Name = 'Invoice test';
            Invoicetest.Comments__c = 'abc';
            Invoicetest.Status__c = 'Posted';
            Invoicetest.Billing_Start_Date__c=system.today();
            Invoicetest.Billing_End_Date__c=system.today()+5;
            Invoicetest.Invoice_Type__c = 'Subscription';
            insert Invoicetest;
            System.debug('Invoice1 : '+Invoicetest);
            
           // Invoice__c Invoicesectest = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2017,'Commentss');
           // System.debug('Invoice : '+Invoice);
                       Invoice__c Invoices = new Invoice__c();

            Invoices.Account_Services__c = accountServices.Id;
            Invoices.Month__c = 'January';
            Invoices.Year__c = 2021;
            Invoices.Paid_unpaid__c = true;
            Invoices.Comments__c = 'Test';
            Invoices.Status__c = 'Posted';
            
            Invoices.Billing_Start_Date__c=system.today();
            Invoices.Billing_End_Date__c=system.today()+5;
            Invoices.Invoice_Type__c = 'Subscription';
            insert Invoices;
            System.debug('Invoice1 : '+Invoices);
            
             ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            cv.Type__c='Invoice';
            //cv.Candidate_ID__c=objCand.id;
            Insert cv;
            
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = Invoicetest.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;
            Attachment att=new Attachment();
            att.Body=Blob.valueOf('ss');
            att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att.parentId=Invoicetest.id;
            insert att;
            
            Attachment att1=new Attachment();
            att1.Body=Blob.valueOf('ss');
            att1.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att1.parentId=Invoicetest.id;
            insert att1;
            test.startTest();
            PageReference pageRef = Page.SubscriptionInvoice;
            Test.setCurrentPage(pageRef);
            SubscriptionInvoiceController.getInvoiceSessionDetails();
            SubscriptionInvoiceController SubInvoiceController = new SubscriptionInvoiceController();
           // SubInvoiceController.AccountServiceID =odsServices.id;
            SubInvoiceController.ServiceId = 'All';
            SubInvoiceController.CurrentPage = 0; 
            SubInvoiceController.AccountId = account.id;
            SubInvoiceController.PageNumber = 1;
            SubInvoiceController.GetAccountServices();
            SubInvoiceController.getSortDirection();
            ODSInvoiceSessionData__c invSession = ODS_InvoicepageController.getInvoiceSessionDetails();            
            test.stopTest();   
            
        }    
    }
    static testMethod void FetchAccSer_PositiveTest1()
    {
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                                     
        System.runAs (portalAccountOwner) 
        {                      
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others');   
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
            Invoice__c inv1 = new Invoice__c();
            inv1.Account_Services__c = accountServices.Id;
            Date StartDate1 = accountServices.Contract_Start_Date__c; 
            String FromDate1 = DateTime.newInstance(StartDate1.year(),StartDate1.month(),StartDate1.day()).format('MM/dd/yyyy');               
            Date EndDate1 = accountServices.Contract_End_Date__c;
            String ToDate1 = DateTime.newInstance(EndDate1.year(),EndDate1.month(),EndDate1.day()).format('MM/dd/yyyy');
           // inv1.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            
            insert inv1;
            
            Attachment att = new Attachment();
            att.Body = Blob.valueOf('TestBody');
            att.Name = 'TestDocument';
            att.ParentId = inv1.Id;
            insert att; 
            test.startTest();
           
            SubscriptionInvoiceController.getInvoiceSessionDetails();
            
            SubscriptionInvoiceController SubInvoiceController = new SubscriptionInvoiceController();
             SubInvoiceController.AccountId = account.Id;
            SubInvoiceController.ServiceId = accountServices.Id;
           // SubInvoiceController.getAccDetails();
            SubInvoiceController.ServiceId = odsServices.Id;
            SubInvoiceController.GetAccountServices();
            SubInvoiceController.GetLoggedUserAccountService();
            SubInvoiceController.UpdateInvoiceStatusAsFalse();
            ODSInvoiceSessionData__c invSession = ODS_InvoicepageController.getInvoiceSessionDetails();            
            test.stopTest();   
            
        }    
    }
    
    static testMethod void FetchAccSer_PositiveTest2()
    {
        
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                                     
        System.runAs (portalAccountOwner) 
        {                      
            Account account = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                                                                                  portalAccountOwner.Id, True,1000,'95543567654','Others','Others');   
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(account.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(account.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');                                   
            Contact contact = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, account.Id,'Others','Others');    
           // Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
           // Invoice__c Invoices = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2017,'Commentss');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact.Id,'Customer');
          
             Invoice__c Invoicetest = new Invoice__c();
            Invoicetest.Account_Services__c = accountServices.Id;
            Invoicetest.Month__c = 'January';
            Invoicetest.Year__c = 2022;
            Invoicetest.Paid_unpaid__c = true;
           // Invoicetest.Name = 'Invoice test';
            Invoicetest.Comments__c = 'abc';
            Invoicetest.Status__c = 'Posted';
            Invoicetest.Billing_Start_Date__c=system.today();
            Invoicetest.Billing_End_Date__c=system.today()+5;
            Invoicetest.Invoice_Type__c = 'Subscription';
             Invoicetest.Invoice_Date__c =  system.today();
            insert Invoicetest;
            System.debug('Invoice1 : '+Invoicetest);
            
           // Invoice__c Invoicesectest = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2017,'Commentss');
           // System.debug('Invoice : '+Invoice);
                       Invoice__c Invoices = new Invoice__c();

            Invoices.Account_Services__c = accountServices.Id;
            Invoices.Month__c = 'January';
            Invoices.Year__c = 2021;
            Invoices.Paid_unpaid__c = true;
            Invoices.Comments__c = 'Test';
            Invoices.Status__c = 'Posted';
            
            Invoices.Billing_Start_Date__c=system.today();
            Invoices.Billing_End_Date__c=system.today()+5;
            Invoices.Invoice_Type__c = 'Subscription';
            Invoices.Invoice_Date__c =  system.today();
            //Invoices.Invoice_Month__c = 'January';
            insert Invoices;
            System.debug('Invoice1 : '+Invoices);
            
             ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            cv.Type__c='Invoice';
            //cv.Candidate_ID__c=objCand.id;
            Insert cv;
            
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = Invoicetest.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;
            Attachment att=new Attachment();
            att.Body=Blob.valueOf('ss');
            att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att.parentId=Invoicetest.id;
            insert att;
            
            Attachment att1=new Attachment();
            att1.Body=Blob.valueOf('ss');
            att1.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att1.parentId=Invoicetest.id;
            insert att1;
            test.startTest();
            SubscriptionInvoiceController.getInvoiceSessionDetails();
            
            SubscriptionInvoiceController SubInvoiceContr = new SubscriptionInvoiceController();
            ApexPages.currentPage().getParameters().put('AccServiceId',accountServices.id);
            SubInvoiceContr.AccountId = account.Id;
            SubInvoiceContr.ServiceId = odsServices.Id;
            SubInvoiceContr.UpdateInvoiceStatus();
            SubInvoiceContr.UpdateInvoiceStatusAsFalse();
            SubInvoiceContr.fetchInvoiceListCommnadLink();
            SubInvoiceContr.GetCustomerByAccountServiceID();
            SubInvoiceContr.GetAccountServices();
            SubInvoiceContr.GetLoggedUserAccountService();
            SubInvoiceContr.AssignPassedAccountService();
           
         
            test.stopTest();   
            
        }    
    }
       static testMethod void PortalCustomer_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {       
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                            portalAccountOwner1.Id, True,1500,'9866857745', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);

            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'SFDC');
            
           
             Invoice__c Invoicetest = new Invoice__c();
            Invoicetest.Account_Services__c = accSrvc.Id;
            Invoicetest.Month__c = 'January';
            Invoicetest.Year__c = 2022;
            Invoicetest.Paid_unpaid__c = true;
           // Invoicetest.Name = 'Invoice test';
            Invoicetest.Comments__c = 'abc';
            Invoicetest.Status__c = 'Posted';
            Invoicetest.Billing_Start_Date__c=system.today();
            Invoicetest.Billing_End_Date__c=system.today()+5;
            Invoicetest.Invoice_Type__c = 'Subscription';
             Invoicetest.Invoice_Date__c =  system.today();
            insert Invoicetest;
            System.debug('Invoice1 : '+Invoicetest);
            
           // Invoice__c Invoicesectest = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2017,'Commentss');
           // System.debug('Invoice : '+Invoice);
                       Invoice__c Invoices = new Invoice__c();

            Invoices.Account_Services__c = accSrvc.Id;
            Invoices.Month__c = 'January';
            Invoices.Year__c = 2021;
            Invoices.Paid_unpaid__c = true;
            Invoices.Comments__c = 'Test';
            Invoices.Status__c = 'Posted';
            
            Invoices.Billing_Start_Date__c=system.today();
            Invoices.Billing_End_Date__c=system.today()+5;
            Invoices.Invoice_Type__c = 'Subscription';
            Invoices.Invoice_Date__c =  system.today();
            //Invoices.Invoice_Month__c = 'January';
            insert Invoices;
            System.debug('Invoice1 : '+Invoices);
            
             ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            cv.Type__c='Invoice';
            //cv.Candidate_ID__c=objCand.id;
            Insert cv;
            
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = Invoicetest.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;
            Attachment att=new Attachment();
            att.Body=Blob.valueOf('ss');
            att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att.parentId=Invoicetest.id;
            insert att;
            
            Attachment att1=new Attachment();
            att1.Body=Blob.valueOf('ss');
            att1.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att1.parentId=Invoicetest.id;
            insert att1;
            test.startTest();
            SubscriptionInvoiceController.getInvoiceSessionDetails();
            
            SubscriptionInvoiceController SubInvoiceContr = new SubscriptionInvoiceController();
           // ApexPages.currentPage().getParameters().put('AccServiceId',accSrvc.id);
            SubInvoiceContr.AccountId = portalAccount1.Id;
            SubInvoiceContr.ServiceId = odsSrv.Id;
            SubInvoiceContr.UpdateInvoiceStatus();
            SubInvoiceContr.UpdateInvoiceStatusAsFalse();
            SubInvoiceContr.fetchInvoiceListCommnadLink();
            SubInvoiceContr.GetCustomerByAccountServiceID();
            SubInvoiceContr.GetAccountServices();
            SubInvoiceContr.GetLoggedUserAccountService();
            SubInvoiceContr.AssignPassedAccountService();
            SubInvoiceContr.enableDisablePaginationLinks();
            SubInvoiceContr.showLast();
            SubInvoiceContr.showFirst();
            SubInvoiceContr.showNext();
            SubInvoiceContr.showPrevious();
         
            test.stopTest(); 
        }
    }
    public static ContentVersion CreateContentVersion(String strPublshLocationId,id CandId, Blob blobVersionData,
                                                      String strPathClient, String strTitle)    
    {            
        ContentVersion objContentVersion = new ContentVersion();  
        
        objContentVersion.FirstPublishLocationId = strPublshLocationId; 
        objContentVersion.Candidate_Id__c = CandId;      
        objContentVersion.VersionData = blobVersionData; 
        objContentVersion.PathOnclient = strPathClient;
        objContentVersion.Title = strTitle;  
        
        insert objContentVersion; 
        return objContentVersion;                    
    }
    
}