/*****************************************************************************************
* @author           Aarthy
* @version          1.0 
* @date             27-DEC-2017
* @Status           Developed
* @Class Name       AccountHandler
* @description      This trigger handler is to send emails viz:welcome abroad, kick off,
env access, lightnign readiness and Onboard docs.
******************************************************************************************
Version     Date           Team                    Comments
******************************************************************************************
* 3.0       Apr 2020        Indhu                   Updating the criteria to check if lightning readiness check is completed.
* 2.2       Apr 2018        Mani&Team               Story CP-19, CP-20, CP-21 and CP-24 - changes to trigger emails when kickoff is completed.
* 2.1       Apr 2018        Mani&Team               Story CP-18 - changes done to add Bcc address for introduction and Kickoff email.
* 1         Dec 2017        Aarthy                  Initial Creation
******************************************************************************************/


public with sharing class AccountHandler
{            		
    /*  This method is for sending welcome_onboard_template and kickoff_template */
    public static void sendEmail(List<Account> List_Accounts, Map<String,OrgWideEmailAddress> Org_wideaddressMap, Map<Id,user> ownerEmailMap, 
                                 Map<Id,user> CSMMap, Map<Id,Contact> PrimarycontactsMap)
    {
        List<account> accountlist = new List<account>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        List<String> practice_HeadsAddress = new List<String>();
        List<User> users = [SELECT Email FROM User WHERE PortalUserRole__c = 'Practice Head' AND IsActive = true AND Email != null AND Management__c = 'Practice Head'];
        Set<ID> roleIdToGetUsers = New Set<ID>();
        ODS_Industry_Mapping__mdt[] CSSIndustryEmails = [Select MasterLabel, IndustryName__c, CSS_Industry_Email__c,Industry_Practice_Role_Id__c from ODS_Industry_Mapping__mdt];
        
        //PB-144
        string profileName=Label.ODS_ReportingManagerRoles;
        List<String> ReportingManagerNameList = profileName.split(',');
        list<string> reportingManagerRoleAfterTrim=new List<string>();
        for(string role:ReportingManagerNameList){
            reportingManagerRoleAfterTrim.add(role.trim());
        }
        
        Map<id,User> reportingManagerDetails=new Map<id,user>([SELECT Id,Name,ManagerId,UserRole.Name,Email FROM User where IsActive = true AND UserRole.Name IN :reportingManagerRoleAfterTrim]);
        /*  This loop is for adding all the user_emails to ccAddress whose PortalUserRole= 'Practice Head'*/
        for(User obj_user: users)
        {
            if(obj_user.email != null){
                practice_HeadsAddress.add(obj_user.email);
            }
        }     
        
        for(Account acc: List_Accounts)
        {
            if(acc.SOW__c == 'Fully Executed' && acc.Primary_Customer_Contact__c != null
               && acc.CheckIntroDuplicate__c == false
               && acc.User__c != null
               && acc.isSentIntroductionMail__c == false
               && acc.TriggerKickoffMail__c == false
               && (acc.Account_Status__c == 'Customer' ||
                   acc.Account_Status__c == 'Active Customer'))
            { 
                accountlist.add(acc);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(acc.Small_Business__c){
                    mail.templateId = Label.ODS_SB_welcome_onboard_template;    
                }else{
                    mail.templateId = Label.welcome_onboard_template;
                }
                toAddress.clear();
                if(acc.Primary_Customer_Contact__c != null){ 
                    mail.targetObjectId = acc.Primary_Customer_Contact__c;
                }
                
                /* Add the account owner as from address to the mail whose account owner email is not null. */
                if(ownerEmailMap.containsKey(acc.ownerId))
                {
                    user owner = ownerEmailMap.get(acc.ownerId);
                    if(Org_wideaddressMap.containskey(owner.Email) && Org_wideaddressMap.get(owner.Email) != null)
                    {
                        OrgWideEmailAddress owaAddress=Org_wideaddressMap.get(owner.Email);                        
                        mail.setOrgWideEmailAddressId(owaAddress.id); 
                        
                    }  
                }
                
                
                
                /* Add Primary customer contact as to address whose email is not null and the
Customer Success Manager mail as ccAddress whose email is not null . */
                if(PrimarycontactsMap.containsKey(acc.Primary_Customer_Contact__c)&& PrimarycontactsMap.get(acc.Primary_Customer_Contact__c).email!=null)
                {
                    toAddress.add(PrimarycontactsMap.get(acc.Primary_Customer_Contact__c).email);                     
                    mail.toAddresses = toAddress;
                    mail.setBccSender(true);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setWhatId(acc.id);
                    mail.setSaveAsActivity(true);  
                    List<String> ccAddress = new List<String>();
                    if(CSMMap.get(acc.User__c).Email != null)
                    {
                        ccAddress.add(CSMMap.get(acc.User__c).Email);  
                    }
                    if(CSMMap.containsKey(acc.Backup_CSM__c) && String.isNotBlank(CSMMap.get(acc.Backup_CSM__c).Email))
                    {
                        ccAddress.add(CSMMap.get(acc.Backup_CSM__c).Email);  
                    }
                    if(CSMMap.containsKey(acc.Customer_Success_Executive__c) && String.isNotBlank(CSMMap.get(acc.Customer_Success_Executive__c).Email))
                    {
                        ccAddress.add(CSMMap.get(acc.Customer_Success_Executive__c).Email);  
                    }
                    if(practice_HeadsAddress.size() > 0)
                    {
                        ccAddress.addAll(practice_HeadsAddress);
                        
                    }
                    
                    //PB-144 add reporting manager of CSM to cc
                    User CSMUser=getReportingManagerDetails(acc.User__c);
                    User managersOfCSM=reportingManagerDetails.get(CSMUser.ManagerId);
                    If(managersOfCSM !=null){
                        ccAddress.add(managersOfCSM.Email);
                        
                    }
                    system.debug('ccAddress---'+ccAddress);
                    
                    //04-01-2020-SD-Change:
                    for(ODS_Industry_Mapping__mdt record:CSSIndustryEmails) {
                        if(acc.Industry != null && acc.Industry == record.IndustryName__c){
                            if(record.Industry_Practice_Role_Id__c != null){
                                
                                roleIdToGetUsers.add(record.Industry_Practice_Role_Id__c);
                            } 
                        }
                    }
                    if(roleIdToGetUsers.Size() >0){
                        
                        List<User> usersList = [SELECT Email,UserRoleId  FROM User WHERE Email != null AND IsActive = true AND UserRoleId  =:roleIdToGetUsers AND Management__c IN ('Practice Head','Industry Practice Head')];
                        if(usersList.size() > 0){
                            for(user userToAddCCaddress :usersList)
                                
                                ccAddress.add(userToAddCCaddress.Email);
                        }
                    }
                    if(ccAddress.size() > 0){
                        mail.ccAddresses = ccAddress;
                    }
                    //04-01-2020-SD-Change:
                    
                    // Stroy CP-18 -- Mani&team changes starts - to add bcc address for introduction email  
                    List<String> bccAddress = new List<String>();
                    if(String.isNotBlank(ownerEmailMap.get(acc.OwnerId).Email))
                    {
                        bccAddress.add(ownerEmailMap.get(acc.OwnerId).Email);
                        mail.setBccAddresses(bccAddress);
                    }
                    // Stroy CP-18 -- Mani&team changes ends
                    mails.add(mail);
                }
            }
        }
        
        System.debug('Total outbound emails: '+mails.size());
        if(mails.size() > 0)
        {
            if(!Label.ODS_Skip_Welcome_Aboard_Email.trim().equalsIgnoreCase('true')){
            	Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(mails);                
            }
            for(Account acc:accountlist){
                acc.Introduction_Email__c = 'Completed';
                acc.isSentIntroductionMail__c = true;
            }
        } 
        
        mails.clear();
        accountlist.clear();
        toAddress.clear();
        
        system.debug('List_Accounts---'+List_Accounts);
        for(Account acc: List_Accounts)
        {
            if(acc.SOW__c == 'Fully Executed'
               && acc.Primary_Customer_Contact__c != null
               && acc.User__c != null
               && acc.isSentIntroductionMail__c == true
               && acc.TriggerKickoffMail__c == true
               && acc.CheckIntroDuplicate__c == false
               && (acc.Account_Status__c == 'Customer' ||
                   acc.Account_Status__c == 'Active Customer')
              ){
                  accountlist.add(acc);
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  system.debug('String.isBlank(acc.CSM_Meeting_Invite_URL__c)'+String.isBlank(acc.CSM_Meeting_Invite_URL__c));
                  if(acc.Small_Business__c){
                    if(String.isBlank(acc.CSM_Meeting_Invite_URL__c))
                      {
                          mail.templateId = Label.ODS_SB_kickoff_template_ALT;
                      }
                      else{
                          mail.templateId = Label.ODS_SB_kickoff_template; 
                      }  
                  }else{
                      if(String.isBlank(acc.CSM_Meeting_Invite_URL__c))
                      {
                          mail.templateId = Label.kickoff_template_ALT;
                      }
                      else{
                          mail.templateId = Label.kickoff_template; 
                      }
                  }
                  toAddress.clear();
                  
                  if(acc.Primary_Customer_Contact__c != null){
                      mail.targetObjectId = acc.Primary_Customer_Contact__c;
                  }
                  
                  /* Add CSM email address as from address whose email is not null */
                  if(CSMMap.containsKey(acc.user__c))
                  {
                      user CSM = CSMMap.get(acc.user__c);
                      if(CSM.Email != null)
                      {                  
                          if(Org_wideaddressMap.containskey(CSM.Email))
                          {
                              OrgWideEmailAddress owaAddress=Org_wideaddressMap.get(CSM.Email);                     
                              mail.setOrgWideEmailAddressId(owaAddress.id);                                           
                          }
                      }  
                  }
                  
                  /* Add Primary customer contact as to address whose email is not null and 
the owner email in ccAddress whose email is not null. */
                  if(PrimarycontactsMap.containsKey(acc.Primary_Customer_Contact__c)&& PrimarycontactsMap.get(acc.Primary_Customer_Contact__c).email!=null)
                  {
                      toAddress.add(PrimarycontactsMap.get(acc.Primary_Customer_Contact__c).email);  
                      mail.toAddresses = toAddress;
                      mail.setBccSender(true);
                      mail.setTreatTargetObjectAsRecipient(false);
                      mail.setWhatId(acc.id);
                      mail.setSaveAsActivity(true);
                      List<String> ccAddress = new List<String>();
                      if(ownerEmailMap.containsKey(acc.ownerId)&&ownerEmailMap.get(acc.ownerId).email != null)
                      {
                          ccAddress.add(ownerEmailMap.get(acc.ownerId).email);  
                      }   
                      if(CSMMap.containsKey(acc.Backup_CSM__c) && String.isNotBlank(CSMMap.get(acc.Backup_CSM__c).Email))
                      {
                          ccAddress.add(CSMMap.get(acc.Backup_CSM__c).Email);  
                      }
                      if(CSMMap.containsKey(acc.Customer_Success_Executive__c) && String.isNotBlank(CSMMap.get(acc.Customer_Success_Executive__c).Email))
                      {
                          ccAddress.add(CSMMap.get(acc.Customer_Success_Executive__c).Email);  
                      }
                      if(practice_HeadsAddress.size() > 0) 
                      {
                          ccAddress.addAll(practice_HeadsAddress);
                      }
                      system.debug('AccountHandlerccAddress'+ccAddress);
                      //04-01-2020-SD-Change:
                      for(ODS_Industry_Mapping__mdt record:CSSIndustryEmails) {
                          if(acc.Industry != null && acc.Industry == record.IndustryName__c){
                              if(record.Industry_Practice_Role_Id__c != null){
                                  
                                  roleIdToGetUsers.add(record.Industry_Practice_Role_Id__c);
                              } 
                          }
                      }
                      if(roleIdToGetUsers.Size() >0){
                          
                          List<User> usersList = [SELECT Email,UserRoleId  FROM User WHERE Email != null AND IsActive = true AND UserRoleId  =:roleIdToGetUsers AND Management__c IN ('Practice Head','Industry Practice Head')];
                          if(usersList.size() > 0){
                              for(user userToAddCCaddress :usersList)
                                  
                                  ccAddress.add(userToAddCCaddress.Email);
                              system.debug('AccountHandlerccAddress'+ccAddress);
                          }
                      }
                      //PB-144
                      User CSMUser=getReportingManagerDetails(acc.User__c);
                      User managersOfCSM=reportingManagerDetails.get(CSMUser.ManagerId);
                      If(managersOfCSM !=null){
                          ccAddress.add(managersOfCSM.Email);
                          
                      }
                      
                      //04-01-2020-SD-Change:
                      if(ccAddress.size() > 0){
                          system.debug('AccountHandlerccAddress'+ccAddress);
                          mail.ccAddresses = ccAddress;
                      }
                      // Stroy CP-18 -- Mani&team changes starts - to add bcc address for kickoff email 
                      List<String> bccAddress = new List<String>();
                      if(String.isNotBlank(CSMMap.get(acc.user__c).Email))
                      {
                          bccAddress.add(CSMMap.get(acc.user__c).Email);                            
                      }                        
                      if(bccAddress.size() > 0){
                          mail.setBccAddresses(bccAddress);
                      }
                      // Stroy CP-18 -- Mani&team changes ends.
                      mails.add(mail);               
                  }
              }          
        }
        
        
        
        if(mails.size() > 0 && !Label.ODS_Skip_Schedule_Kickoff_Email.trim().equalsIgnoreCase('true'))
        {
            //system.debug('mails:::::' + mails);
            Messaging.SendEmailResult[] mailResult = Messaging.sendEmail(mails);
        }       
        for(account acc:accountlist){
            acc.Kickoff__c = 'Email Sent';
            acc.CheckIntroDuplicate__c = true;
        }   
        
    }
    
    //Mani&Team - Story CP19, CP20, CP21, CP24- send env acces, onboard documentation and lightning readiness email upon kickoff complete- code change starts 
    //This method will be executed once the KickOff field is updated to completed status.
    public static void sendEmailOnKickoffComplete (List<Account> acctsToSendEmailList, Map<String,OrgWideEmailAddress> Org_wideaddressMap, Map<Id,user> ownerEmailMap, 
                                                   Map<Id,user> CSMMap, Map<Id,Contact> PrimarycontactsMap)
    {
        
        List<account> accountlist = new List<account>();
        
        
        
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> practiceHeadList = new List<String>();
        List<String> toAddressList = new List<String>();
        List<String> ccAddressList = new List<String>();
        Set<ID> roleIdToGetUsers = New Set<ID>();
        ODS_Industry_Mapping__mdt[] CSSIndustryEmails = [Select MasterLabel, IndustryName__c, CSS_Industry_Email__c,Industry_Practice_Role_Id__c from ODS_Industry_Mapping__mdt];
        
        
        for(User userObj: ODS_EmailUtils.getPracticeHeadEmail())
        {
            if(userObj.email != null)
            {
                practiceHeadList.add(userObj.email);
            }
        } 
        
        for(Account acc : acctsToSendEmailList)
        {
            if(acc.Primary_Customer_Contact__c != null && acc.User__c != null && acc.isSentIntroductionMail__c == true
               && acc.TriggerKickoffMail__c == true && acc.Kickoff__c == 'Completed')
            {
                //this if block is to trigger email for Onboarding documentation and lightning readiness notification once environmental access is completed. CP20 starts
                if(acc.IsEnvironmentAccessEmail__c == true
                   && acc.IsInitialEstEmailSent__c == true
                   && acc.Environment_Access__c  == 'Completed'
                   && acc.isOnboardingDocumentationEmailSent__c == false
                   && acc.isLightningReadinessEmailSent__c == false 
                   && acc.Lightning_Readiness_Check__c != 'Completed') // to avoid reccursive email sending 
                {
                    accountlist.add(acc);
                    //The below apex mail is to intialize onboarding documentation once env access is completed
                    //CP20 - trigger onboarding email once environmental access is completed - changes starts. 
                    Messaging.SingleEmailMessage onboardingEmail = new Messaging.SingleEmailMessage();
                    onboardingEmail.templateid = Label.ODS_OnboardingDocumentEmail; 
                    onboardingEmail.targetObjectId = acc.Primary_Customer_Contact__c; 
                    
                    //from address customization - owa sf system admin address
                    for(OrgWideEmailAddress owa : ODS_EmailUtils.getSFAdminEmail())
                    {
                        if(owa.DisplayName == 'Salesforce Admin' && String.isNotBlank(owa.Address))
                        {
                            onboardingEmail.setOrgWideEmailAddressId(owa.id);
                        }
                    }
                    
                    /* Add CSM in toAddress and Practice Head email in ccAddress */
                    if(CSMMap.containsKey(acc.user__c) && String.isNotBlank(CSMMap.get(acc.user__c).Email))
                    {
                        toAddressList.clear();
                        toAddressList.add(CSMMap.get(acc.user__c).Email); 
                        onboardingEmail.setToAddresses(toAddressList);
                        onboardingEmail.setWhatId(acc.id);
                        onboardingEmail.setBccSender(false);
                        onboardingEmail.setTreatTargetObjectAsRecipient(false);
                        onboardingEmail.setSaveAsActivity(true);
                        
                        if(CSMMap.containsKey(acc.Backup_CSM__c) && String.isNotBlank(CSMMap.get(acc.Backup_CSM__c).Email)){
                            ccAddressList.add(CSMMap.get(acc.Backup_CSM__c).Email);
                        }
                        if(CSMMap.containsKey(acc.Customer_Success_Executive__c) && String.isNotBlank(CSMMap.get(acc.Customer_Success_Executive__c).Email)){
                            ccAddressList.add(CSMMap.get(acc.Customer_Success_Executive__c).Email);
                        }
                        
                        if(!practiceHeadList.isEmpty())
                        {
                            ccAddressList.addAll(practiceHeadList);                            
                        }
                        if(ccAddressList.size() >0){
                            onboardingEmail.ccAddresses = ccAddressList;
                        }
                        emailList.add(onboardingEmail);
                    }
                    acc.isOnboardingDocumentationEmailSent__c = true;
                    //CP20 - trigger onboarding email once environmental access is completed - changes ends. 
                    
                    //The below apex mail is to initialize Lightning readiness email once document onboard is approved.
                    //CP21 - trigger lightning readiness email once environmental access is completed - changes starts. 
                    Messaging.SingleEmailMessage lightningEmail = new Messaging.SingleEmailMessage();
                    lightningEmail.templateid = Label.ODS_LightningReadinessEmail;  
                    lightningEmail.targetObjectId = acc.Primary_Customer_Contact__c; 
                    
                    //from address customization - owa sf system admin address
                    for(OrgWideEmailAddress owa : ODS_EmailUtils.getSFAdminEmail())
                    {
                        if(owa.DisplayName == 'Salesforce Admin' && String.isNotBlank(owa.Address))
                        {
                            lightningEmail.setOrgWideEmailAddressId(owa.id);
                        }
                    }
                    
                    /* Add CSM in toAddress and Practice Head email in ccAddress */
                    if(CSMMap.containsKey(acc.user__c) && String.isNotBlank(CSMMap.get(acc.user__c).Email))
                    {
                        toAddressList.clear();
                        toAddressList.add(CSMMap.get(acc.user__c).Email); 
                        lightningEmail.setToAddresses(toAddressList);
                        lightningEmail.setWhatId(acc.id);
                        lightningEmail.setBccSender(false);
                        lightningEmail.setTreatTargetObjectAsRecipient(false);
                        lightningEmail.setSaveAsActivity(true);
                        
                        if(CSMMap.containsKey(acc.Backup_CSM__c) && String.isNotBlank(CSMMap.get(acc.Backup_CSM__c).Email))
                        {
                            ccAddressList.add(CSMMap.get(acc.Backup_CSM__c).Email); 
                        }
                        if(CSMMap.containsKey(acc.Customer_Success_Executive__c) && String.isNotBlank(CSMMap.get(acc.Customer_Success_Executive__c).Email))
                        {
                            ccAddressList.add(CSMMap.get(acc.Customer_Success_Executive__c).Email); 
                        }
                        
                        if(!practiceHeadList.isEmpty())
                        {
                            ccAddressList.addAll(practiceHeadList);                            
                        }
                        //04-01-2020-SD-Change:
                        for(ODS_Industry_Mapping__mdt record:CSSIndustryEmails) {
                            if(acc.Industry != null && acc.Industry == record.IndustryName__c){
                                if(record.Industry_Practice_Role_Id__c != null){
                                    
                                    roleIdToGetUsers.add(record.Industry_Practice_Role_Id__c);
                                } 
                            }
                        }
                        if(roleIdToGetUsers.Size() >0){
                            
                            List<User> usersList = [SELECT Email,UserRoleId  FROM User WHERE Email != null AND IsActive = true AND UserRoleId  =:roleIdToGetUsers AND Management__c IN ('Practice Head','Industry Practice Head')];
                            if(usersList.size() > 0){
                                for(user userToAddCCaddress :usersList)
                                    
                                    ccAddressList.add(userToAddCCaddress.Email);
                            }
                        }
                        //04-01-2020-SD-Change:
                        if(ccAddressList.size() > 0){
                            lightningEmail.ccAddresses = ccAddressList;
                        }
                        emailList.add(lightningEmail);
                    }
                    acc.isLightningReadinessEmailSent__c=true;
                }
                //CP21 - trigger lightning readiness email once environmental access is completed - changes ends.
                //if end - once environmental access is updated to complete. 
                
                //this else if block is to trigger email for env access and initial estimate notify once kickoff is completed. CP19 & CP24 - changes starts
                else if(acc.IsEnvironmentAccessEmail__c == false && acc.IsInitialEstEmailSent__c == false )    // to avoid reccursive email sending for env access and initiative estimate
                { 
                    List<String> toAddressList1 = new List<String>();
                    accountlist.add(acc);
                    
                    //CP19-send email to env access once kick off is completed - changes starts.
                    //The below apex mail is to initialize environmental access mail once kickoff is completed.
                    Messaging.SingleEmailMessage envAccessEmail = new Messaging.SingleEmailMessage();
                    envAccessEmail.templateid = Label.ODS_EnvironmentalAccessEmail; 
                    envAccessEmail.targetObjectId = acc.Primary_Customer_Contact__c; 
                    
                    //from address customization - owa sf system admin address
                    for(OrgWideEmailAddress owa : ODS_EmailUtils.getSFAdminEmail())
                    {
                        if(owa.DisplayName == 'Salesforce Admin' && String.isNotBlank(owa.Address))
                        {
                            envAccessEmail.setOrgWideEmailAddressId(owa.id);
                        }
                    }
                    
                    /* Add CSM in toAddress and Practice Head email in ccAddress */                   
                    if(CSMMap.containsKey(acc.user__c) && String.isNotBlank(CSMMap.get(acc.user__c).Email))
                    {
                        toAddressList.clear();                        
                        toAddressList.add(CSMMap.get(acc.user__c).Email);   
                        envAccessEmail.setToAddresses(toAddressList);
                        envAccessEmail.setWhatId(acc.id);
                        envAccessEmail.setBccSender(false);
                        envAccessEmail.setTreatTargetObjectAsRecipient(false);
                        envAccessEmail.setSaveAsActivity(true);
                        
                        if(CSMMap.containsKey(acc.Backup_CSM__c) && String.isNotBlank(CSMMap.get(acc.Backup_CSM__c).Email))
                        {
                            ccAddressList.add(CSMMap.get(acc.Backup_CSM__c).Email);   
                        }
                        
                        if(!practiceHeadList.isEmpty())
                        {
                            ccAddressList.addAll(practiceHeadList);                            
                        }
                        //04-01-2020-SD-Change:
                        for(ODS_Industry_Mapping__mdt record:CSSIndustryEmails) {
                            if(acc.Industry != null && acc.Industry == record.IndustryName__c){
                                if(record.Industry_Practice_Role_Id__c != null){
                                    
                                    roleIdToGetUsers.add(record.Industry_Practice_Role_Id__c);
                                } 
                            }
                        }
                        if(roleIdToGetUsers.Size() >0){
                            
                            List<User> usersList = [SELECT Email,UserRoleId  FROM User WHERE Email != null AND IsActive = true AND UserRoleId  =:roleIdToGetUsers AND Management__c IN ('Practice Head','Industry Practice Head')];
                            if(usersList.size() > 0){
                                for(user userToAddCCaddress :usersList)
                                    
                                    ccAddressList.add(userToAddCCaddress.Email);
                            }
                        }
                        //04-01-2020-SD-Change:                        
                        
                        if(ccAddressList.size() >0){
                            envAccessEmail.ccAddresses = ccAddressList;
                        }
                        emailList.add(envAccessEmail);
                    }
                    
                    acc.IsEnvironmentAccessEmail__c=true;
                    //CP19 - send mail for env access once kickoff completed - changes ends.
                    
                    //CP24 - send mail for initial estimate once kickoff completed - changes starts.
                    //The below apex mail is to initialize intial estimate mail once kickoff is completed
                    Messaging.SingleEmailMessage initEstmail = new Messaging.SingleEmailMessage();
                    initEstmail.templateid = Label.ODS_InitiaveEstimateStartEmail;  
                    initEstmail.targetObjectId = acc.Primary_Customer_Contact__c; 
                    
                    //from address customization - owa system admin address
                    for(OrgWideEmailAddress owa : ODS_EmailUtils.getSFAdminEmail())
                    {
                        if(owa.DisplayName == 'Salesforce Admin' && String.isNotBlank(owa.Address))
                        {
                            initEstmail.setOrgWideEmailAddressId(owa.id);
                        }
                    }
                    // initEstmail.orgwideemailaddressid=orgWideSFAdminList[0].id;
                    
                    //set CSM as toAddress user and Practice Head in CCAddress
                    if(CSMMap.containsKey(acc.user__c) && String.isNotBlank(CSMMap.get(acc.user__c).Email))
                    {
                        toAddressList1.add(CSMMap.get(acc.user__c).Email);  
                        initEstmail.setToAddresses(toAddressList1);
                        initEstmail.setWhatId(acc.id);
                        initEstmail.setBccSender(false);
                        initEstmail.setTreatTargetObjectAsRecipient(false);
                        initEstmail.setSaveAsActivity(true);
                        
                        if(CSMMap.containsKey(acc.Backup_CSM__c) && String.isNotBlank(CSMMap.get(acc.Backup_CSM__c).Email))
                        {
                            ccAddressList.add(CSMMap.get(acc.Backup_CSM__c).Email);   
                        }
                        
                        if(!practiceHeadList.isEmpty())
                        {
                            ccAddressList.addAll(practiceHeadList);                            
                        }
                        if(ccAddressList.size() >0){
                            initEstmail.ccAddresses = ccAddressList;
                        }
                        emailList.add(initEstmail);
                    }
                    acc.IsInitialEstEmailSent__c=true; //making this checkbox to true to avoid recurrsive email send.
                    //CP24 - send mail for initial estimate once kickoff completed - changes ends.
                }
                //else if ends - for sending env access and initial estimate mail once kickoff is completed.
                
            }//master if end.
            
        }//for loop end.
        
        if(!emailList.isEmpty() && !Label.ODS_Skip_Kickoff_Completed_Email.trim().equalsIgnoreCase('true'))
        {
            //system.debug('emailList:::::' + emailList);
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emailList);
        }
    }
    
    // DL-141 - Kickoff Email Trigger
    public static void  sendEmailToInvoiceTeam(List<Account> accountList)
    {
        Integer noOfDays ; 
        String tpmName;
        String accName;
        Set<Id> accountIdSet = new Set<id>();
        Map<Id,Date> accountKickoff = new Map<Id,Date>();
        
        for(Account acc:accountList){
            accountIdSet.add(acc.id);
            accountKickoff.put(acc.Id,acc.KickOff_Completed_Date__c);
        }
        
        List<Account_Services__c> accountServiceList30DayBefore=[SELECT ID,Contract_Start_Date__c,Account__r.Primary_Customer_Contact__c,Technical_Account_manager__r.Name,Account__c,Account__r.Kickoff__c,Account__r.SOW_Start_Date__c,Account__r.KickOff_Completed_Date__c,Account__r.Name from Account_Services__c  Where Account__c IN: accountIdSet];
        system.debug('accountServiceList30DayBefore---'+accountServiceList30DayBefore);
        
        List<String> sendTo = new List<String>();
        List<String> ccTo = new List<String>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(!accountServiceList30DayBefore.isEmpty())
        {
            for(Account_Services__c accSer:accountServiceList30DayBefore){
                if(accountKickoff.get(accSer.Account__r.Id) !=null){
                    tpmName = accSer.Technical_Account_manager__r.Name;
                    accName = accSer.Account__r.Name;
                    if(accSer.Contract_Start_Date__c == null){
                        noOfDays = (accSer.Account__r.SOW_Start_Date__c.daysBetween(accountKickoff.get(accSer.Account__r.Id)));
                    }
                    else{
                        noOfDays = (accSer.Contract_Start_Date__c.daysBetween(accountKickoff.get(accSer.Account__r.Id)));
                    }
                    system.debug('noOfDays--'+noOfDays);
                    date contractStDate=accSer.Contract_Start_Date__c;
                    
                    if(noOfDays <= 31){
                        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
                        sendTo.add(Label.ODS_Invoice_Sender_Email);
                        mail.setToAddresses(sendTo);
                        ccTo.add(Label.ODS_KickoffCCEmailaddress);
                        mail.setCcAddresses(ccTo);
                        mail.templateid = Label.EmailToInvoiceTeam_Template;  
                        mail.targetObjectId = accSer.Account__r.Primary_Customer_Contact__c;
                        mail.setSaveAsActivity(false);
                        mail.setWhatId(accSer.Account__r.id);
                        mail.setTreatTargetObjectAsRecipient(false);
                        mail.setUseSignature(false);
                        mails.add(mail);                        
                    }
                }                
            }
            if(!mails.isEmpty() && !Label.ODS_Skip_Kickoff_Completed_Email.trim().equalsIgnoreCase('true')){
                Messaging.sendEmail(mails);
            }
        }
    }
    
    //Mani&Team - Story CP19, CP20, CP21, CP24- send env acces, onboard documentation and lightning readiness email upon kickoff complete- code change ends 
    //PB-144
    private Static User getReportingManagerDetails(string userId){
        
        return [SELECT Id,ManagerId,UserRole.Name FROM User where Id=:userId Limit 1];
    }
}