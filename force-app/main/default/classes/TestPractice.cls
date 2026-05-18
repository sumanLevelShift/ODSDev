public class TestPractice {
    public void test(){
        Integer a = 0;
        Integer b;
        a = a++;
        System.debug('a - ' + a);//0
        a++;
        System.debug('a1 - ' + a);//1
        Integer c = a*5;//10
        String s = String.valueOf(c) + a;
        System.debug(s + ';' + a + ';' + b);
        
        Opportunity opp = [SELECT Id, Stagename FROM Opportunity LIMIT 1];
        
        String t = Opportunity.Stagename.getDescribe().getLabel();
        
        //sObject ObType = opp.getSObjectType();        
        Double x = 2;
        Decimal d;
        
        System.debug('00000 ' + d);
        
        Opportunity opp1 = [ select id, Probability from Opportunity where id = '0067F00000B3hXS'];
        
        Decimal percentValue = opp1.Probability*100;
        System.debug('-------------------' + percentValue);
        
        
    }
    public String myString {
        get {
            System.debug('Inside get');
            if (myString == null) {
                myString = 'a';
            }
            return myString;
        } private set;
    }
    public string getMyString (){
        System.debug('Inside getMyString');
        return 'getMyString';
    }
    public string getStringMethod () {
        System.debug('Inside getStringMethod');
        System.debug('-----------' + myString);
        if (myString == null) {
            myString = 'b';
        }
        System.debug('-----' + myString);
        
        
        List<String> testList = new List<String>();
        testList.add('1'); testList.add('2');
        for(String m : testList){
            List<Contact> contactList = [select id from Contact ];
        }
        return myString;
    }
    public void queryLimitPractice(){
        List<Contact> acc = [select id from Contact LIMIT 10];
        //Delete acc;
        
        //Database.emptyRecycleBin(acc);
        
        System.debug(Limits.getLimitQueries() + ':' + Limits.getLimitDmlStatements());
    }
}