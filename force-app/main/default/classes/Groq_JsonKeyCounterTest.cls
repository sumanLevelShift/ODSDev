@IsTest
private class Groq_JsonKeyCounterTest {
    private class GroqDualMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            System.assert(req.getEndpoint().contains('chat/completions'));
            System.assert(req.getBody().contains('SOURCE JSON'));
            System.assert(req.getBody().contains('TARGET JSON'));
            String assistantCounts = '{"Source":80,"Target":70}';
            Map<String, Object> msg = new Map<String, Object>{
                'role' => 'assistant',
                'content' => assistantCounts,
                'finish_reason' => 'stop',
                'index' => 0
            };
            Map<String, Object> choice = new Map<String, Object>{ 'message' => msg };
            String body = JSON.serialize(new Map<String, Object>{ 'choices' => new List<Object>{ choice } });
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(body);
            return res;
        }
    }

    @IsTest
    static void countSourceAndTargetKeyPairsViaGroq_success() {
        Test.setMock(HttpCalloutMock.class, new GroqDualMock());
        Groq_JsonKeyCounter.apiKeyForTest = 'gsk-test';
        Groq_JsonKeyCounter.endpointForTest = 'https://api.groq.com/openai/v1/chat/completions';
        Groq_JsonKeyCounter.useDualJsonOverride = true;
        Groq_JsonKeyCounter.testSourceJson = '{"a":1,"b":2}';
        Groq_JsonKeyCounter.testTargetJson = '{"x":1}';
        Test.startTest();
        String countsJson = Groq_JsonKeyCounter.countSourceAndTargetKeyPairsViaGroq();
        Test.stopTest();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(countsJson);
        System.assertEquals(80, m.get('Source'));
        System.assertEquals(70, m.get('Target'));
    }

    @IsTest
    static void countSourceAndTargetKeyPairsViaGroq_blankTarget_throws() {
        Groq_JsonKeyCounter.useDualJsonOverride = true;
        Groq_JsonKeyCounter.testSourceJson = '{}';
        Groq_JsonKeyCounter.testTargetJson = '';
        try {
            Groq_JsonKeyCounter.countSourceAndTargetKeyPairsViaGroq();
            System.assert(false, 'expected exception');
        } catch (Groq_JsonKeyCounter.GroqJsonException e) {
            System.assert(e.getMessage().contains('Gemini_POC1_Target'));
        }
    }

    @IsTest
    static void countKeyValuePairs_flatObject() {
        Groq_JsonKeyCounter.useDualJsonOverride = false;
        String answer = Groq_JsonKeyCounter.countKeyValuePairs('{"a":1,"b":2,"c":3}');
        System.assertEquals('3', answer);
    }

    @IsTest
    static void countKeyValuePairs_nestedObject() {
        String answer = Groq_JsonKeyCounter.countKeyValuePairs('{"x":1,"y":{"z":2}}');
        System.assertEquals('3', answer);
    }

    @IsTest
    static void countKeyValuePairs_arrayOfObjects() {
        String answer = Groq_JsonKeyCounter.countKeyValuePairs('[{"a":1},{"b":2}]');
        System.assertEquals('2', answer);
    }

    @IsTest
    static void countKeyValuePairs_blankJson_throws() {
        try {
            Groq_JsonKeyCounter.countKeyValuePairs('');
            System.assert(false, 'expected exception');
        } catch (Groq_JsonKeyCounter.GroqJsonException e) {
            System.assert(e.getMessage().contains('required'));
        }
    }

    @IsTest
    static void countKeyValuePairs_invalidJson_throws() {
        try {
            Groq_JsonKeyCounter.countKeyValuePairs('{not json');
            System.assert(false, 'expected exception');
        } catch (Groq_JsonKeyCounter.GroqJsonException e) {
            System.assert(e.getMessage().contains('Invalid JSON'));
        }
    }

    @IsTest
    static void countKeyValuePairs_fromStaticResource_usesTestOverride() {
        Groq_JsonKeyCounter.useJsonBodyOverride = true;
        Groq_JsonKeyCounter.jsonBodyForTest = '{"objects":[{"apiName":"X","fieldCount":1}]}';
        Test.startTest();
        String answer = Groq_JsonKeyCounter.countKeyValuePairs();
        Test.stopTest();
        System.assertEquals('3', answer);
    }

    @IsTest
    static void countKeyValuePairs_noArg_missingResource_throws() {
        Groq_JsonKeyCounter.useJsonBodyOverride = true;
        Groq_JsonKeyCounter.jsonBodyForTest = '';
        try {
            Groq_JsonKeyCounter.countKeyValuePairs();
            System.assert(false, 'expected exception');
        } catch (Groq_JsonKeyCounter.GroqJsonException e) {
            System.assert(e.getMessage().contains('missing or empty'));
        }
    }
}