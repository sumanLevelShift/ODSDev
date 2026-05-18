public class TipsAPIHelperClass {
    @future(callout = true)
    public static Void HttpRequest(string Endpoint, string body, string MethodType, string timeSheetId,string billingType) {
        try {
            system.debug('body--'+body);
            Http http = new Http();
            string responseJson = '';
            string accessToken = GenerateAuthorizationToken();
            //api request 
            HttpRequest request = new HttpRequest();
            request.setMethod(MethodType);
            request.setEndpoint(Endpoint);
            request.setTimeout(120000);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            
            request.setBody(body);
            
            HTTPResponse response = http.send(request);
            responseJson = response.getBody();            
            system.debug(response.getStatusCode());
            system.debug(response.getStatus());
            system.debug('res--'+responseJson);
            
            Timesheet__c t=new Timesheet__c();
            t.Id=timeSheetId;
            if (response.getStatusCode() != 200) {
                System.debug('Error message: ' + response.getStatus());
                responseJson=response.getStatus();
            }
            if(billingType=='Build'){
                t.TIPS_Api_Response__c=responseJson;
            }
            if(billingType=='Admin'){
                t.TIPS_Api_Admin_Response__c=responseJson;
            }
            if(billingType=='Consulting'){
                t.TIPS_Api_Consulting_Response__c=responseJson;
            }
            update t;
            
        } catch (Exception e) {
            ODS_ExceptionUtility.logTipsIntegrationFailure(timeSheetId, body, e.getMessage(), 'Timesheet');
            
            Timesheet__c t=new Timesheet__c();
            t.Id=timeSheetId;
            if(billingType=='Build'){
                t.TIPS_Api_Response__c='Error Message: '+ e.getMessage();
            }
            if(billingType=='Admin'){
                t.TIPS_Api_Admin_Response__c='Error Message: '+ e.getMessage();
            }
            if(billingType=='Consulting'){
                t.TIPS_Api_Consulting_Response__c='Error Message: '+ e.getMessage();
            }
            update t;
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage());
        }
    }
    public static string GenerateAuthorizationToken() {
        try {
            JWT jwt = new JWT('HS256');
            jwt.privateKey = System.Label.JWT_Private_Key;
            jwt.iss = System.Label.JWT_Issuer;
            jwt.aud = System.Label.JWT_Aud;
            jwt.subject = System.Label.JWT_Subject;
            jwt.audience = System.Label.JWT_Audience;
            string token = jwt.GetToken();
            return token;
        } catch (Exception e) {
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage());
            return '';
        }
    }
    public string AESEncryptDecrypt(String inputString) {
        try {
            system.debug('inputString-'+inputString);
            Blob key = Blob.valueOf(System.Label.AES_Key);
            Blob data = Blob.valueOf(inputString);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
            JWT jwt = new JWT('HS256');
            string encrypted = EncodingUtil.base64Encode(encryptedData);
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encryptedData);
            String decryptedString = decrypted.toString();
            return encrypted;
        } catch (Exception e) {
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage());
            ODS_ExceptionUtility.LogException(e);
            return '';
        }
    }
    
    
    
    
}