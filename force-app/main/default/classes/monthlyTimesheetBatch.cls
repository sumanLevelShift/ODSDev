global class monthlyTimesheetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    List<BC_EmailRequest> emailRequests = new List<BC_EmailRequest>();
    List<Timesheet__c> updateTimesheet=new List<Timesheet__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string frequency='Monthly';
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
            Integer lastMonth = todayDate.month() - 1;
            Integer lastYear = todayDate.year();
            if (lastMonth == 0) {
                lastMonth = 12;
                lastYear--;
            }
            system.debug('accountIdSet-'+accountIdSet);
            Date startDate = Date.newInstance(lastYear, lastMonth, 1);
            Date endDate = startDate.addMonths(1).addDays(-1);
            system.debug('startDate-'+startDate);
            system.debug('endDate-'+endDate);
            
            //Map<id,Work_Order__c> tipsWorkOrderIdMap=monthlyTimesheetHelper.getTIPSIdWO(accountIdSet,endDate);
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
                List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id, Name, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,TIPS_Api_Response__c,BC_Build_API_Response__c FROM Timesheet__c 
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
                for(Id accountServiceId:lastMonthEndWeekTimesheetsMap.keySet()){
                    List<Timesheet__c> timesheets = lastMonthEndWeekTimesheetsMap.get(accountServiceId);
                    date lastWeekTS=latestDatesAccSerMap.get(accountServiceId);
                    for(Timesheet__c ts:timesheets){
                        if(lastWeekTS ==ts.Week_End_Date__c){
                            string tipsMessage=!boolean.valueOf(system.label.BC_Integration)?ts.TIPS_Api_Response__c:ts.BC_Build_API_Response__c;
                            if(string.isNotBlank(tipsMessage) && (tipsMessage.toLowerCase().contains('successfully') || tipsMessage.toLowerCase().contains('invoiced already'))){
                                uploadedTipsAccSer.add(ts.Account_Services__c);
                            }
                            break;
                        }
                    }
                }
                
                
                system.debug('uploadedTipsAccSer non ABC-'+uploadedTipsAccSer);
                accountSerIdSetNonABC.removeAll(uploadedTipsAccSer);
                system.debug('accountSerIdSetNonABC-'+accountSerIdSetNonABC);
                
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
                            string tipsMessage=!boolean.valueOf(system.label.BC_Integration)?ts.TIPS_Api_Response__c:ts.BC_Build_API_Response__c;
                            if(string.isNotBlank(tipsMessage) && (tipsMessage.toLowerCase().contains('successfully') || tipsMessage.toLowerCase().contains('invoiced already'))){
                                uploadedTipsAccSer.add(ts.Account_Services__c);
                            }
                            break;
                        }
                    }
                }
                system.debug('uploadedTipsAccSer-'+uploadedTipsAccSer);
                accountSerIdSetABC.removeAll(uploadedTipsAccSer);
                system.debug('accountSerIdSetABC ABC-'+accountSerIdSetABC);
                
                //Getting not uploaded monthly timesheet list to tips for the account.
                //Map<id,Timesheet__c> lastMonthTimesheetsABC=new map<id,Timesheet__c>([SELECT Id, Name, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,TIPS_Api_Response__c,Account_Services__r.Account__r.Name FROM Timesheet__c 
                //                                                                    WHERE ((Week_Start_Date__c >=: startDate and Week_End_Date__c <=: endDate) OR (Week_Start_Date__c <: startDate AND Week_End_Date__c >: startDate) OR (Week_Start_Date__c <: endDate AND Week_End_Date__c >: endDate)) AND Account_Services__c IN: accountSerIdSetABC AND (Status__c=:'Submitted' OR Status__c='Approved') ORDER BY Week_End_Date__c DESC NULLS FIRST]);
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
                        string tipsIDWOBuild='';
                        string tipsIDWOAdmin='';
                        string tipsIDWOConsulting='';
                        system.debug('accountId-'+accountId);
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