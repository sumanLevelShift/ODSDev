/**
 * Groq LLM org comparison using two Salesforce Content Distribution public URLs (not static resources, not file bodies in the prompt).
 * Obtain URLs first via {@link ContentDocumentDistributionService#getDistributionPublicUrl(Id)} in a transaction that only performs DML,
 * then call {@link #compareSourceAndTargetViaContentFileLinks(String, String)} in a separate transaction with only HTTP callouts so the
 * result JSON can be returned synchronously. Shape matches static resource {@value #SR_RESULT_SCHEMA} (same as {@code Groq_JsonKeyCounter}).
 */
public with sharing class Groq_OrgComparisonViaFiles {
    public class GroqOrgComparisonException extends Exception {
    }

    private static final String SR_RESULT_SCHEMA = 'Groq_POC1_Result';

    private static final String GROQ_CHAT_URL = 'https://api.groq.com/openai/v1/chat/completions';
    private static final String GROQ_API_KEY = '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';
    private static final String MODEL_ID = 'llama-3.3-70b-versatile';

    /**
     * @param sourceOrgDistributionPublicUrl SOURCE org JSON — {@code DistributionPublicUrl} (or equivalent public HTTPS URL to the file).
     * @param targetOrgDistributionPublicUrl TARGET org JSON — same.
     * @return Normalized JSON string matching {@value #SR_RESULT_SCHEMA}.
     */
    public static String compareSourceAndTargetViaContentFileLinks(
        String sourceOrgDistributionPublicUrl,
        String targetOrgDistributionPublicUrl
    ) {
        if (String.isBlank(sourceOrgDistributionPublicUrl)) {
            throw new GroqOrgComparisonException('SOURCE distribution public URL is required.');
        }
        if (String.isBlank(targetOrgDistributionPublicUrl)) {
            throw new GroqOrgComparisonException('TARGET distribution public URL is required.');
        }

        String schemaTemplateJson = readPlainStaticResourceAsString(SR_RESULT_SCHEMA);
        if (String.isBlank(schemaTemplateJson)) {
            throw new GroqOrgComparisonException('Static resource ' + SR_RESULT_SCHEMA + ' is missing or empty.');
        }

        return invokeGroqAndNormalize(
            sourceOrgDistributionPublicUrl.trim(),
            targetOrgDistributionPublicUrl.trim(),
            schemaTemplateJson
        );
    }

    private static String invokeGroqAndNormalize(String sourceUrl, String targetUrl, String schemaTemplateJson) {
        String key = resolveApiKey();
        if (String.isBlank(key) || key == 'gsk_REPLACE_WITH_YOUR_KEY') {
            throw new GroqOrgComparisonException('Set GROQ_API_KEY in Groq_OrgComparisonViaFiles to your Groq API key.');
        }

        String systemMsg =
            'You compare two Salesforce org metadata exports. Each export is a JSON document reachable only ' +
            'via HTTPS. SOURCE is the first org snapshot; TARGET is the second org snapshot. ' +
            'You MUST use HTTP GET (or equivalent) on the two URLs provided in the user message to retrieve ' +
            'the raw JSON text (Salesforce Content Distribution public links). ' +
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
            '\n\nBoth URLs are public distribution links; they may expire. ' +
            'Compare the decoded JSON documents and respond with the required summary JSON only.';

        HttpResponse res = postChatCompletion(systemMsg, userMsg);
        if (res.getStatusCode() != 200) {
            throw new GroqOrgComparisonException('Groq HTTP ' + res.getStatusCode() + ': ' + res.getBody());
        }
        String assistantRaw = extractAssistantContent(res.getBody());
        String normalized = parseAndReturnAssistantJson(assistantRaw);
        logGroqResultJsonSizeToDebug(normalized);
        return normalized;
    }

    private static Blob readStaticResourceBlob(String staticResourceName) {
        List<StaticResource> rows = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :staticResourceName
            LIMIT 1
        ];
        if (rows.isEmpty() || rows[0].Body == null) {
            return null;
        }
        return rows[0].Body;
    }

    private static String readPlainStaticResourceAsString(String staticResourceName) {
        Blob body = readStaticResourceBlob(staticResourceName);
        if (body == null || body.size() == 0) {
            return null;
        }
        return body.toString();
    }

    private static String resolveApiKey() {
        return GROQ_API_KEY;
    }

    private static String resolveEndpoint() {
        return GROQ_CHAT_URL;
    }

    private static HttpResponse postChatCompletion(String systemMessage, String userMessage) {
        List<Map<String, Object>> messages = new List<Map<String, Object>>{
            new Map<String, Object>{ 'role' => 'system', 'content' => systemMessage },
            new Map<String, Object>{ 'role' => 'user', 'content' => userMessage }
        };
        Map<String, Object> bodyMap = new Map<String, Object>{
            'model' => MODEL_ID,
            'messages' => messages,
            'temperature' => 0
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint(resolveEndpoint());
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + resolveApiKey());
        req.setBody(JSON.serialize(bodyMap));
        req.setTimeout(120000);

        return new Http().send(req);
    }

    private static String extractAssistantContent(String responseBody) {
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (root.containsKey('error')) {
            throw new GroqOrgComparisonException('Groq error: ' + JSON.serialize(root.get('error')));
        }
        List<Object> choices = (List<Object>) root.get('choices');
        if (choices == null || choices.isEmpty()) {
            throw new GroqOrgComparisonException('Groq response had no choices.');
        }
        Map<String, Object> first = (Map<String, Object>) choices[0];
        Map<String, Object> message = (Map<String, Object>) first.get('message');
        if (message == null) {
            throw new GroqOrgComparisonException('Groq choice had no message.');
        }
        Object content = message.get('content');
        return content == null ? '' : String.valueOf(content).trim();
    }

    private static String parseAndReturnAssistantJson(String assistantRaw) {
        if (String.isBlank(assistantRaw)) {
            throw new GroqOrgComparisonException('Groq returned empty content for metadata diff.');
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
            throw new GroqOrgComparisonException(
                'Assistant reply was not valid JSON: ' + e.getMessage() + '. Raw: ' + assistantRaw
            );
        }
        return JSON.serialize(parsed);
    }

    private static void logGroqResultJsonSizeToDebug(String normalizedJson) {
        Integer byteCount = String.isBlank(normalizedJson) ? 0 : Blob.valueOf(normalizedJson).size();
        System.debug(
            LoggingLevel.INFO,
            'Groq_OrgComparisonViaFiles result JSON (UTF-8) size: ' + formatUtf8ByteSize(byteCount)
        );
    }

    /** Human-readable size: bytes (B) under 1024, then KB, then MB (UTF-8 byte count of the JSON string). */
    private static String formatUtf8ByteSize(Integer byteCount) {
        if (byteCount == null || byteCount < 0) {
            return '0 B';
        }
        if (byteCount < 1024) {
            return String.valueOf(byteCount) + ' B';
        }
        if (byteCount < 1048576) {
            Decimal kb = (Decimal.valueOf(byteCount) / 1024).setScale(2, System.RoundingMode.HALF_UP);
            return String.valueOf(kb) + ' KB';
        }
        Decimal mb = (Decimal.valueOf(byteCount) / 1048576).setScale(2, System.RoundingMode.HALF_UP);
        return String.valueOf(mb) + ' MB';
    }
}