public class ODS_Common_Utility
{
    public string portalRole{get;set;}
    public string currentUserName {get;set;}
    public string currentUserId {get;set;}
   // public user currentUserRole{get;set;}
    
    public  list<SelectOption> getCustomersByLoggedInUser()
    {
        return getCustomersByLoggedInUser('');
    }
    public  list<SelectOption> getCustomersByLoggedInUser(String PageName)
    {
        currentUserName = UserInfo.getName();
        currentUserId = UserInfo.getUserId();
        
        /*if(userinfo.getUserRoleId() != null){
        userrole  currentUserRole = ODS_Data_Utility.fetchUserRoleName(userinfo.getUserRoleId()); //25-11-2020-SD.
        }  */
        List<SelectOption> lstSlctOptn = new list<SelectOption>(); 
        Boolean isPortalAccess = true;
        integer count = 0;
        integer EngmtTypeCount = 0;
        string accQuery = 'SELECT Name, User__c, Account__c,Account__r.Count_of_ODS_Engagement_Type__c,  Account__r.name, Account__r.Count_of_Services__c '+
            'FROM User_Account__c WHERE Account__r.Is_Portal_Access__c =: isPortalAccess AND Account__r.Count_of_Services__c >: count ';        
        
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        
        Id chnlPartner = objUser.Contact.AccountId;
        Id chnlPartnerCont = objUser.ContactId;
        portalRole = objUser.PortalUserRole__c;
        
        
        if(objUser.PortalUserRole__c == 'Customer')
        {               
            lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
            for(Contact cnt: ODS_Data_Utility.FetchAccountIdByCustomer(objUser.ContactId))
            {
                lstSlctOptn.add(new SelectOption(cnt.accountId, cnt.account.Name)); 
            }    
            lstSlctOptn.remove(0); 
        }
        //Added by Mani & Team
        else if(portalRole == 'Partner') {
            System.debug('@@Inside Partner loop for Contact: '+objUser.ContactId);
            lstSlctOptn.add(new SelectOption('All', 'All Customers'));
            //Id currPartnerId = [SELECT AccountId FROM Contact WHERE Id =:objUser.ContactId LIMIT 1].AccountId; 
            accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND'+
                ' Channel_Partner__c = :chnlPartner AND'+
                ' Channel_Partner_Contact__c =:chnlPartnerCont AND'+
                ' Count_of_Services__c >: count ORDER BY Name ASC ';        
            
            for(Account acc : database.query(accQuery))
            { 
                lstSlctOptn.add(new SelectOption(acc.id, acc.Name));              
            } 
        }     
        else if(portalRole == 'Practice Head'  && objUser.Management__c == 'Administrator')
        {
            if(PageName != 'Dashboard' && PageName != 'viewTimesheet')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count ORDER BY Name ASC ';        
                
                for(Account acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.id, acc.Name)); 
                }  
            } 
            if(PageName == 'Dashboard')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count ORDER BY Name ASC ';        
                
                for(Account acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.id, acc.Name)); 
                }  
            } 
            
            else if (PageName == 'viewTimesheet')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count AND Count_of_ODS_Engagement_Type__c >: EngmtTypeCount ORDER BY Name ASC ';        
                
                for(Account acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.id, acc.Name)); 
                } 
            }
            
            else
            {
                
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count ORDER BY Name ASC ';        
                
                for(Account acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.id, acc.Name)); 
                }  
            }
        }
        //25-11-2020-SD:
        

        else if(portalRole == 'Practice Head'  && (objUser.Management__c == 'Practice Head' || objUser.Management__c == 'Management'))
        {
               if(PageName != 'Dashboard' && PageName != 'viewTimesheet')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count ORDER BY Name ASC ';        
            
                Set<id> accId = new Set<id>();
                
                for(Account acc : database.query(accQuery)){
                    accId.add(acc.id);
                }
                
                List<Account_Services__c> accServiceList = [SELECT Technical_Account_manager__c,Account__r.name,Contract_End_Date__c,Contract_Start_Date__c FROM Account_Services__c WHERE Account__c IN : accId AND Contract_Start_Date__c <= Today AND Contract_End_Date__c >= Today ORDER BY Account__r.name ASC];
                    
                for(Account_Services__c accs : accServiceList)
                { 
                    lstSlctOptn.add(new SelectOption(accs.Account__c, accs.Account__r.name)); 
                }  
            } 
            if(PageName == 'Dashboard')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count ORDER BY Name ASC ';        
                
                Set<id> accId = new Set<id>();
                
                for(Account acc : database.query(accQuery)){
                    accId.add(acc.id);
                }
                
                List<Account_Services__c> accServiceList = [SELECT Technical_Account_manager__c,Account__r.name,Contract_End_Date__c,Contract_Start_Date__c FROM Account_Services__c WHERE Account__c IN : accId AND Contract_Start_Date__c <= Today AND Contract_End_Date__c >= Today ORDER BY Account__r.name ASC];
                    
                for(Account_Services__c accs : accServiceList)
                { 
                    lstSlctOptn.add(new SelectOption(accs.Account__c, accs.Account__r.name)); 
                }  
            } 
            
            else if (PageName == 'viewTimesheet')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count AND Count_of_ODS_Engagement_Type__c >: EngmtTypeCount ORDER BY Name ASC ';        
                
                Set<id> accId = new Set<id>();
                
                for(Account acc : database.query(accQuery)){
                    accId.add(acc.id);
                }
                
                List<Account_Services__c> accServiceList = [SELECT Technical_Account_manager__c,Account__r.name,Contract_End_Date__c,Contract_Start_Date__c FROM Account_Services__c WHERE Account__c IN : accId AND Contract_Start_Date__c <= Today AND Contract_End_Date__c >= Today ORDER BY Account__r.name ASC];
                    
                for(Account_Services__c accs : accServiceList)
                { 
                    lstSlctOptn.add(new SelectOption(accs.Account__c, accs.Account__r.name)); 
                }
            }
            
            else
            {
                
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count ORDER BY Name ASC ';        
                
                Set<id> accId = new Set<id>();
                
                for(Account acc : database.query(accQuery)){
                    accId.add(acc.id);
                }
                
                List<Account_Services__c> accServiceList = [SELECT Technical_Account_manager__c,Account__r.name,Contract_End_Date__c,Contract_Start_Date__c FROM Account_Services__c WHERE Account__c IN : accId AND Contract_Start_Date__c <= Today AND Contract_End_Date__c >= Today ORDER BY Account__r.name ASC];
                    
                for(Account_Services__c accs : accServiceList)
                { 
                    lstSlctOptn.add(new SelectOption(accs.Account__c, accs.Account__r.name)); 
                } 
            }
            
        }        
     
      
       else if(objUser.UserRole.name != null && objUser.UserRole.name == 'Senior Director - Customer Success')
        {
            Set<ID> getallrealtedusers = new Set<ID>();
            Set<ID> getallReportingRole = new Set<ID>();
            
            getallrealtedusers.add(currentUserId);
            
            List<UserRole> getalluserrole = [SELECT DeveloperName,Id,Name,ParentRoleId FROM UserRole where ParentRoleId = :objUser.UserRoleid];
            
            for(userrole getuserroleId:getalluserrole){
                
                getallReportingRole.add(getuserroleId.Id);
            }
            
            List<user> getallReportingUsers = [SELECT FirstName,Id,IsActive,LastName,Name,Username,UserRole.Name,ManagerId FROM User where ManagerId=:objUser.Id and ISactive = : isPortalAccess];           
            
            for(User getusers:getallReportingUsers){
                
                getallrealtedusers.add(getusers.id);
                
            }
            
            if(PageName != 'Dashboard')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery += 'AND User__c IN: getallrealtedusers ORDER BY Account__r.Name ASC ';
                for(User_Account__c acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.Account__C, acc.Account__r.Name)); 
                }  
            } 
            
            else if (PageName == 'viewTimesheet')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count AND Count_of_ODS_Engagement_Type__c >: EngmtTypeCount ORDER BY Name ASC ';        
                
                for(Account acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.id, acc.Name)); 
                } 
            }
            
            else
            {
                accQuery += 'AND User__c IN: getallrealtedusers ORDER BY Account__r.Name ASC ';
                for(User_Account__c acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.Account__C, acc.Account__r.Name)); 
                } 
            }
        } //25-11-2020-SD: 
        
        else
        {
            if(PageName != 'Dashboard')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                
                accQuery += 'AND User__c =: currentUserId ORDER BY Account__r.Name ASC ';
                for(User_Account__c acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.Account__C, acc.Account__r.Name)); 
                }  
            } 
            
            else if (PageName == 'viewTimesheet')
            {
                //lstSlctOptn.add(new SelectOption('All', 'All Customers')); 
                accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
                    'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count AND Count_of_ODS_Engagement_Type__c >: EngmtTypeCount ORDER BY Name ASC ';        
                
                for(Account acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.id, acc.Name)); 
                } 
            }
            
            else
            {
                accQuery += 'AND User__c =: currentUserId ORDER BY Account__r.Name ASC ';
                for(User_Account__c acc : database.query(accQuery))
                { 
                    lstSlctOptn.add(new SelectOption(acc.Account__C, acc.Account__r.Name)); 
                } 
            }
        }
        return lstSlctOptn;
    }
    
    public string getCustomersQueryByLoggedInUser()
    {
        string currentUserId = UserInfo.getUserId();
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        portalRole = objUser.PortalUserRole__c;
        Boolean isPortalAccess = true;
        integer count = 0;
        integer EngmtTypeCount = 0;
        string contactId;
        
        List<Contact> cnt = ODS_Data_Utility.FetchAccountIdByCustomer(objUser.ContactId);
        if(cnt.size() != 0)
        {
            contactId = cnt[0].Id;
        }
        
        string UserAccQuery = 'SELECT Name, User__c, Account__c,Account__r.Count_of_ODS_Engagement_Type__c,  Account__r.name, Account__r.Count_of_Services__c '+
            'FROM User_Account__c WHERE Account__r.Is_Portal_Access__c =: isPortalAccess AND Account__r.Count_of_Services__c >: count ';
        
        string accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c,Count_of_Services__c   '+
            'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count  ORDER BY Name ASC ';
        
        //string cntQuery = 'SELECT Id,Name, AccountId, Account.name FROM Contact WHERE Id =: contactId LIMIT 1 ' ;
        string cntQuery = 'SELECT Id,Name, AccountId, Account.name FROM Contact ' ;
        
        string rtnQuery;   
        
        if(portalRole == 'Practice Head' )
        {
            rtnQuery  = accQuery;
        }
        
        else if(portalRole == 'Customer')
        {     
            rtnQuery = cntQuery;
        }
        
        else
        {
            //UserAccQuery += 'AND User__c =: currentUserId ORDER BY Account__r.Name ASC ';
            rtnQuery = UserAccQuery;
        }
        
        return rtnQuery ;
        
    }
    
    public  List<String> getAllAccountIDByLoggedInUser()
    {    
        currentUserName = UserInfo.getName();
        currentUserId = UserInfo.getUserId();
        
        List<String> lstAccountIDs= new list<String>(); 
        Boolean isPortalAccess = true;
        integer count = 0;
        string accQuery = 'SELECT Name, User__c, Account__c,  Account__r.name, Account__r.Count_of_ODS_Engagement_Type__c ,Account__r.Count_of_Services__c '+
            'FROM User_Account__c WHERE Account__r.Is_Portal_Access__c =: isPortalAccess AND Account__r.Count_of_Services__c >: count ';        
        
        user objUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        Id chnlPartner = objUser.Contact.AccountId;
        Id chnlPartnerCont = objUser.ContactId;
        portalRole = objUser.PortalUserRole__c;
        
        
        
        if(objUser.PortalUserRole__c == 'Customer')
        {               
            for(Contact cnt: ODS_Data_Utility.FetchAccountIdByCustomer(objUser.ContactId))
            {
                lstAccountIDs.add(cnt.accountId); 
            }            
        }     
        else if(portalRole == 'Practice Head' && objUser.Management__c !='Industry Practice Head')
        {
            accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c ,Count_of_Services__c   '+
                'FROM Account WHERE Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count ORDER BY Name ASC ';        
            
            for(Account acc : database.query(accQuery))
            { 
                lstAccountIDs.add(acc.id); 
                
            }   
        }
        //Added by Mani & Team
        else if(portalRole == 'Partner' )
        {
            //Id currPartnerId = [SELECT Contact.AccountId FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1].Contact.AccountId;
            accQuery = 'SELECT id, Name, Is_Portal_Access__c,Count_of_ODS_Engagement_Type__c ,Count_of_Services__c   '+
                'FROM Account WHERE Channel_Partner__c =:chnlPartner  AND'+
                ' Channel_Partner_Contact__c =:chnlPartnerCont AND'+
                ' Is_Portal_Access__c =: isPortalAccess AND Count_of_Services__c >: count ORDER BY Name ASC ';        
            
            for(Account acc : database.query(accQuery))
            { 
                lstAccountIDs.add(acc.id); 
                
            }   
        }
        else
        {
            accQuery += 'AND User__c =: currentUserId ORDER BY Account__r.Name ASC ';
            for(User_Account__c acc : database.query(accQuery))
            { 
                lstAccountIDs.add(acc.Account__C); 
            }   
        }
        return lstAccountIDs;
    }
    
    /// <OBJECTIVE>
    /// Method to upsert Session data Customsetting
    /// </OBJECTIVE>
    public static void upsertSessionData(string accountId, string serviceid)
    {
        list<ODS_SessionData__c> getSessionData =  fetchSessionData(UserInfo.getUserId());
        ODS_SessionData__c objSessiondata;
        if(getSessionData.size()!= 0)
        {
            String sessionID;
            sessionID = getSessionData[0].id;
            objSessiondata = new  ODS_SessionData__c (Id = sessionID);
            objSessiondata.Current_user_Id__c = UserInfo.getUserId(); 
            objSessiondata.Account_Id__c = accountId;
            objSessiondata.Service_Id__c = serviceid;  
            Update objSessiondata;
            
        }
        else
        {
            objSessiondata = new  ODS_SessionData__c ();
            objSessiondata.Name = UserInfo.getUserId();
            objSessiondata.Current_user_Id__c = UserInfo.getUserId(); 
            objSessiondata.Account_Id__c = accountId;
            objSessiondata.Service_Id__c = serviceid;  
            insert objSessiondata;
            
        }
        // return objSessiondata;
    }
    /// <OBJECTIVE>
    /// Method to fetch the Custom setting session data.
    /// </OBJECTIVE>    
    Public static list<ODS_SessionData__c> fetchSessionData(string userID)
    {
        return [SELECT
                Current_user_Id__c,
                Account_Id__c,
                Service_Id__c
                FROM
                ODS_SessionData__c
                WHERE
                Current_user_Id__c =: userID];     
    }
    
    public static String getEmailMessage(String emailBody, String emailSignature){
        String emailMessage = '';
        emailMessage = '<body><table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2">' + emailBody + emailSignature + '</td></tr></table></body>';
        return emailMessage;
    }
    
    public static String getEmailSignature(String senderName, String senderTitleLabel, String phoneNumber, String emailAddress){
        String emailSignature = '';
        emailSignature += '<table style="border:none; width:624px; border-collapse: collapse;"><tbody><tr><td style="border-top:2px solid #000; padding-bottom:15px;"/></tr><tr><td>Thanks,</td></tr>';
        emailSignature += '<tr><td>' + senderName + '</td></tr><tr><td><table><tbody><tr><td valign="top" width="283" style="width:285px; margin:0; padding:25px;vertical-align:top; background-color:#07080A;">';
        emailSignature += '<a href="https://www.levelshift.com/" target="_blank"><img src="'+Label.ODS_Email_Signature_Logo_Url+'" alt="LevelShift" width="285" style="border:none;width:285px;display:block; margin:25px 0;"/></a></td>';
        emailSignature += '<td width="5" style="width:5px;min-width:5px;max-width:5px;margin:0;padding:0;">&nbsp;</td><td style="background-color:#4fc9f3; padding:26px; width:276px;">';
        emailSignature += '<table><tbody><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">' + senderTitleLabel + '</span></p></td>';
        emailSignature += '<td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;">';
        emailSignature += '<span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">' + senderName + '</span></p></td></tr>';

        if(String.isNotBlank(phoneNumber)){
            emailSignature += '<tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Phone</span></p></td>';
            emailSignature += '<td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td>';
            emailSignature += '<td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">' + phoneNumber + '</span></p></td></tr>';            
        }

        if(String.isNotBlank(emailAddress)){
            emailSignature += '<tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Email</span></p></td>';
            emailSignature += '<td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td>';
            emailSignature += '<td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">' + emailAddress + '</span></p></td></tr>';
        }
        
        emailSignature += '</tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td style="border-bottom:2px solid #4fc9f3; padding-top:15px;"/></tr><tr><td width="624" valign="top" style="width:283px;border:none;padding:10px 0"><p style="text-align:justify;">';
        emailSignature += '<span style="font-size:11px; font-family:calibri; color:#ff0000; font-weight: bold;">CONFIDENTIALITY STATEMENT:</span><span style="font-size:11px; font-family:Arial, Sans-Serif, Times New Roman; color:#a6a6a6;">The information contained in this communication is confidential';
        emailSignature += ' and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination,';
        emailSignature += ' distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p></td></tr></tbody></table>';

        return emailSignature;
    }
    public static string generateProjectCodeforAccount(string accountName){
        Set<string> CheckDuplicateProjectCode=new Set<string>();
        
        List<Account> lstCheckDuplicateProjectCode = [SELECT Id,Project_Code__c FROM Account WHERE Project_Code__c !=null];
        system.debug('lstCheckDuplicateProjectCode==>'+lstCheckDuplicateProjectCode);
        if(lstCheckDuplicateProjectCode.size()>0)
        {
            for(Account accObj:lstCheckDuplicateProjectCode){
                CheckDuplicateProjectCode.add(accObj.Project_Code__c);}
        }
        String newAccName = accountName;
        String projectCode ='';
        newAccName = newAccName.toUpperCase().replaceAll('[^A-Z0-9]', '');
        String accName = newAccName + 'XQZJ0123456789'; //X,Q,Z,J LESS COMMONLY USED ALPHABETS
        Integer ITER_MAX = 50000;
        Integer iterationCount = 0;
        do{
            Integer index = Integer.valueOf((Math.random() * accName.length()));
            projectCode += accName.mid(index, 1);
            //first character and all three characters should not be number
            if((projectCode.length() == 1 || projectCode.length() == 3) && projectCode.replaceAll('[0-9]', '') == ''){
                projectCode = '';
            }
            //check if the project code already exists
            if(projectCode.length() == 3 && CheckDuplicateProjectCode.contains(projectCode)){
                projectCode = '';
            }
            //reverse the account name if code not found after 15000 iterations
            if(projectCode == '' && iterationCount == 15000){
                accName = accountName.reverse() + 'JZQX9876543210';
            }
        }while(projectCode.length() < 3 && ++iterationCount < ITER_MAX);
        
        System.debug(projectCode);
       return projectCode;
    }
}