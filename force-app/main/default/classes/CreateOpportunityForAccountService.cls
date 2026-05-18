/**
* @author           Harish Sankaran
* @version          1.0 
* @date             13-April-2021
* @Status           Inprogress
* @description      This Batch class for automatically creating an Renewal Opportunity for the accounts
60 days before the contract end date and also automatically creating a task 
*
*/

global class CreateOpportunityForAccountService implements Database.Batchable<sObject> {
    //Get the contract renewal days from custom label.
    public string getcontractRenewalDays = label.Contract_Renewal_Days;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        return Database.getQueryLocator('Select id,name,CRRDays__c,Contract_End_Date__c,Account__c,Account__r.Name,Account__r.OwnerId from Account_Services__c where CRRDays__c='+getcontractRenewalDays+'');
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account_Services__c> scope){
        
        
        try{
            //Opportunity creation
            List<Opportunity> OpportunityList = new List<Opportunity>();
            //Task LList for insert. 
            List<Task> taskList = new List<Task>();
            //set fired from batch global flag
             ODS_FiredFromBatchClass.setFiredFromBatch();
            for(Account_Services__c accountServiceRec : scope){
                date dateformat = accountServiceRec.Contract_End_Date__c;
                string  Oppname = 'ODS Renewal - Opportunity - Contract expiring '+ dateformat.year()+'-'+dateformat.Month()+'-'+dateformat.day();
                
                List<Opportunity> OppDub = [Select id,Name, AccountId from Opportunity where name = : Oppname and accountid =: accountServiceRec.Account__c];
                if(!(oppDub.size() > 0)){
                    //setting opportunity values here
                    Opportunity renewalopp = new Opportunity();
                    renewalopp.name = Oppname;
                    renewalopp.OwnerId = accountServiceRec.Account__r.OwnerId;
                    renewalopp.Type = 'Existing Business';
                    renewalopp.CloseDate=accountServiceRec.Contract_End_Date__c;
                    renewalopp.StageName='Negotiation';
                    renewalopp.AccountId=accountServiceRec.Account__c;
                    renewalopp.Description = 'ODS Renewal - Opportunity';
                    renewalopp.Business_Unit__c = 'DemandBlue';
					renewalopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Project_ODS').getRecordTypeId();
                    DateTime dT1 = System.now();
                    Date d1 = date.newinstance(dT1.year(), dT1.month(), dT1.day());
                    Datetime ti1 =(Datetime)d1;
                    String dayOfCreatedDate =ti1.format('EEEE');
                    
                    if(dayOfCreatedDate=='Monday'|| dayOfCreatedDate=='Tuesday'||dayOfCreatedDate=='Wednesday' || dayOfCreatedDate=='Thursday' || dayOfCreatedDate=='Sunday')
                            renewalopp.Follow_up_Date__c =d1.addDays(1);
                        if(dayOfCreatedDate=='Friday')
                            renewalopp.Follow_up_Date__c =d1.addDays(3);
                        if(dayOfCreatedDate=='Saturday')
                            renewalopp.Follow_up_Date__c =d1.addDays(2);                       
    
                    OpportunityList.add(renewalopp);
                }
                
                if(!OpportunityList.isEmpty()){
                    system.debug('OpportunityListOpportunityList'+OpportunityList);
                    Database.insert(OpportunityList, false); //Data base insert OpportunityList; 
                    
                }
            }
                
                for(Opportunity RenewalOppTask : [Select id, Account.ownerid,Account.Primary_Customer_Contact__c,Follow_up_Date__c from Opportunity where id IN: OpportunityList ]) { 
                    
                    Task createTask = new Task();
                    //setting Task values here
                    createTask.Subject = 'Send Email';
                    createTask.WhoId = RenewalOppTask.Account.Primary_Customer_Contact__c;
                    createTask.Priority = 'Normal';
                    createTask.Status = 'Not started';
                    createTask.whatId = RenewalOppTask.id;
                    createTask.OwnerId = RenewalOppTask.Account.OwnerId;
                    createTask.ActivityDate=RenewalOppTask.Follow_up_Date__c;
                    createTask.Description = 'ODS Renewal Followup';
                    taskList.add(createTask);
                    
                }  
                
                if(!taskList.isEmpty()){
                    
                    Database.insert(taskList, false);  
                    
                }
                
            
        }
        catch (Exception e){
            
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());   
        }  
    }
    //finish
    global void finish( Database.BatchableContext BC ) {
        
        //Reset fired from batch global flag
        ODS_FiredFromBatchClass.resetFiredFromBatch();
    }
    
}