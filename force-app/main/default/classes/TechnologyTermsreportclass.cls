public class TechnologyTermsreportclass {
    public Date dat {get;set;}
    public Date dats {get;set;}
    public Boolean selected {get; set;}
    public static String cddate  {get;set;}
    public static String lmdate  {get;set;}
    public String searchCategory {get;set;}
    public List<Technology_Group_Term__mdt> listEmpSettings {get;set;}
    public List<string> listEmp {get;set;}
    public integer cpqCount {get;set;}
    public integer fslCount {get;set;}
    public integer fcCount {get;set;}
    public integer eaCount {get;set;}
    public String defaultCheck  {get;set;}
    public List<SearchStringCount> listSearchCount {get;set;}
    public static List<string> whIDList = new List<string>();
    public static List<string> whosIDList = new List<string>();
    
    
    
    public TechnologyTermsreportclass() {
        
        listEmpSettings = [SELECT Id,MasterLabel FROM Technology_Group_Term__mdt];
        system.debug('listEmpSettings111'+listEmpSettings);
        defaultCheck  = 'cddate';
        listSearchCount = new List<SearchStringCount>();
       // sampleing();
        
    }
    
    public List<SelectOption> getItems() {
        
        List<SelectOption> options = new List<SelectOption>();
        for(Technology_Group_Term__mdt  typ : listEmpSettings){
            
            options.add(new SelectOption(typ.MasterLabel,typ.MasterLabel ));
            
        }
        return options;
       
    }
    
    public PageReference search() {
        List<Task>  tastList = new List<Task> ();
        List <Task> listsoftasks = new List<Task>();
        listSearchCount = new List<SearchStringCount>();
        system.debug('defaultCheck'+listSearchCount.size());
        system.debug('defaultCheck'+dat);
        
        if(defaultCheck == 'cddate' && dat !=null ){
            
            //tastList =[SELECT Id,Subject,Technology_Terms_report__c, WhatId,WhoId  FROM Task WHERE CreatedDate >=: dat And  CreatedDate <=: dats And Technology_Terms_report__c IN :listEmp   ];
                       
            tastList =[SELECT Id,Subject,Technology_Terms_report__c, WhatId,WhoId  FROM Task WHERE CreatedDate >=: dat And  CreatedDate <=: dats And (Technology_Terms_report__c Like '%CPQ%' OR Technology_Terms_report__c Like '%Financial Services Cloud%' OR Technology_Terms_report__c Like '%Field Service Lightning%' OR Technology_Terms_report__c Like '%Einstein Analytics%')];
            //listsoftasks =[SELECT Id,Subject,Technology_Terms_report__c, WhatId,WhoId  FROM Task WHERE CreatedDate >=: dat And  CreatedDate <=: dats And Technology_Terms_report__c Like '%Field Service Lightning%'];
           //tastList.addall(listsoftasks);
    
        }
        if(defaultCheck == 'lmdate'){
            
            //tastList =[SELECT Id,Subject,Technology_Terms_report__c, WhatId,WhoId  FROM Task WHERE LastModifiedDate >=: dat And  LastModifiedDate <=: dats And Technology_Terms_report__c IN :listEmp  ];
                   tastList =[SELECT Id,Subject,Technology_Terms_report__c, WhatId,WhoId  FROM Task WHERE CreatedDate >=: dat And  CreatedDate <=: dats And (Technology_Terms_report__c Like '%CPQ%' OR Technology_Terms_report__c Like '%Financial Services Cloud%' OR Technology_Terms_report__c Like '%Field Service Lightning%' OR Technology_Terms_report__c Like '%Einstein Analytics%')];

        }
        
                system.debug('tastList'+tastList);

        integer i=0 ;
        cpqCount = 0;
        fslCount = 0;
        fcCount = 0;
        eaCount = 0;
        
        for(Task taskValue : tastList){
            if(taskValue.Technology_Terms_report__c != null){
                
                if(taskValue.Technology_Terms_report__c.contains('CPQ')){
                    
                
              //  if(taskValue.Technology_Terms_report__c =='CPQ'){
                    // taskslists =[SELECT Id,Subject,Technology_Terms_report__c, WhatId,WhoId  FROM Task];
                    cpqCount = cpqCount + 1;
                    system.debug('defaultCheck'+cpqCount);
                }
                  if(taskValue.Technology_Terms_report__c.contains('Field Service Lightning')){
                    
                    fslCount = fslCount + 1;
                     system.debug('fslCount'+fslCount);
                }
                                if(taskValue.Technology_Terms_report__c.contains('Financial Services Cloud')){

                 // if(taskValue.Technology_Terms_report__c =='Financial Services Cloud' || taskValue.Technology_Terms_report__c =='FSC' ){
                    
                    fcCount = fcCount + 1;
                }
                
                  if(taskValue.Technology_Terms_report__c.contains('Einstein Analytics')){
                    
                    eaCount = eaCount + 1;
                }
            }
        }
        for(String TermValue :listEmp ){
            system.debug('TermValue'+TermValue);
            if(TermValue == 'CPQ'){
                
                SearchStringCount SearchCount = new SearchStringCount();
                SearchCount.SearchString = 'CPQ';
                SearchCount.StringCount = cpqCount;
                listSearchCount.add(SearchCount);
            }
            if(TermValue == 'Field Service Lightning'){
                SearchStringCount SearchCount = new SearchStringCount();
                SearchCount.SearchString = 'Field Service Lightning';
                SearchCount.StringCount = fslCount;
                listSearchCount.add(SearchCount);
            }
            if(TermValue == 'FSL'){
                SearchStringCount SearchCount = new SearchStringCount();
                SearchCount.SearchString = 'FSL';
                SearchCount.StringCount = fslCount;
                listSearchCount.add(SearchCount);
            }
            if(TermValue == 'Financial Services Cloud'){
                SearchStringCount SearchCount = new SearchStringCount();
                SearchCount.SearchString = 'Financial Services Cloud';
                SearchCount.StringCount = fcCount;
                listSearchCount.add(SearchCount);
            }
            if(TermValue == 'Einstein Analytics'){
                SearchStringCount SearchCount = new SearchStringCount();
                SearchCount.SearchString = 'Einstein Analytics';
                SearchCount.StringCount = eaCount;
                listSearchCount.add(SearchCount);
            }
        }
        // sampleing();
        
        return null;
    }
    public class SearchStringCount {
        public String SearchString {get; set;}        
        public integer StringCount {get; set;}
        
    }
    
    public pagereference reDirecttoCustomer()
    {
        string CustomerId = System.currentPageReference().getParameters().get('getCPQ');
        
        string Sdat = System.currentPagereference().getParameters().get('getsdates');
        
        string Edats = System.currentPagereference().getParameters().get('getedates');
        
        string Chec  = System.currentPagereference().getParameters().get('defaultChecks');
        
        PageReference loginpageRef = new PageReference('/apex/TechnologyTermsReportDetails?getCPQ='+CustomerId+'&getsdates='+Sdat+'&getedates='+Edats+'&defaultChecks='+Chec);
        loginpageRef.setRedirect(true);
        return loginpageRef;               
    } 
    
    
    
}