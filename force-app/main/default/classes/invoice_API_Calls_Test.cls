@isTest 
public class invoice_API_Calls_Test {
    
   public static Account accountObject{set;get;}
    public static User userId {set;get;}
    public static Work_Order__c workorderObject{set;get;}
    public static Work_Order__c workorderObject1{set;get;}

    
    public static testMethod void testWorkOrderDetails(){
        set<Id> WorkOderIds=new set<Id>();
        String Token='';
             date strtDt =  Date.today();
            date endDt = strtDt.adddays(30);
        
                 userId = [SELECT Id FROM User WHERE Name = 'Zeeshan Armar' and IsActive=true LIMIT 1];        
User userId1 = [SELECT Id,Name FROM User WHERE Name = 'Selva Pandian' and IsActive=true LIMIT 1];
        
        accountObject = new Account(
            Name ='DemandBlue TestClient',// Account Name
            Lead_Gen_Name__c = 'Others',             
            Industry = 'Hospitality',
            Backup_CSM__c=userId1.Id
        );
        insert accountObject;
        
        Contact contactObject = new Contact(
            FirstName ='sathya',
            LastName='c',
            Email='sathya_c@preludesys.com',
            AccountId=accountObject.Id,
            Lead_Gen_Name__c = 'Others'
        );
        insert contactObject;
        
        
        
         Work_Order__c workorderObject2= new Work_Order__c(
            Client_Name__c=accountObject.Id,
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
            Account_CSM__c=accountObject.Name,
			Tips_Work_Order_ID__c='11422'
        );
        
		insert workorderObject2;
		
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

		// insert Order
		Order order = new Order(
			AccountId = accountObject.Id,
			EffectiveDate = strtDt,
			EndDate=endDt,
			blng__BillingDayOfMonth__c = '1',
			Status = 'Draft',
			BillToContactId=contactObject.Id,
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
		
		 set<Id> InvoiceIds=new set<Id>();
		 
		 blng__Invoice__c Invobj = new blng__Invoice__c(
		  blng__Order__c = order.id,                                                
		  blng__Account__c = accountObject.Id,                                                
		  blng__BillToContact__c = contactObject.id,                                       
		  blng__InvoiceLocked__c = false,                                                 
		  blng__InvoiceStatus__c = 'Draft'                                           

		);
		insert Invobj;
		//system.debug ('TIPS work order id ' + Invobj.Tips_Work_Order__c)';
		 InvoiceIds.add(Invobj.Id);
		 
		 
          
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new InvoiceMockTest());
        invoice_API_Calls.AddInvoiceUsingAPI(InvoiceIds);
        
        Test.stopTest();
    }

     public class InvoiceMockTest implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            string accessToken = invoice_API_Calls.GenerateAuthorizationToken();
			//System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(System.Label.TIPS_INVOICE_API_Endpoint);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer '+accessToken);
            res.setBody('"200-9987"');
            res.setStatusCode(200);
            return res;
        }
        
    } 
}