@isTest
public class Test_updateCampaignMember {
    public static String Localkey ='en_US';
    public static String campaignName ='ODS Force.com';
    public static String status ='calling';
    public static String other ='Others';
    public static String AccountName ='Test Account';
    public static String website ='www.testwebsite.com';
    public static String complete ='Completed';
    public static String Progress ='In Progress';
    public static String Sprint ='Sprint 1';
    public static testmethod void updateCampaignMemberRun(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISR'].Id,
            LastName = 'last',
            
            Email = 'puser00012@amamama.com',
            Username = 'puser00012@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = Localkey,
            LocaleSidKey = Localkey
        );   
        insert u;
        
        User u1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISR'].Id,
            LastName = 'last1',
            
            Email = 'puser0001@amamama.com',
            Username = 'leadgenteam@preludesys.com.test.com1'+ System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = Localkey,
            LocaleSidKey = Localkey,
            DataLoader__c = false
        );   
        insert u1 ;
        
        campaign inserttestcampaign1 = new campaign(name = campaignName);
        insert inserttestcampaign1;
        
        Lead inserttestlead1= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test1','Lead1',other,status,AccountName,website);
        Lead inserttestlead2= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test2','Lead2',other,status,AccountName,website);
        Lead inserttestlead3= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test3','Lead3',other,status,AccountName,website);
        Lead inserttestlead4= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test4','Lead4',other,status,AccountName,website);
        Lead inserttestlead5= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test5','Lead5',other,status,AccountName,website);
        Lead inserttestlead6= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test6','Lead6',other,status,AccountName,website);
        Lead inserttestlead7= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test7','Lead7',other,status,AccountName,website);
        Lead inserttestlead8= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test8','Lead8',other,status,AccountName,website);
        Lead inserttestlead9= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test9','Lead9',other,status,AccountName,website);
        Lead inserttestlead10= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test10','Lead10',other,status,AccountName,website);
        Lead inserttestlead11= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test11','Lead11',other,status,AccountName,website);
        
        
        
        Lead inserttestlead20= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test20','Lead20',other,status,AccountName,website);
        Lead inserttestlead21= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test21','Lead21',other,status,AccountName,website);
        Lead inserttestlead22= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test22','Lead22',other,status,AccountName,website);
        Lead inserttestlead23= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test23','Lead23',other,status,AccountName,website);
        Lead inserttestlead24= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test24','Lead24',other,status,AccountName,website);
        Lead inserttestlead25= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test25','Lead25',other,status,AccountName,website);
        Lead inserttestlead26= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test26','Lead26',other,status,AccountName,website);
        Lead inserttestlead27= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test27','Lead27',other,status,AccountName,website);
        Lead inserttestlead28= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test28','Lead28',other,status,AccountName,website);
        Lead inserttestlead29= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test29','Lead29',other,status,AccountName,website);
        Lead inserttestlead30= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test30','Lead30',other,status,AccountName,website);
        Lead inserttestlead31= EZRE_DataFactory_Test_Utility.createLeadwithcampaignmember('Test31','Lead31',other,status,AccountName,website);
        
        
        task t1 =  new task(); t1.Campaign__c = campaignName; t1.Status = complete;t1.WhoId = inserttestlead1.Id; 
        task t2 =  new task(); t2.Campaign__c = campaignName; t2.Status = complete;t2.WhoId = inserttestlead2.Id; 
        task t3 =  new task(); t3.Campaign__c = campaignName; t3.Status = complete;t3.WhoId = inserttestlead3.Id; 
        task t4 =  new task(); t4.Campaign__c = campaignName; t4.Status = complete;t4.WhoId = inserttestlead4.Id; 
        task t5 =  new task(); t5.Campaign__c = campaignName; t5.Status = complete;t5.WhoId = inserttestlead5.Id; 
        task t6 =  new task(); t6.Campaign__c = campaignName; t6.Status = complete;t6.WhoId = inserttestlead6.Id;
        task t7 =  new task(); t7.Campaign__c = campaignName; t7.Status = complete;t7.WhoId = inserttestlead7.Id; 
        task t8 =  new task(); t8.Campaign__c = campaignName; t8.Status = complete;t8.WhoId = inserttestlead8.Id; 
        task t9 =  new task(); t9.Campaign__c = campaignName; t9.Status = complete;t9.WhoId = inserttestlead9.Id;
        task t10=  new task(); t10.Campaign__c = campaignName; t10.Status = Progress;t10.whoId = inserttestlead10.Id;
        task t11=  new task(); t11.Campaign__c = campaignName; t11.Status = Progress;t11.WhoId = inserttestlead11.Id;
       
        
        task t20 =  new task(); t20.Campaign__c = campaignName; t20.Status = Progress;t20.WhoId = inserttestlead20.Id;
        task t21 =  new task(); t21.Campaign__c = campaignName; t21.Status = Progress;t21.WhoId = inserttestlead21.Id;
        task t22 =  new task(); t22.Campaign__c = campaignName; t22.Status = Progress;t22.WhoId = inserttestlead22.Id;
        task t23 =  new task(); t23.Campaign__c = campaignName; t23.Status = Progress;t23.WhoId = inserttestlead23.Id;
        task t24 =  new task(); t24.Campaign__c = campaignName; t24.Status = Progress;t24.WhoId = inserttestlead24.Id; 
        task t25 =  new task(); t25.Campaign__c = campaignName; t25.Status = Progress;t25.WhoId = inserttestlead25.Id; 
        task t26 =  new task(); t26.Campaign__c = campaignName; t26.Status = Progress;t26.WhoId = inserttestlead26.Id;
        task t27 =  new task(); t27.Campaign__c = campaignName; t27.Status = Progress;t27.WhoId = inserttestlead27.Id; 
        task t28 =  new task(); t28.Campaign__c = campaignName; t28.Status = Progress;t28.WhoId = inserttestlead28.Id; 
        task t29 =  new task(); t29.Campaign__c = campaignName; t29.Status = Progress;t29.WhoId = inserttestlead29.Id;
        task t30 =  new task(); t30.Campaign__c = campaignName; t30.Status = Progress;t30.WhoId = inserttestlead30.Id;
        task t31 =  new task(); t31.Campaign__c = campaignName; t31.Status = Progress;t31.WhoId = inserttestlead31.Id;
        
        CampaignMember newMember1 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead1.Id, Run__c = 'Run 0',sprint__c=Sprint);
        insert newMember1;
        
        CampaignMember newMember2 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead2.Id, Run__c = 'Run 1',sprint__c=Sprint);
        insert newMember2;
        
        CampaignMember newMember3 =  
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead3.Id, Run__c = 'Run 2',sprint__c=Sprint);
        insert newMember3;
        
        CampaignMember newMember4 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead4.Id, Run__c = 'Run 3',sprint__c=Sprint);
        insert newMember4;
        
        CampaignMember newMember5 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead5.Id, Run__c = 'Run 4',sprint__c=Sprint);
        insert newMember5;
        
        CampaignMember newMember6 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead6.Id, Run__c = 'Run 5',sprint__c=Sprint);
        insert newMember6;
        
        CampaignMember newMember7 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead7.Id, Run__c = 'Run 6',sprint__c=Sprint);
        insert newMember7;
        
        CampaignMember newMember8 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead8.Id, Run__c = 'Run 7',sprint__c=Sprint);
        insert newMember8;
        
        CampaignMember newMember9 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead9.Id, Run__c = 'Run 8',sprint__c=Sprint);
        insert newMember9;
        
        CampaignMember newMember10 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead10.Id, Run__c = 'Run 9',sprint__c=Sprint);
        insert newMember10;
        
        CampaignMember newMember20 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead20.Id, Run__c = 'Run 1',sprint__c=Sprint);
        insert newMember20;
        
        CampaignMember newMember21 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead21.Id, Run__c = 'Run 0',sprint__c=Sprint);
        insert newMember21;
        
        CampaignMember newMember22 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead22.Id, Run__c = 'Run 2',sprint__c=Sprint);
        insert newMember22;
        
        CampaignMember newMember23 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead23.Id, Run__c = 'Run 3',sprint__c=Sprint);
        insert newMember23;
 
        
         CampaignMember newMember25 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead25.Id, Run__c = 'Run 4',sprint__c=Sprint);
        insert newMember25;
        
        CampaignMember newMember26 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead26.Id, Run__c = 'Run 5',sprint__c=Sprint);
        insert newMember26;
        
        System.assertEquals(newMember26.Run__c,'Run 5');
        
        CampaignMember newMember27 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead27.Id, Run__c = 'Run 6',sprint__c=Sprint);
        insert newMember27;
        
        CampaignMember newMember28 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead28.Id, Run__c = 'Run 7',sprint__c=Sprint);
        insert newMember28;
        
        CampaignMember newMember29 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead29.Id, Run__c = 'Run 8',sprint__c=Sprint);
        insert newMember29;
        
        CampaignMember newMember30 = 
            new CampaignMember(campaignId = inserttestcampaign1.Id, LeadId = inserttestlead30.Id, Run__c = 'Run 9',sprint__c=Sprint);
        insert newMember30;
       
        
        system.runAs(u){
            
            List<task> tasks = new List<task>();
            tasks.add(t1);
            tasks.add(t2);
            tasks.add(t3);
            tasks.add(t4);
            tasks.add(t5);
            tasks.add(t6);
            tasks.add(t7);
            tasks.add(t8);
             tasks.add(t9);
             tasks.add(t10);
            tasks.add(t11);
            tasks.add(t20);tasks.add(t21);tasks.add(t22);tasks.add(t23);
            tasks.add(t25);tasks.add(t26);tasks.add(t27);
            tasks.add(t28);tasks.add(t29);tasks.add(t30);
            insert tasks;
            tasks.clear();
            update newMember1;
            
            task ut = new task(id=t20.id,Status=complete);
            task ut1 = new task(id=t21.id,Status=complete);
            task ut2 = new task(id=t22.id,Status=complete);
            task ut3 = new task(id=t23.id,Status=complete);
            task ut5 = new task(id=t25.id,Status=complete);
            task ut6 = new task(id=t26.id,Status=complete);
            task ut7 = new task(id=t27.id,Status=complete);
            task ut8 = new task(id=t28.id,Status=complete);
            task ut9 = new task(id=t29.id,Status=complete);
            task ut10 = new task(id=t30.id,Status=complete);
            tasks.add(ut);tasks.add(ut1);tasks.add(ut2);tasks.add(ut3);
            tasks.add(ut5);tasks.add(ut6);tasks.add(ut7);
            tasks.add(ut8);tasks.add(ut9); tasks.add(ut10);
            update tasks;
        }
        
    }
    
    
}