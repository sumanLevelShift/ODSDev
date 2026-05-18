public class InitiativesReportExportController {
    public static string accountName {get;set;}
    public static string serviceName {get;set;}
    public static string tableHTML {get;set;}
    public static list<initiativeReportWrp> initiativeReportRecords {get;set;}
    public InitiativesReportExportController(){
        tableHTML='';
        initiativeReportRecords=new list<initiativeReportWrp>();
        String accountId=ApexPages.currentPage().getParameters().get('accountId');
        String serviceId=ApexPages.currentPage().getParameters().get('serviceId');
        string initiStatusList=ApexPages.currentPage().getParameters().get('initiativeStatusList');
        string stDate=ApexPages.currentPage().getParameters().get('stDate');
        string enDate=ApexPages.currentPage().getParameters().get('enDate');
        date startDate;
        date endDate;
        if(!string.isBlank(stDate)){
            startDate = date.valueOf( stDate );    
        }
        if(!string.isBlank(enDate)){
            endDate = date.valueOf( enDate ); 
        }
        
        list<string> initiativeStatusList=new list<string>();
        if(!string.isBlank(initiStatusList)){
            initiativeStatusList = initiStatusList.split(',');
        }
 
        List <Account_Services__c> accSerlist=new List <Account_Services__c>();
        if(!string.isBlank(accountId) && !string.isBlank(serviceId)){
            if(serviceId !='All'){
                accSerlist = [ SELECT Account__c,Id,ODS_Services__c,ODS_Service_Name__c,Account__r.Name FROM Account_Services__c Where Account__c =: accountId And ODS_Services__c =: serviceId  ];
            }else{
                accSerlist = [ SELECT Account__c,Id,ODS_Services__c,ODS_Service_Name__c,Account__r.Name FROM Account_Services__c Where Account__c =: accountId ];
            } 
            accountName=accSerlist[0].Account__r.Name;
            serviceName=accSerlist[0].ODS_Service_Name__c ;   
        }
        
        list<Initiatives__c> initiativeReportRecordsList=new list<Initiatives__c>();
        if(!string.isBlank(stDate)){
            initiativeReportRecordsList = [SELECT Account_Name__c,Account_Service__c,Id,Submitted_Hours__c,Approved_Date__c,Initiative_Approved_Date__c,Remaining_Hours__c,Consumed_Hours__c ,Name,Estimated_hours__c ,Status__c FROM Initiatives__c Where Status__c IN:initiativeStatusList AND Account_Service__c =:accSerlist[0].Id And ( (Initiative_Approved_Date__c >=: startDate And Initiative_Approved_Date__c <=:endDate) OR (Approved_Date__c >=: startDate And Approved_Date__c <=:endDate AND Initiative_Approved_Date__c =null)) order by Name];
            
        }else{
            initiativeReportRecordsList = [SELECT Account_Name__c,Account_Service__c,Id,Submitted_Hours__c,Approved_Date__c,Initiative_Approved_Date__c,Remaining_Hours__c,Consumed_Hours__c ,Name,Estimated_hours__c ,Status__c FROM Initiatives__c Where  Account_Service__c =:accSerlist[0].Id AND Status__c IN: initiativeStatusList AND (Initiative_Approved_Date__c !=null OR Approved_Date__c !=null) order by Name];
        }
        for(Initiatives__c i:initiativeReportRecordsList){
            date approvedDate;
            if(i.Initiative_Approved_Date__c !=null){
                approvedDate=i.Initiative_Approved_Date__c;
            }else{
                approvedDate=i.Approved_Date__c;
            }
            initiativeReportWrp iW=new initiativeReportWrp(i.Name,approvedDate,i.Estimated_hours__c,i.Submitted_Hours__c,i.Remaining_Hours__c,i.Status__c);
            initiativeReportRecords.add(iW);
        }
        
    }
    public class initiativeReportWrp{
        public string iniName {get;set;}
        public date approvedDate {get;set;}
        public decimal eHours {get;set;}
        public decimal sHours {get;set;}
        public decimal rHours {get;set;}
        public string status {get;set;}
        public initiativeReportWrp(string iName,date aDate,decimal e,decimal s,decimal r,string status){
            this.iniName=iName;
            this.approvedDate=aDate;
            this.eHours=e;
            this.sHours=s;
            this.rHours=r;
            this.status=status;
        }
    }
}