@isTest
public class GoogleAlertToChatterStatusChange_Test {
    public static testmethod void triggerTestMthd(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Account a = new account();
        a.Name = 'Salesforce';
        a.BillingCity = 'Tx';
        a.BillingState = 'AT';
        a.BillingCountry = 'Us';
        a.AnnualRevenue = 1000;
        a.NumberOfEmployees = 50;
        a.Industry = 'Banking';
        a.Phone = '112233';
        a.Website = 'www.test.com';
        a.Lead_Gen_Name__c = 'Others';
        a.If_Others_Please_Specify__c = 'contact';
        a.SOW__c='Fully Executed';
        a.Created_Childs_Automatically__c= False;
        a.customer_engagement_type__c= 'ODS';
        a.Account_Status__c= 'Customer';
        a.User__c = userinfo.getUserId();
        system.debug('********User'+a.User__c);
        a.Google_Alerts_to_Chatter_Status__c='Sign Up';
        insert a;
        a.Google_Alerts_to_Chatter_Status__c='Cancel';
        update a;
     
        Contact con = new Contact();
        con.LastName='TestLast';
        con.FirstName='TestFirst';
        con.AccountId=a.id;
        con.Lead_Gen_Name__c='David';
        insert con;
        ODS_Services__c objSrvce = new ODS_Services__c();
        objSrvce.name__c='SalesForce';
        insert objSrvce;
        User_Account__c objusrAcnt = new User_Account__c();
        objusrAcnt.Account__c=a.id;
        objusrAcnt.User__c=UserInfo.getUserId();
        objusrAcnt.ODS_Services__c=objSrvce.id;
        insert objusrAcnt;
        Account_Services__c objAcntSvce = new Account_Services__c();
        objAcntSvce.Payment_Terms__c='Net 30';
        objAcntSvce.Billing_Frequency__c='Weekly';            
        objAcntSvce.ODS_Hourly_Rate_Amount__c=99;
        objAcntSvce.Retainer_Fee_Frequency_Type__c='Monthly';
        objAcntSvce.Retainer_Fee_Amount__c=999;
        objAcntSvce.Type_of_Engagement__c='ODS';
        objAcntSvce.ODS_Services__c=objSrvce.id;
        objAcntSvce.Account__c=a.id;
        objAcntSvce.Technical_Account_manager__c=UserInfo.getUserId();
        objAcntSvce.Document_Suffix__c='Testttt';
        insert objAcntSvce;
        
        a.Primary_Customer_Contact__c=con.Id;
        system.debug('***********User'+a.Primary_Customer_Contact__c);
        a.BillingCity = 'AZ';
        a.Website='www.google.com';
        update a;
        
        Account objAcnt = new Account();
        objAcnt.name='TetsAcnt';
        insert objAcnt;
        objAcnt.Website='www.google.com';
        
        try{
        update objAcnt;
        
        }catch(Exception e){
        }
        
        delete a;
    }
}