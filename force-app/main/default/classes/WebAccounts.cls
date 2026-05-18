global class WebAccounts {

    global class AccountInfo{
        webservice string AcctName;
        webservice string Industry;
        webservice string Website;
        webservice string LeadGenName;
    }
    
    global class AccountRecord{
        webservice string AcctName;
        webservice string AccId;
    }
    
    webservice static AccountRecord createAccount(AccountInfo p){
        Account acct = new Account();
        acct.Name = p.AcctName;
        acct.Industry = p.Industry;
        acct.Website = p.Website;
        acct.Lead_Gen_Name__c = p.LeadGenName;
        insert acct;
        
        AccountRecord accR = new AccountRecord();
        accR.AcctName = acct.Name;
        accR.AccId = acct.Id;
        return accR;
    }
}