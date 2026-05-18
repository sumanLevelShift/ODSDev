@isTest
global class AccountServiceInvoiceTest{

 @testSetup
static void setup() {
    
UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu1','testuser1@testmail.com','UTF-8','Indumathi1',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test1231@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        { 
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount12',
                                    'California', True,2000,'9433578855', 'Others', 'ODS Project');
     Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@test.com';
            update contact1;									
           
            
           
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('Salesforce','test',true);
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Aruns',portalAccount1.Id,odsSrv.Id);

            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);

            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  Date.today();
            date endDt = strtDt.adddays(30);
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
                                                 
                                              
// insert Billing rule
blng__BillingRule__c bl = new blng__BillingRule__c();
bl.Name='Genereate Billing Invoice rule';
bl.blng__InitialBillingTrigger__c='Order Product Activation Date';
bl.blng__PartialPeriodTreatment__c='Separate';
bl.blng__PeriodTreatmentForBTDO__c='Exclude Billing Day of Month';
bl.blng__GenerateInvoices__c='Yes';
bl.blng__Active__c=true;
insert bl;

// insert Tax rule
blng__TaxRule__c tl = new blng__TaxRule__c();
tl.name='Tax Rule';
tl.blng__Active__c=true;
tl.blng__TaxableYesNo__c='No';
insert tl;

// insert Revenue rule
blng__RevenueRecognitionRule__c rl = new blng__RevenueRecognitionRule__c();
rl.name='Full Revenue Recognition Rule';
rl.blng__Active__c=true;
rl.blng__CreateRevenueSchedule__c='No';
insert rl;

// insert Product    
Product2 p = new Product2();
p.Name = 'Test Product';
p.Description='Test Product';
p.productCode = 'ABC';
p.isActive = true;
p.SBQQ__ChargeType__c= 'One-Time';
p.blng__BillingRule__c=bl.id;
p.blng__TaxRule__c=tl.id;
p.blng__RevenueRecognitionRule__c=rl.id;
insert p;
		
PricebookEntry standardPrice = new PricebookEntry();
standardPrice.Pricebook2Id = Test.getStandardPricebookId();
standardPrice.Product2Id = p.Id;
standardPrice.UnitPrice = 100;
standardPrice.IsActive = true;
standardPrice.UseStandardPrice = false;
insert standardPrice ;   
User userId = [SELECT Id FROM User WHERE Name = 'DemandBlue Customer Success Manager' and IsActive=true LIMIT 1];        
User userId1 = [SELECT Id,Name FROM User WHERE Name = 'Selva Pandian' and IsActive=true LIMIT 1];
            Work_Order__c workorderObject2= new Work_Order__c(
            Client_Name__c=portalAccount1.Id,
            Project_Start_Date__c=system.today().addDays(7),
            Project_End_Date__c=system.today().addDays(20),
            Account_Manager_Name__c=userId.Id,
            SubCategory__c='DemandBlue-Subscription',
            Pay_Rate__c=85,
            Billing_Frequency__c='Monthly',
            Account_Partner__c='Selva Pandian',
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
            Execution_Partner__c=userId1.Id,
            Project_Code__c='DEMANDSF',
            OwnerId=userId1.Id,
            Account_CSM__c=portalAccount1.Name,
			Tips_Work_Order_ID__c='11422'
        );
        
		insert workorderObject2;
// insert Order
Order order = new Order(
	AccountId = portalAccount1.Id,
	EffectiveDate = strtDt,
	EndDate=endDt,
    blng__BillingDayOfMonth__c = '1',
	Status = 'Draft',
	BillToContactId=contact1.Id,
	PriceBook2Id = Test.getStandardPricebookId(),
    SBQQ__PaymentTerm__c='Net 30',
			Work_Order__c = workorderObject2.Id
);
insert order;


// insert Order Product
OrderItem lineItem = new OrderItem();
lineItem.OrderId = order.id;
lineItem.Quantity = 24;
lineItem.UnitPrice = 240;
lineItem.Product2id = p.id;
lineItem.PricebookEntryId=standardPrice.id;
lineItem.ServiceDate=order.EffectiveDate;
lineItem.EndDate=order.EndDate;
lineItem.blng__BillableUnitPrice__c=100;
insert lineItem;

order.Status = 'Activated';
order.blng__BillNow__c=true;
update order;

// insert Invoice
blng__Invoice__c inv = new blng__Invoice__c();
inv.blng__Account__c =portalAccount1.id;
inv.blng__Order__c = order.id;
insert inv;
 
// insert Content version 
ContentVersion content=new ContentVersion(); 
content.Title='Header_Picture1'; 
content.PathOnClient='/' + content.Title + '.jpg'; 
Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
content.VersionData=bodyBlob; 
content.origin = 'H';
insert content;

// insert Content document link     
ContentDocumentLink contentlink=new ContentDocumentLink();
contentlink.LinkedEntityId=inv.id;
contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
contentlink.ShareType = 'I';
contentlink.Visibility = 'AllUsers';
insert contentlink;
        
}
}

 @isTest static void test() {
Test.startTest();
AccountServiceInvoice ODSInvoiceInstance= new AccountServiceInvoice();
Database.executeBatch(ODSInvoiceInstance);

    
SchedulableAccountService sh1 = new SchedulableAccountService();      
String sch = '0 0 * * * ?';
system.schedule('Test check', sch, sh1);

}
    @isTest static void test2() {
Test.startTest();
TipsInvoiceBatch TipsInvoiceInstance= new TipsInvoiceBatch();
Database.executeBatch(TipsInvoiceInstance);

SchedulableTipsInvoice sh2 = new SchedulableTipsInvoice();      
String schedule2 = '0 0 * * * ?';
system.schedule('Test check2', schedule2, sh2);   

}
}