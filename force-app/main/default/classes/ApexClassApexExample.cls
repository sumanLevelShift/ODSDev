public class ApexClassApexExample {
    @AuraEnabled
    public static String[] returnStringArray(){
        String[] strArray = new String[]{'ONE','TWO','THREE','FOUR'};
        return strArray;
    }
}