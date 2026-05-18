public class TestPractice2 {
    public String myString;
    public String getMyString() {
        return 'getmyString';}
    public String getStringMethod1() {
        return myString;
    }
    public String getStringMethod2() {
        if (myString == null)
            myString = 'Method2';
        return myString;
    }
    public void test(){
        TestPractice2 tp = new TestPractice2();
        system.debug(tp.getMyString() + ',' + tp.getStringMethod1() + ','+ tp.getStringMethod2() + ',' + tp.getMyString());
    }
    
    public void test1(){
        try {
            List<String> nameList;
            Account a;
            String s = a.Name;
            nameList.add(s);
        } catch (ListException le ) {
            System.debug(' List Exception ');
        } catch (NullPointerException npe) {
            System.debug(' NullPointer Exception ');
        } catch (Exception e) {
            System.debug(' Generic Exception ');
        } 
    }
    
}