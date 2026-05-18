@isTest
public class KickoffRestApiTest {
    @isTest
    public static void updateKickOff(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account accountObject = new Account(
            Name ='Demand Blue CLient1',// Account Name
            Lead_Gen_Name__c = 'Others',             
            Industry = 'Hospitality',
            Project_Code__c ='GHT',
            Customer_Type__c= 'ABC Type'
        );
        insert accountObject;
        KickoffRestApi.updateKickOff(accountObject.Id, 'Completed', Date.today());

    }
    
}