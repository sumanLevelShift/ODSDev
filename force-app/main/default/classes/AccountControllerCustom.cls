public class AccountControllerCustom {
    public List<Account> lacc{get;set;}
    public List<WrapperClass> lwclass{get;set;}
    public AccountControllerCustom(){
        lwclass = new List<WrapperClass>();
        lacc = [SELECT id,name,phone,website FROM account LIMIT 10];
    } 
    
    public class WrapperClass{
        public Account acc{get;set;}
        public boolean selected{get;set;}
        public WrapperClass(Account a, Boolean b){
            this.acc = a;
            this.selected = b;
        }
    
    }
}