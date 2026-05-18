@IsTest
private class Gemini_POC1Test {
    private static String wrapGeminiTextResponse(String modelText) {
        return '{"candidates":[{"content":{"parts":[{"text":' +
            JSON.serialize(modelText) +
            '}],"role":"model"},"finishReason":"STOP","index":0}]}';
    }

    private class FieldExtractMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assert(req.getEndpoint().contains('generativelanguage.googleapis.com'));
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String modelJson = '{"fieldApiNames":["Id","DeveloperName","Status","Type","Id","Name","ActionId"]}';
            res.setBody(wrapGeminiTextResponse(modelJson));
            return res;
        }
    }

    private class SimpleTextMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(wrapGeminiTextResponse('hello from model'));
            return res;
        }
    }

    @IsTest
    static void extractFieldApiNamesFromJsonString_success() {
        Gemini_POC1.apiKeyForTest = 'test-key';
        Gemini_POC1.snapshotJsonForTest = '{"objects":[{"fields":[{"apiName":"X__c"}]}]}';
        Test.setMock(HttpCalloutMock.class, new FieldExtractMock());

        Test.startTest();
        List<String> names = Gemini_POC1.extractFieldApiNamesFromJsonString(
            Gemini_POC1.snapshotJsonForTest
        );
        String jsonOut = Gemini_POC1.extractFieldApiNamesJsonResponseFromJsonString(
            Gemini_POC1.snapshotJsonForTest
        );
        Test.stopTest();

        System.assertEquals(7, names.size());
        System.assert(jsonOut.contains('fieldApiNames'));
        System.assert(jsonOut.contains('DeveloperName'));
    }

    @IsTest
    static void generateText_success() {
        Gemini_POC1.apiKeyForTest = 'test-key';
        Test.setMock(HttpCalloutMock.class, new SimpleTextMock());

        Test.startTest();
        String t = Gemini_POC1.generateText('ping');
        Test.stopTest();

        System.assertEquals('hello from model', t);
    }

    @IsTest
    static void generateText_noApiKey_returnsHint() {
        Gemini_POC1.apiKeyForTest = null;
        Gemini_POC1.simulateMissingApiKey = true;
        Test.setMock(HttpCalloutMock.class, new SimpleTextMock());

        Test.startTest();
        String t = Gemini_POC1.generateText('ping');
        Test.stopTest();

        System.assert(t.contains('Gemini_API_Key'));
    }
}