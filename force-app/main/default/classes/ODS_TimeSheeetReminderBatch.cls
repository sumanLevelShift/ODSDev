global class ODS_TimeSheeetReminderBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string profileName=Label.ODS_CSM_Profiles;
        List<String> profileNameList = profileName.split(',');
        Set<ID> profileIDList=New Set<ID>();
        List<Profile> profileList=[SELECT Id,Name FROM Profile WHERE Name IN : profileNameList];
        for(Profile p:profileList)
        {
            profileIDList.add(p.id);  
        }
        return Database.getQueryLocator('SELECT Id,ManagerId,Name FROM user Where ProfileId IN : profileIDList');
    }
    
    
    global void execute(Database.BatchableContext BC, List<User> usersList) {
        
        Set<id> accIdList=new Set<id>();
        Set<id> csmidlist=new Set<id>();
        Map<id, string> CSMinfo = new Map<id, string>();
        
        
        for(User useres:usersList){
            csmidlist.add(useres.id);
        }
        List<Account_Services__c> accountServiceList=[SELECT Id,Technical_Account_manager__c,Account__c FROM Account_Services__c WHERE Technical_Account_manager__c IN: CSMIdList]; 
        
        for(Account_Services__c accSer:accountServiceList)
        {
            accIdList.add(accSer.Account__c); 
        }
        
        List<Timesheet__c> gettimesheetvalues=[Select Id, Name, Account_Services__c,Account_Services__r.Account__c,Account_Services__r.Account__r.Id,Account_Services__r.Account__r.Name,Account_Services__r.Technical_Account_manager__r.Email,Account_Services__r.Technical_Account_manager__r.Manager.email,Week_End_Date__c,Week_Start_Date__c,Status__c FROM Timesheet__c Where Status__c = :'Saved' And Account_Services__r.Account__c IN: accIdList And Week_Start_Date__c = LAST_WEEK ];
        //Need to check the case where Timesheet is not created for the pervious week but Active Initiative exist.'
        
        
        for(Timesheet__c tsheet:gettimesheetvalues){
            try{
                string  accID = tsheet.Account_Services__r.Account__r.Id;
                string csmlist = tsheet.Account_Services__r.Technical_Account_manager__c;
                if(CSMinfo.isEmpty())
                {
                    CSMinfo.put(csmlist,accID);  
                }else
                {
                    for(Id idValue : CSMinfo.keyset())
                    { 
                        if(CSMinfo.containsKey(csmlist)){
                            if(!CSMinfo.get(csmlist).contains(accID)){
                                string i=CSMinfo.get(csmlist)+','+accID;
                                CSMinfo.put(csmlist,i); 
                                break;
                            }
                        }else
                        {
                            CSMinfo.put(csmlist,accID); 
                            break;
                        }
                    }
                }
                
            }
            catch (Exception e){
                
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());   
            }  
        }
        
        for(Id idofcsm : CSMinfo.keyset())
        {  
            try{  
                List<String> accID = CSMinfo.get(idofcsm ).split(',');
                list<string> accNameList=new list<string>();
                for(Account a:[Select Id,Name From Account where Id In:accID]){
                    accNameList.add(a.Name);
                }
                for(User useres:[Select Id,Manager.Email,Email,Name from User Where Id =: idofcsm]){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> toEmail = new List<String>();
                    List<String> ccEmail = new List<String>();  
                    toEmail.add(useres.Email);
                    ccEmail.add(useres.Manager.Email);
                    mail.setToAddresses(toEmail);
                    mail.setCcAddresses(ccEmail);
                    mail.setSubject('Pending Timesheets for Submission');
                    String body='Hi '+useres.Name+',';
                    body+='<br/>';
                    body+='<br/>';
                    body+='The Timesheets for the following account(s) are pending for submission:'+'<br/>';
                    body+='<ul>';
                    for(String s : accNameList)
                    {
                        body+='<li> '+s+'</li>';
                    }
                    body+='</ul>';
                    body+='</br>';
                    body+='Thanks,';
                    body+='</br>';
                    body+='LevelShift Customer Success Manager';
                    body+='</br>';
                    
                    mail.setHtmlBody(body);
                    Messaging.SendEmail(new Messaging.SingleEmailMessage[]{mail});
                    
                }
            }catch (Exception e){
                
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());   
            } 
            
            
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}