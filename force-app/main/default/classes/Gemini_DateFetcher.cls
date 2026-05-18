public with sharing class Gemini_DateFetcher {
    // Replace with your real API key
    private static final String API_KEY = 'AIzaSyC0--62uHl1mex21_2tX1bz9S4QDcEc3dg';
    //private static final String API_KEY = 'AIzaSyC90lJgl-csU1cxAcF7L8RwucuS20vypaQ';

    public static String generateText(String prompt) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key='
            + EncodingUtil.urlEncode(API_KEY, 'UTF-8')
        );
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> body = new Map<String, Object>{
            'contents' => new List<Object>{
                new Map<String, Object>{
                    'parts' => new List<Object>{
                        new Map<String, Object>{
                            'text' => prompt
                        }
                    }
                }
            }
        };

        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Object> candidates = (List<Object>) responseMap.get('candidates');
            if (candidates != null && !candidates.isEmpty()) {
                Map<String, Object> firstCandidate =
                    (Map<String, Object>) candidates[0];

                Map<String, Object> content =
                    (Map<String, Object>) firstCandidate.get('content');

                List<Object> parts = (List<Object>) content.get('parts');
                if (parts != null && !parts.isEmpty()) {
                    Map<String, Object> firstPart =
                        (Map<String, Object>) parts[0];

                    return (String) firstPart.get('text');
                }
            }

            return 'No text returned by Gemini.';
        } else {
            return 'Error ' + res.getStatusCode() + ': ' + res.getBody();
        }
    }
}