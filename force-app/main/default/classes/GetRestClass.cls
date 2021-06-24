public with Sharing class GetRestClass {


    
    
        public static HTTPResponse getBlogs() {
        
        
            
            HTTP auth = new HTTP();
String Body = 'userID=salesforce.itsmintegration@vitac.com&password=Caption2#';
HTTPRequest r = new HTTPRequest();
r.setHeader('Content-Type','application/x-www-form-urlenco‌ded');
r.setEndpoint('https://api.samanage.com/incidents.json');
r.setMethod('POST');   
r.setBody(Body);   
HTTPResponse authresp=new HttpResponse();
            System.debug('Line 6:'+authresp.getStatusCode());
authresp = auth.send(r);

        if(authresp.getStatusCode() == 200) {
           System.debug('Succesful');
        }
        return authresp;
    }

}