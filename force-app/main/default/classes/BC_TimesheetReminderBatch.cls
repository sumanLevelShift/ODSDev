global class BC_TimesheetReminderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    public string frequency;
    public BC_TimesheetReminderBatch(string frequency){
        this.frequency=frequency;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Account__c,Invoice_Frequency__c,Account__r.Customer_Type__c FROM Account_Services__c Where Invoice_Frequency__c=:frequency';        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account_Services__c> scope) {
        Set<string> biWeeklyAccSerSet=new Set<String>();
        Set<string> monthlyAccSerSet=new Set<String>();
        Set<string> semiMonthlyAccSerSet=new Set<String>();
        List<Messaging.SingleEmailMessage> emailList=new List<Messaging.SingleEmailMessage>();
        for(Account_Services__c accSer:scope){
            if(accSer.Invoice_Frequency__c=='Bi-Weekly'){
                biWeeklyAccSerSet.add(accSer.Id);
            }else if(accSer.Invoice_Frequency__c=='Monthly'){
                monthlyAccSerSet.add(accSer.Id);
            }else if(accSer.Invoice_Frequency__c=='Semi-Monthly'){
                semiMonthlyAccSerSet.add(accSer.Id);
            }
        }
        Date today = System.today();
        if(!biWeeklyAccSerSet.isEmpty()){
            Date thisWeekMonday = today.toStartOfWeek().addDays(1);
            Date startDate  = thisWeekMonday.addDays(-14);
            Date endDate = today.toStartOfWeek();
            List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id, Name,Non_Bi_Weekly__c, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,Account_Services__r.Account__r.Name,Status__c,
                                                             Account_Services__r.Account_Owner_Email__c,Account_Services__r.Technical_Account_Manager_Email__c,Account_Services__r.Backup_CSM__r.Email,Account_Services__r.Backup_CSM__c FROM Timesheet__c 
                                                             WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: biWeeklyAccSerSet ORDER BY Week_Start_Date__c DESC NULLS FIRST];
            Map<Id,List<Timesheet__c>> lastMonthEndWeekTimesheetsMap=new Map<Id,List<Timesheet__c>>();
            for(Timesheet__c t:lastMonthEndWeekTimesheets){
                List<Timesheet__c> timesheetList=new List<Timesheet__c>();
                timesheetList.add(t);
                if(lastMonthEndWeekTimesheetsMap.containsKey(t.Account_Services__r.Account__c)){
                    timesheetList.addAll(lastMonthEndWeekTimesheetsMap.get(t.Account_Services__r.Account__c));
                }
                lastMonthEndWeekTimesheetsMap.put(t.Account_Services__r.Account__c,timesheetList);
            }
            for(Id accountId:lastMonthEndWeekTimesheetsMap.keySet()){
                List<Timesheet__c> timesheets = lastMonthEndWeekTimesheetsMap.get(accountId);
                system.debug('NonABC - timesheets-'+timesheets.size());
                if (timesheets.size() == 2) {
                    Timesheet__c t1 = timesheets[0];
                    Timesheet__c t2 = timesheets[1];
                    
                    Timesheet__c secondWeek = t1.Week_Start_Date__c > t2.Week_Start_Date__c ? t1 : t2;
                    Timesheet__c firstWeek = t1.Week_Start_Date__c > t2.Week_Start_Date__c ? t2 : t1;                    
                    Boolean isNonBiWeekly = firstWeek.Non_Bi_Weekly__c;
                    Set<String> validStatuses = new Set<String>{'Submitted', 'Approved'};
                        system.debug('firstWeek-'+firstWeek);
                    system.debug('secondWeek-'+secondWeek);
                    system.debug('firstWeek.Status__c-'+firstWeek.Status__c);
                    system.debug('secondWeek.Status__c-'+secondWeek.Status__c);
                    if(isNonBiWeekly && validStatuses.contains(firstWeek.Status__c) && !validStatuses.contains(secondWeek.Status__c)){
                        String emailBody = '<html><body>';
                        emailBody += '<p>Dear Team,</p>';
                        emailBody += '<p>'+system.label.BC_BiWeeklyPendingTimesheetContent+'</p>';
                        
                        emailBody += '<p>Timesheet Details:</p>';
                        emailBody += '<ul>';
                        emailBody += '<li><b>Account Name:</b> ' + secondWeek.Account_Services__r.Account__r.Name + '</li>';
                        emailBody += '<li> <b>Timesheet Periods:</b> '+secondWeek.Week_Start_Date__c.format() + ' to ' + 
                            secondWeek.Week_End_Date__c.format()+'</li>';
                        emailBody += '<li><b>Status:</b> ' + secondWeek.Status__c + '</li>';
                        emailBody += '</ul>';
                        emailBody += '<p>Thank you,<br/><p>Levelshift Admin</p>';
                        emailBody += '</body></html>';
                        List<string> toAddresses=new List<string>();
                        if (firstWeek != null && firstWeek.Account_Services__r != null) {
                            if (firstWeek.Account_Services__r.Technical_Account_Manager_Email__c != null) {
                                toAddresses.add(firstWeek.Account_Services__r.Technical_Account_Manager_Email__c);
                            }
                            if (firstWeek.Account_Services__r.Backup_CSM__r != null &&
                                firstWeek.Account_Services__r.Backup_CSM__r.Email != null) {
                                    toAddresses.add(firstWeek.Account_Services__r.Backup_CSM__r.Email);
                                }
                            if (firstWeek.Account_Services__r.Account_Owner_Email__c != null) {
                                toAddresses.add(firstWeek.Account_Services__r.Account_Owner_Email__c);
                            }
                        }
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toAddresses);
                        mail.setSubject('Pending Timesheet Submission Reminder - '+secondWeek.Account_Services__r.Account__r.Name+' - Bi-Weekly');
                        mail.setHtmlBody(emailBody);
                        emailList.add(mail);
                    }
                }
            }
        }
        if(!monthlyAccSerSet.isEmpty()){
            Integer lastMonth = today.month() - 1;
            Integer lastYear = today.year();
            if (lastMonth == 0) {
                lastMonth = 12;
                lastYear--;
            }
            Date startDate = Date.newInstance(lastYear, lastMonth, 1);
            Date endDate = startDate.addMonths(1).addDays(-1);
            List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id, Name, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,Account_Services__r.Account__r.Name,Status__c,BC_Build_API_Response__c,
                                                             Account_Services__r.Account_Owner_Email__c,Account_Services__r.Technical_Account_Manager_Email__c,Account_Services__r.Backup_CSM__r.Email,Account_Services__r.Backup_CSM__c FROM Timesheet__c 
                                                             WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: monthlyAccSerSet ORDER BY Week_End_Date__c DESC NULLS FIRST];
            
            Map<Id,List<Timesheet__c>> lastMonthEndWeekTimesheetsMap=new Map<Id,List<Timesheet__c>>();
            for(Timesheet__c t:lastMonthEndWeekTimesheets){
                List<Timesheet__c> timesheetList=new List<Timesheet__c>();
                timesheetList.add(t);
                if(lastMonthEndWeekTimesheetsMap.containsKey(t.Account_Services__r.Account__c)){
                    timesheetList.addAll(lastMonthEndWeekTimesheetsMap.get(t.Account_Services__r.Account__c));
                }
                lastMonthEndWeekTimesheetsMap.put(t.Account_Services__r.Account__c,timesheetList);
            }
            for (Id accountId : lastMonthEndWeekTimesheetsMap.keySet()) {
                List<Timesheet__c> timesheetList = lastMonthEndWeekTimesheetsMap.get(accountId);
                Timesheet__c lastTimesheet = timesheetList[timesheetList.size() - 1];
                System.debug('lastTimesheet - ' + lastTimesheet);
                
                Boolean isWeekSuccess = String.isNotBlank(lastTimesheet.BC_Build_API_Response__c) &&
                    (lastTimesheet.BC_Build_API_Response__c.toLowerCase().contains('successfully') || lastTimesheet.BC_Build_API_Response__c.toLowerCase().contains('invoiced already'));
                
                if (!isWeekSuccess) {
                    Set<String> validStatuses = new Set<String>{ 'Submitted', 'Approved' };
                        Boolean hasPendingTimesheet = false;
                    DateTime weekStartDT = DateTime.newInstance(lastTimesheet.Week_Start_Date__c, Time.newInstance(0, 0, 0, 0));
					string monthString=weekStartDT.format('MMMM \'\'YY');
                    string content=system.label.BC_MonthlyPendingTimesheetContent;
                    content=content.replace('MONTH_YEAR',monthString);
                    String emailBody = '<html><body>';
                    emailBody += '<p>Dear Team,</p>';
                    emailBody += '<p>'+content+'</p>';
                    
                    // Add table with border and padding
                    emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">';
                    emailBody += '<tr><th>Account Name</th><th>Timesheet Periods</th><th>Status</th></tr>';
                    
                    for (Timesheet__c t : timesheetList) {
                        if (!validStatuses.contains(t.Status__c)) {
                            hasPendingTimesheet = true;
                            emailBody += '<tr>';
                            emailBody += '<td>' + t.Account_Services__r.Account__r.Name + '</td>';
                            emailBody += '<td>' + t.Week_Start_Date__c.format() + ' to ' + t.Week_End_Date__c.format() + '</td>';
                            emailBody += '<td>' + t.Status__c + '</td>';
                            emailBody += '</tr>';
                        }
                    }
                    
                    emailBody += '</table>';
                    emailBody += '<p>Thank you,<br/>Levelshift Admin</p>';
                    emailBody += '</body></html>';
                    
                    List<String> toAddresses = new List<String>();
                    if (lastTimesheet != null && lastTimesheet.Account_Services__r != null) {
                        if (String.isNotBlank(lastTimesheet.Account_Services__r.Technical_Account_Manager_Email__c)) {
                            toAddresses.add(lastTimesheet.Account_Services__r.Technical_Account_Manager_Email__c);
                        }
                        if (lastTimesheet.Account_Services__r.Backup_CSM__r != null &&
                            String.isNotBlank(lastTimesheet.Account_Services__r.Backup_CSM__r.Email)) {
                                toAddresses.add(lastTimesheet.Account_Services__r.Backup_CSM__r.Email);
                            }
                        if (String.isNotBlank(lastTimesheet.Account_Services__r.Account_Owner_Email__c)) {
                            toAddresses.add(lastTimesheet.Account_Services__r.Account_Owner_Email__c);
                        }
                    }
                    
                    if (hasPendingTimesheet && !toAddresses.isEmpty()) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toAddresses);
                        mail.setSubject('Pending Timesheet Submission Reminder - ' + lastTimesheet.Account_Services__r.Account__r.Name + ' - '+monthString);
                        mail.setHtmlBody(emailBody);
                        emailList.add(mail);
                    }
                }
            }
            
        }
        if(!semiMonthlyAccSerSet.isEmpty()){
            Integer day = today.day();
            Integer month = today.month();
            Integer year = today.year();
            Date startDate;
            Date endDate;
            if (day <= 15) {
                Date firstDayOfCurrentMonth = Date.newInstance(year, month, 1);
                Date lastDayOfPreviousMonth = firstDayOfCurrentMonth.addDays(-1);
                startDate = Date.newInstance(lastDayOfPreviousMonth.year(), lastDayOfPreviousMonth.month(), 16);
                endDate = lastDayOfPreviousMonth;
            } else {
                startDate = Date.newInstance(year, month, 1);
                endDate = Date.newInstance(year, month, 15);
            }
            system.debug('startDate-'+startDate);
            system.debug('endDate-'+endDate);
            system.debug('semiMonthlyAccSerSet-'+semiMonthlyAccSerSet);
            List<Timesheet__c> lastMonthEndWeekTimesheets = [SELECT Id, Name, Week_Start_Date__c,Week_End_Date__c,Account_Services__r.Account__c,Account_Services__r.Account__r.Name,Status__c,BC_Build_API_Response__c,
                                                             Account_Services__r.Account_Owner_Email__c,Account_Services__r.Technical_Account_Manager_Email__c,Account_Services__r.Backup_CSM__r.Email,Account_Services__r.Backup_CSM__c FROM Timesheet__c 
                                                             WHERE Week_End_Date__c>=:startDate AND Week_Start_Date__c<=:endDate AND Account_Services__c IN: semiMonthlyAccSerSet ORDER BY Week_End_Date__c DESC NULLS FIRST];
            
            Map<Id,List<Timesheet__c>> lastMonthEndWeekTimesheetsMap=new Map<Id,List<Timesheet__c>>();
            for(Timesheet__c t:lastMonthEndWeekTimesheets){
                List<Timesheet__c> timesheetList=new List<Timesheet__c>();
                timesheetList.add(t);
                if(lastMonthEndWeekTimesheetsMap.containsKey(t.Account_Services__r.Account__c)){
                    timesheetList.addAll(lastMonthEndWeekTimesheetsMap.get(t.Account_Services__r.Account__c));
                }
                lastMonthEndWeekTimesheetsMap.put(t.Account_Services__r.Account__c,timesheetList);
            }
            for (Id accountId : lastMonthEndWeekTimesheetsMap.keySet()) {
                List<Timesheet__c> timesheetList = lastMonthEndWeekTimesheetsMap.get(accountId);
                Timesheet__c lastTimesheet = timesheetList[timesheetList.size() - 1];
                System.debug('lastTimesheet - ' + lastTimesheet);
                
                Boolean isWeekSuccess = String.isNotBlank(lastTimesheet.BC_Build_API_Response__c) &&
                    (lastTimesheet.BC_Build_API_Response__c.toLowerCase().contains('successfully') || lastTimesheet.BC_Build_API_Response__c.toLowerCase().contains('invoiced already'));
                system.debug('isWeekSuccess -'+isWeekSuccess+'---'+lastTimesheet.BC_Build_API_Response__c);
                if (!isWeekSuccess) {
                    Set<String> validStatuses = new Set<String>{ 'Submitted', 'Approved' };
                        Boolean hasPendingTimesheet = false;
                    DateTime weekStartDT = DateTime.newInstance(lastTimesheet.Week_Start_Date__c, Time.newInstance(0, 0, 0, 0));
					string monthString=weekStartDT.format('MMMM \'\'YY');
                    string content=system.label.BC_SemiMonthlyPendingTimesheetContent;
                    content=content.replace('MONTH_YEAR',monthString);
                    String emailBody = '<html><body>';
                    emailBody += '<p>Dear Team,</p>';
                    emailBody += '<p>'+content+'</p>';
                    
                    // Add table with border and padding
                    emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">';
                    emailBody += '<tr><th>Account Name</th><th>Timesheet Periods</th><th>Status</th></tr>';
                    
                    for (Timesheet__c t : timesheetList) {
                        system.debug('t.Status__c-'+t.Status__c);
                        if (!validStatuses.contains(t.Status__c)) {
                            hasPendingTimesheet = true;
                            emailBody += '<tr>';
                            emailBody += '<td>' + t.Account_Services__r.Account__r.Name + '</td>';
                            emailBody += '<td>' + t.Week_Start_Date__c.format() + ' to ' + t.Week_End_Date__c.format() + '</td>';
                            emailBody += '<td>' + t.Status__c + '</td>';
                            emailBody += '</tr>';
                        }
                    }
                    
                    emailBody += '</table>';
                    emailBody += '<p>Thank you,<br/>Levelshift Admin</p>';
                    emailBody += '</body></html>';
                    
                    List<String> toAddresses = new List<String>();
                    if (lastTimesheet != null && lastTimesheet.Account_Services__r != null) {
                        if (String.isNotBlank(lastTimesheet.Account_Services__r.Technical_Account_Manager_Email__c)) {
                            toAddresses.add(lastTimesheet.Account_Services__r.Technical_Account_Manager_Email__c);
                        }
                        if (lastTimesheet.Account_Services__r.Backup_CSM__r != null &&
                            String.isNotBlank(lastTimesheet.Account_Services__r.Backup_CSM__r.Email)) {
                                toAddresses.add(lastTimesheet.Account_Services__r.Backup_CSM__r.Email);
                            }
                        if (String.isNotBlank(lastTimesheet.Account_Services__r.Account_Owner_Email__c)) {
                            toAddresses.add(lastTimesheet.Account_Services__r.Account_Owner_Email__c);
                        }
                    }                    
                    if (hasPendingTimesheet && !toAddresses.isEmpty()) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        mail.setToAddresses(toAddresses);
                        mail.setSubject('Pending Timesheet Submission Reminder - ' + lastTimesheet.Account_Services__r.Account__r.Name + ' - '+monthString);
                        mail.setHtmlBody(emailBody);
                        emailList.add(mail);
                    }
                }
            }
        }
        system.debug('emailList-'+emailList);
        if(!emailList.isEmpty())
            Messaging.sendEmail(emailList);
        
    }
    global void finish(Database.BatchableContext BC) {
    } 
}