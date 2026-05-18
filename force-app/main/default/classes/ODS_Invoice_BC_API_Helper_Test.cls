@isTest
private class ODS_Invoice_BC_API_Helper_Test {
    
   public static Account accountObject{set;get;}
    public static User userId {set;get;}
    public static Work_Order__c workorderObject{set;get;}
    public static Work_Order__c workorderObject1{set;get;}

    
    public static testMethod void testWorkOrderDetails(){
        set<Id> WorkOderIds=new set<Id>();
        String Token='';
             date strtDt =  Date.today();
            date endDt = strtDt.adddays(30);
        
                 //userId = [SELECT Id FROM User WHERE Name = 'Zeeshan Armar' and IsActive=true LIMIT 1];        
//User userId1 = [SELECT Id,Name FROM User WHERE Name = 'Selva Pandian' and IsActive=true LIMIT 1];
        
        
        UserRole testRole = [SELECT Id FROM UserRole WHERE Name   = 'Vice President Sales'];
        User userId = new User(
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
            insert userId;
        
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account accountObject = new Account(
                Name ='Demand Blue CLient1',// Account Name
                Lead_Gen_Name__c = 'Others',             
                Industry = 'Hospitality',
                Project_Code__c ='GHT',
                Customer_Type__c= 'ABC Type'
            );
            insert accountObject;
            
        Contact contactObject = new Contact(
                FirstName ='sathya',
                LastName='c',
                isPrimary__c=true,
                Email='sathya_c@preludesys.com',
                AccountId=accountObject.Id,
                Lead_Gen_Name__c = 'Others'
        );
        insert contactObject;
        List<Salesforce_BC_API_Configuration__mdt> SFBCApiConfig=[Select Id,Company__c,Access_Token_URL__c,Client_Id__c,Client_Secret__c,Endpoint_URL__c,Grant_Type__c,Parameter__c,Tenant_Id__c,Scope__c,Method_Type__c From Salesforce_BC_API_Configuration__mdt WHERE 
                                                                      Is_Invoice__c =true Limit 1];
          String accessTokenUrl = SFBCApiConfig[0].Access_Token_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/oauth2/v2.0/token';
          string endpoint=SFBCApiConfig[0].Endpoint_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/'+SFBCApiConfig[0].Parameter__c+'?company='+SFBCApiConfig[0].Company__c;
            
           Test.startTest();
            // System.enqueueJob(workOrderAPI);
            Test.setMock(HttpCalloutMock.class, new AccessTokenMockHttpResponseGenerator(accessTokenUrl));
         Work_Order__c workorderObject2= new Work_Order__c(
            Client_Name__c=accountObject.Id,
            Project_Start_Date__c=system.today().addDays(7),
            Project_End_Date__c=system.today().addDays(20),
            //Account_Manager_Name__c=userId.Id,
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
            //Execution_Partner__c=userId1.Id,
            Project_Code__c='DEMANDSF',
            //OwnerId=userId1.Id,
            Account_CSM__c=accountObject.Name,
			BC_Work_Order_ID__c='11422'
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
		 InvoiceIds.add(Invobj.Id);
		 
		 
          
        //Test.startTest();
        
        ODS_Invoice_BC_API_Helper.AddInvoiceUsingAPI(InvoiceIds);
        
        Test.stopTest();
    }
    public class InvoiceMockTest implements HttpCalloutMock {
       
        public string endpointUrl='';
        public InvoiceMockTest(string acc,string endpointUrl){
            
            this.endpointUrl=endpointUrl;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(endpointUrl);
            request.setHeader('Accept','application/json');
            request.setHeader('contentType', 'application/json');
            res.setStatusCode(200);
            return res;
            
        }
        
    } 
    public class AccessTokenMockHttpResponseGenerator implements HttpCalloutMock {
        public string endPoinUrl='';
        public AccessTokenMockHttpResponseGenerator(string e){
            this.endPoinUrl=e;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InEtMjNmYWxldlpoaEQzaG05Q1Fia1A1TVF5VSIsImtpZCI6InEtMjNmYWxldlpoaEQzaG05Q1Fia1A1TVF5VSJ9.eyJhdWQiOiJodHRwczovL2FwaS5idXNpbmVzc2NlbnRyYWwuZHluYW1pY3MuY29tIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvZGY2ZWZmMzItNmY3MS00MjMwLTgyM2UtOTBkNGFlZWZkYTI1LyIsImlhdCI6MTcxMzE4MDExMCwibmJmIjoxNzEzMTgwMTEwLCJleHAiOjE3MTMxODQwMTAsImFpbyI6IkUyTmdZS2pqWjFraWZYUHV2NTdsa1YyVFo3SDhBQUE9IiwiYXBwaWQiOiJlMDk3MDQ2YS01NThhLTQwNGMtOTNlMS1jNTI2MDA4MjkyNmUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9kZjZlZmYzMi02ZjcxLTQyMzAtODIzZS05MGQ0YWVlZmRhMjUvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiIxYTczMjdlOS1hYzg1LTQ1N2MtOTUwYy05MzdjN2NiZjNjNDQiLCJyaCI6IjAuQVFNQU12OXUzM0Z2TUVLQ1BwRFVydV9hSlQzdmJabHNzMU5CaGdlbV9Ud0J1SjhCQVFBLiIsInJvbGVzIjpbIkF1dG9tYXRpb24uUmVhZFdyaXRlLkFsbCIsImFwcF9hY2Nlc3MiLCJBZG1pbkNlbnRlci5SZWFkV3JpdGUuQWxsIiwiQVBJLlJlYWRXcml0ZS5BbGwiXSwic3ViIjoiMWE3MzI3ZTktYWM4NS00NTdjLTk1MGMtOTM3YzdjYmYzYzQ0IiwidGlkIjoiZGY2ZWZmMzItNmY3MS00MjMwLTgyM2UtOTBkNGFlZWZkYTI1IiwidXRpIjoiUWlNblJsUEZFRUtubEV6YXloTERBUSIsInZlciI6IjEuMCJ9.RrZnXSWONhAEEXo6DlhgracHpDIKJ0cjWP-9vtCSxUni-mjnVoOymA_O1lXxAp6xHGjPSa62lBv4YcMl-ngaVg2avcSGi4ToUEuxU99RgtDxlhTO-Lte0Yf6VoE-v_zR5puEPaIqLXr6KTJbJnR-p4B9BWuMWPxIYM13NaBS7CWLi1-Kdu8qMBVmBolhjbwp0rumTe6oj5fWWSMRaqJbUADosFmLU2xoztwCoTmqejB0EilFIhadTW2x4b9W_QoUrBkZz53chKgbTO4njTvrOhsA_cwwrN1dAWVnt4YTl6H3kp3jL_MXpXrNkqr4E64xlZMuErbBm5gVNeeC37cm8g"}');
            res.setStatusCode(200);
            return res;
        }
    }
}