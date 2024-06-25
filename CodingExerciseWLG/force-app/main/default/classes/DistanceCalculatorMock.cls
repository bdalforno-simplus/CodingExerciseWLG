@IsTest
public class DistanceCalculatorMock implements HttpCalloutMock {
    // Implement this interface method
    public HttpResponse respond(HttpRequest req) {
        // Create a new HttpResponse
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        // Define the fake response body
        res.setBody('{' +
            '"destination_addresses": ["400 Broad St, Seattle, WA 98109, USA"],' +
            '"origin_addresses": ["Anaheim, CA 92802, USA"],' +
            '"rows": [{' +
                '"elements": [{' +
                    '"distance": {"text": "1160 mi", "value": 1866836},' + 
                    '"duration": {"text": "17 hours 45 mins", "value": 63900}' + 
                '}]' + 
            '}],' +
            '"status": "OK"' +
        '}');
        
        return res;
    }
}