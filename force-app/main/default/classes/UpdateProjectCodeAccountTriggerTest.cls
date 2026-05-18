@isTest 
public class UpdateProjectCodeAccountTriggerTest {
    public static testMethod void testAccountDetails(){
        
        User userId1 = [SELECT Id FROM User WHERE Name = 'Selva Pandian' and IsActive=true LIMIT 1];
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account accountObject = new Account(
            Name ='DemandBlue TestClient',// Account Name
            Lead_Gen_Name__c = 'Others',             
            Industry = 'Hospitality',
            Backup_CSM__c=userId1.Id,
            Force_com_Account_Status__c = '7: Customer'
        );
        insert accountObject;
        
        Account accountObject1 = new Account(
            Name ='DemandBlue TestClient',// Account Name
            Lead_Gen_Name__c = 'Others',             
            Industry = 'Hospitality',
            Backup_CSM__c=userId1.Id,
            Force_com_Account_Status__c = '7: Customer'
        );
        insert accountObject1;
        
        try {
            accountObject1.Project_Code__c='123';
            update accountObject1;
            accountObject1.Project_Code__c='124';
            update accountObject1;
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('The project code must be 3 characters long and cannot consist of all numbers.'));
        }
        
        Account accountObject2 = new Account(
            Name ='DemandBlue TestClient',// Account Name
            Lead_Gen_Name__c = 'Others',             
            Industry = 'Hospitality',
            Backup_CSM__c=userId1.Id,
            Force_com_Account_Status__c = '7: Customer'
        );
        insert accountObject2;
        
    }    
}