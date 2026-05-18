public class AccountControllerExtension{
    private final Account acct;
    public AccountControllerExtension(ApexPages.StandardController stdController){
        this.acct = (Account)stdController.getRecord();
    }
    public String getGreeting(){
        return 'Hello ' + acct.name + ', id : ' + acct.id;
    }
}