/**
 * Groq Cloud API (OpenAI-compatible chat completions). Configure Custom Label Groq_API_Key.
 * {@link #fetchAndAssignTodaysDate()} asks Groq for today's date and returns it as {@code todaysDate}
 * (represents "today's date"; Apex identifiers cannot contain apostrophes), e.g. 5th April 2024.
 */
public with sharing class Groq_DateFetcher {
    public class GroqException extends Exception {
    }

    private static final String CHAT_COMPLETIONS_URL =
        'https://api.groq.com/openai/v1/chat/completions';
    /** Groq model id (see Groq console docs for current ids). */
    private static final String MODEL_ID = 'llama-3.3-70b-versatile';

    @TestVisible
    private static String apiKeyForTest;

    /**
     * Calls Groq with "What is the date today", parses the assistant reply, and returns the formatted
     * calendar string assigned to the conceptual "today's date" value ({@code todaysDate}).
     */
    public static String fetchAndAssignTodaysDate() {
        String todaysDate;
        String systemText =
            'You answer with only the calendar date in this exact pattern: ' +
            'the day with an English ordinal suffix (st, nd, rd, th), a space, the full month name in English, ' +
            'a space, and the four-digit year. Example: 5th April 2024. No other words or punctuation.';
        HttpResponse res = executeGroqChatRequest(systemText, 'What is the date today');
        if (res.getStatusCode() != 200) {
            throw new GroqException(
                'Groq HTTP ' + res.getStatusCode() + ': ' + res.getBody()
            );
        }
        todaysDate = extractAssistantContent(res.getBody());
        todaysDate = postProcessDateText(todaysDate);
        System.debug(LoggingLevel.INFO, 'today\'s date (formatted): ' + todaysDate);
        return todaysDate;
    }

    private static HttpResponse executeGroqChatRequest(String systemMessage, String userMessage) {
        String apiKey = resolveApiKey();
        if (String.isBlank(apiKey)) {
            throw new GroqException(
                'Set Custom Label Groq_API_Key (Setup → Custom Labels) to your Groq API key ' +
                '(replace the default placeholder value).'
            );
        }
        List<Map<String, Object>> messages = new List<Map<String, Object>>{
            new Map<String, Object>{ 'role' => 'system', 'content' => systemMessage },
            new Map<String, Object>{ 'role' => 'user', 'content' => userMessage }
        };
        Map<String, Object> bodyMap = new Map<String, Object>{
            'model' => MODEL_ID,
            'messages' => messages,
            'temperature' => 0
        };
        String jsonBody = JSON.serialize(bodyMap);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(CHAT_COMPLETIONS_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + apiKey);
        req.setBody(jsonBody);
        req.setTimeout(120000);

        return new Http().send(req);
    }

    private static final String PLACEHOLDER_API_KEY_LABEL = 'REPLACE_ME';

    private static String resolveApiKey() {
        if (Test.isRunningTest() && String.isNotBlank(apiKeyForTest)) {
            return apiKeyForTest;
        }
        String key = System.Label.Groq_API_Key;
        if (String.isBlank(key) || key == PLACEHOLDER_API_KEY_LABEL) {
            return null;
        }
        return key;
    }

    private static String extractAssistantContent(String responseBody) {
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (root.containsKey('error')) {
            throw new GroqException('Groq error payload: ' + JSON.serialize(root.get('error')));
        }
        List<Object> choices = (List<Object>) root.get('choices');
        if (choices == null || choices.isEmpty()) {
            throw new GroqException('Groq response had no choices.');
        }
        Map<String, Object> first = (Map<String, Object>) choices[0];
        Map<String, Object> message = (Map<String, Object>) first.get('message');
        if (message == null) {
            throw new GroqException('Groq choice had no message.');
        }
        Object content = message.get('content');
        return content == null ? '' : String.valueOf(content).trim();
    }

    private static String postProcessDateText(String raw) {
        if (String.isBlank(raw)) {
            return formatOrdinalDate(Date.today());
        }
        String cleaned = raw.replace('"', '').trim();
        if (String.isBlank(cleaned)) {
            return formatOrdinalDate(Date.today());
        }
        return cleaned;
    }

    /** Fallback / local formatting: e.g. 11th May 2026 */
    public static String formatOrdinalDate(Date d) {
        Integer day = d.day();
        String ord = ordinalSuffix(day);
        String monthName = monthNameEnglish(d.month());
        return String.valueOf(day) + ord + ' ' + monthName + ' ' + String.valueOf(d.year());
    }

    private static String ordinalSuffix(Integer day) {
        if (day >= 11 && day <= 13) {
            return 'th';
        }
        Integer m = Math.mod(day, 10);
        if (m == 1) {
            return 'st';
        }
        if (m == 2) {
            return 'nd';
        }
        if (m == 3) {
            return 'rd';
        }
        return 'th';
    }

    private static String monthNameEnglish(Integer monthNum) {
        List<String> names = new List<String>{
            '',
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
        };
        if (monthNum == null || monthNum < 1 || monthNum > 12) {
            return '';
        }
        return names[monthNum];
    }
}