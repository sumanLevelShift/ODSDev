public class HoursConsumedPDFController {
    public static string accountName {get;set;}
    public static string serviceName {get;set;}
    public static List<timesheetDetail> generateTimesheetDetails {get;set;}
    public HoursConsumedPDFController(){
        generateTimesheetDetails = new List<timesheetDetail>();
        
        String accountId=ApexPages.currentPage().getParameters().get('accountId');
        String serviceId=ApexPages.currentPage().getParameters().get('serviceId');
        if(!string.isBlank(accountId) && !string.isBlank(serviceId)){
            List <Account_Services__c> acclist=new List <Account_Services__c>();
            if(serviceId !='All'){
                acclist = [ SELECT Account__c,Id,ODS_Services__c,ODS_Service_Name__c,Account__r.Name FROM Account_Services__c Where Account__c =: accountId And ODS_Services__c =: serviceId  ];
            }else{
                acclist = [ SELECT Account__c,Id,ODS_Services__c,ODS_Service_Name__c,Account__r.Name FROM Account_Services__c Where Account__c =: accountId ];
            } 
            accountName=acclist[0].Account__r.Name;
            serviceName=acclist[0].ODS_Service_Name__c ;
            
            list<string> status=new List<string>();
            status.add('Submitted');
            status.add('Approved');
            
            List<AggregateResult> timesheetOds=[Select Time_Sheet_Cost__r.Year__c,SUM(ODS_Total_Hour__c) sumvalue  from Timesheet__c Where Status__c IN:status AND Time_Sheet_Cost__r.Year__c !=null and Account_Services__c=:acclist[0].id GROUP BY Time_Sheet_Cost__r.Year__c ORDER BY Time_Sheet_Cost__r.Year__c  DESC ];
            
            if(timesheetOds.size() > 0){
                for(AggregateResult a : timesheetOds) {   
                    decimal hours=0.00;
                    if((Decimal)a.get('sumvalue') !=null){
                        hours=(Decimal)a.get('sumvalue');
                    }
                    timesheetDetail wrap2 =  new timesheetDetail();
                    wrap2.timesheetTotalHours = hours;
                    wrap2.timesheetYears = (string)a.get('Year__c');
                    generateTimesheetDetails.add(wrap2);  
                }
            }
        }
        system.debug('generateTimesheetDetails---'+generateTimesheetDetails);
    }

    public class timesheetDetail{
        
        @AuraEnabled
        public Decimal  timesheetTotalHours{get;set;}
        @AuraEnabled
        public string  timesheetYears{get;set;}
        @AuraEnabled
        public string  ID{get;set;}
        
        
    }
}