@isTest
public class ODS_Data_Utility_Invoice_Test {
    static testMethod void checkAllReturnVals1() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Manager';            
            update usrAcc;
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            Date Startdte = System.Today().addYears(-1);
            Date Enddte = System.Today().addYears(2);
            Date thisMonthStart = System.Today().toStartOfMonth();
            Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
            Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
            
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'Salesforce');
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
            test.startTest();
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
            User usr1 = ODS_Data_Utility_Invoice.fetchUserById(portalAccountOwner1.Id);
            Invoice__c inv2 =   ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'TestInv',
                                                                                              ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,
                                                                                              System.today().year(),Blob.valueOf('Test'),'TestComments','Submitted',null);
            Invoice__c inv3 =   ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'TestInv',
                                                                                               ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,
                                                                                               System.today().year(),Blob.valueOf('Test'),'TestComments','Submitted',inv2.Id);
             Invoice__c inv4 =   ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'TestInv',
                                                                                               ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,
                                                                                               System.today().year(),Blob.valueOf('Test'),'TestComments','Submitted',inv3.Id);
          //  Invoice__c inv5 =   ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'sfadmin@demndblue.com','test',ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),Blob.valueOf('Test'),'sample123',Blob.valueOf('Test'),'good','','Submitted',startOfWeek1,endOfWeek1);
          /*  Invoice__c inv5 =   ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'TestInv',
                                                                                              ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,
                                                                                              System.today().year(),Blob.valueOf('Test'),'TestComments',inv2.Id,'Submitted',startOfWeek1,endOfWeek1);*/
          //  Invoice__c inv6 =   ODS_Data_Utility_Invoice.updateApprovedRejectedStatus(inv2.Id, 'Approved','It is good');
            
            list<Invoice__c> inv7 =   ODS_Data_Utility_Invoice.GetInvoiceAttachmentId(inv.Id);
          //  string str1 =   ODS_Data_Utility_Invoice.ValidateInvoice(portalAccount1.Id,odsSrv.Id,'','');
            ODS_Data_Utility_Invoice.UpdateInvoiceStatus(inv.Id);
            ODS_Data_Utility_Invoice.UpdateInvoiceStatusAsFalse(inv1.Id);
          //  string str2 =   ODS_Data_Utility_Invoice.ValidateInvoice(portalAccount1.Id,odsSrv.Id,'TestDocument',inv.Id);
           // string str3 =   ODS_Data_Utility_Invoice.ValidateInvoiceUpdated(portalAccount1.Id,odsSrv.Id,inv.Id,'TestDocument');
            string str4 =   ODS_Data_Utility_Invoice.GetInvoiceAttachment(inv.Id);
            
            Account_Services__c[] acs1 = ODS_Data_Utility_Invoice.GetAccountServiceName(portalAccount1.Id,odsSrv.Id);
            Account_Services__c[] acs2 = ODS_Data_Utility_Invoice.fetchAccServcesByServiceAccount(portalAccount1.Id,odsSrv.Id);
            ODS_Data_Utility_Invoice.FetchInvoiceByID(inv2.Id);          
           // ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'sfadmin@demndblue.com','test',ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),Blob.valueOf('Test'),'sample123',Blob.valueOf('Test'),'good',inv2.Id,'Submitted',startOfWeek1,endOfWeek1);
            ODS_Data_Utility_Invoice.DeleteInvoice(inv1.Id);
            ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetails(accSrvc.Id,portalAccount1.Id,odsSrv.Id,ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),'ABC',inv.Id,'Saved',strtDt,endDt,'sfdc@demandblue.com','','','');
            ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetails(accSrvc.Id,portalAccount1.Id,odsSrv.Id,ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),'ABC','','Saved',strtDt,endDt,'sfdc@demandblue.com','','','');
            test.stopTest();
        }
    }
    static testMethod void checkAllReturnVals2() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            test.startTest();
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Manager';            
            update usrAcc;
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            Date Startdte = System.Today().addYears(-1);
            Date Enddte = System.Today().addYears(2);
            Date thisMonthStart = System.Today().toStartOfMonth();
            Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
            Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
            
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'Salesforce');
            accSrvc.Invoice_Frequency__c = 'Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
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
            User usr1 =  ODS_Data_Utility_Invoice.fetchUserById(UserInfo.getUserId());
            List<Invoice__c> inv1 =  ODS_Data_Utility_Invoice.FetchInvoice(portalAccount1.Id,odsSrv.Id,ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),'LastModifiedDate');
            List<Invoice__c> inv2 = ODS_Data_Utility_Invoice.FetchInvoice('All',odsSrv.Id,ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),'LastModifiedDate');
            List<Invoice__c> inv3 = ODS_Data_Utility_Invoice.FetchInvoice(portalAccount1.Id,'All',ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),'LastModifiedDate');
            List<Invoice__c> inv4 = ODS_Data_Utility_Invoice.FetchInvoice('All','All',ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),'LastModifiedDate');
            List<Invoice__c> inv5 = ODS_Data_Utility_Invoice.FetchInvoice(portalAccount1.Id,odsSrv.Id,'Month',System.today().year(),'LastModifiedDate');
            List<Invoice__c> inv6 = ODS_Data_Utility_Invoice.FetchInvoice(portalAccount1.Id,odsSrv.Id,'Month',null,'LastModifiedDate');
            test.stopTest();
            
        }
    }
 
    
    /*   static testMethod void checkAllReturnVals3() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id); 
   		    system.runAs(portalAccountOwner1) {
            test.startTest();
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas;
                
               
            }
                                                                                              
       }  
*/
                                                                                                     
}