public with sharing class ODS_ClientQueriesApexController {
    
   // public static string currentUserName {get;set;}
    public static List<ClientQueries__c> queryLst {get;set;}
    //public static string AccountId {get;set;}
    //public static string ServiceId {get;set;}
      public static string fromDate {get;set;}
    public static string toDate {get;set;}
    public static String buildQuery {get;set;}
    public static String selectQuery {get;set;}
    public static String whereQuery {get;set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    
    
    //Properties for pagination
   // public static Integer PageSize {get;set;}
    //public static Integer CurrentPage {get;set;}
    //public static Boolean ShowPrevious {get;set;}
    //public static Boolean ShowNext {get;set;}
   // public static String CurrentPageInfo {get;set;}
    public static Integer TotalRecords;
    public static Integer PageNumber;
    
    public static Set<string> GetAllAccounts()
    {
        Set<string> accountIdSet = new Set<string>();
        ODS_Common_Utility obj = new ODS_Common_Utility();
        String[] AccounIDs = obj.getAllAccountIDByLoggedInUser();
        for( String AccID: AccounIDs )
        {
            accountIdSet.add(AccID);
        }
        return accountIdSet;
    }
    
    public static Set<string> GetAllServices()
    {
        Set<string> serviceIdSet = new Set<string>();
        for(ODS_Services__c odsService: ODS_Data_Utility.GetAllServices())
        {
            serviceIdSet.add(odsService.Id);
        }
        return serviceIdSet;
    }

    
    /// <OBJECTIVE>
    /// Get client queries by using user Id.
    /// </OBJECTIVE>
    @AuraEnabled(cacheable=true)
    public static List<ClientQueries__c> GetQueriesByUserId(string AccountId, string ServiceId,string startDate, string endDate)
    {	
        Set<String> allAccountIds = new Set<string>();
        Set<String> allServiceIds = new Set<string>();
        queryLst = new List<ClientQueries__c>();
        buildQuery = '';
        whereQuery ='';
        selectQuery = '';
        system.debug('AccountId : '+AccountId);
        
        
       // date frmDate1 = date.Parse(fromDate);
        //system.debug('frmDate : '+frmDate1);
        system.debug(' fromDate : '+fromDate);
        system.debug(' toDate : '+toDate);
  
        selectQuery = 'SELECT Id, Account_Name__c, Account_Name__r.Name, Queries__c, Query_Date__c, Service_Name__c, Service_Name__r.Name__c FROM ClientQueries__c ';
        whereQuery = 'WHERE ';
        try{
            if(AccountId == 'All')
            {
                allAccountIds = GetAllAccounts();
                whereQuery += 'Account_Name__c IN: allAccountIds AND ';
            }
            else
            {
                whereQuery += 'Account_Name__c =: AccountId AND ';
            }
            if(ServiceId == 'All')
            {
                allServiceIds = GetAllServices();
                whereQuery += 'Service_Name__c IN: allServiceIds AND ';
            }  
            else
            {
                whereQuery += 'Service_Name__c =: ServiceId AND ';
            }
            if(startDate != null && startDate != '')
            {
                fromDate = formatDate(startDate);
                date frmDate = date.Parse(FromDate);
                whereQuery += 'Query_Date__c >=: frmDate AND ';
                system.debug('frmDate....'+frmDate);
            }
            if(endDate != null && endDate != '')
            {
                toDate = formatDate(endDate);
                date toDt = date.Parse(toDate);
                whereQuery += 'Query_Date__c <=: toDt AND ';
                system.debug('toDt....'+toDt);
            }
    
            whereQuery = (whereQuery.trim()).removeEnd('AND');
            whereQuery = (whereQuery.trim()).removeEnd('WHERE'); 
            system.debug('whereQuery : '+whereQuery);
                
            buildQuery = selectQuery +whereQuery; 
            system.debug('buildQuery : '+buildQuery);
            queryLst = database.query(buildQuery );
            system.debug('queryLst : '+queryLst);
            
        
        }
        catch(Exception e){
            System.debug('Invalid date!!');
        }
        return queryLst;
    }
    
    public static string formatDate(string strDate ){
        date updateToDate = date.valueOf(strDate);
        Datetime dtTodayDateTime = datetime.newInstance(updateToDate.year(), updateToDate.month(),updateToDate.day());
        string formattedStrDate = dtTodayDateTime.format('MM/dd/yy');
        return formattedStrDate;
    }
    

 /*   /// <OBJECTIVE>
    /// Enable disable pagination links
    /// </OBJECTIVE>
    public static PaginationWrapper EnableDisablePaginationLinks(integer TotalRecords, integer CurrentPage, integer PageNumber)
    {
        PaginationWrapper navigaionDetails = new PaginationWrapper();
        system.debug('CurrentPage: '+CurrentPage);
        system.debug('PageNumber: '+PageNumber);
        system.debug('TotalRecords: '+TotalRecords);
        system.debug('PageSize: '+PageSize);
        PageSize = integer.valueof(System.Label.PageSize); // No. of rows per page
        
        navigaionDetails.paginationCurPage = CurrentPage;
        if(CurrentPage == 0){
            ShowPrevious = false;
        	navigaionDetails.paginationPreviousVal = ShowPrevious;
        }
        else {   
            ShowPrevious = true; 
        	navigaionDetails.paginationPreviousVal = ShowPrevious;
        }
        if((TotalRecords - PageSize) <= CurrentPage){
            ShowNext = false;
            navigaionDetails.paginationNextVal = ShowNext;
        }
        else{
            ShowNext = true;
        	navigaionDetails.paginationNextVal = ShowNext;
        }
        CurrentPageInfo = 'Showing Page ' + PageNumber +   ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1);
    	navigaionDetails.paginationPageDetail = CurrentPageInfo;
        navigaionDetails.paginationPageNo = PageNumber;
    	return navigaionDetails;
    } 
   
   
    
    public class PaginationWrapper{
        @AuraEnabled
        public string paginationPageDetail{get;set;}  
        @AuraEnabled
        public boolean paginationPreviousVal{get;set;}
        @AuraEnabled
        public boolean paginationNextVal{get;set;}
        @AuraEnabled
        public integer paginationCurPage{get;set;}
        @AuraEnabled
        public integer paginationPageNo{get;set;}
        
        
    }
*/
  /*  
    @AuraEnabled(cacheable=true)
   public static List<ClientQueries__c> getOpps( String searchKey) {
      
       String query = 'SELECT Id, Account_Name__r.Name, Service_Name__r.Name__c, Queries__c, Query_Date__c FROM ClientQueries__c';
       system.debug('query---'+query);
       if ( searchKey != null && searchKey != '' ) {
           String key = '%' + searchKey + '%';
           query += ' WHERE Service_Name__r.Name__c LIKE :key';
       }
       
       return Database.query( query );
   }*/
    @AuraEnabled(Cacheable=false)
    public static void updateSessionData(string accountId,string serviceId){
        ODS_Common_Utility.upsertSessionData(accountId,serviceId);  
    }
}