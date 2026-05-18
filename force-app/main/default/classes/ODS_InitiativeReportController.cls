public with sharing class ODS_InitiativeReportController {
    public static string getAccountID {get;set;}
    public static string getServiceID {get;set;}
    public static list<string> getStatus {get;set;}
    public static date getStartDate {get;set;}
    public static date getEndDate {get;set;}
    
    @AuraEnabled(cacheable=true)
    public static string getExportDetailsWithDate(string accountId, string serviceId, list<string> Initiativestatus,Date startDate ,Date endDate,string fileType){
        getAccountID=accountId;
        getServiceID=serviceId;
        if(Initiativestatus.isEmpty()){
            getStatus=getPickListValuesIntoList();
        }else{
            getStatus=Initiativestatus;   
        }
        getStartDate=startDate;
        getEndDate=endDate;
        string content;
        if(fileType == 'PDF'){
            content= exportPDF();
        }else{
            content= exportExcel(); 
        }
        return content;
    }
    @AuraEnabled(cacheable=true)
    public static string getExportDetailsWithOutDate(string accountId, string serviceId, list<string> Initiativestatus,string fileType){
        getAccountID=accountId;
        getServiceID=serviceId;
        if(Initiativestatus.isEmpty()){
            getStatus=getPickListValuesIntoList();
        }else{
            getStatus=Initiativestatus;   
        }
        string content;
        if(fileType == 'PDF'){
            content= exportPDF();
        }else{
            content= exportExcel(); 
            system.debug('content---'+content);
        }
        return content;
    }
    @AuraEnabled(cacheable=true)
    public static String exportPDF() {
        PageReference pdfPage=new PageReference ('/apex/InitiativesReportPDF?serviceId='+getServiceID+'&accountId='+getAccountID);
        pdfPage.getParameters().put('initiativeStatusList', String.join(getStatus, ','));
        pdfPage.getParameters().put('stDate', string.valueOf(getStartDate));
        pdfPage.getParameters().put('enDate', string.valueOf(getEndDate));
        
        String base64Pdf;
        if(!Test.isRunningTest()) { 
            Blob pdfBlob = pdfPage.getContent();
            base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        }
        return base64Pdf;
    }
    @AuraEnabled
    public static String exportExcel() {
        
        PageReference exPage=new PageReference ('/apex/InitiativesReportExcel?accountId='+getAccountID+'&serviceId='+getServiceID);
        exPage.getParameters().put('initiativeStatusList', String.join(getStatus, ','));
        exPage.getParameters().put('stDate', string.valueOf(getStartDate));
        exPage.getParameters().put('enDate', string.valueOf(getEndDate));
        String base64Excel;
        if(!Test.isRunningTest()) { 
            Blob excelBlob = exPage.getContent();
            base64Excel = EncodingUtil.base64Encode(excelBlob);
        }
        return base64Excel;
    }
    
    @AuraEnabled( cacheable = true )
    public static List<Account_Services__c> getAccountDetails(string accountId, string serviceId){
        List <Account_Services__c> acclist = [ SELECT Account__c,Id,ODS_Services__c,Account__r.Name,ODS_Service_Name__c  FROM Account_Services__c Where Account__c =: accountId And ODS_Services__c =: serviceId  ];
        return acclist;
    }
    
    @AuraEnabled( cacheable = false )
    public static List<initiativeReportWrp> getInitiativeDetails(string accountId, string serviceId){
        List <Account_Services__c> acclist=new List <Account_Services__c>();
        List <Initiatives__c> intList = new List <Initiatives__c>();
        if(serviceId !='All'){
            acclist = [ SELECT Account__c,Id,ODS_Services__c FROM Account_Services__c Where Account__c =: accountId And ODS_Services__c =: serviceId  ];
        }else{
            acclist = [ SELECT Account__c,Id,ODS_Services__c FROM Account_Services__c Where Account__c =: accountId ];
        }
        system.debug('acclist'+acclist);
        if(!acclist.isEmpty()){
            intList = [SELECT Account_Name__c,Account_Service__c,Id,Submitted_Hours__c,Approved_Date__c,Initiative_Approved_Date__c,Remaining_Hours__c,Consumed_Hours__c ,Name,Estimated_hours__c ,Status__c FROM Initiatives__c Where Status__c IN:getPickListValuesIntoList() AND Account_Service__c =:acclist[0].Id AND (Initiative_Approved_Date__c !=null OR Approved_Date__c !=null) order by Name];   
        }
        list<initiativeReportWrp> initiativeReportWrpList=new list<initiativeReportWrp>();
        for(Initiatives__c i:intList){
            date approvedDate;
            if(i.Initiative_Approved_Date__c !=null){
                approvedDate=i.Initiative_Approved_Date__c;
            }else{
                approvedDate=i.Approved_Date__c;
            }
            initiativeReportWrp iW=new initiativeReportWrp(i.id,i.Name,approvedDate,i.Estimated_hours__c,i.Submitted_Hours__c,i.Remaining_Hours__c,i.Status__c);
            initiativeReportWrpList.add(iW);
        }
        return initiativeReportWrpList ;
        
        
    }
    @AuraEnabled( cacheable = false )
    public static List<initiativeReportWrp> getSearchDetailsForStatus(string accountId, string serviceId, list<string> Initiativestatus){
        List <Account_Services__c> acclist=new List <Account_Services__c>();
        
        if(serviceId !='All'){
            acclist = [ SELECT Account__c,Id,ODS_Services__c FROM Account_Services__c Where Account__c =: accountId And ODS_Services__c =: serviceId  ];
        }else{
            acclist = [ SELECT Account__c,Id,ODS_Services__c FROM Account_Services__c Where Account__c =: accountId ];
        }
        List <Initiatives__c> intList = new List <Initiatives__c>();
        if(!acclist.isEmpty()){
            if(Initiativestatus.isEmpty()){
                Initiativestatus=getPickListValuesIntoList();
            }
            intList = [SELECT Account_Name__c,Account_Service__c,Id,Submitted_Hours__c,Approved_Date__c,Initiative_Approved_Date__c,Remaining_Hours__c,Consumed_Hours__c ,Name,Estimated_hours__c ,Status__c FROM Initiatives__c Where Account_Service__c =:acclist[0].Id AND Status__c IN: Initiativestatus AND (Initiative_Approved_Date__c !=null OR Approved_Date__c !=null)];            
        }
        
        list<initiativeReportWrp> initiativeReportWrpList=new list<initiativeReportWrp>();
        for(Initiatives__c i:intList){
            date approvedDate;
            if(i.Initiative_Approved_Date__c !=null){
                approvedDate=i.Initiative_Approved_Date__c;
            }else{
                approvedDate=i.Approved_Date__c;
            }
            initiativeReportWrp iW=new initiativeReportWrp(i.id,i.Name,approvedDate,i.Estimated_hours__c,i.Submitted_Hours__c,i.Remaining_Hours__c,i.Status__c);
            initiativeReportWrpList.add(iW);
        }
        return initiativeReportWrpList ;
    }
    @AuraEnabled( cacheable = false )
    public static List<initiativeReportWrp> getSearchDetails(string accountId, string serviceId, list<string> Initiativestatus,Date startDate ,Date endDate){
        system.debug('---startDate--'+startDate);
        List <Account_Services__c> acclist=new List <Account_Services__c>();
        
        if(serviceId !='All'){
            acclist = [ SELECT Account__c,Id,ODS_Services__c FROM Account_Services__c Where Account__c =: accountId And ODS_Services__c =: serviceId  ];
        }else{
            acclist = [ SELECT Account__c,Id,ODS_Services__c FROM Account_Services__c Where Account__c =: accountId ];
        }
        List <Initiatives__c> intList = new List <Initiatives__c>();
        if(!acclist.isEmpty()){
            if(Initiativestatus.isEmpty()){
                Initiativestatus=getPickListValuesIntoList();
            }
            intList = [SELECT Account_Name__c,Account_Service__c,Id,Submitted_Hours__c,Approved_Date__c,Initiative_Approved_Date__c,Remaining_Hours__c,Consumed_Hours__c ,Name,Estimated_hours__c ,Status__c FROM Initiatives__c Where Account_Service__c =:acclist[0].Id And ( (Initiative_Approved_Date__c >=: startDate And Initiative_Approved_Date__c <=:endDate) OR (Approved_Date__c >=: startDate And Approved_Date__c <=:endDate AND Initiative_Approved_Date__c =null)) And Status__c IN: Initiativestatus ];            
        }
        
        list<initiativeReportWrp> initiativeReportWrpList=new list<initiativeReportWrp>();
        for(Initiatives__c i:intList){
            date approvedDate;
            if(i.Initiative_Approved_Date__c !=null){
                approvedDate=i.Initiative_Approved_Date__c;
            }else{
                approvedDate=i.Approved_Date__c;
            }
            initiativeReportWrp iW=new initiativeReportWrp(i.id,i.Name,approvedDate,i.Estimated_hours__c,i.Submitted_Hours__c,i.Remaining_Hours__c,i.Status__c);
            initiativeReportWrpList.add(iW);
        }
        return initiativeReportWrpList ;    
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Initiatives__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.isActive()){
                if(pickListVal.getValue() =='Initiative Approved' || pickListVal.getValue() =='Initiative Delivered' || pickListVal.getValue() =='Active Initiative' ||pickListVal.getValue() =='Initiative Cancelled'){
                    pickListValuesList.add(pickListVal.getValue());
                }
            }
        }     
        return pickListValuesList;
    }
    public class initiativeReportWrp{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string iniName {get;set;}
        @AuraEnabled
        public date approvedDate {get;set;}
        @AuraEnabled
        public decimal eHours {get;set;}
        @AuraEnabled
        public decimal sHours {get;set;}
        @AuraEnabled
        public decimal rHours {get;set;}
        @AuraEnabled
        public string status {get;set;}
        public initiativeReportWrp(string id,string iName,date aDate,decimal e,decimal s,decimal r,string status){
            this.Id=id;
            this.iniName=iName;
            this.approvedDate=aDate;
            this.eHours=e;
            this.sHours=s;
            this.rHours=r;
            this.status=status;
        }
    }
}