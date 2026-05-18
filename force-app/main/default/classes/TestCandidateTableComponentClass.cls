@isTest
public class TestCandidateTableComponentClass {
    static testMethod void testCreateCandidateRecord_Success(){
        Candidate__c candidate = new Candidate__c(Name='Test Candidate Inserted', Candidate_Email__c='test@gmail.com');
        CandidateTableComponentClass.createCandidateRecord(candidate);
        
        candidate = [SELECT Name FROM Candidate__c WHERE Id =:candidate.Id];
        
        System.assertEquals('Test Candidate Inserted', candidate.Name);
    }
    static testMethod void testCreateCandidateRecord_Exception(){
        Candidate__c candidate = new Candidate__c(Name='Test Candidate Inserted', Candidate_Email__c='test');
        CandidateTableComponentClass.createCandidateRecord(candidate);
        
        Candidate__c[] candidateList = [SELECT Name FROM Candidate__c WHERE Id =:candidate.Id];
        
        System.assertEquals(0, candidateList.size());
    }
    static testMethod void testDeleteCandidateRecord_Success(){
        Candidate__c candidate = new Candidate__c(Name='Test candidate Deleted', Candidate_Email__c='test@gmail.com');
        insert candidate;
        CandidateTableComponentClass.deleteCandidateRecord(candidate);
        
        System.debug('@@@@' + candidate.id);
        candidate = [SELECT Name, isDeleted FROM Candidate__c WHERE Id =:candidate.Id ALL ROWS];
        
        System.assertEquals(candidate.IsDeleted, true);
    }
    static testMethod void testDeleteCandidateRecord_Exception(){
        Candidate__c candidate = new Candidate__c(Name='Test candidate Deleted', Candidate_Email__c='test@gmail.com');
        //insert candidate;
        CandidateTableComponentClass.deleteCandidateRecord(candidate);
        
        Candidate__c[] candidateList = [SELECT Name, isDeleted FROM Candidate__c WHERE Id =:candidate.Id ALL ROWS];
        
        System.assertEquals(candidateList.size(), 0);
    }
}