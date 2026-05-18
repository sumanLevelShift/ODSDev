public class TimesheetTriggerHelper {
    public class TimesheetEntry {
        public Date TimesheetTaskDate;
        public Decimal Hours;
        public String Comment;
        public Decimal RowNo;
    }
    
    public class TimesheetData {
        public String WorkorderId;
        public List<TimesheetEntry> TimesheetData;
    }
    public static string getTimesheetDetailsWeekly(String tipsId, String timesheetId){
        TimesheetData timesheetDataObj = new TimesheetData();
        timesheetDataObj.WorkorderId = tipsId;
        List<TimesheetEntry> timesheetEntries = new List<TimesheetEntry>();
        
        List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c FROM Time_Sheet_Details__c
                                                          WHERE Timesheet__c=:timesheetId];
        for (Time_Sheet_Details__c record : timesheetDetailsList) {
            TimesheetEntry entry = new TimesheetEntry();
            entry.TimesheetTaskDate = record.Timesheet_Date__c;
            entry.Hours = record.Hours_Worked__c;
            entry.Comment = record.Task_Name__c;
            entry.RowNo = record.Row_No__c;
            timesheetEntries.add(entry);
        }
        
        timesheetDataObj.TimesheetData = timesheetEntries;
        String jsonString = JSON.serialize(timesheetDataObj);
        jsonString=jsonString.replaceAll('TimesheetTaskDate', 'Date');
        
        System.debug('jsonString-'+jsonString);   
        return jsonString;
    }
    public static string getTimesheetDetailsMonthly(String tipsId, Set<id> timesheetId,Date startDate,Date endDate){
        TimesheetData timesheetDataObj = new TimesheetData();
        timesheetDataObj.WorkorderId = tipsId;
        List<TimesheetEntry> timesheetEntries = new List<TimesheetEntry>();
        
        List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c FROM Time_Sheet_Details__c
                                                          WHERE Timesheet__c IN: timesheetId AND 
                                                          Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Timesheet_Date__c DESC NULLS FIRST];
        for (Time_Sheet_Details__c record : timesheetDetailsList) {
            system.debug('record-'+record);
            TimesheetEntry entry = new TimesheetEntry();
            entry.TimesheetTaskDate = record.Timesheet_Date__c;
            entry.Hours = record.Hours_Worked__c;
            entry.Comment = record.Task_Name__c;
            entry.RowNo = record.Row_No__c;
            timesheetEntries.add(entry);
        }           
        
        timesheetDataObj.TimesheetData = timesheetEntries;
        String jsonString = JSON.serialize(timesheetDataObj);
        jsonString=jsonString.replaceAll('TimesheetTaskDate', 'Date');
        System.debug(jsonString);
        return jsonString;
    }
    public static string getTimesheetDetailsWeeklyABC(String tipsId, String timesheetId,String initiativeType){
        TimesheetData timesheetDataObj = new TimesheetData();
        timesheetDataObj.WorkorderId = tipsId;
        List<TimesheetEntry> timesheetEntries = new List<TimesheetEntry>();
        
        List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c FROM Time_Sheet_Details__c
                                                          WHERE Timesheet__c=:timesheetId AND Initiative_Billing_Type__c=:initiativeType];
        for (Time_Sheet_Details__c record : timesheetDetailsList) {
            TimesheetEntry entry = new TimesheetEntry();
            entry.TimesheetTaskDate = record.Timesheet_Date__c;
            entry.Hours = record.Hours_Worked__c;
            entry.Comment = record.Task_Name__c;
            entry.RowNo = record.Row_No__c;
            
            timesheetEntries.add(entry);
        }
        
        timesheetDataObj.TimesheetData = timesheetEntries;
        String jsonString = JSON.serialize(timesheetDataObj);
        jsonString=jsonString.replaceAll('TimesheetTaskDate', 'Date');
        System.debug(jsonString);
        return jsonString;
    }
    public static string getTimesheetDetailsMonthlyABC(String tipsId, Set<id> timesheetId, String initiativeType,Date startDate,Date endDate){
        TimesheetData timesheetDataObj = new TimesheetData();
        timesheetDataObj.WorkorderId = tipsId;
        List<TimesheetEntry> timesheetEntries = new List<TimesheetEntry>();
        
        List<Time_Sheet_Details__c> timesheetDetailsList=[SELECT Hours_Worked__c,Row_No__c,Task_Name__c,Timesheet_Date__c,Timesheet__c FROM Time_Sheet_Details__c
                                                          WHERE Timesheet__c IN: timesheetId AND Initiative_Billing_Type__c=:initiativeType
                                                          AND Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Timesheet_Date__c DESC NULLS FIRST];
        for (Time_Sheet_Details__c record : timesheetDetailsList) {
            system.debug('record-'+record);
            system.debug(record.Timesheet_Date__c+'-tipsId---'+tipsId+'---hours---'+record.Hours_Worked__c);
            TimesheetEntry entry = new TimesheetEntry();
            entry.TimesheetTaskDate = record.Timesheet_Date__c;
            entry.Hours = record.Hours_Worked__c;
            entry.Comment = record.Task_Name__c;
            entry.RowNo = record.Row_No__c;
            timesheetEntries.add(entry);
        }
        
        timesheetDataObj.TimesheetData = timesheetEntries;
        String jsonString = JSON.serialize(timesheetDataObj);
        jsonString=jsonString.replaceAll('TimesheetTaskDate', 'Date');
        System.debug(jsonString);
        return jsonString;
    }
}