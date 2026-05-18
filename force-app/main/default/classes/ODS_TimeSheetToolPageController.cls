public class ODS_TimeSheetToolPageController {
    
    @TestVisible 
    public static Map<map<string,string>, Initiatives__c> initiativesList { 
        get {
            if ( null == initiativesList || initiativesList.isEmpty() ){
                initiativesList = new Map<map<string,string>, Initiatives__c>();
                List<Initiatives__c> initList=new List <Initiatives__c>();                
                ODS_Common_Utility obj = new ODS_Common_Utility();
                String[] AccounIDs = obj.getAllAccountIDByLoggedInUser();
                initList = [Select id, name, Status__c,Account_Service__c,Account_Name__c,Account_Service__r.Account__r.Name from Initiatives__c where (Account_Service__r.Account__c IN: AccounIDs) and (Status__c ='Initiative Approved' OR Status__c ='Active Initiative') order by Account_Service__r.Account__r.Name,name];   
                map<string,string> iniAndAcc=new map<string,string>();
                for(Initiatives__c i:initList)   {
                    iniAndAcc=new map<string,string>();
                    iniAndAcc.put(i.Name,i.Account_Service__r.Account__r.Name);
                    initiativesList.put(iniAndAcc,i); 
                } 
                return initiativesList;     
            }
            return initiativesList;
        } set; 
    }
    public string PassedWeekFromDate{get;set;}
    public string PassedWeekToDate{get;set;}
    public Boolean validateCurrentWeekDate {get; set;}
    public Boolean timesheetStatus {get; set;}
    public string initiativeNameList {get; set;}
    public string startWeekDateOnUI {get; set;}
    List<TimesheetTable> timesheetTableList=new List<TimesheetTable>();
    public String CurrentDate {get; set;}
    public date WeekStartDate {get; set;}
    public date WeekEndDate {get; set;}
    public Timesheet__c timeSheet {get; set;}
    public List<Time_Sheet_Details__c> TimesheetDetailList {get; set;}
    public map<string,list<string>> invalidInitiatives {get; set;}
    public static map<string,List<TimesheetTable>> tpmNotAvailable{get; set;}
    
    public boolean ifTimeSheetCreated {get; set;}
    public set<string> notFutureWeekAccount {get; set;}
    public ODS_TimeSheetToolPageController(){
        Datetime currentDateTime = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        CurrentDate  = currentDateTime.format('MM/dd/yyyy'); // formats the date   
    }
    public Time_Sheet_Cost__c SaveTimesheetCost(Date WeekStartDate, Date WeekEndDate, string CurrentAccServiceId, Decimal HourlyRate ){
        
        boolean Result = false;
        Integer startWeekmonth =WeekStartDate.month();
        Integer EndWeekmonth = WeekEndDate.month();
        
        Integer YearOfWeekstartDate = WeekStartDate.year();
        Integer YearOfWeekEndDate = WeekEndDate.year();
        system.debug('#startWeekmonth'+startWeekmonth);
        system.debug('#EndWeekmonth'+EndWeekmonth );
        Time_Sheet_Cost__c objTimesheetCost = new Time_Sheet_Cost__c();
        
        
        objTimesheetCost = ODS_TimeSheetCostController.CheckIfMonthExistInCostTable(startWeekmonth,YearOfWeekstartDate,CurrentAccServiceId,HourlyRate ,WeekStartDate);
        return objTimesheetCost;
    }
    
    Public pagereference exportAsExcel()
    {
        try{
            
            PageReference excel = Page.ODS_DownloadTimeSheetAsExcelForToolPage;
            excel.getParameters().put('startDate', startWeekDateOnUI);
            excel.setRedirect(true);
            return excel;
        }
        catch(exception e)
        {
            system.debug('The attachment is not deleted '+ e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.'));
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }
    public void loadInvalidInitiatives(string accName,string initiatives){
        list<string> iniList=new list<string>();
        if(invalidInitiatives.containsKey(accName)){
            iniList.addAll(invalidInitiatives.get(accName));
            iniList.add(initiatives);
            invalidInitiatives.put(accName,iniList);   
        }
        else{
            iniList.add(initiatives);
            invalidInitiatives.put(accName,iniList); 
        } 
    }
    public void getInitList()
    {
        ifTimeSheetCreated=true;
        Map<string,List<TimesheetTable>> timesheetTableMap=new Map<string,List<TimesheetTable>>();
        tpmNotAvailable=new map<string,List<TimesheetTable>>();
        
        try{
            invalidInitiatives=new map<string,list<string>>();
            notFutureWeekAccount=new set<string>();
            system.debug('initiativesList--'+initiativesList);
            list<ExcelRow> ls = ( List<ExcelRow> )JSON.deserialize(this.initiativeNameList, List<ExcelRow>.class ) ; 
            integer i=0;
            validateCurrentWeekDate=false;
            list<Account_Services__c> accSer=new list<Account_Services__c>();
            string accName=null;
            boolean futureWeek=false;
            for(ExcelRow s:ls){
                if(i==0){
                    system.debug('WeekStartDate---'+WeekStartDate);
                    WeekStartDate=date.parse(string.valueOf(s.StartWeekDate)); 
                    WeekEndDate=date.parse(string.valueOf(s.EndWeekDate)); 
                    i++; 
                    date currentWeekDate = system.today();
                    DateTime dt1 = DateTime.newInstance(currentWeekDate.year(), currentWeekDate.month(),currentWeekDate.day());
                    String dayOfWeek = dt1.format('E');
                    if(dayOfWeek=='Sun'){
                        currentWeekDate=currentWeekDate.addDays(-1); 
                    }
                    
                    date weekStart = currentWeekDate.toStartofWeek();
                    date endWeekdate=weekStart.addDays(7);
                    if(WeekEndDate>endWeekdate){
                        system.debug('true@@@@@@@@@');
                        futureWeek=true;
                    }
                }
                string iniName=s.Initiative;
                List<Initiatives__c> initiativesRec=new list<Initiatives__c>();
                List<TimesheetTable> timeList=new List<TimesheetTable>();
                if(accName==null || accName !=s.AccountName)
                {
                    accName=s.AccountName;
                    accSer=[SELECT id,Account__c,Allow_Future_Timesheets__c,ODS_Service_Name__c FROM Account_Services__c where Account__r.Name=:s.AccountName AND ODS_Service_Name__c='Salesforce' limit 1];
                }
                if(!accSer.isEmpty())
                {
                    if((futureWeek && accSer[0].Allow_Future_Timesheets__c==true) || !futureWeek){
                        if(s.Initiative !=null && iniName.length()!=0 )
                        {
                            map<string,string> iniAndAcc=new map<string,string>();
                            iniAndAcc.put(s.Initiative,s.AccountName);
                            system.debug('initiativesList--'+initiativesList.containsKey(iniAndAcc));
                            initiativesRec=new list<Initiatives__c>();
                            initiativesRec.add(initiativesList.get(iniAndAcc));
                            if(initiativesRec[0] !=null){
                                if(timesheetTableMap.containsKey(initiativesRec[0].id)){
                                    timeList.addAll(timesheetTableMap.get(initiativesRec[0].id));
                                    timeList.add(new TimesheetTable(initiativesRec[0].id,initiativesRec[0].Name,s.Description,s.TPM,s.Mon,s.Tue,s.Wed,s.Thu,s.Fri,s.Sat,s.Sun,initiativesRec[0].Account_Service__c,initiativesRec[0].Account_Service__r.Account__c));
                                    timesheetTableMap.put(initiativesRec[0].id,timeList);
                                }
                                else{
                                    timeList.add(new TimesheetTable(initiativesRec[0].id,initiativesRec[0].Name,s.Description,s.TPM,s.Mon,s.Tue,s.Wed,s.Thu,s.Fri,s.Sat,s.Sun,initiativesRec[0].Account_Service__c,initiativesRec[0].Account_Service__r.Account__c));
                                    timesheetTableMap.put(initiativesRec[0].id,timeList);   
                                }
                            }
                            else{
                                loadInvalidInitiatives(s.AccountName,s.Initiative);
                            }
                        }else{
                            if(timesheetTableMap.containsKey('No Initiative')){
                                timeList.addAll(timesheetTableMap.get('No Initiative'));
                                timeList.add(new TimesheetTable('No Initiative',null,s.Description,s.TPM,s.Mon,s.Tue,s.Wed,s.Thu,s.Fri,s.Sat,s.Sun,accSer[0].id,accSer[0].Account__c));
                                timesheetTableMap.put('No Initiative',timeList);
                            }else{
                                timeList.add(new TimesheetTable('No Initiative',null,s.Description,s.TPM,s.Mon,s.Tue,s.Wed,s.Thu,s.Fri,s.Sat,s.Sun,accSer[0].id,accSer[0].Account__c));
                                timesheetTableMap.put('No Initiative',timeList); 
                            }
                        }
                    }else{
                        system.debug('@@@accName---'+accName);
                        notFutureWeekAccount.add(accName);
                    }
                }
            }
            system.debug('timesheetTableMap---'+timesheetTableMap.size());
            calculateSameInitiativesHours(timesheetTableMap);
        }catch(Exception e){
            ifTimeSheetCreated=false;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName()); 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.')); 
            system.debug('Exception--'+e.getMessage()+'-line no=='+e.getLineNumber());
            sendMailForException(e);
        }
    }
    public void calculateSameInitiativesHours(Map<string,List<TimesheetTable>> timesheetTableMap){
        timesheetTableList=new List<TimesheetTable>();
        Map<Map<string,string>,List<TimesheetTable>> timesheetMap=new Map<Map<string,string>,List<TimesheetTable>>();
        
        for(string i:timesheetTableMap.keySet()){
            if(i!='No Initiative'){
                for(TimesheetTable t:timesheetTableMap.get(i)){
                    List<TimesheetTable> timeList=new List<TimesheetTable>();
                    map<string,string> mapInsert=new map<string,string>();
                    mapInsert.put(t.Description, t.InitiativeId);
                    timeList.add(new TimesheetTable(t.InitiativeId,t.InitiativeName,t.Description,t.TPM,t.Mon,t.Tue,t.Wed,t.Thu,t.Fri,t.Sat,t.Sun,t.AccSerId,t.AccId));
                    if(timesheetMap.containsKey(mapInsert)){
                        timeList.addAll(timesheetMap.get(mapInsert));
                        timesheetMap.put(mapInsert,timeList);  
                    }else{
                        timesheetMap.put(mapInsert,timeList);    
                    }
                    
                }
            }else{
                for(TimesheetTable s:timesheetTableMap.get(i)){
                    decimal mon=0;
                    decimal tue=0;
                    decimal wed=0;
                    decimal thu=0;
                    decimal fri=0;
                    decimal sat=0;
                    decimal sun=0;
                    if(!String.isBlank(s.Mon)){
                        mon +=decimal.valueOf(s.Mon); 
                    }
                    if(!String.isBlank(s.Tue)){
                        tue +=decimal.valueOf(s.Tue);
                    }
                    if(!String.isBlank(s.Wed)){
                        wed +=decimal.valueOf(s.Wed);
                    }
                    if(!String.isBlank(s.Thu)){
                        thu +=decimal.valueOf(s.Thu);
                    }
                    if(!String.isBlank(s.Fri)){
                        fri +=decimal.valueOf(s.Fri);
                    }
                    if(!String.isBlank(s.Sat)){
                        sat +=decimal.valueOf(s.Sat);
                    }
                    if(!String.isBlank(s.Sun)){
                        sun +=decimal.valueOf(s.Sun);
                    }
                    timesheetTableList.add(new TimesheetTable('No Initiative',null,s.Description,s.TPM,string.valueOf(mon),string.valueOf(tue),string.valueOf(wed),string.valueOf(thu),string.valueOf(fri),string.valueOf(sat),string.valueOf(sun),s.AccSerId,s.AccId));
                }
            }         
        }
        calculateSameHoursBasedDes(timesheetMap);        
    }
    public void calculateSameHoursBasedDes(Map<Map<string,string>,List<TimesheetTable>> timesheetTableMap){
        for(Map<String,String> sMap:timesheetTableMap.keySet()){
            string inId;
            string inName;
            string des;
            string tpm;
            string asrId;
            string accId;
            decimal mon=0;
            decimal tue=0;
            decimal wed=0;
            decimal thu=0;
            decimal fri=0;
            decimal sat=0;
            decimal sun=0;
            for(TimesheetTable t:timesheetTableMap.get(sMap)){
                inId=t.InitiativeId;
                inName=t.InitiativeName;
                des=t.Description;
                tpm=t.TPM;
                asrId=t.AccSerId;
                accId=t.AccId;
                if(!String.isBlank(t.Mon)){
                    mon +=decimal.valueOf(t.Mon); 
                }
                if(!String.isBlank(t.Tue)){
                    tue +=decimal.valueOf(t.Tue);
                }
                if(!String.isBlank(t.Wed)){
                    wed +=decimal.valueOf(t.Wed);
                }
                if(!String.isBlank(t.Thu)){
                    thu +=decimal.valueOf(t.Thu);
                }
                if(!String.isBlank(t.Fri)){
                    fri +=decimal.valueOf(t.Fri);
                }
                if(!String.isBlank(t.Sat)){
                    sat +=decimal.valueOf(t.Sat);
                }
                if(!String.isBlank(t.Sun)){
                    sun +=decimal.valueOf(t.Sun);
                }
            }
            timesheetTableList.add(new TimesheetTable(inId,inName,des,tpm,string.valueOf(mon),string.valueOf(tue),string.valueOf(wed),string.valueOf(thu),string.valueOf(fri),string.valueOf(sat),string.valueOf(sun),asrId,accId));
        }
        system.debug('timesheetTableList-'+timesheetTableList);
        map<string,List<TimesheetTable>> timeSheetDetailsList=new map<string,List<TimesheetTable>>();
        for(TimesheetTable t:timesheetTableList){
            List<TimesheetTable> timeList=new List<TimesheetTable>();
            timeList.add(t);
            if(timeSheetDetailsList.containsKey(t.AccSerId)){
                timeList.addAll(timeSheetDetailsList.get(t.AccSerId));
                timeSheetDetailsList.put(t.AccSerId,timeList);  
            }else{
                timeSheetDetailsList.put(t.AccSerId,timeList);    
            }
        }
        try{
            system.debug('timeSheetDetailsList---'+timeSheetDetailsList);
            //if(!timeSheetDetailsList.isEmpty()){
            system.debug('invalidInitiatives--'+invalidInitiatives);
            system.debug('invalidInitiatives--'+invalidInitiatives.size());
            map<string,List<TimesheetTable>> timeSheetDetailsListToInsert=new map<string,List<TimesheetTable>>();
            Set<string> accountNameList=New Set<string>();
            for(string aSId:timeSheetDetailsList.keySet()){
                for(TimesheetTable t:timeSheetDetailsList.get(aSId)){
                    if(!checkTPMAvailability(t)){
                        List<TimesheetTable> timeList=new List<TimesheetTable>();
                        timeList.add(t);
                        if(timeSheetDetailsListToInsert.containsKey(aSId)){
                            timeList.addAll(timeSheetDetailsListToInsert.get(aSId));
                            timeSheetDetailsListToInsert.put(aSId,timeList);  
                        }else{
                            timeSheetDetailsListToInsert.put(aSId,timeList);    
                        }
                    }
                }
            }
            List<Account_Services__c> accountSerList=[SELECT Account__r.Name,Id FROM Account_Services__c Where Id=:timeSheetDetailsListToInsert.keySet()];
            for(Account_Services__c a:accountSerList){
              accountNameList.add(a.Account__r.Name);  
            }
            accountNameList.addAll(tpmNotAvailable.keySet());
            system.debug('accountNameList---'+accountNameList);
            UploadBulkTimeSheetBatch obj=new UploadBulkTimeSheetBatch(timeSheetDetailsListToInsert,WeekStartDate,WeekEndDate,invalidInitiatives,tpmNotAvailable,accountNameList);
            Database.executeBatch(obj);
            //}
            if(!notFutureWeekAccount.isEmpty()){
                system.debug('notFutureWeekAccount--'+notFutureWeekAccount);
                sendMailForNotFutureWeek(notFutureWeekAccount);
            }
        }catch(Exception e){
            ifTimeSheetCreated=false;
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName()); 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Data. Unable to complete your request due to '+ e.getMessage()+'.')); 
            sendMailForException(e);
        }
    }
    public void sendMailForException(Exception e){
        User currentUser=[Select Id,Email,Name From User where Id=:UserInfo.getUserId() limit 1];
        list<string> toEmailList=new list<string>();
        toEmailList.add(currentUser.Email);
        
        String body='Hi <b>'+currentUser.Name+'</b>,<br/><br/>';
        body +='While uploading the timesheets, we got the below-mentioned error.<br/>';
        body +='<br/>Error Message : '+e.getMessage()+' At line number '+e.getLineNumber()+'.';
        body +='<br/><br/> The uploaded timesheet data is incorrect, please check and upload the timesheet with correct data.';
        body +='<br/><br/>Thanks,';
        body +='<br/><br/>LevelShift Customer Success Manager';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toEmailList);
        email.setBccAddresses(new String[]{System.Label.ODS_Portal_Support});
        email.setSubject('ODS Timesheet Upload Failed');
        email.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    public void sendMailForNotFutureWeek(set<string> accountName){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        User currentUser=[Select Id,Email,Name From User where Id=:UserInfo.getUserId() limit 1];
        list<string> toEmailList=new list<string>();
        toEmailList.add(currentUser.Email);
        string stDate=DateTime.newInstance(WeekStartDate.year(), WeekStartDate.month(), WeekStartDate.day()).format('dd-MMM-YYYY');
        string eDate=DateTime.newInstance(WeekEndDate.year(), WeekEndDate.month(), WeekEndDate.day()).format('dd-MMM-YYYY');
        for(string aName:accountName){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Bulk Timesheet Future Week Is Not Enabled - '+aName);
            String body='Hi <b>'+currentUser.Name+'</b>,<br/><br/>';
            body +='The future week timesheet is not created for <b>'+aName+'</b> because the future week is not enabled.';
            body +='<br/>Week Date : '+stDate+' to '+eDate;
            body +='<br/><br/>Thanks,';
            body +='<br/><br/>LevelShift Customer Success Manager';
            email.setToAddresses(toEmailList);
            email.setHtmlBody(body);
            mails.add(email);
        }
        Messaging.sendEmail(mails);
    }
    public class ExcelRow {
        public String AccountName;
        public String Initiative;
        public String Description;
        public String TPM;
        public String Mon;
        public String Tue;
        public String Wed;
        public String Thu;
        public String Fri;
        public String Sat;
        public String Sun;   
        public String StartWeekDate; 
        public String EndWeekDate; 
    }
    public static boolean checkTPMAvailability(TimesheetTable t){
        boolean flag=false;
        List<Account> accountList=[Select Id,Name From Account Where Id=:t.AccId limit 1];
        List<TimesheetTable> timeList=new list<TimesheetTable>();
        if(string.isBlank(t.TPM) && t.InitiativeId =='No Initiative'){
            timeList.add(t);
            if(tpmNotAvailable.containsKey(accountList[0].Name)){
                timeList.addAll(tpmNotAvailable.get(accountList[0].Name));
                tpmNotAvailable.put(accountList[0].Name,timeList);
                flag=true;
            }
            else{
                tpmNotAvailable.put(accountList[0].Name,timeList);   
                flag=true;
                
            } 
        }
        system.debug('tpmNotAvailable $$$--'+tpmNotAvailable);
        return flag;
    }
}