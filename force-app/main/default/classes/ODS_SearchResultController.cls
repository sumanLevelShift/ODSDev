/*******************************************************************************************
* @author           Gireesh and Prasanna
* @version          1.0 
* @Status           Development Completed
* @Class Name       ODS_SearchResultController
* @description      This is the class For ODS_SearchResult Page
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	10 AUG 2020    	DemandBlue 		Initial Development
*********************************************************************************************/
global class ODS_SearchResultController{
    
    Public List<Contact> contactList{get;set;}
    Public List<Account> accountList{get;set;}
    Public List<Initiatives__c> initiativeList {get;set;} 
    Public List<Time_Sheet_Details__c> timesheetList {get;set;} 
    Public List<Status_Report__c> statusReportList {get;set;} 
    Public List<Task> taskList {get;set;} 
    Public String searchString {get;set;}
    Public String AccountId {get;set;}
    public string ServiceID {get;set;}  
    public string CurrentUserName {get;set;}
    
    //Redirection property
    public string CurrenInitiativeId {get;set;}
    public string AccountServiceID {get;set;} 
    public string CurrenTimesheetId {get;set;}
    public string WorkDayParam{get;set;}
    
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
    
    //Initiative Pagination Property
    public Integer InitTotalRecords;
    public Integer InitCurrentPage{get;set;}
    public Integer InitPageNumber;
    public String  InitCurrentPageInfo {get;set;}
    public Boolean InitShowPrevious {get;set;}
    public Boolean InitShowNext {get;set;}
    
    //Timesheet Pagination Property
    public Integer TsTotalRecords;
    public Integer TsCurrentPage{get;set;}
    public Integer TsPageNumber;
    public String  TsCurrentPageInfo {get;set;}
    public Boolean TsShowPrevious {get;set;}
    public Boolean TsShowNext {get;set;}
    
    //Status Report Pagination Property
    public Integer SrTotalRecords;
    public Integer SrCurrentPage{get;set;}
    public Integer SrPageNumber;
    public String  SrCurrentPageInfo {get;set;}
    public Boolean SrShowPrevious {get;set;}
    public Boolean SrShowNext {get;set;}
    
    //Task Pagination Property
    public Integer TaskTotalRecords;
    public Integer TaskCurrentPage{get;set;}
    public Integer TaskPageNumber;
    public String  TaskCurrentPageInfo {get;set;}
    public Boolean TaskShowPrevious {get;set;}
    public Boolean TaskShowNext {get;set;}
    
    Public ODS_SearchResultController(){
        string searchText = System.CurrentPageReference().getparameters().get('searchText'); 
        string accountIdFromURL = System.CurrentPageReference().getparameters().get('accntId');
        system.debug('===searchText==='+searchText);
        system.debug('===accntId==='+accountIdFromURL);        
        if(searchText != null){
            searchString = searchText;
        }
        else{
            searchString = '';
        }  
        if(accountIdFromURL != null){
            AccountId = accountIdFromURL;
        }else{
            AccountId = 'All';
        }
        ServiceID = 'All';
        //CurrentUserName = UserInfo.getName();                ///ServiceId = sessiondata[0].Service_Id__c; 
        getSearchResult();
    }					
    Public void getSearchResult(){
        contactList = New List<contact>();
        accountList = New List<account>();
        initiativeList = New List<Initiatives__c>();
        timesheetList = New List<Time_Sheet_Details__c>();
        statusReportList = New List<Status_Report__c>();
        taskList = New List<Task>();
        try
        {
        if(searchString != null && searchString.length() > 1){           
            String searchStringNew = '*'+searchString+'*';
            String searchStringNew1 = '\'%'+searchString+'%\'';
            String searchQuery = '';
            //id selectedAccount = AccountId == 'All'? '' : Id.valueOf(AccountId);//('0013D00000eovTaQAI');
            //AccountId = 'All1';
            If(AccountId == 'All'){
                searchQuery = 'FIND \'' + searchStringNew + '\' IN ALL FIELDS RETURNING  Account (Id,Name,Account_Status__c,ParentId,Force_com__c,Backup_CSM__r.Email,Backup_CSM__r.Phone,Force_com_Account_Status__c,Backup_CSM__r.Name,' +
                    'ODS_AWS__c,ODS_AWS_Account_Status__c,type),Contact(name,AccountId,Phone,email,Lead_Gen_Name__c,Status__c,AccountID_formula__c),Initiatives__c(Id,Name,Account_Service__c,AccountServiceId_formula__c,Status__c,Account_Name__c),' + 
                    'Timesheet__c(Id,Name,Account_Services__c,TimeSheet_formulaID__c,Approver_Name__c,Status__c,Week_End_Date__c,Week_Start_Date__c,Total_Hours__c),'+
                    'Status_Report__c(Id,Name,Account_Services__c,Status__c,Status_Date__c,Issues_and_Concerns__c,Work_For_The_Day__c,Work_For_The_Next_Day__c),'+
                    'Task(Id,Subject,OwnerId,AccountId,Status,Owner.name,Account.name)';
            }
            else{
                id selectedAccount = Id.valueOf(AccountId);//('0013D00000eovTaQAI');
                //Account_Services__c accountService = [SELECT Id, Account__c, ODS_Services__c, ODS_Services__r.Name__c, Type_of_Engagement__c from Account_Services__c where id in ('a283D000000BSSYQA4') Limit 1];
                List<ID> AccountServiceID = new List<ID>();
                for(Account_Services__c ASId : [select id from Account_Services__c where Account__c =: selectedAccount]){
                    AccountServiceID.add(ASId.id);
                }
                
                searchQuery = 'FIND \'' + searchStringNew + '\' IN ALL FIELDS RETURNING  Account (Id,Name,Account_Status__c,ParentId,Force_com__c,Backup_CSM__r.Email,Backup_CSM__r.Phone,Force_com_Account_Status__c,Backup_CSM__r.Name,' +
                    'ODS_AWS__c,ODS_AWS_Account_Status__c,type WHERE id in (\''+selectedAccount +'\')),Contact(name,AccountId,AccountID_formula__c,Phone,email,Lead_Gen_Name__c,'+
                    'Status__c WHERE AccountId in (\''+selectedAccount +'\')),Initiatives__c(Id,Name,Account_Service__c,AccountServiceId_formula__c,Status__c,Account_Name__c WHERE Account_Service__c in : AccountServiceID),' + 
                    'Timesheet__c(Id,Name,Account_Services__c,TimeSheet_formulaID__c,Approver_Name__c,Status__c,Week_End_Date__c,Week_Start_Date__c,Total_Hours__c WHERE Account_Services__c in : AccountServiceID),'+
                    'Status_Report__c(Id,Name,Account_Services__c,Status__c,Status_Date__c,Issues_and_Concerns__c,Work_For_The_Day__c,Work_For_The_Next_Day__c WHERE Account_Services__c in : AccountServiceID),'+
                    'Task(Id,Subject,OwnerId,AccountId,whatid,Status,Owner.name,Account.name WHERE whatid  in (\''+selectedAccount +'\'))';
                
            }	
            List<List <sObject>> searchList = search.query(searchQuery);
            accountList = (List<Account>)searchList[0];
            CurrentPage = 0; 
            PageNumber = 1; 
            ShowPrevious = false;
            PageSize = integer.valueof(System.Label.PageSize); // No. of rows per page
            if(accountList.size() > 0){
                TotalRecords = accountList.size();  // Total No of records need to display in Grid.   
                if(TotalRecords > PageSize)
                    ShowNext = true;
                else
                    ShowNext = false;       
                CurrentPageInfo = 'Showing Page ' + PageNumber + ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1); 
            }
            contactList  = (List<Contact>)searchList[1];
            ConCurrentPage = 0;
            ConPageNumber = 1;
            if(contactList.size() > 0){
                ConTotalRecords = contactList.size();  // Total No of records need to display in Grid.   
                if(ConTotalRecords > PageSize)
                    ConShowNext = true;
                else
                    ConShowNext = false;       
                ConCurrentPageInfo = 'Showing Page ' + ConPageNumber + ' of ' + (Math.mod(ConTotalRecords, PageSize) == 0 ? ConTotalRecords/PageSize : (ConTotalRecords/PageSize) + 1); 
            }
            initiativeList = (List<Initiatives__c>)searchList[2];
            InitCurrentPage = 0;
            InitPageNumber = 1;
            if(initiativeList.size() > 0){
                InitTotalRecords = initiativeList.size();  // Total No of records need to display in Grid.   
                if(InitTotalRecords > PageSize)
                    InitShowNext = true;
                else
                    InitShowNext = false;       
                InitCurrentPageInfo = 'Showing Page ' + InitPageNumber + ' of ' + (Math.mod(InitTotalRecords, PageSize) == 0 ? InitTotalRecords/PageSize : (InitTotalRecords/PageSize) + 1); 
            }
            timesheetList = getTimeSheetDetails((List<Timesheet__c>)searchList[3]);
            TsCurrentPage = 0;
            TsPageNumber = 1;        
            if(timesheetList.size() > 0){
                TsTotalRecords = timesheetList.size();  // Total No of records need to display in Grid.   
                if(TsTotalRecords > PageSize)
                    TsShowNext = true;
                else
                    TsShowNext = false;       
                TsCurrentPageInfo = 'Showing Page ' + TsPageNumber + ' of ' + (Math.mod(TsTotalRecords, PageSize) == 0 ? TsTotalRecords/PageSize : (TsTotalRecords/PageSize) + 1); 
            }
            statusReportList = (List<Status_Report__c>)searchList[4];
            SrCurrentPage = 0;
            SrPageNumber = 1;
            
            if(statusReportList.size() > 0){
                SrTotalRecords = statusReportList.size();  // Total No of records need to display in Grid.   
                if(SrTotalRecords > PageSize)
                    SrShowNext = true;
                else
                    SrShowNext = false;       
                SrCurrentPageInfo = 'Showing Page ' + SrPageNumber + ' of ' + (Math.mod(SrTotalRecords, PageSize) == 0 ? SrTotalRecords/PageSize : (SrTotalRecords/PageSize) + 1); 
            }
            taskList = (List<Task>)searchList[5];
            
            TaskCurrentPage = 0;
            TaskPageNumber = 1;
            
            if(taskList.size() > 0){
                TaskTotalRecords = taskList.size();  // Total No of records need to display in Grid.   
                if(TaskTotalRecords > PageSize)
                    TaskShowNext = true;
                else
                    TaskShowNext = false;       
                TaskCurrentPageInfo = 'Showing Page ' + TaskPageNumber + ' of ' + (Math.mod(TaskTotalRecords, PageSize) == 0 ? TaskTotalRecords/PageSize : (TaskTotalRecords/PageSize) + 1); 
            }
            
            
            
            if(accountList.size() == 0 && contactList.size() == 0 && initiativeList.size() == 0 && timesheetList.size() == 0 && statusReportList.size() == 0 && taskList.size() == 0){
                apexPages.addmessage(new apexpages.message(apexpages.severity.INFO, 'Sorry, no results returned with matching string..'));
                return;
            }
        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters in the search box..'));
            return;
        }
       	}
        catch(Exception objException)
        {
            system.debug('Exception occured:::' +objException.getMessage());
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, objException.getMessage()));
            return;
        }
    }
    
    public List<Time_Sheet_Details__c> getTimeSheetDetails(List<TimeSheet__c> TimeSheetList)
    {
        List<Time_Sheet_Details__c> timeSheetDetails = new List<Time_Sheet_Details__c>();
        List<ID> TimeSheetIDs = new List<ID>();
        if(TimeSheetList.size() > 0){            
        	for(TimeSheet__c TimeSheet : TimeSheetList){
            	TimeSheetIDs.add(TimeSheet.id);
            }
            if(TimeSheetIDs.size() > 0){
                // Query for all of the masters' child records
				List<Time_Sheet_Details__c> allChildren = [select Timesheet__c, Timesheet__r.Status__c,Timesheet__r.Week_End_Date__c,Timesheet__r.Week_Start_Date__c,Timesheet__r.Total_Hours__c,Initiative_Name__c, Task_Name__c from Time_Sheet_Details__c 
    			WHERE Timesheet__c IN :TimeSheetIDs ORDER BY Timesheet__c DESC, LastModifiedDate DESC];

				// Iterate through and save the first child for each master				
				Id currentMasterId;
				for (Time_Sheet_Details__c TimeSheetDetail : allChildren) {
    				if (TimeSheetDetail.Timesheet__c != currentMasterId) {
       					currentMasterId = TimeSheetDetail.Timesheet__c;
       					timeSheetDetails.add(TimeSheetDetail);
    				}
				}
            }
        }
        return timeSheetDetails;
    }
    
    
    // Account Pagination logic Start
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
    
    // Initiative Pagination logic start
    
    public void InitShowPrevious()
    {
        InitCurrentPage = InitCurrentPage- PageSize;
        InitPageNumber--;
        InitEnableDisablePaginationLinks();     
    }
    
    public void InitShowNext()
    {
        InitCurrentPage = InitCurrentPage + PageSize;
        InitPageNumber++;
        InitEnableDisablePaginationLinks();
    }
    
    public void InitShowFirst()
    {
        InitCurrentPage = 0;
        InitPageNumber = 1;
        InitEnableDisablePaginationLinks();
    }
    
    public void InitShowLast()
    {
        InitCurrentPage = (Math.mod(InitTotalRecords, PageSize) == 0) ? InitTotalRecords - PageSize : (InitTotalRecords / PageSize) * PageSize;
        InitPageNumber = (Math.mod(InitTotalRecords, PageSize) == 0 ? InitTotalRecords/PageSize : (InitTotalRecords/PageSize) + 1);
        InitEnableDisablePaginationLinks();
    }
    
    public void InitEnableDisablePaginationLinks()
    {
        if(InitCurrentPage == 0)
            InitShowPrevious = false;
        else    
            InitShowPrevious = true; 
        if((InitTotalRecords - PageSize) <= InitCurrentPage)
            InitShowNext = false;
        else
            InitShowNext = true;
        InitCurrentPageInfo = 'Showing Page ' + InitPageNumber +   ' of ' + (Math.mod(InitTotalRecords, PageSize) == 0 ? InitTotalRecords/PageSize : (InitTotalRecords/PageSize) + 1);
    }   
    
    // Initiative Pagination logic Ends
    
    // Timesheet Pagination logic start
    
    public void TsShowPrevious()
    {
        TsCurrentPage = TsCurrentPage- PageSize;
        TsPageNumber--;
        TsEnableDisablePaginationLinks();     
    }
    
    public void TsShowNext()
    {
        TsCurrentPage = TsCurrentPage + PageSize;
        TsPageNumber++;
        TsEnableDisablePaginationLinks();
    }
    
    public void TsShowFirst()
    {
        TsCurrentPage = 0;
        TsPageNumber = 1;
        TsEnableDisablePaginationLinks();
    }
    
    public void TsShowLast()
    {
        TsCurrentPage = (Math.mod(TsTotalRecords, PageSize) == 0) ? TsTotalRecords - PageSize : (TsTotalRecords / PageSize) * PageSize;
        TsPageNumber = (Math.mod(TsTotalRecords, PageSize) == 0 ? TsTotalRecords/PageSize : (TsTotalRecords/PageSize) + 1);
        TsEnableDisablePaginationLinks();
    }
    
    public void TsEnableDisablePaginationLinks()
    {
        if(TsCurrentPage == 0)
            TsShowPrevious = false;
        else    
            TsShowPrevious = true; 
        if((TsTotalRecords - PageSize) <= TsCurrentPage)
            TsShowNext = false;
        else
            TsShowNext = true;
        TsCurrentPageInfo = 'Showing Page ' + TsPageNumber +   ' of ' + (Math.mod(TsTotalRecords, PageSize) == 0 ? TsTotalRecords/PageSize : (TsTotalRecords/PageSize) + 1);
    }  
    
    // Timesheet Pagination logic Ends
    
    // Status Report Pagination logic Starts
    
    public void SrShowPrevious()
    {
        SrCurrentPage = SrCurrentPage- PageSize;
        SrPageNumber--;
        SrEnableDisablePaginationLinks();     
    }
    
    public void SrShowNext()
    {
        SrCurrentPage = SrCurrentPage + PageSize;
        SrPageNumber++;
        SrEnableDisablePaginationLinks();
    }
    
    public void SrShowFirst()
    {
        SrCurrentPage = 0;
        SrPageNumber = 1;
        SrEnableDisablePaginationLinks();
    }
    
    public void SrShowLast()
    {
        SrCurrentPage = (Math.mod(SrTotalRecords, PageSize) == 0) ? SrTotalRecords - PageSize : (SrTotalRecords / PageSize) * PageSize;
        SrPageNumber = (Math.mod(SrTotalRecords, PageSize) == 0 ? SrTotalRecords/PageSize : (SrTotalRecords/PageSize) + 1);
        SrEnableDisablePaginationLinks();
    }
    
    public void SrEnableDisablePaginationLinks()
    {
        if(SrCurrentPage == 0)
            SrShowPrevious = false;
        else    
            SrShowPrevious = true; 
        if((SrTotalRecords - PageSize) <= SrCurrentPage)
            SrShowNext = false;
        else
            SrShowNext = true;
        SrCurrentPageInfo = 'Showing Page ' + SrPageNumber +   ' of ' + (Math.mod(SrTotalRecords, PageSize) == 0 ? SrTotalRecords/PageSize : (SrTotalRecords/PageSize) + 1);
    }  
    
    
    // Status Report Pagination logic Ends
    
    
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
    
    public pagereference reDirecttoCustomer()
    {
        string CustomerId = System.currentPageReference().getParameters().get('CustomerId');        
        PageReference loginpageRef = new PageReference('/apex/Customer?custId='+CustomerId);
        loginpageRef.setRedirect(true); 
        return loginpageRef;        
    }
    public pagereference reDirecttoviewTimesheet(){
        TimeSheet__c timesheetRecById = ODS_Data_Utility.FetchTimesheetById(CurrenTimesheetId);
        AccountServiceID = timesheetRecById.Account_Services__c;
        string timeshtStats = timesheetRecById.Status__c;
        string weekStart = string.valueOf(timesheetRecById.Week_Start_Date__c);
        PageReference pgRef = new PageReference('/apex/TimesheetPage?id=' +CurrenTimesheetId + '&AccServiceId='+AccountServiceID+'&Status='+timeshtStats+'&WeekStart='+weekStart);
        pgRef.setRedirect(true);
        return pgRef;
    }
    public pagereference reDirecttoViewInitiative(){
        Initiatives__c initiativeRecById = ODS_Data_Utility.FetchInitiativeByID(CurrenInitiativeId);
        AccountServiceID = initiativeRecById.Account_Service__c;
        String initiativeStats = initiativeRecById.Status__c;
        PageReference pgRef = new PageReference('/apex/InitiativePage?CurrenInitiativeId=' +initiativeRecById.id + '&AccServiceId='+AccountServiceID+ '&Status='+initiativeStats);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public pagereference reDirecttoStatusReport(){
        String editSRtId = ApexPages.currentPage().getParameters().get('editSRId');
        Status_Report__c objSRforEdit = new Status_Report__c();
        objSRforEdit = ODS_Data_Utility.fetchStatusReportbyID(editSRtId);
        WorkDayParam = ApexPages.currentPage().getParameters().get('WorkDayParam');
        PageReference pr = new pagereference('/apex/AddStatusReport?accntId='+objSRforEdit.Account_services__r.Account__c+'&srvcId='+objSRforEdit.Account_services__r.ODS_Services__c+'&srId='+editSRtId);
        pr.setRedirect(true);      
        return pr;     
        
    }
    
}