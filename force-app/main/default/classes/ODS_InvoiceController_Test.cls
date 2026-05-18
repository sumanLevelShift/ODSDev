/**
 * @author          Gnana Prakash
 * @version          1.0 
 * @date             11-Jan-2017
 * @Status           Developed
 * @description      This is the Test class for Invoice controller
 */

@isTest
public class ODS_InvoiceController_Test
{
     /// <OBJECTIVE>
    /// To test the Invoice fetch with filter conditions
    /// </OBJECTIVE>
    static testMethod void FetchInvoiceList_PositiveTest()
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
             Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
             
             Date InvoiceStartDate= date.parse('11/01/2016');
             Date InvoiceEndDate = date.parse('11/30/2016');            
             test.startTest();
             ApexPages.currentPage().getParameters().put('AccServiceId',accountServices.id);
             ApexPages.currentPage().getParameters().put('CurrenInvoiceId',Invoice.id);
             ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
             InvoiceController.AccountId = account.Id;
             InvoiceController.ServiceId = odsServices.Id;
             InvoiceController.FetchInvoiceList(account.Id,odsServices.Id,'January',2017);
             InvoiceController.FetchInvoiceList(account.Id,odsServices.Id,'',0);
             InvoiceController.GetCustomerByAccountServiceID();
             InvoiceController.getYears();
             InvoiceController.AddInvoice();
             InvoiceController.ViewInvoice();
            // InvoiceController.GetValue();
            // InvoiceController.getInvoiceList();
            
