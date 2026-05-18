/*
*Author.............: Mani & Team
*Date...............: 17/May/2018
*Purpose............: Send invoice to customer when Account services subscription type updated to -Upfront-
*TestClass..........: ODS_Invoice_Upfornt_Test
*/
public class ODS_Invoice_Upfornt
{    
    public static void sendUpfrontInvoice(List<Account_Services__c> lAsv,Map<Id,Account_Services__c> mOldAcs,String runningEvent) {
        Set<Id> sAsv = new Set<Id>();
        system.debug('@@Executing upfront handler:'+runningEvent );    
        for(Account_Services__c acs:lAsv) {
            //After Insert context
            if(runningEvent == 'AfterInsert') {
                if(acs.Retainer_Fee_Frequency_Type__c.equalsIgnoreCase('Upfront') && acs.Do_not_send_invoice__c == false
                    && acs.Trigger_Subscription_Invoice__c == true && acs.isTriggerRecursiveUpdate__c == false && acs.Invoice_Trial_Running__c == false
                    && acs.Contract_End_Date__c != null && System.today() <= acs.Contract_End_Date__c && acs.Retainer_Fee_Amount__c != null) {
                    sAsv.add(acs.Id);
                    system.debug('@@Executing after insert upfront'+sAsv.size());                    
                }
            }else if(runningEvent == 'AfterUpdate'){
                //After Update context
                Account_Services__c oldAcs = mOldAcs.get(acs.Id);                
                if(acs.Retainer_Fee_Frequency_Type__c.equalsIgnoreCase('Upfront') && acs.Do_not_send_invoice__c == false
                    && acs.Trigger_Subscription_Invoice__c == true && acs.isTriggerRecursiveUpdate__c == false
                    && System.today() <= acs.Contract_End_Date__c && acs.Invoice_Trial_Running__c == false
                    && (acs.Contract_End_Date__c != oldAcs.Contract_End_Date__c || 
                    acs.Retainer_Fee_Amount__c != oldAcs.Retainer_Fee_Amount__c || 
                    acs.Retainer_Fee_Frequency_Type__c != oldAcs.Retainer_Fee_Frequency_Type__c ||
                    acs.Trigger_Subscription_Invoice__c != oldAcs.Trigger_Subscription_Invoice__c)) { 
                    sAsv.add(acs.Id);
                    system.debug('@@Executing after update upfront'+sAsv.size());
                }
            }
        }
        
        if(!sAsv.isEmpty()) {
            if(Boolean.valueOf(System.Label.ODS_Invoice_SendEmail)) {                
                system.debug('@@Sending upfront emails'); 
                constructInvoice(sAsv);
                updAccServAftMail(sAsv);                
            }
        }
    }
    
