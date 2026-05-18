@isTest
public class AccountHandler_Test{
    static testmethod void testappendSysdate(){
        Account acc = new Account();
        acc.name = 'Test';
        insert acc;
    }
}