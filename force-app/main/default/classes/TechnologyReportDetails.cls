global class TechnologyReportDetails {
   
    public static List<string> whIDList = new List<string>();
    public static List<string> whosIDList = new List<string>();
    public static List<string> TasksIDList {get;set;}
    public static List<string> AcclistSearch {get;set;}
    public static List<string> ConlistSearch {get;set;}
    public static List<string> LeadIDList {get;set;}
    public static List<string> OppIDList {get;set;}
    
    public List<Task> tasList {get;set;}
    Public List<Account> accountList{get;set;}
    Public List<Lead> leadList{get;set;}
    Public List<Contact> contactList{get;set;}
    Public List<Opportunity> opportunityList{get;set;}
    Public List<Task> TList{get;set;}
    
    //  public String defaultCheck  {get;set;}
    public String CustomerId {get;set;}
    public String Chec {get;set;}
    
     //Account Pagination porperty
    public Integer PageSize {get;set;}
    public Integer CurrentPage {get;set;}
    public Boolean ShowPrevious {get;set;}
    public Boolean ShowNext {get;set;}
    public String CurrentPageInfo {get;set;}
    public Integer TotalRecords;
    public Integer PageNumber;   
     //Contact Pagination porperty
    public Integer ConTotalRecords;
    public Integer ConCurrentPage{get;set;}
    public Integer ConPageNumber;
    public String  ConCurrentPageInfo {get;set;}
    public Boolean ConShowPrevious {get;set;}
    public Boolean ConShowNext {get;set;}
  
      //Task Pagination Property
    public Integer TaskTotalRecords;
    public Integer TaskCurrentPage{get;set;}
    public Integer TaskPageNumber;
    public String  TaskCurrentPageInfo {get;set;}
    public Boolean TaskShowPrevious {get;set;}
    public Boolean TaskShowNext {get;set;}
    
    
    //Lead Pagination Property
    public Integer LeadTotalRecords;
    public Integer LeadCurrentPage{get;set;}
    public Integer LeadPageNumber;
    public String  LeadCurrentPageInfo {get;set;}
    public Boolean LeadShowPrevious {get;set;}
    public Boolean LeadShowNext {get;set;}
    
    // Opportunity Pagination Property
    public Integer OpportunityTotalRecords;
    public Integer OpportunityCurrentPage{get;set;}
    public Integer OpportunityPageNumber;
    public String  OpportunityCurrentPageInfo {get;set;}
    public Boolean OpportunityShowPrevious {get;set;}
    public Boolean OpportunityShowNext {get;set;}
    
    public TechnologyReportDetails(){
        
        String CustomerId = System.currentPagereference().getParameters().get('getCPQ');
        system.debug('COustemr*'+CustomerId);
        String Sdat =System.currentPagereference().getParameters().get('getsdates');
        system.debug('Sdates***'+Sdat);
        Datetime dt = DateTime.parse(Sdat+' 12:00 AM');
        String Edats =System.currentPagereference().getParameters().get('getedates');
                system.debug('Edats***'+Edats);

        Datetime et = DateTime.parse(Edats+' 11:00 PM');
        string Chec = System.currentPagereference().getParameters().get('defaultChecks');
        
        CustomerId = CustomerId.trim();
        Chec = Chec.trim();
         
             
        if(Chec == 'lmdate'){
           String searchString = '%' + customerid + '%';
        tasList =[SELECT Id,Subject,Technology_Terms_report__c,CreatedDate, LastModifiedDate,WhatId,WhoId  FROM Task WHERE Technology_Terms_report__c Like : searchString And  LastModifiedDate >=: dt And  LastModifiedDate <=: et  ];
           // tasList =[SELECT Id,Subject,Technology_Terms_report__c,CreatedDate, LastModifiedDate,WhatId,WhoId  FROM Task WHERE Technology_Terms_report__c Like '%CustomerId%' And  LastModifiedDate >=: dt And  LastModifiedDate <=: et  ];
        }
        if(Chec == 'cddate'){
            String searchString = '%' + customerid + '%';
            tasList = [SELECT Id,Subject,Technology_Terms_report__c,CreatedDate,LastModifiedDate,WhatId,WhoId FROM Task WHERE  Technology_Terms_report__c Like : searchString  And CreatedDate >=: dt And  CreatedDate <=: et];
            
        }
        system.debug('tasList!!!!!'+tasList);
        
        //  taskslists = new List<Account>();
        accountList = New List<Account>();
        contactList = New List <Contact>();
        opportunityList = New List<Opportunity>();
        TList = New List<Task>();
        leadList = New List<Lead>();
        //List<Task>  tasList = new List<Task> ();
        //  system.debug('Cdate11!!!!!'+defaultCheck);
        /*   if(defaultCheck == 'cddate' && Sdat !=null ){

tasList =[SELECT Id,Subject,Technology_Terms_report__c, WhatId,WhoId  FROM Task WHERE CreatedDate >= 2020-12-08T01:02:03Z And  CreatedDate <= 2021-01-10T01:02:03Z And Technology_Terms_report__c =:message];

}
if(defaultCheck == 'lmdate'){

tasList =[SELECT Id,Subject,Technology_Terms_report__c, WhatId,WhoId  FROM Task WHERE LastModifiedDate >= 2020-12-08T01:02:03Z And  LastModifiedDate <= 2021-01-10T01:02:03Z And Technology_Terms_report__c =:message];
}*/
        //system.debug('Tasklist++++++'+tasList.size());
        for(integer i=0; i < tasList.size(); i++)
        {
            if(tasList[i].WhatId != null  ){
                
                whIDList.add(tasList[i].WhatId);
            }
            if( tasList[i].WhoId != null ){
                
                whosIDList.add(tasList[i].WhoId);
                
                
                //system.debug('whIDList[i].startswith:'+whIDList[i].startswith('001'));
            }
            
            system.debug('whIDList====>'+whIDList);
            system.debug('whosIDList====>'+whosIDList);
        }
        AcclistSearch = new list<string> ();
        for(integer j = 0; j< whIDList.size(); j++){ 
            system.debug('AcclistSearch===1111>'+whIDList[j]);
            if(whIDList[j].startswith('001')){
                
                AcclistSearch.add(whIDList[j]);
                system.debug('AcclistSearch===>'+AcclistSearch);
            }
            
        }
        ConlistSearch = new list<string> ();
        for(integer j = 0; j< whosIDList.size(); j++){ 
            system.debug('ConlistSearch===11>'+ConlistSearch);
            if(whosIDList[j].startswith('003')){
                ConlistSearch.add(whosIDList[j]);
            }
            
        }
        LeadIDList = new list<string> ();
        for(integer j = 0; j< whosIDList.size(); j++){ 
            system.debug('LeadIDList===11>'+LeadIDList);
            if(whosIDList[j].startswith('00Q')){
                LeadIDList.add(whosIDList[j]);
            }
            
        }
        OppIDList = new list<string> ();
        for(integer j = 0; j< whIDList.size(); j++){ 
            system.debug('OppIDList===11>'+OppIDList);
            if(whIDList[j].startswith('006')){
                OppIDList.add(whIDList[j]);
            }
            
            
            
        }
        TasksIDList = new list<string> ();
        for(integer j = 0; j< whIDList.size(); j++){ 
            system.debug('TasksIDList===11>'+TasksIDList);
            if(whIDList[j].startswith('00T')){
                TasksIDList.add(whIDList[j]);
            }
        }
        accountList = [SELECT Account_Status__c ,CreatedDate,Force_com_Account_Status__c,Id,Industry,Name,Owner.Name FROM Account WHERE Id IN : AcclistSearch ];
        contactList = [SELECT Account.Name,CreatedDate,Email,Id,Name,Phone,Status__c FROM Contact WHERE Id IN : ConlistSearch];
        leadList = [SELECT Campaigns_Associated__c,Company,CreatedDate,Email,Id,Name,Status FROM Lead WHERE Id IN : LeadIDList];
        opportunityList  = [SELECT AccountId,CreatedDate,Name,Status__c,StageName FROM Opportunity WHERE Id IN : OppIDList];
        TList =[SELECT Id,Owner.Name,Status,Subject,CreatedDate,Technology_Terms_report__c,WhatId,WhoId FROM Task WHERE Id IN : tasList ];
       
        
        CurrentPage = 0; 
            PageNumber = 1; 
            ShowPrevious = false;
            PageSize = 10;
            if(accountList.size() > 0){
                TotalRecords = accountList.size();  // Total No of records need to display in Grid.   
                if(TotalRecords > PageSize)
                    ShowNext = true;
                else
                    ShowNext = false;       
                CurrentPageInfo = 'Showing Page ' + PageNumber + ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1); 
            }
           
            ConCurrentPage = 0;
            ConPageNumber = 1;
        PageSize = 10;
            if(contactList.size() > 0){
                ConTotalRecords = contactList.size();  // Total No of records need to display in Grid.   
                if(ConTotalRecords > PageSize)
                    ConShowNext = true;
                else
                    ConShowNext = false;       
                ConCurrentPageInfo = 'Showing Page ' + ConPageNumber + ' of ' + (Math.mod(ConTotalRecords, PageSize) == 0 ? ConTotalRecords/PageSize : (ConTotalRecords/PageSize) + 1); 
            }
                     
            TaskCurrentPage = 0;
            TaskPageNumber = 1;
        PageSize = 10;
            
            if(TList.size() > 0){
                TaskTotalRecords = TList.size();  // Total No of records need to display in Grid.   
                if(TaskTotalRecords > PageSize)
                    TaskShowNext = true;
                else
                    TaskShowNext = false;       
                TaskCurrentPageInfo = 'Showing Page ' + TaskPageNumber + ' of ' + (Math.mod(TaskTotalRecords, PageSize) == 0 ? TaskTotalRecords/PageSize : (TaskTotalRecords/PageSize) + 1); 
            }
        
         OpportunityCurrentPage = 0;
            OpportunityPageNumber = 1;
        PageSize = 10;
            
            if(opportunityList.size() > 0){
                OpportunityTotalRecords = opportunityList.size();  // Total No of records need to display in Grid.   
                if(OpportunityTotalRecords > PageSize)
                    OpportunityShowNext = true;
                else
                    OpportunityShowNext = false;       
                OpportunityCurrentPageInfo = 'Showing Page ' + OpportunityPageNumber + ' of ' + (Math.mod(OpportunityTotalRecords, PageSize) == 0 ? OpportunityTotalRecords/PageSize : (OpportunityTotalRecords/PageSize) + 1); 
            }
            LeadCurrentPage = 0;
            LeadPageNumber = 1;
        PageSize = 10;
            
            if(leadList.size() > 0){
                LeadTotalRecords = leadList.size();  // Total No of records need to display in Grid.   
                if(LeadTotalRecords > PageSize)
                    LeadShowNext = true;
                else
                    LeadShowNext = false;       
                LeadCurrentPageInfo = 'Showing Page ' + LeadPageNumber + ' of ' + (Math.mod(LeadTotalRecords, PageSize) == 0 ? LeadTotalRecords/PageSize : (LeadTotalRecords/PageSize) + 1); 
            }
        
        
        
        system.debug('accountList=====>1'+accountList);
        system.debug('ContactList=====>1'+contactList);
        system.debug('LeadList=====>1'+leadList);
        system.debug('Opp=====>1'+opportunityList);
        system.debug('TList=====>1'+TList);
    }
     
            
            
    
     public void showPrevious()
    {
        CurrentPage = CurrentPage- PageSize;
        PageNumber--;
        enableDisablePaginationLinks();     
    }
    
    public void showNext()
    {
        CurrentPage = CurrentPage + PageSize;
        PageNumber++;
        enableDisablePaginationLinks();
    }
    
    public void showFirst()
    {
        CurrentPage = 0;
        PageNumber = 1;
        enableDisablePaginationLinks();
    }
    
    public void showLast()
    {
        CurrentPage = (Math.mod(TotalRecords, PageSize) == 0) ? TotalRecords - PageSize : (TotalRecords / PageSize) * PageSize;
        PageNumber = (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1);
        enableDisablePaginationLinks();
    }
    
    public void enableDisablePaginationLinks()
    {
        if(CurrentPage == 0)
            ShowPrevious = false;
        else    
            ShowPrevious = true; 
        if((TotalRecords - PageSize) <= CurrentPage)
            ShowNext = false;
        else
            ShowNext = true;
        CurrentPageInfo = 'Showing Page ' + PageNumber +   ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1);
    }   
    // Account Pagination logic Ends
    
     // Contact Pagination logic Starts
    
    public void conShowPrevious()
    {
        ConCurrentPage = ConCurrentPage- PageSize;
        ConPageNumber--;
        conEnableDisablePaginationLinks();     
    }
    
    public void conShowNext()
    {
        ConCurrentPage = ConCurrentPage + PageSize;
        ConPageNumber++;
        conEnableDisablePaginationLinks();
    }
    
    public void conShowFirst()
    {
        ConCurrentPage = 0;
        ConPageNumber = 1;
        conEnableDisablePaginationLinks();
    }
    
    public void conShowLast()
    {
        ConCurrentPage = (Math.mod(ConTotalRecords, PageSize) == 0) ? ConTotalRecords - PageSize : (ConTotalRecords / PageSize) * PageSize;
        ConPageNumber = (Math.mod(ConTotalRecords, PageSize) == 0 ? ConTotalRecords/PageSize : (ConTotalRecords/PageSize) + 1);
        conEnableDisablePaginationLinks();
    }
    
    public void conEnableDisablePaginationLinks()
    {
        if(ConCurrentPage == 0)
            ConShowPrevious = false;
        else    
            ConShowPrevious = true; 
        if((ConTotalRecords - PageSize) <= ConCurrentPage)
            ConShowNext = false;
        else
            ConShowNext = true;
        ConCurrentPageInfo = 'Showing Page ' + ConPageNumber +   ' of ' + (Math.mod(ConTotalRecords, PageSize) == 0 ? ConTotalRecords/PageSize : (ConTotalRecords/PageSize) + 1);
    }   
    
    
    // contact Pagination logic Ends
       
      // Task Pagination logic Starts
       public void TaskShowPrevious()
    {
        TaskCurrentPage = TaskCurrentPage- PageSize;
        TaskPageNumber--;
        TaskEnableDisablePaginationLinks();     
    }
    
    public void TaskShowNext()
    {
        TaskCurrentPage = TaskCurrentPage + PageSize;
        TaskPageNumber++;
        TaskEnableDisablePaginationLinks();
    }
    
    public void TaskShowFirst()
    {
        TaskCurrentPage = 0;
        TaskPageNumber = 1;
        TaskEnableDisablePaginationLinks();
    }
    
    public void TaskShowLast()
    {
        TaskCurrentPage = (Math.mod(TaskTotalRecords, PageSize) == 0) ? TaskTotalRecords - PageSize : (TaskTotalRecords / PageSize) * PageSize;
        TaskPageNumber = (Math.mod(TaskTotalRecords, PageSize) == 0 ? TaskTotalRecords/PageSize : (TaskTotalRecords/PageSize) + 1);
        TaskEnableDisablePaginationLinks();
    }
    
    public void TaskEnableDisablePaginationLinks()
    {
        if(TaskCurrentPage == 0)
            TaskShowPrevious = false;
        else    
            TaskShowPrevious = true; 
        if((TaskTotalRecords - PageSize) <= TaskCurrentPage)
            TaskShowNext = false;
        else
            TaskShowNext = true;
        TaskCurrentPageInfo = 'Showing Page ' + TaskPageNumber +   ' of ' + (Math.mod(TaskTotalRecords, PageSize) == 0 ? TaskTotalRecords/PageSize : (TaskTotalRecords/PageSize) + 1);
    }  
    
     // Task Pagination logic Ends 
     
     
     // Lead Pagination logic Starts
       public void LeadShowPrevious() 
    {
        LeadCurrentPage = LeadCurrentPage- PageSize;
        LeadPageNumber--;
        LeadEnableDisablePaginationLinks();     
    }
    
    public void LeadShowNext()
    {
        LeadCurrentPage = LeadCurrentPage + PageSize;
        LeadPageNumber++;
        LeadEnableDisablePaginationLinks();
    }
    
    public void LeadShowFirst()
    {
        LeadCurrentPage = 0;
        LeadPageNumber = 1;
        LeadEnableDisablePaginationLinks();
    }
    
    public void LeadShowLast()
    {
        LeadCurrentPage = (Math.mod(LeadTotalRecords, PageSize) == 0) ? LeadTotalRecords - PageSize : (LeadTotalRecords / PageSize) * PageSize;
        LeadPageNumber = (Math.mod(LeadTotalRecords, PageSize) == 0 ? LeadTotalRecords/PageSize : (LeadTotalRecords/PageSize) + 1);
        LeadEnableDisablePaginationLinks();
    }
    
    public void LeadEnableDisablePaginationLinks()
    {
        if(LeadCurrentPage == 0)
            LeadShowPrevious = false;
        else    
            LeadShowPrevious = true; 
        if((LeadTotalRecords - PageSize) <= LeadCurrentPage)
            LeadShowNext = false;
        else
            LeadShowNext = true;
        LeadCurrentPageInfo = 'Showing Page ' + LeadPageNumber +   ' of ' + (Math.mod(LeadTotalRecords, PageSize) == 0 ? LeadTotalRecords/PageSize : (LeadTotalRecords/PageSize) + 1);
    }  
    
     // Lead Pagination logic Ends 
     
    
      // Opportunity Pagination logic Starts  
      
       public void OpportunityShowPrevious()
    {
        OpportunityCurrentPage = OpportunityCurrentPage- PageSize;
        OpportunityPageNumber--;
        OpportunityEnableDisablePaginationLinks();     
    }
    
    public void OpportunityShowNext()
    {
        OpportunityCurrentPage = OpportunityCurrentPage + PageSize;
        OpportunityPageNumber++;
        OpportunityEnableDisablePaginationLinks();
    }
    
    public void OpportunityShowFirst()
    {
        OpportunityCurrentPage = 0;
        OpportunityPageNumber = 1;
        OpportunityEnableDisablePaginationLinks();
    }
    
    public void OpportunityShowLast()
    {
        OpportunityCurrentPage = (Math.mod(OpportunityTotalRecords, PageSize) == 0) ? OpportunityTotalRecords - PageSize : (OpportunityTotalRecords / PageSize) * PageSize;
        OpportunityPageNumber = (Math.mod(OpportunityTotalRecords, PageSize) == 0 ? OpportunityTotalRecords/PageSize : (OpportunityTotalRecords/PageSize) + 1);
        OpportunityEnableDisablePaginationLinks();
    }
    
    public void OpportunityEnableDisablePaginationLinks()
    {
        if(OpportunityCurrentPage == 0)
            OpportunityShowPrevious = false;
        else    
            OpportunityShowPrevious = true; 
        if((OpportunityTotalRecords - PageSize) <= OpportunityCurrentPage)
            OpportunityShowNext = false;
        else
            OpportunityShowNext = true;
        OpportunityCurrentPageInfo = 'Showing Page ' + OpportunityPageNumber +   ' of ' + (Math.mod(OpportunityTotalRecords, PageSize) == 0 ? OpportunityTotalRecords/PageSize : (OpportunityTotalRecords/PageSize) + 1);
    }  
    
     // Opportunity Pagination logic Ends 
    
}