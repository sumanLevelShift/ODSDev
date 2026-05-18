@isTest
public class ODS_WorkorderDetailsController_Test {
    
    public static testmethod void methodName(){
        
        List<String> lAcc = new List<String>();  
        Contact con = new Contact();
        String campaignName =  System.Label.LeadInfo_Campaign_Name;
        List<Campaign> campaigns = [SELECT ID FROM Campaign WHERE Name =:campaignName]; 
        if(campaigns.size() <= 0 ){	
            Campaign camp = new Campaign();
            camp.Name = campaignName;
            insert camp;
        }
        Account a = new Account(Name = 'Test',Customer_Engagement_Type__c='ODS',Account_Status__c='Customer',Backup_CSM__c =UserInfo.getUserId(),Lead_Gen_Name__c ='Kevin', User__c=UserInfo.getUserId());
        insert a;        
        lAcc.add(a.id);
        
        con.FirstName='Test1';
        con.lastname = 'test';
        con.AccountID  = a.id;
        con.Email='test@testmail.com';
        insert con;
        
         
        
        Account a1 = new Account(id=a.id,Name = 'Test1',Customer_Engagement_Type__c='ODS',Account_Status__c='Customer',User__c=UserInfo.getUserId(),Primary_Customer_Contact__c=con.id);
        update a1;
        lAcc.add(a1.id);

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
        ODS_WorkOrderSettings__c objStng = new ODS_WorkOrderSettings__c();
        objStng.name='SFDC';
        objStng.Account_Partner_Name__c='Test';
        objStng.Billing_Frequency__c='Weekly';
        objStng.Bill_Rate__c=1000;
        objStng.Execution_Partner_Name__c='TestPrtnr';
        objStng.LCA_Required__c=True;
        objStng.Payment_Terms__c='Net 30';
        objStng.Project_Sub_Category__c='TestCat';
        objStng.Project_Type__c='ODS';
        objStng.Subscription_Fee__c=10000;
        objStng.Subscription_Fee_Frequency__c='High';
        objStng.Work_Order_Category__c='TestCat';
        objStng.Work_Order_Head__c='TestHead';        
        insert objStng;
        List<string> lstStng = new List<string>();
        lstStng.add('11aa');
        lstStng.add('22bb');
        ODS_WorkorderDetailsController obj = new ODS_WorkorderDetailsController(new ApexPages.StandardController(a));
        ODS_WorkorderDetailsController.SendWorkOrderEmail(lstStng);
        
        Test.startTest();
        PageReference pageRef = Page.ODS_Workorder_Details;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',a.id);
        Test.stopTest();
        ODS_WorkorderDetailsController.SendWorkOrderEmail(lAcc);
    }
}