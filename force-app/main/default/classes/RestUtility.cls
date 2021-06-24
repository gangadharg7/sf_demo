public class RestUtility {

    @future (callout=true)
    public Static void postAPICall(String endPoint, String param1,String param2,String param3){
        System.debug('param1 ===>:' + param1);
        HttpRequest requestParam = new HttpRequest();
        Integer statusCode = null;
        try{
            //getEndpointDetails();
            String authorizationHeader = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRldkBldmVyZ2UuY29tIiwicm9sZSI6IlN0YW5kYXJkIiwibmJmIjoxNjIxNDkyOTM4LCJleHAiOjE2MjE0OTY1MzgsImlhdCI6MTYyMTQ5MjkzOH0.AOPmjz-uaVD-TYkvZPAgkbZRXJXUvwK-gttJX6ViaX0';
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            if(String.isEmpty(param1)){ 
                gen.WriteStringField('jobId', param1);
            }            
            gen.writeEndObject();
            String jsonString = (String)gen.getAsString();
            system.debug('jsonString:'+jsonString);
            requestParam.setEndpoint(endPoint);
            system.debug('endpoint:'+endpoint);
            requestParam.setHeader('Content-Type', 'application/json;charset=UTF-8');
            requestParam.setHeader('Authorization', authorizationHeader);
            requestParam.setMethod('POST');
            requestParam.setBody(jsonString);
            System.debug('Payload:'+jsonString);
            Http httpObj = new Http();
            
            HttpResponse res = httpObj.send(requestParam);
            System.debug('Status code:'+res.getStatusCode());
            statusCode = res.getStatusCode();
            if(res.getStatusCode() == 200){
                String resultSet=res.getBody();
                System.JSONParser jp=JSON.createParser(resultSet);
                While(jp.nextToken()!=null){
                    
                }
            }  
        }Catch(Exception e){
            System.debug('Exception while calling post API:'+e.getMessage());
        }
        //return requestParam;
    }
}