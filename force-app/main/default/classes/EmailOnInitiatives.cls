/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       EmailOnInitiatives
* @description      This class is called from process builder(Initiatives nearing Completion Email)
*********************************************************************************************
Version     Date            Team            Comments
*********************************************************************************************
* 1         29-DEC-2020     DemandBlue      Initial Development
*********************************************************************************************/
global class EmailOnInitiatives {
    /* This method will fire from process builder(Initiatives nearing Completion Email). */
    @InvocableMethod
    public static void SendInitiativeEmail(List<string> InitiativeId)
    {
        try{ 
            if(InitiativeId.size() > 0){                         
                List<Messaging.singleEmailMessage> emailList = new List<Messaging.singleEmailMessage>();
                List<Initiatives__C> initiativesToSendEmail = new List<Initiatives__C>();
                initiativesToSendEmail = [SELECT Id,Name,Account_Name__c,Account_Service__c,Estimated_hours__c,Submitted_Hours__c,
                                          Initiatives_Completion__c,Account_Service__r.Technical_Account_manager__r.Name,
                                          Account_Service__r.Technical_Account_manager__r.Email,Account_Service__r.Backup_CSM__r.Email,
                                          Account_Service__r.Account__r.Industry,JIRA_ID__c,Offshore_Estimate__c,Probable_Start_Date__c,
                                          Probable_End_Date__c,UAT_Expected_Date__c,Account_Service__r.Account__c,Account_Service__r.ODS_Services__c
                                          FROM Initiatives__C WHERE Id IN: InitiativeId];
                
                /*To get the Selva Pandian email*/
                String cSSFromEmailName = System.Label.CSS_FromEmailName; 
                if(String.IsBlank(cSSFromEmailName)){
                    ODS_ExceptionUtility.saveErrorLogs('', 'Custom Label CSS_FromEmailName should not be Empty.', 'Class.EmailOnInitiatives.SendInitiativeEmail: line 31, column 1', 'System.NullPointerException');
                    return;
                }
                List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
                owea = [select Id,DisplayName,address from OrgWideEmailAddress where DisplayName =: System.Label.CSS_FromEmailName];
                if(owea.size() <= 0){
                    ODS_ExceptionUtility.saveErrorLogs('', 'DisplayName ' + System.Label.CSS_FromEmailName + ' not available in OrgWideEmailAddress.', 'Class.EmailOnInitiatives.SendInitiativeEmail: line 37, column 1', 'System.NullPointerException');
                    return;
                }
                ODS_Industry_Mapping__mdt[] ODSIndustryEmails = [Select MasterLabel, IndustryName__c, CSS_Industry_Email__c from ODS_Industry_Mapping__mdt];
                for(Initiatives__C initiative : initiativesToSendEmail){
                    /* We maintain targeted CSS_TO email recepients in custom label(If multiple with comma seperated) */
                    List<String> lstToAddress = new List<String>();
                    List<String> lstCcAddress = new List<String>(); 
                    String split_emailswithcomma = System.Label.CSS_TO;
                    if(String.IsNotBlank(split_emailswithcomma)){
                        List<String> splitted_emails = split_emailswithcomma.split(',');                                        
                        if(splitted_emails.size() > 0){
                            lstToAddress.addAll(splitted_emails);                            
                        }
                        else{ 
                            lstToAddress.add(split_emailswithcomma); 
                        }
                    }                
                    if(initiative.Account_Service__r.Technical_Account_manager__r.Email != null){
                        lstToAddress.add(initiative.Account_Service__r.Technical_Account_manager__r.Email);
                    }
                    if(initiative.Account_Service__r.Backup_CSM__c != null && initiative.Account_Service__r.Backup_CSM__r.Email != null){
                        lstToAddress.add(initiative.Account_Service__r.Backup_CSM__r.Email);
                    }
                    if(String.IsNotBlank(System.Label.CSS_CC)){
                        lstCcAddress.add(System.Label.CSS_CC);
                    }
                    for(ODS_Industry_Mapping__mdt record:ODSIndustryEmails) {
                        if(initiative.Account_Service__r.Account__r.Industry != null && initiative.Account_Service__r.Account__r.Industry == record.IndustryName__c){
                            if(String.IsNotBlank(record.CSS_Industry_Email__c)){
                                List<String> Industryemails = record.CSS_Industry_Email__c.split(',');                                        
                                if(Industryemails.size() > 0){
                                    lstCcAddress.addAll(Industryemails);                                    
                                }
                                else{ 
                                    lstCcAddress.add(record.CSS_Industry_Email__c); 
                                }
                            } 
                        }
                    }
                    
                    Decimal submittedHours = initiative.Submitted_Hours__c != null ?initiative.Submitted_Hours__c: 0.00;                    
                    Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
                    mail.setToAddresses(lstToAddress);
                    mail.setCcAddresses(lstCcAddress);
                    mail.setOrgWideEmailAddressId(owea[0].ID);
                    mail.setSubject('Customer Success Story to be initiated for initiative - '+ initiative.Name);
                    String strHtmlBody = '<font face="Calibri " size="3"> ' + string.format(Label.CSS_GreetingToNames, new List<String>{initiative.Account_Service__r.Technical_Account_manager__r.Name});          
                    strHtmlBody += ' <br/><br/>The initiative <strong>' + initiative.Name + '</strong> is nearing completion as ' + submittedHours.setscale(2);
                    strHtmlBody += ' of ' + initiative.Estimated_hours__c + ' hours have been consumed. Please start working on the CSS for the initiative.';
                    
                    strHtmlBody += ' The initiative details are given below: <br/>';
                    strHtmlBody += '<br/>Account Name: ' + initiative.Account_Name__c;
                    strHtmlBody += '<br/>Initiative Name: ' + initiative.Name;
                    strHtmlBody += '<br/>JIRA Id: ' + initiative.JIRA_ID__c;
                    strHtmlBody += '<br/>Delivery Estimate: ' + initiative.Offshore_Estimate__c;
                    if(initiative.Probable_Start_Date__c != null){
                        strHtmlBody += '<br/>Start Date: ' + (initiative.Probable_Start_Date__c).format();
                    }
                    if(initiative.Probable_End_Date__c != null){
                        strHtmlBody += '<br/>End Date: ' + (initiative.Probable_End_Date__c).format();
                    }
                    if(initiative.UAT_Expected_Date__c != null){
                        strHtmlBody += '<br/>UAT Expected Date: '+ (initiative.UAT_Expected_Date__c).format();
                    }
                    strHtmlBody += '<br/>Initiative URL: <a href="'+Label.ODS_SiteURL+'/apex/InitiativePage?AccServiceId='+initiative.Account_Service__c+ '&CurrenInitiativeId=' + initiative.id +'&emlsrc=cseinitiative&emlrf_ServiceName='+initiative.Account_Service__r.ODS_Services__c+'&emlrf_AcccountId='+initiative.Account_Service__r.Account__c+'">'+initiative.Name + '</a>';
                    strHtmlBody += '<br/><br/>Thanks, <br/> Selva <br/><br/></font>';
                    mail.setHtmlBody(strHtmlBody);                           
                    emailList.add(mail);                
                }                 
                if(!emailList.isEmpty()){                                          
                    Messaging.sendEmail(emailList);
                }
            }            
        } 
        catch(Exception e){
            system.debug('Error occured on sending Initiative Email::: '+ e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(e.getCause()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        } 
    }
}