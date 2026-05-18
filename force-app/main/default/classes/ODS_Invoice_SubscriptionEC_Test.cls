@isTest
Public class ODS_Invoice_SubscriptionEC_Test
{
    static TestMethod void generatePDF_Test()
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
            portalAccount1.User__c = UserInfo.getUserId();
            update portalAccount1;
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            
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
            accSrvc.Invoice_Frequency__c = 'Weekly';
            accSrvc.Contract_Term__c = 'Net 30';
            accSrvc.Purchase_Order__c = 'test';
            accSrvc.Invoice_Monthly_Subscription_Discount__c = 10;
            update accSrvc;                             
            
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
                        
            ApexPages.currentPage().getParameters().put('term','Net 30');
            ApexPages.currentPage().getParameters().put('billToStr','Siruseri');
            ApexPages.currentPage().getParameters().put('billToCty','Chennai');
            ApexPages.currentPage().getParameters().put('billToStat','Tamilnadu');
            ApexPages.currentPage().getParameters().put('billToCtry','India');
            ApexPages.currentPage().getParameters().put('billToPcod','640000');
            String constructMth = '';
            if(System.today().month() < 10) constructMth = '0'+String.valueOf(System.today().month());
            else constructMth = String.valueOf(System.today().month());
            String invNumber = String.valueOf(System.today().year())+constructMth+'11C45';
            ApexPages.currentPage().getParameters().put('invNumb',invNumber);
            ApexPages.currentPage().getParameters().put('accNumb','C45');
            Date StartDate = strtDt; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');           
            Date EndDate = endDt;
            String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            ApexPages.currentPage().getParameters().put('billPerd',FromDate+' - '+ToDate);    
            ApexPages.currentPage().getParameters().put('startDt',String.valueOf(StartDate));
            ApexPages.currentPage().getParameters().put('endDt',String.valueOf(EndDate));
            ApexPages.currentPage().getParameters().put('AccServId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('hrlyRate','90');
            ApexPages.currentPage().getParameters().put('discFee','');
            ApexPages.currentPage().getParameters().put('subsType','upfront');
            ApexPages.currentPage().getParameters().put('ref',String.valueOf(accSrvc.Purchase_Order__c));
            ApexPages.currentPage().getParameters().put('proj',String.valueOf(accSrvc.ODS_Service_Name__c));
            ApexPages.currentPage().getParameters().put('mnths','1');
            
            ODS_Invoice_SubscriptionEC invPdf = new ODS_Invoice_SubscriptionEC();                                    
                          
        }
    }   
}