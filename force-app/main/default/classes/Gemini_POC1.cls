/**
 * POC: call Google Gemini with org snapshot JSON (see static resource Gemini_POC1_OrgSnapshot)
 * and extract field {@code apiName} values. Uses Custom Label Gemini_API_Key (same as Gemini_DateFetcher).
 */
public with sharing class Gemini_POC1 {
    public class Gemini_POC1Exception extends Exception {
    }

    private static final String MODEL_ID = 'gemini-2.0-flash';
    private static final String STATIC_RESOURCE_NAME = 'Gemini_POC1_OrgSnapshot';
    private static final String PLACEHOLDER_API_KEY_LABEL = 'AIzaSyDV4IzXyzwrbSKZBXAoRuJm1WctA6Qk5-k';

    @TestVisible
    private static String apiKeyForTest;

    /** When true in a test, {@link #resolveApiKey()} returns null (exercise missing-key paths). */
    @TestVisible
    private static Boolean simulateMissingApiKey;

    /** When set in tests, used instead of loading the static resource. */
    @TestVisible
    private static String snapshotJsonForTest;

    /**
     * JSON file shipped as static resource {@value #STATIC_RESOURCE_NAME} (org metadata snapshot).
     */
    public static String getOrgSnapshotJson() {
        if (Test.isRunningTest() && snapshotJsonForTest != null) {
            return snapshotJsonForTest;
        }
        StaticResource sr = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_NAME
            LIMIT 1
        ];
        return sr.Body.toString();
    }

    /**
     * Sends the org snapshot JSON to Gemini, asks for every {@code objects[].fields[].apiName},
     * and returns the parsed list (document order; duplicate api names such as {@code Id} are kept).
     */
    public static List<String> extractFieldApiNamesFromOrgSnapshot() {
        return extractFieldApiNamesFromJson(getOrgSnapshotJson()).apiNames;
    }

    /**
     * Same as {@link #extractFieldApiNamesFromOrgSnapshot()} but returns the model JSON string
     * {@code {"fieldApiNames":["...",...]}} (single LLM round-trip).
     */
    public static String extractFieldApiNamesJsonResponseFromOrgSnapshot() {
        return extractFieldApiNamesFromJson(getOrgSnapshotJson()).responseJson;
    }

    /**
     * Runs field extraction on arbitrary JSON in the same snapshot shape.
     */
    public static List<String> extractFieldApiNamesFromJsonString(String jsonDocument) {
        return extractFieldApiNamesFromJson(jsonDocument).apiNames;
    }

    public static String extractFieldApiNamesJsonResponseFromJsonString(String jsonDocument) {
        return extractFieldApiNamesFromJson(jsonDocument).responseJson;
    }

    private class FieldExtractionResult {
        List<String> apiNames;
        String responseJson;
    }

    private static FieldExtractionResult extractFieldApiNamesFromJson(String jsonDocument) {
        if (String.isBlank(jsonDocument)) {
            throw new Gemini_POC1Exception('JSON document is required.');
        }
        String systemText =
            'You receive JSON that includes an "objects" array. Each object may contain a "fields" array; ' +
            'each field object includes an "apiName" string for the Salesforce field API name. ' +
            'Traverse all objects in order, and within each object all fields in array order. ' +
            'Collect the apiName value for every field object (include duplicates if the same apiName appears on multiple rows, e.g. Id). ' +
            'Respond with a single JSON object only — no markdown, no commentary. ' +
            'Use exactly this shape: {"fieldApiNames":["apiName1","apiName2",...]} where fieldApiNames is a JSON array of strings.';

        String userText =
            'Process the following JSON and return fieldApiNames as specified.\n\n' +
            jsonDocument;

        Map<String, Object> genCfg = new Map<String, Object>{
            'temperature' => 0,
            'responseMimeType' => 'application/json'
        };

        HttpResponse res = executeGeminiRequest(systemText, userText, genCfg);
        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            throw new Gemini_POC1Exception(
                'Gemini HTTP ' + res.getStatusCode() + ': ' + res.getBody()
            );
        }
        String modelText = extractModelText(res.getBody());
        String stripped = stripMarkdownCodeFences(modelText);
        List<String> names = parseFieldApiNamesObject(stripped);

        FieldExtractionResult out = new FieldExtractionResult();
        out.apiNames = names;
        out.responseJson = stripped;
        return out;
    }

    /**
     * Simple text generation (original POC entry point). On HTTP errors returns a message string;
     * on missing API key returns a configuration hint.
     */
    public static String generateText(String prompt) {
        String apiKey = resolveApiKey();
        if (String.isBlank(apiKey)) {
            return 'Configure Custom Label Gemini_API_Key with your Google AI Studio API key.';
        }
        try {
            HttpResponse res = executeGeminiRequest(null, prompt, null);
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                return extractModelText(res.getBody());
            }
            return 'Error ' + res.getStatusCode() + ': ' + res.getBody();
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    private static HttpResponse executeGeminiRequest(
        String systemInstructionText,
        String userText,
        Map<String, Object> generationConfigOverrides
    ) {
        String apiKey = resolveApiKey();
        if (String.isBlank(apiKey)) {
            throw new Gemini_POC1Exception(
                'Set Custom Label Gemini_API_Key (Setup → Custom Labels) to your Google AI Studio API key.'
            );
        }
        Map<String, Object> userContent = new Map<String, Object>{
            'role' => 'user',
            'parts' => new List<Object>{ new Map<String, Object>{ 'text' => userText } }
        };
        Map<String, Object> genCfg = new Map<String, Object>{ 'temperature' => 0 };
        if (generationConfigOverrides != null) {
            for (String k : generationConfigOverrides.keySet()) {
                genCfg.put(k, generationConfigOverrides.get(k));
            }
        }
        Map<String, Object> bodyMap = new Map<String, Object>{
            'contents' => new List<Object>{ userContent },
            'generationConfig' => genCfg
        };
        if (!String.isBlank(systemInstructionText)) {
            bodyMap.put(
                'systemInstruction',
                new Map<String, Object>{
                    'parts' => new List<Object>{ new Map<String, Object>{ 'text' => systemInstructionText } }
                }
            );
        }

        String jsonBody = JSON.serialize(bodyMap);
        //String jsonBody = 'What is the date today?';
        String path = '/v1beta/models/' + MODEL_ID + ':generateContent';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://generativelanguage.googleapis.com' + path);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-goog-api-key', apiKey);
        req.setBody(jsonBody);
        req.setTimeout(120000);
        return new Http().send(req);
    }

    private static String resolveApiKey() {
        if (Test.isRunningTest() && simulateMissingApiKey == true) {
            return null;
        }
        if (Test.isRunningTest() && String.isNotBlank(apiKeyForTest)) {
            return apiKeyForTest;
        }
        String key = System.Label.Gemini_API_Key;
        if (String.isBlank(key) || key == PLACEHOLDER_API_KEY_LABEL) {
            return null;
        }
        return key;
    }

    private static String extractModelText(String responseBody) {
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (root.containsKey('error')) {
            throw new Gemini_POC1Exception('Gemini error payload: ' + JSON.serialize(root.get('error')));
        }
        List<Object> candidates = (List<Object>) root.get('candidates');
        if (candidates == null || candidates.isEmpty()) {
            throw new Gemini_POC1Exception('Gemini response had no candidates.');
        }
        Map<String, Object> first = (Map<String, Object>) candidates[0];
        Map<String, Object> content = (Map<String, Object>) first.get('content');
        if (content == null) {
            throw new Gemini_POC1Exception('Gemini candidate had no content.');
        }
        List<Object> parts = (List<Object>) content.get('parts');
        if (parts == null || parts.isEmpty()) {
            throw new Gemini_POC1Exception('Gemini content had no parts.');
        }
        Map<String, Object> firstPart = (Map<String, Object>) parts[0];
        Object text = firstPart.get('text');
        return text == null ? '' : String.valueOf(text).trim();
    }

    private static List<String> parseFieldApiNamesObject(String jsonText) {
        if (String.isBlank(jsonText)) {
            throw new Gemini_POC1Exception('Model returned empty JSON for field extraction.');
        }
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        Object arr = root.get('fieldApiNames');
        if (arr == null) {
            throw new Gemini_POC1Exception(
                'Model JSON must contain top-level fieldApiNames array. Got: ' + jsonText
            );
        }
        if (!(arr instanceof List<Object>)) {
            throw new Gemini_POC1Exception('fieldApiNames must be a JSON array.');
        }
        List<String> out = new List<String>();
        for (Object o : (List<Object>) arr) {
            if (o != null) {
                String s = String.valueOf(o).trim();
                if (!String.isBlank(s)) {
                    out.add(s);
                }
            }
        }
        return out;
    }

    private static String stripMarkdownCodeFences(String raw) {
        String t = raw == null ? '' : raw.trim();
        if (!t.startsWith('```')) {
            return t;
        }
        Integer firstNl = t.indexOf('\n');
        if (firstNl > 0) {
            t = t.substring(firstNl + 1);
        }
        Integer endFence = t.lastIndexOf('```');
        if (endFence > 0) {
            t = t.substring(0, endFence).trim();
        }
        return t.trim();
    }
}