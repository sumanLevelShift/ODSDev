/**
 * Apex-side key-value counting for JSON, plus Claude (Anthropic) LLM flow that loads
 * {@value #SR_SOURCE} and {@value #SR_TARGET} (custom object and field metadata from two orgs)
 * and returns a JSON document in the same shape as static resource {@value #SR_RESULT_SCHEMA}.
 */
public with sharing class Claude_OrgComparisonViaFiles {
    public class ClaudeJsonException extends Exception {
    }

    private static final String SR_SOURCE = 'Groq_POC_SourceJSON';
    private static final String SR_TARGET = 'Groq_POC_TargetJSON';
    /** Example / contract JSON the LLM must follow (onlyInSourceObjects, onlyInTargetObjects, objectFieldDifferences). */
    private static final String SR_RESULT_SCHEMA = 'Groq_POC1_Result';

    private static final String ANTHROPIC_MESSAGES_URL = 'https://api.anthropic.com/v1/messages';
    private static final String ANTHROPIC_VERSION = '2023-06-01';
    private static final String ANTHROPIC_API_KEY = 'sk-ant-api03_REPLACE_WITH_YOUR_KEY';
    private static final String MODEL_ID = 'claude-sonnet-4-6';
    private static final Integer MAX_OUTPUT_TOKENS = 8192;

    @TestVisible
    private static Boolean useJsonBodyOverride;
    @TestVisible
    private static String jsonBodyForTest;

    @TestVisible
    private static Boolean useDualJsonOverride;
    @TestVisible
    private static String testSourceJson;
    @TestVisible
    private static String testTargetJson;

    @TestVisible
    private static Boolean useSchemaBodyOverride;
    @TestVisible
    private static String testSchemaJson;

    @TestVisible
    private static String apiKeyForTest;
    @TestVisible
    private static String endpointForTest;

    /**
     * Loads both static resources (org metadata snapshots), sends them to Claude, and returns the assistant’s
     * JSON summary of differences between SOURCE org and TARGET org (objects, fields, types, etc.).
     */
    public static String countSourceAndTargetKeyPairsViaClaude() {
        String sourceJson = readStaticResourceJson(SR_SOURCE);
        String targetJson = readStaticResourceJson(SR_TARGET);
        String schemaTemplateJson = readResultSchemaTemplate();
        if (String.isBlank(sourceJson)) {
            throw new ClaudeJsonException('Static resource ' + SR_SOURCE + ' is missing or empty.');
        }
        if (String.isBlank(targetJson)) {
            throw new ClaudeJsonException('Static resource ' + SR_TARGET + ' is missing or empty.');
        }
        if (String.isBlank(schemaTemplateJson)) {
            throw new ClaudeJsonException('Static resource ' + SR_RESULT_SCHEMA + ' is missing or empty.');
        }
        String key = resolveApiKey();
        if (String.isBlank(key) || key == 'sk-ant-api03_REPLACE_WITH_YOUR_KEY') {
            throw new ClaudeJsonException('Set ANTHROPIC_API_KEY in Claude_OrgComparisonViaFiles to your Anthropic API key.');
        }
        String systemMsg =
            'You compare two Salesforce org metadata exports given as JSON. Each export describes custom ' +
            'objects and their fields (e.g. apiName, label, dataType, fields arrays, object-level flags). ' +
            'SOURCE is the first org snapshot; TARGET is the second org snapshot. ' +
            'Identify differences: objects present only in SOURCE or only in TARGET; fields added, removed, ' +
            'or changed between matching objects (apiName, label, datatype, required flags, picklist values, lookup targets, etc.). ' +
            'You MUST reply with exactly one JSON object and no other text. ' +
            'The JSON MUST use these top-level keys only: onlyInSourceObjects, onlyInTargetObjects, objectFieldDifferences. ' +
            'Shape must match this template (replace example content with your analysis; use empty arrays where none apply):\n' +
            schemaTemplateJson +
            '\nRules: onlyInSourceObjects and onlyInTargetObjects are arrays of objects with keys objectApiName and fields; ' +
            'each element of fields has label and apiName. objectFieldDifferences is an array of objects with objectApiName and ' +
            'fieldDifferences; each element of fieldDifferences has difference (human-readable change) and apiName. ' +
            'Do not add other top-level keys. No markdown code fences, no commentary before or after the JSON.';
        String userMsg = 'SOURCE JSON:\n' + sourceJson + '\n\nTARGET JSON:\n' + targetJson;

        HttpResponse res = postMessages(systemMsg, userMsg);
        if (res.getStatusCode() != 200) {
            throw new ClaudeJsonException('Claude HTTP ' + res.getStatusCode() + ': ' + res.getBody());
        }
        String assistantRaw = extractAssistantText(res.getBody());
        String normalized = parseAndReturnAssistantJson(assistantRaw);
        Id contentDocumentId = saveLlmJsonAsSalesforceFile(normalized);
        System.debug('LLM response ContentDocumentId: ' + String.valueOf(contentDocumentId));
        logMetadataDiffToDebug(normalized);
        return normalized;
    }

    /**
     * Persists {@code jsonBody} as a Salesforce File ({@link ContentVersion} / {@link ContentDocument}) in the
     * running user's private files. Returns the new {@link ContentDocument} Id, or {@code null} if {@code jsonBody} is blank.
     */
    private static Id saveLlmJsonAsSalesforceFile(String jsonBody) {
        if (String.isBlank(jsonBody)) {
            return null;
        }
        String stamp = String.valueOf(System.now().getTime());
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Claude metadata diff ' + stamp;
        cv.PathOnClient = 'ClaudeMetadataDiff_' + stamp + '.json';
        cv.VersionData = Blob.valueOf(jsonBody);
        cv.Description = 'LLM JSON from Claude_OrgComparisonViaFiles.countSourceAndTargetKeyPairsViaClaude';
        cv.FirstPublishLocationId = UserInfo.getUserId();
        insert cv;
        ContentVersion inserted = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];
        return inserted.ContentDocumentId;
    }

    /**
     * Reads JSON from static resource {@link #SR_SOURCE} and returns the Apex key-value pair count as text.
     */
    public static String countKeyValuePairs() {
        String jsonText = resolveJsonBody();
        if (String.isBlank(jsonText)) {
            throw new ClaudeJsonException('Static resource ' + SR_SOURCE + ' is missing or empty.');
        }
        return String.valueOf(countKeyValuePairsInternal(jsonText));
    }

    /**
     * Apex count of key-value pairs in {@code jsonPayload} (same depth rules as Claude system prompt).
     */
    public static String countKeyValuePairs(String jsonPayload) {
        if (String.isBlank(jsonPayload)) {
            throw new ClaudeJsonException('JSON payload is required.');
        }
        return String.valueOf(countKeyValuePairsInternal(jsonPayload));
    }

    public static String countSamplePayload() {
        String sampleJson = '{"name":"Ada","role":"Dev","level":3}';
        return countKeyValuePairs(sampleJson);
    }

    private static String readStaticResourceJson(String staticResourceName) {
        if (Test.isRunningTest() && useDualJsonOverride == true) {
            if (staticResourceName == SR_SOURCE) {
                return testSourceJson;
            }
            if (staticResourceName == SR_TARGET) {
                return testTargetJson;
            }
        }
        List<StaticResource> rows = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :staticResourceName
            LIMIT 1
        ];
        if (rows.isEmpty() || rows[0].Body == null) {
            return null;
        }
        return rows[0].Body.toString();
    }

    private static String readResultSchemaTemplate() {
        if (Test.isRunningTest() && useSchemaBodyOverride == true && String.isNotBlank(testSchemaJson)) {
            return testSchemaJson;
        }
        return readStaticResourceJson(SR_RESULT_SCHEMA);
    }

    private static String resolveJsonBody() {
        if (Test.isRunningTest() && useJsonBodyOverride == true) {
            return jsonBodyForTest;
        }
        return readStaticResourceJson(SR_SOURCE);
    }

    private static Integer countKeyValuePairsInternal(String jsonText) {
        Object root;
        try {
            root = JSON.deserializeUntyped(jsonText);
        } catch (Exception e) {
            throw new ClaudeJsonException('Invalid JSON: ' + e.getMessage());
        }
        return countDeep(root);
    }

    private static Integer countDeep(Object node) {
        if (node == null) {
            return 0;
        }
        if (node instanceof Map<String, Object>) {
            Map<String, Object> m = (Map<String, Object>) node;
            Integer total = m.size();
            for (Object v : m.values()) {
                total += countDeep(v);
            }
            return total;
        }
        if (node instanceof List<Object>) {
            Integer total = 0;
            for (Object item : (List<Object>) node) {
                total += countDeep(item);
            }
            return total;
        }
        return 0;
    }

    private static String resolveApiKey() {
        if (Test.isRunningTest() && String.isNotBlank(apiKeyForTest)) {
            return apiKeyForTest;
        }
        return ANTHROPIC_API_KEY;
    }

    private static String resolveEndpoint() {
        if (Test.isRunningTest() && String.isNotBlank(endpointForTest)) {
            return endpointForTest;
        }
        return ANTHROPIC_MESSAGES_URL;
    }

    private static HttpResponse postMessages(String systemMessage, String userMessage) {
        Map<String, Object> bodyMap = new Map<String, Object>{
            'model' => MODEL_ID,
            'max_tokens' => MAX_OUTPUT_TOKENS,
            'system' => systemMessage,
            'temperature' => 0,
            'messages' => new List<Map<String, Object>>{
                new Map<String, Object>{ 'role' => 'user', 'content' => userMessage }
            }
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(resolveEndpoint());
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-api-key', resolveApiKey());
        req.setHeader('anthropic-version', ANTHROPIC_VERSION);
        req.setBody(JSON.serialize(bodyMap));
        req.setTimeout(120000);

        return new Http().send(req);
    }

    private static String extractAssistantText(String responseBody) {
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if ('error'.equals(String.valueOf(root.get('type')))) {
            throw new ClaudeJsonException('Claude error: ' + JSON.serialize(root.get('error')));
        }
        List<Object> contentBlocks = (List<Object>) root.get('content');
        if (contentBlocks == null || contentBlocks.isEmpty()) {
            throw new ClaudeJsonException('Claude response had no content blocks.');
        }
        List<String> parts = new List<String>();
        for (Object blockObj : contentBlocks) {
            if (!(blockObj instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> block = (Map<String, Object>) blockObj;
            if (!'text'.equals(String.valueOf(block.get('type')))) {
                continue;
            }
            Object textVal = block.get('text');
            if (textVal != null) {
                parts.add(String.valueOf(textVal));
            }
        }
        return String.join(parts, '').trim();
    }

    private static String parseAndReturnAssistantJson(String assistantRaw) {
        if (String.isBlank(assistantRaw)) {
            throw new ClaudeJsonException('Claude returned empty content for metadata diff.');
        }
        String s = assistantRaw.trim();
        if (s.startsWith('```')) {
            Integer openBrace = s.indexOf('{');
            Integer closeBrace = s.lastIndexOf('}');
            if (openBrace >= 0 && closeBrace > openBrace) {
                s = s.substring(openBrace, closeBrace + 1);
            } else {
                Integer openBracket = s.indexOf('[');
                Integer closeBracket = s.lastIndexOf(']');
                if (openBracket >= 0 && closeBracket > openBracket) {
                    s = s.substring(openBracket, closeBracket + 1);
                }
            }
        }
        Object parsed;
        try {
            parsed = JSON.deserializeUntyped(s);
        } catch (Exception e) {
            throw new ClaudeJsonException(
                'Assistant reply was not valid JSON: ' + e.getMessage() + '. Raw: ' + assistantRaw
            );
        }
        return JSON.serialize(parsed);
    }

    /**
     * Parses the normalized result-shaped JSON and writes a structured breakdown to the debug log.
     */
    private static void logMetadataDiffToDebug(String normalizedJson) {
        System.debug(LoggingLevel.INFO, '=== Claude metadata diff (Groq_POC1_Result shape) - full JSON ===');
        System.debug(LoggingLevel.INFO, normalizedJson);
        Object rootObj;
        try {
            rootObj = JSON.deserializeUntyped(normalizedJson);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Structured log skipped (re-parse failed): ' + e.getMessage());
            return;
        }
        if (!(rootObj instanceof Map<String, Object>)) {
            System.debug(LoggingLevel.WARN, 'Structured log skipped: root is not a JSON object.');
            return;
        }
        Map<String, Object> root = (Map<String, Object>) rootObj;

        logOnlyInObjectsSection('onlyInSourceObjects', root.get('onlyInSourceObjects'));
        logOnlyInObjectsSection('onlyInTargetObjects', root.get('onlyInTargetObjects'));
        logObjectFieldDifferencesSection(root.get('objectFieldDifferences'));
    }

    private static void logOnlyInObjectsSection(String sectionName, Object sectionValue) {
        System.debug(LoggingLevel.INFO, '--- ' + sectionName + ' ---');
        if (!(sectionValue instanceof List<Object>)) {
            System.debug(LoggingLevel.INFO, '(missing or not an array)');
            return;
        }
        List<Object> rows = (List<Object>) sectionValue;
        System.debug(LoggingLevel.INFO, 'count=' + rows.size());
        Integer i = 0;
        for (Object row : rows) {
            if (!(row instanceof Map<String, Object>)) {
                i++;
                System.debug(LoggingLevel.INFO, '[' + i + '] (not an object)');
                continue;
            }
            Map<String, Object> m = (Map<String, Object>) row;
            String objApi = m.containsKey('objectApiName') ? String.valueOf(m.get('objectApiName')) : '';
            System.debug(LoggingLevel.INFO, '[' + (++i) + '] objectApiName=' + objApi);
            Object fieldsVal = m.get('fields');
            if (!(fieldsVal instanceof List<Object>)) {
                System.debug(LoggingLevel.INFO, '    fields: (missing or not an array)');
                continue;
            }
            Integer fi = 0;
            for (Object f : (List<Object>) fieldsVal) {
                if (!(f instanceof Map<String, Object>)) {
                    fi++;
                    System.debug(LoggingLevel.INFO, '    field[' + fi + ']: (not an object)');
                    continue;
                }
                Map<String, Object> fm = (Map<String, Object>) f;
                String api = fm.containsKey('apiName') ? String.valueOf(fm.get('apiName')) : '';
                String lbl = fm.containsKey('label') ? String.valueOf(fm.get('label')) : '';
                System.debug(LoggingLevel.INFO, '    field[' + (++fi) + '] apiName=' + api + ', label=' + lbl);
            }
        }
    }

    private static void logObjectFieldDifferencesSection(Object sectionValue) {
        System.debug(LoggingLevel.INFO, '--- objectFieldDifferences ---');
        if (!(sectionValue instanceof List<Object>)) {
            System.debug(LoggingLevel.INFO, '(missing or not an array)');
            return;
        }
        List<Object> rows = (List<Object>) sectionValue;
        System.debug(LoggingLevel.INFO, 'count=' + rows.size());
        Integer oi = 0;
        for (Object row : rows) {
            if (!(row instanceof Map<String, Object>)) {
                oi++;
                System.debug(LoggingLevel.INFO, '[' + oi + '] (not an object)');
                continue;
            }
            Map<String, Object> m = (Map<String, Object>) row;
            String objApi = m.containsKey('objectApiName') ? String.valueOf(m.get('objectApiName')) : '';
            System.debug(LoggingLevel.INFO, '[' + (++oi) + '] objectApiName=' + objApi);
            Object diffsVal = m.get('fieldDifferences');
            if (!(diffsVal instanceof List<Object>)) {
                System.debug(LoggingLevel.INFO, '    fieldDifferences: (missing or not an array)');
                continue;
            }
            Integer di = 0;
            for (Object d : (List<Object>) diffsVal) {
                if (!(d instanceof Map<String, Object>)) {
                    di++;
                    System.debug(LoggingLevel.INFO, '    diff[' + di + ']: (not an object)');
                    continue;
                }
                Map<String, Object> dm = (Map<String, Object>) d;
                String fn = dm.containsKey('apiName') ? String.valueOf(dm.get('apiName')) : '';
                String diff = dm.containsKey('difference') ? String.valueOf(dm.get('difference')) : '';
                System.debug(LoggingLevel.INFO, '    diff[' + (++di) + '] apiName=' + fn + ' | ' + diff);
            }
        }
    }
}
