/*Created By: Soumya N
Date: 10/10/14
Description: This Class is used by opportunity_SendEmails trigger to send emails to all Active
             Users when Opportunity Stage changes to "Opportunity Won"
*/

public Class Opportunity_SendEmailCntrl
{
    public static void sendEmailMethod(LIST<Opportunity> opportunity_List)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();
        String[] emailIds = new String[] {};
        String strOppEmailId = System.Label.OpportunitySendEmail; 
        list<string> lstAWSEmailIds=new list<string>();
        list<string> lstEmailIds=new list<string>();
        Set<String> set_emailIds=new set<String>();
        String[] lstBCCEmailIds=new String[]{};
        try
        {     
            //Set of email ids getting from custom label               
            lstEmailIds=strOppEmailId.split(',');   
            for(String strEmailId:lstEmailIds)
            {
                if((!String.isBlank(strEmailId)) && (strEmailId!='null'))
                {
                    set_emailIds.add(strEmailId);                                 
                }
            }    
            system.debug('System.Label.OpportunitySendEmailBCC-'+System.Label.OpportunitySendEmailBCC);
            for(String strEmailId:System.Label.OpportunitySendEmailBCC.split(','))
            {
                if((!String.isBlank(strEmailId)) && (strEmailId!='null'))
                {
                    lstBCCEmailIds.add(strEmailId);                                 
                }
            }  
            system.debug('lstBCCEmailIds-'+lstBCCEmailIds);
            System.debug('#####set_emailIds' + set_emailIds);
            
            List<User> usrObj = [select Id, Email from user where isActive=true and Management__c = 'Management' AND PortalUserRole__c = 'Practice Head' limit 1];
            
            system.debug('usrObj:----------------'+usrObj );
            /*if(set_emailIds.contains(usrObj[0].Email)){}
				set_emailIds.remove(usrObj[0].Email);*/
            System.debug('set_emailIds2' + set_emailIds);    
            emailIds.addAll(set_emailIds);
            
            System.debug('emailIds**' + emailIds);
            
            EmailTemplate mailTemplate = [Select Id from EmailTemplate where Name = 'Opportunity Project Synopsis' limit 1];
            
            for (Opportunity opportunityObj : opportunity_List) 
            {         
                if(opportunityObj.StageName == 'Closed Won')
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    mail.setWhatId(opportunityObj.Id);
                    mail.setTemplateId(mailTemplate.Id);
                    mail.setTargetObjectId(usrObj[0].Id);
                    List<account> lstacc = [Select id,name,ODS_AWS__c,ODS_AWS_Account_Status__c from Account where Id =: opportunityObj.Id AND ODS_AWS__c = true AND ODS_AWS_Account_Status__c = '5a: Outcome - Opportunity'];
                    if(lstacc.size() >0)
                    {                      
                        String strOppAWSEmailId = System.Label.OpportunitySendEmailAWS;
                        lstAWSEmailIds=strOppAWSEmailId.split(',');   
                        for(String strAWSEmailId :lstAWSEmailIds)
                        {
                            if((!String.isBlank(strAWSEmailId)) && (strAWSEmailId !='null'))
                            {
                                emailIds.add(strAWSEmailId);                                 
                            }
                        }    
                    }
                    if(!lstBCCEmailIds.isEmpty()){
                        system.debug('here---');
                        mail.setBccAddresses(lstBCCEmailIds);
                    }
                    if(emailIds != NULL && emailIds.size()>1)
                        mail.setToAddresses(emailIds);
                    mail.setSaveAsActivity(false);              
                    system.debug('mail-'+mail);
                    //Add email to the list
                    mails.add(mail); 
                }
            }
            
            //Send all emails
            if(mails != null && !mails.isEmpty())
                Messaging.sendEmail(mails);
        }catch(Exception e) { System.debug('Exception Occured: ' + e.getMessage()); }
    }
}