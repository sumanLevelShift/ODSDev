global class UploadBulkTimeSheetBatch implements Database.Batchable<sObject>,Database.stateful {
    list<Initiatives__c> failedInitiatives=new list<Initiatives__c>();
    map<string,list<Initiatives__c>> failedInitiativesMap=new Map<string,list<Initiatives__c>>();
    Map<Id, Account_Services__c> accountSerList = new Map<Id, Account_Services__c>([SELECT ID,ODS_Hourly_Rate_Amount__c, Account__c,Account__r.Name from Account_Services__c]);
    map<string,List<TimesheetTable>> timeSheetDetailsList=new map<string,List<TimesheetTable>>();
    map<string,List<TimesheetTable>> timeSheetDetailsListValidated=new map<string,List<TimesheetTable>>();
    map<string,List<TimesheetTable>> fiveHoursGreaterNoIni=new map<string,List<TimesheetTable>>();
    set<string> accountNameList=new set<string>();
    public map<string,List<TimesheetTable>> tpmNotAvailable{get; set;}
    
    public date WeekStartDate {get; set;}
    public date WeekEndDate {get; set;}
    public map<string,list<string>> invalidInitiatives {get; set;}
    @TestVisible 
    public static Map<id, Initiatives__c> initiativesList { 
        get {
            if ( null == initiativesList || initiativesList.isEmpty() ){
                ODS_Common_Utility obj = new ODS_Common_Utility();
                String[] AccounIDs = obj.getAllAccountIDByLoggedInUser();
                initiativesList =new Map<id, Initiatives__c>( [Select Id, name, Status__c,Estimated_hours__c,Remaining_Hours__c,Account_Name__c from Initiatives__c where (Account_Service__r.Account__c IN: AccounIDs) and (Status__c ='Initiative Approved' OR Status__c ='Active Initiative') ]);   
                return initiativesList;     
            }
            return initiativesList;
        } set; 
    }    
    public UploadBulkTimeSheetBatch(map<string,List<TimesheetTable>> timeSheetList,date weekStartDate,date weekEndDate,map<string,list<string>> invalidList,map<string,list<TimesheetTable>> noTPM,set<string> aList){
        this.timeSheetDetailsList=timeSheetList;  
        this.WeekStartDate=weekStartDate;
        this.WeekEndDate=weekEndDate;
        this.invalidInitiatives=invalidList;
        this.tpmNotAvailable=noTPM;
        this.accountNameList=aList;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id,Name From Account Limit 1');
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        UploadBulkTimeSheetHelper helper=new UploadBulkTimeSheetHelper();
        fiveHoursGreaterNoIni=new map<string,List<TimesheetTable>>();
        try{
            Timesheet__c timeSheet=new Timesheet__c();
            //if(!timeSheetDetailsList.isEmpty()){
            map<string,list<TimesheetTable>> sameInitiativeMap=new map<string,list<TimesheetTable>>();
            system.debug('timeSheetDetailsList---'+timeSheetDetailsList);
            for(string accSerId:timeSheetDetailsList.keySet()){
                failedInitiatives=new list<Initiatives__c>();
                Account_Services__c objAcntSrv=new Account_Services__c();
                objAcntSrv=accountSerList.get(accSerId);
                boolean flag=false;
                flag=helper.checkTimesheetvalidation(objAcntSrv,WeekStartDate,WeekEndDate);
                if(flag){
                    for(TimesheetTable t:timeSheetDetailsList.get(accSerId)){
                        if(t.InitiativeId !='No Initiative'){
                            list<TimesheetTable> ttList=new list<TimesheetTable>();
                            ttList.add(t);
                            if(sameInitiativeMap.containsKey(t.InitiativeId)){
                                ttList.addAll(sameInitiativeMap.get(t.InitiativeId)); 
                            }
                            sameInitiativeMap.put(t.InitiativeId,ttList);  
                        }else{
                            decimal sumOfHours=0;
                            sumOfHours +=decimal.Valueof(t.Mon)+decimal.Valueof(t.Tue)+decimal.Valueof(t.Wed)+decimal.Valueof(t.Thu)+decimal.Valueof(t.Fri)+decimal.Valueof(t.Sat)+decimal.Valueof(t.Sun);
                            system.debug('sumOfHours---'+sumOfHours+'---t.InitiativeId--'+t.InitiativeId);
                            if(sumOfHours > 5){  
                                system.debug('ttttt---'+t);
                                List<TimesheetTable> timeListInValid=new List<TimesheetTable>();
                                timeListInValid.add(t);
                                if(fiveHoursGreaterNoIni.containsKey(objAcntSrv.Account__r.Name)){
                                    timeListInValid.addAll(fiveHoursGreaterNoIni.get(objAcntSrv.Account__r.Name));
                                }
                                fiveHoursGreaterNoIni.put(objAcntSrv.Account__r.Name,timeListInValid);   
                            }else{
                                List<TimesheetTable> timeList=new List<TimesheetTable>();
                                timeList.add(t);
                                if(timeSheetDetailsListValidated.containsKey(accSerId)){
                                    timeList.addAll(timeSheetDetailsListValidated.get(accSerId));
                                }
                                timeSheetDetailsListValidated.put(accSerId,timeList);    
                            }
                            
                        }
                        
                    }
                }
            }
            system.debug('sameInitiative---'+sameInitiativeMap);
            for(string initId:sameInitiativeMap.keySet()){
                decimal sumOfHours=0;
                for(TimesheetTable t:sameInitiativeMap.get(initId)){
                    sumOfHours +=decimal.Valueof(t.Mon)+decimal.Valueof(t.Tue)+decimal.Valueof(t.Wed)+decimal.Valueof(t.Thu)+decimal.Valueof(t.Fri)+decimal.Valueof(t.Sat)+decimal.Valueof(t.Sun);
                }
                boolean remainingHours=false;
                list<Initiatives__c> getInitiatives=new list<Initiatives__c>();
                if(initId !='No Initiative'){
                    system.debug('initId--##--'+initId);
                    getInitiatives.add(initiativesList.get(initId));   
                    remainingHours=getInitiatives[0].Remaining_Hours__c < sumOfHours;
                }
                system.debug('sumOfHours---'+sumOfHours+'---initId--'+initId);
                if(remainingHours){
                    failedInitiatives=new list<Initiatives__c>();
                    failedInitiatives.add(getInitiatives[0]);
                    if(failedInitiativesMap.containsKey(getInitiatives[0].Account_Name__c)){
                        failedInitiatives.addAll(failedInitiativesMap.get(getInitiatives[0].Account_Name__c));
                        failedInitiativesMap.put(getInitiatives[0].Account_Name__c,failedInitiatives);  
                    }else{
                        failedInitiativesMap.put(getInitiatives[0].Account_Name__c,failedInitiatives);    
                    }
                }
                else{
                    List<TimesheetTable> timeList=new List<TimesheetTable>();
                    timeList.addAll(sameInitiativeMap.get(initId));
                    if(timeSheetDetailsListValidated.containsKey(timeList[0].accSerId)){
                        timeList.addAll(timeSheetDetailsListValidated.get(timeList[0].accSerId));
                    }
                    timeSheetDetailsListValidated.put(timeList[0].accSerId,timeList);    
                }
            }
            system.debug('failedInitiativesMap---'+failedInitiativesMap);
            
            //insert timesheet and timesheet details.
            List<Time_Sheet_Details__c> TimesheetDetailList=new List<Time_Sheet_Details__c>();
            Map<string,list<TimesheetTable>> validationListForMoreThen24HrsMap=new Map<string,list<TimesheetTable>>();
            
            for(string accSerId:timeSheetDetailsListValidated.keySet()){
                TimesheetDetailList=new List<Time_Sheet_Details__c>();
                list<TimesheetTable> validationListForMoreThen24Hrs=new list<TimesheetTable>();
                list<TimesheetTable> insertTimesheetList=new list<TimesheetTable>();
                
                Account_Services__c objAcntSrv=new Account_Services__c();
                objAcntSrv=accountSerList.get(accSerId);
                //check 24Hours per day
                
                for(TimesheetTable t:timeSheetDetailsListValidated.get(accSerId)){
                    Time_Sheet_Details__c timesheetDetail = new Time_Sheet_Details__c();
                    if(decimal.Valueof(t.Mon)!=0){
                        if(decimal.Valueof(t.Mon) >=24){
                            validationListForMoreThen24Hrs.add(t);   
                        }else{
                            insertTimesheetList.add(t);
                        }
                    }
                    if(decimal.Valueof(t.Tue)!=0){
                        if(decimal.Valueof(t.Tue) >=24){
                            validationListForMoreThen24Hrs.add(t);   
                        }else{
                            insertTimesheetList.add(t);
                        }
                    }
                    if(decimal.Valueof(t.Wed)!=0){
                        if(decimal.Valueof(t.Wed) >=24){
                            validationListForMoreThen24Hrs.add(t);   
                        }else{
                            insertTimesheetList.add(t);
                        }
                    }
                    if(decimal.Valueof(t.Thu)!=0){
                        if(decimal.Valueof(t.Thu) >=24){
                            validationListForMoreThen24Hrs.add(t);   
                        }else{
                            insertTimesheetList.add(t);
                        }
                    }
                    if(decimal.Valueof(t.Fri)!=0){
                        if(decimal.Valueof(t.Fri) >=24){
                            validationListForMoreThen24Hrs.add(t);   
                        }else{
                            insertTimesheetList.add(t);
                        }
                    }
                    if(decimal.Valueof(t.Sat)!=0){
                        if(decimal.Valueof(t.Sat) >=24){
                            validationListForMoreThen24Hrs.add(t);   
                        }else{
                            insertTimesheetList.add(t);
                        }
                    }
                    if(decimal.Valueof(t.Sun)!=0){
                        if(decimal.Valueof(t.Sun) >=24){
                            validationListForMoreThen24Hrs.add(t);   
                        }else{
                            insertTimesheetList.add(t);
                        }
                    }
                    
                }
                validationListForMoreThen24HrsMap.put(objAcntSrv.Account__r.Name,validationListForMoreThen24Hrs);
                //outside for loop
                
                
                    timeSheet=helper.createTimesheet(accSerId,objAcntSrv,WeekStartDate,WeekEndDate);
                    if(timeSheet.Status__c =='Saved'){
                        Project_Team_Member__c ptm=[Select Id,Account__c from Project_Team_Member__c where Account__c=:objAcntSrv.Account__c limit 1];
                        integer i=0;
                        for(TimesheetTable t:timeSheetDetailsListValidated.get(accSerId)){
                            i++;
                            Time_Sheet_Details__c timesheetDetail = new Time_Sheet_Details__c();
                            if(decimal.Valueof(t.Mon)!=0){
                            if(decimal.Valueof(t.Mon) >=24){
                                //validationListForMoreThen24Hrs.add(t);   
                            }else{
                                TimesheetDetailList.add(helper.createTimesheetDetails(WeekStartDate,timeSheet.id,t.InitiativeId,i,t.Description,ptm.id,decimal.Valueof(t.Mon),t.TPM));
                            }
                        }
                        if(decimal.Valueof(t.Tue)!=0){
                            if(decimal.Valueof(t.Tue) >=24){
                                //validationListForMoreThen24Hrs.add(t);   
                            }else{
                                TimesheetDetailList.add(helper.createTimesheetDetails(WeekStartDate.addDays(1),timeSheet.id,t.InitiativeId,i,t.Description,ptm.id,decimal.Valueof(t.Tue),t.TPM));
                            }
                        }
                        if(decimal.Valueof(t.Wed)!=0){
                            if(decimal.Valueof(t.Wed) >=24){
                                //validationListForMoreThen24Hrs.add(t);   
                            }else{
                                TimesheetDetailList.add(helper.createTimesheetDetails(WeekStartDate.addDays(2),timeSheet.id,t.InitiativeId,i,t.Description,ptm.id,decimal.Valueof(t.Wed),t.TPM));
                            }
                        }
                        if(decimal.Valueof(t.Thu)!=0){
                            if(decimal.Valueof(t.Thu) >=24){
                                //validationListForMoreThen24Hrs.add(t);   
                            }else{
                                TimesheetDetailList.add(helper.createTimesheetDetails(WeekStartDate.addDays(3),timeSheet.id,t.InitiativeId,i,t.Description,ptm.id,decimal.Valueof(t.Thu),t.TPM));
                            }
                        }
                        if(decimal.Valueof(t.Fri)!=0){
                            if(decimal.Valueof(t.Fri) >=24){
                                //validationListForMoreThen24Hrs.add(t);   
                            }else{
                                TimesheetDetailList.add(helper.createTimesheetDetails(WeekStartDate.addDays(4),timeSheet.id,t.InitiativeId,i,t.Description,ptm.id,decimal.Valueof(t.Fri),t.TPM));
                            }
                        }
                        if(decimal.Valueof(t.Sat)!=0){
                            if(decimal.Valueof(t.Sat) >=24){
                                //validationListForMoreThen24Hrs.add(t);   
                            }else{
                                TimesheetDetailList.add(helper.createTimesheetDetails(WeekStartDate.addDays(5),timeSheet.id,t.InitiativeId,i,t.Description,ptm.id,decimal.Valueof(t.Sat),t.TPM));
                                
                            }
                        }
                        if(decimal.Valueof(t.Sun)!=0){
                            if(decimal.Valueof(t.Sun) >=24){
                                //validationListForMoreThen24Hrs.add(t);   
                            }else{
                                TimesheetDetailList.add(helper.createTimesheetDetails(WeekEndDate,timeSheet.id,t.InitiativeId,i,t.Description,ptm.id,decimal.Valueof(t.Sun),t.TPM));
                            }
                        }
                            
                        }
                                    if(!TimesheetDetailList.isEmpty()){
                insert TimesheetDetailList;
                
            }
                    }  
/*                failedInitiatives=new list<Initiatives__c>();
                if(!failedInitiativesMap.isEmpty()){
                    if(failedInitiativesMap.containsKey(objAcntSrv.Account__r.Name)){
                        failedInitiatives.addAll(failedInitiativesMap.get(objAcntSrv.Account__r.Name));
                    }   
                }
                
                
                if(!validationListForMoreThen24Hrs.isEmpty() || invalidInitiatives.containsKey(objAcntSrv.Account__r.Name)==true ||!failedInitiatives.isEmpty() || !tpmNotAvailable.isEmpty()){

Messaging.SingleEmailMessage mail=helper.sendMailForGrether24Hours(validationListForMoreThen24HrsMap.get(objAcntSrv.Account__r.Name),WeekStartDate,invalidInitiatives,objAcntSrv.Account__r.Name,failedInitiatives,fiveHoursGreaterNoIni,tpmNotAvailable);
mails.add(mail);
validationListForMoreThen24HrsMap.remove(objAcntSrv.Account__r.Name);
invalidInitiatives.remove(objAcntSrv.Account__r.Name);
fiveHoursGreaterNoIni.remove(objAcntSrv.Account__r.Name);
tpmNotAvailable.remove(objAcntSrv.Account__r.Name);
failedInitiativesMap.remove(objAcntSrv.Account__r.Name);
accountNameList.remove(objAcntSrv.Account__r.Name);
}*/
            } 

            system.debug('210 failedInitiativesMap---'+failedInitiativesMap);
            //outSideloop
            if(!accountNameList.isEmpty()){
                for(string accountName:accountNameList){
                    failedInitiatives=new list<Initiatives__c>();
                    if(failedInitiativesMap.containsKey(accountName)){
                        failedInitiatives.addAll(failedInitiativesMap.get(accountName));
                    }
                    List<TimesheetTable> listOf24HoursTimesheet=new List<TimesheetTable>();
                    
                    if(validationListForMoreThen24HrsMap.containsKey(accountName)){
                        listOf24HoursTimesheet.addAll(validationListForMoreThen24HrsMap.get(accountName));
                    }
                    if(!listOf24HoursTimesheet.isEmpty() || !failedInitiatives.isEmpty() || invalidInitiatives.containsKey(accountName) || fiveHoursGreaterNoIni.containsKey(accountName) || tpmNotAvailable.containsKey(accountName)){
                        Messaging.SingleEmailMessage mail=helper.sendMailForGrether24Hours(listOf24HoursTimesheet,WeekStartDate,invalidInitiatives,accountName,failedInitiatives,fiveHoursGreaterNoIni,tpmNotAvailable);
                        mails.add(mail);         
                    }
					accountNameList.remove(accountName);
                    if(validationListForMoreThen24HrsMap.containsKey(accountName)){
                        validationListForMoreThen24HrsMap.remove(accountName);
                    }
                    if(invalidInitiatives.containsKey(accountName)){
                        invalidInitiatives.remove(accountName);    
                    }
                    if(fiveHoursGreaterNoIni.containsKey(accountName)){
                        fiveHoursGreaterNoIni.remove(accountName);
                    }
                    if(failedInitiativesMap.containsKey(accountName)){
                        failedInitiativesMap.remove(accountName);
                    }
                    if(tpmNotAvailable.containsKey(accountName)){
                        tpmNotAvailable.remove(accountName);
                    }
                }
            }
            
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
            //}
        } catch(Exception e){
            system.debug('batch Exception--'+e.getMessage()+'-line no=='+e.getLineNumber());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName()); 
            new ODS_TimeSheetToolPageController().sendMailForException(e);
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
}