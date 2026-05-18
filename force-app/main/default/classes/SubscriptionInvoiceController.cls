global class SubscriptionInvoiceController {
    
    //Properties for Header Components
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string CurrentAccServiceId {get;set;}  
    public string CurrentAccId {get;set;}    
    public List<ContentVersion> contentVersionList {get;set;}
    public LIST<Invoice__c> invoiceList{get;set;}
    public Invoice__c Invoice{ get; set; }
    public string CurrentUserName {get;set;}
    public string CurrentUserId {get;set;}
    public string PortalRole{get;set;}
    public string CurrenInvoiceId {get;set;}
    public Boolean isCustomer{get;set;}
    public Boolean isPartner{get;set;}
    public string AccountServiceID {get;set;}
    public string PassAccountName {get;set;}
    public string PassServiceName {get;set;}
    
    public static list<Invoice__c> invoicesList {get;set;}
    public List<wrapAttachment> wrapAttachmentList {get; set;}  
    public Boolean norecord{get;set;}
    
    
    
    // Wrapper/Container class
    public class wrapAttachment{
        public string documentId {get; set;}
        public string Id {get; set;}
        public string documentName {get; set;}
        public string docstartDate {get; set;}
        public string  docEndDate {get; set;}
        public string documentstatus {get; set;}
        public Boolean documentpaid {get; set;}
        public String docuemtType {get; set;}
        public String docuemtmonth {get; set;}
        
        
    }
    
    
    //Properties for pagination
    public Integer PageSize {get;set;}
    public Integer CurrentPage {get;set;}
    public Boolean ShowPrevious {get;set;}
    public Boolean ShowNext {get;set;}
    public String CurrentPageInfo {get;set;}
    public Integer TotalRecords;
    public Integer PageNumber; 
    public String sortDirection = 'ASC';
    public String sortExp = 'Billing_Start_Date__c';
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
    
    
    
    
    
    public SubscriptionInvoiceController()
    {
        Invoice = new Invoice__c();
        CurrentUserName = UserInfo.getName();
        CurrentUserId = UserInfo.getUserId();
        system.debug('CurrentUserId'+CurrentUserId);
        
        CurrentPage = 0; 
        PageSize = integer.valueof(System.Label.PageSize); // No. of rows per page
        PageNumber = 1; 
        ShowPrevious = false; 
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        PortalRole = objUser.PortalUserRole__c;
        // ContactId = objUser.contactId;
        if(objUser.PortalUserRole__c == 'Customer')
        { 
            isCustomer = true;
            
        }
        else if (objUser.PortalUserRole__c == 'Partner')
        {
            isPartner = true;
        }
        else
        {  
            isCustomer = false; 
            isPartner = false;
        } 
        
        
    }
    public void getAccDetails(){
        system.debug('AccountId11111'+AccountId);
        system.debug('ServiceId'+ServiceId);
        Account_Services__c  accountServices;
        wrapAttachmentList=new list<wrapAttachment>();
        invoicesList = new list<Invoice__c>();
        List<Contact_Account_Service__c> primaryContact = new List<Contact_Account_Service__c>();
        List<Invoice__c> Inviocelist = new List<Invoice__c>();
        string sortFullExp = sortExpression  + ' ' + sortDirection + ' NULLS LAST';
        system.debug('sortFullExp---'+sortFullExp);
        if(ServiceId != 'All'){
            
            accountServices = [SELECT Account__r.Id,Document_Suffix__c,Account__r.Name,ODS_Services__c,ODS_Services__r.Name,ODS_Service_Name__c FROM  Account_Services__c WHERE ODS_Services__c =: ServiceId And Account__r.Id =:AccountId]; 
        }
        else{
            accountServices = [SELECT Account__r.Id,Document_Suffix__c,Account__r.Name,ODS_Services__c,ODS_Services__r.Name,ODS_Service_Name__c FROM  Account_Services__c WHERE Account__r.Id =:AccountId]; 
            
        }
        system.debug('accountServices$$$$$$$'+accountServices);
        
        if(accountServices != null){
            
            
            Accountid = accountServices.Account__r.Id;
            primaryContact = [SELECT ID,Email__c,Contact__r.Name,ODS_Service__c FROM Contact_Account_Service__c WHERE Contact__r.AccountId =: accountServices.Account__r.ID AND ODS_Service__c =:accountServices.ODS_Services__c AND Is_Approver__c = True Limit 1];
            string invoiceType='Subscription';
            string accountServiceIdString=accountServices.id;
            string InvoiceCust='SELECT Account_Services__c,Invoice_Date__c,Billing_End_Date__c,Billing_Start_Date__c,Id,Invoice_Type__c,Status__c,Paid_unpaid__c,Month__c,Name,Year__c FROM Invoice__c WHERE Invoice_Type__c =:invoiceType AND Account_Services__c =:accountServiceIdString';
            string posted='Posted';
            if(isCustomer){
                InvoiceCust+=' AND Status__c=:Posted';
            }
            InvoiceCust+=' order by ' + sortFullExp + ' limit 500';
            
            Inviocelist = Database.query(InvoiceCust);
           // Inviocelist = Database.query('SELECT Account_Services__c,Invoice_Date__c,Billing_End_Date__c,Billing_Start_Date__c,Id,Invoice_Type__c,Status__c,Paid_unpaid__c,Month__c,Name,Year__c FROM Invoice__c WHERE Invoice_Type__c =:invoiceType AND Account_Services__c =:accountServiceIdString order by ' + sortFullExp + ' limit 10000');
            system.debug('Inviocelist'+Inviocelist);
            set<id> invoices =new set<id>();
            Map<Id, Id> contentdoclink = new Map<Id, Id>();
            Map<Id, Id> contenversionMap = new Map<Id, Id>();
            Map<Id, string> contentDocLinkTitleMap = new Map<Id, string>();
            Map<Id, string> contentDocTypeMap = new Map<Id, string>();
              if(isCustomer)
          {
             
          }
             system.debug('test'+isCustomer);
            for(Invoice__c inclist :Inviocelist ){
                invoices.add(inclist.Id);
            }
            List<ContentDocumentLink> condoclink = new List<ContentDocumentLink>();
            contentVersionList=new List<ContentVersion>();
            set<id> condId=new set<id>();
            set<id> invoId=new set<id>();
            norecord= false;
            if(invoices.isEmpty()){
                norecord = true;
                
            }
            system.debug('norecord-----'+norecord);
            if(invoices.size()>0){
                condoclink = [SELECT id,ContentDocumentId,ContentDocument.Title,ContentDocument.FileType,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: invoices];
                if(condoclink !=null){
                    for(ContentDocumentLink cd:condoclink){
                        condId.add(cd.ContentDocumentId);  
                        system.debug('condId'+cd.ContentDocument.Title);
                        contentdoclink.put(cd.LinkedEntityId,cd.ContentDocumentId);
                        contentDocLinkTitleMap.put(cd.LinkedEntityId,cd.ContentDocument.Title);
                        contentDocTypeMap.put(cd.LinkedEntityId,cd.ContentDocument.FileType);
                        // invoId.add(cd.LinkedEntityId);
                        //system.debug('invoId'+invoId);
                    }
                }
                
                contentVersionList=[Select Id,ContentDocument.Title,ContentDocument.FileType,ContentDocumentId,ContentDocument.ParentId From ContentVersion Where ContentDocumentId IN:condId ];
                system.debug('condoclink'+condoclink);
                for(ContentVersion cv:contentVersionList){
                    contenversionMap.put(cv.ContentDocument.id,cv.Id);
                }
                for(Invoice__c invo: Inviocelist){
                    Datetime dtTodayDateTime = datetime.newInstance(invo.Billing_Start_Date__c.year(), invo.Billing_Start_Date__c.month(),invo.Billing_Start_Date__c.day());
                    Datetime dtTodayDateTimes = datetime.newInstance(invo.Billing_End_Date__c.year(), invo.Billing_End_Date__c.month(),invo.Billing_End_Date__c.day());
                    Datetime dtInvoiceDate = datetime.newInstance(invo.Invoice_Date__c.year(), invo.Invoice_Date__c.month(),invo.Invoice_Date__c.day());
                    
                    wrapAttachment accWrapper = new wrapAttachment();
                    accWrapper.docstartDate = dtTodayDateTime.format('MM/dd/yyyy');
                    accWrapper.docEndDate = dtTodayDateTimes.format('MM/dd/yyyy');
                    accWrapper.documentstatus = invo.Status__c;
                    accWrapper.Id = invo.Id;
                    accWrapper.documentpaid = invo.Paid_unpaid__c;
                    accWrapper.docuemtmonth =dtInvoiceDate.format('MM/dd/yyyy');
                    accWrapper.documentName = contentDocLinkTitleMap.get(invo.Id);
                    accWrapper.documentId =  contenversionMap.get(contentdoclink.get(invo.Id));
                    system.debug('accWrapper.Id'+accWrapper.documentId);
                    accWrapper.docuemtType = contentDocTypeMap.get(invo.Id);  
                    wrapAttachmentList.add(accWrapper);
                    system.debug('wrapAttachmentList!!!!!'+wrapAttachmentList);
                    //wrapAttachmentList.sort();
                    
                }
                
            }
        }
        
        else{
            PassAccountName = 'None';
            PassServiceName = 'None';
        }
        if(wrapAttachmentList.size()>0)
        {
            TotalRecords = wrapAttachmentList.size();  // Total No of records need to display in Grid.      
            if(TotalRecords > PageSize)
                ShowNext = true;
            else
                ShowNext = false;       
            CurrentPageInfo = 'Showing Page ' + PageNumber + ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1); 
        }
    }
    public void fetchInvoiceListCommnadLink(){
        system.debug('=======TestLinkMtd');
        
        getAccDetails();
    }
    
    public pagereference GetCustomerByAccountServiceID() 
    { 
        try
        {
            ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);     
            getAccDetails();
            GetAccountServices(); 
            
            
        }
        catch(Exception ex)
        {
            system.debug(ex+'--'+ex.getLineNumber());
        }         
        return null;  
    }
    
    public void GetAccountServices(){
        try{
            List<Account_Services__c > accServList = new List<Account_Services__c >();
            accServList = ODS_Data_Utility.fetchAccServcesByAccAndSrv(AccountId,ServiceId);     
            system.debug('accServList'+accServList);
            
            if(accServList.size() > 0){
                AccountServiceID = accServList[0].Id;
            }
            else{
                AccountServiceID = '';
            }
        }
        catch(exception e){
            system.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());            
            
        }
    }
    public void GetLoggedUserAccountService()
    {
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId()); 
        if(objUser.PortalUserRole__c == 'Customer')
        {   
            List<Contact> cnt = new List<Contact>();
            cnt = ODS_Data_Utility.FetchAccountIdByCustomer(objUser.ContactId);
            if(cnt.size() > 0){
                AccountId = cnt[0].AccountId;
                System.debug('@@@@@@QAccountId'+AccountId);
            }
            else{
                AccountId = 'All';
            }
            List<Account_Services__c> accService = new List<Account_Services__c>();
            accService = ODS_Data_Utility.fetchAccServcesByAcc(AccountId);
            if(accService.size() > 0){
                ServiceId = accService[0].ODS_Services__c;
            }
            else{
                ServiceId = 'All';
            }
        }
        else
        {
            AccountId = 'All';
            ServiceId = 'All';
        }
    }   
    public void AssignPassedAccountService()
    {
        List<Account_Services__c > accServiceLst = new List<Account_Services__c >();
        System.debug('@@@@@@Line No:217 CurrentAccServiceId'+CurrentAccServiceId);
        accServiceLst = ODS_Data_Utility.fetchRelatedAccountService(CurrentAccServiceId);
        if(accServiceLst.size() > 0){
            AccountId = accServiceLst[0].Account__c;
            ServiceId = accServiceLst[0].ODS_Services__c;
        }
    }
    @RemoteAction
    global static ODSInvoiceSessionData__c getInvoiceSessionDetails()
    {
        ODSInvoiceSessionData__c userSession = ODSInvoiceSessionData__c.getInstance( userInfo.getUserId() );
        system.debug('userSession '+userSession.UserBillingStartDate__c);
        return userSession;
    }
    
    
    public void showPrevious()
    {
        CurrentPage = CurrentPage- PageSize;
        PageNumber--;
        enableDisablePaginationLinks();     
    }
    public void showNext()
    {
        system.debug('Inside Next Method');
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
    
    public void UpdateInvoiceStatus(){
        Invoice__c UpdateInvoice = new Invoice__c();
        
        string InvoiceId = System.currentPageReference().getParameters().get('InvoiceId');
        System.debug('InvoiceId====>' + InvoiceId);
        ODS_Data_Utility_Invoice.UpdateInvoiceStatus(InvoiceId);
    }
    
    public void UpdateInvoiceStatusAsFalse(){
        string InvoiceId = System.currentPageReference().getParameters().get('InvoiceId');
        System.debug('InvoiceId====>' + InvoiceId);
        ODS_Data_Utility_Invoice.UpdateInvoiceStatusAsFalse(InvoiceId);
    }
    
}