public class UploadBulkTimeSheetHelper {
    @TestVisible 
    public static Map<string, User_Account__c> userAccountList { 
        get {
            if ( null == userAccountList || userAccountList.isEmpty() ){  
                userAccountList=new Map<string, User_Account__c>();
                list<User_Account__c> userAcc=new list<User_Account__c>();
                userAcc = [SELECT Account__c, User__c, User__r.Email, Role_in_Account__c FROM User_Account__c WHERE Account__c !=null and Role_in_Account__c = 'Account Manager'];
                for(User_Account__c i:userAcc)   {
                    userAccountList.put(i.Account__c,i); 
                } 
                return userAccountList;     
            }
            return userAccountList;
        } set; 
    }
    public boolean checkTimesheetvalidation(Account_Services__c objAcntSrv,date WeekStartDate,date WeekEndDate){
        boolean flag=false;
        list<Timesheet__c> checkExistingTimesheet=[SELECT Id,Week_End_Date__c,Week_Start_Date__c,Status__c FROM Timesheet__c where Account_Services__c=:objAcntSrv.id and Week_Start_Date__c=:WeekStartDate and Week_End_Date__c=:WeekEndDate limit 1];
        if(!checkExistingTimesheet.isEmpty()){
            if(checkExistingTimesheet[0].Status__c == 'Saved'){
                flag=true;
            }
        }
        else{
            flag=true;
        }
        return flag;
    }
    public Timesheet__c createTimesheet(string accountSerId,Account_Services__c objAcntSrv,date WeekStartDate,date WeekEndDate){
        Timesheet__c timeSheet = new Timesheet__c();
        //timesheetStatus=false;
        list<Timesheet__c> checkExistingTimesheet=[SELECT Id,Week_End_Date__c,Week_Start_Date__c,Status__c FROM Timesheet__c where Account_Services__c=:objAcntSrv.id and Week_Start_Date__c=:WeekStartDate and Week_End_Date__c=:WeekEndDate limit 1];
        if(!checkExistingTimesheet.isEmpty()){
            if(checkExistingTimesheet[0].Status__c == 'Saved'){
                timeSheet=checkExistingTimesheet[0];
                List<Time_Sheet_Details__c> timeSheetDetailsList=[SELECT Id,Timesheet__c FROM Time_Sheet_Details__c where Timesheet__c=:checkExistingTimesheet[0].id];
                if(!timeSheetDetailsList.isEmpty()){
                    
                    delete timeSheetDetailsList;
                }
            }else{
                timeSheet=checkExistingTimesheet[0];   
            }
        }
        else {
            List<Contact_Account_Service__c> ContctAccService  = new List<Contact_Account_Service__c>();
            
            ContctAccService = ODS_Data_Utility.getContactAccountService(objAcntSrv.Account__c, objAcntSrv.Id);
            timeSheet.Account_Services__c=objAcntSrv.id;
            ODS_TimeSheetToolPageController o=new ODS_TimeSheetToolPageController();
            Time_Sheet_Cost__c objTimesheetCost=o.SaveTimesheetCost(WeekStartDate,WeekEndDate,objAcntSrv.id,objAcntSrv.ODS_Hourly_Rate_Amount__c);
            list<User_Account__c> userAcc = new list<User_Account__c> ();
            //userAcc = [SELECT Account__c, User__c, User__r.Email, Role_in_Account__c FROM User_Account__c WHERE Account__c =: objAcntSrv.Account__c AND Role_in_Account__c = 'Account Manager' LIMIT 1];
            if(userAccountList.containsKey(objAcntSrv.Account__c)==true){
                userAcc.add(userAccountList.get(objAcntSrv.Account__c));
            }
            
            timeSheet.Week_Start_Date__c = WeekStartDate;
            timeSheet.Week_End_Date__c = WeekEndDate;
            if(!userAcc.isEmpty() ){
                timeSheet.Account_Manager_Email__c = userAcc[0].User__r.Email;
            }
            timeSheet.Account_Name__c = objAcntSrv.Account__r.Name;
            timeSheet.Time_Sheet_Cost__c = objTimesheetCost.Id;
            timeSheet.Cost_Per_Hour__c = objAcntSrv.ODS_Hourly_Rate_Amount__c ;
            timeSheet.Status__c = 'Saved';
            if(ContctAccService.size() >0){
                user userobj = new user();
                userobj = ODS_Data_Utility.getuser(ContctAccService[0].Contact__c);
                if(userobj != null)
                    timeSheet.Approver_Name__c  =userobj.id;
            } 
            insert timeSheet;
        }
        return timeSheet;
    }
    public Time_Sheet_Details__c createTimesheetDetails(date tDate,string timeSheetId,string intiativeId,integer rowValue,string taskName,string resourceId,decimal hours,string tpm){
        Time_Sheet_Details__c timesheetDetail = new Time_Sheet_Details__c();
        timesheetDetail.Hours_Worked__c = hours;
        timesheetDetail.Row_No__c = rowValue;                    
        timesheetDetail.Task_Name__c = taskName;
        timesheetDetail.Resource_Id__c = resourceId;
        if(intiativeId =='No Initiative'){
            intiativeId=null; 
        }
        timesheetDetail.Intiative__c = intiativeId;
        timesheetDetail.Timesheet__c=timeSheetId;
        timesheetDetail.Timesheet_Date__c=tDate;
        timesheetDetail.Technical_Project_Manager__c=tpm;
        //TimesheetDetailList.add(timesheetDetail);
        return timesheetDetail;
    } 
    public Messaging.SingleEmailMessage sendMailForGrether24Hours(List<TimesheetTable> timesheet,date WeekStartDate,map<string,list<string>> invalidList,string accountName,list<Initiatives__c> failedInitiatives,map<string,List<TimesheetTable>> fiveHoursNoIni,map<string,List<TimesheetTable>> noTPMAvailable){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        User currentUser=[Select Id,Email,Name From User where Id=:UserInfo.getUserId() limit 1];
        string stDate=DateTime.newInstance(WeekStartDate.year(), WeekStartDate.month(), WeekStartDate.day()).format('dd/MM/YYYY');
        
        list<string> toEmailList=new list<string>();
        toEmailList.add(currentUser.Email);
        email.setSubject('Bulk Timesheet Upload Exceptions - '+accountName+' - '+stDate);
        String body='Hi <b>'+currentUser.Name+'</b>,<br/><br/>';
        
        //****for no TPM available
        if(!noTPMAvailable.isEmpty()){
            list<TimesheetTable> noTPMTimeSheet=new List<TimesheetTable>();
            if(noTPMAvailable.containsKey(accountName)){
                noTPMTimeSheet.addAll(noTPMAvailable.get(accountName));
            }
            system.debug('noTPMTimeSheet---'+noTPMTimeSheet);
            if(!noTPMTimeSheet.isEmpty()){
                
                body +='The following timesheets are not uploaded because when no initiative is selected then TPM is required.<br/>';
                body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Initiatives Name</th><th style=" border: 1px solid black;">Task Name</th><th style=" border: 1px solid black;">Technical Project Manager</th></tr>';
                for(TimesheetTable t:noTPMTimeSheet){
                    string TPMName='';
                    string initiativeName='';
                    if(!string.isBlank(t.TPM)){
                        TPMName=t.TPM;
                    }
                    if(!string.isBlank(t.InitiativeName)){
                        initiativeName=t.InitiativeName;
                    }
                    body +='<tr><td style=" border: 1px solid black;">'+accountName+'</td><td style=" border: 1px solid black;">'+initiativeName+'</td><td style=" border: 1px solid black;">'+t.Description+'</td><td style=" border: 1px solid black;">'+TPMName+'</td></tr>';
                }
                body +='</table><br/><br/>';
                
            }
        }
        
        //****for more than 5 hours when no initiatives
        if(!fiveHoursNoIni.isEmpty()){
            list<TimesheetTable> fiveHoursNoList=new List<TimesheetTable>();
            if(fiveHoursNoIni.containsKey(accountName)){
                fiveHoursNoList.addAll(fiveHoursNoIni.get(accountName));
            }
            if(!fiveHoursNoList.isEmpty()){
                
                body +='The following timesheets are not uploaded because of no initiatives were selected and uploaded hours/task is more than 5 hours for the selected week.<br/>';
                body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Task Name</th><th style=" border: 1px solid black;">Total Hours</th></tr>';
                for(TimesheetTable t:fiveHoursNoList){
                    decimal sumOfHours=0;
                    sumOfHours =decimal.Valueof(t.Mon)+decimal.Valueof(t.Tue)+decimal.Valueof(t.Wed)+decimal.Valueof(t.Thu)+decimal.Valueof(t.Fri)+decimal.Valueof(t.Sat)+decimal.Valueof(t.Sun);
                    body +='<tr><td style=" border: 1px solid black;">'+accountName+'</td><td style=" border: 1px solid black;">'+t.Description+'</td><td style=" border: 1px solid black;">'+sumOfHours+'</td></tr>';
                }
                body +='</table><br/><br/>';
                
            }
        }
        
        //****for uploaded hours existed
        if(!failedInitiatives.isEmpty()){
            Map<Id, Initiatives__c> mapSObj = new Map<Id, Initiatives__c>();
            mapSObj.putAll(failedInitiatives);
            body +='The following timesheets are not uploaded because of uploaded hours are more than remaining hours for the initiatives.<br/>';
            body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Initiatives Name</th><th style=" border: 1px solid black;">Exceptions</th></tr>';
            for(Initiatives__c i:mapSObj.values()){
                body +='<tr><td style=" border: 1px solid black;">'+accountName+'</td><td style=" border: 1px solid black;">'+i.Name+'</td><td style=" border: 1px solid black;">Total added hours is higher than the estimated hours of <b>' + i.Estimated_hours__c +'</b> for Initiative: <b>'+ i.Name + '</b>. Remaining Hours: <b>' +i.Remaining_Hours__c+'</b>.</td></tr>';
            }
            body +='</table><br/><br/>';
        }
        
        //****for Exist 24Hours
        if(!timesheet.isEmpty()){
            body +='The following timesheets are not uploaded because of greather then 24 hours per day.<br/>';
            body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Initiatives Name</th><th style=" border: 1px solid black;">Task Description</th>';
            body +='<th style=" border: 1px solid black;">'+formateDate(WeekStartDate)+'</th><th style=" border: 1px solid black;">'+formateDate(WeekStartDate.addDays(1))+'</th><th style=" border: 1px solid black;">'+formateDate(WeekStartDate.addDays(2))+'</th><th style=" border: 1px solid black;">'+formateDate(WeekStartDate.addDays(3))+'</th>';
            body +='<th style=" border: 1px solid black;">'+formateDate(WeekStartDate.addDays(4))+'</th><th style=" border: 1px solid black;">'+formateDate(WeekStartDate.addDays(5))+'</th><th style=" border: 1px solid black;">'+formateDate(WeekStartDate.addDays(6))+'</th></tr>';
            for(TimesheetTable t:timesheet){
                Account accRecord=new Account();
                accRecord=[Select Id,Name From Account where ID=:t.AccId];
                string initiveName=' ';
                if(String.isNotBlank(t.InitiativeName))
                {
                    initiveName=t.InitiativeName;
                }
                body +='<tr><td style=" border: 1px solid black;">'+accRecord.Name+'</td><td style=" border: 1px solid black;">'+initiveName+'</td><td style=" border: 1px solid black;">'+t.Description+'</td>';
                if(decimal.Valueof(t.Mon)>=24){
                    body +='<td style=" border: 1px solid black;"> '+t.Mon+'</td>';
                }
                else{
                    body +='<td style=" border: 1px solid black;"> </td>';
                }
                if(decimal.Valueof(t.Tue)>=24){
                    body +='<td style=" border: 1px solid black;"> '+t.Tue+'</td>';
                } else{
                    body +='<td style=" border: 1px solid black;"> </td>';
                }
                if(decimal.Valueof(t.Wed)>=24){
                    body +='<td style=" border: 1px solid black;"> '+t.Wed+'</td>';
                } else{
                    body +='<td style=" border: 1px solid black;"> </td>';
                }
                if(decimal.Valueof(t.Thu)>=24){
                    body +='<td style=" border: 1px solid black;"> '+t.Thu+'</td>';
                } else{
                    body +='<td style=" border: 1px solid black;"> </td>';
                }
                if(decimal.Valueof(t.Fri)>=24){
                    body +='<td style=" border: 1px solid black;"> '+t.Fri+'</td>';
                } else{
                    body +='<td style=" border: 1px solid black;"> </td>';
                }
                if(decimal.Valueof(t.Sat)>=24){
                    body +='<td style=" border: 1px solid black;"> '+t.Sat+'</td>';
                } else{
                    body +='<td style=" border: 1px solid black;"> </td>';
                }
                if(decimal.Valueof(t.Sun)>=24){
                    body +='<td style=" border: 1px solid black;"> '+t.Sun+'</td></tr>';
                } else{
                    body +='<td style=" border: 1px solid black;"> </td></tr>';
                }
            }
            body +='</table>';
        }
        
        //for invalid initiatives
        if(!invalidList.isEmpty() && invalidList.containsKey(accountName)){
            body +='<br/>The following timesheets are not uploaded due to invalid initiatives name.<br/>';
            body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Initiatives Name</th></tr>';
            //for(string accName:invalidList.keySet()){
            for(string i:invalidList.get(accountName)){
                body +='<tr style=" border: 1px solid black;"><td style=" border: 1px solid black;">'+accountName+'</td><td style=" border: 1px solid black;">'+i+'</td></tr>';
            }  
            //}
            body +='</table>';
        }
        
        
        body +='<br/><br/>Thanks,';
        body +='<br/><br/>LevelShift Customer Success Manager';
        email.setToAddresses(toEmailList);
        email.setHtmlBody(body);
        return email;
    }
    /*public Messaging.SingleEmailMessage forMismatchInitiatives(map<string,list<string>> invalidList,date WeekStartDate,string accountName,map<string,List<TimesheetTable>> noTPMAvailable){
List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
User currentUser=[Select Id,Email,Name From User where Id=:UserInfo.getUserId() limit 1];
list<string> toEmailList=new list<string>();
toEmailList.add(currentUser.Email);
toEmailList.add('sthirumal@demandblue.com');
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

string stDate=DateTime.newInstance(WeekStartDate.year(), WeekStartDate.month(), WeekStartDate.day()).format('dd/MM/YYYY');
email.setSubject('Bulk Timesheet Upload Exceptions - '+accountName+' - '+stDate);
String body='Hi <b>'+currentUser.Name+'</b>,<br/><br/>';

if(!noTPMAvailable.isEmpty()){
list<TimesheetTable> noTPMTimeSheet=new List<TimesheetTable>();
if(noTPMAvailable.containsKey(accountName)){
noTPMTimeSheet.addAll(noTPMAvailable.get(accountName));
}
system.debug('noTPMTimeSheet---'+noTPMTimeSheet);
if(!noTPMTimeSheet.isEmpty()){

body +='The following timesheets are not uploaded because of technical project manager are not given or no initiative is selected and no TPM is specified.<br/>';
body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Initiatives Name</th><th style=" border: 1px solid black;">Task Name</th><th style=" border: 1px solid black;">Technical Project Manager</th></tr>';
for(TimesheetTable t:noTPMTimeSheet){
string TPMName='';
string initiativeName='';
if(!string.isBlank(t.TPM)){
TPMName=t.TPM;
}
if(!string.isBlank(t.InitiativeName)){
initiativeName=t.InitiativeName;
}
body +='<tr><td style=" border: 1px solid black;">'+accountName+'</td><td style=" border: 1px solid black;">'+initiativeName+'</td><td style=" border: 1px solid black;">'+t.Description+'</td><td style=" border: 1px solid black;">'+TPMName+'</td></tr>';
}
body +='</table><br/><br/>';

}
}
if(!invalidList.isEmpty()){               
if(invalidList.containsKey(accountName)){

body +='The following timesheets are not uploaded due to invalid initiatives name.<br/>';
body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Initiatives Name</th></tr>';

for(string i:invalidList.get(accountName)){
body +='<tr style=" border: 1px solid black;"><td style=" border: 1px solid black;">'+accountName+'</td><td style=" border: 1px solid black;">'+i+'</td></tr>';
}  
body +='</table>';
}          
}
body +='<br/><br/>Thanks,';
body +='<br/><br/>LevelShift Customer Success Manager';
email.setToAddresses(toEmailList);
email.setHtmlBody(body);
//Messaging.sendEmail(mails);
return email;
}
public Messaging.SingleEmailMessage sendMailForExitHours(string accountName,list<Initiatives__c> failedInitiatives,date WeekStartDate,map<string,List<TimesheetTable>> noTPMAvailable){
List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
User currentUser=[Select Id,Email,Name From User where Id=:UserInfo.getUserId() limit 1];
list<string> toEmailList=new list<string>();
toEmailList.add(currentUser.Email);
toEmailList.add('sthirumal@demandblue.com');
string stDate=DateTime.newInstance(WeekStartDate.year(), WeekStartDate.month(), WeekStartDate.day()).format('dd/MM/YYYY');
email.setSubject('Bulk Timesheet Upload Exceptions - '+accountName+' - '+stDate);
String body='Hi <b>'+currentUser.Name+'</b>,<br/><br/>';
if(!noTPMAvailable.isEmpty()){
list<TimesheetTable> noTPMTimeSheet=new List<TimesheetTable>();
if(noTPMAvailable.containsKey(accountName)){
noTPMTimeSheet.addAll(noTPMAvailable.get(accountName));
}
system.debug('noTPMTimeSheet---'+noTPMTimeSheet);
if(!noTPMTimeSheet.isEmpty()){

body +='The following timesheets are not uploaded because of technical project manager are not given or no initiative and no initiative is selected and no TPM is specified.<br/>';
body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Initiatives Name</th><th style=" border: 1px solid black;">Task Name</th><th style=" border: 1px solid black;">Technical Project Manager</th></tr>';
for(TimesheetTable t:noTPMTimeSheet){
string TPMName='';
string initiativeName='';
if(!string.isBlank(t.TPM)){
TPMName=t.TPM;
}
if(!string.isBlank(t.InitiativeName)){
initiativeName=t.InitiativeName;
}
body +='<tr><td style=" border: 1px solid black;">'+accountName+'</td><td style=" border: 1px solid black;">'+initiativeName+'</td><td style=" border: 1px solid black;">'+t.Description+'</td><td style=" border: 1px solid black;">'+TPMName+'</td></tr>';
}
body +='</table><br/><br/>';

}
}
if(!failedInitiatives.isEmpty()){
Map<Id, Initiatives__c> mapSObj = new Map<Id, Initiatives__c>();
mapSObj.putAll(failedInitiatives);
body +='The following timesheets are not uploaded because of uploaded hours are more than remaining hours for the initiatives.<br/>';
body +='<br/><table style="border-collapse: collapse"><tr style=" border: 1px solid black;border-collapse: collapse"><th style=" border: 1px solid black;">Account Name</th><th style=" border: 1px solid black;">Initiatives Name</th><th style=" border: 1px solid black;">Exceptions</th></tr>';
for(Initiatives__c i:mapSObj.values()){
body +='<tr><td style=" border: 1px solid black;">'+accountName+'</td><td style=" border: 1px solid black;">'+i.Name+'</td><td style=" border: 1px solid black;">Total added hours is higher than the estimated hours of <b>' + i.Estimated_hours__c +'</b> for Initiative: <b>'+ i.Name + '</b>. Remaining Hours: <b>' +i.Remaining_Hours__c+'</b>.</td>';
}
body +='</table><br/><br/>';
body +='<br/><br/>Thanks,';
body +='<br/><br/>LevelShift Customer Success Manager';
email.setToAddresses(toEmailList);
email.setHtmlBody(body);
//mails.add(email);

}
return email;
//Messaging.sendEmail(mails);
}*/
    public string formateDate(date dayDate){
        DateTime dt = DateTime.newInstance(dayDate.year(), dayDate.month(),dayDate.day());
        String dateStr = dt.format('dd-MMM-YYYY');
        return dateStr;
    }
    
}