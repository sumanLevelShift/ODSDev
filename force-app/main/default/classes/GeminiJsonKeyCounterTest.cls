@IsTest
private class GeminiJsonKeyCounterTest {
    private class GeminiOkMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '{"candidates":[{"content":{"parts":[{"text":"3 key-value pairs."}],"role":"model"}}]}'
            );
            return res;
        }
    }

    @IsTest
    static void askCount_returnsModelText() {
        Test.setMock(HttpCalloutMock.class, new GeminiOkMock());
        Test.startTest();
        String out = GeminiJsonKeyCounter.askCount('{"a":1}');
        Test.stopTest();
        System.assert(out.contains('3'));
    }
}