/**************************************************************************************
* @Author       : Mani & Team
* @Status       : Deployed
* @Class Name   : ODS_OnboardLightnFollowUpEmailBacth
* @Description  : Once Environment access is completed, if onboarding doc not given within 10 days and lightning readiness not checked within 3 days
                ----send escalation/followup email            
***************************************************************************************
 Version     Date           Team                    Comments
***************************************************************************************
* 1          Apr 2018       Mani&Team               Initial Creation
***************************************************************************************/

global class ODS_OnboardLightnFollowUpEmailBacth implements Database.Batchable<sObject>
{
    global final String qry;
    global String fld;
    
    global ODS_OnboardLightnFollowUpEmailBacth(String q,String f) {
        qry = q; fld = f;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(qry);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accountlist = new List<Account>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        //toAddress.add('venkt07@gmail.com');    //update after testing
        for(User u: ODS_EmailUtils.getPracticeHeadEmail()) {
            toAddress.add(u.Email);
        }
        List<String> ccAddress = new List<String>();       
        
        ODS_FiredFromBatchClass.setFiredFromBatch();
        
        for(Account s: scope) {
            accountlist.add(s);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(fld == 'onboardingDoc') mail.templateid = Label.ODS_OnBoardingDocFollowupEmail; //To do: create separate template
            else mail.templateId = Label.ODS_LightnReadyFollowupEmail;  //To do: create separate template
            mail.targetObjectId = s.Primary_Customer_Contact__c;
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setToAddresses(toAddress);
            //ccAddress.add('maanikmaestro@gmail.com');     //update after testing
            ccAddress.add(s.User__r.Email);
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
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(mails);
            if(!accountlist.isEmpty()) {
                List<Account> lToBeUpdAcc = new List<Account>();
                for(Account a: accountlist) {
                    if(fld == 'onboardingDoc') a.isFollowedOnboardDoc__c = true;
                    else a.isFollowedLightnReady__c = true;
                    
                    lToBeUpdAcc.add(a);
                }
                
                if(!lToBeUpdAcc.isEmpty()) {
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