public without sharing class oDSEstimationSummaryViewPageController {
     @AuraEnabled( cacheable = false )
    public static boolean getcurrentUserAccessForEstimation(){
        List<User> curUser=[SELECT Delivery_Role__c FROM User Where ( Delivery_Role__c !='' AND Delivery_Role__c !='None')  AND Id=:UserInfo.getUserId()];
        if(!curUser.isEmpty()){
            return true;
        }
        return false;
    }
    @AuraEnabled( cacheable = false )
    public static string getEstimationSummaryRecords(string accountId,Integer pageSize, Integer pageNumber){
        list<wrapODSEstimate> displayRecordList=new list<wrapODSEstimate>();
        String jsonDT = '';
        List<Estimation_Summary__c> estSumList=new List<Estimation_Summary__c>();
        Integer totalRecords = [SELECT COUNT() FROM Estimation_Summary__c where Customer__c=:accountId];
        Integer recordEnd;
        Integer offset=0;
        if(pageSize !=0){
            //Offset for SOQL
            offset = (pageNumber - 1) * pageSize;
            
            //Total Records
            recordEnd = pageSize * pageNumber;
            
            estSumList=[SELECT Status__c,Total_Effort_In_Hours__c,Project_ID__r.JIRA_ID__c ,Project_ID__r.Name,Customer__r.Name,Created_By__c,Customer__c,Customer_Success_Manager__c,Customer_Success_Manager__r.Name,Technical_Project_Manager__r.Full_Name__c,Estimation_Date__c,Id,Is_Coding_Involved__c,Name,Project_Billing_Type__c,Project_Description__c,Project_ID__c,Proposed_End_Date__c,Proposed_Start_Date__c,Revenue_Region__c,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c where Customer__c=:accountId ORDER BY LastModifiedDate DESC  NULLS FIRST LIMIT :pageSize OFFSET :offset ];
        }else{
            estSumList=[SELECT Status__c,Total_Effort_In_Hours__c ,Project_ID__r.JIRA_ID__c ,Project_ID__r.Name,Customer__r.Name,Created_By__c,Customer__c,Customer_Success_Manager__c,Customer_Success_Manager__r.Name,Technical_Project_Manager__r.Full_Name__c,Estimation_Date__c,Id,Is_Coding_Involved__c,Name,Project_Billing_Type__c,Project_Description__c,Project_ID__c,Proposed_End_Date__c,Proposed_Start_Date__c,Revenue_Region__c,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c where Customer__c=:accountId ORDER BY LastModifiedDate DESC  NULLS FIRST];
            
        }
        for(Estimation_Summary__c e:estSumList){
            boolean deleteIcon=false;
            if(e.Status__c == 'Approved' || e.Status__c == 'Ready for Approval'){
                deleteIcon=true;
            }
            displayRecordList.add(new wrapODSEstimate(e.Id,e.Customer__r.Name,e.Project_ID__r.Name,e.Project_ID__r.JIRA_ID__c ,e.Proposed_Start_Date__c,e.Technical_Project_Manager__r.Full_Name__c,e.Status__c,e.Estimation_Date__c,e.Customer_Success_Manager__r.Name,e.Total_Effort_In_Hours__c,deleteIcon));
        }
        PaginationDTWrapper objDT =  new PaginationDTWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.WrapODSEstimate=displayRecordList;
        jsonDT = JSON.serialize(objDT);
        return jsonDT;
    }
    
    @AuraEnabled(Cacheable=false)
    public static void updateSessionData(string accountId,string serviceId){
        system.debug('serviceId--'+serviceId);
        ODS_Common_Utility.upsertSessionData(accountId,serviceId);  
    }
    @AuraEnabled( cacheable = false )
    public static void deleteEstimationSummaryRecords(string recordId){
        List<Estimation_Summary__c> estSumList=[SELECT Project_ID__r.Name,Customer__r.Name,Created_By__c,Customer__c,Customer_Success_Manager__c,Technical_Project_Manager__c,Estimation_Date__c,Id,Is_Coding_Involved__c,Name,Project_Billing_Type__c,Project_Description__c,Project_ID__c,Proposed_End_Date__c,Proposed_Start_Date__c,Revenue_Region__c,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c where Id=:recordId ];
        if(!estSumList.isEmpty()){
            Delete estSumList;            
        }
    }
    public class PaginationDTWrapper {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public List<wrapODSEstimate> WrapODSEstimate {get;set;}
    }
    public class wrapODSEstimate {
        @AuraEnabled  
        public string ID {get; set;}
        @AuraEnabled  
        public string Customer {get; set;}
        @AuraEnabled  
        public string ProjectId {get; set;}
        @AuraEnabled  
        public string JiraId {get; set;}
        @AuraEnabled  
        public date StartDate {get; set;}
        @AuraEnabled  
        public string TechnicalProjectManager	 {get; set;}
        @AuraEnabled  
        public string Status {get; set;}
        @AuraEnabled  
        public date EstimateDate {get; set;}
        @AuraEnabled  
        public string CSMName {get; set;}
        @AuraEnabled  
        public Decimal totalEffortHours {get; set;}
        @AuraEnabled
        public boolean hideDeleteButton {get;set;}
        public wrapODSEstimate(string id,string cus,string proId,string JiraId,date stDate, string engManager,string s,date estimateDate,string csm,decimal teh,boolean d) {
            this.ID = id;
            this.Customer=cus;
            this.ProjectId = proId;
            this.JiraId = JiraId;
            this.StartDate = stDate;
            this.TechnicalProjectManager = engManager;
            this.Status = s;
            this.EstimateDate = estimateDate;
            this.CSMName=csm;
            this.totalEffortHours=teh;
            this.hideDeleteButton=d;
        }
    }
}