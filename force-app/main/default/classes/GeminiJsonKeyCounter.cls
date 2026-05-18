/**
 * Minimal Gemini example: POST JSON to the model and ask it to count key-value pairs.
 * Replace ENDPOINT and API_KEY with your values. Requires Remote Site for generativelanguage.googleapis.com.
 */
public with sharing class GeminiJsonKeyCounter {
    private static final String API_KEY = 'AIzaSyC0--62uHl1mex21_2tX1bz9S4QDcEc3dg';
    private static final String ENDPOINT =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=' +
        EncodingUtil.urlEncode(API_KEY, 'UTF-8');

    /** Example payload you can change or replace via {@link #askCount(String)}. */
    private static final String SAMPLE_JSON = '{"name":"Acme","active":true,"count":3}';

    /**
     * Sends {@link #SAMPLE_JSON} to Gemini and returns the model reply text (expected: count explanation).
     */
    public static String countPairsSampleJson() {
        return askCount(SAMPLE_JSON);
    }

    /**
     * Sends arbitrary JSON text and asks Gemini how many key-value pairs it contains (nested keys counted separately).
     */
    public static String askCount(String jsonText) {
        if (String.isBlank(jsonText)) {
            return 'Error: JSON text is empty.';
        }
        String prompt =
            'You receive JSON below. Count every key-value pair in the entire structure. ' +
            'If an object is nested inside another object or array, count each nested pair separately. ' +
            'Answer with one short sentence stating only the number you counted and nothing else.\n\n' +
            jsonText;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);

        Map<String, Object> body = new Map<String, Object>{
            'contents' => new List<Object>{
                new Map<String, Object>{
                    'parts' => new List<Object>{ new Map<String, Object>{ 'text' => prompt } }
                }
            },
            'generationConfig' => new Map<String, Object>{
                'temperature' => 0
            }
        };
        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> candidates = (List<Object>) root.get('candidates');
            if (candidates != null && !candidates.isEmpty()) {
                Map<String, Object> first = (Map<String, Object>) candidates[0];
                Map<String, Object> content = (Map<String, Object>) first.get('content');
                if (content != null) {
                    List<Object> parts = (List<Object>) content.get('parts');
                    if (parts != null && !parts.isEmpty()) {
                        Map<String, Object> part = (Map<String, Object>) parts[0];
                        Object text = part.get('text');
                        return text == null ? '' : String.valueOf(text).trim();
                    }
                }
            }
            return 'No text in Gemini response.';
        }
        return 'HTTP ' + res.getStatusCode() + ': ' + res.getBody();
    }
}