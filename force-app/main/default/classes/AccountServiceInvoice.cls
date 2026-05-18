global class AccountServiceInvoice implements database.Batchable<Sobject> {

    DateTime dt = System.Now().addHours(-1);    
    global database.QueryLocator start(database.BatchableContext context){
      string query = 'SELECT blng__Account__c,Id,Billing_Start_Date__c,Billing_End_Date__c,blng__InvoiceDate__c,blng__InvoiceStatus__c,Paid__c FROM blng__Invoice__c where createddate>=:dt';
        return Database.getQueryLocator(query);
        
    
      }
  global void execute(database.BatchableContext context , list<blng__Invoice__c> Scope ){
	List<Invoice__c> newInvoice = new List<Invoice__c>(); 
	List<ContentDocumentLink> contentlink = new List<ContentDocumentLink>();
        
    Map <Id, Id> InvoiceMap= New Map <Id, Id>();
    Set<Id> allInvoice=  new Set<Id> ();
    List<Id> allAccount= new List<Id> ();
	
    for(blng__Invoice__c Inv:Scope){
    InvoiceMap.put(Inv.Id,Inv.blng__Account__c);
   
    allAccount= InvoiceMap.values();
    
    allInvoice= InvoiceMap.keySet();
    
     }
     List<ContentDocumentLink> ContDoc = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in:allInvoice];
      Map <Id, Id> DocMap= New Map <Id, Id>();
          for (ContentDocumentLink CD :ContDoc)  {
          DocMap.put (CD.LinkedEntityId,CD.ContentDocumentId);
          }
  
         List<Account_Services__c> AccService = [Select Account__c,Id from Account_Services__c Where Account__c in:allAccount and ODS_Service_Name__c	= 'Salesforce'];
          Map <Id, Id> ASMap= New Map <Id, Id>();
          for (Account_Services__c Acs :AccService)  {		
		 ASMap.put (Acs.Account__c, Acs.Id);

          }
   
      for(blng__Invoice__c Inv:Scope){
      
      If(ASMap.keyset().contains(Inv.blng__Account__c)&& DocMap.keyset().contains(Inv.Id))
      {
          Invoice__c Invoicecontent = new Invoice__c();
          Invoicecontent.Account_Services__c=ASMap.get (Inv.blng__Account__c);
		  Invoicecontent.Account__c=Inv.blng__Account__c;
		  Invoicecontent.Billing_Invoice__c=Inv.id;
		  Invoicecontent.Billing_Start_Date__c=Inv.Billing_Start_Date__c;
		  Invoicecontent.Billing_End_Date__c=Inv.Billing_End_Date__c;
		  Invoicecontent.Invoice_Date__c=Inv.blng__InvoiceDate__c;
		  Invoicecontent.Invoice_Type__c='Subscription';
		  Invoicecontent.Paid_unpaid__c=Inv.Paid__c;
		  Invoicecontent.Status__c=Inv.blng__InvoiceStatus__c;
          newInvoice.add(Invoicecontent);
      
      }
      
        }
        if (!newInvoice.isEmpty())
      {
       insert newInvoice;
        }
		 for(Invoice__c newInv:newInvoice){
         ContentDocumentLink newcontent = new ContentDocumentLink();
         newcontent.ContentDocumentId=DocMap.get(newInv.Billing_Invoice__c);
         newcontent.LinkedEntityId=newInv.id;
		 System.debug('LinkedEntityId is' + newcontent.LinkedEntityId);
         contentlink.add(newcontent);
      
        }
        if (!contentlink.isEmpty())
      {
       insert contentlink;
        }

  }
     global void finish(database.BatchableContext context){
          
      }
      
       
}