public class ReusableOrgController {

    public PageReference redirectToReusables(){
        string redirectUrl = getRedirectURL();
        PageReference retURL = new PageReference(redirectUrl);
        retURL.setRedirect(true);
        retURL.setRedirectCode(302);
        return retURL;
    }
    
    private string getRedirectURL(){
        JWT_S2SAccessToken jwtAccessToken = new JWT_S2SAccessToken();
        Auth.JWT jwt = jwtAccessToken.getAuthJWT(System.Label.RSBL_ORG_Username, System.Label.RSBL_ORG_ClientId, true);
        string sessionId = jwtAccessToken.getOAuthAccessToken(jwt, System.Label.RSBL_ORG_CertName, true);
        string pathSeparator = (System.Label.RSBL_ORG_URL.endsWith('/') || System.Label.RSBL_ORG_LandingPage.startsWith('/')) ? '' : '/';
        string retURL = System.Label.RSBL_ORG_URL + pathSeparator + System.Label.RSBL_ORG_LandingPage;
        string redirectURL = System.Label.RSBL_ORG_URL + '/secur/frontdoor.jsp?sid={0}&retURL={1}';
        redirectURL = string.format(redirectURL, new object[]{sessionId,  EncodingUtil.urlEncode(retURL, 'UTF-8')});
        return redirectURL;
    }
}