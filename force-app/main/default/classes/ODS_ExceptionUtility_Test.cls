@isTest
public class ODS_ExceptionUtility_Test {
    public static testmethod void saveErrorLogs(){
        
        string erCause = '';
        string erMessage = 'Error: Invalid.';
        string erStackTrace = 'ODS_ExceptionUtility.saveErrorLogs';
        string erTypeName = 'system.DMLException';
        
        try {
            Integer.valueOf('number');
        } catch (Exception e) {
            ODS_ExceptionUtility.LogException(e);
        }
        
        ODS_ExceptionUtility.saveErrorLogs(erCause,erMessage,erStackTrace,erTypeName);
        ODS_ExceptionUtility.logTipsIntegrationFailure('','','','Admin');

    }  
}