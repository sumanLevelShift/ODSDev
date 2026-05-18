public with sharing class onboardingWordDocController {
    @AuraEnabled(cacheable=false)
    public static boolean checkActiveAccount(string accountId){
        list<ClientAndNamedCredMapping__mdt> customMetadata=[SELECT Id,Account_Id__c FROM ClientAndNamedCredMapping__mdt WHERE Is_Active__c=true AND Account_Id__c=:accountId.substring(0,15)];
        if(customMetadata.isEmpty()){
            return true;
        }
        return false;
    }
    @AuraEnabled(cacheable=false)
    public static Account getCurrentAccount(string accountId){
        system.debug('accountId-'+accountId);
        Account accountList=[Select Id,Name,Business_Overview__c,Products_Services_Offered__c,Customers__c,Key_Competitors__c,Collaborators_Partners__c,Compliance_Requirements__c,
                             Salesforce_Roadmap__c,Product_Backlog__c,Current_Painpoints__c,ERP__c	From Account Where ID = :accountId Limit 1];
        system.debug('accountList-'+accountList);
        return accountList;
    }
    @AuraEnabled(cacheable=false)
    public static Map<string,string> getExternalData(string accountId){
        system.debug('accountId-'+accountId);
        List<OBD_External_Data__c> getExistingOBD=[SELECT ID,API_Response__c,Section_Name__c From OBD_External_Data__c WHERE Account__c =: accountId];
        Map<string,string> externalData=new Map<string,string>();
        for(OBD_External_Data__c ob:getExistingOBD){
            if(string.isNotBlank(ob.API_Response__c)){
                externalData.put(ob.Section_Name__c,ob.API_Response__c);
            }
        }
        system.debug('externalData-'+externalData.size());
        if(externalData.isEmpty()){
            Database.executeBatch(new onBoardingDocumentBatch(accountId.substring(0,15)));
            return null;
        }else{
            /*List<Account> listAccount=[Select Id,Onboarding_Document__c From Account WHERE ID=:accountId AND Onboarding_Document__c=:'Not Started' limit 1];
            if(!listAccount.isEmpty()){
                Account accountObj=new Account();
                accountObj.Id=listAccount[0].Id;
                accountObj.Onboarding_Document__c='In Progress';
                update accountObj;                
            }*/
            return externalData;
        }
        
    }
    @AuraEnabled
    public static void uploadFile(String base64, String filename, String recordId) {
        List<Account_Services__c> accountService=[SELECT id,Account__c,ODS_Service_Name__c FROM Account_Services__c Where ODS_Service_Name__c='Salesforce' AND Account__c=:recordId Limit 1];
        if(!accountService.isEmpty()){
            list<Attachment> AttachmentRecord=[Select Id From Attachment Where Name=:filename+'.docx' AND ParentId=:accountService[0].Id];
            if(!AttachmentRecord.isEmpty()){
                delete AttachmentRecord;
            }
            
            Attachment attachment = new Attachment();
            attachment.Body = EncodingUtil.base64Decode(base64);
            attachment.Name = filename+'.docx';
            attachment.ParentId = accountService[0].id; 
            insert attachment;
        }
    }   
}