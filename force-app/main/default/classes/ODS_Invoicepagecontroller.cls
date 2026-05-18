/**
 * @author           Gnana Prakash
 * @version          1.0 
 * @date             05-Oct-2016
 * @Status           Developed
 * @description      This is the class For Invoice Page Controller.
 */
global class ODS_Invoicepagecontroller {
      

    //Properties for Invoice
    public string CurrenInvoiceId {get;set;}
    public transient Blob blobBody { get; set; }
    public String filename { get; set; }
    public transient Blob supportingBlobBody { get; set; }
    public String supportingFileName { get; set; }
    public String InvoiceStatus { get; set; }
    public String primaryConEmailAddress { get; set; }
    public string toAddress { get; set; }
    public LIST<Invoice__c> invoiceList{get;set;}
    public Invoice__c Invoice{ get; set; }
    public string FromDate {get;set;}
    public string ToDate {get;set;}
    public string UniqueInvoiceId {get;set;}
    public string Month{get;set;}
    Public Integer Year{get;set;}

   // public List<SelectOption> InvoiceMonthOptions{get;set;}
    //public List<SelectOption> InvoiceYearOptions{get;set;}
    public string AccountServiceID {get;set;} 
    
    //Properties for Header Components
    public string AccountId {get;set;}
    public string ServiceId {get;set;}    
    public string CurrentUserName {get;set;}
    public string CurrentUserId {get;set;}
    public string PortalRole{get;set;}
    public string ContactId{get;set;}
    public Boolean IsCustomer{get;set;}
    public Boolean IsCustomerGrid{get;set;}
    
    //Properties for pagination
    public Integer PageSize {get;set;}
    public Integer CurrentPage {get;set;}
    public Boolean ShowPrevious {get;set;}
    public Boolean ShowNext {get;set;}
    public String CurrentPageInfo {get;set;}
    public Integer TotalRecords;
    public Integer PageNumber; 
    public Boolean ShowDisclaimer {get;set;}
    public Boolean ShowUploadInvoice {get;set;} 
    public Date BillingStartDate {get; set;}
    public Date BillingEndDate {get; set;}  
    
    public String sortDirection = 'DESC';
    public String sortExp = 'Billing_End_Date__c';
     public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }

/*    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }	*/
    
    public ODS_Invoicepagecontroller()
    {
        
        Invoice = new Invoice__c();
        CurrentUserName = UserInfo.getName();
        CurrentUserId = UserInfo.getUserId();
       // CurrentUserId = UserInfo.getUserId();
        CurrentPage = 0; 
        PageSize = integer.valueof(System.Label.PageSize); // No. of rows per page
        PageNumber = 1; 
        ShowPrevious = false; 
        user objUser = ODS_Data_Utility_Invoice.fetchUserById(UserInfo.getUserId());
        PortalRole = objUser.PortalUserRole__c;
        ContactId = objUser.contactId;
        if(objUser.PortalUserRole__c == 'Customer')
        { 
            isCustomer = true;
            ShowDisclaimer = false;      
            ShowUploadInvoice = false;
        }
        else
        {  
            isCustomer = false; 
            ShowUploadInvoice = true;
            ShowDisclaimer = true;
        } 
               
    }
