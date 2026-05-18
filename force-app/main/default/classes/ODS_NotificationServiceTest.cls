@isTest(SeeAllData=true)
private class ODS_NotificationServiceTest {
    
    @isTest
    private static void odsNotificationServiceMethod(){        
        string title = 'New Initiative Submitted for Approval';
        string message = ' Please <a href="" target="_blank">click here</a> to view the initiative.';
        string notificationName = 'New Initiative';
        String notificationTypeId = '0ML7i000000CbqDGAS';
        set <String> recipientId = new set <String>();
        recipientId.add('0051W000004hGq0QAE');
        
        string accName='Demandblue Deployment Record';
        Account acc = [SELECT Id FROM Account WHERE Name =:accName];
        
        Account_Services__c accse = [SELECT Account__c,Id FROM  Account_Services__c where Account__c =: acc.Id ];      
                
        Test.startTest();
        
        ODS_NotificationService.NotificationServiceRequest serviceRequest = new ODS_NotificationService.NotificationServiceRequest();
        serviceRequest.accountServiceId = accse.Id;
        serviceRequest.message = message;
        serviceRequest.notificationName = notificationName;
        serviceRequest.title = title;

        ODS_NotificationService obj=new ODS_NotificationService(serviceRequest);

        Boolean result = true;

        try{
        obj.notifyUsers(notificationTypeId,recipientId);       
        }catch(Exception e){
            result = false;
        }

        System.assertEquals(true, result);
        
        Test.stopTest();
    }  
}