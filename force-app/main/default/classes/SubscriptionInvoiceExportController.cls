public class SubscriptionInvoiceExportController {
    public static string selectedYear {get;set;}
    public static String fileName {get;set;}
    @AuraEnabled(cacheable=true)
    public static MonthLabelWrapper getTableLabels() {
        selectedYear=ApexPages.currentPage().getParameters().get('selectedYear');
        Integer startYear = Integer.valueOf(selectedYear.substring(0, 4));
        Integer endYear = startYear + 1;
        List<String> tableLabels = new List<String>();
        for (Integer month = 4; month <= 12; month++) {
            tableLabels.add('=TEXT("'+DateTime.newInstance(startYear, month, 1)+'","MMM-yy")');   
        }
        for (Integer month = 1; month <= 3; month++) {
            tableLabels.add('=TEXT("'+DateTime.newInstance(endYear, month, 1)+'","MMM-yy")');
        }     
        MonthLabelWrapper wrapper = new MonthLabelWrapper(tableLabels);
        return wrapper;
    }
    public  SubscriptionInvoiceExportController() {
        selectedYear=ApexPages.currentPage().getParameters().get('selectedYear');
        fileName='ODS - Subscription Invoice Report FY - '+selectedYear;
    }
    public WorkOrderItemWrapper GetSubscriptionExport() { 
        selectedYear=ApexPages.currentPage().getParameters().get('selectedYear');
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
        WorkOrderItemWrapper workOrderItemObj =  new WorkOrderItemWrapper();  
        List<WorkOrderDetails> workOrderDetailsList=new List<WorkOrderDetails>();
        List<Work_Order__c> tamLst = new List<Work_Order__c>(); 
        tamLst = [SELECT Account_CSM__c,Account_Manager_Name__c,Client_Name__r.Client_Code__c,Client_Name__r.Name,CSM__c,Id,Project_End_Date__c,Project_Code__c,Project_Name__c,Project_Start_Date__c,SubCategory__c,Subscription_Fee_Exceptions__c,Subscription_Fee_Frequency__c,Subscription_Fee_Terms__c,Client_Name__r.Project_Code__c,Subscription_Fee__c,Total_Subscription_Fee__c FROM Work_Order__c WHERE SubCategory__c In('DemandBlue-Subscription', 'DemandBlue-Subscription-CO') AND Client_Name__c != null AND 
                  ((Project_Start_Date__c >= :fdateValue AND Project_End_Date__c <= :enddateValue) OR (Project_Start_Date__c <= :enddateValue AND Project_End_Date__c >=: fdateValue )) order by Client_Name__r.Name];
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
        //jsonObjItm  = JSON.serialize(workOrderItemObj);
        return workOrderItemObj;
    }
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
        public List<WorkOrderDetails> WorkOrderDetails {get;set;}
    }
    public class MonthLabelWrapper {
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