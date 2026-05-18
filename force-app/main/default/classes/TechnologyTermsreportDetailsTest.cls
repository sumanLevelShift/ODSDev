@isTest
public class TechnologyTermsreportDetailsTest {
    
    @isTest
    public static void testMethod1(){
        List<Technology_Terms__mdt> technologyList =[SELECT Label FROM Technology_Terms__mdt];
        List<string> nameList=New List<String>();
        List<Task> taskList=new List<Task>();
        List<Account> acclist =new List<Account>();
        
        List<Lead> leadList = new List<Lead>();
        List<Contact> contactList = new List<Contact>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        
        Account testAccount = new Account();
        testAccount.Name= 'Test Account' ;
        insert testAccount;
        
        Lead myLead = new Lead();
        myLead.FirstName='Harish';
        myLead.LastName ='KK';
        myLead.Company ='AAA';
        insert myLead;
        
        
        Task t1=new Task();
        t1.Subject='test Demo';
        t1.Description='CPQ';
        insert t1;
        t1.Description='FSL';
        update t1;
        
        
        
        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.Accountid= testAccount.id;
        insert cont;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.Accountid = testAccount.id;
        objOpportunity.StageName = 'Prospecting';
        objOpportunity.CloseDate = system.Today()+3;
        insert objOpportunity;
        
        
        integer i=0;
        for(Technology_Terms__mdt s:technologyList){
            nameList.add(s.Label);
            Task t=new Task();
            t.Subject='test '+i;
            t.Description=s.Label;
            t.WhatId  = testAccount.id;
            t.WhoId = cont.Id;
            taskList.add(t);
        }
        
        insert taskList;
        
        
        Test.startTest();
        
        
        PageReference pageRef = Page.TechnologyTermsReportDetails;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('getCPQ','FSL');
        pageRef.getParameters().put('getsdates','01/01/2021');
        pageRef.getParameters().put('getedates','01/20/2021');
        pageRef.getParameters().put('defaultChecks','cddate');
        
        TechnologyReportDetails obj=new TechnologyReportDetails(); 
        
        obj.PageNumber = 1; 
        obj.PageSize = 10;
        obj.TotalRecords = acclist.size();
        obj.showPrevious();
        obj.showNext();
        obj.showFirst();
        obj.showLast();
        obj.ConCurrentPage = 0; 
        obj.conPageNumber = 1; 
        obj.PageSize = 10;
        obj.conTotalRecords = contactList.size();     
        obj.conshowPrevious();
        obj.conshowNext();
        obj.conshowFirst();
        obj.conshowLast();
        obj.TaskCurrentPage = 0; 
        obj.TaskPageNumber = 1; 
        obj.PageSize = 10;
        obj.TaskTotalRecords = Tasklist.size();
        //obj.getSearchResult();
        obj.TaskshowPrevious();
        obj.TaskshowNext();
        obj.TaskshowFirst();
        obj.TaskshowLast();
        obj.TaskenableDisablePaginationLinks();
        
        
        
        obj.LeadCurrentPage = 0;
        obj.LeadPageNumber = 1;
        obj.PageSize = 10;
        obj.LeadTotalRecords = leadList.size();
        
        obj.LeadShowPrevious();
        obj.LeadShowNext();
        obj.LeadShowFirst();
        obj.LeadShowLast();
        obj.LeadEnableDisablePaginationLinks();
        
        obj.OpportunityPageNumber = 1;
        obj.OpportunityCurrentPage = 0;
        obj.OpportunityTotalRecords = opportunityList.size();
        obj.PageSize = 10;
        obj.OpportunityShowFirst();
        obj.OpportunityShowLast();
        obj.OpportunityShowNext();
        obj.OpportunityShowPrevious();
        obj.OpportunityEnableDisablePaginationLinks();
        
        
        
        
        //obj.CustomerId=nameList;
        //obj.dt=system.today()-9;
        // obj.dats=system.today()+2;
        obj.Chec='lmdate';
        obj.Chec='cddate';
        // obj.getItems();
        // obj.search();
        Test.stopTest();
        system.assertEquals(taskList.size(), technologyList.size());
    }
    
}