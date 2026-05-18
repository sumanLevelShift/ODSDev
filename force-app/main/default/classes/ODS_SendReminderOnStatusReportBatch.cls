global class ODS_SendReminderOnStatusReportBatch implements Database.Batchable<sObject> {
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
    
    global void execute(Database.BatchableContext BC, List<User> recordList) {
        Set<id> CSMIdList=new Set<id>();
        Set<id> accountIdList=new Set<id>();
        
        Map<id, string> pendingCSMDetails = new Map<id, string>();
        
        for(User u:recordList){
            CSMIdList.add(u.id);
        }
        
        List<Account_Services__c> accSerList=[SELECT Id,Technical_Account_manager__c,Account__c FROM Account_Services__c WHERE Technical_Account_manager__c IN: CSMIdList]; 
        for(Account_Services__c accSer:accSerList)
        {
            accountIdList.add(accSer.Account__c); 
        }
        
        List<Status_Report__c> getStatusReport=[Select Id, Name, Account_Services__c,Account_Services__r.Account__c,Account_Services__r.Account__r.Name,
                                                Account_Services__r.Technical_Account_manager__r.Email,
                                                Account_Services__r.Technical_Account_manager__r.Manager.email,Account_Services__r.Account__r.Id,
                                                Status__c,Status_Date__c,Work_For_The_Day__c From Status_Report__c
                                                Where Status__c = :'Saved' And Account_Services__r.Account__c IN: accountIdList AND Status_Date__c=YESTERDAY];
        
        for(Status_Report__c sr:getStatusReport){
            try{ 
                String workForTheDay = sr.Work_For_The_Day__c;
                workForTheDay = workForTheDay.replaceAll('<[/a-zAZ0-9]*>','');
                if(sr.Work_For_The_Day__c != null && !workForTheDay.equalsignorecase('none') && sr.Account_Services__c !=null && workForTheDay !=' ') {
                    string accID=sr.Account_Services__r.Account__r.Id;
                    String CSMID=sr.Account_Services__r.Technical_Account_manager__c;
                    if(pendingCSMDetails.isEmpty())
                    {
                        pendingCSMDetails.put(CSMID,accID);  
                    }else
                    {
                        for(Id idValue : pendingCSMDetails.keyset())
                        { 
                            if(pendingCSMDetails.containsKey(CSMID)){
                                if(!pendingCSMDetails.get(CSMID).contains(accID)){
                                    string i=pendingCSMDetails.get(CSMID)+','+accID;
                                    pendingCSMDetails.put(CSMID,i);  
                                    break;
                                }
                            }else{
                                pendingCSMDetails.put(CSMID,accID); 
                                break;
                            }
                        }
                    }
                    
                }
            }catch (Exception e){
                
                ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());   
            }  
        }
        
        for(Id idValue : pendingCSMDetails.keyset())
        {
            try{  
                List<String> accID = pendingCSMDetails.get(idValue ).split(',');
                list<string> accNameList=new list<string>();
                List<Account> accountFinalList=[Select Id,Name From Account where Id IN:accID];
                for(Account a:accountFinalList){
                    accNameList.add(a.Name);
                }
                for(User u:[Select Id,Manager.Email,Email,Name from User Where Id =: idValue]){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> toEmail = new List<String>();
                    List<String> ccEmail = new List<String>();  
                    toEmail.add(u.Email);
                    ccEmail.add(u.Manager.Email);
                    mail.setToAddresses(toEmail);
                    mail.setCcAddresses(ccEmail);
                    mail.setSubject('Pending Status Report Submission');
                    String body='Hi '+u.Name+',';
                    body+='<br>';
                    body+='<br>';
                    body+='The status report for the following account(s) are pending for submission:'+'<br>';
                    body+='<ul>';
                    for(String s : accNameList)
                    {
                        system.debug('name--'+s);
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