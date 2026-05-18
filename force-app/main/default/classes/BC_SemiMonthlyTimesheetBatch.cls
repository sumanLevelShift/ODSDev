global class BC_SemiMonthlyTimesheetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    List<BC_EmailRequest> emailRequests = new List<BC_EmailRequest>();
    List<Timesheet__c> updateTimesheet=new List<Timesheet__c>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string frequency='Semi-Monthly';
        String query = 'SELECT Id,Account__c,Invoice_Frequency__c,Account__r.Customer_Type__c FROM Account_Services__c Where Invoice_Frequency__c=:frequency';        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account_Services__c> scope) {
        Set<id> accountSerIdSetNonABC=new Set<id>();
        Set<id> accountSerIdSetABC=new Set<id>();
        Set<id> accountIdSet=new Set<id>();
       // List<Timesheet__c> updateTimesheet=new List<Timesheet__c>();
        
        try{
            for(Account_Services__c aSer:scope){
                if(aSer.Account__r.Customer_Type__c=='ABC Type'){
                    accountSerIdSetABC.add(aSer.id);
                }else{
                    accountSerIdSetNonABC.add(aSer.id);
                }
                accountIdSet.add(aSer.Account__c);
            }
            Date todayDate = Date.today();
            
            Date startDate;
            Date endDate;
            
            Integer day = todayDate.day();
            Integer month = todayDate.month();
            Integer year = todayDate.year();
            
            if (day <= 15) {
                Date firstDayOfCurrentMonth = Date.newInstance(year, month, 1);
                Date lastDayOfPreviousMonth = firstDayOfCurrentMonth.addDays(-1);
                startDate = Date.newInstance(lastDayOfPreviousMonth.year(), lastDayOfPreviousMonth.month(), 16);
                endDate = lastDayOfPreviousMonth;
            } else {
                startDate = Date.newInstance(year, month, 1);
                endDate = Date.newInstance(year, month, 15);
            }
            
            System.debug('Current Date: ' + todayDate);
            System.debug('Previous Semi-Monthly Start Date: ' + startDate);
            System.debug('Previous Semi-Monthly End Date: ' + endDate);
            
            Map<id,List<Work_Order__c>> bcWorkOrderIdMap=monthlyTimesheetBCHelper.getBCIdWO(accountIdSet,startDate,endDate);
            system.debug('bcWorkOrderIdMap-'+bcWorkOrderIdMap);
            system.debug('bcWorkOrderIdMap-'+bcWorkOrderIdMap.size());
            
            //Non ABC Timesheets
            if(!accountSerIdSetNonABC.isEmpty()){
                system.debug('accountSerIdSetNonABC-'+accountSerIdSetNonABC);
                List<AggregateResult> aggResults = [SELECT Account_Services__c, MAX(Week_End_Date__c) latestDate
                                                    FROM Timesheet__c
                                                    WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: accountSerIdSetNonABC AND (Status__c=:'Submitted' OR Status__c='Approved')
                                                    GROUP BY Account_Services__c];
                Map<Id, Date> latestDatesAccSerMap = new Map<Id, Date>();
                
                for(AggregateResult ar : aggResults) {
                    Id accServiceId = (Id)ar.get('Account_Services__c');
                    Date latestDate = (Date)ar.get('latestDate');
                    latestDatesAccSerMap.put(accServiceId, latestDate);
                }
                
                //checking monthly timesheet hours are uploaded to tips for the account.
                List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id, Name,Non_Bi_Weekly__c, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,TIPS_Api_Response__c,BC_Build_API_Response__c FROM Timesheet__c 
                                                                 WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: accountSerIdSetNonABC AND (Status__c=:'Submitted' OR Status__c='Approved') ORDER BY Week_End_Date__c DESC NULLS FIRST];
                Map<Id,List<Timesheet__c>> lastMonthEndWeekTimesheetsMap=new Map<Id,List<Timesheet__c>>();
                for(Timesheet__c t:lastMonthEndWeekTimesheets){
                    List<Timesheet__c> timesheetList=new List<Timesheet__c>();
                    timesheetList.add(t);
                    if(lastMonthEndWeekTimesheetsMap.containsKey(t.Account_Services__c)){
                        timesheetList.addAll(lastMonthEndWeekTimesheetsMap.get(t.Account_Services__c));
                    }
                    lastMonthEndWeekTimesheetsMap.put(t.Account_Services__c,timesheetList);
                }
                Set<id> uploadedTipsAccSer=new Set<id>();
                system.debug('lastMonthEndWeekTimesheets-'+lastMonthEndWeekTimesheets.size());
                for(Id accountServiceId:lastMonthEndWeekTimesheetsMap.keySet()){
                    List<Timesheet__c> timesheets = lastMonthEndWeekTimesheetsMap.get(accountServiceId);
                    date lastWeekTS=latestDatesAccSerMap.get(accountServiceId);
                    for(Timesheet__c ts:timesheets){
                        if(lastWeekTS ==ts.Week_End_Date__c){
                            system.debug('ts.BC_Build_API_Response__c-'+ts.BC_Build_API_Response__c);
                            string bcMessage=ts.BC_Build_API_Response__c;
                            if(string.isNotBlank(bcMessage) && (bcMessage.toLowerCase().contains('successfully') || bcMessage.toLowerCase().contains('invoiced already'))){
                                uploadedTipsAccSer.add(ts.Account_Services__c);
                            }
                        }
                    }
                }
                system.debug('uploadedTipsAccSer-'+uploadedTipsAccSer);
                system.debug('accountSerIdSetNonABC-'+accountSerIdSetNonABC);
                accountSerIdSetNonABC.removeAll(uploadedTipsAccSer);
                system.debug('accountSerIdSetNonABC 1-'+accountSerIdSetNonABC);
                Map<id,Timesheet__c> lastMonthTimesheets=new map<id,Timesheet__c>([SELECT Id, Name, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,TIPS_Api_Response__c,Account_Services__r.Account__r.Name,BC_Build_API_Response__c FROM Timesheet__c WHERE Account_Services__c IN: accountSerIdSetNonABC AND (Status__c=:'Submitted' OR Status__c='Approved') AND 
                                                                                   ((Week_Start_Date__c >= :startDate AND Week_End_Date__c <= :endDate) OR (Week_Start_Date__c < :startDate AND Week_End_Date__c >= :startDate)
                                                                                    OR (Week_Start_Date__c <= :endDate AND Week_End_Date__c > :endDate) OR (Week_Start_Date__c = :startDate)) ORDER BY Week_End_Date__c DESC NULLS FIRST]);
                
                system.debug('lastMonthTimesheets-'+lastMonthTimesheets);
                if(!lastMonthTimesheets.isEmpty()){
                    Map<Id,set<id>> timesheetIdWithAccId=new Map<Id,set<id>>();
                    for(Timesheet__c t:lastMonthTimesheets.values()){
                        Set<id> timesheetIds=new Set<id>();
                        timesheetIds.add(t.id);
                        if(timesheetIdWithAccId.containsKey(t.Account_Services__r.Account__c)){
                            timesheetIds.addAll(timesheetIdWithAccId.get(t.Account_Services__r.Account__c)); 
                        }
                        timesheetIdWithAccId.put(t.Account_Services__r.Account__c,timesheetIds);
                    }
                    system.debug('non ABC timesheetIdWithAccId-'+timesheetIdWithAccId);
                    for(id accountId:timesheetIdWithAccId.keySet()){
                        List<Work_Order__c> validWorkOrders=bcWorkOrderIdMap.get(accountId);
                        updateTimesheet.addAll(monthlyTimesheetBCHelper.monthlyTimesheets(timesheetIdWithAccId.get(accountId),startDate,endDate,accountId,validWorkOrders,emailRequests));   
                    }
                }
            }
            //ABC Type Timesheets
            if(!accountSerIdSetABC.isEmpty()){
                List<AggregateResult> aggResults = [SELECT Account_Services__c, MAX(Week_End_Date__c) latestDate
                                                    FROM Timesheet__c
                                                    WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: accountSerIdSetABC AND (Status__c=:'Submitted' OR Status__c='Approved')
                                                    GROUP BY Account_Services__c];
                Map<Id, Date> latestDatesAccSerMap = new Map<Id, Date>();
                
                for(AggregateResult ar : aggResults) {
                    Id accServiceId = (Id)ar.get('Account_Services__c');
                    Date latestDate = (Date)ar.get('latestDate');
                    latestDatesAccSerMap.put(accServiceId, latestDate);
                }
                //checking monthly timesheet hours are uploaded to tips for the account.
                List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id, Name, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,TIPS_Api_Response__c,TIPS_Api_Admin_Response__c,TIPS_Api_Consulting_Response__c,BC_Build_API_Response__c,BC_Admin_API_Response__c,BC_Consult_API_Response__c FROM Timesheet__c 
                                                                 WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: accountSerIdSetABC AND (Status__c=:'Submitted' OR Status__c='Approved') ORDER BY Week_End_Date__c DESC NULLS FIRST];
                
                Map<Id,List<Timesheet__c>> lastMonthEndWeekTimesheetsMap=new Map<Id,List<Timesheet__c>>();
                for(Timesheet__c t:lastMonthEndWeekTimesheets){
                    List<Timesheet__c> timesheetList=new List<Timesheet__c>();
                    timesheetList.add(t);
                    if(lastMonthEndWeekTimesheetsMap.containsKey(t.Account_Services__c)){
                        timesheetList.addAll(lastMonthEndWeekTimesheetsMap.get(t.Account_Services__c));
                    }
                    lastMonthEndWeekTimesheetsMap.put(t.Account_Services__c,timesheetList);
                }
                Set<id> uploadedTipsAccSer=new Set<id>();
                system.debug('lastMonthEndWeekTimesheets-'+lastMonthEndWeekTimesheets.size());
                for(Id accountServiceId:lastMonthEndWeekTimesheetsMap.keySet()){
                    List<Timesheet__c> timesheets = lastMonthEndWeekTimesheetsMap.get(accountServiceId);
                    date lastWeekTS=latestDatesAccSerMap.get(accountServiceId);
                    for(Timesheet__c ts:timesheets){
                        if(lastWeekTS ==ts.Week_End_Date__c){
                            string bcMessage=ts.BC_Build_API_Response__c;
                            if(string.isNotBlank(bcMessage) && (bcMessage.toLowerCase().contains('successfully') || bcMessage.toLowerCase().contains('invoiced already'))){
                                uploadedTipsAccSer.add(ts.Account_Services__c);
                            }
                            break;
                        }
                    }
                }
                system.debug('uploadedTipsAccSer-'+uploadedTipsAccSer);
                accountSerIdSetABC.removeAll(uploadedTipsAccSer);
                system.debug('accountSerIdSetABC ABC-'+accountSerIdSetABC);
                
                Map<id,Timesheet__c> lastMonthTimesheetsABC=new map<id,Timesheet__c>([SELECT Id, Name, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,TIPS_Api_Response__c,Account_Services__r.Account__r.Name,BC_Build_API_Response__c,BC_Admin_API_Response__c,BC_Consult_API_Response__c FROM Timesheet__c 
                                                                                      WHERE Account_Services__c IN: accountSerIdSetABC AND (Status__c=:'Submitted' OR Status__c='Approved') AND ((Week_Start_Date__c >= :startDate AND Week_End_Date__c <= :endDate) OR (Week_Start_Date__c < :startDate AND Week_End_Date__c >= :startDate)
                                                                                                                                                                                                 OR (Week_Start_Date__c <= :endDate AND Week_End_Date__c > :endDate) OR (Week_Start_Date__c = :startDate)) ORDER BY Week_End_Date__c DESC NULLS FIRST]);
                
                system.debug('lastMonthTimesheetsABC-'+lastMonthTimesheetsABC);
                if(!lastMonthTimesheetsABC.isEmpty()){
                    Map<Id,set<id>> timesheetIdWithABCAccId=new Map<Id,set<id>>();
                    for(Timesheet__c t:lastMonthTimesheetsABC.values()){
                        Set<id> timesheetIds=new Set<id>();
                        timesheetIds.add(t.id);
                        if(timesheetIdWithABCAccId.containsKey(t.Account_Services__r.Account__c)){
                            timesheetIds.addAll(timesheetIdWithABCAccId.get(t.Account_Services__r.Account__c)); 
                        }
                        timesheetIdWithABCAccId.put(t.Account_Services__r.Account__c,timesheetIds);
                    }
                    
                    for(id accountId:timesheetIdWithABCAccId.keySet()){
                        List<Work_Order__c> validWorkOrders=bcWorkOrderIdMap.get(accountId);
                        updateTimesheet.addAll(monthlyTimesheetBCHelper.monthlyTimesheetsABC(timesheetIdWithABCAccId.get(accountId),startDate,endDate,accountId,validWorkOrders,emailRequests));   
                    }
                }
            }
            
        }catch(Exception e){
            System.debug('message -'+e.getMessage());
            System.debug('message st-'+e.getStackTraceString());
            ODS_ExceptionUtility.LogException(e);
        }
    }   
    global void finish(Database.BatchableContext BC) {
        if(!updateTimesheet.isEmpty()) {
            Map<Id, Timesheet__c> timesheetMap = new Map<Id, Timesheet__c>();
            
            for(Timesheet__c ts : updateTimesheet) {
                timesheetMap.put(ts.Id, ts);
            }
            
            if(!timesheetMap.isEmpty()) {
                update timesheetMap.values();
            }
        }
        if(!emailRequests.isEmpty()){
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            for(BC_EmailRequest req : emailRequests) {
                if(req.emailType == 'FAILURE') {
                    emailsToSend.add(monthlyTimesheetBCHelper.createFailureEmail(req));
                } else if(req.emailType == 'INTEGRATION_FAILURE') {
                    emailsToSend.add(monthlyTimesheetBCHelper.createIntegrationFailureEmail(req));
                }
            }
            
            if(!emailsToSend.isEmpty()) {
                Messaging.sendEmail(emailsToSend);
            }
        }
    } 
}