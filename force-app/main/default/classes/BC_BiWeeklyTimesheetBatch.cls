global class BC_BiWeeklyTimesheetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    List<Timesheet__c> updateTimesheet=new List<Timesheet__c>();
    List<BC_EmailRequest> emailRequests = new List<BC_EmailRequest>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string frequency='Bi-Weekly';
        String query = 'SELECT Id,Account__c,Invoice_Frequency__c,Account__r.Customer_Type__c FROM Account_Services__c Where Invoice_Frequency__c=:frequency';        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account_Services__c> scope) {
        Set<id> accountSerIdSetNonABC=new Set<id>();
        Set<id> accountSerIdSetABC=new Set<id>();
        Set<id> accountIdSet=new Set<id>();
        
        try{
            for(Account_Services__c aSer:scope){
                if(aSer.Account__r.Customer_Type__c=='ABC Type'){
                    accountSerIdSetABC.add(aSer.id);
                }else{
                    accountSerIdSetNonABC.add(aSer.id);
                }
                accountIdSet.add(aSer.Account__c);
            }
            Date today = System.today();
            Date thisWeekMonday = today.toStartOfWeek().addDays(1);
            Date startDate  = thisWeekMonday.addDays(-14);
            system.debug('startDate-'+startDate);
            Date endDate = today.toStartOfWeek();
            system.debug('EndDate-'+endDate);
            
            Map<id,List<Work_Order__c>> tipsWorkOrderIdMap=monthlyTimesheetBCHelper.getBCIdWO(accountIdSet,startDate,endDate);
            system.debug('tipsWorkOrderIdMap-'+tipsWorkOrderIdMap);
            system.debug('tipsWorkOrderIdMap-'+tipsWorkOrderIdMap.size());
            
            //Non ABC Timesheets
            if(!accountSerIdSetNonABC.isEmpty()){
                system.debug('accountSerIdSetNonABC-'+accountSerIdSetNonABC);
                //checking monthly timesheet hours are uploaded to tips for the account.
                List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id, Name,Non_Bi_Weekly__c, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,TIPS_Api_Response__c,BC_Build_API_Response__c FROM Timesheet__c 
                                                                 WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: accountSerIdSetNonABC AND (Status__c=:'Submitted' OR Status__c='Approved') ORDER BY Week_Start_Date__c DESC NULLS FIRST];
                Map<Id,List<Timesheet__c>> lastMonthEndWeekTimesheetsMap=new Map<Id,List<Timesheet__c>>();
                for(Timesheet__c t:lastMonthEndWeekTimesheets){
                    List<Timesheet__c> timesheetList=new List<Timesheet__c>();
                    timesheetList.add(t);
                    if(lastMonthEndWeekTimesheetsMap.containsKey(t.Account_Services__r.Account__c)){
                        timesheetList.addAll(lastMonthEndWeekTimesheetsMap.get(t.Account_Services__r.Account__c));
                    }
                    lastMonthEndWeekTimesheetsMap.put(t.Account_Services__r.Account__c,timesheetList);
                }
                Set<id> uploadedTipsAccSer=new Set<id>();
                system.debug('lastMonthEndWeekTimesheets-'+lastMonthEndWeekTimesheets.size());
                for(Id accountId:lastMonthEndWeekTimesheetsMap.keySet()){
                    List<Timesheet__c> timesheets = lastMonthEndWeekTimesheetsMap.get(accountId);
                    system.debug('NonABC - timesheets-'+timesheets.size());
                    if (timesheets.size() == 2) {
                        Timesheet__c t1 = timesheets[0];
                        Timesheet__c t2 = timesheets[1];
                        
                        Timesheet__c secondWeek  = t1.Week_Start_Date__c > t2.Week_Start_Date__c ? t1 : t2;
                        Timesheet__c firstWeek  = t1.Week_Start_Date__c > t2.Week_Start_Date__c ? t2 : t1;
                        
                        Boolean isFirstWeekSuccess = String.isNotBlank(firstWeek.BC_Build_API_Response__c) ?
                            (firstWeek.BC_Build_API_Response__c.toLowerCase().contains('successfully') ||
                             firstWeek.BC_Build_API_Response__c.toLowerCase().contains('invoiced already')):false;
                        
                        Boolean isSecondWeekSuccess = String.isNotBlank(secondWeek.BC_Build_API_Response__c)?
                            (secondWeek.BC_Build_API_Response__c.toLowerCase().contains('successfully')||
                             secondWeek.BC_Build_API_Response__c.toLowerCase().contains('invoiced already')):false;
                        
                        Boolean isNonBiWeekly = firstWeek.Non_Bi_Weekly__c;
                        
                        if (isFirstWeekSuccess){
                            uploadedTipsAccSer.add(firstWeek.Account_Services__c); 
                        }else if (isNonBiWeekly && isSecondWeekSuccess){
                            uploadedTipsAccSer.add(secondWeek.Account_Services__c);
                        }
                    }else if (timesheets.size() == 1){
                        Timesheet__c t1 = timesheets[0];
                        Boolean isNonBiWeekly = t1.Non_Bi_Weekly__c;
                        Boolean isFirstWeekSuccess = String.isNotBlank(t1.BC_Build_API_Response__c) ?
                            (t1.BC_Build_API_Response__c.toLowerCase().contains('successfully')||
                             t1.BC_Build_API_Response__c.toLowerCase().contains('invoiced already')):false;
                        system.debug('isNonBiWeekly-'+isNonBiWeekly);
                        system.debug('isFirstWeekSuccess-'+isFirstWeekSuccess);
                        if (isNonBiWeekly && isFirstWeekSuccess){
                            uploadedTipsAccSer.add(t1.Account_Services__c);
                        }
                    }
                }
                system.debug('uploadedTipsAccSer-'+uploadedTipsAccSer);
                system.debug('accountSerIdSetNonABC-'+accountSerIdSetNonABC);
                accountSerIdSetNonABC.removeAll(uploadedTipsAccSer);
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
                        List<Work_Order__c> workOrderRecords=tipsWorkOrderIdMap.get(accountId);
                        if(boolean.valueOf(system.label.BC_Integration)){
                            updateTimesheet.addAll(monthlyTimesheetBCHelper.monthlyTimesheets(timesheetIdWithAccId.get(accountId),startDate,endDate,accountId,workOrderRecords,emailRequests));    
                        }
                    }
                }
            }
            //ABC Type Timesheets
            if(!accountSerIdSetABC.isEmpty()){
                //checking monthly timesheet hours are uploaded to tips for the account.
                List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id, Name,Non_Bi_Weekly__c, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,TIPS_Api_Response__c,TIPS_Api_Admin_Response__c,TIPS_Api_Consulting_Response__c,BC_Build_API_Response__c,BC_Admin_API_Response__c,BC_Consult_API_Response__c FROM Timesheet__c 
                                                                 WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: accountSerIdSetABC AND (Status__c=:'Submitted' OR Status__c='Approved') ORDER BY Week_Start_Date__c DESC NULLS FIRST];
                Map<Id,List<Timesheet__c>> lastMonthEndWeekTimesheetsMap=new Map<Id,List<Timesheet__c>>();
                for(Timesheet__c t:lastMonthEndWeekTimesheets){
                    List<Timesheet__c> timesheetList=new List<Timesheet__c>();
                    timesheetList.add(t);
                    if(lastMonthEndWeekTimesheetsMap.containsKey(t.Account_Services__r.Account__c)){
                        timesheetList.addAll(lastMonthEndWeekTimesheetsMap.get(t.Account_Services__r.Account__c));
                    }
                    lastMonthEndWeekTimesheetsMap.put(t.Account_Services__r.Account__c,timesheetList);
                }
                Set<id> uploadedTipsAccSer=new Set<id>();
                system.debug('lastMonthEndWeekTimesheets-'+lastMonthEndWeekTimesheets.size());
                for(Id accountId:lastMonthEndWeekTimesheetsMap.keySet()){
                    List<Timesheet__c> timesheets = lastMonthEndWeekTimesheetsMap.get(accountId);
                    if (timesheets.size() == 2) {
                        Timesheet__c t1 = timesheets[0];
                        Timesheet__c t2 = timesheets[1];
                        
                        Timesheet__c secondWeek  = t1.Week_Start_Date__c > t2.Week_Start_Date__c ? t1 : t2;
                        Timesheet__c firstWeek  = t1.Week_Start_Date__c > t2.Week_Start_Date__c ? t2 : t1;
                        
                        Boolean isFirstWeekSuccess = String.isNotBlank(firstWeek.BC_Build_API_Response__c) ?
                            (firstWeek.BC_Build_API_Response__c.toLowerCase().contains('successfully') || 
                             firstWeek.BC_Build_API_Response__c.toLowerCase().contains('invoiced already')):false;
                        
                        Boolean isSecondWeekSuccess = String.isNotBlank(secondWeek.BC_Build_API_Response__c)?
                            (secondWeek.BC_Build_API_Response__c.toLowerCase().contains('successfully') ||
                             secondWeek.BC_Build_API_Response__c.toLowerCase().contains('invoiced already')):false;
                        
                        Boolean isNonBiWeekly = firstWeek.Non_Bi_Weekly__c;
                        
                        if (isFirstWeekSuccess){
                            uploadedTipsAccSer.add(firstWeek.Account_Services__c); 
                        }else if (isNonBiWeekly && isSecondWeekSuccess){
                            uploadedTipsAccSer.add(firstWeek.Account_Services__c);
                        }
                    }else if (timesheets.size() == 1){
                        Timesheet__c t1 = timesheets[0];
                        Boolean isNonBiWeekly = t1.Non_Bi_Weekly__c;
                        Boolean isFirstWeekSuccess = String.isNotBlank(t1.BC_Build_API_Response__c) ?
                            (t1.BC_Build_API_Response__c.toLowerCase().contains('successfully') ||
                             t1.BC_Build_API_Response__c.toLowerCase().contains('invoiced already')):false;
                        if (isNonBiWeekly && isFirstWeekSuccess){
                            uploadedTipsAccSer.add(t1.Account_Services__c);
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
                        system.debug('accountId-'+accountId);
                        if(boolean.valueOf(system.label.BC_Integration)){
                            List<Work_Order__c> WorkOrderRecords=tipsWorkOrderIdMap.get(accountId);
                            updateTimesheet.addAll(monthlyTimesheetBCHelper.monthlyTimesheetsABC(timesheetIdWithABCAccId.get(accountId),startDate,endDate,accountId,WorkOrderRecords,emailRequests));    
                        }
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
        system.debug('updateTimesheet-'+updateTimesheet);
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