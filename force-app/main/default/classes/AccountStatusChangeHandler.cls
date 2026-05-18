public class AccountStatusChangeHandler {
    public static void sendWelcomeEmail(List<Account> accounts) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for(Account acc : accounts) {
            if(acc.Account_Status__c == 'Active') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { acc.Contact_Email__c });
                mail.setSubject('Welcome to Our Service');
                mail.setPlainTextBody('Dear ' + acc.Name + ', Welcome to our service. We are happy to have you with us.');
                emails.add(mail);
            }
        }
        
        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}