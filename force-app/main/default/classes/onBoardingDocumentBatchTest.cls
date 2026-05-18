@isTest(SeeAllData=true)
public class onBoardingDocumentBatchTest {
    @isTest
    public static void batchOnBoarding(){
        List<ClientAndNamedCredMapping__mdt> clientandNameCred1=[SELECT Account_Id__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c !=:null and Account_Id__c !=:'NOT_FOUND' and Account_Id__c !=:'NEW' AND In_progress__c=false Limit 1];
        if(!clientandNameCred1.isEmpty()){
            database.executeBatch(new onBoardingDocumentBatch(clientandNameCred1[0].Account_Id__c));
            onBoardingDocumentAPIHelper obj=new onBoardingDocumentAPIHelper();
            obj.getNamedCredForClient(clientandNameCred1[0].Account_Id__c);
        }
    }
}