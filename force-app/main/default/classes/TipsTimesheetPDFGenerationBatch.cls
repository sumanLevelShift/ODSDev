global class TipsTimesheetPDFGenerationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public string timesheetFrequency='';
    Public string weeklyTimesheetId='';
    Public Set<id> monthlyTimesheetIdSet;
    Public date startDate;
    Public date endDate;
    Public string tipsId;
    Public string initiativeType;
    public boolean isABCCustomer;
    Public string accountName;
    public TipsTimesheetPDFGenerationBatch(string timesheetFrequency,string weeklyTimesheetId,Set<id> monthlyTimesheetIdSet,
                                           date startDate,date endDate,string tipsId,string initiativeType,boolean isABCCustomer,string accountName){
                                               this.timesheetFrequency=timesheetFrequency;
                                               this.weeklyTimesheetId=weeklyTimesheetId;
                                               this.monthlyTimesheetIdSet=monthlyTimesheetIdSet;
                                               this.startDate=startDate;
                                               this.endDate=endDate;
                                               this.tipsId=tipsId;
                                               this.initiativeType=initiativeType;
                                               this.isABCCustomer=isABCCustomer;
                                               this.accountName=accountName;
                                               
                                           }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        query='SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c,Timesheet__r.Approver_Name__r.Name,Timesheet__r.Comments__c,Timesheet__r.ApproverName__c,Timesheet__r.Approved_Date__c,Timesheet__r.Account_Services__r.Account__r.Name,Timesheet__r.Account_Services__r.ODS_Service_Name__c,Timesheet__r.Status__c FROM Time_Sheet_Details__c LIMIT 1';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Time_Sheet_Details__c> scope) {
        try{
            PageReference pdfPage=new PageReference ('/apex/TipsTimesheetPDF?timesheetFrequency='+timesheetFrequency+'&weeklyTimesheetId='+weeklyTimesheetId);
            pdfPage.getParameters().put('monthlyTimesheetIdSet', String.join(monthlyTimesheetIdSet, ','));
            pdfPage.getParameters().put('startDate', string.valueOf(startDate));
            pdfPage.getParameters().put('endDate', string.valueOf(endDate));
            pdfPage.getParameters().put('tipsId', tipsId);
            pdfPage.getParameters().put('initiativeType', initiativeType);
            
            if(isABCCustomer){
                pdfPage.getParameters().put('CustomeType', 'ABC Type');
            }else{
                pdfPage.getParameters().put('CustomeType', 'Regular');
            }
            Datetime stTimesheetDate = DateTime.newinstance(startDate.year(),startDate.month(),startDate.day());
            Datetime enTimesheetDate = DateTime.newinstance(endDate.year(),endDate.month(),endDate.day());
            //string fileName=accountName+' - Timesheet - ' + stTimesheetDate.format('MM-dd-yyyy')+' to '+enTimesheetDate.format('MM-dd-yyyy')+' TIPS ID -'+tipsId+'.pdf';
            string fileName=tipsId+' - '+accountName+' - '+stTimesheetDate.format('MM-dd-yyyy')+' to '+enTimesheetDate.format('MM-dd-yyyy')+'.pdf';
            String base64Pdf;
            Blob pdfBlob;
            if(!Test.isRunningTest()) { 
                pdfBlob = pdfPage.getContent();
                base64Pdf = EncodingUtil.base64Encode(pdfBlob);
            }
            
            TipsAPIHelperClass apiHelper = new TipsAPIHelperClass();
            string body='{"data":"'+apiHelper.AESEncryptDecrypt('{"WorkOrderId":"'+tipsId+'","StartDate":"'+stTimesheetDate.format('MM/dd/yyyy')+'","EndDate":"'+enTimesheetDate.format('MM/dd/yyyy')+'","FileName":"'+fileName+'","Pdffile":"'+base64Pdf+'"}')+'"}';
            system.debug('PDF Body'+body);
            TipsTimesheetPDFController.uploadTimesheetToTips(body);
            if(String.isNotBlank(weeklyTimesheetId)){
                monthlyTimesheetIdSet.add(weeklyTimesheetId);
            }
            List<ContentDocumentLink> existingVersions = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE 
                                                          ContentDocument.Title = :fileName AND LinkedEntityId IN:monthlyTimesheetIdSet];
            If(!existingVersions.isEmpty()){
                delete existingVersions;
            }
            system.debug('monthlyTimesheetIdSet-'+monthlyTimesheetIdSet);
            ContentVersion newVersion = new ContentVersion();
            newVersion.Title = fileName;
            newVersion.PathOnClient = fileName;
            newVersion.VersionData = pdfBlob;
            newVersion.ContentLocation = 'S'; 
            insert newVersion;
            List<ContentDocumentLink> CDLList=new List<ContentDocumentLink>();
            for(ID timesheetId:monthlyTimesheetIdSet){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: newVersion.Id].ContentDocumentId;
                cdl.LinkedEntityId = timesheetId;
                cdl.ShareType = 'I'; 
                cdl.Visibility = 'AllUsers'; 
                CDLList.add(cdl);
            }
            if(!CDLList.isEmpty()){
                insert CDLList;
            }
        } catch (Exception e) {
            ODS_ExceptionUtility.LogException(e);
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}