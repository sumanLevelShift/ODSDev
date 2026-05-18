public class WebUtility {
    public static Boolean IsNotMobileSDK() {
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(Test.isRunningTest()){
            userAgent = 'SalesforceMobileSDK/7.1.2 iOS';
        }
        if(userAgent.contains(Label.ODS_Mobile_App_User_Agent)) {
            return false;
        }
        return true;
    }
}