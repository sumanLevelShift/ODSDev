/*
*Author.............: Mani & Team
*Date...............: 17/May/2018
*Purpose............: 
*TestClass..........: ODS_Invoice_MnthExportTimshetEC_Test
*/
Public class ODS_Invoice_MnthExportTimshetEC
{
    //Globals
    public string accServId {get;set;} 
    public string TimesheetAccount {get;set;}
    public string TimesheetAccountService {get;set;}
    public string FromDate {get;set;}
    public string ToDate {get;set;}
    public string timeSheetIds {get;set;}
    public string TimesheetEntries {get;set;} 
    
    List<Time_Sheet_Details__c> lTimShetEntry;
    Map<Id,List<Time_Sheet_Details__c>> mTimShetMapping;
    
    //Empty constructor 
    Public ODS_Invoice_MnthExportTimshetEC()
    {              
    }
    //Visualforce page onload action
    public void GetMonthlyTimesheet()
    {  
        accServId = Apexpages.currentpage().getparameters().get('accServ');
        TimesheetAccount = Apexpages.currentpage().getparameters().get('accName');
        TimesheetAccountService = Apexpages.currentpage().getparameters().get('odsServName');
        FromDate = Apexpages.currentpage().getparameters().get('startDate');
        ToDate = Apexpages.currentpage().getparameters().get('endDate');
        timeSheetIds = Apexpages.currentpage().getparameters().get('timeSheets');
        
        Date sDate = Date.valueOf(FromDate);
        Date eDate = Date.valueOf(ToDate);
        
        Set<Id> sTimeSheets = new Set<Id>();
        List<Timesheet__c> lTimeSheet = new List<Timesheet__c>();
        if(String.isNotBlank(timeSheetIds)) {
            for(String s:timeSheetIds.split('-')) {
                sTimeSheets.add(Id.valueOf(s));
            }
        }
        System.debug('@@incoming timesheet ids: '+sTimeSheets);
        List<TimeSheet__c> lTimeSheets = new List<TimeSheet__c>([SELECT Id,Status__c,Week_Start_Date__c
                 FROM TimeSheet__c WHERE Id IN:sTimeSheets ORDER BY Week_Start_Date__c ASC]);
        List<Time_Sheet_Details__c> lTimeShtDetail = new List<Time_Sheet_Details__c>([SELECT Id,
                    Row_No__c,Hours_Worked__c,Resource_Id__c,Resource__c,Task_Name__c,
                    Timesheet__c,Timesheet__r.Status__c,Timesheet_Date__c,Intiative__c,
                    Intiative__r.Remaining_Hours__c,Initiative_Name__c
                FROM Time_Sheet_Details__c
                WHERE Timesheet__c IN:sTimeSheets AND (Timesheet__r.Status__c = 'Submitted'
                    OR Timesheet__r.Status__c = 'Approved') AND Timesheet_Date__c >=:sDate AND Timesheet_Date__c <=:eDate 
                ORDER BY Timesheet_Date__c ASC]);
        System.debug('@@timesheet detail recs: '+lTimeShtDetail.size());
        lTimShetEntry = new List<Time_Sheet_Details__c>();
        
        if(!lTimeSheets.isEmpty() && !lTimeShtDetail.isEmpty()) {
            for(TimeSheet__c ts:lTimeSheets) {                
                for(Time_Sheet_Details__c tsd:lTimeShtDetail) {
                    if(tsd.Timesheet__c == ts.Id) {                        
                        lTimShetEntry.add(tsd);
                    }                    
                }
                
                TimesheetEntries += BuildTimesheetHtml(lTimShetEntry,ts.Id,ts.Week_Start_Date__c);
                System.debug('@@PDF Json length: '+TimesheetEntries.length());
            }                   
        }               
    }
    
    public string BuildTimesheetHtml(List<Time_Sheet_Details__c> timeShtDetailList,string TimesheetId, Date WeekStartDate)
    {
        System.debug('@@incoming timesheetdetails: '+timeShtDetailList);
        System.debug('@@incoming timesheetId: '+TimesheetId);
        System.debug('@@incoming weekstartDate: '+WeekStartDate);
        decimal MonTotalHours=0;
        decimal TueTotalHours=0;
        decimal WedTotalHours=0;
        decimal ThuTotalHours=0;
        decimal FriTotalHours=0;
        decimal SatTotalHours=0;
        decimal SunTotalHours=0;
        DateTime weekStartDateTime = Datetime.NewInstance(WeekStartDate.year(), WeekStartDate.Month(), WeekStartDate.day());
        
        DateTime Mondaydate = weekStartDateTime;
        DateTime Tuedate = weekStartDateTime.addDays(1);
        DateTime Weddate = weekStartDateTime.addDays(2);
        DateTime Thudate = weekStartDateTime.addDays(3);
        DateTime Fridate = weekStartDateTime.addDays(4);
        DateTime Satdate = weekStartDateTime.addDays(5);
        DateTime Sundate = weekStartDateTime.addDays(6);
          
        string  TimesheetBuilder = '<table border=\'1 px solid #d7d7d7\'   id=\'Tbltimesheet\' cellpadding=\'0\' cellspacing=\'0\' width=\'100%\'>';  
        //Header Row
        //TimesheetBuilder +='<tr >';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;  padding:5px; text-align: center;" ><strong>INITIATIVE NAME</strong>';
        TimesheetBuilder +='</th>';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>USER STORIES/TASK NAME</strong>';
        TimesheetBuilder +='</th>';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>'+Mondaydate.format('MMM')+' '+ Mondaydate.format('dd')+'<br />MON </strong>';
        TimesheetBuilder +='</th>';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>'+Tuedate.format('MMM')+' '+ TueDate.format('dd')+'<br />TUE </strong>';
        TimesheetBuilder +='</th>';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>'+Weddate.format('MMM')+' '+ Weddate.format('dd')+'<br />WED </strong>';
        TimesheetBuilder +='</th>';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>'+Thudate.format('MMM')+' '+ Thudate.format('dd')+'<br />THU </strong>';
        TimesheetBuilder +='</th>';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>'+Fridate.format('MMM')+' '+ Fridate.format('dd')+'<br />FRI </strong>';
        TimesheetBuilder +='</th>';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>'+Satdate.format('MMM')+' '+ Satdate.format('dd')+'<br />SAT </strong>';
        TimesheetBuilder +='</th>';
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>'+Sundate.format('MMM')+' '+ Sundate.format('dd')+'<br />SUN </strong>';
        TimesheetBuilder +='</th>';
        
        TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7;  border-bottom: none;  color: #fff; font-size: 14px;  padding:5px; text-align: center;"><strong>Total</strong>';
        TimesheetBuilder +='</th> ';
        TimesheetBuilder +='</tr>';
        Map<String,Decimal> TimesheetMap =new Map<String,Decimal>();
        //For loop 
        for(Time_Sheet_Details__c eachRow: timeShtDetailList){
            Datetime TimesheetDate = DateTime.newinstance(eachRow.Timesheet_Date__c.year(),eachRow.Timesheet_Date__c.month(),eachRow.Timesheet_Date__c.day());
            string EachDateString = eachRow.Row_No__c + '_'+ TimesheetDate.format('MM/dd/yyyy');
            TimesheetMap.put(EachDateString,eachRow.Hours_Worked__c );        
        }
        system.debug('##TimesheetMap'+TimesheetMap);
        List<Aggregateresult> objResult = ODS_Data_Utility.GetAggregateTimesheetDetails(TimesheetId,accServId);
        decimal TotalHours = 0;
        for(Aggregateresult  eachrowresult :objResult)
        {
        
            TimesheetBuilder +='<tr>';
            string InitiativeName = string.valueof(eachrowresult.get('Initiative_Name__c'));
            string TaskName = string.valueof(eachrowresult.get('Task_Name__c'));
            string ResourceName =  string.valueof(eachrowresult.get('Resource__c'));
            string RowNo =  string.valueof(eachrowresult.get('Row_No_Value__c'));
            
            string strMondate = RowNo+'_'+Mondaydate.format('MM/dd/yyyy');
            string strTueDate =  RowNo+'_'+Tuedate.Format('MM/dd/yyyy');
            string strWedDate =  RowNo+'_'+Weddate.format('MM/dd/yyyy');
            string strThuDate =  RowNo+'_'+Thudate.format('MM/dd/yyyy');
            string strFriDate =  RowNo+'_'+Fridate.Format('MM/dd/yyyy');
            string strSatDate =  RowNo+'_'+Satdate.format('MM/dd/yyyy');
            string strSunDate =  RowNo+'_'+Sundate.format('MM/dd/yyyy');
            decimal HoursWorked =0;
            decimal EachRowTotalHours=0;
            
             TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  ">';
             if(InitiativeName != null){
                 TimesheetBuilder += InitiativeName;
             }
             TimesheetBuilder +='</td>  ';
             
             TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  ">';
             TimesheetBuilder += TaskName;
             TimesheetBuilder +='</td>  ';

            if ((TimesheetMap.containsKey(strMondate))) {
                    HoursWorked =  TimesheetMap.get(strMondate);
                    EachRowTotalHours+=HoursWorked;
                    MonTotalHours +=HoursWorked;
                    TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                    TimesheetBuilder += HoursWorked ;
                    TimesheetBuilder +='</td>  ';
         
            }else{
            
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                TimesheetBuilder += '';
                TimesheetBuilder +='</td>  ';
            } 
            
             if ((TimesheetMap.containsKey(strTueDate))) {
            
                    HoursWorked =  TimesheetMap.get(strTueDate);
                    EachRowTotalHours+=HoursWorked;
                    TueTotalHours +=HoursWorked;
                    TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                    TimesheetBuilder += HoursWorked ;
                    TimesheetBuilder +='</td>  ';
         
            }else{
            
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                TimesheetBuilder += '';
                TimesheetBuilder +='</td>  ';
            } 
            
             if ((TimesheetMap.containsKey(strWedDate))) {
             
                    HoursWorked =  TimesheetMap.get(strWedDate );
                    EachRowTotalHours+=HoursWorked;
                    WedTotalHours +=HoursWorked;
                    TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                    TimesheetBuilder += HoursWorked ;
                    TimesheetBuilder +='</td>  ';
         
            }else{
            
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                TimesheetBuilder += '';
                TimesheetBuilder +='</td>  ';
            } 
             if ((TimesheetMap.containsKey(strThudate))) {
             
                    HoursWorked =  TimesheetMap.get(strThudate);
                    EachRowTotalHours+=HoursWorked;
                    ThuTotalHours +=HoursWorked;
                    TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                    TimesheetBuilder += HoursWorked ;
                    TimesheetBuilder +='</td>  ';
         
            }else{
            
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                TimesheetBuilder += '';
                TimesheetBuilder +='</td>  ';
            } 
             if ((TimesheetMap.containsKey(strFridate))) {
            
                    HoursWorked =  TimesheetMap.get(strFridate);
                    EachRowTotalHours+=HoursWorked;
                    FriTotalHours +=HoursWorked;
                    TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                    TimesheetBuilder += HoursWorked ;
                    TimesheetBuilder +='</td>  ';
         
            }else{
            
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                TimesheetBuilder += '';
                TimesheetBuilder +='</td>  ';
            } 
             if ((TimesheetMap.containsKey(strSatdate))) {
                    HoursWorked =  TimesheetMap.get(strSatdate);
                    EachRowTotalHours+=HoursWorked; 
                    SatTotalHours +=HoursWorked;
                    TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                    TimesheetBuilder += HoursWorked ;
                    TimesheetBuilder +='</td>  ';
            }else{
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                TimesheetBuilder += '';
                TimesheetBuilder +='</td>  ';
            } 
            if ((TimesheetMap.containsKey(strSundate))) {
                    HoursWorked =  TimesheetMap.get(strSundate);
                    EachRowTotalHours+=HoursWorked;
                    SunTotalHours +=HoursWorked;
                    TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                    TimesheetBuilder += HoursWorked ;
                    TimesheetBuilder +='</td>  ';
            }else{
            
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                TimesheetBuilder += '';
                TimesheetBuilder +='</td>  ';
            } 
             
            TimesheetBuilder +='<td  style=" padding:5px; border: 1px solid #d7d7d7; border-bottom: none;  text-align: right;">';
            TimesheetBuilder += EachRowTotalHours;
            TimesheetBuilder +='</td>  ';

            TimesheetBuilder +='</tr>';
            TotalHours +=EachRowTotalHours;
        }
            TimesheetBuilder +='<tr>';
            TimesheetBuilder +='<td  colspan=\'2\'  style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; text-align: Left; ">';
            TimesheetBuilder += 'Total';
            TimesheetBuilder +='</td>  ';
            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7;  text-align: right; ">'+MonTotalHours +'</td> ';
            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7;  text-align: right; ">'+TueTotalHours +'</td> ';
            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7;  text-align: right; ">'+WedTotalHours +'</td> ';
            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7;  text-align: right; ">'+ThuTotalHours +'</td> ';
            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7;  text-align: right; ">'+FriTotalHours +'</td> ';
            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7;  text-align: right; ">'+SatTotalHours +'</td> ';
            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7;  text-align: right; ">'+SunTotalHours +'</td> ';
            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7;  text-align: right; ">';
            TimesheetBuilder += TotalHours  ;
            TimesheetBuilder +='</td>  ';
            TimesheetBuilder +='</tr>';
            TimesheetBuilder +='<br></br><br></br>';
          return TimesheetBuilder ;
    }
}