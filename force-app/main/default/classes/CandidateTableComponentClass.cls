public class CandidateTableComponentClass {
	@AuraEnabled
    public static Candidate__c createCandidateRecord(Candidate__c candidate){
        System.debug('Inside createCandidateRecord()');
        try{
            if(candidate != null){
                insert candidate;
                System.debug('Inside insert if');
            }
        }catch(Exception e){
            System.debug('Error while inserting record@@@@ : ' + e.getMessage());
            candidate = null;
        }
        return candidate;
    }
    @AuraEnabled
    public static void deleteCandidateRecord(Candidate__c candidate){
        System.debug('Inside deleteCandidateRecord()');
        try{
            /*if(candidate != null){
                System.debug('Inside insert if');
                Candidate__c cand = new Candidate__c(Name=candidate.Name, Candidate_Email__c=candidate.Candidate_Email__c);
                delete cand;
            }*/
            if(candidate != null){
                System.debug('Inside insert if');
                Candidate__c[] toBeDeletedCandidate = [SELECT Id, Name, Candidate_Email__c FROM Candidate__c 
                         WHERE Name =: candidate.Name AND Candidate_Email__c =: candidate.Candidate_Email__c]; 
				if(toBeDeletedCandidate.size() == 1)
    				delete toBeDeletedCandidate;
                else
                    System.debug('More than 1 records in the list to be deleted. Pl check.');
            }
        }catch(Exception e){
            System.debug('Error while deleting record@@@@ : ' + e.getMessage());
        }
    }
}