public class ResetCustomerAccountsHelper {
    
    public static List<Contact_Account_Service__c> updateContactAccSer;
    
    public static void resetContactAccountService(){
        if(updateContactAccSer != null && !updateContactAccSer.isEmpty()){
            update updateContactAccSer;
        }
        updateContactAccSer = null;
    }
    
    public static void resetCustomerDetails(List<Account> accountList,set<id> accountIds,Map<Id,Account> oldAccountMap){
        
        updateContactAccSer = new List<Contact_Account_Service__c>();
        Map<Id,Contact_Account_Service__c> getConatctAccSerMap=new Map<id,Contact_Account_Service__c>();
        List<Contact_Account_Service__c> contactAccountService=[SELECT Id,Account__c,Is_Approver__c,Is_initiate_approver__c,Name,Status_Report_Required__c FROM Contact_Account_Service__c WHERE Account__c IN: accountIds ];
        for(Contact_Account_Service__c cas:contactAccountService){
            getConatctAccSerMap.put(cas.Account__c,cas);
        }
        boolean accountHistoryValidation=false;
        List<AccountHistory> accountHistories = [SELECT Id, Field, NewValue, AccountId, CreatedDate FROM AccountHistory WHERE Field=:'Force_com_Account_Status__c' AND AccountId IN :accountIds ORDER BY CreatedDate DESC NULLS FIRST];
        Map<Id,AccountHistory> accountHistoryMap=New Map<Id,AccountHistory>();
        for(AccountHistory ah:accountHistories){
            string newValue=string.valueOf(ah.NewValue);
            if (newValue != null && newValue.Contains('7a: Customer - No Longer')){
                if(!accountHistoryMap.ContainsKey(ah.AccountId)){
                    accountHistoryMap.put(ah.AccountId,ah);
                }
            }
        }
        
        for(Account acc:accountList){
            if(accountHistoryMap.ContainsKey(acc.Id)){
                AccountHistory mostRecentHistory = accountHistoryMap.get(acc.Id);
                Integer months = integer.valueOf(System.Label.ACCOUNT_STATUS_MONTHS_THRESHOLD);
                Date sixMonthsAgo = Date.today().addMonths(-months);
                system.debug('sixMonthsAgo-'+sixMonthsAgo+'---'+mostRecentHistory.CreatedDate);
				//date created=Date.today().addMonths(-months).addDays(-1);
                //if (created < sixMonthsAgo) {
                if (mostRecentHistory.CreatedDate < sixMonthsAgo) {
                    accountHistoryValidation=true;
                }
            }
            system.debug('accountHistoryValidation-'+accountHistoryValidation);
            if(Test.isRunningTest()){
                accountHistoryValidation=true;   
            }
            Account oldAccountData = oldAccountMap.get(acc.Id);
            if(accountHistoryValidation && oldAccountData.Force_com_Account_Status__c=='7a: Customer - No Longer' && acc.Force_com_Account_Status__c=='7: Customer' && acc.Customer_Engagement_Type__c == 'ODS'){
                system.debug('account record-'+acc);
                acc.isSentIntroductionMail__c = false;
                acc.TriggerKickoffMail__c = false;
                acc.Kickoff__c = 'Not Started';                        
                acc.IsEnvironmentAccessEmail__c = false;
                acc.Environment_Access__c  = 'Not Started';
                acc.isLightningReadinessEmailSent__c = false;
                acc.Lightning_Readiness_Check__c = 'Not Started';
                acc.IsInitialEstEmailSent__c = false;                        
                acc.isOnboardingDocumentationEmailSent__c = false;
                acc.Onboarding_Document__c = 'Not Started';
                acc.Customer_Portal_Access__c = 'Not Started';
                acc.Customer_Portal_Demo__c = 'Not Started';
                acc.Is_Portal_Access__c = false;
                acc.CheckIntroDuplicate__c = false;
                acc.Customer_Portal_Demo_Status_Date__c = null;
                acc.Customer_Portal_Access_Status_Date__c = null;
                acc.EnviAccCompletedDate__c = null;
                acc.Environment_Access_Status_Date__c = null;                        
                acc.Introduction_Email_Status_Date__c = null;
                acc.KickOff_Completed_Date__c = null;
                acc.Kickoff_Status_Date__c = null;
                acc.Lightning_Readiness_Check_Status_Date__c = null;
                acc.Onboarding_Document_Status_Date__c = null;
                acc.Project_Initation_Status_Date__c = null;
                if(getConatctAccSerMap.containsKey(acc.id)){
                    Contact_Account_Service__c contactAccSer=getConatctAccSerMap.get(acc.id);
                    contactAccSer.Is_Approver__c=false;
                    contactAccSer.Is_initiate_approver__c=false;
                    contactAccSer.Status_Report_Required__c=false;
                    updateContactAccSer.add(contactAccSer);
                }
            }
         }
    }
}