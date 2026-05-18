global class UpdateResourceCountBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Account_Services__c,Month__c,Resource_Count__c,Year__c FROM Time_Sheet_Cost__c Order by Year__c,Month__c,Account_Services__c ';
        return Database.getQueryLocator(query);
    } 
    global void execute(Database.BatchableContext BC, List<Time_Sheet_Cost__c> timesheetCostList) {
        try{
            for(Time_Sheet_Cost__c tsc:timesheetCostList){
                Decimal ResourceCount = 0;
                Decimal totalHours = 0;
                Date startDateofMonth = Date.newInstance(integer.valueOf(tsc.Year__c), integer.valueOf(tsc.Month__c), 1);
                system.debug('startDateofMonth-'+startDateofMonth);
                DateTime startDateTimeofMonth =  DateTime.newInstance(startDateofMonth.Year(),startDateofMonth.Month(),startDateofMonth.Day());
                string[] WeekBoundaryDates = ODS_DateUtility.GetWeekBoundaryDatesByMonth(startDateTimeofMonth);
                Integer daysInMonth = Date.daysInMonth(integer.valueOf(tsc.Year__c), integer.valueOf(tsc.Month__c));
                Date lastDayOfMonth = startDateofMonth.addDays(daysInMonth - 1);
                AggregateResult[] aggHours = [SELECT SUM(Hours_Worked__c) ODSTotalHrs,Resource__c from Time_Sheet_Details__c WHERE Timesheet_Date__c >=: startDateofMonth AND Timesheet_Date__c <=: lastDayOfMonth 
                                              AND Timesheet__r.Account_Services__c =: tsc.Account_Services__c AND Status__c IN ('Submitted','Approved') group by Resource__c];
                if(!aggHours.isEmpty()){
                    totalHours += (Decimal)aggHours[0].get('ODSTotalHrs');  
                    system.debug('totalHours-'+totalHours);
                }
                /* for(string eachBoundary: WeekBoundaryDates )
{
string StartDate = eachBoundary.split('~')[0];
string EndDate = eachBoundary.split('~')[1];                
Date eachWeekStartDate = date.valueof(StartDate);
Date eachWeekEndDate = date.valueof(EndDate);
AggregateResult[] aggHours = [SELECT SUM(Hours_Worked__c) ODSTotalHrs,Resource__c from Time_Sheet_Details__c WHERE Timesheet_Date__c >=: eachWeekStartDate AND Timesheet_Date__c <=: eachWeekEndDate 
AND Timesheet__r.Account_Services__c =: tsc.Account_Services__c AND Status__c IN ('Submitted','Approved') group by Resource__c];
if(!aggHours.isEmpty()){
totalHours += (Decimal)aggHours[0].get('ODSTotalHrs');  
}
}*/
                if(totalHours>0){
                    // system.debug('totalHours-'+totalHours);
                    ResourceCount = (Decimal)Math.ceil(totalHours/40);
                }
                tsc.Resource_Count__c=ResourceCount;
                system.debug('ResourceCount-'+ResourceCount);
            }
            system.debug('timesheetCostList-'+timesheetCostList.size());
            if(!timesheetCostList.isEmpty()){
                update timesheetCostList;
            }
        }catch(Exception e){
            System.debug('Error--'+e.getMessage());
        }
    }    
    global void finish(Database.BatchableContext BC) {
    }
}