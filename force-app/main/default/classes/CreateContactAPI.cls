/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       CreateContactAPI
* @description      This API class is calling from ODS_ContactViewController
*********************************************************************************************
Version     Date            Team            Comments
*********************************************************************************************
* 1         31-MAR-2021     DemandBlue      Initial Development
*********************************************************************************************/
@RestResource(urlMapping='/createContact')
global without sharing class CreateContactAPI {    
    @HttpPost
    global static Void createContactNew(){ 
        try{
            // Initializing the request parameter with the incoming request
            RestRequest contactRequest = RestContext.request;
            // Getting the request body from the request
            String requestBody = contactRequest.requestBody.toString();
            //Deserializing the JSON response body and assigning it to an instance of Contact object
            Map<String, Object> contactMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            Contact contact = new Contact();
            contact.LastName = (String)contactMap.get('LastName');
            contact.FirstName = (String)contactMap.get('FirstName');
            contact.AccountId = (String)contactMap.get('AccountId');
            contact.Title = (String)contactMap.get('Title');
            contact.ReportsToId = (String)contactMap.get('ReportsToId');
            contact.Role_Level__c = (String)contactMap.get('RoleLevel');
            contact.Status__c = (String)contactMap.get('Status');
            contact.MailingStreet = (String)contactMap.get('MailingStreet');
            contact.MailingCity = (String)contactMap.get('MailingCity');
            contact.MailingState = (String)contactMap.get('MailingState');
            contact.MailingPostalCode = (String)contactMap.get('MailingPostalCode');
            contact.MailingCountry = (String)contactMap.get('MailingCountry');
            contact.Phone = (String)contactMap.get('Phone');
            contact.MobilePhone = (String)contactMap.get('MobilePhone');
            contact.Email = (String)contactMap.get('Email');
            contact.ODS_DotNet_Status__c = (String)contactMap.get('ODSDotNetStatus');
            contact.isPrimary__c = (boolean)contactMap.get('isPrimary');
            contact.HasOptedOutOfEmail = (boolean)contactMap.get('HasOptedOutOfEmail');
            contact.Is_Portal_Access__c = (boolean)contactMap.get('IsPortalAccess');
            contact.OtherStreet = (String)contactMap.get('OtherStreet');
            contact.OtherCity = (String)contactMap.get('OtherCity');
            contact.OtherState = (String)contactMap.get('OtherState');
            contact.OtherPostalCode = (String)contactMap.get('OtherPostalCode');
            contact.OtherCountry = (String)contactMap.get('OtherCountry');
            String contactId = (String)contactMap.get('Id');
            if(String.IsNotBlank(contactId)){
                contact.Id = contactId;
                update contact;
            }
            else{
                insert contact;
            }
        }
        catch(exception e){            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured on saving new Contact::: <font color="red" size = "4">' + e.getMessage() + '</font>'));
        }
    }    
}