/*   public List<Invoice__c> getInvoiceList() {
        return invoiceList;
   }	*/
    /// <OBJECTIVE>
    /// Fetch Invoice list based on the Account and Service Id
    /// </OBJECTIVE>
    public void FetchInvoiceList(string accountId, string serviceId, string Month, integer Year)
    {          
        system.debug('===========FetchInvoiceList===========');
        string sortFullExp = sortExpression  + ' ' + sortDirection + ' NULLS LAST';
       try
       {        
          invoiceList = new List<Invoice__c>();
          List<Invoice__c> mainInvoiceList = new List<Invoice__c>();
          mainInvoiceList =  ODS_Data_Utility_Invoice.FetchInvoice(accountId, serviceId, Month, Year,sortFullExp); 
          if(isCustomer)
          {
              for(Invoice__c tempInv: mainInvoiceList)
              {
                  if(tempInv.Status__c != 'Saved')
                  {
                      invoiceList.add(tempInv);
                  }
              }
          }
          else
          {
              invoiceList.addAll(mainInvoiceList);
          }
          
           CurrentPage = 0; 
           PageNumber = 1; 
           ShowPrevious = false;
           if(invoiceList.size()>0)
           {
                TotalRecords = invoiceList.size();  // Total No of records need to display in Grid.      
                system.debug('###TotalRecords:' +TotalRecords);
                if(TotalRecords > PageSize)
                    ShowNext = true;
                else
                    ShowNext = false;       
                CurrentPageInfo = 'Showing Page ' + PageNumber + ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1); 
            }
        }
        catch(Exception ex)
        {
            system.debug('Error' + ex);
        }
    }
    
    
    @RemoteAction
    global static ODSInvoiceSessionData__c getInvoiceSessionDetails()
    {
        ODSInvoiceSessionData__c userSession = ODSInvoiceSessionData__c.getInstance( userInfo.getUserId() );
        return userSession;
    }
    
    /// <OBJECTIVE>
    /// Bind year dropdown.
    /// </OBJECTIVE>
    public List<SelectOption> getYears()
    {
        List<SelectOption> yearLst = new List<SelectOption>();
        Integer startYear = Date.today().Year();
        Integer endYear = Date.today().addYears(-3).Year();
        yearLst.add(new SelectOption('Year','Year')); 
        for(integer i = startYear; i >= endYear; i--)
        {
            yearLst.add(new SelectOption(string.ValueOf(i),string.ValueOf(i))); 
        }
        return yearLst;
    }
    
    
    /// <OBJECTIVE>
     /// Delete the Uploaded Invoice
    /// </OBJECTIVE>
    public void DeleteInvoice()
    {
          try
          {
               Invoice__c DeleteInvoiceId = new Invoice__c();
               string InvoiceId = System.currentPageReference().getParameters().get('InvoiceId');
               //sendEmailDelete(InvoiceId);               
               ODS_Data_Utility_Invoice.DeleteInvoice(InvoiceId);
          }
          catch(Exception ex)
          {
              system.debug(ex);
          }
    }
    
    public void UpdateInvoiceStatus(){
        string InvoiceId = System.currentPageReference().getParameters().get('InvoiceId');
        System.debug('InvoiceId====>' + InvoiceId);
        ODS_Data_Utility_Invoice.UpdateInvoiceStatus(InvoiceId);
    }
    
    public void UpdateInvoiceStatusAsFalse(){
        string InvoiceId = System.currentPageReference().getParameters().get('InvoiceId');
        System.debug('InvoiceId====>' + InvoiceId);
        ODS_Data_Utility_Invoice.UpdateInvoiceStatusAsFalse(InvoiceId);
    }
    
    
    /// <OBJECTIVE>
    ///  To get the Customer based on Account service Id
    /// </OBJECTIVE>
    public pagereference GetCustomerByAccountServiceID() 
    { 
        try
        {
            ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);     
            FetchInvoicelist(accountId, serviceId, Month, Year);
            GetAccountServices(); 
            
            
        }
        catch(Exception ex)
        {
              system.debug(ex);
        }         
        return null;  
    }
    public void GetAccountServices()
    {
        if(AccountId == 'All' || ServiceId == 'All')
        {
            ShowUploadInvoice = false;
            if(PortalRole == 'Customer')
            {
                ShowDisclaimer = false;
            }
            else{
                ShowDisclaimer = true;
            }
        }
        else
        {
            ShowDisclaimer = false;
            if(PortalRole == 'Customer')
            {
                ShowUploadInvoice = false;
            }
            else
            {
                ShowUploadInvoice = true;
            }
            List<Account_Services__c > accServList = new List<Account_Services__c >();
            List<Contact_Account_Service__c> primaryContact = new List<Contact_Account_Service__c>();
            accServList = ODS_Data_Utility_Invoice.fetchAccServcesByServiceAccount(AccountId, ServiceId);
            if(accServList.size() > 0){
                AccountServiceID = accServList[0].Id;
                primaryContact = [SELECT ID,Email__c,Contact__r.Name,ODS_Service__c FROM Contact_Account_Service__c WHERE Contact__r.AccountId =: accServList[0].Account__r.ID AND ODS_Service__c =:accServList[0].ODS_Services__c AND Is_Approver__c = True Limit 1];
                if(primaryContact != Null)
                {
                    toAddress = primaryContact[0].Email__c;
                    primaryConEmailAddress = primaryContact[0].Email__c;
                    system.debug('toaddress-----' +toAddress);
                }
            }
            else{
                AccountServiceID = '';
            }
        }
    }
       
    
   public PageReference AddInvoice()
    {
        system.debug('PAgeReferenceredirecttoEditInovie');
        PageReference pgRef = new PageReference('/apex/EditUploadInvoice?AccServiceId='+AccountServiceID);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public PageReference ViewInvoice()
    {

         System.debug('@@@@@@@@CurrenInitiativeId in View Initiative Method'+CurrenInvoiceId);
         PageReference pgRef = new PageReference('/apex/EditUploadInvoice?CurrenInvoiceId=' +CurrenInvoiceId + '&AccServiceId='+AccountServiceID);
         pgRef.setRedirect(true);
         return pgRef;
    }
        
    
    /// <OBJECTIVE>
    ///  Enable disable showPrevious button.
    /// </OBJECTIVE>
    public void showPrevious()
    {
        CurrentPage = CurrentPage- PageSize;
        PageNumber--;
        enableDisablePaginationLinks();     
    }
    /// <OBJECTIVE>
    /// Enable disable showNext button
    /// </OBJECTIVE>
    public void showNext()
    {
        system.debug('Inside Next Method');
        CurrentPage = CurrentPage + PageSize;
        PageNumber++;
        enableDisablePaginationLinks();
    }
    /// <OBJECTIVE>
    /// Enable disable showFirst button
    /// </OBJECTIVE>
    public void showFirst()
    {
        CurrentPage = 0;
        PageNumber = 1;
        enableDisablePaginationLinks();
    }
    /// <OBJECTIVE>
    /// Enable disable showLast button
    /// </OBJECTIVE>
    public void showLast()
    {
        CurrentPage = (Math.mod(TotalRecords, PageSize) == 0) ? TotalRecords - PageSize : (TotalRecords / PageSize) * PageSize;
        PageNumber = (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1);
        enableDisablePaginationLinks();
    }
    /// <OBJECTIVE>
    /// Enable disable pagination links
    /// </OBJECTIVE>
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
    
    ///<OBJECTIVE>
    /// Method to get search results
    ///</OBJECTIVE>   
    public void fetchInvoiceListCommnadLink(){
        system.debug('=======TestLinkMtd');
        
        FetchInvoiceList(accountId, serviceId, Month, Year);
    }
    public void GetSearchResults()
    {      
        system.debug('Month'+ Month+'#####Year'+ Year); 
        try
        {
            CurrentPage = 0;
            PageNumber=1;
            //enableDisablePaginationLinks();
            FetchInvoiceList(accountId, serviceId, Month, Year);           
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
    } 
    
   
    @RemoteAction
    global static string GetInvoiceAttachment(string InvoiceId) {
        
        string InvoiceJSON = '';
        system.debug('##InvoiceId:'+ InvoiceId);
        try
        {
            InvoiceJSON =  ODS_Data_Utility_Invoice.GetInvoiceAttachment(InvoiceId);
            system.debug('###InvoiceJSON :' +InvoiceJSON );            
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
        return InvoiceJSON;
    } 

    /*
     * BWDCOMP BEGIN FOR PB-115
     */
    public String InvoiceComments { get; set; }
    
    public pagereference UploadInvoice(){
        return null;
    }
    
    @RemoteAction
    global static string ValidateUploadInvoice(string accountId, string serviceId, string InvoiceId, string fileName){
        return '';
    }
    
    public PageReference GetValue()
    {
        return null;
    }
    /*
     * BWDCOMP END FOR PB-115
     */
}