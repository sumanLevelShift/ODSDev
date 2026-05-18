/*****************************************************************************************
* @Author       : Mani & Team
* @Status       : Deployed
* @Class Name   : EnvironmentFollowUpEmailBacth
* @Description  : This batch class is used to send follow up/escalation emails 
                  if appropriate action is not taken. The follow up emails is for env access, 
                  lightning readiness, onboarding etc.
******************************************************************************************
 Version     Date           Team                    Comments
******************************************************************************************
* 1          Apr 2018       Mani&Team               Initial Creation
******************************************************************************************/
global class ODS_EnvironmentFollowUpEmailBacth implements Database.Batchable<sObject>
{
    global final String qry;
    
    global ODS_EnvironmentFollowUpEmailBacth(String q) {
        qry = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(qry);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accountlist = new List<Account>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        List<String> bccAddress = new List<String>();
        //toAddress.add(System.Label.ODS_PrimaryCustomerContactEmail);
        //toAddress.add(Primary_Customer_Contact__r.Email);
        List<String> ccAddress = new List<String>();
        //ccAddress.add('maanikmaestro@gmail.com');
        for(User u: ODS_EmailUtils.getPracticeHeadEmail()) {
            ccAddress.add(u.Email);
        }
        
        /*Map<String,OrgWideEmailAddress> mOWA = new Map<String,OrgWideEmailAddress>();
        for(OrgWideEmailAddress owa: [Select Id,Address FROM OrgWideEmailAddress]) {
            mOWA.put(owa.Address,owa);
        }*/
        
        ODS_FiredFromBatchClass.setFiredFromBatch();
        
        for(Account s: scope) {
            accountlist.add(s);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.templateid = Label.ODS_EnvironmentFollowupEmail;
            mail.targetObjectId = s.Primary_Customer_Contact__c;
            mail.setTreatTargetObjectAsRecipient(false);
            toAddress.add(s.User__r.Email);
            mail.setToAddresses(toAddress);
            mail.setCcAddresses(ccAddress);
            //bccAddress.add(s.User__r.Email);
            //mail.setBccAddresses(bccAddress);
            mail.setBccSender(false);
            mail.setSaveAsActivity(false);
            mail.setWhatId(s.id);
            //mail.setOrgWideEmailAddressId(mOWA.get(s.User__r.Email).Id);
            for(OrgWideEmailAddress owa : ODS_EmailUtils.getSFAdminEmail()) {
                if(owa.DisplayName == 'Salesforce Admin' && String.isNotBlank(owa.Address)) {
                    mail.setOrgWideEmailAddressId(owa.id);
                }
            }
            mails.add(mail);
        }
        
        if(!mails.isEmpty())
        {
            System.debug('mails to be sent: '+mails);
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(mails);
            if(!accountlist.isEmpty()) {
                List<Account> lToBeUpdAcc = new List<Account>();
                for(Account a: accountlist) {
                    a.isFollowedEnvironmentAccess__c = true;
                    lToBeUpdAcc.add(a);
                }
                
                if(!lToBeUpdAcc.isEmpty()) {
                    System.debug('accounts to be updated: '+lToBeUpdAcc);
                    update lToBeUpdAcc;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //Reset fired from batch global flag
        ODS_FiredFromBatchClass.resetFiredFromBatch();
    }
}