@isTest
public class ReusableOrgControllerTest {

    @isTest
    public static void testRedirect(){
        ReusableOrgController roc = new ReusableOrgController();
        PageReference pageRef = roc.redirectToReusables();
        System.Assert.areEqual(pageRef.getRedirectCode(), 302);
    }
}