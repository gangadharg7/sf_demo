public class Vitac_RestOBUtilities{
    private String IntegrationName{get;set;}
    private static String URL;
    private String Parameters{get;set;}
    private static String Method;
    private static String AuthToken;
    private boolean Asynch;
    private static String RequestBody; 
    
    //Constructor to get the Data from Custom Metadata Type and also initialise the request JSON
    public Vitac_RestOBUtilities(String IntegrationName, String Request)
    {
        RequestBody = Request;
        getMetadata(IntegrationName);
    }
    
    public void handleRequest()
    {
        switch on Method{
            when 'Get' {
            }
            when 'Post' {
                postRequest();
            }
                
        }
    }
    
    //Query the Custom Metadata and retrieve the parameters needed to make an external call
    private void getMetadata(String IntegrationName)
    { 
      List<Vitac_Integration__mdt> restMetaData = [SELECT Method__c,Log_JSON__c,Asyncrhonous__c FROM Vitac_Integration__mdt WHERE DeveloperName = :IntegrationName ];
      Method = restMetaData[0].Method__c;

        
    }
    
    private void postRequest()
    {
        if(Asynch)
            postASynchRequest();
        else
            postSynchRequest();
    }

    private void postSynchRequest()
    { 
       sendPostRequest(); 
        
    }
    
    @future(callout=true)
    private static void postASynchRequest()
    { 
           sendPostRequest();
        
    } 
    
    private static void sendPostRequest()
    {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(URL);
            request.setMethod(Method);
            request.setHeader('Authorization', 'Bearer ' + AuthToken);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(120000);
            
            //request.setHeader('callingsystem', 'Salesforce');
            // Set the body as a JSON object
            request.setBody(RequestBody);
            System.debug('reqBody :::' + RequestBody);
            HttpResponse response = http.send(request); 
    }       
      
}