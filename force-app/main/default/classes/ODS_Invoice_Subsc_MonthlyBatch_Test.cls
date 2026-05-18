@isTest
public class ODS_Invoice_Subsc_MonthlyBatch_Test
{
    static TestMethod void runBatch_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                    'California', True,2000,'9433578865', 'Others', 'ODS Project');                             
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
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
            portalAccount1.SOW__c = 'Fully Executed';
            portalAccount1.User__c =  UserInfo.getUserId();
            update portalAccount1;
            
            /*ODS_Invoice_EmailControl__c cst = new ODS_Invoice_EmailControl__c();
            cst.name = 'ccPracticeHead';
            cst.isAllowed__c = false;
            insert cst;*/
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
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);

            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);

            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(5);
            date aprveDt = strtDt.adddays(6);
            Date Startdte = date.parse('11/01/2016');
            Date Enddte = date.parse('11/30/2016');
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'ODSDOTNET');
            accSrvc.Retainer_Fee_Frequency_Type__c = 'Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            accSrvc.Invoice_Monthly_Subscription_Discount__c = 10;
            accSrvc.Purchase_Order__c = 'test';
            try {
                update accSrvc;  
            }catch(Exception err) {
                System.debug(err.getMessage());
            }
            
            Id accSrvcId = accSrvc.Id;
            
            String monthlyQry = 'SELECT Id,Account__c,Account__r.Name,Account__r.SOW__c,'+
                            'Account__r.Primary_Customer_Email_OptOut__c,'+
                            'Account__r.Primary_Customer_Email_Id__c,Account__r.BillingStreet,'+
                            'Account__r.BillingCity,Account__r.BillingState,Account__r.BillingCountry,Account__r.BillingPostalCode,'+
                            'Account__r.Invoice_Type__c,Account__r.ODS_Invoice_Contact_Email__c,'+
                            'Retainer_Fee_Frequency_Type__c,Retainer_Fee_Amount__c,Purchase_Order__c,'+
                            'Subscription_Fee_Discount__c,Contract_Start_Date__c,Invoice_Monthly_Subscription_Discount__c,'+
                            'Contract_End_Date__c,Invoice_MnthSubs_Date__c,Invoice_Sent__c,'+
                            'Contract_Term__c,Account__r.SOW_Status_Date__c,ODS_Service_Name__c,'+
                            'Account__r.ODS_Invoice_Account_Number__c,Account__r.ODS_Invoice_Count__c'+
                            ' FROM Account_Services__c WHERE Account__r.Name=\'TestAccount\'';
            
            Test.StartTest();
            ODS_Invoice_Subsc_MonthlyBatch b = new ODS_Invoice_Subsc_MonthlyBatch(monthlyQry); 
            database.executebatch(b); 
            Test.StopTest();                                     
        }         
    }
    
    static TestMethod void scheduleBatch_Test()
    {
        String sch = '0 0 23 * * ?';
        ODS_ScheduledInvoiceSubscrip init = new ODS_ScheduledInvoiceSubscrip();
        system.schedule('Test init check',sch,init); 
    }
}