global class ODS_EditUploadInvoicecontroller {
    
    //Properties for Invoice
    public transient Blob blobBody { get; set; }
    public String filename { get; set; }
    public Boolean ShowUploadInvoice {get;set;} 
    public String InvoiceStatus { get; set; }
    public string toAddress { get; set; }
    public string ccAddress { get; set; }
    public string emailSubject { get; set; }
    public Invoice__c Invoice{ get; set; }
    public string Month{get;set;}
    Public Integer Year{get;set;}
    public string PassAccountName {get;set;}
    public string PassServiceName {get;set;}
    public List<Attachment> InvoiceAttachments {get;set;}
    public string AttachmentToDelete {get;set;}
    public string AttachmentType {get;set;}
    public string AccountServiceID {get;set;}
    public string fileType {get;set;}
    public string documentSuffix {get;set;}
    
    //Properties for Header Components
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string CurrentAccServiceId {get;set;}    
    public string CurrentUserName {get;set;}
    public string CurrentUserId {get;set;}
    public string PortalRole{get;set;}
    public string CurrenInvoiceId {get;set;}
    public Boolean isCustomer{get;set;}
    public Boolean isPartner{get;set;}
    
    //Properties for pagination
    public Date BillingStartDate {get; set;}
    public Date BillingEndDate {get; set;} 
    public boolean hasTimesheetFile {get; set;}
    public boolean hasInvoiceFile {get; set;}
    // public String CommentHistory {get;set;}
    public String CommentData {get;set;}
    public List<wrapAttachment> wrapAttachmentList {get; set;}    
    
    // Wrapper/Container class
    public class wrapAttachment{
        public string documentId {get; set;}
        public string documentName {get; set;}
        public String docuemtType {get; set;}
        public wrapAttachment(String Name, String Id, String Type){
            documentId = Id;
            documentName = Name;
            docuemtType = Type;                       			
        }
        
    }
    
    public ODS_EditUploadInvoicecontroller()
    {
        Invoice = new Invoice__c();       
        CurrentUserName = UserInfo.getName();
        CurrentUserId = UserInfo.getUserId();
        
        user objUser = ODS_Data_Utility_Invoice.fetchUserById(UserInfo.getUserId());
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
        
        
        Account_Services__c  acc;
        List<Contact_Account_Service__c> primaryContact = new List<Contact_Account_Service__c>();
        CurrentAccServiceId = ApexPages.CurrentPage().getParameters().get('AccServiceId');
        CurrenInvoiceId = ApexPages.CurrentPage().getParameters().get('CurrenInvoiceId');
        system.debug('CurrentAccServiceId============'+CurrentAccServiceId);
        system.debug('CurrenInvoiceId============'+CurrenInvoiceId);
        
        if(CurrentAccServiceId != null){
            
            acc = [SELECT Account__r.Id,Document_Suffix__c,Account__r.Name,ODS_Services__c,ODS_Services__r.Name,ODS_Service_Name__c FROM  Account_Services__c WHERE Id =: CurrentAccServiceId]; 
        }
        if(acc != null){
            PassAccountName = acc.Account__r.Name;
            PassServiceName = acc.ODS_Service_Name__c ;
            AccountId = acc.Account__r.Id;
           /* primaryContact = [SELECT ID,Email__c,Contact__r.Name,ODS_Service__c FROM Contact_Account_Service__c WHERE Contact__r.AccountId =: acc.Account__r.ID AND ODS_Service__c =:acc.ODS_Services__c AND Is_Approver__c = True Limit 1];
            if(primaryContact != Null){
                toAddress = primaryContact[0].Email__c;
            }*/
            toAddress='';
            List<Work_Order__c> WOList=[SELECT Contact_to_Send_the_Invoice__r.Email,Other__c FROM Work_Order__c WHERE Client_Name__c=:acc.Account__r.ID ORDER BY CreatedDate DESC limit 1];
            if(!WOList.isEmpty()){
                if(string.isNotBlank(WOList[0].Contact_to_Send_the_Invoice__r.Email)){
                    toAddress=WOList[0].Contact_to_Send_the_Invoice__r.Email;   
                }
                if(string.isNotBlank(WOList[0].Other__c) && string.isNotBlank(toAddress)){
                    toAddress =toAddress+','+WOList[0].Other__c;
                }
                if(string.isBlank(toAddress) && string.isNotBlank(WOList[0].Other__c)){
                    toAddress=WOList[0].Other__c;  
                }
            }
        }
        else{
            PassAccountName = 'None';
            PassServiceName = 'None';
        }
        
        
        
        if(CurrenInvoiceId != null){
            
            ShowUploadInvoice = true; 
            Invoice__c invoiceobj = ODS_Data_Utility_Invoice.FetchInvoiceByID(CurrenInvoiceId);
            system.debug('invoiceObj '+invoiceobj);
            system.debug('invoiceObj '+invoiceobj.status__c);
            if(CurrentAccServiceId == null){
                GetLoggedUserAccountService();
            }
            else{
                AssignPassedAccountService();
            }
            GetAccountServices();
            Invoice.Month__c = invoiceobj.Month__c;
            Invoice.Year__c = invoiceobj.Year__c;
            Invoice.Invoice_ID__c = invoiceobj.Id; 
            Invoice.Status__c = invoiceobj.Status__c;
            Invoice.Email_Body__c = invoiceobj.Email_Body__c;
            emailSubject = invoiceobj.Subject__c;
            InvoiceStatus = invoiceobj.Status__c;
            BillingStartDate = invoiceobj.Billing_Start_Date__c;
            BillingEndDate = invoiceobj.Billing_End_Date__c;
            // CommentHistory = invoiceobj.Comment_History__c;
            CurrenInvoiceId = invoiceobj.Id;
            CommentData = invoiceobj.Comments__c; //imp
            if(String.isNotEmpty(invoiceobj.Invoice_CC__c)){
                
                ccAddress = invoiceobj.Invoice_CC__c; 
            }
            
            system.debug('CommentData '+invoice.Comments__c);
            
            
            List<ContentDocumentLink> condoclink = new List<ContentDocumentLink>();
            condoclink = [SELECT id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: CurrenInvoiceId];
            hasTimesheetFile = false;
            hasInvoiceFile = false;
            if(!condoclink.isEmpty())
            {
                Set<id> condoset = new Set<id>(); 
                for(ContentDocumentLink condl : condoclink){
                    condoset.add(condl.ContentDocumentId);
                }
                
                List<ContentVersion> conv = new List<ContentVersion>();
                conv = [SELECT id,Type__c,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: condoset];                
                
                for(ContentVersion c : conv){
                    if(c.Type__c == 'Timesheet'){
                        hasTimesheetFile = true;
                    }
                    
                    else if(c.Type__c == 'Invoice'){
                        hasInvoiceFile = true;
                    }
                    
                }                 
            }
            
            if(String.isNotEmpty(invoiceobj.Email__c)){
                
                toAddress = invoiceobj.Email__c; 
            }
            GetCurrentAttachments(invoiceobj.Id);
        }
        else{
            Invoice = new Invoice__c();
            if(CurrentAccServiceId == null){
                GetLoggedUserAccountService();
            }
            else{
                AssignPassedAccountService();
            }
            
        }
    }
    
    public void GetAccountServices(){
        try{
            List<Account_Services__c > accServList = new List<Account_Services__c >();
            accServList = ODS_Data_Utility_Invoice.fetchAccServcesByServiceAccount(AccountId, ServiceId);        
            
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
    
    public void GetCurrentAttachments(String CurrentInvoiceId)
    {
        try{
            List<Attachment> invoiceAttachmentTemp = new List<Attachment>();
            if((CurrentInvoiceId != Null)&&(CurrentInvoiceId !=''))
            {
                invoiceAttachmentTemp = [Select Id, Name, CreatedDate, ParentId, body from Attachment where ParentId =:CurrentInvoiceId Order By CreatedDate DESC Limit 10];
            }
            if((invoiceAttachmentTemp.size() != 0)&&(!invoiceAttachmentTemp.isEmpty()) &&(invoiceAttachmentTemp != Null))
            {
                InvoiceAttachments = invoiceAttachmentTemp;
            }
            else
            {
                InvoiceAttachments = Null;
            }
            if(wrapAttachmentList == null){
                wrapAttachmentList = new List<wrapAttachment>();
                for(Attachment a : [select Id, Name, ParentId, body from Attachment where ParentId =: CurrentInvoiceId]){ 
                    wrapAttachmentList.add(new wrapAttachment(a.Name,a.Id,'' ));
                }
                //wrapContentVersionList = new List<wrapAttachment>();
                set<Id> getContentDecID = new set<ID>();
                List<ContentDocumentLink>  getContentDocumentLink = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=: CurrentInvoiceId];
                for(ContentDocumentLink addDocId:getContentDocumentLink ){
                    getContentDecID.add(addDocId.ContentDocumentId);
                }
                for(ContentVersion con : [Select Id, Title, Type__c,ContentDocumentId from ContentVersion where ContentDocumentId =: getContentDecID]){
                    wrapAttachmentList.add(new wrapAttachment(con.Title,con.Id,con.Type__c)); 
                }
            }
            system.debug('wrapAttachmentList '+wrapAttachmentList);
        }
        Catch(exception e){
            System.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());                                    
        }
    }
    
    @RemoteAction
    global static ODSInvoiceSessionData__c getInvoiceSessionDetails()
    {
        ODSInvoiceSessionData__c userSession = ODSInvoiceSessionData__c.getInstance( userInfo.getUserId() );
        system.debug('userSession '+userSession.UserBillingStartDate__c);
        return userSession;
    }
    
    public PageReference DeleteAttachment(){
        try{
            string attachmentId = AttachmentToDelete;
            string type = AttachmentType;
            System.debug('@@@attachmentId : ' + attachmentId);
            System.debug('@@@attachmentType : ' + type);
            Attachment attachmentdelete = new Attachment();
            ContentVersion conver = new ContentVersion();
            string currentId;
            if(type == null || type == '')
            {
                attachmentdelete  = [Select Id, ParentId From Attachment where Id=:attachmentId Limit 1];    
                if(attachmentdelete != null)
                {
                    currentId = attachmentdelete.ParentId;
                    delete attachmentdelete;
                }
            }
            else
            {
                conver = [Select id, Type__c,ContentDocumentId From ContentVersion where id =: attachmentId Limit 1];
                ContentDocumentLink cdl = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink where ContentDocumentId =: conver.ContentDocumentId];
                
                ContentDocument contdocdelete = [Select id from ContentDocument where id =: conver.ContentDocumentId];
                if(contdocdelete != null)
                {
                    currentId = cdl.LinkedEntityId;
                    delete contdocdelete;
                }
            }
            
            system.debug('currentId ================ '+currentId);
            Invoice__c invoiceRecById = ODS_Data_Utility_Invoice.FetchInvoiceByID(currentId);
            if(conver.Type__c == 'Invoice'){
                invoiceRecById.Attachment_File__c = '';
                invoiceRecById.Uploaded_by__c = null;
                invoiceRecById.Uploaded_Date__c = null;
                update invoiceRecById;
            }
            string AccntServiceID = invoiceRecById.Account_Services__c;
            String AccountId = invoiceRecById.Account_Services__r.Account__r.Id;
            PageReference pgRef = new PageReference('/apex/EditUploadInvoice?CurrenInvoiceId=' +invoiceRecById.id + '&AccServiceId='+AccntServiceID);        
            pgRef.setRedirect(true);
            return pgRef;
        }
        catch(exception e){
            System.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());            
            return null;
        }        
    }
    
    
    public pagereference InsertUpdateInvoice() 
    {     
        Invoice__c InvoiceId = new Invoice__c();
        try
        {                
            system.debug('---InvoiceId passed--------' + Invoice.Invoice_ID__c);
            ODSInvoiceSessionData__c userSession = ODSInvoiceSessionData__c.getValues( userInfo.getUserId() );
            System.debug('##userSession:' + userSession);
            
            if(userSession != null){
                userSession.UserBillingStartDate__c = BillingStartDate;
                userSession.UserBillingEndDate__c = BillingEndDate;
                update userSession;
            }
            else{
                insert new ODSInvoiceSessionData__c(SetupOwnerId=UserInfo.getUserId(), UserBillingStartDate__c=BillingStartDate, UserBillingEndDate__c=BillingEndDate);
            }
            if(Invoice!=null){
                
                
                //   system.debug('CommentHistory Details :'+CommentHistory);
                system.debug('##BillingStartDate:' +BillingStartDate + '###:' +BillingEndDate);
                system.debug('invoicecomment '+ CommentData);
                system.debug('Invoice.Status__c '+ Invoice.Status__c);
                system.debug('emailSubject----'+emailSubject);
                system.debug('Invoice.Email_Body__c----'+Invoice.Email_Body__c);
                if(Invoice.Status__c == 'Submitted')
                {
                    
                    InvoiceId = ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetails(CurrentAccServiceId,accountId,serviceId,Invoice.Month__c, Invoice.Year__c,CommentData, Invoice.Invoice_ID__c,Invoice.Status__c,
                                                                                    BillingStartDate , BillingEndDate,toAddress,ccAddress,emailSubject,Invoice.Email_Body__c);
                    sendEmail(InvoiceId.Id,toAddress,ccAddress);
                    Invoice.Status__c = '';
                    toAddress = '';
                    system.debug('Submitted Start date :'+ InvoiceId.Billing_Start_Date__c + ' Submitted  End Date:'+ InvoiceId.Billing_End_Date__c);
                    
                }
                
                else
                {
                    
                    InvoiceId = ODS_Data_Utility_Invoice.InsertUpdateInvoiceDetails(CurrentAccServiceId,accountId,serviceId,Invoice.Month__c, Invoice.Year__c,CommentData, Invoice.Invoice_ID__c,Invoice.Status__c,
                                                                                    BillingStartDate , BillingEndDate,toAddress,ccAddress,emailSubject,Invoice.Email_Body__c);
                    updateTheEmailMessageInVoice(InvoiceId.Id);
                    toAddress = '';
                    system.debug('Updated Start date :'+ InvoiceId.Billing_Start_Date__c + ' Updated End Date:'+ InvoiceId.Billing_End_Date__c);
                    
                } 
                
            }
        }
        catch(Exception e)
        {
            system.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());            
            
        }
        PageReference pgRef = new PageReference('/apex/EditUploadInvoice?CurrenInvoiceId=' +InvoiceId.Id + '&AccServiceId='+CurrentAccServiceId);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public pagereference redirectToInvoice()
    {
        
        
        Pagereference pgRef = new PageReference('/apex/Invoice');
        pgRef.setRedirect(true);
        return pgRef ;
        
        
    }
    public pagereference redirectToInvoiceList()
    {
        system.debug('I am called');
        try{   
            ODS_Common_Utility.upsertSessionData(AccountId,ServiceID);
            Pagereference pgRef = new PageReference('/apex/Invoice?accntId='+AccountId+'&srvcId='+ServiceID);
            pgRef.setRedirect(true);
            return pgRef ;
        }
        catch(exception e)
        {
            system.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());            
            return null;
        }
    }
    public PageReference attachFile()
    {
        try{
            filename=Apexpages.currentPage().getParameters().get('filename');
            string body=Apexpages.currentPage().getParameters().get('blobBody');
            string actualBodyString = body.substring(body.indexOf('base64,')+7);
            blobBody=EncodingUtil.base64Decode(actualBodyString);
            CurrenInvoiceId = ApexPages.CurrentPage().getParameters().get('CurrenInvoiceId');
            system.debug('Test file---'+filename+'--blob--'+EncodingUtil.base64Decode(actualBodyString)+' id---'+CurrenInvoiceId+'--fileType--'+fileType);
            
            
            if(filename !=null)
            {
                transient blob blobFileData = blobBody;
                
                ContentVersion conVer = new ContentVersion();
                ContentDocumentLink cdl = new ContentDocumentLink();
                string contVerId = '';
                if(CurrenInvoiceId != '' || CurrenInvoiceId != null)
                    
                {
                    conVer.ContentLocation = 'S';
                    conVer.PathOnClient = filename; 
                    conVer.Title = filename; 
                    conVer.VersionData = blobFileData; 
                    conVer.Type__c = fileType;
                    
                    insert conVer; 
                    contVerId = conVer.Id;
                    system.debug('conVerconVer'+conVer);
                    //  if(Test.isRunningTest()){
                    if(!Test.isRunningTest()){
                        id contentdocumentid = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
                        cdl.ContentDocumentId = contentdocumentid;
                        cdl.LinkedEntityId = CurrenInvoiceId;
                        cdl.ShareType = 'I';
                        cdl.Visibility = 'AllUsers';
                        insert cdl;
                        system.debug('cdlcdlcdl'+cdl);
                        ContentDocumentLink cdltoDelete = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink where ContentDocumentId=: contentdocumentid and LinkedEntityId !=: CurrenInvoiceId];
                        
                        delete  cdltoDelete; 
                    }
                    ContentVersion insertedContVersion = new ContentVersion();
                    if(fileType == 'Invoice' && string.isNotEmpty(contVerId ) )
                    {
                        insertedContVersion = [select ID, CreatedById, CreatedDate, Title From ContentVersion where Id=:contVerId];
                        Invoice__c InvoiceRecord = new Invoice__c (id=CurrenInvoiceId);
                        InvoiceRecord.Uploaded_by__c = insertedContVersion.CreatedById;
                        InvoiceRecord.Uploaded_Date__c = insertedContVersion.CreatedDate;
                        InvoiceRecord.Attachment_File__c = filename;
                        Update InvoiceRecord;   
                    }
                    
                }
            }
            PageReference pgRef = new PageReference('/apex/EditUploadInvoice?CurrenInvoiceId=' +CurrenInvoiceId + '&AccServiceId='+CurrentAccServiceId);
            pgRef.setRedirect(true);
            return pgRef;
        }
        Catch(exception e){
            system.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }
    public PageReference attachTimeSheet()
    {
        try{
            CurrenInvoiceId = ApexPages.CurrentPage().getParameters().get('CurrenInvoiceId');
            system.debug('CurrenInvoiceId---'+CurrenInvoiceId);
            Invoice__c Invoice = new Invoice__c();
            Invoice = [SELECT CreatedDate, CreatedById,Billing_Start_Date__c,Billing_End_Date__c,CreatedBy.Name,LastModifiedDate, Account_Services__r.Account__c, Account_Services__r.Account__r.ID, Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Account_Services__r.ODS_Services__c,Account_Services__r.ODS_Services__r.Name, Attachment_Id__c,Comments__c, Month__c,Year__c, Id FROM Invoice__c where id =:CurrenInvoiceId ];
            Timesheet__c  tsTosendEmail = new Timesheet__c();
            tsTosendEmail = [Select Id, Name, Approver_Name__c,Approver_Email__c, Comments__c,Approver_Name__r.Name,Status_Date__c,
                             Week_Start_Date__c,Week_End_Date__c,Account_Services__c,Account_Services__r.Account__c, Account_Services__r.Account__r.name, 
                             Account_Services__r.ODS_Service_Name__c,Account_Services__r.Technical_Account_manager__r.Name, 
                             Account_Services__r.Technical_Account_manager__r.Email, Account_Services__r.Backup_CSM__r.Email, 
                             Status__c from Timesheet__c where Account_Services__r.Account__c =: AccountId AND Week_Start_Date__c=:  invoice.Billing_Start_Date__c AND Week_End_Date__c=: invoice.Billing_End_Date__c];
            
            Date StartDate = tsTosendEmail.Week_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy'); 
            
            Date EndDate = tsTosendEmail.Week_End_Date__c;
            String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            
            String[] bccAddress = new List<String>();      
            String AccSerId= tsTosendEmail.Account_Services__c;
            string timshtCmts = '';
            PageReference pdf = Page.ODS_ExportTimesheet;
            
            pdf.getParameters().put('Weekfromdate',FromDate);
            System.debug('@@@@@@@@FromDate------------'+FromDate);
            pdf.getParameters().put('Weektodate',ToDate);
            System.debug('@@@ToDate------------'+ToDate);
            pdf.getParameters().put('Accountservice',AccSerId);
            System.debug('@@@@@@@@@AccSerId------------'+AccSerId);
            
            // the contents of the attachment from the pdf
            Blob body;
            
            try {
                // returns the output of the page as a PDF
                body = pdf.getContent();
                System.debug('@@@@@@@@@body ------------'+body );
            } 
            catch (VisualforceException e) {
                body = Blob.valueOf('Weekly Timesheet');
            }
            string formattedStartDate = (tsTosendEmail.Week_Start_Date__c).format().replace('/','-');
            string formattedEndDate = (tsTosendEmail.Week_End_Date__c).format().replace('/','-');
            
            
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = PassAccountName+ ' ' +formattedStartDate + ' - ' +formattedEndDate+'.pdf'; 
            conVer.Title = PassAccountName+ ' ' +formattedStartDate + '--' +formattedEndDate+'.pdf'; 
            conVer.VersionData = body; 
            conVer.Type__c = 'Timesheet'; 
            //conVer.Candidate_ID__c=null;
            insert conVer;   
            
            system.debug('conVer////'+conVer);
            // First get the Content Document Id from ContentVersion Object
            if(!Test.isRunningTest()){
                ContentDocumentLink cdl = new ContentDocumentLink();
                id contentdocumentid = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
                cdl.ContentDocumentId = contentdocumentid;
                cdl.LinkedEntityId = CurrenInvoiceId;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                //cdl.ShareType = 'V';
                insert cdl;
                
                ContentDocumentLink cdltoDelete = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink where ContentDocumentId=: contentdocumentid and LinkedEntityId !=: CurrenInvoiceId];
                
                delete  cdltoDelete; 
                system.debug('conDocLink????/////'+cdl); 
            }
            PageReference pgRef = new PageReference('/apex/EditUploadInvoice?CurrenInvoiceId=' +CurrenInvoiceId + '&AccServiceId='+CurrentAccServiceId);
            pgRef.setRedirect(true);
            return pgRef;
        }
        catch(exception e){
            system.debug('e-'+e);
            system.debug(e.getLineNumber());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;       
        }
    } 
    
    public List<SelectOption> getInvoiceStatus {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Invoice__c.Status__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    
    
    @Future(Callout = true)
    public Static void sendEmail(string InvoiceId, string userEnteredEmails, string userEnteredCCAddress)
    {
        try{
            List<String> lstToAddress = new List<String>();
            List<String> lstCcAddress = new List<String>();
            List<String> lstBccAddress = new List<String>();
            string invoiceTeamMailIdLabel = System.Label.ODS_InvoiceTeam;
            string practiceHeadMailIdLabel = System.Label.ODS_PracticeHeadEmail;
            Set<String> setCcAddress = new Set<String>();        
            Invoice__c Invoice = new Invoice__c();
            List<Contact_Account_Service__c > contactList = new List<Contact_Account_Service__c >(); 
            List<string> userEnteredEmailList = new List<string>();
            List<string> userEnteredCCAddressList = new List<string>();
            if(!string.isEmpty(userEnteredEmails))
            {
                userEnteredEmailList = userEnteredEmails.split(',');
                for(string emailAddress: userEnteredEmailList)
                {
                    lstToAddress.add(emailAddress); 
                    
                }
                system.debug('User entered email ' +userEnteredEmailList);
            }
            if(!string.isEmpty(userEnteredCCAddress))
            {
                userEnteredCCAddressList = userEnteredCCAddress.split(',');
                for(string ccAddress: userEnteredCCAddressList)
                {
                    lstCcAddress.add(ccAddress); 
                    
                }
                system.debug('User entered email ' +userEnteredCCAddressList);
            }
            Invoice = [SELECT Subject__c,Email_Body__c,CreatedDate, CreatedById,Billing_Start_Date__c,Billing_End_Date__c,CreatedBy.Name,LastModifiedDate, Account_Services__r.Account__c, Account_Services__r.Account__r.ID, Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Account_Services__r.ODS_Services__c,Account_Services__r.ODS_Services__r.Name,Comments__c, Month__c,Year__c, Id FROM Invoice__c where id =:InvoiceId ];
            
            /*contactList =[SELECT ID,AccountId__c,Contact__r.AccountId,Email__c,Name,ODS_Service__c FROM Contact_Account_Service__c WHERE Contact__r.AccountId =: Invoice.Account_Services__r.Account__r.ID AND ODS_Service__c =:Invoice.Account_Services__r.ODS_Services__c AND Is_Approver__c = True];
            for(Contact_Account_Service__c contactMailId:contactList)
            {
                if(contactMailId.Email__c != null)
                {
                    lstToAddress.add(contactMailId.Email__c);      
                }
                system.debug('####@@lstToAddress:' +lstToAddress);
            }*/
            
            List<Attachment> attachmentList = new List<Attachment>();
            
            attachmentList = [SELECT id,Name,Body,ParentId FROM Attachment WHERE ParentId =: InvoiceId];
            
            List<ContentDocumentLink> conDocLink = new List<ContentDocumentLink>();
            conDocLink = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =: InvoiceId];
            Set<Id> contDocLinkSet = new Set<Id>();        
            for(ContentDocumentLink conDoc: conDocLink){
                contDocLinkSet.add(conDoc.ContentDocumentId);
            }
            
            List<ContentVersion> conVersList = new List<ContentVersion>();       		
            conVersList=[SELECT Id,Title,Type__c,ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId IN : contDocLinkSet];         
            
            if(invoiceTeamMailIdLabel != null)
            {
                lstBccAddress.add(invoiceTeamMailIdLabel);        
            }
            if(practiceHeadMailIdLabel != null)
            {
                lstCcAddress.add(practiceHeadMailIdLabel);        
            }
            
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            if(attachmentList.size()>0){
                for(Attachment a: attachmentList)
                {
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    efa.setInline(false);
                    efa.setContentType('application/pdf');
                    fileAttachments.add(efa);
                }
            }
            
            if(conVersList.size()>0){
                for(ContentVersion c: conVersList)
                {
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(c.Title);
                    efa.setBody(c.VersionData);
                    efa.setInline(false);
                    efa.setContentType('application/pdf');
                    fileAttachments.add(efa);
                }
            }
            
            system.debug('fileAttachments :' + fileAttachments);
            OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where Address=:Label.ODS_Invoice_Sender_Email];
            
            Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
            mail.setToAddresses(lstToAddress);
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            //mail.setSenderDisplayName(Label.ODS_Invoice_Sender);
            mail.setCcAddresses(lstCcAddress);
            mail.setBccAddresses(lstBccAddress);
            String subject =Invoice.Subject__c;
            mail.setSubject(subject);  
            string baseURL= URL.getSalesforceBaseUrl().toExternalForm(); 
            String strHtmlBody = Invoice.Email_Body__c;       
            strHtmlBody +='<p><span style="font-size: 16px; font-family: Times New Roman, serif;">Thanks!</span></p> <table class="ql-table-blob" style="font-family: "Times New Roman"; border: none;"> <tbody> <tr> <td style="width: 473.4pt; border-top: 1.5pt solid rgb(79, 200, 243); border-left: none; border-bottom: 1.5pt solid black; border-right: none; padding: 0cm 5.4pt; height: 7.2pt; vertical-align: top;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; line-height: 17.25px;"><span style="font-size: 16px; line-height: 18.4px; font-family: "Times New Roman", serif;"> </span></p> </td> </tr> <tr> <td style="width: 473.4pt; border-top: none; border-right: none; border-left: none; border-image: initial; border-bottom: 1.5pt solid black; padding: 0cm 5.4pt; vertical-align: top;"> <table style="border: none; width: 468pt;"> <tbody> <tr> <td style="width: 272.425px; padding: 10.8pt 5.75pt;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; text-align: center; line-height: 17.25px;"><a href="https://www.levelshift.com/"><img width="268" height="72" src="'+Label.ODS_Email_Signature_Logo_WB_Url+'"></a></p> </td> <td style="width: 3px; padding: 10.8pt 5.75pt; vertical-align: bottom;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; text-align: center; line-height: 17.25px;"><span style="font-size: 16px; line-height: 18.4px; font-family: "Times New Roman", serif;"><img width="3" height="86" src="https://www.levelshift.com/wp-content/uploads/2018/04/mail-linessm.jpg" alt="https://www.levelshift.com/wp-content/uploads/2018/04/mail-linessm.jpg"></span></p> </td> <td style="width: 317.925px; padding: 0cm;"> <table style="border: none; width: 234pt; margin-left: 4.45pt;"> <tbody> <tr> <td style="width: 234pt; padding: 0cm 0cm 0cm 5.75pt;"> </td> </tr> <tr> <td style="width: 234pt; padding: 0cm 0cm 0cm 5.75pt;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; line-height: 14pt;"><strong><em><span style="font-size: 16px; font-family: Times New Roman, serif; color: rgb(79, 200, 243);">'+Label.ODS_Invoice_Sender+'</span></em></strong></p> </td> </tr> <tr> <td style="width: 234pt; padding: 0cm;"> <table style="border: none; width: 225pt;"> <tbody> <tr> <td style="width: 35.45pt; padding: 0cm 5.4pt; vertical-align: top;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; line-height: 14pt;"><span style="font-size: 16px; font-family: Times New Roman, serif;">Email</span></p> </td> <td style="width: 13.5pt; padding: 0cm 5.4pt; vertical-align: top;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; line-height: 14pt;"><span style="font-size: 16px; font-family: Times New Roman, serif;">:</span></p> </td> <td style="width: 176.05pt; padding: 0cm 5.4pt; vertical-align: top;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; line-height: 14pt;"><span style="font-size: 16px; font-family: Times New Roman, serif;"><a href="mailto:invoice@levelshift.com">'+Label.ODS_Invoice_Sender_Email+'</a></span></p> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> <tr> <td style="width: 473.4pt; border-top: none; border-right: none; border-left: none; border-image: initial; border-bottom: 1.5pt solid rgb(79, 200, 243); padding: 0cm 5.4pt; height: 3.6pt; vertical-align: top;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; line-height: 17.25px;"><span style="font-size: 16px; line-height: 18.4px; font-family: Times New Roman, serif;"> </span></p> </td> </tr> <tr> <td style="width: 473.4pt; padding: 5.75pt;"> <p style="margin: 0cm; font-size: 15px; font-family: Calibri, sans-serif; text-align: justify; line-height: 17.25px;"><strong><span style="font-size: 16px; line-height: 18.4px; font-family:Times New Roman, serif; color: red;">CONFIDENTIALITY STATEMENT:</span></strong><span style="font-size: 16px; line-height: 18.4px; font-family: Times New Roman, serif; color: rgb(166, 166, 166);"> The information contained in this communication is confidential and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p> </td> </tr> </tbody> </table> <p><br></p>';

            mail.setHtmlBody(strHtmlBody);
            mail.setFileAttachments(fileAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(exception e){
            system.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());                        
        }
        
    }  
    
    public List<SelectOption> getContentVersionType {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : ContentVersion.Type__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    @RemoteAction
    global static string validateOnSubmitUpdated(String CurrentInvoiceId){
        
        try{        
            string cType = '';  
            Set<id> cdl = new Set<id>(); 
            List<ContentDocumentLink> contDocLinkList = new List<ContentDocumentLink>();
            List<ContentVersion> contVersList = new List<ContentVersion>();  
            if(CurrentInvoiceId != Null || CurrentInvoiceId != ''){                    
                contDocLinkList = [SELECT id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: CurrentInvoiceId];                    
                if(!contDocLinkList.isEmpty()){               
                    for(ContentDocumentLink cl : contDocLinkList){
                        cdl.add(cl.ContentDocumentId);
                    }
                    
                    for(ContentVersion c : [SELECT id,Type__c,ContentDocumentId FROM COntentVersion WHERE ContentDocumentId IN: cdl]){
                        if(c.Type__c == 'Timesheet'){
                            cType = cType + 'T';                        
                        }
                        else if(c.Type__c == 'Invoice'){
                            cType = cType + 'I';                        
                        }                 
                    }       
                }
                else{
                    cType ='';            
                }    
                
            }
            return cType; 
        } 
        catch(exception e){
            system.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            return null;
        }
    }
    public Static void updateTheEmailMessageInVoice(string InvoiceId){
        try{
            Invoice__c Invoice = [SELECT Email_Body__c,Subject__c,CreatedDate, Invoice_CC__c,CreatedById,Billing_Start_Date__c,Billing_End_Date__c,CreatedBy.Name,LastModifiedDate, Account_Services__r.Account__c, Account_Services__r.Account__r.ID, Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Account_Services__r.ODS_Services__c,Account_Services__r.ODS_Services__r.Name,Comments__c, Month__c,Year__c, Id FROM Invoice__c where id =:InvoiceId ];
            datetime stDate=Invoice.Billing_Start_Date__c;
            //string st=string.valueOf(stDate.year())+'-'+string.valueOf(stDate.month())+'-'+string.valueOf(stDate.day());
            datetime eDate=Invoice.Billing_End_Date__c;
            //string ed=string.valueOf(eDate.year())+'-'+string.valueOf(eDate.month())+'-'+string.valueOf(eDate.day());
            if(Invoice.Subject__c ==null || Invoice.Subject__c =='')
            {
                String subject = 'Levelshift Invoice for Salesforce On Demand Services - '+stDate.formatGMT('MM-dd-YYYY')+' to '+eDate.formatGMT('MM-dd-YYYY');
                Invoice.Subject__c=subject;
            }
            if(Invoice.Email_Body__c ==null || Invoice.Email_Body__c =='')
            {
                String strHtmlBody ='<html><head> Hi, <br/><br/> Please find attached the Invoice with Timesheets for Salesforce on Demand Services – '+stDate.formatGMT('MM-dd-YYYY')+' to '+eDate.formatGMT('MM-dd-YYYY')+'.<br/>Please confirm the receipt and reach us if you have any questions!';
                Invoice.Email_Body__c=strHtmlBody;
            }
            Update Invoice;
        } 
        catch(exception e){
            system.debug(e);
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }  
    }    
    
}