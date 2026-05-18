public class ODS_HoursConsumedController {
    @AuraEnabled 
    public static String exportPDF(string accountId, string serviceId) {
        
        PageReference pdfPage=new PageReference ('/apex/HoursConsumedPdf?accountId='+accountId+'&serviceId='+serviceId);
        String base64Pdf;
        if(!Test.isRunningTest()) { 
            Blob pdfBlob = pdfPage.getContent();
            base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        }
        return base64Pdf;
    }
    @AuraEnabled 
    public static string exportExcel(string accountId, string serviceId) {
        system.debug('accountId---'+accountId);
        PageReference exPage=new PageReference ('/apex/HoursConsumedExcel?accountId='+accountId+'&serviceId='+serviceId);
        String base64Excel;
        if(!Test.isRunningTest()) { 
            blob excelBlob = exPage.getContent();
            base64Excel = EncodingUtil.base64Encode(excelBlob);
        }
        return base64Excel;
    }
    @AuraEnabled( cacheable = true )
    public static List<Account_Services__c> getAccountDetails(string accountId, string serviceId){
        List <Account_Services__c> acclist = [ SELECT Account__c,Id,ODS_Services__c,Account__r.Name,ODS_Service_Name__c  FROM Account_Services__c Where Account__c =: accountId And ODS_Services__c =: serviceId  ];
        return acclist;
    }
    @AuraEnabled( cacheable = true )
    public static List<timesheetDetail> getTimesheetDetails(string accountId, string serviceId){
        List <Account_Services__c> acclist=new List <Account_Services__c>();
        if(serviceId !='All'){
            acclist = [ SELECT Account__c,Id,ODS_Services__c FROM Account_Services__c Where Account__c =: accountId And ODS_Services__c =: serviceId  ];
        }else{
            acclist = [ SELECT Account__c,Id,ODS_Services__c FROM Account_Services__c Where Account__c =: accountId ];
        }
        
        list<string> status=new List<string>();
        status.add('Submitted');
        status.add('Approved');
        
        List<AggregateResult> timesheetOds=[Select Time_Sheet_Cost__r.Year__c,SUM(ODS_Total_Hour__c) sumvalue  from Timesheet__c Where Status__c IN:status AND Time_Sheet_Cost__r.Year__c !=null and Account_Services__c=:acclist[0].id GROUP BY Time_Sheet_Cost__r.Year__c ORDER BY Time_Sheet_Cost__r.Year__c  DESC ];
        
        List<timesheetDetail> wrap1 = new List<timesheetDetail>();
        if(timesheetOds.size() > 0){
            for(AggregateResult a : timesheetOds) {  
                system.debug('a---'+a);
                decimal hours=0.00;
                if((Decimal)a.get('sumvalue')!=null){
                    hours=(Decimal)a.get('sumvalue');
                }
                timesheetDetail wrap2 =  new timesheetDetail();
                wrap2.timesheetTotalHours = hours.setScale(2, RoundingMode.CEILING);
                wrap2.timesheetYears = (string)a.get('Year__c');
                wrap1.add(wrap2);  
            }
        }
        
        return wrap1 ;
        //return reportRec;
        
        
    }
 
    public class timesheetDetail{
        
        @AuraEnabled
        public Decimal  timesheetTotalHours{get;set;}
        @AuraEnabled
        public string  timesheetYears{get;set;}      
        
    }
    
}