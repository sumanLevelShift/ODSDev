@isTest
public class ODS_Invoice_Monthly_Test
{
    static TestMethod void generateInvoiceInsert_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu1','testuser1@testmail.com','UTF-8','Indumathi1',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test1231@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount12',
                                    'California', True,2000,'9433578855', 'Others', 'ODS Project');                             
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test12','McTesty1', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@test.com';
            update contact1;
            portalAccount1.ODS_Invoice_Account_Number__c = 'C55';
            portalAccount1.Invoice_Type__c = 'Paper';
            portalAccount1.Primary_Customer_Contact__c = contact1.Id;
            portalAccount1.InvoiceContact__c = contact1.Id;
            portalAccount1.BillingCity = 'Chennai';
            portalAccount1.BillingStreet = 'Siruseri';
            portalAccount1.BillingState = 'Tamilnadu';            
            portalAccount1.BillingCountry = 'India';
            portalAccount1.BillingPostalcode = '640000';
            portalAccount1.ODS_Invoice_Count__c = 10;
            portalAccount1.SOW__c = 'Fully Executed';
            portalAccount1.SOW_Start_Date__c = System.today();
            portalAccount1.SOW_End_Date__c = System.today().addDays(10);
            //portalAccount1.SOW_Status_Date__c = System.today();
            portalAccount1.User__c =  UserInfo.getUserId();
            update portalAccount1;
            
            /*ODS_Invoice_EmailControl__c cst = new ODS_Invoice_EmailControl__c();
            cst.name = 'sendInvoiceEmail';
            cst.isAllowed__c = true;
            insert cst;
            ODS_Invoice_EmailControl__c cst1 = new ODS_Invoice_EmailControl__c();
            cst1.name = 'ccPracticeHead';
            cst1.isAllowed__c = false;
            insert cst1;*/
            Integer mNumb = System.Today().month();
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
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('ODSTNETTest12','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Aruns',portalAccount1.Id,odsSrv.Id);

            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);

            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            try {                
                Account_Services__c accSrvc = new Account_Services__c();
                accSrvc.Account__c = portalAccount1.id;
                accSrvc.Contract_Start_Date__c = strtDt;          
                accSrvc.Contract_End_Date__c = endDt;
                accSrvc.ODS_Hourly_Rate_Amount__c = 150;
                accSrvc.ODS_Services__c = odsSrv.id;
                accSrvc.Retainer_Fee_Amount__c = 1000; 
                accSrvc.Contract_Term__c = 'Net 30';
                accSrvc.Subscription_Fee_Discount__c = 50;
                accSrvc.Purchase_Order__c = 'Test1';
                accSrvc.Retainer_Fee_Frequency_Type__c = 'Monthly';
                accSrvc.Invoice_Monthly_Subscription_Discount__c = 10;
                accSrvc.Technical_Account_manager__c = portalAccountOwner1.Id;
                accSrvc.Document_Suffix__c = 'ODSTest';
                accSrvc.Trigger_Subscription_Invoice__c = true;
                accSrvc.Do_not_send_invoice__c = false;
                accSrvc.Invoice_MnthSubs_Date__c = null;
                accSrvc.Ignore_Validations__c = true;
                insert accSrvc;                             
            }catch(Exception err) {
                System.debug('insert error: '+err.getMessage());
            }                             
                                                 
        }         
    }
    
    static TestMethod void generateInvoiceUpdate_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser2@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test1232@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount23',
                                    'California', True,2000,'9433578875', 'Others', 'ODS Project');                             
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test23','McTesty2', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test2@test.com';
            update contact1;
            portalAccount1.ODS_Invoice_Account_Number__c = 'C455';
            portalAccount1.Invoice_Type__c = 'Paper';
            portalAccount1.Primary_Customer_Contact__c = contact1.Id;
            portalAccount1.InvoiceContact__c = contact1.Id;
            portalAccount1.BillingCity = 'Chennai';
            portalAccount1.BillingStreet = 'Siruseri';
            portalAccount1.BillingState = 'Tamilnadu';            
            portalAccount1.BillingCountry = 'India';
            portalAccount1.BillingPostalcode = '640000';
            portalAccount1.ODS_Invoice_Count__c = 10;
            portalAccount1.SOW_Start_Date__c = System.today();
            portalAccount1.SOW_End_Date__c = System.today().addDays(10);
            portalAccount1.SOW__c = 'Fully Executed';
            //portalAccount1.SOW_Status_Date__c = System.today().adddays(-1);
            portalAccount1.User__c =  UserInfo.getUserId();
            update portalAccount1;
            
            /*ODS_Invoice_EmailControl__c cst = new ODS_Invoice_EmailControl__c();
            cst.name = 'sendInvoiceEmail';
            cst.isAllowed__c = true;
            insert cst;
            ODS_Invoice_EmailControl__c cst1 = new ODS_Invoice_EmailControl__c();
            cst1.name = 'ccPracticeHead';
            cst1.isAllowed__c = false;
            insert cst1;*/
            Integer mNumb = System.Today().month();
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
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('ODsDTest13','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);

            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);

            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            
            Account_Services__c accSrvc = new Account_Services__c();
                accSrvc.Account__c = portalAccount1.id;
                accSrvc.Contract_Start_Date__c = strtDt;          
                accSrvc.Contract_End_Date__c = endDt;
                accSrvc.ODS_Hourly_Rate_Amount__c = 150;
                accSrvc.ODS_Services__c = odsSrv.id;
                accSrvc.Retainer_Fee_Amount__c = 1000; 
                accSrvc.Contract_Term__c = 'Net 30';
                accSrvc.Subscription_Fee_Discount__c = 50;
                accSrvc.Purchase_Order__c = 'Test';
                accSrvc.Retainer_Fee_Frequency_Type__c = 'Upfront';
                accSrvc.Technical_Account_manager__c = portalAccountOwner1.Id;
                accSrvc.Document_Suffix__c = 'ODSTest';
                accSrvc.Invoice_MnthSubs_Date__c = null;
                accSrvc.Invoice_Monthly_Subscription_Discount__c = 10;
                accSrvc.Invoice_Upfront_Discount__c = 10;
                accSrvc.Invoice_Upfront_Months__c = 10;
                accSrvc.Trigger_Subscription_Invoice__c = false;
                accSrvc.Do_not_send_invoice__c = false;
                accSrvc.Ignore_Validations__c = true;
            insert accSrvc;
            
            accSrvc.Retainer_Fee_Frequency_Type__c = 'Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            accSrvc.Trigger_Subscription_Invoice__c = true;
            accSrvc.Do_not_send_invoice__c = false;
            accSrvc.Invoice_MnthSubs_Date__c = null;
            try {
                update accSrvc;  
            }catch(Exception err) {
                System.debug('update error: '+err.getMessage());
            }                                     
        }         
    }
}