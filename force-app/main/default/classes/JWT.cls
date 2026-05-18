public class JWT {
    
    public String alg {get;set;}
    public String iss {get;set;}
    public String aud {get;set;}
    public String subject {get;set;}
    public String audience {get;set;}
    public Integer validFor {get;set;}
    public String privateKey {get;set;}
    
    public static final String HS256 = 'HS256';

    public JWT(String alg) {
        this.alg = alg;
        this.validFor = integer.valueof(System.Label.JWT_ValidFor);
    }
    
    
    public String GetToken() {
    
        String jwt = '';
    
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
            
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', this.iss);
        body.writeStringField('aud', this.aud);
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        body.writeNumberField('exp', (rightNow + validFor));
        body.writeStringField('iss', this.subject);
        body.writeStringField('aud', this.audience);        
        body.writeEndObject();
        
        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        
        if ( this.alg == HS256 ) {
            Blob secretkey=Blob.valueOf(privateKey);
            string paramvalue = EncodingUtil.base64Encode(secretkey);
            Blob key = EncodingUtil.base64Decode(paramvalue);
            Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            jwt += '.' + base64URLencode(signature);  
        }
        
        return jwt;
    
    }
    

    public String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
    

}