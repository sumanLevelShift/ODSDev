/*******************************************************************************************
* @author           Aarthy
* @version          1.0 
* @date             27-DEC-2017
* @Status           Developed
* @Class Name     IntroductionAndKickoffEmailTrigger
* @description      This trigger fires before update on account,to send welcome abroad, kick off mail and other emails.

*********************************************************************************************
Version   	Date      	Team     	Comments
*********************************************************************************************
* 3     	28-OCT-2020	Gireesh		Added the Primary Customer Contact email validation and error messages.
* 2     	Apr 2018  	Mani&Team	Story CP-19, CP-20, CP-21 and CP-24 - changes to trigger emails when kickoff is completed.
* 1      	Dec 2017    Aarthy      Initial Creation
*********************************************************************************************/

trigger IntroductionAndKickoffEmailTrigger on Account (before update,after update) 
{   
    Boolean enableKickOffReset=boolean.valueOf(System.Label.ENABLE_KICKOFF_RESET_ON_ACCOUNT);
    Set<Id> PrimarycontactIds = new Set<Id>();     
    Set<Id> accountOwnerIdSet=new Set<Id>();
    Set<Id> CSMSet=new Set<Id>();
    List<Account> acctsToSendEmail = new List<Account>();
    List<Account> acctsForInvoices = new List<Account>();
    Map<String,OrgWideEmailAddress> Org_wideaddress=new Map<String,OrgWideEmailAddress>();
    Set<Id> allPrimarycontactIds = new Set<Id>(); 
    OrgWideEmailAddress[] list_Orgwideaddress= [select Id, address from OrgWideEmailAddress];
    for(OrgWideEmailAddress owa: list_Orgwideaddress)
    {
        if(!Org_wideaddress.containsKey(owa.address))
        {
            Org_wideaddress.put(owa.address,owa);
        }       
    }
    
    /* Trigger will fires only if customer engagement type is "ODS" and SOW is "Fully-Executed" and Account_Status is "Customer" or "Active Customer" */
    if(trigger.isBefore && trigger.isUpdate)
    {
        if(isRecursiveAccountTrigger.runOnce())
        {
            for(Account accountNew: trigger.new)
            {
                if(accountNew.Primary_Customer_Contact__c != Null){
                    allPrimarycontactIds.add(accountNew.Primary_Customer_Contact__c);                                   
                }
            }
            Map<id,Contact> allContactsMap = new Map<Id,Contact>([SELECT id,Email FROM Contact WHERE Id IN :allPrimarycontactIds]);
           
            //START DL-161 - Trigger Kick-off emails on returning customers
            if(enableKickOffReset){
                ResetCustomerAccountsHelper.resetCustomerDetails(trigger.new, Trigger.newMap.keySet(), Trigger.oldMap);
            }
            
            for(Account acc: trigger.new){
                system.debug('venkat account details before if condition'+acc);
                system.debug('CET'+acc.Customer_Engagement_Type__c);
                system.debug('CET'+acc.SOW__c);
                system.debug('CET'+acc.Account_Status__c); 
                
                if(acc.Customer_Engagement_Type__c == 'ODS' && acc.SOW__c == 'Fully Executed' && (acc.Account_Status__c == 'Customer' || acc.Account_Status__c == 'Active Customer' ) )
                {
                    system.debug('venkat account details inside if '+acc);
                    acctsToSendEmail.add(acc);  
                    accountOwnerIdSet.add(acc.ownerId);
                    CSMSet.add(acc.user__c);
                    if(acc.Backup_CSM__c != null){
                        CSMSet.add(acc.Backup_CSM__c);
                    }
                    if(acc.Customer_Success_Executive__c != null){
                        CSMSet.add(acc.Customer_Success_Executive__c);
                    }
                    if(acc.Primary_Customer_Contact__c != Null){
                        PrimarycontactIds.add(acc.Primary_Customer_Contact__c); 
                        Contact objContact = allContactsMap.get(acc.Primary_Customer_Contact__c);
                        if(string.isBlank(objContact.email)){
                            acc.addError('Email of the Primary Customer Contact should not be empty!!!');
                        }
                    }else{
                        acc.addError('Primary Customer Contact should not be empty!!!');
                    }
                }  
                
                //Mani&Team - Story CP19- follow up Email for env access email send  - code for follow up email - change starts.
                //To capture the date when kickoff is set to completed
                Account oldAcc = trigger.oldMap.get(acc.Id);
                if(String.isNotBlank(acc.Kickoff__c) && acc.Kickoff__c == 'Completed' && acc.Kickoff__c != oldAcc.Kickoff__c) 
                {
                    acc.KickOff_Completed_Date__c = System.Today();
                    acctsForInvoices.add(acc);
                }
                
                //To capture the date when Environment access is set to completed
                if(String.isNotBlank(acc.Environment_Access__c) && acc.Environment_Access__c == 'Completed' && acc.Environment_Access__c != oldAcc.Environment_Access__c) {
                    acc.EnviAccCompletedDate__c = System.Today();
                }
                //Mani&Team - Story CP19- follow up email for env access email send - code change ends.
                
            }
            
            Map<Id,user> ownerEmailMap=new Map<id,user>([Select id,email from user where id IN:accountOwnerIdSet]);
            Map<Id,user> CSMMap=new Map<id,user>([Select id,email from user where id IN:CSMSet]);
            Map<Id,Contact> PrimarycontactsMap = new Map<Id,Contact>([Select Id,Name,Email from contact where Id = : PrimarycontactIds]);
            system.debug('PrimarycontactsMap' +PrimarycontactsMap);
            isRecursiveAccountTrigger.firedfromAccount();
            AccountHandler.sendEmail(acctsToSendEmail, Org_wideaddress, ownerEmailMap, CSMMap, PrimarycontactsMap);
            //Mani&Team - Story CP19 to CP21 & CP24 - added below handler to send different emails once kick off is set to complete.
            system.debug('----------------------------------------'+acctsToSendEmail);
            AccountHandler.sendEmailOnKickoffComplete(acctsToSendEmail, Org_wideaddress, ownerEmailMap, CSMMap, PrimarycontactsMap);
            AccountHandler.sendEmailToInvoiceTeam(acctsForInvoices);
        }        
    }  
    
    if(trigger.isAfter && trigger.isUpdate){
        if(enableKickOffReset){
            ResetCustomerAccountsHelper.resetContactAccountService(); 
        }
    }
}