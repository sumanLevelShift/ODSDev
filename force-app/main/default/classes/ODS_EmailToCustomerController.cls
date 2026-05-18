/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       ODS_EmailToCustomerController
* @description      This is the class For ODS_EmailToCustomer Page
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	25 SEP 2020    	DemandBlue 		Initial Development
* 2        	07 DEC 2020    	DemandBlue 		After sending draft email, that draft email should be deleted - functionality added
*********************************************************************************************/
global class ODS_EmailToCustomerController {
    //Properties for email to Customer page
    public string currentUserId {get;set;}
    //public LIST<Account> accountList{get;set;}
    public List<Account_Services__c> accountServiceList {get;set;}
    Map<Id, Account_Services__c> customersMap {get;set;}    
    public List<DraftEmail__c> draftEmailList {get; set;}
    public DraftEmail__c draftEmail {get; set;}
    //public List<Documents__c> Documents {get; set;}
    public String selectedCustomerNames {get;set;}
    public String savedCustomerIds {get;set;}
    public string AccountServiceID {get;set;} 
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public Attachment attachment1 {
        get {
            if (attachment1 == null)
                attachment1 = new Attachment();
            return attachment1;
        }
        set;
    }
    public Attachment attachment2 {
        get {
            if (attachment2 == null)
                attachment2 = new Attachment();
            return attachment2;
        }
        set;
    }
    //public string StringJSON {get;set;}
    //public string AttachmentIds {get;set;}
    public SelectOption[] selectedCustomers { get; set; }
    public SelectOption[] allCustomers { get; set; }    
    //public String Message { get; set; }
    public string draftMailId {get;set;}
    List<ID> selectedCustomerIds = new List<ID>();
    //Account Pagination porperty
    public Integer PageSize {get;set;}
    public Integer CurrentPage {get;set;}
    public Boolean ShowPrevious {get;set;}
    public Boolean ShowNext {get;set;}
    public String CurrentPageInfo {get;set;}
    public Integer TotalRecords;
    public Integer PageNumber;    
    
    public ODS_EmailToCustomerController()
    {        
        currentUserId = UserInfo.getUserId();
        system.debug('currentUserId'+ currentUserId);
        draftEmail = new DraftEmail__c();
        selectedCustomers = new List<SelectOption>();
        //Documents = new List<Documents__c>();            
        allCustomers = new List<SelectOption>();
        //draftEmailList = new List<DraftEmail__c>();
        getCustomers();
        getDraftEmails();
        //FetchDocuments();
        
    }
    public void GetAccountServices(){
        List<Account_Services__c > accServList = new List<Account_Services__c >();
        accServList = ODS_Data_Utility.fetchAccServcesByServiceAccount(AccountId, ServiceId);        
        if(accServList.size() > 0){
            AccountServiceID = accServList[0].Id;
        }
        else{
            AccountServiceID = '';
        }
    }
    
    public PageReference GetTimesheetByAccountServiceID() {        
        ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);
        GetAccountServices();
        return null;
    }
    
    public void getCustomers(){   
        
        List<SelectOption> customersList = new  list<SelectOption>();
        ODS_Common_Utility objUtility = new  ODS_Common_Utility();
        accountServiceList = new LIST<Account_Services__c>(); 
        selectedCustomers = new List<SelectOption>();
        allCustomers = new List<SelectOption>();
        customersList = objUtility.getCustomersByLoggedInUser('');        
        if(customersList != null && customersList.size() > 0){
            for(SelectOption accountService: customersList) {                 
                If(accountService.getValue() != 'All' && !listContains(allCustomers, new SelectOption(accountService.getValue(), accountService.getLabel()))){                   
                    allCustomers.add(new SelectOption(accountService.getValue(), accountService.getLabel()));
                }
            }
        }
        string fetchSrvceQuery = 'SELECT Account__c, Account__r.Name, Contract_End_Date__c, ODS_Services__c, ODS_Services__r.Name__c, '+
            ' Technical_Account_manager__r.Email,Backup_CSM__r.Email,Customer_Success_Executive__r.Email, Account__r.Primary_Customer_Email_Id__c, Technical_Account_manager__c FROM Account_Services__c WHERE Account__r.Is_Portal_Access__c = true AND Account__r.Count_of_Services__c > 0 ORDER BY Account__r.Name ASC ';
        accountServiceList = database.query(fetchSrvceQuery);
        customersMap = new Map<Id, Account_Services__c>();
        for(Account_Services__c accountService : accountServiceList)
        {
            customersMap.put(accountService.Account__c, accountService);
        }       
        //return accountServiceList;
    }
    
    public Boolean listContains(Object[] source, Object target){
        return (new Set<Object>(source)).contains(target);
    }
    
    public void getDraftEmails(){
        draftEmailList = new List<DraftEmail__c>();
        string fetchEmailQuery = 'SELECT Name, CustomerIds__c, EmailBody__c, EmailSubject__c, EmailStatus__c, OwnerId, DocumentIds__c,CreatedDate,LastModifiedDate FROM DraftEmail__c WHERE OwnerId =: currentUserId AND IsDeleted__c = false ORDER BY CreatedDate DESC';
        draftEmailList = database.query(fetchEmailQuery);
        CurrentPage = 0; 
        PageNumber = 1; 
        ShowPrevious = false;
        PageSize = 5;//integer.valueof(System.Label.PageSize); // No. of rows per page
        if(draftEmailList.size() > 0){
            TotalRecords = draftEmailList.size();  // Total No of records need to display in Grid.   
            if(TotalRecords > PageSize)
                ShowNext = true;
            else
                ShowNext = false;     
            
            CurrentPageInfo = 'Showing Page ' + PageNumber + ' of ' + (Math.mod(TotalRecords, PageSize) == 0 ? TotalRecords/PageSize : (TotalRecords/PageSize) + 1); 
        }
        ///return draftEmailList;
    }    
    
    //public void saveDraftEmail(String EmailSubject,String EmailBody,String CustomerIds){
    public PageReference saveDraftEmail(){
        try{
            if(draftEmail.EmailSubject__c != null && draftEmail.EmailBody__c != null){            
                draftEmail.EmailStatus__c = 'Draft';
                List<string> attachmentIds = new List<string>();
                draftEmail.CustomerIds__c = getSelectedCustomers();
                //if(attachment1.body != null){
                //string fileExtension = attachment1.Name.substring(attachment1.Name.lastIndexOf('.') + 1);
                //string attachment1Id = InsertUpdateDocumentDetails('Other',attachment1.body,attachment1.Name,'','',fileExtension);
                //attachmentIds.add(attachment1Id);
                //}
                //if(attachment2.body != null){
                // string fileExtension = attachment2.Name.substring(attachment2.Name.lastIndexOf('.') + 1);
                //string attachment2Id = InsertUpdateDocumentDetails('Other',attachment2.body,attachment2.Name,'','',fileExtension);
                //attachmentIds.add(attachment2Id);
                //}           
                //draftEmail.DocumentIds__c = string.join(attachmentIds,',');           
                insert draftEmail;
                clearControls();
                getCustomers();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'<font color="green" size = "4"> Email was saved successfully.</font>'));
                //ID[] attachmentId = UploadAttachments(draftEmail.Id);
                
                //system.debug('attachmentIds====' + attachmentId);
                //draftEmail.DocumentIds__c = CustomerIds;
                //update draftEmail;
            }
        }
        catch(exception e){            
            system.debug('Error Occured::: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured on saving Email::: <font color="red" size = "4">' + e.getMessage() + '</font>'));
        }  
        PageReference pgRef = new PageReference('/apex/ODS_EmailToCustomer');
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public PageReference deleteDraftEmail(){ 	
        DraftEmail__c draftEmailObj = new DraftEmail__c();
        try{            
            string draftEmailId = System.currentPageReference().getParameters().get('DraftEmailId');        	
            if(draftEmailId != null && String.isNotBlank(draftEmailId)){
                deleteDraftEmail(draftEmailId);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'<font color="green" size = "4">Draft Email deleted successfully.</font>'));
            }
        }
        catch(exception e){            
            system.debug('Error Occured::: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'<font color="red" size = "4">Error on deleting Draft Email.</font>'));
        }       
        PageReference pgRef = new PageReference('/apex/ODS_EmailToCustomer');
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public void deleteDraftEmail(String DraftEmailID){ 	
        DraftEmail__c draftEmailObj = new DraftEmail__c();
        try{
            if(DraftEmailID != null && String.isNotBlank(DraftEmailID)){
                draftEmailObj  = [Select Id,IsDeleted__c From DraftEmail__c where Id=:DraftEmailID Limit 1];
                if(draftEmailObj != null){
                    //draftEmailObj.IsDeleted__c = true;
                    //update draftEmailObj;
                    delete draftEmailObj;                    
                } 
            }
        }
        catch(exception e){            
            system.debug('Error Occured::: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'<font color="red" size = "4">Error on deleting Draft Email.</font>'));
        }
    }
    
    public string getSelectedCustomers() {
        String strCustomerIds = '';
        Boolean first = true;
        for (SelectOption customerId : selectedCustomers) {            
            if (!first) {
                strCustomerIds += ',';
            }
            strCustomerIds += customerId.getValue();
            first = false;
        }
        
        return strCustomerIds;       
    }  
    public void clearControls() {
        attachment1 = new Attachment();
        attachment2 = new Attachment();
        draftEmail = new DraftEmail__c();
        selectedCustomers = new List<SelectOption>();
        allCustomers = new List<SelectOption>();
        savedCustomerIds = '';
        draftMailId = '';
    } 
    
    @RemoteAction
    global static string getCustomerNames(String SelectedCustomerIds){
        String strCustomerNames = '';
        String strCustomerIds = '';
        Boolean first = true;
        if(string.isNotBlank(SelectedCustomerIds)){
            string customerIds = SelectedCustomerIds.deleteWhitespace();
            List<String> listCustomerIds = customerIds.split(',');
            for(Account_Services__c account : [SELECT Account__c, Account__r.Name FROM Account_Services__c WHERE Account__c IN:listCustomerIds ORDER BY Account__r.Name ASC]){
                if (!first) {
                    strCustomerNames += ', ';
                    strCustomerIds += ',';
                }
                strCustomerNames += account.Account__r.Name;
                strCustomerIds += account.Account__c;
                first = false;
            }
        }
        return strCustomerNames + '|' + strCustomerIds;
    }  
    //public string InsertUpdateDocumentDetails(string documentType,Blob fileData,string fileName,string documentId,string folderId,string fileExtension)
    //{
    //string attachmentId = '';
    ////Insert the Document Details into Document Object
    // Documents__c documents = null;
    // DateTime nowDT=System.now();
    // if(documentId == '' || documentId ==null)
    // {
    //     //system.debug('---InsertMethod---'+ accountId + '---'+serviceId+'----'+name);
    //    documents = new Documents__c();      
    //    //documents.Account__c = accountId;
    //    //documents.Account_Services__c = serviceId;
    //    documents.Document_Type__c = documentType;
    //    documents.Name = filename.trim() + '_' + string.valueofGmt(nowDT);
    //    //documents.Project_Name__c = projectName;
    //    //documents.SprintNumber__c =  sprintNumber;
    //    documents.Attachment_File__c = filename;
    //    documents.File_Extension__c =fileExtension;
    //    if(folderId != null && folderId !='')
    //    {
    //        documents.FolderId__c = folderId;
    //    }
    //    insert documents ;
    //    attachmentId = documents.Id;
    //}
    //else
    //{
    //    //system.debug('---UpdateMethod---'+ documentId);
    //    documents = new Documents__c(id=documentId);
    //    documents.Document_Type__c = documentType;
    //    documents.Name = filename.trim() + '_' + string.valueofGmt(nowDT);
    //    //documents.Project_Name__c = projectName;
    //    //documents.SprintNumber__c =  sprintNumber;
    //    documents.Attachment_File__c = fileName;
    //    if(fileExtension != null && fileExtension !='')
    //    {
    //         documents.File_Extension__c = fileExtension;
    //    }
    //    if(folderId != null && folderId !='')
    //   {
    //       documents.FolderId__c = folderId;
    //   }
    //   else
    //   {
    //       documents.FolderId__c = null;
    
    // }
    
    // //documents.File_Extension__c =fileExtension;
    
    // update documents ;
    // attachmentId = documentId;
    //}
    //transient blob blobFileDate = fileData;
    
    ////Inserts the attachment into Attachment object
    //Attachment attachment= null;
    //if(documentId == '' || documentId == null)
    //{
    //    attachment= new Attachment(); 
    //    attachment.parentId = documents.Id;
    //    attachment.body = blobFileDate;
    //    attachment.Name = filename.trim() + '_' + string.valueofGmt(nowDT);
    //    insert attachment;
    //}
    //else
    //{   
    //    //system.debug('---UpdateMethod---Else---FileName'+filename );
    //    if(blobFileDate != null)
    //    {    
    //       //system.debug('---UpdateMethod---Else If');
    //       Documents__c[] documentsData =  [Select Id,Attachment_Id__c from Documents__c where Id=:documentId];  
    //       attachment= new Attachment(id=documentsData[0].Attachment_Id__c);             
    //       attachment.body= blobFileDate;
    //       attachment.Name = filename.trim() + '_' + string.valueofGmt(nowDT);
    //       update attachment;
    //   }
    //}
    
    // //Updates the attachentid into documents object
    // if(documentId == '' || documentId ==null)
    // {
    //     Documents__c queryDocuments= [SELECT Id FROM Documents__c WHERE Id =: documents.Id LIMIT 1];
    //     queryDocuments.Attachment_Id__c = attachment.Id;
    //     update queryDocuments;
    // }
    
    // return attachmentId;
    //}
    
    /// <OBJECTIVE>
    /// Method to Document and Attachment Details. Document and Attachment JSON results is concat with delimeter $$##
    /// <OBJECTIVE>
    //@RemoteAction
    // global static string GetDocumentAttachment(string DraftEmailId,string DocumentIds) {
    //		string documentAttachmentJSON = '';
    //    try
    //    {
    //        if(DocumentIds != null){
    //            documentAttachmentJSON =  FetchDocuments(DocumentIds);              
    //        }                        
    //    }
    //   catch(Exception ex)
    //    {
    //       system.debug(ex);
    //   }
    //   return documentAttachmentJSON;
    //}  
    ///<OBJECTIVE>
    ///Get the Document details
    ///</OBJECTIVE>    
    //public static string FetchDocuments(string attachmentIds){ 
    //    //string strDocIds = 'a0G3D000001r6XsUAI'+','+ 'a0G3D000001r6Y2UAI';
    //    string attachmentJSON = '';
    //    string attachmentIdsJSON = '';
    //    if(attachmentIds != null){
    //        system.debug('AttachmentIds=======>' + attachmentIds);
    //    	List<string> DocIdsList = attachmentIds.split(',');
    //    	string fetchEmailQuery = 'SELECT id,CreatedDate,File_Extension__c ,Image_URL__c,name,Attachment_Id__c,CreatedById,CreatedBy.name FROM Documents__c WHERE Is_Deleted__c = false AND Id IN: DocIdsList' ;
    //    	system.debug('fetchEmailQuery=======>' + fetchEmailQuery);
    //    	List<Documents__c> documents = database.query(fetchEmailQuery);
    //        if(documents != null){
    //         	Boolean first = true;
    //     		for (Documents__c documentObj : documents) {            
    //                if (!first){
    ////            		attachmentJSON += ',';  
    //                	attachmentIdsJSON += ',';
    //               }
    //       		attachmentJSON += documentObj.name;
    //               attachmentIdsJSON += documentObj.Attachment_Id__c;
    ////       		first = false;
    //  		}
    //                      }
    //      //attachmentJSON = Json.serialize(Documents);
    //  }
    //  //Documents = ODS_Data_Utility.GetDocuments(AccountId,ServiceId,SelectedFolderID, FromDate, ToDate, FolderOrDocumentName,sortFullExp1);
    // return attachmentJSON + '$$##' + attachmentIdsJSON;
    //}
    //public ID[] UploadAttachments(ID DraftEmailId){
    //   ID[] attachmentIds = new ID[]{};
    //	try {
    //       if(attachment1.body != null){
    //          attachment1.ParentId = DraftEmailId;
    //           insert attachment1;
    //          attachmentIds.add(attachment1.Id);
    //      }
    //      if(attachment2.body != null){
    //          attachment2.ParentId = DraftEmailId;
    //          insert attachment2;
    //          attachmentIds.add(attachment2.Id);
    //      }
    // 	}
    //  catch(DMLException e){
    //		// ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
    //      System.debug('====exception==='+e.getmessage());
    //      return null;
    //	} 
    //  finally {
    //  	//attachment = new Attachment(); 
    //  }
    //      //attachment = new Attachment();
    //     // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    //
    // return attachmentIds;
    
    //}   
    
    /// <OBJECTIVE>
    /// To fetch the documents
    /// </OBJECTIVE>
    // public void FetchDocuments(){ 
    //     //string strDocIds = 'a0G3D000001r6XsUAI'+','+ 'a0G3D000001r6Y2UAI';
    ////     if(AttachmentIds != null){
    ////      system.debug('AttachmentIds=======>' + AttachmentIds);
    // 	List<string> DocIdsList = AttachmentIds.split(',');
    //  	string fetchEmailQuery = 'SELECT id,CreatedDate,File_Extension__c ,Image_URL__c,name,Attachment_Id__c,CreatedById,CreatedBy.name FROM Documents__c WHERE Is_Deleted__c = false AND Id IN: DocIdsList' ;
    //	system.debug('fetchEmailQuery=======>' + fetchEmailQuery);
    //	Documents = database.query(fetchEmailQuery);       
    //}
    ////Documents = ODS_Data_Utility.GetDocuments(AccountId,ServiceId,SelectedFolderID, FromDate, ToDate, FolderOrDocumentName,sortFullExp1);
    //// return null;
    //}
    public PageReference sendEmails(){
        try{
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();           		
            String[] arraySavedCustomers = new String[]{};
                if(string.isNotBlank(savedCustomerIds)){
                    arraySavedCustomers = savedCustomerIds.split(',');
                }
            else{                   
                for(SelectOption customerId : selectedCustomers){
                    arraySavedCustomers.add(customerId.getValue());
                }                    
            }
            for(String strCustomerId : arraySavedCustomers){
                Account_Services__c accountServiceEmail = customersMap.get(strCustomerId);
                if(accountServiceEmail.Account__r.Primary_Customer_Email_Id__c != null && String.IsNotBlank(draftEmail.EmailSubject__c) && String.IsNotBlank(draftEmail.EmailBody__c)){
                    List<String> toEmailAddress = new List<String>{accountServiceEmail.Account__r.Primary_Customer_Email_Id__c}; 
                        if(accountServiceEmail.Technical_Account_manager__r.Email != null){
                            List<String> CsmAndBcsmEmailAddress = new List<String>();
                            CsmAndBcsmEmailAddress.add(accountServiceEmail.Technical_Account_manager__r.Email);                     
                            if(accountServiceEmail.Backup_CSM__r.Email != null)
                                CsmAndBcsmEmailAddress.add(accountServiceEmail.Backup_CSM__r.Email);
                            
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email = getSendEmail(toEmailAddress, CsmAndBcsmEmailAddress,draftEmail.EmailSubject__c,draftEmail.EmailBody__c,'a283D000000Ka27QAC');
                            //List<String> EmailAddressTemp = new List<String>{'gireesh_k@preludesys.com','gireesh_k@preludesys.com'};                       
                            //email = getSendEmail(EmailAddressTemp,EmailAddressTemp,draftEmail.EmailSubject__c,draftEmail.EmailBody__c,'a283D000000Ka27QAC');
                            emailList.add(email);
                        }                     
                }
            }
            if(!emailList.isEmpty()){
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emailList);
                if(draftMailId != null && String.isNotBlank(draftMailId)){
                    deleteDraftEmail(draftMailId);
                }
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'<font color="green" size = "4"> Email(s) sent successfully.</font>')); 
            }                
            clearControls();
            getCustomers();
        }
        catch(exception e){            
            system.debug('Error Occured::: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured on sending Email::: <font color="red" size = "4">' + e.getMessage() + '</font>'));
        }
        PageReference pgRef = new PageReference('/apex/ODS_EmailToCustomer');
        pgRef.setRedirect(true);
        return pgRef;
    } 
    
    //To Send the Customer email
    public Messaging.SingleEmailMessage getSendEmail(List<String> ToEmailAddress,List<String> CcEmailAddress, String EmailSubject,String EmailBody,String DocumentIds){
        System.debug('ToEmailAddress ===> '+ToEmailAddress);
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
            //String[] toAddresses = new String[]{ToEmailAddress};
            mail.setToAddresses(ToEmailAddress);
            //String[] BccAddresses = new String[]{'gireesh_k@preludesys.com'};
            mail.setCcAddresses(CcEmailAddress); 
            //mail.setBccAddresses(BccAddresses);
            mail.setSenderDisplayName(UserInfo.getName());
            // ID[] DocIds = new ID[]{DocumentIds};
            
            Messaging.EmailFileAttachment attachmentOne = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment attachmentTwo = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment[] emailFileAttachments = new Messaging.EmailFileAttachment[]{};
                //if(AttachmentIds != null){
                //    List<string> DocIdsList = attachmentIds.split(',');
                //    if(DocIdsList[0] != null){
                //    for (Attachment attOne : [select Name, Body, BodyLength from Attachment where ID = :DocIdsList[0]])
                //	{
                //		// Add to attachment file list 
                //		//Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                //		attachmentOne.setFileName(attOne.Name);
                //		attachmentOne.setBody(attOne.Body);
                //		emailFileAttachments.Add(attachmentOne);
                //	}
                //    }
                //    if(DocIdsList[1] != null){
                //    for (Attachment attTwo : [select Name, Body, BodyLength from Attachment where ID = :DocIdsList[1]])
                //	{
                //		// Add to attachment file list 
                //		//Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                //		attachmentTwo.setFileName(attTwo.Name);
                //		attachmentTwo.setBody(attTwo.Body);
                //		emailFileAttachments.Add(attachmentTwo);
                //	}
                //    }
                // }
                //  //if(attachementOne != null && attachementTwo != null){
                //  //    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachementOne,attachementTwo});}
                //  //else 
                // 	if(attachment1.Body != null){
                //      attachmentOne.setFileName(attachment1.Name);
                //      attachmentOne.setBody(attachment1.Body);
                //       emailFileAttachments.Add(attachmentOne);}
                //     	//mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachementOne});}
                // if(attachment2.Body != null){
                //     attachmentTwo.setFileName(attachment2.Name);
                //     attachmentTwo.setBody(attachment2.Body);
                //     emailFileAttachments.Add(attachmentTwo);}
                
                //     mail.setFileAttachments(emailFileAttachments);
                // //mail.setEntityAttachments(List<String> param1)
                // //mail.setFileAttachments(List<Messaging.EmailFileAttachment> param1);
                mail.setSubject(EmailSubject);
            mail.setHtmlBody(EmailBody);            
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            return mail;
        }
        Catch(Exception mailException)
        {
            System.debug('Error Occured::: ' + mailException);
            return null;
        }      
    }  
    
    //Account Pagination logic Start
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
    //Account Pagination logic Ends   
    
}