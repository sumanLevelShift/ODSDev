/**
 * Claude LLM org comparison using caller-supplied Salesforce file {@link ContentDistribution#DistributionPublicUrl}
 * values (HTTPS). Sends those URLs to Claude, instructs the model to HTTP GET both JSON payloads, compare them,
 * and return summary JSON matching static resource {@value #SR_RESULT_SCHEMA}.
 */
public with sharing class Claude_OrgComparisonViaFiles1 {
    public class ClaudeOrgComparisonViaFiles1Exception extends Exception {
    }

    private static final String SR_RESULT_SCHEMA = 'Groq_POC1_Result';

    private static final String ANTHROPIC_MESSAGES_URL = 'https://api.anthropic.com/v1/messages';
    private static final String ANTHROPIC_VERSION = '2023-06-01';
    private static final String ANTHROPIC_API_KEY = 'sk-ant-api03_REPLACE_WITH_YOUR_KEY';
    private static final String MODEL_ID = 'claude-sonnet-4-6';
    private static final Integer MAX_OUTPUT_TOKENS = 8192;

    /**
     * @param sourceOrgDistributionPublicUrl SOURCE org JSON — {@code DistributionPublicUrl} (HTTPS public link to the file).
     * @param targetOrgDistributionPublicUrl TARGET org JSON — same.
     * @return Normalized JSON string matching {@value #SR_RESULT_SCHEMA}.
     */
    public static String compareSourceAndTargetViaClaude(
        String sourceOrgDistributionPublicUrl,
        String targetOrgDistributionPublicUrl
    ) {
        if (String.isBlank(sourceOrgDistributionPublicUrl)) {
            throw new ClaudeOrgComparisonViaFiles1Exception('SOURCE DistributionPublicUrl is required.');
        }
        if (String.isBlank(targetOrgDistributionPublicUrl)) {
            throw new ClaudeOrgComparisonViaFiles1Exception('TARGET DistributionPublicUrl is required.');
        }

        String schemaTemplateJson = readPlainStaticResourceAsString(SR_RESULT_SCHEMA);
        if (String.isBlank(schemaTemplateJson)) {
            throw new ClaudeOrgComparisonViaFiles1Exception(
                'Static resource ' + SR_RESULT_SCHEMA + ' is missing or empty.'
            );
        }

        String normalized = invokeClaudeAndNormalize(
            sourceOrgDistributionPublicUrl.trim(),
            targetOrgDistributionPublicUrl.trim(),
            schemaTemplateJson
        );
        Id contentDocumentId = saveLlmJsonAsSalesforceFile(normalized);
        System.debug('LLM response ContentDocumentId: ' + String.valueOf(contentDocumentId));
        logMetadataDiffToDebug(normalized);
        return normalized;
    }

    private static String readPlainStaticResourceAsString(String staticResourceName) {
        List<StaticResource> rows = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :staticResourceName
            LIMIT 1
        ];
        if (rows.isEmpty() || rows[0].Body == null || rows[0].Body.size() == 0) {
            return null;
        }
        return rows[0].Body.toString();
    }

    private static String invokeClaudeAndNormalize(String sourceUrl, String targetUrl, String schemaTemplateJson) {
        String key = resolveApiKey();
        if (String.isBlank(key) || key == 'sk-ant-api03_REPLACE_WITH_YOUR_KEY') {
            throw new ClaudeOrgComparisonViaFiles1Exception(
                'Set ANTHROPIC_API_KEY in Claude_OrgComparisonViaFiles1 to your Anthropic API key.'
            );
        }

        String systemMsg =
            'You compare two Salesforce org metadata exports. Each export is a JSON document reachable only ' +
            'via HTTPS. SOURCE is the first org snapshot; TARGET is the second org snapshot. ' +
            'You MUST use HTTP GET (or equivalent) on the two URLs provided in the user message to retrieve ' +
            'the raw JSON text from Salesforce Content Distribution public links (secure delivery endpoints). ' +
            'Do not invent file contents. ' +
            'After both payloads are loaded, identify differences: objects only in SOURCE or only in TARGET; ' +
            'fields added, removed, or changed between matching objects (apiName, label, datatype, required ' +
            'flags, picklist values, lookup targets, etc.). ' +
            'You MUST reply with exactly one JSON object and no other text. ' +
            'The JSON MUST use these top-level keys only: onlyInSourceObjects, onlyInTargetObjects, objectFieldDifferences. ' +
            'Shape must match this template (replace example content with your analysis; use empty arrays where none apply):\n' +
            schemaTemplateJson +
            '\nRules: onlyInSourceObjects and onlyInTargetObjects are arrays of objects with keys objectApiName and fields; ' +
            'each element of fields has label and apiName. objectFieldDifferences is an array of objects with objectApiName and ' +
            'fieldDifferences; each element of fieldDifferences has difference (human-readable change) and apiName. ' +
            'Do not add other top-level keys. No markdown code fences, no commentary before or after the JSON.';

        String userMsg =
            'Retrieve and compare the following two JSON exports.\n' +
            'SOURCE org JSON (HTTP GET this URL for the SOURCE snapshot):\n' +
            sourceUrl +
            '\n\nTARGET org JSON (HTTP GET this URL for the TARGET snapshot):\n' +
            targetUrl +
            '\n\nBoth URLs are Salesforce file distribution public links; they may expire. ' +
            'Compare the decoded JSON documents and respond with the required summary JSON only.';

        HttpResponse res = postMessages(systemMsg, userMsg);
        if (res.getStatusCode() != 200) {
            throw new ClaudeOrgComparisonViaFiles1Exception(
                'Claude HTTP ' + res.getStatusCode() + ': ' + res.getBody()
            );
        }
        String assistantRaw = extractAssistantText(res.getBody());
        return parseAndReturnAssistantJson(assistantRaw);
    }

    private static Id saveLlmJsonAsSalesforceFile(String jsonBody) {
        if (String.isBlank(jsonBody)) {
            return null;
        }
        String stamp = String.valueOf(System.now().getTime());
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Claude metadata diff (files1) ' + stamp;
        cv.PathOnClient = 'ClaudeMetadataDiff1_' + stamp + '.json';
        cv.VersionData = Blob.valueOf(jsonBody);
        cv.Description = 'LLM JSON from Claude_OrgComparisonViaFiles1.compareSourceAndTargetViaClaude';
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

    private static String resolveApiKey() {
        return ANTHROPIC_API_KEY;
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
        req.setEndpoint(ANTHROPIC_MESSAGES_URL);
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
            throw new ClaudeOrgComparisonViaFiles1Exception('Claude error: ' + JSON.serialize(root.get('error')));
        }
        List<Object> contentBlocks = (List<Object>) root.get('content');
        if (contentBlocks == null || contentBlocks.isEmpty()) {
            throw new ClaudeOrgComparisonViaFiles1Exception('Claude response had no content blocks.');
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
            throw new ClaudeOrgComparisonViaFiles1Exception('Claude returned empty content for metadata diff.');
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
            throw new ClaudeOrgComparisonViaFiles1Exception(
                'Assistant reply was not valid JSON: ' + e.getMessage() + '. Raw: ' + assistantRaw
            );
        }
        return JSON.serialize(parsed);
    }

    private static void logMetadataDiffToDebug(String normalizedJson) {
        System.debug(LoggingLevel.INFO, '=== Claude_OrgComparisonViaFiles1 metadata diff (Groq_POC1_Result shape) ===');
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
