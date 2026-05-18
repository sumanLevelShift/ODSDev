/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       ActivitiesForCSM
* @description      This class is used in LWC Component(ShowAccountActivities)
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	21-JAN-2021    	DemandBlue 		Initial Development
*********************************************************************************************/
public without sharing class ActivitiesForCSM {
    /* This is wrapper class to Show Account Activities */    
    public without sharing class AccountActivity{
        @AuraEnabled
        public string AccId {get; set;} 
        @AuraEnabled
        public string Name {get; set;}
        @AuraEnabled
        public string Subject {get; set;}
        @AuraEnabled
        public string ActivityId {get; set;} 
        @AuraEnabled
        public string AssignedToName {get; set;} //OwnerId
        @AuraEnabled
        public string RelatedToName {get; set;} //WhatId
        @AuraEnabled
        public string WhoIDName {get; set;} //WhoID
        @AuraEnabled
        public Datetime StartDateTime {get; set;} 
        @AuraEnabled
        public Datetime EndDateTime {get; set;} 
        @AuraEnabled
        public string ActivityType {get; set;}
        @AuraEnabled
        public string ActivityDescription {get; set;}
        
    }
    /* This method is called from LWC Component(ShowAccountActivities) */ 
    @AuraEnabled(cacheable = true)
    public static List<AccountActivity> getActivities(string accountId) {
        try{ 
            List<AccountActivity> accountActivityList = new List<AccountActivity>();        
            if(String.IsNotBlank(accountId)){                
                List<Account> accList = [SELECT Id,Name,(SELECT Id,Subject,CreatedDate,ActivityDate,OwnerId,WhatId,Owner.Name,Who.Name,What.Name,What.Type,EndDateTime,StartDateTime,Description FROM ActivityHistories ORDER BY ActivityDate DESC NULLS FIRST,Subject ASC,LastModifiedDate DESC LIMIT 500),(SELECT Id,Subject,CreatedDate,ActivityDate,OwnerId,WhatId,Owner.Name,Who.Name,What.Name,What.Type,EndDateTime,StartDateTime,Description FROM OpenActivities ORDER BY ActivityDate DESC NULLS FIRST,Subject DESC,LastModifiedDate ASC) FROM Account WHERE Id =:accountId];
                if(!accList.isEmpty()){
                    for(Account accObj:accList){
                        for(OpenActivity openActivityRecord:accObj.OpenActivities){
                            AccountActivity aAWraper = new AccountActivity();
                            aAWraper.AccId = accObj.Id;
                            aAWraper.Name = accObj.Name;
                            aAWraper.ActivityId = openActivityRecord.Id;
                            aAWraper.Subject = openActivityRecord.Subject;            
                            aAWraper.AssignedToName = openActivityRecord.Owner.Name;
                            aAWraper.RelatedToName = openActivityRecord.What.Name;
                            aAWraper.WhoIDName = openActivityRecord.Who.Name;
                            aAWraper.StartDateTime = openActivityRecord.StartDateTime;
                            aAWraper.EndDateTime = openActivityRecord.EndDateTime;
                            aAWraper.ActivityType = openActivityRecord.What.Type;
                            aAWraper.ActivityDescription = openActivityRecord.Description;
                            accountActivityList.add(aAWraper);
                        }
                        for(ActivityHistory activityRecord:accObj.ActivityHistories){
                            AccountActivity aAWraper = new AccountActivity();
                            aAWraper.AccId = accObj.Id;
                            aAWraper.Name = accObj.Name;
                            aAWraper.ActivityId = activityRecord.Id;
                            aAWraper.Subject = activityRecord.Subject;            
                            aAWraper.AssignedToName = activityRecord.Owner.Name;
                            aAWraper.RelatedToName = activityRecord.What.Name;
                            aAWraper.WhoIDName = activityRecord.Who.Name;
                            aAWraper.StartDateTime = activityRecord.StartDateTime;
                            aAWraper.EndDateTime = activityRecord.EndDateTime;
                            aAWraper.ActivityType = activityRecord.What.Type;
                            aAWraper.ActivityDescription = activityRecord.Description;
                            accountActivityList.add(aAWraper);                        
                        }                     
                    }
                }
            }        
            return accountActivityList;
        } 
        catch(Exception e){
            system.debug('Error occured on getting the Activities::: '+ e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        } 
    }
}