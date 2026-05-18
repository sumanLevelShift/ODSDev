@isTest
public class WebUtilityTest {
    public static testmethod void checkMobileApp(){
        Boolean retValue = WebUtility.IsNotMobileSDK();
        System.assertEquals(false, retValue);
    }
}