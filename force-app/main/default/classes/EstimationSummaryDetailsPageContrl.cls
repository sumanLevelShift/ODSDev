public without sharing class EstimationSummaryDetailsPageContrl {
    public string EstimationId {get;set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public EstimationSummaryDetailsPageContrl(){
        AccountId = apexpages.currentpage().getparameters().get('accountId');
        ServiceId = apexpages.currentpage().getparameters().get('serviceId');
        EstimationId = apexpages.currentpage().getparameters().get('estimationId');
    }
    @AuraEnabled
    public static Estimation_Summary__c getEstimatedSummeryRecord(string estimatedId){
        Estimation_Summary__c es=[SELECT Acceptance_Criteria__c,Assumptions__c,CreatedById,CreatedDate,Created_By__c,Customer_Success_Manager__c,Customer__c,Estimation_Date__c,Has_Data_Migration__c,Id,IsDeleted,Is_Coding_Involved__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Out_of_Scope__c,Project_Billing_Type__c,Project_Description__c,Project_ID__c,Proposed_End_Date__c,Proposed_Start_Date__c,Revenue_Region__c,Scope__c,SystemModstamp,Team_Productivity__c,Technical_Project_Manager__c,Technology__c,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c 
                                  FROM Estimation_Summary__c WHERE Id=:estimatedId LIMIT 1];
        return es;
    }
    @AuraEnabled( cacheable = false )
    public static list<Initiatives__c> getInitiativesList(string accountId,string serviceId){
        list<Account_Services__c> accountSer=[SELECT Account__c,ODS_Services__c FROM Account_Services__c where Account__c=:accountId AND ODS_Services__c=:serviceId limit 1];
        
        list<Initiatives__c> initiativesList=new list<Initiatives__c> ();
        if(!accountSer.isEmpty()){
            initiativesList=[SELECT Account_Service__c,Id,Name FROM Initiatives__c where Account_Service__c=:accountSer[0].Id ORDER BY Name ASC NULLS FIRST];        
        }
        return initiativesList;
    }
    @AuraEnabled( cacheable = false )
    public static void updateWithRisk(string estimateSummaryId,decimal withRisk){
        List<Estimation_Summary__c> esList=[SELECT Id,With_Risk__c  FROM Estimation_Summary__c Where id=:estimateSummaryId Limit 1]; 
        if(!esList.isEmpty()){
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.Id=esList[0].id;
            es.With_Risk__c =withRisk;
            update es;
        }
    }
    @AuraEnabled( cacheable = false )
    public static Estimation_Summary__c getCustomerNamedetails(string estimateSummaryId){
        Estimation_Summary__c es=[SELECT Customer__c,Project_ID__c,Customer__r.Name,Project_ID__r.Name,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c Where id=:estimateSummaryId]; 
        return es;
    }
    @AuraEnabled( cacheable = false )
    public static integer checkInventorySize(string estimateSummaryId){
        list<Estimation_Detail__c> returnInventory=[SELECT Quantity__c,Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                                    FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimateSummaryId AND RecordType.Name=:'Inventory' ORDER BY S_No__c ASC NULLS FIRST];
        return returnInventory.size();
    }
    public PageReference updateSessionData(){
        system.debug('AccountId---'+AccountId);
        system.debug('ServiceId---'+ServiceId);
        string acId= ApexPages.currentPage().getParameters().get('SelectedAccountId');
        string serId= ApexPages.currentPage().getParameters().get('SelectedServiceID');
        ODS_Common_Utility.upsertSessionData(acId,serId);
        PageReference pr = new PageReference('/apex/ViewEstimationSummary');
        pr.setRedirect(true);
        return pr;
    }
   /* Public pagereference exportAsExcel()
    {
        try{
            
            PageReference excel = Page.EstimationReport;
            excel.getParameters().put('AccountId', AccountId);
            excel.getParameters().put('EstimationId', EstimationId);
            excel.setRedirect(true);
            return excel;
        }
        catch(exception e)
        {
            system.debug('The attachment is not deleted '+ e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }*/
}