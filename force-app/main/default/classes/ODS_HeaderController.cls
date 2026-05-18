global class ODS_HeaderController
{

    public string AccountId
    {
        get;set;
    }
    public string currentUserName
    {
        get;set;
    }
    
    public Boolean isCustomer
    {
        get;set;
    }
    
    public string PortalUserRole
    {
        get;set;
    }
    public Boolean IsPortalApprover
    {
        get;set;
    }
    public  Contact objContact 
    {
        get;set;
    }
    //public list <Account> accList {get;set;}    
    public string PageName{get;set;}
    public string userPortalRole {get;set;}
    public Boolean isPartner {get;set;}
    public String searchKey {get;set;}
    public Boolean onboardingDocument {get;set;}

    public ODS_HeaderController()
    {
        //PageName = ApexPages.currentPage().GetURL().substringBefore('?').substringafter('/').substringafter('/');
        currentUserName = UserInfo.getName();
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        userPortalRole = String.valueOf(objUser.PortalUserRole__c);
        onboardingDocument=false;
        if(objUser.PortalUserRole__c == 'Customer'){
            isCustomer = true;
        }        
        else{
            isCustomer = false;
        }
        
        if(objUser !=null){
            string username=objUser.Username;
            if(username.contains('sfadmin@demandblue.com')){
                onboardingDocument=true;
            }
        }
        
        if(objUser.PortalUserRole__c == 'Partner') {
            isPartner = true;
        }else {
            isPartner = false;
        }
        string URLString=ApexPages.currentPage().GetURL();
        system.debug('ApexPages.currentPage().GetURL()--'+ApexPages.currentPage().GetURL());
        List<ODS_SessionData__c> sessiondata = ODS_Common_Utility.fetchSessionData(UserInfo.getUserId());
        string PageName = ApexPages.currentPage().GetURL().substringBefore('?').substringafter('/').substringafter('/');
        system.debug('@@@userPortalRole : '+ userPortalRole );
        system.debug('@@@PageName : '+ PageName );
        system.debug('###sessiondata: '+ sessiondata);
        
        if(PageName != 'Dashboard'){
            if(sessiondata.size() == 0){
                AccountId = 'ALL';
                ServiceId = 'All';
                
            }
            else if(PageName == 'ODS_SearchResult'){
                string accountIdFromURL = System.CurrentPageReference().getparameters().get('accntId');
                if(accountIdFromURL != null)
                    AccountId = accountIdFromURL;
                else
                    AccountId = sessiondata[0].Account_Id__c;
            }
            else{
                /* to process the links clicked from the email: E.g: Email – “Customer Success Story to be initiated for initiative” */
                if(URLString.contains('emlrf_ServiceName') && URLString.contains('emlrf_AcccountId')){
                    AccountId=System.CurrentPageReference().getparameters().get('emlrf_AcccountId');
                    ServiceId=System.CurrentPageReference().getparameters().get('emlrf_ServiceName');
                }else{
                    AccountId = sessiondata[0].Account_Id__c;
                    ServiceId = sessiondata[0].Service_Id__c;  
                }
                system.debug('---AccountId'+AccountId);
                system.debug('---ServiceId'+ServiceId);  
            } 
        }
        else{        
            //Else loop for dashboard page. 
            List<SelectOption> lstSlctOptn = new  list<SelectOption>();
            ODS_Common_Utility objUtility = new  ODS_Common_Utility();
            lstSlctOptn = objUtility.getCustomersByLoggedInUser(PageName);          
            if(sessiondata.size() == 0){ // Checks if session data is not saved. 
                if(lstSlctOptn.size() > 0){
                    SelectOption objoption = lstSlctOptn[0];
                    AccountId = objoption.getValue();                
                }
            }
            else{
                if(sessiondata[0].Account_Id__c =='All'){ //if saved then check for account id is all.             
                    if(lstSlctOptn.size() > 0){
                        SelectOption objoption = lstSlctOptn[0];
                        AccountId = objoption.getValue();                                         
                    }              
                }else{             
                    AccountId = sessiondata[0].Account_Id__c;
                    ServiceId = sessiondata[0].Service_Id__c;  
                }
            }            
        }               
    }
    
    
    public void GetLoggedUserAccountService()
    {
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        PortalUserRole = objUser.PortalUserRole__c;
        IsPortalApprover = objUser.Contact.Is_Approver__c;
        if(PortalUserRole == 'Customer')
        {
            List<Contact> cnt = new  List<Contact>();
            cnt = ODS_Data_Utility.FetchAccountIdByCustomer(objUser.ContactId);
            system.debug('###cnt'+cnt);
            if(cnt.size() > 0)
            {
                AccountId = cnt[0].AccountId;
            }
            else
            {
                AccountId = 'All';
            }
            system.debug('###AccountId '+AccountId );
            List<Account_Services__c> accService = new  List<Account_Services__c>();
            accService = ODS_Data_Utility.fetchAccServcesByAcc(AccountId);
            List<Contact_Account_Service__c> contactService = new list<Contact_Account_Service__c >();
            contactService = ODS_Data_Utility.GetAccServiceByContact(objUser.ContactId);
            if(accService.size() > 0)
            {
                ServiceId = accService[0].ODS_Services__c;
            }
            else
            {
                ServiceId = 'All';
            }
        }
        else
        {
            AccountId = 'All';
            ServiceId = 'All';
        }
    }
    
    public void SetRelatedService()
    {

        if(AccountId == 'All')
        {
            ServiceId = 'All';
        }
        system.debug('Acnt$$$'+AccountId );
        PageName = ApexPages.currentPage().GetURL().substringBefore('?').substringafter('/').substringafter('/');
              
        system.debug('^^^'+PageName);
    }
    
    public string ServiceId
    {
        get;set;
    }
    
    public List<SelectOption> GetAccountPicklistValues()
    {
        List<SelectOption> lstSlctOptn = new  list<SelectOption>();
        ODS_Common_Utility objUtility = new  ODS_Common_Utility();
        string PageName = ApexPages.currentPage().GetURL().substringBefore('?').substringafter('/').substringafter('/');
        lstSlctOptn = objUtility.getCustomersByLoggedInUser(PageName);
        set<SelectOption> setSlctOptn = new  set<SelectOption>();
        setSlctOptn.addAll(lstSlctOptn);
        List<SelectOption> lstSlctOptn2 = new  list<SelectOption>();
        lstSlctOptn2.addAll(setSlctOptn);
        system.debug('lstSlctOptn2--'+lstSlctOptn2);

        return lstSlctOptn2;  

    }
    
    public List<SelectOption> getServiceDropdownValues()
    {
        string PageName = ApexPages.currentPage().GetURL().substringBefore('?').substringafter('/').substringafter('/');
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        Id chnlPartner = objUser.Contact.AccountId;
        Id chnlPartnerCont = objUser.ContactId;
        string  portalRole = objUser.PortalUserRole__c;
        IsPortalApprover = objUser.Contact.Is_Approver__c;
        List<SelectOption> lstSlctOptn = new  list<SelectOption>();
        List<Account_Services__c > lstfetchAccServcesByAcc = new List<Account_Services__c >();
        
        if(PageName == 'Dashboard' && (portalRole == 'Practice Head' || portalRole == 'Partner'))
        {
            lstSlctOptn.add(new  SelectOption('All', 'All Services'));
        }
        
        if(PageName != 'Dashboard' && PageName != 'viewTimesheet')
        {
            lstSlctOptn.add(new  SelectOption('All', 'All Services'));
        }
        if(PortalRole != 'Customer' && PageName == 'viewTimesheet')
        {
            lstSlctOptn.add(new  SelectOption('All', 'All Services'));
            lstfetchAccServcesByAcc = ODS_Data_Utility.fetchAccServcesByAccAndEngmtType(AccountId);
            if(lstfetchAccServcesByAcc.size()!=0)
            {
                for(Account_Services__c odsAccService: lstfetchAccServcesByAcc)
                {
                    lstSlctOptn.add(new  SelectOption(odsAccService.ODS_Services__c, odsAccService.ODS_Services__r.Name__c));
                }
            }        
        }
        if(AccountId != 'All')
        {
            system.debug('@@@PortalUserRole '+PortalUserRole);
            if(portalRole == 'Customer')
            {
                if(PageName != 'viewTimesheet')
                {
                    system.debug('@@@PortalUserRole '+PortalUserRole);
                    List<Contact_Account_Service__c> contactService = new list<Contact_Account_Service__c >();
                    contactService = ODS_Data_Utility.GetAccServiceByContact(objUser.ContactId);
                    if(contactService.size() > 0)
                    {
                        for(Contact_Account_Service__c odsAccService: contactService)
                        {
                            lstSlctOptn.add(new  SelectOption(odsAccService.ODS_Service__c, odsAccService.ODS_Service__r.Name__c));
                        }
                    }  
                } 
                else
                {
                    system.debug('@@@PortalUserRole '+PortalUserRole);
                    List<Contact_Account_Service__c> contactService = new list<Contact_Account_Service__c >();
                    contactService = ODS_Data_Utility.GetAccServiceByContact(objUser.ContactId);
                    if(contactService.size() > 0)
                    {   
                        set<string> serviceIdSet = new set<string>();
                        for(Contact_Account_Service__c conServ :contactService){
                            serviceIdSet.add(conServ.ODS_Service__c);
                        }
                        for(Account_Services__c odsAccService: ODS_Data_Utility.fetchAccServcesByAccAndEngmtType(contactService[0].Account__c, serviceIdSet))
                        {
                            lstSlctOptn.add(new  SelectOption(odsAccService.ODS_Services__c, odsAccService.ODS_Services__r.Name__c));
                        }
                    }  
                } 
            }
            else
            {
                if(PageName != 'viewTimesheet')
                {
                    Set<String> sOdsServiceName = new set<String>();
                    lstfetchAccServcesByAcc = ODS_Data_Utility.fetchAccServcesByAcc(AccountId);
                    if(lstfetchAccServcesByAcc.size()!=0)
                    {
                        for(Account_Services__c odsAccService: lstfetchAccServcesByAcc)
                        {
                            //lstSlctOptn.add(new  SelectOption(odsAccService.ODS_Services__c, odsAccService.ODS_Services__r.Name__c));
                            sOdsServiceName.add(odsAccService.ODS_Services__r.Name__c);
                        }
                    }
                    
                    if(!sOdsServiceName.isEmpty()) {
                        for(ODS_Services__c osvs:[SELECT Id,Name__c FROM ODS_Services__c WHERE Name__c IN:sOdsServiceName]) {
                            lstSlctOptn.add(new  SelectOption(osvs.Id,osvs.Name__c));
                        }
                    }
                }
            }
        }
        else if(AccountId != 'All' && portalRole == 'Partner') {
            //If single Account is seleted
            Set<String> sOdsServiceNames = new set<String>();
            List<Account_Services__c> lPartnerODSService = ODS_Data_Utility.fetchAccServcesByAcc(AccountId);
            if(lPartnerODSService.isEmpty()) {
                for(Account_Services__c acs:lPartnerODSService) {
                    //lstSlctOptn.add(new  SelectOption(acs.ODS_Services__c, acs.ODS_Services__r.Name__c));
                    sOdsServiceNames.add(acs.ODS_Services__r.Name__c);
                }
            }
            
            if(!sOdsServiceNames.isEmpty()) {
                for(ODS_Services__c osvs:[SELECT Id,Name__c FROM ODS_Services__c WHERE Name__c IN:sOdsServiceNames]) {
                    lstSlctOptn.add(new  SelectOption(osvs.Id,osvs.Name__c));
                }            
            }
        }
        else if(portalRole == 'Partner') {
            //If no specific Account selected from dropdown
            Integer AcsCount = 0;
            //Id currPartnerId = [SELECT AccountId FROM Contact WHERE Id =: objUser.ContactId LIMIT 1].AccountId;
            List<Account> lOdsCustomers = new List<Account>([SELECT Id,Name FROM Account 
                                                             WHERE  Is_Portal_Access__c = true 
                                                             AND Channel_Partner__c = :chnlPartner
                                                             AND Channel_Partner_Contact__c =:chnlPartnerCont 
                                                             AND Count_of_Services__c >: AcsCount 
                                                             LIMIT 50000]);
            Set<Id> sOdsCustomers = new Set<Id>();
            //List<Account_Services__c> lPartnerODSService = new List<Account_Services__c>();
            Set<String> sOdsServices = new Set<String>();
            System.debug('@@OdsCustomers: '+lOdsCustomers);
            if(!lOdsCustomers.isEmpty()) {                
                for(Account acc:lOdsCustomers) {
                    sOdsCustomers.add(acc.Id);
                }
            }
            System.debug('@@OdsCustomers set: '+sOdsCustomers);
            if(!sOdsCustomers.isEmpty()) {
                for(Account_Services__c accserv:[SELECT Id,Account__c,ODS_Services__c,ODS_Services__r.Name__c ,Type_of_Engagement__c
                                                 FROM Account_Services__c 
                                                 WHERE Account__c IN:sOdsCustomers
                                                 ORDER BY ODS_Services__r.Name__c ASC]) {
                                                     sOdsServices.add(accserv.ODS_Services__r.Name__c);                      
                                                 }                                      
            }
            
            if(!sOdsServices.isEmpty()) {                
                for(ODS_Services__c osv:[SELECT Id,Name__c FROM ODS_Services__c WHERE Name__c IN:sOdsServices]) {
                    lstSlctOptn.add(new  SelectOption(osv.Id,osv.Name__c));
                }
                System.debug('@@selectOptions: '+lstSlctOptn);
            }
        }
        else {
            List<ODS_Services__c> servceLst = new List<ODS_Services__c >();
            servceLst = ODS_Data_Utility.fetchAccServces(); 
            if(servceLst.size()!=0)
            {
                for( ODS_Services__c odsServces: servceLst)
                {
                    lstSlctOptn.add(new SelectOption(odsServces.id, odsServces.Name__c));
                }  
            } 
        }
        return lstSlctOptn;
    }
    
    
    
    @RemoteAction
    global static string RedirectDashboardPage(string DashboardAcntId, string DashboardSrvId)
    {
        system.debug('--#######-DashboardAcntId'+DashboardAcntId);
        system.debug('-##########--DashboardSrvId'+DashboardSrvId);
        List<Account_Services__c> accService = new  List<Account_Services__c>();
        string EngagementType;
        string AgileType;
        accService = ODS_Data_Utility.fetchAccServcesByAccAndSrv(DashboardAcntId,DashboardSrvId);
        system.debug('---accService '+accService );
        if(accService[0].Type_of_Engagement__c == 'ODS')
        {
            EngagementType = 'ODS';
        }
        else if (accService[0].Type_of_Engagement__c == 'SOW' || accService[0].Type_of_Engagement__c == 'T&M')
        {
            EngagementType = 'Other';
        }
        AgileType = accService[0].Agile__c;
        return EngagementType+'$$##'+AgileType ;
        
        
    }
    
     public String getUserPhoto()
    {
        if(isCustomer){
            return getCustomerPhoto();
        }else{
            return getPhoto();
        }
    }   
    /// <OBJECTIVE>
    /// To get photo for the user.
    /// </OBJECTIVE>
    public String getPhoto()
    {
        String Photo = '';
        
        list<user> userPhotoLst=new list<user>();
        set<Id> userId = new set<Id>();
        userId.add(UserInfo.getUserId());
        try
        {
            userPhotoLst = ODS_Data_Utility.fetchUserPhotoUrlByUserId(userId);
            system.debug('##userPhotoLst:'+userPhotoLst);
            if(!userPhotoLst.isEmpty()){
                Photo = userPhotoLst[0].FullPhotoUrl;
                if(String.isNotBlank(Photo) && Photo.contains('/profilephoto/005/F')){
                    Photo = '';/*use the tech pic as set on the header component*/
                }
            }
        }
        catch(Exception e)
        {
            Photo = '';
            system.debug('No rows found');
        }
        return Photo;   
    }
    
    /// <OBJECTIVE>
    /// To get photo for the customer.
    /// </OBJECTIVE>
    public String getCustomerPhoto()
    {
        String Photo = '';
        User objuser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        string conId = objuser.ContactId;
        objContact = ODS_Data_Utility.fetchAttachmentByContactId(conId);
        if(objContact.attachments.size() > 0){
            Photo = objContact.attachments[0].Id;
        }
        return Photo;
    }
    /// <OBJECTIVE>
    /// To get redirect to search result page.
    /// </OBJECTIVE>
    public PageReference search(){
        //ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);
        PageReference pgRef = new PageReference('/apex/ODS_SearchResult?searchText='+searchKey.replaceAll('[^a-zA-Z0-9\\s+]', '')+'&accntId='+AccountId);
        pgRef.setRedirect(True);
        return pgRef;
    }
    
}