    //Future call to allow PDF rendering
    @future(callout=true)       
    public static void constructInvoice(Set<Id> sAsv) {
        //Query to get Relationship fields since trigger context does not allow it
        List<Account_Services__c> lAccServ = new List<Account_Services__c>([SELECT Id,                                
                                            Account__c,Account__r.Name,Account__r.SOW__c,
                                            Account__r.Primary_Customer_Email_OptOut__c,Account__r.InvoiceContact__c,
                                            Account__r.Primary_Customer_Email_Id__c,Account__r.BillingStreet,
                                            Account__r.Invoice_Type__c,Account__r.ODS_Invoice_Contact_Email__c,
                                            Account__r.BillingCity,Account__r.BillingState,Account__r.BillingCountry,Account__r.BillingPostalCode,
                                            Retainer_Fee_Frequency_Type__c,Retainer_Fee_Amount__c,Invoice_Upfront_Months__c,Invoice_Upfront_Discount__c,
                                            Subscription_Fee_Discount__c,Contract_Start_Date__c,Purchase_Order__c,
                                            Contract_End_Date__c,Invoice_Sent_Date__c,Invoice_Sent__c,
                                            Contract_Term__c,Account__r.SOW_Status_Date__c,ODS_Service_Name__c,
                                            Account__r.ODS_Invoice_Account_Number__c,Account__r.ODS_Invoice_Count__c
                                            FROM Account_Services__c 
                                            WHERE Account__r.SOW__c = 'Fully Executed' AND 
                                            Contract_End_Date__c != null AND Retainer_Fee_Frequency_Type__c = 'Upfront' AND 
                                            Retainer_Fee_Amount__c != null AND Id IN:sAsv]);
                                            
        List<Messaging.SingleEmailMessage> lEmailsToSend = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        Map<Id,Blob> mAccServAtt = new Map<Id,Blob>();
        
        if(!lAccServ.isEmpty()) { 
        //To avoid EZRE_ContactActivityDateUpdate trigger error
        ODS_FiredFromBatchClass.setFiredFromBatch();
        
        //Invoice team OWD
        Id owdId = null;
        for(OrgWideEmailAddress owa : ODS_EmailUtils.getInvoiceTeamEmail()) {   
            if(String.isNotBlank(owa.Address)) {
                owdId = owa.id;
            }
        }   
        
        //Add practice head email into css address
        for(User u: ODS_EmailUtils.getPracticeHeadEmail()) {
            ///To avoid test class failures - control given on custom label
            if(Boolean.valueOf(System.Label.ODS_Invoice_TestClassControl)) {
                //Label to check whether ccing actual practice head allowed            
                if(Boolean.valueOf(System.Label.ODS_Invoice_CcPracticeHead))
                    ccAddress.add(u.Email);
                else
                    ccAddress.add(System.label.ODS_InvoiceTestEmail);
            }else {
                ccAddress.add(System.label.ODS_InvoiceTestEmail);
            }
        }
                                                  
        for(Account_Services__c ac:lAccServ) {            
            Date StartDate = ac.Contract_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');
            String formatFromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM-dd-yyyy');       
    
            Date EndDate = ac.Contract_End_Date__c;
            String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            String formatToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM-dd-yyyy');
            
            /*Integer monthsBw = ac.Contract_Start_Date__c.monthsBetween(ac.Contract_End_Date__c);
            monthsBw = (monthsBw < 1) ? 1 : monthsBw;
            Double discVal = ac.Subscription_Fee_Discount__c * monthsBw;*/
            Double discVal = (ac.Invoice_Upfront_Months__c*ac.Invoice_Upfront_Discount__c);
            
            PageReference invPdf = Page.ODS_Invoice_SubsMonthlyFormat;
            invPdf.getParameters().put('term',ac.Contract_Term__c);
            invPdf.getParameters().put('billToStr',String.valueOf(ac.Account__r.BillingStreet));
            invPdf.getParameters().put('billToCty',String.valueOf(ac.Account__r.BillingCity));
            invPdf.getParameters().put('billToStat',String.valueOf(ac.Account__r.BillingState));
            invPdf.getParameters().put('billToCtry',String.valueOf(ac.Account__r.BillingCountry));
            invPdf.getParameters().put('billToPcod',String.valueOf(ac.Account__r.BillingPostalcode));
            String constructMth = '';
            if(System.today().month() < 10) constructMth = '0'+String.valueOf(System.today().month());
            else constructMth = String.valueOf(System.today().month());
            Integer invCnt = 0;
            if(ac.Account__r.ODS_Invoice_Count__c != null) invCnt = Integer.valueOf(ac.Account__r.ODS_Invoice_Count__c);
            else invCnt = (System.today().day()-1);
            String invCntPrint = invCnt<10 ? '0'+String.valueOf(invCnt+1) : String.valueOf(invCnt+1);
            String invNumber = String.valueOf(System.today().year())+constructMth+invCntPrint+String.valueOf(ac.Account__r.ODS_Invoice_Account_Number__c);
            invPdf.getParameters().put('invNumb',invNumber);
            invPdf.getParameters().put('accNumb',String.valueOf(ac.Account__r.ODS_Invoice_Account_Number__c));
            invPdf.getParameters().put('billPerd',FromDate+' - '+ToDate);      
            invPdf.getParameters().put('AccServId',ac.Id);
            invPdf.getParameters().put('hrlyRate',String.valueOf(ac.Retainer_Fee_Amount__c));
            invPdf.getParameters().put('mnths',String.valueOf(ac.Invoice_Upfront_Months__c));
            invPdf.getParameters().put('discFee',String.valueOf(discVal));
            invPdf.getParameters().put('startDt',String.valueOf(StartDate));
            invPdf.getParameters().put('endDt',String.valueOf(EndDate));
            invPdf.getParameters().put('subsType','upfront');
            invPdf.getParameters().put('ref',String.valueOf(ac.Purchase_Order__c));
            invPdf.getParameters().put('proj',String.valueOf(ac.ODS_Service_Name__c));
            
            Blob invBody;        
            try { 
                invBody = invPdf.getContentAsPdf();             
            }catch (VisualforceException e) {
                invBody = Blob.valueOf('Weekly Invoice');
            }
            //Capture the blob to upload to Invoice object
            mAccServAtt.put(ac.Id,invBody);
                                        
            Messaging.EmailFileAttachment invAtt = new Messaging.EmailFileAttachment();
            invAtt.setContentType('appliction/pdf');
            invAtt.setFileName('Invoice'+invNumber+'.pdf');
            invAtt.setInline(false);
            invPdf.setRedirect(true);
            invAtt.Body = invBody;
            
            Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
            
            //Beta or Live release
            if(System.Label.ODS_InvoiceReleaseType.equalsIgnoreCase('beta')) {
                toAddress.add(System.Label.ODS_InvoiceBetaEmailID);
            }else {
                if(ac.Account__r.Invoice_Type__c.equalsIgnoreCase('Paper')) { //Using existing field on account to check email option for customer
                    toAddress.add(System.Label.ODS_InvoiceTeam); 
                    //mail.setToAddresses(toAddress);
                }else {
                    if(String.isNotBlank(ac.Account__r.ODS_Invoice_Contact_Email__c)) { 
                        toAddress.add(ac.Account__r.ODS_Invoice_Contact_Email__c);
                        mail.setTargetObjectId(ac.Account__r.InvoiceContact__c);
                        mail.setSaveAsActivity(true);
                        mail.setBccSender(false);
                    }
                    else toAddress.add(System.Label.ODS_InvoiceTeam); //If invoice customer email is empty, we must notify invoice team
                    //mail.setToAddresses(toAddress);
                }
            }
            mail.setToAddresses(toAddress);
            mail.setOrgWideEmailAddressId(owdId);
            mail.setCcAddresses(ccAddress);
            
            String subject = 'Levelshift Invoice for '+ac.ODS_Service_Name__c+' ODS (Upfront Subscription Fee)'+' from ' + (ac.Contract_Start_Date__c).format() 
            + ' to ' +(ac.Contract_End_Date__c).format();
            mail.setSubject(subject);
    
            String strHtmlBody = '' ;        
            strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3"><b>Hi,</b>'+' <br/><br/><b>Please find the attached Invoice for \''+ac.ODS_Service_Name__c+' On Demand Services (Upfront Subscription Fee)\' for the period '+(ac.Contract_Start_Date__c).format() + ' through ' +(ac.Contract_End_Date__c).format()
                + '.<br/><br/>'+'Please confirm the receipt and reach us if you have any questions!</b><br/><br/>';
            
            strHtmlBody += '<table style="border:none; width:624px; border-collapse: collapse;"><tbody><tr><td style="border-top:2px solid #000; padding-bottom:15px;"></td></tr><tr><td><p style="margin:0px; color:#000;"><b>Thanks,</b></p></td></tr><tr><td><p style="margin:0px; color:#000;">'+'<b>LEVEL SHIFT</b>'+'</p></td></tr><tr><td><table><tbody><tr><td valign="top" width="283" style="width:285px; margin:0; padding:25px;vertical-align:top; background-color:#07080A;"><a href="https://www.levelshift.com/" target="_blank"><img src="https://www.levelshift.com/image-assets/signature/levelshift-logo-signature.jpg" alt="Levelshift" width="285" style="border:none;width:285px;display:block; margin:25px 0;"></a></td><td width="5" style="width:5px;min-width:5px;max-width:5px;margin:0;padding:0;">&nbsp;</td><td style="background-color:#4fc9f3; padding:26px; width:276px;"><table><tbody><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Name</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+'Invoice Team'+'</span></p></td></tr></tbody></table></td></tr><tr><td><p style="border-bottom:1px solid #FFF; width:267px; margin:5px 0;"></p></td></tr><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Email</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+System.Label.ODS_InvoiceTeam+'</span></p></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td style="border-bottom:2px solid #4fc9f3; padding-top:15px;"></td></tr><tr><td width="624" valign="top" style="width:283px;border:none;padding:10px 0"><p style="text-align:justify;"><span style="font-size:11px; font-family:calibri; color:#ff0000; font-weight: bold;">CONFIDENTIALITY STATEMENT:</span><span style="font-size:11px; font-family:Arial, Sans-Serif, Times New Roman; color:#a6a6a6;">The information contained in this communication is confidential and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p></td></tr></tbody></table>';
          
            mail.setHtmlBody(strHtmlBody);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {invAtt});
            lEmailsToSend.add(mail);
            
        }
        }//End of IF list not empty
           
