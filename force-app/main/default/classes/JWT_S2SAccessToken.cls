public class JWT_S2SAccessToken {
    public static Boolean runningInASandbox {
        get {
            if (runningInASandbox == null) {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return runningInASandbox;
        }
        set;
    }
    
    public Auth.JWT getAuthJWT(String username, String consumerKey, Boolean isSandbox){
        String audienceClaimUrl = 'https://login.salesforce.com';
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(username);
        if(isSandbox){
            audienceClaimUrl = 'https://test.salesforce.com';
        }
        jwt.setAud(audienceClaimUrl);
        
        jwt.setIss(consumerKey);
        
        jwt.setValidityLength(600); //in seconds - 10 minutes
       
        return jwt;
    }
    
    public void addAuthorizationHeader(HttpRequest req, Auth.JWT jwt, String certName, Boolean isSandbox){
        req.setHeader('Authorization', 'Bearer ' + getOAuthAccessToken(jwt, certName, isSandbox));
    }    

    public String getOAuthAccessToken(Auth.JWT jwt, String certName, Boolean isSandbox){
        String tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token'; //default set to production
        String accessToken = '';
        
        if(isSandbox){
            tokenEndpoint = 'https://test.salesforce.com/services/oauth2/token';           
        }

        Auth.JWS jws = new Auth.JWS(jwt, certName);
        
        if(!Test.isRunningTest()){
            String token = jws.getCompactSerialization();
            
            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
            
            accessToken = bearer.getAccessToken();
        }else{
            accessToken = 'test-token-generated';
        }
        
        return accessToken;        
    }    
}