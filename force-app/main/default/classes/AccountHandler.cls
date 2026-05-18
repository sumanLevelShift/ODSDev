public with sharing class AccountHandler{
    public static void appendSysdate(List<Account> lAcc){
        for(Account a: lAcc){
            a.name = a.name + System.now();
        }
    }
    public static void createContact(List<Account> lAcc){
        List<Contact> lcontact = new List<Contact>();
        for(Account a: lAcc){
            Integer i = 0;
            Contact c = new Contact();
            c.firstname = 'Suman';
            c.lastname= 'Dahiya';
            c.accountid = a.id;
            lcontact .add(c);
        }
        if(!lcontact.isEmpty()){
            insert lcontact;
        }
    }
    public static void createNewContact(List<Account> lAcc){
        Set<Id> ownerIdSet = new Set<id>();
        List<Contact> lcontact = new List<Contact>();
        for(Account a : lAcc)
        {
        	ownerIdSet.add(a.OwnerId);	    
        }
        // Get account owner emails using map
        Map<Id,User> ownerMap = new Map<Id,User>([Select id,email from user where Id in : ownerIdSet]);
        
        for(Account a: lAcc){
            Contact c = new Contact();
            c.accountid = a.id;
            c.firstname = 'Suman';
            c.lastname= a.name;
            c.phone = a.phone;
            c.email = ownerMap.get(a.OwnerId).email;
            
            lcontact .add(c);
        }
        if(!lcontact.isEmpty()){
            insert lcontact;
        }
    }
}