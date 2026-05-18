public class ODSSubscriptionInvoiceReport {
    @AuraEnabled(cacheable=true)
    public static MonthLabelWrapper getTableLabels(String selectedYear) {
        Integer startYear = Integer.valueOf(selectedYear.substring(0, 4));
        Integer endYear = startYear + 1;
        
        List<String> tableLabels = new List<String>();
        for (Integer month = 4; month <= 12; month++) {
            tableLabels.add(DateTime.newInstance(startYear, month, 1).format('MMM-yy'));
        }
        for (Integer month = 1; month <= 3; month++) {
            tableLabels.add(DateTime.newInstance(endYear, month, 1).format('MMM-yy'));
        }     
        MonthLabelWrapper wrapper = new MonthLabelWrapper(tableLabels);
        return wrapper;
    }
    
    @AuraEnabled(cacheable=True)
    public static string getworkorderdetails(String selectedYear,Integer pageSize, Integer pageNumber) {          
        String fiscalYear = '';
        Integer startYear = Integer.valueOf(selectedYear.substring(0, 4));
        Integer endYear = Integer.valueOf(selectedYear.substring(5));
        // Define the start date of the fiscal year
        Date fiscalYearStart = Date.newInstance(startYear, 4, 1);
        // Define the end date of the fiscal year
        Date fiscalYearEnd = Date.newInstance(endYear, 3, 31);
        // Format the start date as DD/MM/YYYY
        String startDateString = String.valueOf(fiscalYearStart.year()) + '-'
            + String.valueOf(fiscalYearStart.month()) + '-'
            + String.valueOf(fiscalYearStart.day());
        
        // Format the end date as DD/MM/YYYY
        String endDateString = String.valueOf(fiscalYearEnd.year()) + '-'
            + String.valueOf(fiscalYearEnd.month()) + '-'
            + String.valueOf(fiscalYearEnd.day());
        Date startdateValue = Date.valueOf(startDateString);
        Datetime datetimeValue = Datetime.newInstance(startdateValue.year(), startdateValue.month(), startdateValue.day());
        String formattedDate = datetimeValue.format('yyyy-MM-dd');
        Date fdateValue = Date.valueOf(formattedDate);
        Date enddateValue = Date.valueOf(endDateString);
        String jsonObjItm = '';
        Integer offset = (pageNumber-1) * pageSize; 
        Integer totalRecords = [SELECT COUNT() FROM Work_Order__c WHERE SubCategory__c In('DemandBlue-Subscription', 'DemandBlue-Subscription-CO') AND Client_Name__c != null AND ((Project_Start_Date__c >= :fdateValue AND Project_End_Date__c <= :enddateValue) OR (Project_Start_Date__c <= :enddateValue AND Project_End_Date__c >=: fdateValue )) ];
        Integer recordEnd = pageSize * pageNumber;
        WorkOrderItemWrapper workOrderItemObj =  new WorkOrderItemWrapper();  
        workOrderItemObj.pageNumber = pageNumber;
        workOrderItemObj.pageSize = pageSize;        
        workOrderItemObj.recordStart = offset + 1;
        workOrderItemObj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        workOrderItemObj.totalRecords = totalRecords;

        List<WorkOrderDetails> workOrderDetailsList=new List<WorkOrderDetails>();
        List<Work_Order__c> tamLst = new List<Work_Order__c>(); 
        tamLst = [SELECT Account_CSM__c,Account_Manager_Name__c,Client_Name__r.Client_Code__c,Client_Name__r.Name,CSM__c,Id,Project_End_Date__c,Project_Code__c,Project_Name__c,Project_Start_Date__c,SubCategory__c,Subscription_Fee_Exceptions__c,Subscription_Fee_Frequency__c,Subscription_Fee_Terms__c,Client_Name__r.Project_Code__c,Subscription_Fee__c,Total_Subscription_Fee__c FROM Work_Order__c WHERE SubCategory__c In('DemandBlue-Subscription', 'DemandBlue-Subscription-CO') AND Client_Name__c != null AND 
                  ((Project_Start_Date__c >= :fdateValue AND Project_End_Date__c <= :enddateValue) OR (Project_Start_Date__c <= :enddateValue AND Project_End_Date__c >=: fdateValue )) order by Client_Name__r.Name LIMIT :pageSize OFFSET :offset];
        For(Work_Order__c wo:tamLst){
            WorkOrderDetails wObj=new WorkOrderDetails();
            wObj.Id=wo.id;
            wObj.CustomerName = wo.Client_Name__r.Name;
            wObj.Accounting = wo.Client_Name__r.Client_Code__c;
            wObj.CSM = wo.Account_CSM__c;
            wObj.SubscriptionFF = wo.Subscription_Fee_Frequency__c;
            wObj.SubscriptionFT = wo.Subscription_Fee_Terms__c;
            wObj.SubscriptionFE = wo.Subscription_Fee_Exceptions__c;
            
            decimal totalFees=wo.Total_Subscription_Fee__c;
            decimal sumOfFees=0;
            List<integer> monthsInRange=new List<integer>();
            if(wo.Subscription_Fee_Frequency__c=='Annually' || wo.Subscription_Fee_Frequency__c=='Upfront'){
                date projectStartDate=wo.Project_Start_Date__c;
                if (projectStartDate >= fdateValue && projectStartDate <= enddateValue) {
                    monthsInRange.add(projectStartDate.month());
                }
            }
            if(wo.Subscription_Fee_Frequency__c=='Monthly'){
                monthsInRange=getMonths(wo.Project_Start_Date__c,wo.Project_End_Date__c,fdateValue,enddateValue);
            }
            
            for(integer i:monthsInRange){
                if(i==4){wObj.April=totalFees;sumOfFees+=totalFees;}
                if(i==5){wObj.May=totalFees;sumOfFees+=totalFees;}
                if(i==6){wObj.June=totalFees;sumOfFees+=totalFees;}
                if(i==7){wObj.July=totalFees;sumOfFees+=totalFees;}
                if(i==8){wObj.August=totalFees;sumOfFees+=totalFees;}
                if(i==9){wObj.September=totalFees;sumOfFees+=totalFees;}
                if(i==10){wObj.October=totalFees;sumOfFees+=totalFees;}
                if(i==11){wObj.November=totalFees;sumOfFees+=totalFees;}
                if(i==12){wObj.December=totalFees;sumOfFees+=totalFees;}
                if(i==1){wObj.January=totalFees;sumOfFees+=totalFees;}
                if(i==2){wObj.February=totalFees;sumOfFees+=totalFees;}
                if(i==3){wObj.March=totalFees;sumOfFees+=totalFees;}
            }
            wObj.SumOfFees=sumOfFees;
            workOrderDetailsList.add(wObj);                
        }
        workOrderItemObj.WorkOrderDetails=workOrderDetailsList;
        jsonObjItm  = JSON.serialize(workOrderItemObj);
        return jsonObjItm;
    }
    
    /*
     * Add the months to the output list only if one of the following conditions are met:
     * 1) current month value (from project start date/fiscal year start date) is not same as project end date month
     * 2) current month value is same as project end date month AND no. of days in the project end date month is same as the project end date day 
     * 		- this condition will avoid adding additional month to the list if the end date day is not 28/29 (Feb) or 30/31 for others. eg: 3/15/2023 to 7/14/2023
     * 		- when the above is not added, invoice period will appear as 5 months instead of 4 months.
     * 
     */
    public static List<integer> getMonths(date projectStartDate,date projectEndDate, date fiscalYearStart,date fiscalYearEnd){
        Date actualProjectStartDate = projectStartDate;
        List<integer> monthsInRange = new List<integer>();
        if (projectStartDate < fiscalYearStart) {
            projectStartDate = fiscalYearStart;
        }
        if (projectEndDate > fiscalYearEnd) {
            projectEndDate = fiscalYearEnd;
        }
        
        Date currentMonth = projectStartDate;
        while (currentMonth <= projectEndDate) {
            datetime dt=currentMonth;
            if((currentMonth.month() != projectEndDate.month()) || 
               (currentMonth.month() == projectEndDate.month() && (Date.daysInMonth(projectEndDate.year(), projectEndDate.month()) == projectEndDate.day()))){
                   monthsInRange.add(currentMonth.month());
               }
            currentMonth = currentMonth.addMonths(1);
        }
        return monthsInRange;
    }
    
   
    public class WorkOrderItemWrapper { 
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public Integer pageSize {get;set;}    
        @AuraEnabled
        public List<WorkOrderDetails> WorkOrderDetails {get;set;}
    }
    public class MonthLabelWrapper {
        @AuraEnabled
        public Decimal totalYear{get;set;}
        @AuraEnabled
        public string fyMonths{get;set;}
        @AuraEnabled
        public List<String> labels { get; set; }
        public MonthLabelWrapper(List<String> labelList){
            this.labels=labelList;
            
        }
    }
    public class WorkOrderDetails {
        @AuraEnabled
        public string Id{get;set;}
        @AuraEnabled
        public String customerName{get;set;}
        @AuraEnabled
        public String Accounting{get;set;}
        @AuraEnabled
        public String CSM{get;set;}
        @AuraEnabled
        public decimal sumOfFees {get;set;}
        @AuraEnabled
        public Decimal April{get;set;}
        @AuraEnabled
        public Decimal May{get;set;}
        @AuraEnabled
        public Decimal June{get;set;}
        @AuraEnabled
        public Decimal July{get;set;}
        @AuraEnabled
        public Decimal August{get;set;}
        @AuraEnabled
        public Decimal September{get;set;}
        @AuraEnabled
        public Decimal October{get;set;}
        @AuraEnabled
        public Decimal November{get;set;}
        @AuraEnabled
        public Decimal December{get;set;}
        @AuraEnabled
        public Decimal January{get;set;}
        @AuraEnabled
        public Decimal February{get;set;}
        @AuraEnabled
        public Decimal March{get;set;}
        @AuraEnabled
        public String subscriptionFF{get;set;}
        @AuraEnabled
        public String subscriptionFT{get;set;}
        @AuraEnabled
        public String subscriptionFE{get;set;}
    }
    
}