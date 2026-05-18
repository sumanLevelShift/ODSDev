@isTest
private class LeadInfoScoreAccountTest {
    testmethod static void userCreationTest(){
        Campaign camp = new Campaign(Name = 'ODSTest force.com');
        insert camp;
        Lead led= new Lead(firstName='test Lead FN',lastname = 'test Lead',website='www.levelshift.com',company='Levelshift');
        insert led;
        CampaignMember campMem = new CampaignMember(LeadId = led.Id,CampaignId= camp.Id);
        Insert campMem;
        Account acc = new Account(name='test acc',website='www.levelshift.com',Lead_Gen_Name__c ='Others',Industry='Education');
        insert acc;
        Contact con = new Contact(accountid=acc.id,Lead_Gen_Name__c ='Others',firstName='test con fn',lastname='test con',email='testMail@gmail.com');
        insert con;
        acc.Website= 'www.levelshift.com';
        update acc;
        System.assertEquals('www.levelshift.com', acc.Website,'Acc website');
        Web_Page_Category__c webPageCategory = new Web_Page_Category__c(Name='Service Pages',Points__c = 10);
        insert webPageCategory;
        Website_Page__c webPage = new Website_Page__c(Name = '/',Page_URL__c='/',Page_Category__c =webPageCategory.Id );
        insert webPage;
        LeadinfoWebsiteVisits__c leadInfoWebRecord = new LeadinfoWebsiteVisits__c(Name = 'Website visit 25-07-2022 at 09:29 (Leadinfo)',PageViews__c = 7,Duration__c='6s',Points__c=0,Account__c=acc.Id,Pages__c='<table style="width: 100%;"><tr><td colspan="1" rowspan="1">09:29</td><td colspan="1" rowspan="1"><a target="_blank" href="https://www.levelshift.com/">/</a></td><td colspan="1" rowspan="1">5s</td></tr><tr><td colspan="1" rowspan="1">09:22</td><td colspan="1" rowspan="1"><a target="_blank" href="https://www.levelshift.com/">/</a></td><td colspan="1" rowspan="1">55s</td></tr><tr><td colspan="1" rowspan="1">09:11</td><td colspan="1" rowspan="1"><a target="_blank" href="https://www.levelshift.com/">/</a></td><td colspan="1" rowspan="1">55s</td></tr><tr><td colspan="1" rowspan="1">09:06</td><td colspan="1" rowspan="1"><a target="_blank" href="https://www.levelshift.com/?customize_changeset_uuid=f0625d14-4f24-4e90-a58e-d9f0d011b429&amp;customize_theme=divi-child&amp;customize_messenger_channel=preview-0">/</a></td><td colspan="1" rowspan="1">15s</td></tr><tr><td colspan="1" rowspan="1">09:02</td><td colspan="1" rowspan="1"><a target="_blank" href="https://www.levelshift.com/">/</a></td><td colspan="1" rowspan="1">25s</td></tr><tr><td colspan="1" rowspan="1">09:02</td><td colspan="1" rowspan="1"><a target="_blank" href="https://www.levelshift.com/">/</a></td><td colspan="1" rowspan="1">5s</td></tr><tr><td colspan="1" rowspan="1">09:01</td><td colspan="1" rowspan="1"><a target="_blank" href="https://www.levelshift.com/">/</a></td><td colspan="1" rowspan="1">15s</td></tr></table>');
        insert leadInfoWebRecord;
        List<Lead> webLeads = [SELECT ID, Lead_Info_Score__c,website FROM Lead WHERE Website =:acc.Website and status != 'Qualified'];
        System.debug('Webleads size ' + webLeads.size());
        for(Lead webLead :webLeads){
            System.debug('Lead website ' + webLead.website);
        }
        
        
       
       CampaignMember campMem1 = new CampaignMember(ContactId = con.Id,CampaignId= camp.Id);
        Insert campMem1;
        
        Test.startTest();
        
        Test.stopTest();
    }
}