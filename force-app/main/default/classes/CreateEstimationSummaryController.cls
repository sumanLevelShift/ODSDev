public without sharing class CreateEstimationSummaryController {
    @AuraEnabled( cacheable = false )
    public static void updateApproverUserTrack(string estimationId){
        list<Estimation_Summary__c> estimationSummary=[SELECT Approved_User_Track__c,Id,Status__c FROM Estimation_Summary__c WHERE ID=:estimationId LIMIT 1];
        if(!estimationSummary.isEmpty()){
            Estimation_Summary__c e=new Estimation_Summary__c();
            e.id=estimationSummary[0].id;
            e.Approved_User_Track__c='';
            update e;
        }
    }
    @AuraEnabled( cacheable = false )
    public static boolean getcurrentUserAccessForEstimation(){
        List<User> curUser=[SELECT Delivery_Role__c FROM User Where ( Delivery_Role__c !='' AND Delivery_Role__c !='None')  AND Id=:UserInfo.getUserId()];
        if(!curUser.isEmpty()){
            return true;
        }
        return false;
    }
    @AuraEnabled( cacheable = false )
    public static boolean getcurrentUserPM(string summaryId){
        List<Estimation_Summary__c> summaryList=[SELECT Id,Status__c FROM Estimation_Summary__c where id=:summaryId AND Status__c='Approved' limit 1];
        List<User> curUser=[SELECT Delivery_Role__c FROM User Where Delivery_Role__c includes ('Program Manager') AND Id=:UserInfo.getUserId()];
        if(!curUser.isEmpty() && !summaryList.isEmpty()){
            return true;
        }
        return false;
    }
    @AuraEnabled( cacheable = false )
    public static List<Hierarchy_Lookup__c> getHierarchyLookupList(){
        List<Hierarchy_Lookup__c> hLookupList=[SELECT Id,Full_Name__c FROM Hierarchy_Lookup__c];
        return hLookupList;
    }
    
    @AuraEnabled( cacheable = false )
    public static void updateHours(string summaryId,decimal month,decimal week,decimal day)
    { 
        List<Estimation_Summary__c> summaryList=[SELECT Id,Status__c,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c  FROM Estimation_Summary__c where id=:summaryId limit 1];
        if(!summaryList.isEmpty()){
            summaryList[0].Work_Days_Per_Month__c=month;
            summaryList[0].Work_Days_Per_Week__c=week;
            summaryList[0].Work_Hours_Per_Day__c=day;
            update summaryList;
        }
    }
    
    @AuraEnabled( cacheable = false )
    public static string approveTheEstimation(string summaryId,string userName){
        string status='Not Approved';
        List<Estimation_Summary__c> summaryList=[SELECT Acceptance_Criteria__c,Assumptions__c,Out_of_Scope__c,Scope__c,Project_ID__c,Customer__c,Estimation_Date__c,Program_Manager__r.Full_Name__c,SME_Vertical__r.Full_Name__c,Technical_Project_Manager__r.Full_Name__c,Id,Technical_Project_Manager__c,SME_Vertical__c,Program_Manager__c,Approved_User_Track__c FROM Estimation_Summary__c where id=:summaryId];
        List<Estimation_Summary__c> updateEstimationSummary=new list<Estimation_Summary__c>();
        
        if(!summaryList.isEmpty()){
            if(string.isBlank(summaryList[0].Acceptance_Criteria__c ) || string.isBlank(summaryList[0].Out_of_Scope__c ) ||
               string.isBlank(summaryList[0].Assumptions__c ) || string.isBlank(summaryList[0].Scope__c )){
                   status='Invalid';
                   return 'Invalid';
               }
            string approverName=summaryList[0].Approved_User_Track__c;
            // List<Hierarchy_Lookup__c> hierarchyLookupList=[SELECT Delivery_Role__c,Full_Name__c,Id FROM Hierarchy_Lookup__c Where Full_Name__c=:userName limit 1];
            //  List<User> userList=[SELECT Id, Name,Delivery_Role__c FROM User WHERE Delivery_Role__c =:hierarchyLookupList[0].Delivery_Role__c LIMIT 1];
            //if(!userList.isEmpty()){
            if(string.isNotBlank(approverName)){
                approverName =approverName+' | '+userName+', '+Date.today().format();
            }else{
                approverName =userName+', '+Date.today().format();
            }
            // }
            boolean level1=false;
            boolean level2=false;
            boolean level3=false;
            if(summaryList[0].Technical_Project_Manager__c !=null){
                if(approverName.contains(summaryList[0].Technical_Project_Manager__r.Full_Name__c)){
                    level1=true;  
                }
            }
            if(summaryList[0].SME_Vertical__c !=null){
                if(approverName.contains(summaryList[0].SME_Vertical__r.Full_Name__c)){
                    level2=true;  
                }
            }else{
                level2=true;    
            }
            if(summaryList[0].Program_Manager__c !=null){
                if(approverName.contains(summaryList[0].Program_Manager__r.Full_Name__c)){
                    level3=true;  
                }
            }else{
                level3=true;  
            }
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.id=summaryList[0].id;
            es.Approved_User_Track__c=approverName;
            
            if(level1 && level2 && level3){
                status ='Approved';
                es.Status__c='Approved';
                if(summaryList[0].Estimation_Date__c ==null){
                    es.Estimation_Date__c=system.today();  
                }
                List<Estimation_Summary__c> getOtherInitiativeList=[SELECT id,Status__c,Project_ID__c,Customer__c FROM Estimation_Summary__c 
                                                                    where id !=:summaryId AND Customer__c=:summaryList[0].Customer__c AND Project_ID__c=:summaryList[0].Project_ID__c];
                for(Estimation_Summary__c estSummary:getOtherInitiativeList){
                    Estimation_Summary__c es1=new Estimation_Summary__c();
                    es1.id=estSummary.id;
                    es1.Status__c='Obsolete';
                    updateEstimationSummary.add(es1);
                }
            }
            updateEstimationSummary.add(es);
            if(!updateEstimationSummary.isEmpty()){
                update updateEstimationSummary;
                sendEstimationApproved(summaryId);
            }
        }
        return status;
    }
    @AuraEnabled( cacheable = true )
    Public static void sendEstimationApproved(string estimationId){
        List<Estimation_Summary__c> approvedEstimation=[SELECT Customer__r.Name,Project_ID__c,Customer__c,Customer_Success_Manager__r.Name,id,Project_ID__r.Name,Customer_Success_Manager__r.Email,Customer_Success_Manager__c,Name,Program_Manager__c,SME_Vertical__c,Status__c,Technical_Project_Manager__c,
                                                        Technical_Project_Manager__r.Full_Name__c,SME_Vertical__r.Full_Name__c,Program_Manager__r.Full_Name__c,
                                                        Technical_Project_Manager__r.Email_Address__c ,SME_Vertical__r.Email_Address__c ,Program_Manager__r.Email_Address__c  FROM Estimation_Summary__c 
                                                        WHERE Status__c='Approved' AND ID=:estimationId LIMIT 1];
        if(!approvedEstimation.isEmpty()){
            Account_Services__c accSer=[SELECT Id,Account__c,ODS_Services__c FROM Account_Services__c WHERE Account__c =: approvedEstimation[0].Customer__c LIMIT 1];
            List<string> toAddrress=New List<String>();
            string signName='';
            string signEmail='';
            string signTitle='';
            if(string.isNotBlank(approvedEstimation[0].Customer_Success_Manager__r.Email)){
                toAddrress.add(approvedEstimation[0].Customer_Success_Manager__r.Email);
            }
            List<String> ccAddrress=New List<String>();
            if(string.isNotBlank(approvedEstimation[0].Technical_Project_Manager__r.Email_Address__c)){
                ccAddrress.add(approvedEstimation[0].Technical_Project_Manager__r.Email_Address__c);   
            }
            if(string.isNotBlank(approvedEstimation[0].SME_Vertical__r.Email_Address__c)){
                ccAddrress.add(approvedEstimation[0].SME_Vertical__r.Email_Address__c);
            }
            if(string.isNotBlank(approvedEstimation[0].Program_Manager__r.Email_Address__c)){
                ccAddrress.add(approvedEstimation[0].Program_Manager__r.Email_Address__c);  
                signEmail=approvedEstimation[0].Program_Manager__r.Email_Address__c;
                signName=approvedEstimation[0].Program_Manager__r.Full_Name__c;
                signTitle='PM';
            }else{
                signEmail=approvedEstimation[0].Technical_Project_Manager__r.Email_Address__c;
                signName=approvedEstimation[0].Technical_Project_Manager__r.Full_Name__c; 
                signTitle='TPM';
            }
            system.debug('ccAddrress-'+ccAddrress);
            Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
            if(toAddrress.size() > 0){
                mail.setToAddresses(toAddrress);
            }
            if(ccAddrress.size() > 0){
                mail.setCcAddresses(ccAddrress);
            }
            String subject = 'Estimation For '+approvedEstimation[0].Project_ID__r.Name+' - Available For Review'; 
            mail.setSubject(subject);
            mail.setSenderDisplayName('LevelShift - ODS');
            
            String InitiativeUrl = System.Label.ODS_SiteURL; 
            String URL = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+approvedEstimation[0].Project_ID__c+'&AccServiceId='+accSer.id;
            
            String strHtmlBody = ''; 
            strHtmlBody +=approvedEstimation[0].Status__c;
            strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi '+ approvedEstimation[0].Customer_Success_Manager__r.Name +',';
            strHtmlBody +='<br/><br/>The estimation for '+'<a href='+url+'>'+approvedEstimation[0].Project_ID__r.Name+'</a> is available on the ODS Portal.<br/><br/>';
            strHtmlBody +='Please click '+'<a href="'+Label.ODS_SiteURL+'/apex/DetailsEstimationSummary?estimationId='+approvedEstimation[0].id+'&accountId='+approvedEstimation[0].Customer__c +'&serviceId='+accSer.ODS_Services__c+'">here </a> to view the estimation.<br/><br/>';
            strHtmlBody +='<b>Account Name: </b>'+approvedEstimation[0].Customer__r.Name;
            strHtmlBody +='<br/><br/>Thanks,<br/><br/>'+signName+'<br/>';
            strHtmlBody += '<table style="border:none; width:624px; border-collapse: collapse;"><tbody><tr><td style="border-top:2px solid #000; padding-bottom:15px;"></td></tr><tr><td><table><tbody><tr><td valign="top" width="283" style="width:285px; margin:0; padding:25px;vertical-align:top; background-color:#07080A;"><a href="https://www.levelshift.com/" target="_blank"><img src="'+Label.ODS_Email_Signature_Logo_Url+'" alt="LevelShift" width="285" style="border:none;width:285px;display:block; margin:25px 0;"></a></td><td width="5" style="width:5px;min-width:5px;max-width:5px;margin:0;padding:0;">&nbsp;</td><td style="background-color:#4fc9f3; padding:25px 20px; width:276px;"><table><tbody><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#fff;">'+signTitle+'</span></p></td><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#000;">'+signName+'</span></p></td></tr><tr><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#fff;">Email</span></p></td><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#000;">'+signEmail+'</span></p></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td style="border-bottom:2px solid #4fc9f3; padding-top:15px;"></td></tr><tr><td width="624" valign="top" style="width:283px;border:none;padding:10px 0"><p style="text-align:justify;"><span style="font-size:11px; font-family:calibri; color:#ff0000; font-weight: bold;">CONFIDENTIALITY STATEMENT:</span> <span style="font-size:11px; font-family:Arial, Sans-Serif, Times New Roman; color:#a6a6a6;">The information contained in this communication is confidential and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p></td></tr></tbody></table>';
            mail.setHtmlBody(strHtmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
    }
    @AuraEnabled
    Public static void sendEstimationReadyForApproval(string estimationId){
        List<Estimation_Summary__c> approvedEstimation=[SELECT Created_By__c,Created_By__r.Full_Name__c,Created_By__r.Email_Address__c,Customer__r.Name,Project_ID__c,Customer__c,Customer_Success_Manager__r.Name,id,Project_ID__r.Name,Customer_Success_Manager__r.Email,Customer_Success_Manager__c,Name,Program_Manager__c,SME_Vertical__c,Status__c,Technical_Project_Manager__c,
                                                        Technical_Project_Manager__r.Full_Name__c,SME_Vertical__r.Full_Name__c,Program_Manager__r.Full_Name__c,
                                                        Technical_Project_Manager__r.Email_Address__c ,SME_Vertical__r.Email_Address__c ,Program_Manager__r.Email_Address__c  FROM Estimation_Summary__c 
                                                        WHERE ID =: estimationId LIMIT 1];
        if(!approvedEstimation.isEmpty()){
            Account_Services__c accSer=[SELECT Id,Account__c,ODS_Services__c FROM Account_Services__c WHERE Account__c =: approvedEstimation[0].Customer__c LIMIT 1];
            List<string> toAddrress=New List<String>();
            List<string> ccAddrress=New List<String>();
            string signName='';
            string signEmail='';
            string sendTo='';
            string signTitle='Developer';
            
            if(string.isNotBlank(approvedEstimation[0].Program_Manager__r.Email_Address__c)){
                ccAddrress.add(approvedEstimation[0].Program_Manager__r.Email_Address__c); 
                //sendTo=approvedEstimation[0].Program_Manager__r.Full_Name__c;
            }
            
            if(string.isNotBlank(approvedEstimation[0].Technical_Project_Manager__r.Email_Address__c)){
                toAddrress.add(approvedEstimation[0].Technical_Project_Manager__r.Email_Address__c);  
                if(String.isBlank(sendTo)){
                    sendTo +=approvedEstimation[0].Technical_Project_Manager__r.Full_Name__c;
                }else{
                    sendTo +=', '+approvedEstimation[0].Technical_Project_Manager__r.Full_Name__c;
                }
            }
            if(string.isNotBlank(approvedEstimation[0].SME_Vertical__r.Email_Address__c)){
                toAddrress.add(approvedEstimation[0].SME_Vertical__r.Email_Address__c);
                if(String.isBlank(sendTo)){
                    sendTo +=approvedEstimation[0].SME_Vertical__r.Full_Name__c;                   
                }else{
                    sendTo +=', '+approvedEstimation[0].SME_Vertical__r.Full_Name__c;  
                }
            }
            if(string.isNotBlank(approvedEstimation[0].Created_By__r.Email_Address__c)){
                signEmail=approvedEstimation[0].Created_By__r.Email_Address__c;
                signName=approvedEstimation[0].Created_By__r.Full_Name__c;   
            }
            Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
            if(toAddrress.size() > 0){
                mail.setToAddresses(toAddrress);
            }
            if(ccAddrress.size() > 0){
                mail.setCcAddresses(ccAddrress);
            }
            String subject = 'Estimation For '+approvedEstimation[0].Project_ID__r.Name+' - Ready for your approval'; 
            mail.setSubject(subject);
            mail.setSenderDisplayName('LevelShift - ODS');
            
            String InitiativeUrl = System.Label.ODS_SiteURL; 
            String URL = InitiativeUrl+'/apex/InitiativePage?CurrenInitiativeId='+approvedEstimation[0].Project_ID__c+'&AccServiceId='+accSer.id;
            
            String strHtmlBody = ''; 
            strHtmlBody +=approvedEstimation[0].Status__c;
            strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi '+ sendTo +',';
            strHtmlBody +='<br/><br/>The estimation for '+'<a href='+url+'>'+approvedEstimation[0].Project_ID__r.Name+'</a> is ready for your approval.<br/><br/>';
            strHtmlBody +='Please click '+'<a href="'+Label.ODS_SiteURL+'/apex/DetailsEstimationSummary?estimationId='+approvedEstimation[0].id+'&accountId='+approvedEstimation[0].Customer__c +'&serviceId='+accSer.ODS_Services__c+'">here </a> to view the estimation.<br/><br/>';
            strHtmlBody +='<b>Account Name: </b>'+approvedEstimation[0].Customer__r.Name;
            strHtmlBody +='<br/><br/>Thanks,<br/><br/>'+signName+'<br/>';
            strHtmlBody += '<table style="border:none; width:624px; border-collapse: collapse;"><tbody><tr><td style="border-top:2px solid #000; padding-bottom:15px;"></td></tr><tr><td><table><tbody><tr><td valign="top" width="283" style="width:285px; margin:0; padding:25px;vertical-align:top; background-color:#07080A;"><a href="https://www.levelshift.com/" target="_blank"><img src="'+Label.ODS_Email_Signature_Logo_Url+'" alt="LevelShift" width="285" style="border:none;width:285px;display:block; margin:25px 0;"></a></td><td width="5" style="width:5px;min-width:5px;max-width:5px;margin:0;padding:0;">&nbsp;</td><td style="background-color:#4fc9f3; padding:25px 20px; width:276px;"><table><tbody><tr><td><table><tbody><tr><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#fff;">'+signTitle+'</span></p></td><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#000;">'+signName+'</span></p></td></tr><tr><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#fff;">Email</span></p></td><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#fff;">:</span></p></td><td><p style="margin:0px;"><span style="font-size:12px; font-family:Arial,sans-serif; color:#000;">'+signEmail+'</span></p></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td style="border-bottom:2px solid #4fc9f3; padding-top:15px;"></td></tr><tr><td width="624" valign="top" style="width:283px;border:none;padding:10px 0"><p style="text-align:justify;"><span style="font-size:11px; font-family:calibri; color:#ff0000; font-weight: bold;">CONFIDENTIALITY STATEMENT:</span> <span style="font-size:11px; font-family:Arial, Sans-Serif, Times New Roman; color:#a6a6a6;">The information contained in this communication is confidential and intended only for the use of the recipient named above, and may be legally privileged and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please resend it to the sender and delete the original message and any copy of it from your computer system</span></p></td></tr></tbody></table>';
            mail.setHtmlBody(strHtmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
    }
    @AuraEnabled( cacheable = false )
    public static List<string> getNotApproverUser(string summaryId){
        List<string> userList=New List<String>();
        set<string> userSet=New set<String>();
        List<Estimation_Summary__c> summaryList=[SELECT SME_Vertical__r.Delivery_Role__c,Technical_Project_Manager__r.Delivery_Role__c,Program_Manager__r.Full_Name__c,SME_Vertical__r.Full_Name__c,Technical_Project_Manager__r.Full_Name__c,Id,Technical_Project_Manager__c,SME_Vertical__c,Program_Manager__c,Approved_User_Track__c 
                                                 FROM Estimation_Summary__c where id=:summaryId AND Status__c=:'Ready for Approval' limit 1];
        if(!summaryList.isEmpty()){
            string info=summaryList[0].Approved_User_Track__c;
            
            List<User> currentUserTPMSEMList=[SELECT Id, Name,Delivery_Role__c FROM User 
                                              WHERE ID=:UserInfo.getUserId() AND Delivery_Role__c =:'TPM/SME' LIMIT 1];
            If(!currentUserTPMSEMList.isEmpty()){
                if(string.isNotBlank(info)){
                    if(!info.contains(summaryList[0].Technical_Project_Manager__r.Full_Name__c) && summaryList[0].Technical_Project_Manager__r.Delivery_Role__c !='Program Manager'){
                        userSet.add(summaryList[0].Technical_Project_Manager__r.Full_Name__c);
                    }
                    if(summaryList[0].SME_Vertical__c !=null && !info.contains(summaryList[0].SME_Vertical__r.Full_Name__c) && summaryList[0].SME_Vertical__r.Delivery_Role__c !='Program Manager'){
                        userSet.add(summaryList[0].SME_Vertical__r.Full_Name__c);
                    }
                }else{
                    if(summaryList[0].Technical_Project_Manager__r.Delivery_Role__c !='Program Manager'){
                        userSet.add(summaryList[0].Technical_Project_Manager__r.Full_Name__c);   
                    }
                    if(summaryList[0].SME_Vertical__c !=null && summaryList[0].SME_Vertical__r.Delivery_Role__c !='Program Manager'){
                        userSet.add(summaryList[0].SME_Vertical__r.Full_Name__c);
                    }
                }
            }
            
            List<User> currentUserPMList=[SELECT Id, Name,Delivery_Role__c FROM User WHERE ID=:UserInfo.getUserId() 
                                          AND Delivery_Role__c includes ('Program Manager') LIMIT 1];

            If(!currentUserPMList.isEmpty()){                
                if(string.isNotBlank(info)){
                    if(summaryList[0].Program_Manager__c !=null && !info.contains(summaryList[0].Program_Manager__r.Full_Name__c)){
                        userSet.add(summaryList[0].Program_Manager__r.Full_Name__c);
                    }  
                    if(!info.contains(summaryList[0].Technical_Project_Manager__r.Full_Name__c)){
                        userSet.add(summaryList[0].Technical_Project_Manager__r.Full_Name__c);
                    }
                    if(summaryList[0].SME_Vertical__c !=null && !info.contains(summaryList[0].SME_Vertical__r.Full_Name__c) && summaryList[0].SME_Vertical__r.Delivery_Role__c=='Program Manager'){
                        userSet.add(summaryList[0].SME_Vertical__r.Full_Name__c);
                    }
                }else{
                    if(summaryList[0].Program_Manager__c !=null){
                        userSet.add(summaryList[0].Program_Manager__r.Full_Name__c);
                    }
                    if(summaryList[0].SME_Vertical__c !=null && summaryList[0].SME_Vertical__r.Delivery_Role__c=='Program Manager'){
                        userSet.add(summaryList[0].SME_Vertical__r.Full_Name__c);
                    }
                    userSet.add(summaryList[0].Technical_Project_Manager__r.Full_Name__c);   
                }
            }
        }
        userList.AddAll(userSet);
        system.debug('userList--'+userList);
        return userList;
    }
    @AuraEnabled( cacheable = false )
    public static boolean validationForApproverButton(string summaryId){
        boolean button=false;
        List<Estimation_Summary__c> summaryList=[SELECT Program_Manager__r.Delivery_Role__c,SME_Vertical__r.Delivery_Role__c,Technical_Project_Manager__r.Delivery_Role__c,
                                                 Program_Manager__r.Full_Name__c,SME_Vertical__r.Full_Name__c,Technical_Project_Manager__r.Full_Name__c,Id,Technical_Project_Manager__c,SME_Vertical__c,Program_Manager__c,Approved_User_Track__c FROM Estimation_Summary__c where id=:summaryId AND Status__c=:'Ready for Approval' limit 1];
        if(!summaryList.isEmpty()){
            string info=summaryList[0].Approved_User_Track__c;
            List<User> currentUserList=[SELECT Id, Name ,Delivery_Role__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
            string deliveryRoleUser=currentUserList[0].Delivery_Role__c;
            //TPM's
            if(summaryList[0].Technical_Project_Manager__c !=null && deliveryRoleUser.contains(summaryList[0].Technical_Project_Manager__r.Delivery_Role__c)){
                if(string.isNotBlank(info)){
                    if(!info.contains(summaryList[0].Technical_Project_Manager__r.Full_Name__c)){
                        button=true;
                    }
                }else{
                    button=true; 
                }
            }
            
            //SEM vertical Users
            if(summaryList[0].SME_Vertical__c !=null && (deliveryRoleUser.contains(summaryList[0].Technical_Project_Manager__r.Delivery_Role__c) && summaryList[0].SME_Vertical__r.Delivery_Role__c=='Program Manager')||
                                                         (summaryList[0].SME_Vertical__r.Delivery_Role__c == currentUserList[0].Delivery_Role__c))
            {
                if(string.isNotBlank(info)){
                    if(!info.contains(summaryList[0].SME_Vertical__r.Full_Name__c)){
                        button=true;   
                    }
                }else{
                    button=true;    
                }
            }
            
            //program manager user
            if(summaryList[0].Program_Manager__c !=null && deliveryRoleUser.contains(summaryList[0].Program_Manager__r.Delivery_Role__c)){
                if(string.isNotBlank(info)){
                    if(!info.contains(summaryList[0].Program_Manager__r.Full_Name__c)){
                        button=true;
                    }
                }else{
                    button=true;
                }
            }
            
        }
        return button;
    }
    
    @AuraEnabled( cacheable = false )
    public static List<String> getStatusPickListValue(string summaryId){
        
        /* boolean approvedBy=false;
decimal sumOfSDLCPhase=0;
list<Estimation_Detail__c> inventoryRecords=[SELECT Quantity__c,Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
FROM Estimation_Detail__c WHERE Estimation_Summary__c=:summaryId AND RecordType.Name=:'Inventory' ORDER BY S_No__c ASC NULLS FIRST];

for(AggregateResult  objAgr: [SELECT sum(Project_Specific__c) total FROM Effort_Calculation__c WHERE ODS_Estimate__c =:summaryId and RecordType.Name='SDLC Phase Effort'])
{
sumOfSDLCPhase=(Decimal)objAgr.get('total');
}
if( !inventoryRecords.isEmpty() && sumOfSDLCPhase==100){

}*/
        
        List<String> pickListValuesList= new List<String>();
        List<Estimation_Summary__c> summaryList=[SELECT Id, Status__c FROM Estimation_Summary__c where Status__c=:'Reevaluation In-progress' AND id=:summaryId limit 1];
        List<Estimation_Summary__c> summaryListApproved=[SELECT Id, Status__c FROM Estimation_Summary__c where (Status__c=:'Approved' or Status__c=:'Obsolete') AND id=:summaryId limit 1];
        if(!summaryListApproved.isEmpty()){
            pickListValuesList.add(summaryListApproved[0].Status__c); 
        }
        
        if(!summaryList.isEmpty()){
            pickListValuesList.add(summaryList[0].Status__c); 
            pickListValuesList.add('Ready for Approval');
        }else{
            pickListValuesList.add('Estimation In-progress');
            pickListValuesList.add('Ready for Approval');
            
            /* for( Schema.PicklistEntry pickListVal : ple){
if(pickListVal.getValue() !='Approved' && pickListVal.getValue() !='Reevaluation In-progress'){
pickListValuesList.add(pickListVal.getValue());
}

}  */
            
        }
        return pickListValuesList;
    }
    @AuraEnabled( cacheable = false )
    public static Datetime getSummaryCreatedDate(string summaryId)
    { 
        Datetime createdDate;
        List<Estimation_Summary__c> summaryList=[SELECT Id,CreatedDate FROM Estimation_Summary__c where id=:summaryId limit 1];
        if(!summaryList.isEmpty()){
            createdDate=summaryList[0].CreatedDate;
        }
        return createdDate;
    }
    @AuraEnabled( cacheable = false )
    public static List<Initiatives__c> getInitiativeDetails(string initiativeId)
    { 
        List<Initiatives__c> initiativeList=[SELECT Approver_Name__c,Technical_Project_Manager__c,id,Account_Service__r.Technical_Account_manager__c FROM Initiatives__c where id=:initiativeId limit 1];
        return initiativeList;
    }
    @AuraEnabled( cacheable = false )
    public static string getTPMDetails(string tPMName)
    { 
        system.debug('tPMName-'+tPMName);
        string hId='';
        List<Hierarchy_Lookup__c> HLList=[SELECT Delivery_Role__c,Full_Name__c,Id FROM Hierarchy_Lookup__c WHERE (Delivery_Role__c = 'TPM/SME' OR Delivery_Role__c = 'Program Manager')  AND Full_Name__c=:tPMName LIMIT 1];
        if(!HLList.isEmpty()){
            system.debug('HLList-'+HLList);
            return HLList[0].id;
        }
        return hId;
    }
    @AuraEnabled( cacheable = false )
    public static List<Account_Services__c> getCSMNameList(string accountId,string serviceId)
    { 
        List<Account_Services__c> accountSerList=[SELECT Account__r.User__c,Account__r.Backup_CSM__c,Account__r.User__r.Name,Account__r.Backup_CSM__r.Name,Account__c,ODS_Services__c,Technical_Account_manager__c,Technical_Account_manager__r.Name FROM Account_Services__c where Account__c=:accountId and ODS_Service_Name__c=:'Salesforce'];
        return accountSerList;
    }
    
    @AuraEnabled( cacheable = true )
    public static List<Account> getCustomerList()
    {     
        set<id> accountId=new set<id>();
        List<SelectOption> customersList = new  list<SelectOption>();
        
        ODS_Common_Utility objUtility = new  ODS_Common_Utility();
        customersList = objUtility.getCustomersByLoggedInUser('');        
        if(customersList != null && customersList.size() > 0){
            for(SelectOption accountService: customersList) {      
                If(accountService.getValue() != 'All'){
                    accountId.add(accountService.getValue());
                }
            }
        }
        List<Account> accountList=[Select Id,Name From Account Where Id IN:accountId ORDER BY Name ASC NULLS FIRST ];
        return accountList;
    }    
    @AuraEnabled( cacheable = false )
    public static list<Initiatives__c> getInitiativesList(string accountId,string serviceId){
        list<Account_Services__c> accountSer=[SELECT Account__c,ODS_Services__c FROM Account_Services__c where Account__c=:accountId AND ODS_Services__c=:serviceId limit 1];
        set<id> existInitiativeID=new set<id>();
        set<id> finalInitiativeID=new set<id>();
        List<AggregateResult> existEstimationRecord = [SELECT COUNT(Id)relationCount,Project_ID__c FROM Estimation_Summary__c where Customer__c=:accountId AND Project_ID__c !=:null GROUP BY Project_ID__c]; 
        for (AggregateResult ar: existEstimationRecord) {
            integer count=(Integer) ar.get('relationCount');
            if(count>=2){
                existInitiativeID.add((Id) ar.get('Project_ID__c'));
            }
        }
        for(Estimation_Summary__c es:[SELECT Customer__c,Project_ID__c FROM Estimation_Summary__c where Status__c='Approved' AND Customer__c=:accountId AND Project_ID__c !=:null]){
            existInitiativeID.add(es.Project_ID__c); 
        }
        
        list<Initiatives__c> initiativesList=new list<Initiatives__c> ();
        Set<string> statusList=New Set<string>();
        statusList.add('Saved');
        statusList.add('Re-evaluate');
        if(!accountSer.isEmpty()){
            initiativesList=[SELECT Account_Service__c,Id,Name,JIRA_ID__c  FROM Initiatives__c where Status__c IN:statusList AND Account_Service__c=:accountSer[0].Id AND Id NOT IN: existInitiativeID ORDER BY Name ASC NULLS FIRST];        
        }
        return initiativesList;
    }
    @AuraEnabled( cacheable = true )
    public static List<String> getRiskBoundaryPickListValue(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Estimation_Risk_Description__c.Risk_Boundary__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }     
        system.debug('pickListValuesList-'+pickListValuesList);
        return pickListValuesList;
    }
    @AuraEnabled(cacheable=false)
    public static boolean insertInsertRDList(String insertRiskDescriptionList, string estimationSummaryId){
        system.debug('insertRiskDescriptionList--'+insertRiskDescriptionList);
        
        List<Estimation_Risk_Description__c> estimationRDList=new List<Estimation_Risk_Description__c>();        
        List<Object> obList = (List<object>) json.deserializeUntyped(insertRiskDescriptionList);
        for(object ob : obList) 
        {
            Map<String, object> obmap = (Map<String, object>)ob;
            String RiskDescription = (String)obmap.get('RiskDescription');
            String RiskBoundary = (String)obmap.get('RiskBoundary');
            Estimation_Risk_Description__c rd=new Estimation_Risk_Description__c();
            if(estimationSummaryId.length() !=0){
                rd.Estimation_Summary__c=estimationSummaryId;
                rd.Risk_Description__c=RiskDescription;
                if(RiskBoundary !='--None--'){
                    rd.Risk_Boundary__c=RiskBoundary;
                }
                estimationRDList.add(rd);
            }
        }
        list<Estimation_Risk_Description__c> existRiskDescriptionList=[SELECT Estimation_Summary__c,Id,Risk_Boundary__c,Risk_Description__c FROM Estimation_Risk_Description__c where Estimation_Summary__c=:estimationSummaryId];
        if(!existRiskDescriptionList.isEmpty()){
            delete existRiskDescriptionList;
        }
        if(!estimationRDList.isEmpty()){
            
            insert estimationRDList;
        }
        return true;
    }
    @AuraEnabled(cacheable=false)
    public static Estimation_Summary__c getEstimatedSummeryRecord(string estimatedId){
        Estimation_Summary__c es=[SELECT Acceptance_Criteria__c,Assumptions__c,CreatedById,
                                  CreatedDate,Created_By__c,Customer_Success_Manager__c,Customer__c,
                                  Estimation_Date__c,Has_Data_Migration__c,Id,IsDeleted,Is_Coding_Involved__c,
                                  LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Out_of_Scope__c,
                                  Project_Billing_Type__c,Project_Description__c,Project_ID__c,Proposed_End_Date__c,Proposed_Start_Date__c,
                                  Revenue_Region__c,Scope__c,SystemModstamp,Team_Productivity__c,Technical_Project_Manager__c,Technology__c,
                                  Work_Days_Per_Month__c,Status__c,
                                  Work_Days_Per_Week__c,Work_Hours_Per_Day__c,Project_ID__r.Name,Project_ID__r.JIRA_ID__c,SME_Vertical__c,Program_Manager__c,Total_Effort_In_Hours__c
                                  FROM Estimation_Summary__c WHERE Id=:estimatedId LIMIT 1];
        return es;
    }
    @AuraEnabled
    public static list<Estimation_Risk_Description__c> getRiskDescriptionList(string estimatedId){
        list<Estimation_Risk_Description__c> riskDescriptionList=[SELECT Estimation_Summary__c,Id,Risk_Boundary__c,Risk_Description__c FROM Estimation_Risk_Description__c where Estimation_Summary__c=:estimatedId];
        return riskDescriptionList;
    }
    @AuraEnabled(cacheable=false)
    public static void clearStatusToMakeEdit(string estimatedId){
        List<Estimation_Summary__c> getEstimation=[ SELECT Approved_User_Track__c,Status__c,Project_ID__r.status__c FROM Estimation_Summary__c Where ID=:estimatedId];
        if(!getEstimation.isEmpty()){
            getEstimation[0].Status__c='Reevaluation In-progress';
            getEstimation[0].Approved_User_Track__c=null;
            Update getEstimation[0];
        }
    }
    @AuraEnabled(cacheable=false)
    public static boolean getReEvaluateInitiatives(string estimatedId){
        boolean button=false;
        List<Estimation_Summary__c> summaryList=[SELECT Id,Technical_Project_Manager__c,SME_Vertical__c,Program_Manager__c,Approved_User_Track__c FROM Estimation_Summary__c where id=:estimatedId limit 1];
        if(!summaryList.isEmpty()){
            List<User> UserList=[SELECT Delivery_Role__c,Id, Name FROM User WHERE (Delivery_Role__c='Program Manager' OR Delivery_Role__c='TPM/SME' ) AND ID=:UserInfo.getUserId() LIMIT 1];
            //TPM's
            if(!UserList.isEmpty()){
                button=true; 
            }
        }
        if(button){
            List<Estimation_Summary__c> getEstimation=[ SELECT status__c,Project_ID__r.status__c FROM Estimation_Summary__c Where ID=:estimatedId AND Project_ID__r.status__c='Re-evaluate' AND status__c='Approved'];
            if(!getEstimation.isEmpty()){
                return true;
            }
        }
        return false;  
    }
    @AuraEnabled(cacheable=false)
    public static boolean validationOnCheckList(string estimationSummaryId){
        boolean validation=false;
        checkExistRecordsOnRelated(estimationSummaryId);
        List<Estimation_Checklist__c> existCheckListRecord=[SELECT Activities__c,Check__c,Estimation_Summary__c,Id,Remarks__c,Required__c,Status__c,S_No__c FROM Estimation_Checklist__c
                                                            WHERE Estimation_Summary__c=:estimationSummaryId
                                                            AND Status__c = 'No'];
        system.debug('existCheckListRecord---'+existCheckListRecord.size());
        for(Estimation_Checklist__c ec:existCheckListRecord){
            system.debug(ec.Status__c +'-----'+ec.Remarks__c);
            if(ec.Status__c =='No' && string.isBlank(ec.Remarks__c)){
                validation=true;
                return true;
            }
        }
        system.debug('validation--'+validation);
        return validation;
    }
    @AuraEnabled(cacheable=false)
    public static boolean validationOnEffortCalculation(string estimationSummaryId){
        boolean validation=false;
        decimal sumOfSDLCPhase=0;
        for(AggregateResult  objAgr: [SELECT sum(Project_Specific__c) total FROM Effort_Calculation__c WHERE ODS_Estimate__c =:estimationSummaryId and RecordType.Name='SDLC Phase Effort'])
        {
            sumOfSDLCPhase=(Decimal)objAgr.get('total');
        }
        if(sumOfSDLCPhase !=100){
            return true;
        }
        String odsEstimateRecordTypeID = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('ODS Estimate').getRecordTypeId();
        List<Effort_Calculation__c> getODSEstimate=[Select Id From Effort_Calculation__c Where RecordTypeId=:odsEstimateRecordTypeID AND ODS_Estimate__c=:estimationSummaryId ];
        if(getODSEstimate.isEmpty()){
            return true; 
        }
        return validation;
    }
    @AuraEnabled(cacheable=false)
    public static boolean validationOnInventory(string estimationSummaryId){
        boolean validation=false;
        list<Estimation_Detail__c> inventoryRecords=[SELECT Quantity__c,Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                                     FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummaryId AND RecordType.Name=:'Inventory' ORDER BY S_No__c ASC NULLS FIRST];
        if(inventoryRecords.isEmpty()){
            return true; 
        }      
        return validation;
    }
    @AuraEnabled(cacheable=false)
    public static boolean validationOnComplexity(string estimationSummaryId){
        boolean validation=false;
        list<Estimation_Detail__c> returnComplexityMatrix=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                                           FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummaryId AND RecordType.Name=:'Complexity Matrix' ORDER BY S_No__c ];   
        if(returnComplexityMatrix.isEmpty()){
            return true; 
        }      
        return validation;
    }
    @AuraEnabled
    public static void checkExistRecordsOnRelated(string estimationSummaryId){
        List<Estimation_Summary__c> estimationSummaryRecord=[SELECT Estimation_Date__c  FROM Estimation_Summary__c WHERE ID=:estimationSummaryId ];
        if(!estimationSummaryRecord.isEmpty()){
            
            List<Estimation_Checklist__c> existCheckListRecord=[SELECT Activities__c,Check__c,Estimation_Summary__c,Id,Remarks__c,Required__c,Status__c,S_No__c FROM Estimation_Checklist__c WHERE Estimation_Summary__c=:estimationSummaryId];
            if(existCheckListRecord.isEmpty()){
                String recordTypeInventory = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
                List<String> entityTypeList=New List<String>();
                List<Estimation_Detail__c> estimationDetailsList=[SELECT Entity_Type__c,Estimation_Summary__c,Id,RecordTypeId FROM Estimation_Detail__c WHERE RecordTypeId=:recordTypeInventory AND Estimation_Summary__c=:estimationSummaryId ];
                For(Estimation_Detail__c ed:estimationDetailsList){
                    entityTypeList.add(ed.Entity_Type__c);
                }
                List<Estimation_Checklist_REF__mdt > getcList=[SELECT Active__c,Activities__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Entity_Type__c FROM Estimation_Checklist_REF__mdt where Active__c=true ORDER BY Label ASC NULLS FIRST];
                list<Estimation_Checklist__c> insertEstimationCheckList=New List<Estimation_Checklist__c>();
                decimal sno=0;
                for(Estimation_Checklist_REF__mdt exitsEC:getcList){
                    sno++;
                    Estimation_Checklist__c newEC=new Estimation_Checklist__c();
                    newEC.Activities__c=exitsEC.Activities__c;
                    newEC.S_No__c=sno;
                    newEC.Status__c='No';
                    newEC.Estimation_Summary__c=estimationSummaryId;
                    
                    insertEstimationCheckList.add(newEC);
                    
                }
                if(!insertEstimationCheckList.isEmpty()){
                    insert insertEstimationCheckList;
                }
            }
            
        }
    }
}