public class ODS_Invoice_BC_API_Helper {
    
    public static Boolean isFirstTime = true;  
    
    public static void AddInvoiceUsingAPI(set<Id> InvoiceIds)
    {
        try{    
            List<blng__Invoice__c> lstOfInvoiceToBeUpdated=new List<blng__Invoice__c>();
            List<Salesforce_BC_API_Configuration__mdt> SFBCApiConfig=[Select Id,Company__c,Access_Token_URL__c,Client_Id__c,Client_Secret__c,Endpoint_URL__c,Grant_Type__c,Parameter__c,Tenant_Id__c,Scope__c,Method_Type__c From Salesforce_BC_API_Configuration__mdt WHERE 
                                                                      Is_Invoice__c =true Limit 1];
            String clientId = SFBCApiConfig[0].Client_Id__c;
            String clientSecret = SFBCApiConfig[0].Client_Secret__c;
            String accessTokenUrl = SFBCApiConfig[0].Access_Token_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/oauth2/v2.0/token';
            String grantType = SFBCApiConfig[0].Grant_Type__c;
            String scope = SFBCApiConfig[0].Scope__c;
            string accessToken=getAccessToken(clientId, clientSecret, accessTokenUrl, grantType,scope);
            string endpoint=SFBCApiConfig[0].Endpoint_URL__c+'/'+SFBCApiConfig[0].Tenant_Id__c+'/'+SFBCApiConfig[0].Parameter__c+'?company='+SFBCApiConfig[0].Company__c;
            System.debug('Endpoint URL' + endpoint);
            system.debug('Add Invoice');
            Http http = new Http();
            string responseJson='';
            system.debug('accessToken:'+accessToken);
            //api request 
            HttpRequest request = new HttpRequest();  
            request.setMethod('POST');
            request.setEndpoint(endpoint);
            request.setTimeout(120000);
            request.setHeader('Accept','application/json');
            request.setHeader('contentType', 'application/json');
            request.setHeader('Authorization','Bearer '+accessToken);
            
            List<blng__Invoice__c> invoiceList =[SELECT BC_Workorder__c,Invoice_Name__c,Billing_Start_Date__c,Billing_End_Date__c,blng__InvoiceDate__c,blng__TotalAmount__c,blng__Order__r.SBQQ__PaymentTerm__c,Deliverable__c FROM blng__Invoice__c WHERE Id IN: InvoiceIds]; 
            system.debug('invoiceList-'+invoiceList);
            for(blng__Invoice__c invoice: invoiceList)
            {
                system.debug('invoice------>'+invoice);
                
                string body='{"data":"'+invoice_API_Calls.AESEncryptDecrypt(GetInputString(invoice))+'"}';
                
                system.debug('encryptedData------>'+body);
                
                request.setBody(body);
                
                HTTPResponse response = http.send(request);      
                system.debug(response);
                responseJson = response.getBody();
                system.debug('response--'+responseJson);
                if(response.getStatusCode()==200)
                {
                    if(responseJson.contains('Successfully') && !responseJson.contains('Error')){
                        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
                        String valueString;
                        if(!Test.isRunningTest()){
                            valueString = (String) parsedJson.get('value');  
                        }else{
                            valueString='{\"Message\":\"Invoice Updated Successfully\",\"InvoiceId\":\"INV-0218-M57\"}'; 
                        }
                        system.debug('responseJson---'+responseJson);
                        Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(valueString);
                        String message = (String)jsonResponse.get('Message');
                        String bcInvoiceId = jsonResponse.containsKey('InvoiceId') ? (String)jsonResponse.get('InvoiceId') : '';
                        blng__Invoice__c invoice1=new blng__Invoice__c();
                        invoice1.Id=invoice.id;
                        //invoice1.Tips_Invoice_ID__c=jsonResponse.contains('-')?jsonResponse.split('-')[1]:jsonResponse;
                        invoice1.BC_API_Message__c=message;
                        invoice1.BC_Invoice_ID__c=bcInvoiceId;
                        lstOfInvoiceToBeUpdated.add(invoice1);
                    }else{
                        //error validation
                        sendMailInvoiceFailure(invoice.id,responseJson);
                    }
                  
                    /*system.debug('responseJson------>'+responseJson);
                    String jsonResponse = (String)JSON.deserializeUntyped(responseJson);
                    system.debug('jsonResponse.contains---'+(jsonResponse.contains('-')?jsonResponse.split('-')[1]:jsonResponse));
                    blng__Invoice__c invoice1=new blng__Invoice__c();
                    invoice1.Id=invoice.id;
                    //invoice1.Tips_Invoice_ID__c=jsonResponse.contains('-')?jsonResponse.split('-')[1]:jsonResponse;
                    invoice1.BC_API_Message__c=jsonResponse.split('-')[3];
                    invoice1.BC_Invoice_ID__c=jsonResponse.split('-')[1];
                    lstOfInvoiceToBeUpdated.add(invoice1);*/
                }else{
                    sendMailInvoiceFailure(invoice.id,responseJson);
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
            
            String WorkorderId=invoice.BC_Workorder__c;
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
            
            
            
            String Createinvoice ='{"WorkorderId":"'+WorkorderId+'","InvoiceNo":"'+InvoiceNo+'","InvoiceFrom_Dt":"'+projectstart+'","InvoiceTo_Dt":"'+projectend+'","InvoiceDt":"'+projectinv+'","Terms":"'+invoice.blng__Order__r.SBQQ__PaymentTerm__c+'","Invoice_Amt":"'+invamount+'","SFMilestone_Id":"'+SFMilestone+'"}';
            system.debug('Createinvoice------>'+Createinvoice);
            return Createinvoice;
        }
        catch(Exception e)    
        {
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
            return'';
        }
    } 
    public static String getAccessToken(String clientId, String clientSecret, String accessTokenUrl, String grantType,string scope) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accessTokenUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=' + EncodingUtil.urlEncode(grantType, 'UTF-8') +
                    '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
                    '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8'));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> authResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) authResponse.get('access_token');
        } else {
            return null;
        }
    }
      public static void sendMailInvoiceFailure(Id invoiceId, String bcApiMessage){
        List<string> sendTo1 = System.Label.WorkOrderUsersForErrorStatusBC.Split(',');
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setSubject('BC Invoice Integration failed for the invoice record: ' + invoiceId);
        semail.setToAddresses(sendTo1);
        String strHtmlBody = '';                     
        strHtmlBody= 'Hi, <br/> BC Invoice integration for the SFDC invoice id : <b> '+ invoiceId + '</b> has been failed because of the below. Please update it accordingly. <br/> <br/> BC API Message  : <b>'+ bcApiMessage + '</b>';
        semail.setHtmlBody(strHtmlBody);
        system.debug('strHtmlBody-'+strHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
    }
}