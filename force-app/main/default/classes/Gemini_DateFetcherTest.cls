@IsTest
private class Gemini_DateFetcherTest {
    private class GeminiMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            System.assert(req.getEndpoint().contains('generativelanguage.googleapis.com'));
            System.assert(req.getHeader('x-goog-api-key') != null);
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '{"candidates":[{"content":{"parts":[{"text":" 5th April 2024 "}],"role":"model"},"finishReason":"STOP","index":0}]}'
            );
            return res;
        }
    }

    private class GeminiErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(403);
            res.setBody('{"error":{"code":403,"message":"invalid key","status":"PERMISSION_DENIED"}}');
            return res;
        }
    }

    @IsTest
    static void fetchAndAssignTodaysDate_success() {
        Test.setMock(HttpCalloutMock.class, new GeminiMock());
        Gemini_DateFetcher.apiKeyForTest = 'test-api-key';

        Test.startTest();
        String todaysDate = Gemini_DateFetcher.fetchAndAssignTodaysDate();
        Test.stopTest();

        System.assertEquals('5th April 2024', todaysDate);
    }

    @IsTest
    static void fetchAndAssignTodaysDate_httpError() {
        Test.setMock(HttpCalloutMock.class, new GeminiErrorMock());
        Gemini_DateFetcher.apiKeyForTest = 'test-api-key';

        Test.startTest();
        try {
            Gemini_DateFetcher.fetchAndAssignTodaysDate();
            System.assert(false, 'expected exception');
        } catch (Gemini_DateFetcher.GeminiException e) {
            System.assert(e.getMessage().contains('403'));
        }
        Test.stopTest();
    }

    @IsTest
    static void formatOrdinalDate_knownValues() {
        Date d = Date.newInstance(2024, 4, 5);
        System.assertEquals('5th April 2024', Gemini_DateFetcher.formatOrdinalDate(d));
        System.assertEquals(
            '11th May 2026',
            Gemini_DateFetcher.formatOrdinalDate(Date.newInstance(2026, 5, 11))
        );
    }
}