            ODSInvoiceSessionData__c invSession = ODS_InvoicepageController.getInvoiceSessionDetails();            
             test.stopTest();   
            
         }    
    }
    
   
    
     /// <OBJECTIVE>
    /// To test the Invoice fetch with filter conditions
    /// </OBJECTIVE>
    static testMethod void FetchInvoiceList_PositiveTest_WithFilterCondition()
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
             Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
             Date InvoiceStartDate= date.parse('11/01/2016');
             Date InvoiceEndDate = date.parse('11/30/2016');
            
             test.startTest();
            ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
            InvoiceController.FromDate = '';
            InvoiceController.ToDate = '';
            InvoiceController.AccountId = account.Id;
            InvoiceController.ServiceId = odsServices.Id;
            InvoiceController.FetchInvoiceList(account.Id,odsServices.Id,'January',2017);
            string s = 'test';
           // InvoiceController.setSortDirection(s);
            InvoiceController.getSortDirection();
            InvoiceController.sortExpression = 'test';
            InvoiceController.fetchInvoiceListCommnadLink();
             //InvoiceController.FetchInvoiceList(account.Id,odsServices.Id,'','');
             test.stopTest();   
            
         }    
    }
    
    /// <OBJECTIVE>
    /// To test the Delete Invoice 
    /// </OBJECTIVE>
    static testMethod void Delete_PositiveTest()
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
             Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
             Date InvoiceStartDate= date.parse('11/01/2016');
             Date InvoiceEndDate = date.parse('11/30/2016');
             Attachment attachment =  ODS_DataFactory_Test_Utility.InsertAttachment('Invoice', 'Invoice for the month of june',Invoice.Id); 
             Invoice__c Invoice1 = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
             Attachment attachment1 =  ODS_DataFactory_Test_Utility.InsertAttachment('Invoice1', 'Invoice for the month of july',Invoice1.Id); 
            
             test.startTest();
             ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
            
             InvoiceController.AccountId = account.Id;
             InvoiceController.ServiceId = odsServices.Id;
             ApexPages.currentPage().getParameters().put('InvoiceId',Invoice.Id);
             
             InvoiceController.DeleteInvoice();
             test.stopTest(); 
         }    
    }
    
     static testMethod void UpdateInvoiceAsTrueTest()
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
             Invoice__c Invoice = new Invoice__c();
             Invoice.Comments__c = 'Test Comments';
             Invoice.Month__c = 'Month';
             Invoice.Year__c =  2020;  
             Invoice.Paid_unpaid__c = False;
             Invoice.Account_Services__c = accountServices.id;
             
             insert Invoice;
             
             test.startTest();
             ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
             ApexPages.currentPage().getParameters().put('InvoiceId',Invoice.Id);
             InvoiceController.UpdateInvoiceStatus(); 
             test.stopTest(); 
        }
     }
    
     static testMethod void UpdateInvoiceAsFalseTest()
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
         
         Invoice__c Invoice = new Invoice__c();
         Invoice.Comments__c = 'Test Comments';
         Invoice.Month__c = 'Month';
         Invoice.Year__c =  2020;  
         Invoice.Paid_unpaid__c = True;
         Invoice.Account_Services__c = accountServices.id;
         
         insert Invoice;
         
         test.startTest();
         ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
         ApexPages.currentPage().getParameters().put('InvoiceId',Invoice.Id);
         InvoiceController.UpdateInvoiceStatusAsFalse(); 
         test.stopTest(); 
        }
     }
     
    /// <OBJECTIVE>
    /// To test the Upload Invoice 
    /// </OBJECTIVE>
    static testMethod void Upload_PositiveTest()
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
             test.startTest();
             ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
             Invoice__c Invc = new Invoice__c(Month__c = 'January', Year__c = 2016, Comments__c = 'Test Comments');
             InvoiceController.AccountId = account.Id;
             InvoiceController.ServiceId = odsServices.Id;
             InvoiceController.fileName = 'Invoice for the month of june';
             InvoiceController.blobBody = Blob.valueOf('Invoice for the month of June');
             InvoiceController.Invoice =  Invc;
            // InvoiceController.UploadInvoice();          
             test.stopTest(); 
         }    
    }
    
    /// <OBJECTIVE>
    /// To test the GetInvoiceAttachment
    /// </OBJECTIVE>
    static testMethod void GetInvoiceAttachment_PositiveTest()
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
             Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
             Date InvoiceStartDate= date.parse('11/01/2016');
             Date InvoiceEndDate = date.parse('11/30/2016');
             Attachment attachment =  ODS_DataFactory_Test_Utility.InsertAttachment('Invoice', 'Invoice for the month of june',Invoice.Id); 
            
             test.startTest();
             //ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
            
             ODS_InvoicepageController.GetInvoiceAttachment(Invoice.Id);
             test.stopTest(); 
         }    
    }
    
    /// <OBJECTIVE>
    /// To test the Validate Invoicemethod
    /// </OBJECTIVE>
    static testMethod void ValidateUploadInvoice_PositiveTest()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {       
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                            portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            Contact cont = ODS_DataFactory_Test_Utility.UpdateContactApprover(contact1.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
         
            
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
           // List<Contact_Account_Service__c> contactAccServcList = ODS_Data_Utility.fetchContactAccountService(cont.id,'Demandblue Demo Account');

            Date InvoiceStartDate= date.parse('11/01/2016');
            Date InvoiceEndDate = date.parse('11/30/2016');
            Attachment attachment =  ODS_DataFactory_Test_Utility.InsertAttachment('Invoice', 'Invoice for the month of june',Invoice.Id); 
            
            test.startTest();
            ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
           // ODS_InvoicepageController.ValidateUploadInvoice(portalAccount1.Id, odsSrv.Id, Invoice.Id, 'Test File Name');
            //ODS_InvoicepageController.sendEmail(Invoice.id, 'test123@testmail.com');
            
            test.stopTest(); 
         }    
    }
    
    /// <OBJECTIVE>
    /// To test the Validate Invoicemethod
    /// </OBJECTIVE>
    static testMethod void FetchInvoiceList_PositiveTest2()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {       
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                            portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Account Manager	',portalAccountOwner1.Id,odsSrv.Id);
            Contact cont = ODS_DataFactory_Test_Utility.UpdateContactApprover(contact1.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            Invoice__c Invoice = ODS_DataFactory_Test_Utility.InsertInvoice(accountServices.Id,'January',2016,'Comments');
            Date InvoiceStartDate= date.parse('11/01/2016');
            Date InvoiceEndDate = date.parse('11/30/2016');
            Attachment attachment =  ODS_DataFactory_Test_Utility.InsertAttachment('Invoice', 'Invoice for the month of june',Invoice.Id); 
            
            test.startTest();
            ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
            InvoiceController.AccountId = portalAccount1.Id;
            InvoiceController.ServiceId = odsSrv.Id;
            InvoiceController.FromDate = '';
            InvoiceController.ToDate = '';
            InvoiceController.GetSearchResults();
            InvoiceController.enableDisablePaginationLinks();
            InvoiceController.showLast();
            InvoiceController.showFirst();
            InvoiceController.showNext();
            InvoiceController.showPrevious();
          //  InvoiceController.IsCustomer=true;
          //  InvoiceController.ShowDisclaimer=false;
          //  InvoiceController.ShowUploadInvoice=false;
            
            test.stopTest(); 
        }            
    }
     static testMethod void UploadInvoiceList_PositiveTest2()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {       
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                            portalAccountOwner1.Id, True,1000,'95543567654', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Is_Approver__c = True;
            update contact1;
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                            'test12345@test.com', contact1.Id,'Customer');
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            Contact cont = ODS_DataFactory_Test_Utility.UpdateContactApprover(contact1.Id);
           // string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            Date Startdte = System.Today().addYears(-1);
            Date Enddte = System.Today().addYears(2);
            Date thisMonthStart = System.Today().toStartOfMonth();
            Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
            Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'JHCSFDC');
            accSrvc.Invoice_Frequency__c = 'Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            accSrvc.Document_Suffix__c = 'cs';
            update accSrvc;
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            update objTmeShtCst;
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
            insertTimeSheetWeek1.Status__c = 'Submitted';
            insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
            update insertTimeSheetWeek1;
            Invoice__c inv = new Invoice__c();
            inv.Account_Services__c = accSrvc.Id;
            Date StartDate = accSrvc.Contract_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');               
            Date EndDate = accSrvc.Contract_End_Date__c;
            String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            inv.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv.Comments__c = 'Test'+String.valueOf(System.Today());
            //Custom setting to get month name 
            Integer mNumb = System.today().month();
            String mName = '';
            if(mNumb==1)mName='January';else if(mNumb==2)mName='February';
            else if(mNumb==3)mName='March';else if(mNumb==4)mName='April';
            else if(mNumb==5)mName='May';else if(mNumb==6)mName='June';
            else if(mNumb==7)mName='July';else if(mNumb==8)mName='August';
            else if(mNumb==9)mName='September';else if(mNumb==10)mName='October';
            else if(mNumb==11)mName='November';else mName='December';
            ODS_Invoice_Month__c invm = new ODS_Invoice_Month__c();
            invm.name=String.valueOf(System.Today().month());
            invm.MonthName__c=mName; 
            insert invm;             
            inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv.Year__c = System.today().year();
            insert inv;
            
            Invoice__c inv1 = new Invoice__c();
            inv1.Account_Services__c = accSrvc.Id;
            Date StartDate1 = accSrvc.Contract_Start_Date__c; 
            String FromDate1 = DateTime.newInstance(StartDate1.year(),StartDate1.month(),StartDate1.day()).format('MM/dd/yyyy');               
            Date EndDate1 = accSrvc.Contract_End_Date__c;
            String ToDate1 = DateTime.newInstance(EndDate1.year(),EndDate1.month(),EndDate1.day()).format('MM/dd/yyyy');
            inv1.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv1.Comments__c = 'Test'+String.valueOf(System.Today());                         
            inv1.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv1.Year__c = System.today().year();
            inv1.Status__c = 'Submitted';
            insert inv1;
            
            Attachment att = new Attachment();
            att.Body = Blob.valueOf('TestBody');
            att.Name = 'TestDocument';
            att.ParentId = inv.Id;
            insert att; 
            test.startTest();
            ODS_InvoicepageController InvoiceController = new ODS_InvoicepageController();
            InvoiceController.AccountId = portalAccount1.Id;
            InvoiceController.ServiceId = odsSrv.Id;
           // InvoiceController.AccountId = account.Id;
           // InvoiceController.ServiceId = odsServices.Id;
            InvoiceController.fileName = 'Invoice for the month of june';
            InvoiceController.blobBody = Blob.valueOf('Invoice for the month of June');
            InvoiceController.Invoice =  inv;
            InvoiceController.InvoiceStatus = 'Submitted';
            InvoiceController.toAddress = 'test@gmail.com';
            InvoiceController.BillingStartDate = startOfWeek1;
             InvoiceController.BillingEndDate =   endOfWeek1; 
         //   InvoiceController.UploadInvoice(); 
            ODS_InvoicepageController InvoiceController1 = new ODS_InvoicepageController();
            InvoiceController1.AccountId = portalAccount1.Id;
            InvoiceController1.ServiceId = odsSrv.Id;
            InvoiceController1.Invoice =  inv;
            InvoiceController1.InvoiceStatus = 'Approved';
          //  InvoiceController1.InvoiceComments = 'Looks Good';
        //    InvoiceController1.UploadInvoice();
            ODS_InvoicepageController InvoiceController2 = new ODS_InvoicepageController();
            InvoiceController2.AccountId = portalAccount1.Id;
            InvoiceController2.ServiceId = odsSrv.Id;
            InvoiceController2.Invoice =  inv;
            //InvoiceController2.InvoiceComments = 'Need To Improve it';
            InvoiceController2.InvoiceStatus = 'Rejected';
          //  InvoiceController2.UploadInvoice();
          //  ODS_InvoicepageController.sendApproveRejectEmail(inv.id,'Rejected');
           // ODS_InvoicepageController.sendApproveRejectEmail(inv.id,'Approved');
            test.stopTest(); 
        }            
    }
    
    
}