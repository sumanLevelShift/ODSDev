public class invoice_API_Calls{
    public static Boolean isFirstTime = true;  
    public static void AddInvoiceUsingAPI(set<Id> InvoiceIds)
    {
        try{    
            List<blng__Invoice__c> lstOfInvoiceToBeUpdated=new List<blng__Invoice__c>();
            system.debug('Add Invoice');
            Http http = new Http();
            string responseJson='';
            string accessToken=GenerateAuthorizationToken();
            system.debug('accessToken:'+accessToken);
            //api request 
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(System.Label.TIPS_INVOICE_API_Endpoint);
            request.setTimeout(120000);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization','Bearer '+accessToken);
            
            List<blng__Invoice__c> invoiceList =[SELECT Tips_Work_Order__c,Invoice_Name__c,Billing_Start_Date__c,Billing_End_Date__c,blng__InvoiceDate__c,blng__TotalAmount__c,blng__Order__r.SBQQ__PaymentTerm__c,Deliverable__c FROM blng__Invoice__c WHERE Id IN: InvoiceIds]; 
            
            for(blng__Invoice__c invoice: invoiceList)
            {
                system.debug('invoice------>'+invoice);
                
                string body='{"data":"'+AESEncryptDecrypt(GetInputString(invoice))+'"}';
                
                system.debug('encryptedData------>'+body);
                
                request.setBody(body);
                
                HTTPResponse response = http.send(request);      
                system.debug(response);
                responseJson = response.getBody();
                system.debug(response);
                if(response.getStatusCode()==200)
                {
                    system.debug('responseJson------>'+responseJson);
                    String jsonResponse = (String)JSON.deserializeUntyped(responseJson);
                    system.debug('jsonResponse.contains---'+(jsonResponse.contains('-')?jsonResponse.split('-')[1]:jsonResponse));
                    blng__Invoice__c invoice1=new blng__Invoice__c();
                    invoice1.Id=invoice.id;
                    //invoice1.Tips_Invoice_ID__c=jsonResponse.contains('-')?jsonResponse.split('-')[1]:jsonResponse;
                    invoice1.Tips_API_Message__c=jsonResponse.split('-')[3];
                    invoice1.Tips_Invoice_ID__c=jsonResponse.split('-')[1];
                    lstOfInvoiceToBeUpdated.add(invoice1);
                }
                
            }
            
            //update work orders
            if(!lstOfInvoiceToBeUpdated.isEmpty())
            {
                system.debug('lstOfInvoiceToBeUpdated--'+lstOfInvoiceToBeUpdated);
                update lstOfInvoiceToBeUpdated;
            }
            
        }
        catch(Exception e)    
        {
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    } 
    public static String GetInputString(blng__Invoice__c invoice)
    {
        try{
          
			String WorkorderId=invoice.Tips_Work_Order__c;
			String InvoiceNo=invoice.Invoice_Name__c;
            Date startdt=invoice.Billing_Start_Date__c;
            Date enddt=invoice.Billing_End_Date__c;
			Date invdt=invoice.blng__InvoiceDate__c;
			//String invamount=invoice.blng__TotalAmount__c;
            string invamount=String.valueOf(invoice.blng__TotalAmount__c);
			String Milestone=invoice.Deliverable__c;
            String projectstart=''; 
            String projectend='';     
            String projectinv='';
			String SFMilestone=''; 
            
            if(startdt!=null && enddt!=null)
            {
                projectstart = DateTime.newInstance(startdt.year(),startdt.month(),startdt.day()).format('MM/dd/YYYY');
                projectend = DateTime.newInstance(enddt.year(),enddt.month(),enddt.day()).format('MM/dd/YYYY');
				projectinv = DateTime.newInstance(invdt.year(),invdt.month(),invdt.day()).format('MM/dd/YYYY');
            }
			
			if(Milestone!=null)
            {
                SFMilestone = invoice.Deliverable__c;
            }
			
			
           
            String Createinvoice ='{"WorkorderId":'+WorkorderId+',"InvoiceNo":"'+InvoiceNo+'","InvoiceFrom_Dt":"'+projectstart+'","InvoiceTo_Dt":"'+projectend+'","InvoiceDt":"'+projectinv+'","Terms":"'+invoice.blng__Order__r.SBQQ__PaymentTerm__c+'","Invoice_Amt":"'+invamount+'","SFMilestone_Id":"'+SFMilestone+'"}';
             system.debug('Createinvoice------>'+Createinvoice);
            return Createinvoice;
        }
        catch(Exception e)    
        {
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return'';
        }
    }    
    
    public static string GenerateAuthorizationToken()
    {
        try{
            JWT jwt = new JWT('HS256');
            jwt.privateKey =System.Label.JWT_Private_Key;
            jwt.iss = System.Label.JWT_Issuer;
            jwt.aud =System.Label.JWT_Aud;
            jwt.subject = System.Label.JWT_Subject;
            jwt.audience = System.Label.JWT_Audience;
            string token = jwt.GetToken();  
            system.debug('token===='+token);
            return token;
        }
        catch(Exception e)    
        {
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return'';
        }
    }
    
    public static string AESEncryptDecrypt(String inputString)
    {
        try
        {
            system.debug('inputString------>'+inputString);        
            Blob key=Blob.valueOf(System.Label.AES_Key);
            system.debug('key------>'+key);
            Blob data = Blob.valueOf(inputString);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128',key, data);
            JWT jwt = new JWT('HS256');
            string encrypted=EncodingUtil.base64Encode(encryptedData);
            system.debug('encryptedData------>'+encrypted);
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encryptedData);
            String decryptedString = decrypted.toString();
            system.debug('decryptedData------>'+decryptedString);	
            return encrypted;
        }
        catch(Exception e)    
        {
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return'';
        }
    } 
}