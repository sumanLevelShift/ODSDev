public class Dennemeyer_POC {
    @AuraEnabled    
    public static Id saveQuestionsToDB(){
        Property__c newProperty= new Property__c(Name='Test Property', Beds__c=2);
        insert newProperty;
        return newProperty.Id;
    }
    @AuraEnabled    
    public static Boolean deleteQuestionsFromDB(String propId){
        Property__c newProperty= [SELECT Id FROM Property__c WHERE ID=:propId];
        delete newProperty;
        return true;
    }
    @AuraEnabled  
    public static List<ContentDocument> getFiles(string recordId){ 
        // TO avoid following exception 
        // System.QueryException: Implementation restriction: ContentDocumentLink requires
        // a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or 
        // multiple Id's using the IN operator.
        // We have to add sigle record id into set or list to make SOQL query call
        Set<Id> recordIds=new Set<Id>{recordId};
        Set<Id> documentIds = new Set<Id>(); 
        System.debug('%%%%%%%%%%%%%%%recordIds%%%%%%%%%%' + recordIds);
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        List<ContentDocument> test = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];
        System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%' + test);
        return test;  
    } 
    @AuraEnabled  
    public static void deleteFiles(string sdocumentId){ 
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId];       
    } 
}