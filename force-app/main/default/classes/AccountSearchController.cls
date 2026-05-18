public class AccountSearchController {
    public List<Account> accounts { get; set; }
    public String name { get; set; }
    //public String mailingState { get; set; }
    
    public AccountSearchController()
    {
        accounts = new List<Account>();
    }
    
    public PageReference searchAccounts()
    {
        accounts = [select Id,name,AccountSource,type,industry from Account where Name = :name];
        System.debug('*************' + accounts.size());
        return null;
    }
}