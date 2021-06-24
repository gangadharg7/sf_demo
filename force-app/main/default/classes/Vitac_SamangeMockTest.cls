@istest
global class Vitac_SamangeMockTest implements HttpCalloutMock{
	
    global static HTTPResponse respond(HttpRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id": 71021002,"number": 63276,"name": "Test 7","description": null,"description_no_html": "","state": "New","priority": "Low","category": null,"subcategory": null,}');
        res.setStatusCode(200);
        return res;
    }
}