public class ODS_Invoice_MonthlyQ1 implements Queueable,Database.AllowsCallouts {
    Set<Id> sAsv;
    
    public ODS_Invoice_MonthlyQ1(Set<Id> records) {
        this.sAsv = records;
    }
    
    public void execute(QueueableContext context) {
        
        //Query to get Relationship fields since trigger context does not allow it
        List<Account_Services__c> lAccServ = new List<Account_Services__c>([SELECT Id,Account__c,Account__r.Name,Account__r.SOW__c,
                        Account__r.Primary_Customer_Email_OptOut__c,Account__r.SOW_Start_Date__c,
                        Account__r.Primary_Customer_Email_Id__c,Account__r.BillingStreet,
                        Account__r.BillingCity,Account__r.BillingState,Account__r.BillingCountry,Account__r.BillingPostalCode,
                        Account__r.Invoice_Type__c,Account__r.ODS_Invoice_Contact_Email__c,Account__r.InvoiceContact__c,
                        Retainer_Fee_Frequency_Type__c,Retainer_Fee_Amount__c,Invoice_Monthly_Subscription_Discount__c,
                        Subscription_Fee_Discount__c,Contract_Start_Date__c,Purchase_Order__c,
                        Contract_End_Date__c,Invoice_MnthSubs_Date__c,Invoice_Sent__c,
                        Contract_Term__c,Account__r.SOW_Status_Date__c,ODS_Service_Name__c,
                        Account__r.ODS_Invoice_Account_Number__c,Account__r.ODS_Invoice_Count__c
                    FROM Account_Services__c 
                    WHERE Account__r.SOW__c = 'Fully Executed' AND Do_not_send_invoice__c = false AND  
                        Contract_End_Date__c != null AND Retainer_Fee_Frequency_Type__c = 'Monthly' AND  
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
            //To avoid test class failures - control given on custom label
            if(Boolean.valueOf(System.Label.ODS_Invoice_TestClassControl)) {
                //Custom setting to check whether ccing actual practice head allowed            
                if(Boolean.valueOf(System.Label.ODS_Invoice_CcPracticeHead))
                    ccAddress.add(u.Email);
                else
                    ccAddress.add(System.label.ODS_InvoiceTestEmail);
            }else {
                ccAddress.add(System.label.ODS_InvoiceTestEmail);
            }
        }
        
        for(Account_Services__c ac:lAccServ) {
            //Checking SOW signed date to send the email on the same day of every month
            if((ac.Invoice_MnthSubs_Date__c == null || ac.Invoice_MnthSubs_Date__c.month() < System.Today().month()) 
                && (ac.Invoice_MnthSubs_Date__c == null || ac.Invoice_MnthSubs_Date__c < ac.Contract_End_Date__c)) {
                                 
                //Consecutive month invoices after trial disabled
                Date StartDate = Date.newInstance(System.today().year(),System.today().month(),ac.Contract_Start_Date__c.day());
                //Date StartDate = ac.Invoice_MnthSubs_Date__c == null ? ac.Account__r.SOW_Start_Date__c : System.Today().toStartOfMonth(); 
                String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');       
                Integer numOfDays = Date.daysInMonth(StartDate.year(),StartDate.month());
                
                //Date CalcEndDate = Date.newInstance(StartDate.year(),StartDate.month(),numOfDays);
                Date CalcEndDate = Date.valueOf(StartDate.addDays(numOfDays));
                Date EndDate = (CalcEndDate > ac.Contract_End_Date__c) ? ac.Contract_End_Date__c : CalcEndDate;
                String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
                
                PageReference invPdf = Page.ODS_Invoice_SubsMonthlyFormat;
                invPdf.getParameters().put('term',ac.Contract_Term__c);
                invPdf.getParameters().put('billToStr',String.valueOf(ac.Account__r.BillingStreet));
                invPdf.getParameters().put('billToCty',String.valueOf(ac.Account__r.BillingCity));
                invPdf.getParameters().put('billToStat',String.valueOf(ac.Account__r.BillingState));
                invPdf.getParameters().put('billToCtry',String.valueOf(ac.Account__r.BillingCountry));
                invPdf.getParameters().put('billToPcod',String.valueOf(ac.Account__r.BillingPostalcode));
                String constructMth = '';
                if(StartDate.month() < 10) constructMth = '0'+String.valueOf(StartDate.month());
                else constructMth = String.valueOf(StartDate.month());
                Integer invCnt = 0;
                if(ac.Account__r.ODS_Invoice_Count__c != null) invCnt = Integer.valueOf(ac.Account__r.ODS_Invoice_Count__c);
                else invCnt = (System.today().day()-1);
                String invCntPrint = invCnt<10 ? '0'+String.valueOf(invCnt+1) : String.valueOf(invCnt+1);
                String invNumber = String.valueOf(StartDate.year())+constructMth+invCntPrint+String.valueOf(ac.Account__r.ODS_Invoice_Account_Number__c);
                invPdf.getParameters().put('invNumb',invNumber);
                invPdf.getParameters().put('accNumb',String.valueOf(ac.Account__r.ODS_Invoice_Account_Number__c));
                invPdf.getParameters().put('billPerd',FromDate+' - '+ToDate);      
                invPdf.getParameters().put('AccServId',ac.Id);
                invPdf.getParameters().put('mnths','1');
                invPdf.getParameters().put('hrlyRate',String.valueOf(ac.Retainer_Fee_Amount__c));
                invPdf.getParameters().put('discFee',String.valueOf(ac.Invoice_Monthly_Subscription_Discount__c));
                invPdf.getParameters().put('startDt',String.valueOf(StartDate));
                invPdf.getParameters().put('endDt',String.valueOf(EndDate));
                invPdf.getParameters().put('subsType','monthly');
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
                    if(ac.Account__r.Invoice_Type__c == 'Paper') { //Using existing field on account to check email option for customer
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
                
                String subject = 'LevelShift Invoice for '+ac.ODS_Service_Name__c+' ODS (Monthly Subscription Fee)'+' from ' + FromDate
                + ' to ' +ToDate;
                mail.setSubject(subject);
        
                String strHtmlBody = '' ;        
                strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3"><b>Hi,</b>'+' <br/><br/><b>Please find the attached Invoice for \''+ac.ODS_Service_Name__c+' On Demand Services (Monthly Subscription Fee)\' for the period '+FromDate+ ' through ' +ToDate
                    + '.<br/><br/>'+'Please confirm the receipt and reach us if you have any questions!</b><br/><br/>';
                
                strHtmlBody += '<table style="border:none; width:624px; border-collapse: collapse;"><tbody><tr><td style="border-top:2px solid #000; padding-bottom:15px;"></td></tr><tr><td><p style="margin:0px; color:#000;"><b>Thanks,</b></p></td></tr><tr><td><p style="margin:0px; color:#000;">'+'<b>LEVEL SHIFT</b>'+'</p></td></tr><tr><td><table><tbody><tr><td valign="top" width="283" style="width:285px; margin:0; padding:25px;vertical-align:top; background-color:#07080A;"><a href="https://www.levelshift.com/" target="_blank"><img src="https://www.levelshift.com/image-assets/signature/levelshift-logo-signature.jpg" alt="LevelShift" width="285" style="border:none;width:285px;display:block; margin:25px 0;"></a></td><td width="5" style="width:5px;min-width:5px;max-width:5px;margin:0;padding:0;">&nbsp;</td><td style="background-color:#4fc9f3; padding:26px; width:276px;"><table><tbody><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Name</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+'Invoice Team'+'</span></p></td></tr></tbody></table></td></tr><tr><td><p style="border-bottom:1px solid #FFF; width:267px; margin:5px 0;"></p></td></tr><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Email</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+System.Label.ODS_InvoiceTeam+'</span></p></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td style="border-bottom:2px solid #4fc9f3; padding-top:15px;"></td></tr><tr><td width="624" valign="top" style="width:283px;border:none;padding:10px 0"><p style="text-align:justify;"><span style="font-size:11px; font-family:calibri; color:#ff0000; font-weight: bold;">CONFIDENTIALITY STATEMENT:</span><span style="font-size:11px; font-family:Arial, Sans-Serif, Times New Roman; color:#a6a6a6;">The information contained in this communication is confidential and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p></td></tr></tbody></table>';
              
                mail.setHtmlBody(strHtmlBody);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {invAtt});
                lEmailsToSend.add(mail);
            }
        
        }        
        }//end of List not null   
        if(!lEmailsToSend.isEmpty()) {
            //Send email
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(lEmailsToSend);
            
            //List<Account_Services__c> lAccServLog = new List<Account_Services__c>();
            Set<Id> sAsvIds = new Set<Id>();            
            List<Invoice_Logger__c> lSubscLog = new List<Invoice_Logger__c>();
            List<Invoice__c> lInvRec = new List<Invoice__c>();            
            
            for(Account_Services__c acLog:lAccServ) {
                //Update Account Services for sent invoice
                //acLog.Invoice_MnthSubs_Date__c = System.today();
                //acLog.Invoice_Sent__c = true;
                //lAccServLog.add(acLog);
                sAsvIds.add(acLog.Id);                
                
                //Upload the sent invoice to Invoice__c object
                Invoice__c inv = new Invoice__c();
                inv.Account_Services__c = acLog.Id;
                //Date StartDate = System.Today().toStartOfMonth();
                Date StartDate = Date.newInstance(System.today().year(),System.today().month(),acLog.Contract_Start_Date__c.day()); 
                String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy'); 
                Integer numOfDays = Date.daysInMonth(StartDate.year(),StartDate.month());              
                //Date EndDate = Date.newInstance(System.Today().year(),System.Today().month(),numOfDays);
                Date CalcEndDate = Date.valueOf(StartDate.addDays(numOfDays));
                Date EndDate = (CalcEndDate > acLog.Contract_End_Date__c) ? acLog.Contract_End_Date__c : CalcEndDate;
                String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
                String constructMth = '';
                if(System.today().month() < 10) constructMth = '0'+String.valueOf(StartDate.month());
                else constructMth = String.valueOf(StartDate.month());
                Integer invCntLog = 0;
                if(acLog.Account__r.ODS_Invoice_Count__c != null) invCntLog = Integer.valueOf(acLog.Account__r.ODS_Invoice_Count__c);
                else invCntLog = (System.today().day()-1);
                String invCntLogPrint = invCntLog<10 ? '0'+String.valueOf(invCntLog+1) : String.valueOf(invCntLog+1);
                String invNumber = String.valueOf(System.today().year())+constructMth+invCntLogPrint+String.valueOf(acLog.Account__r.ODS_Invoice_Account_Number__c);
                inv.Attachment_File__c='Invoice'+invNumber+'.pdf';
                inv.Comments__c = 'Invoice File - '+String.valueOf(System.Today());
                //Custom setting to get month name             
                inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(StartDate.month())).MonthName__c;
                inv.Year__c = StartDate.year();
                lInvRec.add(inv);                                               
                
                //Logging the activity into custom object
                Invoice_Logger__c log = new Invoice_Logger__c();
                log.Account__c = acLog.Account__c;
                log.Account_Services__c = acLog.Id;
                log.Invoice_Sent_DateTime__c = System.now();
                log.SOW_Status__c = acLog.Account__r.SOW__c;
                log.Invoice_Number__c = invNumber;
                log.Log_Type__c = 'Monthly Subscrption Invoice';
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
            
            if(!sAsvIds.isEmpty() && !Test.isRunningTest()) {
                //Second job to update the invoice sent date - chaining is tested with different test class
                System.enqueueJob(new ODS_Invoice_MonthlyQ2(sAsvIds));
            }
        }
        ODS_FiredFromBatchClass.resetFiredFromBatch(); 
    }
}