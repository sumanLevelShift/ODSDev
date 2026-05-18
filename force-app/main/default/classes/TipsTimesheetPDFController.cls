public class TipsTimesheetPDFController {
    public string TimesheetAccount {get;set;}
    public string TimesheetAccountService {get;set;}
    public string Comments{get;set;} 
    public string ApproverName {get;set;}
    public string CurrentTimeSheetStatus {get;set;}
    public string FromDate {get;set;}
    public string ToDate {get;set;}
    public string ManagerName {get;set;}
    public string CuDt{get;set;}
    public string TimesheetBuilder {get;set;}
    public list<string> inputString {get;set;}
    public List<TimesheetDetailsWarpper> TimesheetDetailsWarpperList{get;set;}
    public TipsTimesheetPDFController(){
        TimesheetDetailsWarpperList=new list<TimesheetDetailsWarpper>();
        String timesheetFrequency=ApexPages.currentPage().getParameters().get('timesheetFrequency');
        String weeklyTimesheetId=ApexPages.currentPage().getParameters().get('weeklyTimesheetId');
        string monthlyTimesheetId=ApexPages.currentPage().getParameters().get('monthlyTimesheetIdSet');
        string stDate=ApexPages.currentPage().getParameters().get('startDate');
        string enDate=ApexPages.currentPage().getParameters().get('endDate');
        String tipsId=ApexPages.currentPage().getParameters().get('tipsId');
        String initiativeType=ApexPages.currentPage().getParameters().get('initiativeType');
        String isABCCustomer=ApexPages.currentPage().getParameters().get('CustomeType');
        
        date startDate;
        date endDate;
        if(!string.isBlank(stDate)){
            startDate = date.valueOf( stDate );    
        }
        if(!string.isBlank(enDate)){
            endDate = date.valueOf( enDate ); 
        }
        inputString=new list<string>();
        
        
        list<string> monthlyTimesheetIdSet=new list<string>();
        if(!string.isBlank(monthlyTimesheetId)){
            monthlyTimesheetIdSet = monthlyTimesheetId.split(',');
        }
        List<Timesheet__c> timesheetWithTimesheetDetails;
        if(isABCCustomer =='ABC Type'){
            if(timesheetFrequency=='Weekly'){
                timesheetWithTimesheetDetails=[Select Id,Week_Start_Date__c,Week_End_Date__c,Approver_Name__r.Name,Comments__c,ApproverName__c,Approved_Date__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,
                                               (SELECT Initiative_Billing_Type__c,Id,Hours_Worked__c,Row_No_Value__c ,Task_Name__c,Timesheet_Date__c,Timesheet__c From Timesheet_Details__r WHERE Initiative_Billing_Type__c=:initiativeType ORDER BY Row_No_Value__c ASC NULLS FIRST)
                                               From Timesheet__c WHERE ID =:weeklyTimesheetId];
            }else{
                timesheetWithTimesheetDetails=[Select Id,Week_Start_Date__c,Week_End_Date__c,Approver_Name__r.Name,Comments__c,ApproverName__c,Approved_Date__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,
                                               (SELECT Hours_Worked__c,Row_No_Value__c ,Task_Name__c,Timesheet_Date__c,Timesheet__c From Timesheet_Details__r WHERE Initiative_Billing_Type__c=:initiativeType AND Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Row_No_Value__c ASC NULLS FIRST)
                                               From Timesheet__c WHERE ID IN:monthlyTimesheetIdSet AND ((Week_Start_Date__c >= :startDate AND Week_End_Date__c <= :endDate) OR (Week_Start_Date__c < :startDate AND Week_End_Date__c >= :startDate)
        																						OR (Week_Start_Date__c <= :endDate AND Week_End_Date__c > :endDate) OR (Week_Start_Date__c = :startDate))];
            }
        }else{
            if(timesheetFrequency=='Weekly'){
                timesheetWithTimesheetDetails=[Select Id,Week_Start_Date__c,Week_End_Date__c,Approver_Name__r.Name,Comments__c,ApproverName__c,Approved_Date__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,
                                               (SELECT id,Hours_Worked__c,Row_No_Value__c ,Task_Name__c,Timesheet_Date__c,Timesheet__c From Timesheet_Details__r ORDER BY Row_No_Value__c ASC NULLS FIRST)
                                               From Timesheet__c WHERE ID =:weeklyTimesheetId];
            }else{
                timesheetWithTimesheetDetails=[Select Id,Week_Start_Date__c,Week_End_Date__c,Approver_Name__r.Name,Comments__c,ApproverName__c,Approved_Date__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,
                                               (SELECT Hours_Worked__c,Row_No_Value__c ,Task_Name__c,Timesheet_Date__c,Timesheet__c From Timesheet_Details__r WHERE Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Row_No_Value__c ASC NULLS FIRST)
                                               From Timesheet__c WHERE ID IN:monthlyTimesheetIdSet AND ((Week_Start_Date__c >= :startDate AND Week_End_Date__c <= :endDate) OR (Week_Start_Date__c < :startDate AND Week_End_Date__c >= :startDate)
        																						OR (Week_Start_Date__c <= :endDate AND Week_End_Date__c > :endDate) OR (Week_Start_Date__c = :startDate))]; 
            }  
        }
        
        for(Timesheet__c t:timesheetWithTimesheetDetails){
            decimal TotalHours=0;
            decimal MonTotalHours=0;
            decimal TueTotalHours=0;
            decimal WedTotalHours=0;
            decimal ThuTotalHours=0;
            decimal FriTotalHours=0;
            decimal SatTotalHours=0;
            decimal SunTotalHours=0;
            date weekStartDate=t.Week_Start_Date__c;
            date weekEndDate=t.Week_End_Date__c;
            Set<Date> timesheetDates = new Set<Date>();
            for (Date currentDate = weekStartDate; currentDate <= weekEndDate; currentDate = currentDate.addDays(1)) {
                timesheetDates.add(currentDate);
                weekStartDate.addDays(1);
            }
            TimesheetBuilder='';
            TimesheetBuilder = '<table border=\'1 px solid #d7d7d7\'   id=\'Tbltimesheet\' cellpadding=\'0\' cellspacing=\'0\' width=\'100%\'>';  
            TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;  padding:5px; text-align: center;" ><strong>INITIATIVE NAME</strong>';
            TimesheetBuilder +='</th>';
            TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;"><strong>USER STORIES/TASK NAME</strong>';
            TimesheetBuilder +='</th>';
            for(date d:timesheetDates){
                DateTime tDate = Datetime.NewInstance(d.year(), d.Month(), d.day());
                TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  color: #fff; font-size: 14px;   padding:5px; text-align: center;   text-transform: uppercase;"><strong>'+tDate.format('MMM')+' '+ tDate.format('dd')+'<br/>'+tDate.format('EEE')+'</strong>';
                TimesheetBuilder +='</th>';
            }
            TimesheetBuilder +='<th style="background: #3399cc; border: 1px solid #d7d7d7;  border-bottom: none;  color: #fff; font-size: 14px;  padding:5px; text-align: center;"><strong>Total</strong>';
            TimesheetBuilder +='</th> ';
            TimesheetBuilder +='</tr>';
            system.debug('t.Timesheet_Details__r-'+t.Timesheet_Details__r);
            Map<String,decimal> timesheetMap =new Map<String,decimal>();
            set<string> rowNo=new set<string>();
            for(Time_Sheet_Details__c ts:t.Timesheet_Details__r){
                Datetime TimesheetDate = DateTime.newinstance(ts.Timesheet_Date__c.year(),ts.Timesheet_Date__c.month(),ts.Timesheet_Date__c.day());
                string EachDateString = ts.Row_No_Value__c  + '_'+ TimesheetDate.format('MM/dd/yyyy');
                timesheetMap.put(EachDateString,ts.Hours_Worked__c); 
                rowNo.add(ts.Row_No_Value__c);
            }
            system.debug(t.id+'---timesheetMap'+timesheetMap);
            List<Aggregateresult> objResult;
            if(isABCCustomer =='ABC Type'){
                objResult=[SELECT Row_No_Value__c ,Task_Name__c, Initiative_Name__c FROM Time_Sheet_Details__c WHERE Timesheet__c =: t.id AND Initiative_Billing_Type__c=:initiativeType Group BY Row_No_Value__c,Task_Name__c,Initiative_Name__c ];
            }
            else{
                objResult=[SELECT Row_No_Value__c ,Task_Name__c, Initiative_Name__c FROM Time_Sheet_Details__c WHERE Timesheet__c =: t.id Group BY Row_No_Value__c,Task_Name__c,Initiative_Name__c ];
            }
            for( Aggregateresult  eachrowresult :objResult)
            { 
                string InitiativeName = string.valueof(eachrowresult.get('Initiative_Name__c'));
                string TaskName = string.valueof(eachrowresult.get('Task_Name__c'));
                TimesheetBuilder +='<tr>';
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  ">';
                if(InitiativeName != null){
                    TimesheetBuilder += InitiativeName;
                }
                TimesheetBuilder +='</td>  ';
                
                TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none;  ">';
                TimesheetBuilder += TaskName;
                TimesheetBuilder +='</td>  ';
                decimal sumOfRow=0;
                //rowNo.sort();
                for(string i:rowNo){
                    for(date d:timesheetDates) {
                        Datetime TimesheetDate = DateTime.newinstance(d.year(),d.month(),d.day());
                        string EachDateString = i + '_'+ TimesheetDate.format('MM/dd/yyyy');
                        system.debug(t.id+'----'+EachDateString);
                        decimal HoursWorked =0;
                        if ((TimesheetMap.containsKey(EachDateString))) {
                            HoursWorked=TimesheetMap.get(EachDateString);
                            sumOfRow +=HoursWorked;
                            //TotalHours +=sumOfRow;
                            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                            TimesheetBuilder += HoursWorked ;
                            TimesheetBuilder +='</td>  ';
                            if(TimesheetDate.format('EEE')=='Mon')
                                MonTotalHours +=HoursWorked;
                            if(TimesheetDate.format('EEE')=='Tue')
                                TueTotalHours +=HoursWorked;
                            if(TimesheetDate.format('EEE')=='Wed')
                                WedTotalHours +=HoursWorked;
                            if(TimesheetDate.format('EEE')=='Thu')
                                ThuTotalHours +=HoursWorked;
                            if(TimesheetDate.format('EEE')=='Fri')
                                FriTotalHours +=HoursWorked;
                            if(TimesheetDate.format('EEE')=='Sat')
                                SunTotalHours +=HoursWorked;
                            if(TimesheetDate.format('EEE')=='Sun')
                                SunTotalHours +=HoursWorked;
                        }else{
                            TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                            TimesheetBuilder += '' ;
                            TimesheetBuilder +='</td>  ';
                        }
                    }
                    TimesheetBuilder +='<td style=" padding:5px; border: 1px solid #d7d7d7; border-right: none; border-bottom: none; text-align: right; ">';
                    TimesheetBuilder += sumOfRow ;
                    TimesheetBuilder +='</td>  ';
                    rowNo.remove(i);
                    break;
                }
                TimesheetBuilder +='</tr>';
                
            }
            TotalHours=MonTotalHours+TueTotalHours+WedTotalHours+ThuTotalHours+FriTotalHours+SatTotalHours+SunTotalHours;
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
            TimesheetBuilder +='</table>';
            TimesheetAccount = t.Account_Services__r.Account__r.Name;
            TimesheetAccountService = t.Account_Services__r.ODS_Service_Name__c;
            CurrentTimeSheetStatus  = t.Status__c;
            FromDate = DateTime.newInstance(weekStartDate.year(),weekStartDate.month(),weekStartDate.day()).format('MM/dd/yyyy');       
            ToDate= DateTime.newInstance(weekEndDate.year(),weekEndDate.month(),weekEndDate.day()).format('MM/dd/yyyy');
            ManagerName = t.Approver_Name__r.Name;
            Comments = t.Comments__c;
            ApproverName = t.ApproverName__c;
            if(t.Approved_Date__c != null){
                CuDt = DateTime.newInstance(t.Approved_Date__c.year(),t.Approved_Date__c.month(),t.Approved_Date__c.day()).format('MM/dd/yyyy');
            }
            TimesheetDetailsWarpperList.add(new TimesheetDetailsWarpper(TimesheetAccount,TimesheetAccountService,CurrentTimeSheetStatus,
                                                                        FromDate,ToDate,TimesheetBuilder,
                                                                        ManagerName,Comments,ApproverName,CuDt));
            inputString.add(TimesheetBuilder);
        }
        
        
    }
    public static void uploadTimesheetToTips(string body){
        try {
            TipsAPIHelperClass apiHelper=new TipsAPIHelperClass();
            system.debug('body--'+body);
            Http http = new Http();
            string responseJson = '';
            string accessToken = GenerateAuthorizationToken();
            //api request 
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint(System.Label.TIPS_Timesheet_PDF_API_Endpoint);
            request.setTimeout(120000);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            
            request.setBody(body);
            
            HTTPResponse response = http.send(request);
            responseJson = response.getBody(); 
            system.debug('PDF responseJson-'+responseJson);
            
        }  catch (Exception e) {
            ODS_ExceptionUtility.logTipsIntegrationFailure('', body, e.getMessage(), 'Timesheet PDF Upload');
        }
    }
    public static string GenerateAuthorizationToken() {
        try {
            JWT jwt = new JWT('HS256');
            jwt.privateKey = System.Label.JWT_Private_Key;
            jwt.iss = System.Label.JWT_Issuer;
            jwt.aud = System.Label.JWT_Aud;
            jwt.subject = System.Label.JWT_Subject;
            jwt.audience = System.Label.JWT_Audience;
            string token = jwt.GetToken();
            return token;
        } catch (Exception e) {
            system.debug('Error --> ' + e.getLineNumber() + ':' + e.getMessage());
            return '';
        }
    }
    public class TimesheetDetailsWarpper{
        Public string TimesheetAccount {get;set;}
        Public string TimesheetAccountService {get;set;}
        Public string CurrentTimesheetStatus {get;set;}
        Public string FromDate {get;set;}
        Public string ToDate {get;set;}
        Public string inputString {get;set;}
        Public string ManagerName {get;set;}
        Public string Comments {get;set;}
        Public string ApproverName {get;set;}
        Public string CuDt {get;set;}
        public TimesheetDetailsWarpper(String TimesheetAccount,String TimesheetAccountService,string CurrentTimesheetStatus,
                                       String FromDate,String ToDate,string inputString,
                                       String ManagerName,String Comments,string ApproverName,string CuDt){
                                           this.TimesheetAccount=TimesheetAccount;
                                           this.TimesheetAccountService=TimesheetAccountService;
                                           this.CurrentTimesheetStatus=CurrentTimesheetStatus;
                                           this.FromDate=FromDate;
                                           this.ToDate=ToDate;
                                           this.inputString=inputString;
                                           this.ManagerName=ManagerName;
                                           this.Comments=Comments;
                                           this.ApproverName=ApproverName;
                                           this.CuDt=CuDt;
                                       }
    }
}