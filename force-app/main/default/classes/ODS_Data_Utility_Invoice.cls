public class ODS_Data_Utility_Invoice {
    
     public  ODS_Data_Utility_Invoice(ODS_Invoicepagecontroller myController){
        
    }
    
     Public static User fetchUserById(string curntUserId)
    {
        try{
            return [SELECT 
                        Id, 
                        Name,
                        ContactId,
                        Email,
                        Photo__c,
                        PortalUserRole__c,
                        Management__c,
                        UserRole.name,
                        userRoleid,
                        Contact.Is_Approver__c,
                        Contact.AccountId                
                    FROM 
                        User 
                    WHERE 
                        Id =: curntUserId];
        }
        catch(exception e){
              ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
			  return null;
        }
    }
    public static List<Invoice__c> FetchInvoice(string accountId, string serviceId, string Month, Integer Year, string sortOrder)
    {
        try{
                string YearString =string.valueof(Year);
                 string subInvoice ='Subscription';
                string accountServiceQuery = 'SELECT CreatedDate,Invoice_Type__c,Uploaded_by__c,Email__c,Paid_unpaid__c, Uploaded_by__r.Name, Uploaded_Date__c,Status__c, CreatedById, Billing_Start_Date__c, Billing_End_Date__c, LastModifiedBy.Name,CreatedBy.Name,LastModifiedDate,Attachment_File__c,Account_Services__r.Account__c,Account_Services__r.ODS_Service_Name__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Services__c, Attachment_Id__c,Comments__c, Month__c,Year__c,Id FROM Invoice__c Where ';
                
                if(accountId != 'All' && serviceId != 'All')
                {
                     accountServiceQuery += ' Account_Services__r.Account__c =: accountId  AND Account_Services__r.ODS_Services__c =:serviceId AND';
                }  
                else if (accountId == 'All' && serviceId != 'All')
                {
                    accountServiceQuery += ' Account_Services__r.ODS_Services__c =: serviceId AND';
                }
                else if (accountId != 'All' && serviceId == 'All')
                {
                    accountServiceQuery += ' Account_Services__r.Account__c =: accountId AND';
                }
                if (Month == null || Month == 'Month')
                {
                    
                }
                else{
                    accountServiceQuery += ' Month__c =: Month AND'; 
                }
                if (Year == null || YearString == 'Year' || Year == 0)
                {
                    
                }
                else{
                    accountServiceQuery += ' Year__c =:Year AND'; 
                }
            	accountServiceQuery += ' Invoice_Type__c !=: subInvoice AND'; 
                
                //Updated by Mani and Team
                User currUser = [SELECT Id,ContactId,Contact.AccountId,PortalUserRole__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
                Id currPartnerId = currUser.Contact.AccountId;
                Id currPartnerCont = currUser.ContactId;
                if(currUser.PortalUserRole__c == 'Partner') accountServiceQuery += ' Account_Services__r.Account__r.Channel_Partner__c =:currPartnerId AND Account_Services__r.Account__r.Channel_Partner_Contact__c =:currPartnerCont ';  
                accountServiceQuery = (accountServiceQuery.trim()).removeEnd('AND'); //+' ORDER BY LastModifiedDate Desc';
                accountServiceQuery = (accountServiceQuery.trim()).removeEnd('Where'); //+' ORDER BY LastModifiedDate Desc';        
                accountServiceQuery+=' ORDER BY '+sortOrder;
                system.debug('-----Query--' + accountServiceQuery + Month + Year); 
                system.debug('&&&&&accountServiceQuery'+accountServiceQuery);   
                system.debug('&&&&&Month'+Month); 
                system.debug('&&&&&Year'+Year); 
                system.debug('&&&&&accountId '+accountId );
                system.debug('&&&&&serviceId '+serviceId );                   
                List<Invoice__C> invoiceList = new List<Invoice__C>();
                invoiceList = database.query(accountServiceQuery);
                system.debug('&&&&&invoiceList '+invoiceList );
                return invoiceList;
        }    
        Catch(Exception e){             
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
            return null;
        }    
    }
    public static Invoice__c InsertUpdateInvoiceDetails(string CurrentAccServiceId, string accountId, string serviceId,string Month, Decimal Year,string Comments, string InvoiceId, string Status,
                       date billingStart, date billingEnd,string userEnteredEmail, string userEnteredCCAddress,string userEnteredSubject, string userEnteredBody)
    {
        Invoice__c Invoice = null;
        try{
        //string accountServiceId = ODS_Data_Utility.GetAccSerDetails(accountId, serviceId);
        if(InvoiceId == '' || InvoiceId == null)
        {
            system.debug('---Inside Insert Method---');
            Invoice = new Invoice__c ();      
            Invoice.Account_Services__c = CurrentAccServiceId ;
            Invoice.Month__c = Month; 
            Invoice.Year__c = Year;
            Invoice.Comments__c = Comments;
            Invoice.Billing_Start_Date__c = billingStart;
            Invoice.Billing_End_Date__c = billingEnd;
            Invoice.Status__c = Status;
            Invoice.Email__c = userEnteredEmail;
            Invoice.Invoice_CC__c = userEnteredCCAddress;
            Invoice.Subject__c=userEnteredSubject;
            Invoice.Email_Body__c=userEnteredBody;
            Invoice.Invoice_Type__c = 'ODS';
            insert Invoice;
            Invoice__c updateInvoice = new Invoice__c(Id=Invoice.Id);
            updateInvoice.Invoice_ID__c = Invoice.Id;
            update updateInvoice;   
            system.debug('updateInvoice'+updateInvoice);
        }
        else
        {
            system.debug('---##Inside Update Method##---'+ InvoiceId);
            Invoice = new Invoice__c (id=InvoiceId);
            Invoice.Account_Services__c = CurrentAccServiceId ;
            Invoice.Month__c=  Month; 
            Invoice.Year__c =  Year;
            Invoice.Invoice_Type__c = 'ODS';
            if(Invoice.Comments__c == 'undefined')
            {
                Invoice.Comments__c = '';
            }
            else
            {
                Invoice.Comments__c = Comments;
            }
            Invoice.Invoice_ID__c = InvoiceId;   
            Invoice.Billing_Start_Date__c = billingStart;
            Invoice.Billing_End_Date__c = billingEnd; 
            Invoice.Status__c = Status;
            Invoice.Email__c = userEnteredEmail;
            Invoice.Invoice_CC__c = userEnteredCCAddress;
            Invoice.Subject__c=userEnteredSubject;
            Invoice.Email_Body__c=userEnteredBody;
            update Invoice;
            system.debug('---UpdateInvoice---'+ Invoice);
            
        }
            }
        catch(exception e)
        {
            system.debug('Error occured '+e.getLineNumber() + ' '+ e.getMessage() + ' '+e.getCause()+ ' '+e.getTypeName());
        }
        
        return Invoice;
    }
  
      ///<OBJECTIVE>
    ///Get the Invoice details
    ///</OBJECTIVE>
    public static void DeleteInvoice(string InvoiceId)
    { 
        try{ 
           Invoice__c[]  Invoice = [Select Id from Invoice__c where Id=: InvoiceId];
           delete Invoice;
        }
        catch(exception e){
        	ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());                     
        }
    }
    public static void UpdateInvoiceStatus(String InvoiceID){
        try{ 
            List<Invoice__c> InvoiceList = [select id,Paid_unpaid__c from Invoice__c where id =:InvoiceID];
            System.debug('InvoiceList====>' + InvoiceList);
            for(Invoice__c invoice: InvoiceList){
                if(invoice.Paid_unpaid__c == False){
                    invoice.Paid_unpaid__c = True; 
                }
            }
            Update InvoiceList;
        }
        catch(exception e){
             ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
        }
    }
    public static void UpdateInvoiceStatusAsFalse(String InvoiceID){
        try{
            List<Invoice__c> InvoiceList = [select id,Paid_unpaid__c from Invoice__c where id =:InvoiceID];
            System.debug('InvoiceList====>' + InvoiceList);
            for(Invoice__c invoice: InvoiceList){
                if(invoice.Paid_unpaid__c == True){
                    invoice.Paid_unpaid__c = False; 
                }
            }
            Update InvoiceList;
        }
        Catch(exception e){
             ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
        }
    }
    /// <OBJECTIVE>
    /// fetch the Account Services details.
    /// </OBJECTIVE>    
    Public static List<Account_Services__c > fetchAccServcesByServiceAccount(string selectedAccount, string selectedService)
    {
        try{
            return [SELECT Id,
                         Account__c, 
                         Account__r.Name,
                         Account__r.Id,
                         ODS_Services__c,
                         ODS_Services__r.Name__c
                     FROM 
                         Account_Services__c 
                     WHERE
                         Account__c =: selectedAccount
                         AND
                         ODS_Services__c =: selectedService             
                     ORDER BY CreatedDate DESC];
        }
        Catch(Exception e){
             ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
			 return null;
        }
    }
    
    ///<OBJECTIVE>
    ///Get the Document details
    ///</OBJECTIVE>
    public static string GetInvoiceAttachment(string InvoiceId)
    { 
        try{
            List<Invoice__c> Invoice = new List<Invoice__c>();
            string InvoiceJSON;
            string attachmentJSON;
            string primaryContactEmailJSON;
            Invoice = [SELECT ID,
                            Account_Services__c,
                            Attachment_Id__c,
                            Comments__c,
                            Month__c,
                            Email__c,
                            Invoice_ID__c,
                            Billing_Start_Date__c,
                            Billing_End_Date__c,
                            Year__c,Account_Services__r.Account__r.ID,
                            Account_Services__r.ODS_Services__c From Invoice__c WHERE Id =: InvoiceId];
            if(invoice != null){                
                InvoiceJSON = Json.serialize(Invoice);
                system.debug('---InvoiceJSON--'+ InvoiceJSON );
            }
            
            List<Attachment> attachment = new List<Attachment>();
            attachment = [SELECT Id, Name FROM Attachment WHERE Id =: Invoice[0].Attachment_Id__c];
            
            if(attachment != null){
                attachmentJSON = Json.serialize(attachment);
                
                system.debug('---JSON--'+ attachmentJSON);
            }
            List<Contact_Account_Service__c> primaryContact = [SELECT ID,Email__c,Contact__r.Name,ODS_Service__c FROM Contact_Account_Service__c WHERE Contact__r.AccountId =: Invoice[0].Account_Services__r.Account__r.ID AND ODS_Service__c =:Invoice[0].Account_Services__r.ODS_Services__c AND Is_Approver__c = True Limit 1];
            if(primaryContact != Null)
            {
                primaryContactEmailJSON = Json.serialize(primaryContact);
                system.debug('---JSON--'+ primaryContactEmailJSON);
            }
            return InvoiceJSON +'$$##'+attachmentJSON+'$$##'+primaryContactEmailJSON;
        }
        Catch(Exception e){
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
			return null;
        }
    }
     ///<OBJECTIVE>
    ///Get Account Service Name
    ///</OBJECTIVE>
    public static Account_Services__c[] GetAccountServiceName(string accountId, string serviceId)
    { 
       try{ 
           Account_Services__c[]  accountService = [SELECT Account__r.Name,ODS_Services__r.Name, ODS_Service_Name__c, Technical_Account_manager__c,Customer_Success_Executive__c, Technical_Account_manager__r.name,
                       Technical_Account_manager__r.Email FROM Account_Services__c where Account__c =: accountId AND ODS_Services__c =: serviceId];
           return accountService;
       }
        Catch(Exception e){
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
			return null;
        }
    }
     public static Invoice__c[] GetInvoiceAttachmentId(string InvoiceId)
    { 
        try{
               Invoice__c[] Invoice = [SELECT Attachment_Id__c  FROM Invoice__c where Id =: InvoiceId];
               return Invoice;
        }
        Catch(Exception e){
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
				return null;
        }
    }
    ///<OBJECTIVE>
    /// To Insert the Invoice Details and Attachment
    ///</OBJECTIVE>
    public static Invoice__c InsertUpdateInvoiceDetailsAttachment(string accountId, string serviceId,string fileName,
                       string Month, Decimal Year, Blob fileData, string Comments, string Status, string InvoiceId)
    {
        try{
            string attachmentId = '';     
            system.debug('---InsertMethod---'+ filename);
            system.debug('---##InvoiceId##---'+ InvoiceId);
            //Insert the Invoice Details into Invoice Object
            Invoice__c Invoice = null;
            string accountServiceId = ODS_Data_Utility.GetAccSerDetails(accountId, serviceId);
            if(InvoiceId == '' || InvoiceId == null)
            {
                system.debug('---Inside Insert Method---'+ InvoiceId);
                Invoice = new Invoice__c ();      
                Invoice.Account_Services__c = accountServiceId ;
                Invoice.Month__c = Month; 
                Invoice.Year__c = Year;
                Invoice.Comments__c = Comments;
                Invoice.Attachment_File__c = filename;
                Invoice.Status__c = Status;
                insert Invoice;
                system.debug('---Invoice---'+ Invoice);
                Invoice__c updateInvoice = new Invoice__c(Id=Invoice.Id);
                updateInvoice.Invoice_ID__c = Invoice.Id;
                Invoice.Status__c = Status;
                update updateInvoice;            
            }
            else
            {
                system.debug('---InvoiceId---'+ InvoiceId);
                system.debug('---##Inside Update Method##---'+ InvoiceId);
                Invoice = new Invoice__c (id=InvoiceId);
                Invoice.Account_Services__c = accountServiceId ;
                Invoice.Month__c=  Month; 
                Invoice.Year__c =  Year;
                if(Invoice.Comments__c == 'undefined')
                {
                    Invoice.Comments__c = '';
                }
                else
                {
                    Invoice.Comments__c = Comments;
                }
                Invoice.Attachment_File__c = filename;   
                Invoice.Invoice_ID__c = InvoiceId; 
                Invoice.Status__c = Status;
                update Invoice;
                system.debug('---UpdateInvoice---'+ Invoice);
                
            }
            
            //Gets the Account Service Id to concate with file name
            string documentSuffix = ODS_Data_Utility.GetAccountServiceDetails(accountId, serviceId);
            transient blob blobFileDate = fileData;
            
            //Inserts the attachment into Attachment object
            Attachment attachment= null;
            
            if(InvoiceId == '' || InvoiceId == null)
            {
                attachment= new Attachment(); 
                attachment.parentId = Invoice.Id;
                attachment.body= blobFileDate;
                if(documentSuffix == null)
                {
                    attachment.Name = filename;
                }
                else
                {
                    attachment.Name = documentSuffix +'_'+ filename;
                }   
                insert attachment;
            }
            else
            {   
                system.debug('---UpdateMethod---Else---FileName'+filename );
                if(blobFileDate != null)
                {    
                    system.debug('---UpdateMethod---Else If');
                    Invoice__C[] InvoiceData =  [Select Id,Attachment_Id__c from Invoice__c where Id=:InvoiceId];  
                    attachment= new Attachment(id=InvoiceData[0].Attachment_Id__c);             
                    attachment.body= blobFileDate;
                    
                    integer i = 0; string fileDocumentSuffix = ''; string fullFileName ='';
                    //Split the file name with _ and check whether its a same file
                    //If its a same file then keep the file name as same else add the suffix
                    for(String fileNameSplit: filename.split('_'))
                    {
                       if(i == 0)
                       {
                           fileDocumentSuffix = fileNameSplit;                       
                       }  
                       
                       fullFileName += fullFileName + fileNameSplit;
                         
                       i++;
                    }
                    
                    if(documentSuffix  == fileDocumentSuffix)
                    {
                        attachment.Name = filename;                
                    }
                    else
                    {
                         attachment.Name = documentSuffix +'_'+ filename;
                    }
                    
                    system.debug('----Suffix----' + fileDocumentSuffix +'----' + fullFileName);
                    
                    update attachment;
                }
          }                        
            //Updates the attachentid into documents object
            if(InvoiceId == '' || InvoiceId ==null)
            {
                Invoice__c queryInvoice = [SELECT Id FROM Invoice__c WHERE Id =: Invoice.Id LIMIT 1];
                queryInvoice.Attachment_Id__c = attachment.Id;
                update queryInvoice ;
            }
            
            return Invoice;
        }
        Catch(Exception e){
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
			return null;
        }

    } 

    public static Invoice__c FetchInvoiceByID(String InvoiceId){
        try{
        return [select ID,
                       Name,
                	   Account_Services__c,
                	   Account_Services__r.Account__r.Name,
                	   Account_Services__r.Account__r.Id,
                	   Attachment_File__c,
                	   Billing_End_Date__c,
                	   Billing_Start_Date__c,
                	   Comments__c,
                	   Email__c,
                       Invoice_CC__c,
                       Email_Body__c,
                       Subject__c,                
                	   Invoice_Month__c,
                	   Invoice_AccountId__c,
                	   Invoice_Count__c,
                	   Invoice_ID__c,
                	   Invoice_Number__c,                	   
                	   Month__c,
                       Paid_unpaid__c,
                	   Status__c,
                	   Uploaded_by__c,
                       Uploaded_Date__c,
                	   Year__c                	                  	  
                	   FROM 
                            Invoice__c 
                       Where 
                            Id =: InvoiceId];  
        }
        Catch(exception e){
           ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());         
		   return null;
        }
                	       
	}

}