trigger leadInfoScoreAccount on Account (after insert,after update) {
     String scoreFieldChanged = 'no';
     Decimal scoreUpdateDiff = 0;
    Map<Id, Decimal> accountScoreMap = new Map <id, Decimal>();
    // Checking the account to get old score if its already created account
    if(!trigger.isinsert){
        for(Account acc :Trigger.New){
            if(Trigger.oldMap.get(acc.Id) != null){
               Account old = Trigger.oldMap.get(acc.Id);
         	  if(acc.Score__c != old.Score__c ){
                  scoreFieldChanged = 'yes';
                  scoreUpdateDiff = acc.Score__c - old.Score__c;
                  accountScoreMap.put(acc.Id, scoreUpdateDiff);
              }else{
                  scoreFieldChanged = 'no';
              }
            }
        }
    }else if (trigger.isinsert){
        for(Account acc:Trigger.New){
            if(acc.Score__c != 0  ){
                scoreFieldChanged = 'yes';
                accountScoreMap.put(acc.Id, acc.Score__c);
            }
        }
        
    }
    if(!accountScoreMap.isEmpty()){
        // instantiate a new instance of the Queueable class
		//UpdateContactAndLead updateJob = new UpdateContactAndLead(accountScoreMap);
        // enqueue the job for processing
		//ID jobID = System.enqueueJob(updateJob);
    }
}