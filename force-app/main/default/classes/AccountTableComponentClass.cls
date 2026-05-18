public class AccountTableComponentClass {
	@AuraEnabled
    public static List<Account> getAccountsList(){
        return [SELECT Id,Name,Type FROM Account LIMIT 10];
    }
}