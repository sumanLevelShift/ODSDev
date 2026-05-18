public class SalesforceFeatureChartController {
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string productImageUrl {get;set;}
    public boolean ReportButton {get;set;}

    public pagereference downloadHeatMapReport()
    {
       // AccountId = Apexpages.currentPage().getParameters().get('SelectedAccountId');
        //ServiceId = Apexpages.currentPage().getParameters().get('SelectedServiceID');
        //productImageUrl = Apexpages.currentPage().getParameters().get('chartURL');
        system.debug('productImageUrl--'+productImageUrl);
        system.debug('AccountId--'+AccountId);

        List<Account_Services__c> accountService=[SELECT id,Account__c,ODS_Service_Name__c FROM Account_Services__c Where ODS_Service_Name__c='Salesforce' AND Account__c=:AccountId Limit 1];
        if(!accountService.isEmpty()){
            list<Attachment> AttachmentRecord=[Select Id From Attachment Where Name=:'productCloud.png' AND ParentId=:accountService[0].id];
            if(!AttachmentRecord.isEmpty()){
                delete AttachmentRecord;
            }
            Attachment attachment = new Attachment();
            attachment.Body = EncodingUtil.base64Decode(productImageUrl);
            attachment.Name = 'productCloud.png';
            attachment.ParentId = accountService[0].id; 
            insert attachment;
        }
        PageReference pageRef = new PageReference('/apex/SalesforceHeatMapReport');
        pageRef.getParameters().put('accountId',AccountId);
        
        return pageRef;
    }
    public void GetAccountServiceID() 
    {
        ReportButton=false;    
        List<ClientAndNamedCredMapping__mdt> conApp=[SELECT id,Account_Id__c,Is_Active__c,Use_Connected_App__c,In_progress__c FROM ClientAndNamedCredMapping__mdt 
                                                     where Account_Id__c=:AccountId AND In_progress__c=:false AND Last_Run_Date_Time__c !=null];
        if(!conApp.isEmpty()){
            ReportButton=conApp[0].Use_Connected_App__c;
        }
        ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);        
    }
}