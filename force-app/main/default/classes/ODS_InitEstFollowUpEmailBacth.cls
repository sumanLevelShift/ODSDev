/**************************************************************************************
* @Author       : Mani & Team
* @Status       : Deployed
* @Class Name   : ODS_InitEstFollowUpEmailBacth
* @Description  : This is a batch class to send follow up email for Initial Estimate Email                
***************************************************************************************
 Version     Date           Team                    Comments
***************************************************************************************
* 1          Apr 2018       Mani&Team               Initial Creation
***************************************************************************************/
global class ODS_InitEstFollowUpEmailBacth implements Database.Batchable<sObject>
{
    global final String qry;
    
    global ODS_InitEstFollowUpEmailBacth(String q) {
        qry = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(qry);
    }
    
    global void execute(Database.BatchableContext BC, List<Initiatives__c> scope) {
        List<Initiatives__c> initlist = new List<Initiatives__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        //toAddress.add('venkt07@gmail.com');   //update after testing
        for(User u: ODS_EmailUtils.getPracticeHeadEmail()) {
            toAddress.add(u.Email);
        }
        List<String> ccAddress = new List<String>();                         
        
        ODS_FiredFromBatchClass.setFiredFromBatch();
                
        for(Initiatives__c s: scope) {
            initlist.add(s);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.templateid = Label.ODS_InitEstimateFollowupEmail;    //To do: create separate template
            mail.targetObjectId = s.Account_Service__r.Account__r.Primary_Customer_Contact__c;
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setToAddresses(toAddress);
            //ccAddress.add('maanikmaestro@gmail.com');     //update after testing
            ccAddress.add(s.Account_Service__r.Account__r.User__r.Email);  
            mail.setCcAddresses(ccAddress);
            mail.setWhatId(s.id);
            mail.setBccSender(false);
            mail.setSaveAsActivity(false);
            for(OrgWideEmailAddress owa : ODS_EmailUtils.getSFAdminEmail()) {
                if(owa.DisplayName == 'Salesforce Admin' && String.isNotBlank(owa.Address)) {
                    mail.setOrgWideEmailAddressId(owa.id);
                }
            }
            
            mails.add(mail);
        }
        
        if(!mails.isEmpty())
        {
            System.debug('mails to send: '+mails);
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(mails);
            if(!initlist.isEmpty()) {
                List<Initiatives__c> lToBeUpdInit = new List<Initiatives__c>();
                for(Initiatives__c a: initlist) {
                    a.isFollowedInitEstimate__c = true;
                    lToBeUpdInit.add(a);
                }
                
                if(!lToBeUpdInit.isEmpty()) {
                    System.debug('Initiatives to update: '+lToBeUpdInit);
                    update lToBeUpdInit;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //Reset fired from batch global flag
        ODS_FiredFromBatchClass.resetFiredFromBatch();
    }
}