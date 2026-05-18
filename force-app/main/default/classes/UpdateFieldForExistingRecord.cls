/*******************************************************************************************
* @author           Vignesh M
* @version          1.0 
* @Status           Development Completed
* @Batch Apex       UpdateFieldForExistingRecord
* @description      This is the Batch For updating technology term field if the comments contains from Technology_Terms__mdt 
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	18 Dec 2020    	DemandBlue 		Initial Development
*********************************************************************************************/
global class UpdateFieldForExistingRecord implements Database.Batchable<sobject>,Database.Stateful{
    global set<id> allIds=new set<id>();
    global set<id> allFailedId=new set<id>();
    global set<id> allSuccessId=new set<id>();
    global integer totalSizeRecords=0;
    global Map<Id, String> errorMap {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}
    global String subjectstring = label.TechnologyTermReportSubject;
    
    
    global UpdateFieldForExistingRecord(){
        errorMap = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();
        allSuccessId = new set<id>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<string> subjectStringList = subjectstring.split(',');

        //get the task records to update for technology term.
        String query = 'SELECT Description,Id,Subject,Technology_Terms_report__c FROM Task WHERE Technology_Terms_report__c=null and subject NOT IN :subjectStringList' ;
        system.debug('test'+Database.getQueryLocator(query));
        
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Task> scope) {
        
        try{
            
            totalSizeRecords+=scope.size();
            ODS_FiredFromBatchClass.setFiredFromBatch();
            List<Technology_Terms__mdt> arrayname =  new List<Technology_Terms__mdt>();
            arrayname = [SELECT Label FROM Technology_Terms__mdt];
            
            List<Task> UpdateTaskinstance = new List<Task>();
            
            for(Task tsk : scope)
            {
                
                if(tsk.Description != null){
                    system.debug('test'+tsk.Description);
                    string getTechTerm=tsk.Description;
                    string containingData ='';
                    boolean flage = false ;
                    
                    for(Technology_Terms__mdt  checkTermName : arrayname ){
                        
                        if(getTechTerm.containsIgnoreCase(checkTermName.Label)){
                           
                            if(flage){
                                
                                containingData += ','; 
                            }
                            containingData += checkTermName.Label;
                           
                            flage = true;
                        }            
                    }
                    
                    Task taskToUpdate = new Task();  
                    taskToUpdate.Technology_Terms_report__c = containingData;
                    taskToUpdate.Id=tsk.Id;
                    UpdateTaskinstance.add(taskToUpdate);
                }  
                
            }
            
           
            if(UpdateTaskinstance.size() > 0) {
                
                database.SaveResult[] myResult=database.update(UpdateTaskinstance,false);
                
                Integer	 index = 0;
                for(Database.SaveResult dsr : myResult){
                    if(!dsr.isSuccess()){
                        String errMsg = dsr.getErrors()[index].getMessage();
                        errorMap.put(UpdateTaskinstance[index].Id, errMsg);
                        IdToSObjectMap.put(UpdateTaskinstance[index].Id, UpdateTaskinstance[index]);
                    }
                    if(dsr.isSuccess()) 
                        {
                        allSuccessId.add(UpdateTaskinstance[index].Id);
                    }
                    index++;
                }
            }
        }
        
        catch(Exception Error){
            
            System.debug('Error'+Error);
            
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        
        //Send an email to the User after your batch completes 
        system.debug('SuccessID'+allSuccessId);
        if(!errorMap.isEmpty()){
            AsyncApexJob a = [SELECT id, ApexClassId,
                              JobItemsProcessed, TotalJobItems,
                              NumberOfErrors, CreatedBy.Email
                              FROM AsyncApexJob
                              WHERE id = :BC.getJobId()];
            String body = 'Your batch job '
                + 'BatchApexTaskUpdate '
                + 'has finished. \n' 
                + 'There were '
                + errorMap.size()
                + ' errors. Please find the error list attached to the Email.\n'
                + 'Total Completed Records' 
                +  allSuccessId.size();
                
            String[] toAddresses = new String[] { a.CreatedBy.Email,'sfadmin1@demandblue.com'};
                
            // Creating the CSV file
            String finalstr = 'Id, Error \n';
            String subject = 'Task - Apex Batch Error List';
            String attName = 'Task Errors.csv';
            for(Id id  : errorMap.keySet()){
                string err = errorMap.get(id);
                Task Taskrec = (Task) IdToSObjectMap.get(id);
                string recordString = '"'+id+'","'+err+'"\n';
                finalstr = finalstr +recordString;
            } 
            
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            // Create the email attachment    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));
            
            // Sets the paramaters of the email
            email.setSubject( subject );
            email.setToAddresses(toAddresses);
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
            
        }
        
        ODS_FiredFromBatchClass.resetFiredFromBatch();
    }
    
}