@RestResource(urlMapping='/kickoff')
global class KickoffRestApi {
    @httpPost
    global static void updateKickOff(string accountId,string kickoffStatus, Date completedDate){
        
        try{
            List<Account> accountRecord=[SELECT Id,KickOff_Completed_Date__c,Kickoff__c FROM Account WHERE Id=:accountId]; 
            if(!accountRecord.isEmpty()){
                Account acc=new Account();
                acc.Id=accountRecord[0].Id;
                acc.KickOff_Completed_Date__c=completedDate;
                acc.Kickoff__c=KickOffStatus;
                update acc;
            }
        } catch(Exception e)    
        {
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            system.debug('Error --> '+e.getLineNumber()+':'+e.getMessage());
        }
    }
}