@isTest
public class JWT_S2SAccessTokenTest {
    @isTest
    public static void requestForAccessToken1(){
        Boolean runningInASandbox = JWT_S2SAccessToken.runningInASandbox;
        requestForAccessToken(runningInASandbox);
    }

    @isTest
    public static void requestForAccessToken2(){
        Boolean runningInASandbox = JWT_S2SAccessToken.runningInASandbox;
        requestForAccessToken(!runningInASandbox);
    }
    
    private static void requestForAccessToken(Boolean isSandbox){
        JWT_S2SAccessToken jwtToken = new JWT_S2SAccessToken();
        HttpRequest request = new HttpRequest();        
        Auth.JWT jwt = jwtToken.getAuthJWT('sfadmin@demandblue.com.ezreodsqa', 'tes12545', isSandbox);
        jwtToken.addAuthorizationHeader(request, jwt, 'Test', isSandbox);
        system.assertEquals(request.getHeader('Authorization'), 'Bearer test-token-generated');
    }    
}