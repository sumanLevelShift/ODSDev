@isTest
public class ODS_CustomNotificationTest {
    @isTest
    public static  void ODS_CustomNotificationMethod()
    {
      
        set <String> recipients = new set <String>();
        recipients.add('0051W000004hGq0QAE');
        ODS_CustomNotification.NotificationRequest n=new ODS_CustomNotification.NotificationRequest();
        n.title = 'New Initiative Submitted for Approval';
        n.message = 'Please <a href="" target="_blank">click here</a> to view the initiative.';
        n.targetId = 'a3R7i0000001gRFEAY';
        n.notificationTypeId = '0ML7i000000CbqDGAS';
        n.targetPageRef = 'standard__recordPage';
      
        Test.startTest();
        
        ODS_CustomNotification.notifyUsers(n,recipients);
        
        Test.stopTest();
    }
  
}