public class ODS_DownloadTimsheetController {
    
    public List <Initiatives__c> initList {get;set;} 
    public List<integer> emptyRow {get;set;}
    public List <string> weekDateList {get;set;} 
    public String xmlheader {get;set;}
    public String endfile{get;set;}
    public String accountServiceId = ApexPages.currentPage().getParameters().get('accountService');
    public String accountName {get;set;}
    public String fileName {get;set;}
    public list<string> TPMList {get;set;}

    public ODS_DownloadTimsheetController(){
        
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
        weekDateList=new List<string>();
        TPMList=new List<string>();
        
        for( Schema.PicklistEntry obj : Initiatives__c.Technical_Project_Manager__c.getDescribe().getPicklistValues()) {
            if(obj.getValue() !='None'){
                TPMList.add(obj.getValue());  
            }
        }
        emptyRow=new List<integer>();
        Account_Services__c accSer=[SELECT Account__c,id,Account__r.Name FROM Account_Services__c where id=:accountServiceId limit 1];
        accountName=accSer.Account__r.Name;
        initList = [Select id, name, Status__c, Account_Service__c from Initiatives__c where (Account_Service__c =: accountServiceId) and (Status__c =: 'Initiative Approved' OR Status__c =:'Active Initiative') order by name];        
        date myDate = date.today();
        DateTime dt1 = DateTime.newInstance(myDate.year(), myDate.month(),myDate.day());
        String dayOfWeek = dt1.format('E');
        if(dayOfWeek=='Sun'){
            myDate=myDate.addDays(-1); 
        }
        date weekStart = myDate.toStartofWeek();
        for(integer i=1;i<=7;i++){
            date dToday=weekStart.addDays(i);
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String dateStr = dt.format('dd-MMM');
            weekDateList.add(dateStr);
        }
        //empty row on excel sheet
        for(integer i=0;i<100;i++){
            emptyRow.add(i);
        }
        date dToday1=weekStart.addDays(1);
        DateTime dt = DateTime.newInstance(dToday1.year(), dToday1.month(),dToday1.day());
        String dateStr = dt.format('dd-MMM-YYYY');
        fileName='Timesheet-'+accountName+'-'+dateStr; 
    } 
    
    
    
}