public class CreateChildswhenSOWisFullyExecuted {
    
    public static void createChilds(List<Account> acc){
        List<Account_Services__c> objAccountService = new List<Account_Services__c>();
        List<Contact_Account_Service__c> objAcontactAccountService = new List<Contact_Account_Service__c>();
        List<User_Account__c> objUserAccount = new List<User_Account__c>();
        List<Account> UpdateAccount = new List<Account>();
        List<Project_Team_Member__c> teamMembers = new List<Project_Team_Member__c>();
        List<sObject> records = new List<sObject>();        
        ODS_WorkOrderSettings__c cs = ODS_WorkOrderSettings__c.getInstance('SFDC');
        String amid = Label.Account_Manager_Id;
        ODS_Services__c serviceName = [Select Name__c From ODS_Services__c where Name__c = 'Salesforce' limit 1];
        List<ODS_User_Account_Setting__mdt> userAccSettings = new List<ODS_User_Account_Setting__mdt>();
        userAccSettings = [SELECT AccountPartnerUserId__c, CSMUserId__c, CSMUsersToBeAssigned__c FROM ODS_User_Account_Setting__mdt LIMIT 1];
        Map<Id, Map<Id,String>> AccountWithUserIds = new Map<Id, Map<Id,String>>();
        Map<Id,String> userMap = new Map<Id,String>();
        //DCO-71
        string profileName=Label.ODS_ReportingManagerRoles;
        List<String> ReportingManagerNameList = profileName.split(',');
        list<string> reportingManagerRoleAfterTrim=new List<string>();
        for(string role:ReportingManagerNameList){
            reportingManagerRoleAfterTrim.add(role.trim());
        }    
        
        Map<id,User> reportingManagerDetails=new Map<id,user>([SELECT Id,Name,ManagerId,UserRole.Name,Email FROM User where UserRole.Name IN :reportingManagerRoleAfterTrim]);
        
        for(Account accnt : acc)
        {
            userMap.put(accnt.User__c,'');
            //Added by Indhu on 04-Feb-2020 to include Backup CSM
            userMap.put(accnt.Backup_CSM__c,'');
            AccountWithUserIds.put(accnt.Id,userMap);
        }
        
        for(user usr : [select Id,PortalUserRole__c from user where Id in: userMap.Keyset()])
        {
            for(Id accId : AccountWithUserIds.keySet())
            {
                If(AccountWithUserIds.get(accId).containsKey(usr.Id))
                {
                    AccountWithUserIds.get(accId).put(usr.Id,usr.PortalUserRole__c);
                }
            }
        }
        
        for(Account objAccount : acc){
            if(objAccount.SOW__c=='Fully Executed' && objAccount.Primary_Customer_Contact__c !=null || objAccount.Primary_Customer_Contact__c !=''&&objAccount.User__c != null&&objAccount.Customer_Engagement_Type__c == 'ODS'){
                Account_Services__c objServiceAccount = new Account_Services__c();
                Contact_Account_Service__c objContactAccount = new Contact_Account_Service__c();
                
                User_Account__c objAccountUser = new User_Account__c();
                User_Account__c objBackupCSMUser = new User_Account__c();
                User_Account__c newCSMUser = new User_Account__c();
                
                User_Account__c accountOwnerUser = new User_Account__c();
                
                Map<id,User_Account__c> userAccountMap=new  Map<id,User_Account__c>();
                userAccountMap=checkExistUserAccount(objAccount.Id,serviceName.Id);
                
                String AccName = objAccount.Name;
                String AccountName = '';
                If( AccName.length() > 5 )
                {
                    AccountName = AccName.substring(0,3) + AccName.right(2); 
                } 
                else{
                    AccountName = Accname;   
                }
                string docSuf='_'+AccountName+'%';
                Integer existDocumentSufCount =  [SELECT count() FROM Account_Services__c WHERE Document_Suffix__c like: docSuf];
                if(existDocumentSufCount !=0){
                    existDocumentSufCount++;
                    AccountName=AccountName+string.valueOf(existDocumentSufCount);
                }
                objAccountUser.Account__c = objAccount.Id;
                objBackupCSMUser.Account__c = objAccount.Id;
                if(AccountWithUserIds.containsKey(objAccount.Id))
                {
                    if(AccountWithUserIds.get(objAccount.Id).containsKey(objAccount.User__c))
                    {
                        String portalUserValue = AccountWithUserIds.get(objAccount.Id).get(objAccount.User__c);
                        if(portalUserValue == 'Technical Account Manager' || portalUserValue == 'Practice Head' || portalUserValue == 'Account Manager')
                        {
                            AccountWithUserIds.get(objAccount.Id).put(objAccount.User__c,portalUserValue);
                            objAccountUser.User__c = objAccount.User__c;   
                            User CSMUser=getReportingManagerDetails(objAccount.User__c);
                            User managersOfCSM=reportingManagerDetails.get(CSMUser.ManagerId);
                            if(managersOfCSM !=null){
                                newCSMUser.Account__c = objAccount.Id;
                                newCSMUser.User__c = managersOfCSM.id;
                                newCSMUser.ODS_Services__c = serviceName.Id;               
                                newCSMUser.Role_in_Account__c = 'Account Partner';
                                if(newCSMUser != null && !userAccountMap.containsKey(managersOfCSM.id)){
                                    objUserAccount.add(newCSMUser);
                                } 
                            }
                        }
                        
                        if(AccountWithUserIds.get(objAccount.Id).containsKey(objAccount.Backup_CSM__c))
                        {
                            String backupCSMportalValue = AccountWithUserIds.get(objAccount.Id).get(objAccount.Backup_CSM__c);
                            if(backupCSMportalValue == 'Technical Account Manager' || backupCSMportalValue == 'Practice Head' || backupCSMportalValue == 'Account Manager')
                            {
                                AccountWithUserIds.get(objAccount.Id).put(objAccount.Backup_CSM__c,backupCSMportalValue);
                                objBackupCSMUser.User__c = objAccount.Backup_CSM__c;
                            }
                        }   
                        
                    }
                    else
                    {
                        objAccountUser.addError('The customer success manager role should be either Technical Account Manager, Practice Head or Account Manager');
                    }
                }
                objAccountUser.ODS_Services__c = serviceName.Id;      
                objBackupCSMUser.ODS_Services__c = serviceName.Id;          
                objAccountUser.Role_in_Account__c = 'Technical Account Manager'; 
                objBackupCSMUser.Role_in_Account__c = 'Backup Technical Account Manager'; 
                
                objServiceAccount.Account__c = objAccount.Id;               
                objServiceAccount.ODS_Services__c = serviceName.Id;               
                Date dt = objAccount.SOW_Start_Date__c;
                Date ed = objAccount.SOW_End_Date__c;
                if(dt ==null)
                    dt = Date.today();
                objServiceAccount.Contract_Start_Date__c = dt;
                objServiceAccount.Contract_End_Date__c = ed;
                objServiceAccount.Retainer_Fee_Frequency_Type__c = 'Monthly';
                objServiceAccount.Timesheet_Start_Date__c = dt;
                objServiceAccount.Document_Suffix__c = '_'+AccountName;              
                objServiceAccount.Technical_Account_manager__c = objAccount.User__c;
                objServiceAccount.Retainer_Fee_Amount__c = objAccount.SOW_Subscription_Fee__c;
                objServiceAccount.ODS_Hourly_Rate_Amount__c = objAccount.ODS_Hourly_Rate__c;
                objServiceAccount.Admin_Hourly_Rate__c=objAccount.Admin_Hourly_Rate__c;
                objServiceAccount.Consulting_Hourly_Rate__c=objAccount.Consulting_Hourly_Rate__c;
                objServiceAccount.Invoice_Frequency__c = objAccount.Invoice_Frequency__c;
                objServiceAccount.Contract_Term__c = objAccount.Contract_Terms__c;
                objServiceAccount.Account_Manager__c = amid;
                objServiceAccount.Rally_password__c ='Prelude@123';
                objServiceAccount.Backup_CSM__c = objAccount.Backup_CSM__c;
                
                objContactAccount.Contact__c = objAccount.Primary_Customer_Contact__c;                
                objContactAccount.ODS_Service__c = serviceName.Id;
                objContactAccount.Status_Report_Required__c = true;
                objContactAccount.Is_Approver__c = true;               
                objContactAccount.Account__c = objAccount.Id;
                objContactAccount.Is_initiate_approver__c = true;
                
                if(!userAccountMap.containsKey(objAccount.User__c)){
                    objUserAccount.add(objAccountUser);
                }
                if(!userAccountMap.containsKey(objAccount.Backup_CSM__c)){
                    objUserAccount.add(objBackupCSMUser);             
                }
                
                //user account record for delivery team
                Set<string> deliveryTeamProfiles=new Set<string>();
                for(string s:Label.DeliveryRoleProfile.split(',')){
                    deliveryTeamProfiles.add(s.trim());
                }
                List<User> userRecords=[SELECT Delivery_Role__c,Id,Profile.Name FROM User Where Profile.Name IN:deliveryTeamProfiles];
                for(User u:userRecords){
                    User_Account__c deliveryRoleUserAccount = new User_Account__c();    
                    deliveryRoleUserAccount.Account__c = objAccount.Id;
                    deliveryRoleUserAccount.User__c = u.Id;
                    deliveryRoleUserAccount.ODS_Services__c = serviceName.Id;               
                    deliveryRoleUserAccount.Role_in_Account__c = 'Delivery Team';   
                    objUserAccount.add(deliveryRoleUserAccount);
                }   
                
                
                //user account record for account owner
                if(String.isNotBlank(objAccount.OwnerId)){
                    accountOwnerUser.Account__c = objAccount.Id;
                    accountOwnerUser.User__c = objAccount.OwnerId;
                    accountOwnerUser.ODS_Services__c = serviceName.Id;               
                    accountOwnerUser.Role_in_Account__c = 'Account Manager';
                    objUserAccount.add(accountOwnerUser);
                }                
                system.debug('###objUserAccount:' +objUserAccount);
                
                list<Account_Services__c> checkExistAccountService=[SELECT Account__c,ODS_Services__c FROM Account_Services__c Where Account__c=:objAccount.Id AND ODS_Services__c=: serviceName.Id limit 1];
                if(checkExistAccountService.isEmpty()){
                    objAccountService.add(objServiceAccount);
                }
                list<Contact_Account_Service__c> checkExistCAS=[Select Account__c,ODS_Service__c,Contact__c From Contact_Account_Service__c Where Account__c=:objAccount.Id AND ODS_Service__c=: serviceName.Id AND Contact__c =: objAccount.Primary_Customer_Contact__c limit 1];
                if(checkExistCAS.isEmpty()){
                    objAcontactAccountService.add(objContactAccount);   
                }
            }
            list<Project_Team_Member__c> checkExistPTMList=[Select id from Project_Team_Member__c where Account__c=:objAccount.Id AND ODS_Services__c=:serviceName.Id AND Resource_Name__c = 'Resource1' LIMIT 1];
            Project_Team_Member__c projTeamMember = new Project_Team_Member__c();
            projTeamMember = CreateProjectTeamMember(objAccount.Id, serviceName.Id);
            if(projTeamMember != null && checkExistPTMList.isEmpty())
                teamMembers.add(projTeamMember);
        }
        system.debug('objUserAccount--'+objUserAccount);
        if(!objUserAccount.isEmpty()){
            insert objUserAccount;
        }
        if(!objAcontactAccountService.isEmpty()){
            
            insert objAcontactAccountService;
        }
        if(!objAccountService.isEmpty()){
            
            insert objAccountService;
        }
        if(!teamMembers.isEmpty()){
            insert teamMembers;           
        }
        
        for(Account ac:acc)
        {
            Account a = new Account(id = ac.id);
            a.Created_Childs_Automatically__c = True ; 
            UpdateAccount.add(a); 
        } 
        Update UpdateAccount;
        
    }
    
    
    
    public static Project_Team_Member__c CreateProjectTeamMember(string accountId, string serviceId)
    {
        Project_Team_Member__c teamMember = new Project_Team_Member__c();
        teamMember.Account__c = accountId;
        teamMember.ODS_Services__c = serviceId;
        teamMember.Resource_Name__c = 'Resource1';
        return teamMember;   
    }
    
    private Static User getReportingManagerDetails(string userId){
        
        return [SELECT Id,ManagerId,UserRole.Name FROM User where Id=:userId Limit 1];
    }
    Private static Map<id,User_Account__c> checkExistUserAccount(String accountId, string serviceId){
        Map<id,User_Account__c> userAccountMap=new  Map<id,User_Account__c>();
        List<User_Account__c> userAccountList=[SELECT Account__c,ODS_Services__c,User__c FROM User_Account__c where 
                                               Account__c=:accountId AND ODS_Services__c=: serviceId];
        for(User_Account__c ua:userAccountList){
            userAccountMap.put(ua.User__c,ua);
        }
        return userAccountMap;
    }
  
}