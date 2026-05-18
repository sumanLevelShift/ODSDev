public class ODS_Invoice_MnthTimeSheetEC 
{
    public String terms {get; set;}
    //public String billToAddr {get; set;}
    public String BillStreet {get; set;}
    public String BillCity {get; set;}
    public String BillState {get; set;}
    public String BillCountry {get; set;}
    public String BillPostalCode {get; set;}
    public Double totAmt {get; set;}
    public List<wrapInvComp> lInvTablComp {get; set;}
    public String currentDate {get{return String.valueOf(String.valueOf(System.today().month()+'/'+System.today().day()+'/'+System.today().year()));} set;}
    public String invNumb {get; set;}
    public String accNumb {get; set;}
    public String dueDate {get{return String.valueOf(System.today().addMonths(1).month()+'/'+System.today().day()+'/'+System.today().year());} set;}
    public String billPerd {get;set;}
    public String refr {get;set;}
    public String project {get;set;}
    
    public String accServId = '';
    public String timSheetIds = '';
    public Date mnthStartDate;
    public Date mnthEndDate;
    Double rate = 0;
    
    public ODS_Invoice_MnthTimeSheetEC() {
        accServId = String.valueOf(ApexPages.currentPage().getParameters().get('AccServId'));
        terms = String.valueOf(ApexPages.currentPage().getParameters().get('term'));
        //String descr = String.valueOf(ApexPages.currentPage().getParameters().get('desc'));
        //billToAddr = String.valueOf(ApexPages.currentPage().getParameters().get('billTo'));
        BillStreet = String.valueOf(ApexPages.currentPage().getParameters().get('billToStr'));
        BillCity = String.valueOf(ApexPages.currentPage().getParameters().get('billToCty'));
        BillState = String.valueOf(ApexPages.currentPage().getParameters().get('billToStat'));
        BillCountry = String.valueOf(ApexPages.currentPage().getParameters().get('billToCtry'));
        BillPostalCode = String.valueOf(ApexPages.currentPage().getParameters().get('billToPcod'));
        invNumb = String.valueOf(ApexPages.currentPage().getParameters().get('invNumb'));
        accNumb = String.valueOf(ApexPages.currentPage().getParameters().get('accNumb'));
        billPerd = String.valueOf(ApexPages.currentPage().getParameters().get('billPerd'));
        timSheetIds = String.valueOf(ApexPages.currentPage().getParameters().get('timShtId'));
        mnthStartDate = Date.valueOf(ApexPages.currentPage().getParameters().get('startDt'));
        mnthEndDate = Date.valueOf(ApexPages.currentPage().getParameters().get('endDt'));
        refr = ApexPages.currentPage().getParameters().get('ref');
        project = ApexPages.currentPage().getParameters().get('proj');
               
        String rte = ApexPages.currentPage().getParameters().get('hrlyRate');
            if(String.isNotBlank(rte)) rte = rte; else rte='0';   
        rate = Double.valueOf(rte);
        String dis = ApexPages.currentPage().getParameters().get('discFee'); 
            if(String.isNotBlank(dis)) dis = dis; else dis='0';   
        Double discount = Double.valueOf(dis);
        
        lInvTablComp = new List<wrapInvComp>(); 
        //Validate timeSheet id parameter
        if(String.isNotBlank(timSheetIds)) {       
            if(discount != 0) {
                popInvInfo();
                lInvTablComp.add(new wrapInvComp(null,'LESS: Discount fee',0,-discount,rate-discount));
                totAmt = calcTotalAmt(lInvTablComp);
            }else {
                popInvInfo();
                totAmt = calcTotalAmt(lInvTablComp);
            }
        }   
    }
    
    private Double calcTotalAmt(List<wrapInvComp> lWrap) {
        Double sumAmt = 0;
        for(wrapInvComp w:lWrap) {
            sumAmt+=w.amount;
        }
        
        return sumAmt;
    }
   
    private void popInvInfo() {    
        Set<Id> sTimeSheets = new Set<Id>();
        //Store all timesheet ids to query timesheet details
        for(String s:timSheetIds.split('-')) {
            sTimeSheets.add(Id.valueOf(s));
        }
        //Timesheet details to construct invoice
        List<Time_Sheet_Details__c> objResult1;
        if(!sTimeSheets.isEmpty()) {
            objResult1 = new List<Time_Sheet_Details__c>([SELECT Task_Name__c,Hours_Worked__c
                                        FROM Time_Sheet_Details__c
                                        WHERE Timesheet__r.Account_Services__c =:accServId AND Timesheet__c IN:sTimeSheets AND (Status__c = 'Submitted' OR Status__c = 'Approved')
                                            AND Timesheet_Date__c >=:mnthStartDate AND Timesheet_Date__c <=:mnthEndDate 
                                        ORDER BY Task_Name__c ASC LIMIT 50000]);
        }                                        
        Set<String> sUniqueTasks = new Set<String>();
        List<wrapInvLineItems> lInvLineItem = new List<wrapInvLineItems>();
        if(!objResult1.isEmpty()) {
            for(Time_Sheet_Details__c tsd:objResult1) {
                sUniqueTasks.add(tsd.Task_Name__c);
            }                                                                                       
        }
        
        if(!sUniqueTasks.isEmpty()) {
            //Storing task names into List to make sortable - since Set cannot quarantee the order
            List<String> lUniqueTasks = new List<String>();            
            for(String sToL:sUniqueTasks) {
                lUniqueTasks.add(sToL);
            }
            lUniqueTasks.sort();
            
            Set<Id> sProcessedIds = new Set<Id>(); 
            Set<String> sProcessedTasks = new Set<String>();          
            Double hrsWorked = 0;
            Integer firstIndx = 0;
            System.debug('@@Task name list:'+lUniqueTasks);
            for(String s:lUniqueTasks) {
                for(Time_Sheet_Details__c td:objResult1) {
                    if(s == td.Task_Name__c && !sProcessedIds.contains(td.Id)) {
                        System.debug('@@Comparison success:'+td.Task_Name__c);
                        hrsWorked += td.Hours_Worked__c;
                        sProcessedIds.add(td.Id);
                        if(sProcessedIds.size() == objResult1.size()) {                            
                            lInvLineItem.add(new wrapInvLineItems(s,hrsWorked,rate,rate*hrsWorked));
                            sProcessedTasks.add(s);
                            hrsWorked = 0;
                            System.debug('@@End of list:'+lInvLineItem);
                            break; 
                        }else { 
                            continue;
                        }
                    }else if(!sProcessedTasks.contains(td.Task_Name__c) && !sProcessedIds.contains(td.Id)) {
                        lInvLineItem.add(new wrapInvLineItems(s,hrsWorked,rate,rate*hrsWorked));
                        //Once the matching logic is over - break and reinitalise the local vars to start the new comparision
                        sProcessedTasks.add(s);
                        hrsWorked = 0;
                        break;
                    }                        
                }                
            }
        }
        System.debug('@@Wrapper list:'+lInvLineItem);        
        Integer lineItemCount = 1;
        if(!lInvLineItem.isEmpty()) {
            for(wrapInvLineItems wrp:lInvLineItem) {
                lInvTablComp.add(new wrapInvComp(lineItemCount,wrp.LIdescription,wrp.LIhours,wrp.LIrate,wrp.LIamount));
                lineItemCount++;
            }
        }
    }

    //Wrapper to stor unique line items
    public class wrapInvLineItems
    {
        public String LIdescription {get; set;}
        public Double LIhours {get; set;}
        public Double LIrate {get; set;}
        public Double LIamount {get; set;}
        
        public wrapInvLineItems(String description,Double hrs,Double rate,Double amount) {
            this.LIdescription = description;
            this.LIhours = hrs;
            this.LIrate = rate;
            this.LIamount = amount;
        }
    }
        
    //Final wrapper with complete line item numbers
    public class wrapInvComp
    {
        public Integer itemNum {get;set;}
        public String description {get; set;}
        public Double hours {get; set;}
        public Double rate {get; set;}
        public Double amount {get; set;}
        
        public wrapInvComp(Integer itmNo,String description,Double hrs,Double rate,Double amount) {
            this.itemNum = itmNo;
            this.description = description;
            this.hours = hrs;
            this.rate = rate;
            this.amount = amount;
        }
    }        
}