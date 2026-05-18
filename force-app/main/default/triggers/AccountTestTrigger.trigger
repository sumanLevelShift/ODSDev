trigger AccountTestTrigger on Account (before update) {
    List<Contact> theContacts = new List<Contact>();
    for(Account a : Trigger.new){
        a.Name = 'test';
        update a;
    }
    System.debug('***Size' + theContacts.size());
    update theContacts;
}