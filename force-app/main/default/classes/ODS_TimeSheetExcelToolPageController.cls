public class ODS_TimeSheetExcelToolPageController {
    public List <Initiatives__c> initList {get;set;} 
    public List <Account> accountList {get;set;} 
    public List<integer> emptyRow {get;set;}
    public List <string> weekDateList {get;set;} 
    public String xmlheader {get;set;}
    public String endfile{get;set;}
    public String fileName {get;set;}
    public String CurrentDate {get; set;}
    public list<string> TPMList {get;set;}
    public Map<String, String> accountListAlpha {get; set;}
    public Map<String, String> accInitiativeRange {get; set;}
    public ODS_TimeSheetExcelToolPageController(){
        TPMList=new List<string>();
        accountListAlpha = new Map<String, String>();
        accInitiativeRange = new Map<String, String>();

        for( Schema.PicklistEntry obj : Initiatives__c.Technical_Project_Manager__c.getDescribe().getPicklistValues()) {
            if(obj.getValue() !='None'){
                TPMList.add(obj.getValue());  
            }
        }
        
        Datetime currentDateTime = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        CurrentDate  = currentDateTime.format('MM/dd/yyyy'); // formats the date
        
        initList=new List <Initiatives__c>();
        accountList=new List <Account>();
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
        weekDateList=new List<string>();
        emptyRow=new List<integer>();
        
        ODS_Common_Utility obj = new ODS_Common_Utility();
        String[] AccounIDs = obj.getAllAccountIDByLoggedInUser();
        accountList=[Select Id,Name From Account Where Id IN: AccounIDs order by Name];
        initList = [Select id, name, Status__c,Account_Service__c,Account_Name__c,Account_Service__r.Account__r.Name from Initiatives__c where (Account_Service__r.Account__c IN: AccounIDs) and (Status__c ='Initiative Approved' OR Status__c ='Active Initiative') AND Account_Service__r.ODS_Service_Name__c='Salesforce' order by Account_Service__r.Account__r.Name,name];        
        system.debug('initList---'+initList);

        for (Account acc : accountList) {
            accountListAlpha.put(acc.Name, accountNameToAlpha(acc.Name));
        }

        AggregateResult[] results = [SELECT Account_Service__r.Account__r.Name, Count(Id) FROM Initiatives__c 
        WHERE (Account_Service__r.Account__c IN: AccounIDs) and (Status__c ='Initiative Approved' OR Status__c ='Active Initiative') 
        AND Account_Service__r.ODS_Service_Name__c='Salesforce' 
        Group By Account_Service__r.Account__r.Name Order by Account_Service__r.Account__r.Name];

        integer initiativeRowStart = 2;
        for (AggregateResult ar : results)  {
            accInitiativeRange.put(accountNameToAlpha(String.valueOf(ar.get('Name'))), 'R'+initiativeRowStart+'C2:R'+ (initiativeRowStart + integer.valueOf(ar.get('expr0'))-1)  +'C2');
            initiativeRowStart = initiativeRowStart + integer.valueOf(ar.get('expr0'));
        }        

        date currentWeekDate = date.parse(ApexPages.currentPage().getParameters().get('startDate'));
        DateTime dt1 = DateTime.newInstance(currentWeekDate.year(), currentWeekDate.month(),currentWeekDate.day());
        String dayOfWeek = dt1.format('E');
        if(dayOfWeek=='Sun'){
            currentWeekDate=currentWeekDate.addDays(-1); 
        }
        
        date weekStart = currentWeekDate.toStartofWeek();
        for(integer i=1;i<=7;i++){
            date dToday=weekStart.addDays(i);
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            //String dateStr = dt.format('dd-MMM-YYYY');
            String dateStr = dt.format('yyyy-MM-dd')+'T00:00:00.000';
            system.debug('dt---'+dateStr);

            weekDateList.add(dateStr);
        }
        system.debug('weekDateList--'+weekDateList);
        //empty row on excel sheet
        for(integer i=0;i<500;i++){
            emptyRow.add(i);
        }
        
        date dToday1=weekStart.addDays(1);
        DateTime dt = DateTime.newInstance(dToday1.year(), dToday1.month(),dToday1.day());
        String dateStr = dt.format('dd-MMM-yyyy');
        fileName='Timesheet - '+dateStr; 
        
        
    }

    private static String accountNameToAlpha(string accName){
        return accName.replaceAll('[^a-zA-Z\\s]','').replace(' ', '_');
    }
    
}