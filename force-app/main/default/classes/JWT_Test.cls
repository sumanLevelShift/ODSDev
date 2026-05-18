@isTest 
public class JWT_Test {
    
    public static testMethod void testJWTDetails(){
        Test.startTest();
        JWT jwt = new JWT('HS256');
        jwt.privateKey =System.Label.JWT_Private_Key;
        jwt.iss = System.Label.JWT_Issuer;
        jwt.aud =System.Label.JWT_Aud;
        jwt.subject = System.Label.JWT_Subject;
        jwt.audience = System.Label.JWT_Audience;
        string token = jwt.GetToken(); 
        Test.stopTest();
    }
    
}