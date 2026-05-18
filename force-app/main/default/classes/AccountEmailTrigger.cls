public class AccountEmailTrigger {
    public static void sendEmailToCustomer(List<Account> newAccounts, Map<Id, Account> oldMap) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Account acc : newAccounts) {
            if (acc.Account_Status__c == 'Active' && oldMap.get(acc.Id).Account_Status__c != 'Active') {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ acc.Contact_Email__c});
                email.setSubject('Account Status Update');
                email.setPlainTextBody('Dear Customer, your account is now active.');
                emails.add(email);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}