        if(!lEmailsToSend.isEmpty()) {
            //Send email
            system.debug('@@Number of emails'+lEmailsToSend.size());
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(lEmailsToSend);
            
            Set<Id> sAccServIds = new Set<Id>();            
            List<Invoice_Logger__c> lSubscLog = new List<Invoice_Logger__c>();
            List<Invoice__c> lInvRec = new List<Invoice__c>();            
            
            for(Account_Services__c acLog:lAccServ) {
                //Update Account Services for sent invoice - future call                
                sAccServIds.add(acLog.Id);
                
                //Upload the sent invoice to Invoice__c object
                Invoice__c inv = new Invoice__c();
                inv.Account_Services__c = acLog.Id;
                Date StartDate = acLog.Contract_Start_Date__c; 
                String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy'); 
                String formatFromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM-dd-yyyy');              
                Date EndDate = acLog.Contract_End_Date__c;
                String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
                String formatToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM-dd-yyyy');
                String constructMth = '';
                if(System.today().month() < 10) constructMth = '0'+String.valueOf(System.today().month());
                else constructMth = String.valueOf(System.today().month());
                Integer invCntLog = 0;
                if(acLog.Account__r.ODS_Invoice_Count__c != null) invCntLog = Integer.valueOf(acLog.Account__r.ODS_Invoice_Count__c);
                else invCntLog = (System.today().day()-1);
                String invCntLogPrint = invCntLog<10 ? '0'+String.valueOf(invCntLog+1) : String.valueOf(invCntLog+1);
                String invNumber = String.valueOf(System.today().year())+constructMth+invCntLogPrint+String.valueOf(acLog.Account__r.ODS_Invoice_Account_Number__c);
                inv.Attachment_File__c='Invoice'+invNumber+'.pdf';
                inv.Comments__c = 'Invoice File - '+String.valueOf(System.Today());
                //Custom setting to get month name             
                inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
                inv.Year__c = System.today().year();
                lInvRec.add(inv);                                               
                
                //Logging the activity into custom object
                Invoice_Logger__c log = new Invoice_Logger__c();
                log.Account__c = acLog.Account__c;
                log.Account_Services__c = acLog.Id;
                log.Invoice_Sent_DateTime__c = System.now();
                log.SOW_Status__c = acLog.Account__r.SOW__c;
                log.Invoice_Number__c = invNumber;
                log.Log_Type__c = 'Upfront Subscription Invoice';
                lSubscLog.add(log);
            }
            
            if(!lInvRec.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(lInvRec, false);
                Set<Id> sInvId = new Set<Id>();
                List<Attachment> lAttFiles = new List<Attachment>();
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted invoice. ID: ' + sr.getId());
                        sInvId.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred. '+err.getStatusCode()
                                                + ': ' + err.getMessage()+' on: '+ err.getFields());                            
                        }
                    }
                }
                //Linking Invoice with Attachment
                if(!sInvId.isEmpty()) {
                    for(Invoice__c inv :[SELECT Id,Account_Services__c,Attachment_File__c FROM Invoice__c WHERE Id IN:sInvId]) {
                        //Insert Attachment with invoice record as parent id               
                        Attachment att = new Attachment();
                        att.Body = mAccServAtt.get(inv.Account_Services__c);
                        att.Name = inv.Attachment_File__c ;
                        att.ParentId = inv.Id;
                        lAttFiles.add(att); 
                    }
                    Set<Id> sAttId = new Set<Id>();
                    if(!lAttFiles.isEmpty()) {
                        Database.SaveResult[] attList = Database.insert(lAttFiles, false);
                        for (Database.SaveResult ar : attList) {
                            if (ar.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted invoice. ID: ' + ar.getId());
                                sAttId.add(ar.getId());
                            }
                            else {
                                // Operation failed, so get all errors                
                                for(Database.Error er : ar.getErrors()) {
                                    System.debug('The following error has occurred. '+er.getStatusCode()
                                                        + ': ' + er.getMessage()+' on: '+ er.getFields());                            
                                }
                            }
                        }
                        List<Invoice__c> lInvToLink = new List<Invoice__c>();
                        for(Attachment at:[SELECT Id,ParentId FROM Attachment WHERE Id IN:sAttId]) {
                            Invoice__c invc = new Invoice__c(Id=at.ParentId,Attachment_Id__c=at.Id);
                            lInvToLink.add(invc);
                        }
                        
                        //Update linked invoice
                        if(!lInvToLink.isEmpty()) {
                            update lInvToLink;
                        }
                    }
                }
                
            }
            
            if(!sAccServIds.isEmpty()) {
                //UPDATE - this method is depreciated to avoid recursive future calls
                //Calling future method to update the record which is being processed by trigger - to avoid record lock
                //updAccServAftMail(sAccServIds);
            }
            
            if(!lSubscLog.isEmpty()) {
                insert lSubscLog;
                /*//Deleting logs an year older - dynamically saving data space - consider SOQL limit and uncomment this                
                DateTime prevYr = System.now().addYears(-1);
                List<Invoice_Logger__c> lSubscLogToPurge = new List<Invoice_Logger__c>([SELECT Id 
                                    FROM Invoice_Logger__c
                                    WHERE CreatedDate = :prevYr]);
                if(!lSubscLogToPurge.isEmpty()) {
                    delete lSubscLogToPurge;
                }*/
            }
        }
        ODS_FiredFromBatchClass.resetFiredFromBatch();                                                    
    } //end of constructInvoice() method
    
    //Capture the invoice sent date
    private static void updAccServAftMail(Set<Id> sAccUpdIds) {
        /*List<Account_Services__c> lAsv = new List<Account_Services__c>([SELECT Id,
                                                Invoice_Sent_Date__c,Invoice_Sent__c 
                                                FROM Account_Services__c
                                                WHERE Id IN:sAccServIds]);*/
        List<Account_Services__c> lAsvToUpd = new List<Account_Services__c>();                                            
        //for(Account_Services__c asv:lAsv) {
        for(Id sId:sAccUpdIds) {
            Account_Services__c asv = new Account_Services__c();
            asv.Id = sId;
            asv.Invoice_Sent_Date__c = System.today();
            asv.Invoice_Sent__c = true;            
            lAsvToUpd.add(asv);
        }
        
        if(!lAsvToUpd.isEmpty()) {                                                
            update lAsvToUpd;
        }
    }
}