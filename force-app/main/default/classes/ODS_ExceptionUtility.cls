public class ODS_ExceptionUtility {
    public static void LogException(Exception e)
    {
        LogException(e,'');
    }
    
    // Log Exception in CustomException object. 
    // relatedToId : Case/object for which this error in logged.
    public static void LogException(Exception e,string relatedToId)
    {
        try
        {
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String className = stackTrace.substringAfter('.').substringBefore('.');	
            String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
            
            //Governer Limit of executingQuery 
            String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
            
            //Log information in object
            Error_Log_Message__c exc = new Error_Log_Message__c();
            exc.Related_To_Number__c=relatedToId;
            exc.Govt_Limit_in_Executing_Code__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{QueryLimit, DMLimit,DMLStat,CPUT});
            exc.Message__c  = e.getMessage();
            exc.Type_Name__c  = e.getTypeName();
            exc.Line_Number__c = e.getLineNumber();
            exc.Stack_Trace__c  = e.getStackTraceString();
            exc.MethodName__c=methodName;
            exc.ClassName__c=className;
            database.insert(exc);            
        } 
        finally{
        }            
    }
    public static void saveErrorLogs(string erCause, string erMessage, string erStackTrace, string erTypeName)
    {
        Error_Log_Message__c error = new Error_Log_Message__c();
        error.Cause__c = erCause;
        error.Message__c = erMessage;
        error.Stack_Trace__c = erStackTrace;
        error.Type_Name__c = erTypeName;
        insert error;
    }
    public static void logTipsIntegrationFailure(string workOrderId,string encryptString,string tipsErrorMessage,string typeWO){
        Error_Log_Message__c error = new Error_Log_Message__c();
        error.Related_To_Number__c = workOrderId;
        error.Stack_Trace__c = encryptString;
        error.Message__c = tipsErrorMessage;
        error.MethodName__c = typeWO;
        insert error; 
    }
}