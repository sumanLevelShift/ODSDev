/*
*Author: Mani & Team
*Crated: 17/May/2018
*TestClass: ODS_Invoice_TimShet_MonthlyBatch_Test 
*/
global class ODS_Invoice_TimShet_MonthlyBatch implements Database.Batchable<sObject>
{
    global final String qry;
    
    global ODS_Invoice_TimShet_MonthlyBatch(String q) {
        qry = q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(qry);
    }
    
    global void execute(Database.BatchableContext BC, List<Account_Services__c> lAccServ) {
    
        List<Messaging.SingleEmailMessage> lEmailsToSend = new List<Messaging.SingleEmailMessage>();
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        Map<Id,Blob> mAccServAtt = new Map<Id,Blob>();
        Set<Id> sStartAccServIds = new Set<Id>();
        Set<Id> sEndAccServIds = new Set<Id>();
        Set<Id> sPrevEndAccServIds = new Set<Id>(); 
        Set<Id> sTimShetToCalc = new Set<Id>(); 
        List<Account_Services__c> lEmailAccServ = new List<Account_Services__c>();
        List<Timesheet__c> lTimShet = new List<Timesheet__c>();
        
        //Invoice team OWD
        Id owdId = null;
        for(OrgWideEmailAddress owa : ODS_EmailUtils.getInvoiceTeamEmail()) {   
            if(String.isNotBlank(owa.Address)) {
                owdId = owa.id;
            }
        }   
        
        //Add practice head email into cc address
        for(User u: ODS_EmailUtils.getPracticeHeadEmail()) {
            //Label to check whether ccing actual practice head allowed
            if(Boolean.valueOf(System.Label.ODS_Invoice_CcPracticeHead))
                ccAddress.add(u.Email);
            else 
                ccAddress.add(System.label.ODS_InvoiceTestEmail);
        }
        
        //Identifying timesheet that needs to be processed for current month
        Date firstDay = System.Today().toStartOfMonth();        
        Integer numOfDays = Date.daysInMonth(System.Today().year(),System.Today().month());        
        Date lastDay = Date.newInstance(System.Today().year(),System.Today().month(),numOfDays);
        //If timesheet filled later, considering the previous month to calculate invoice
        Date prevMnthFirstDay = System.Today().addMonths(-1).toStartOfMonth();
        Integer prevMnthNumOfDays = Date.daysInMonth(prevMnthFirstDay.year(),prevMnthFirstDay.month());
        Date prevMnthLastDay = Date.newInstance(prevMnthFirstDay.year(),prevMnthFirstDay.month(),prevMnthNumOfDays);
        Boolean isPreviousMnth = false;
        
        if(!lAccServ.isEmpty()) {
            //To avoid EZRE_ContactActivityDateUpdate trigger error
            ODS_FiredFromBatchClass.setFiredFromBatch();
            Set<Id> sProcessAccServ = new Set<Id>();
            //Check and run monthly batches once for a month
            for(Account_Services__c ac:lAccServ) {
                if((ac.Invoice_MnthTimSheet_Date__c == null || ac.Invoice_MnthTimSheet_Date__c.month() < System.Today().month()) 
                    && (ac.Invoice_MnthTimSheet_Date__c == null || ac.Invoice_MnthTimSheet_Date__c < ac.Contract_End_Date__c)) {
                    sProcessAccServ.add(ac.Id);
                }
            }
            //Query timehseets to check current or previous month timesheet cost added
            if(!sProcessAccServ.isEmpty()) {
                lTimShet = [SELECT Id,Week_Start_Date__c,Week_End_Date__c,Account_Services__c,Status__c,
                    Time_Sheet_Cost__r.End_Date_of_Month__c,Time_Sheet_Cost__r.Start_Date_of_Month__c 
                    FROM Timesheet__c 
                    WHERE Account_Services__c IN:sProcessAccServ AND (Status__c = 'Submitted' OR Status__c = 'Approved')
                    ORDER BY Account_Services__c ASC,Week_Start_Date__c ASC];
            }                    
        }
        if(!lTimShet.isEmpty()) {
            System.debug('@@timesheet records to process'+lTimShet);
            //Check for month Start & End date and get the Account service id to fetch all timehseets related to it
            for(Timesheet__c ts:lTimShet) {
                if(ts.Time_Sheet_Cost__r.Start_Date_of_Month__c == firstDay  && ts.Time_Sheet_Cost__r.End_Date_of_Month__c == lastDay) {
                    sEndAccServIds.add(ts.Account_Services__c);
                    isPreviousMnth = false;
                }else if(ts.Time_Sheet_Cost__r.Start_Date_of_Month__c == prevMnthFirstDay && ts.Time_Sheet_Cost__r.End_Date_of_Month__c == prevMnthLastDay) {
                    isPreviousMnth = true;
                    //sEndAccServIds.add(ts.Account_Services__c);
                    sPrevEndAccServIds.add(ts.Account_Services__c); 
                }
            }

            //Identifying individual timesheet records having start and end of month
            if(!sEndAccServIds.isEmpty() || !sPrevEndAccServIds.isEmpty()) {
                for(Timesheet__c ts:lTimShet) {
                    if(sEndAccServIds.contains(ts.Account_Services__c) || sPrevEndAccServIds.contains(ts.Account_Services__c)) {
                        sTimShetToCalc.add(ts.Id);
                    }
                }
            }
        }

        //Build a Map to create pdf files
        List<Timesheet__c> lTimShetToCalc = new List<Timesheet__c>();
        Map<Id, List<Timesheet__c>> mAccServTimShetLst = new Map<Id, List<Timesheet__c>>();
        Map<Id,String> mAccServTimShetStr = new Map<Id,String>();
        String tsIds = '';
        
        if(!sEndAccServIds.isEmpty() && !lTimShet.isEmpty() && !sTimShetToCalc.isEmpty()) {
            System.debug('@@Unique Account service records to process'+sEndAccServIds);
            for(Id acs:sEndAccServIds) {
                for(Timesheet__c ts:lTimShet) {
                    if(acs == ts.Account_Services__c && sTimShetToCalc.contains(ts.Id)) {
                        lTimShetToCalc.add(ts);
                        tsIds = tsIds + ts.Id + '-';
                    }
                }
                mAccServTimShetLst.put(acs,lTimShetToCalc);
                mAccServTimShetStr.put(acs,tsIds);
                //Reinitialize for next iteration
                tsIds = '';
                lTimShetToCalc.clear();
            }            
        }
        //Previous month calc
        if(!sPrevEndAccServIds.isEmpty() && !lTimShet.isEmpty() && !sTimShetToCalc.isEmpty()) {            
            for(Id acs:sPrevEndAccServIds) {
                for(Timesheet__c ts:lTimShet) {
                    if(acs == ts.Account_Services__c && sTimShetToCalc.contains(ts.Id)) {
                        lTimShetToCalc.add(ts);
                        tsIds = tsIds + ts.Id + '-';
                    }
                }
                mAccServTimShetLst.put(acs,lTimShetToCalc);
                mAccServTimShetStr.put(acs,tsIds);
                //Reinitialize for next iteration
                tsIds = '';
                lTimShetToCalc.clear();
            }
            System.debug('@@Map of Account service to List of timesheet records'+mAccServTimShetLst);
        }
        
        if(!sEndAccServIds.isEmpty() || !sPrevEndAccServIds.isEmpty()) {
            System.debug('@@Account service records to process'+sEndAccServIds+'previous month:'+sPrevEndAccServIds);
            //Account Services to construct SingleEmailMessage
            for(Account_Services__c acs:lAccServ) {
                if(sEndAccServIds.contains(acs.Id) || sPrevEndAccServIds.contains(acs.Id)) {
                    lEmailAccServ.add(acs);
                }
            } 
        }
        
        if(!lEmailAccServ.isEmpty()) {   
              
            for(Account_Services__c ac:lEmailAccServ) {
                if((ac.Invoice_MnthTimSheet_Date__c == null) || ((ac.Invoice_MnthTimSheet_Date__c < ac.Contract_End_Date__c)
                    && ac.Invoice_MnthTimSheet_Date__c.month() != system.today().month())) {
                    Date StartDate;
                    if(!sPrevEndAccServIds.isEmpty() && sPrevEndAccServIds.contains(ac.Id)) StartDate = prevMnthFirstDay; 
                    else StartDate = firstDay;
                    String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');       
            
                    Date EndDate;
                    if(!sPrevEndAccServIds.isEmpty() && sPrevEndAccServIds.contains(ac.Id)) EndDate = prevMnthLastDay;
                    else EndDate = lastDay;
                    String ToDate= DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');

                    //generate email with the details
                    PageReference pdf = Page.ODS_Invoice_mnthExportTimesheet;                            
                    pdf.getParameters().put('accServ',ac.Id);
                    pdf.getParameters().put('accName',ac.Account__r.Name);
                    pdf.getParameters().put('odsServName',ac.ODS_Service_Name__c);
                    pdf.getParameters().put('startDate',String.valueOf(StartDate));
                    pdf.getParameters().put('endDate',String.valueOf(EndDate));
                    pdf.getParameters().put('timeSheets',mAccServTimShetStr.get(ac.Id));
                    
                    // the contents of the attachment from the pdf
                    Blob body;
                    
                    try {        
                        // returns the output of the page as a PDF
                        body = pdf.getContentAsPdf();
                        System.debug('@@@@@@@@@body ------------'+body ); 
                    } catch (VisualforceException e) {
                        body = Blob.valueOf('Weekly Timesheet');
                    }
                    
                    //Generate invoice pdf        
                    PageReference invPdf = Page.ODS_Invoice_MnthTimeSheetFormat;
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
                    invPdf.getParameters().put('timShtId',mAccServTimShetStr.get(ac.Id));
                    invPdf.getParameters().put('hrlyRate',String.valueOf(ac.ODS_Hourly_Rate_Amount__c));
                    invPdf.getParameters().put('discFee','');
                    invPdf.getParameters().put('startDt',String.valueOf(StartDate));
                    invPdf.getParameters().put('endDt',String.valueOf(EndDate));
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
                    
                    Messaging.EmailFileAttachment attachement = new Messaging.EmailFileAttachment();
                    attachement.setContentType('appliction/pdf');
                    attachement.setFileName('Timesheet - '+ac.Account__r.name+ ' - '+ac.ODS_Service_Name__c+ ' from ' +StartDate.format()+ ' to ' +EndDate.format()+'.pdf');
                    attachement.setInline(false);
                    pdf.setRedirect(true);
                    attachement.Body = body;
                                                
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
                    
                    String subject = 'Levelshift Invoice for '+ac.ODS_Service_Name__c+' on Demand Service'+' from ' + StartDate.format() 
                    + ' to ' + endDate.format();
                    mail.setSubject(subject);
            
                    String strHtmlBody = '' ;        
                    strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3"><b>Hi '+ac.Account__r.InvoiceContact__r.Name+',</b>'+' <br/><br/><b>Please find the attached Invoice for \''+ac.ODS_Service_Name__c+' On Demand Services for the period '+StartDate.format()+ ' through ' +endDate.format()
                        + '.<br/><br/>'+'Please confirm the receipt and reach us if you have any questions!</b><br/><br/>';
                    
                    strHtmlBody += '<table style="border:none; width:624px; border-collapse: collapse;"><tbody><tr><td style="border-top:2px solid #000; padding-bottom:15px;"></td></tr><tr><td><p style="margin:0px; color:#000;"><b>Thanks,</b></p></td></tr><tr><td><p style="margin:0px; color:#000;">'+'<b>LEVEL SHIFT</b>'+'</p></td></tr><tr><td><table><tbody><tr><td valign="top" width="283" style="width:285px; margin:0; padding:25px;vertical-align:top; background-color:#07080A;"><a href="https://www.levelshift.com/" target="_blank"><img src="https://www.levelshift.com/image-assets/signature/levelshift-logo-signature.jpg" alt="Levelshift" width="285" style="border:none;width:285px;display:block; margin:25px 0;"></a></td><td width="5" style="width:5px;min-width:5px;max-width:5px;margin:0;padding:0;">&nbsp;</td><td style="background-color:#4fc9f3; padding:26px; width:276px;"><table><tbody><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Name</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+'Invoice Team'+'</span></p></td></tr></tbody></table></td></tr><tr><td><p style="border-bottom:1px solid #FFF; width:267px; margin:5px 0;"></p></td></tr><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">Email</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:11px; font-family:Arial,sans-serif; color:#000;">'+System.Label.ODS_InvoiceTeam+'</span></p></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td style="border-bottom:2px solid #4fc9f3; padding-top:15px;"></td></tr><tr><td width="624" valign="top" style="width:283px;border:none;padding:10px 0"><p style="text-align:justify;"><span style="font-size:11px; font-family:calibri; color:#ff0000; font-weight: bold;">CONFIDENTIALITY STATEMENT:</span><span style="font-size:11px; font-family:Arial, Sans-Serif, Times New Roman; color:#a6a6a6;">The information contained in this communication is confidential and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p></td></tr></tbody></table>';
                  
                    mail.setHtmlBody(strHtmlBody);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachement,invAtt});
                    lEmailsToSend.add(mail);
                }
            }
        }  
        if(!lEmailsToSend.isEmpty()) {
            //Send email
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(lEmailsToSend);
            
            List<Account_Services__c> lAccServLog = new List<Account_Services__c>();            
            List<Invoice_Logger__c> lSubscLog = new List<Invoice_Logger__c>();
            List<Invoice__c> lInvRec = new List<Invoice__c>();            
            
            for(Account_Services__c acLog:lEmailAccServ) {
                //Update Account Services for sent invoice
                acLog.Invoice_MnthTimSheet_Date__c = System.today();
                acLog.Invoice_MnthTimShet_Sent__c = true;
                lAccServLog.add(acLog);                
                
                //Upload the sent invoice to Invoice__c object
                Invoice__c inv = new Invoice__c();
                inv.Account_Services__c = acLog.Id;
                Date StartDate = acLog.Contract_Start_Date__c; 
                String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');               
                Date EndDate = acLog.Contract_End_Date__c;
                String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
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
                log.Log_Type__c = 'Monthly Timesheet Invoice';
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
            
            if(!lAccServLog.isEmpty()) {                
                update lAccServLog;
            }
            
            if(!lSubscLog.isEmpty()) {
                insert lSubscLog;
                /*//Deleting logs an year older - dynamically saving data space - consider SOQL limit and uncomment this                
                DateTime prevYr = System.now().addYears(-1);
                List<Invoice_Logger__c> lSubscLogToPurge = new List<Subscription_Invoice_Logger__c>([SELECT Id 
                                    FROM Invoice_Logger__c
                                    WHERE CreatedDate = :prevYr]);
                if(!lSubscLogToPurge.isEmpty()) {
                    delete lSubscLogToPurge;
                }*/
            }
        }
                
    }
    
    global void finish(Database.BatchableContext BC) {
        ODS_FiredFromBatchClass.resetFiredFromBatch();
        //Do nothing
    }
}