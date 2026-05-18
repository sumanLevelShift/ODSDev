@IsTest
private class Groq_DateFetcherTest {
    private class GroqMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            System.assert(req.getEndpoint().contains('api.groq.com'));
            System.assert(req.getHeader('Authorization') != null);
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '{"choices":[{"message":{"role":"assistant","content":" 5th April 2024 "},"finish_reason":"stop","index":0}],"model":"llama-3.3-70b-versatile"}'
            );
            return res;
        }
    }

    private class GroqErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401);
            res.setBody('{"error":{"message":"invalid api key"}}');
            return res;
        }
    }

    @IsTest
    static void fetchAndAssignTodaysDate_success() {
        Test.setMock(HttpCalloutMock.class, new GroqMock());
        Groq_DateFetcher.apiKeyForTest = 'gsk-test-key';

        Test.startTest();
        String todaysDate = Groq_DateFetcher.fetchAndAssignTodaysDate();
        Test.stopTest();

        System.assertEquals('5th April 2024', todaysDate);
    }

    @IsTest
    static void fetchAndAssignTodaysDate_httpError() {
        Test.setMock(HttpCalloutMock.class, new GroqErrorMock());
        Groq_DateFetcher.apiKeyForTest = 'gsk-test-key';

        Test.startTest();
        try {
            Groq_DateFetcher.fetchAndAssignTodaysDate();
            System.assert(false, 'expected exception');
        } catch (Groq_DateFetcher.GroqException e) {
            System.assert(e.getMessage().contains('401'));
        }
        Test.stopTest();
    }

    @IsTest
    static void formatOrdinalDate_knownValues() {
        Date d = Date.newInstance(2024, 4, 5);
        System.assertEquals('5th April 2024', Groq_DateFetcher.formatOrdinalDate(d));
        System.assertEquals(
            '11th May 2026',
            Groq_DateFetcher.formatOrdinalDate(Date.newInstance(2026, 5, 11))
        );
    }
}