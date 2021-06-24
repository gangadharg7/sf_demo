global class Vitac_CasePeriodicUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
   
    public static string userNamePassword;
    public static String endpoint;
    public static string responseMessage;
    public static string authorizationHeader;
    public static Blob headerValue;
   // public String query='Select id,Status,Samanage_Assigned_To__c,Samanage_Tkt__c from Case where Status == Closed AND Samanage_Tkt__c != Null';
   	public String query = 'Select Id,Status,Samanage_Assigned_To__c,Samanage_Tkt__c from Case Where Status = \'SaManage Ticket - Waiting\' AND Samanage_Tkt__c != null';
    Set<Id> caseids=new Set<Id>();
    
    public static End_Point_Configuration__mdt getEndpointDetails(){
        End_Point_Configuration__mdt endPointRec = [select MasterLabel,DeveloperName,Password__c,UserName__c,URL__c from End_Point_Configuration__mdt where masterLabel='Samanage_Endpoint' LIMIT 1];
        if(endPointRec <> NULL){
            userNamePassword = endPointRec.UserName__c+':'+endPointRec.Password__c;
            headerValue = Blob.valueOf(userNamePassword);
            authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        }
        if(endPointRec <> NULL){
            endpoint=endPointRec.URL__c + '/incidents/';
            System.debug(endpoint);
        }
        return endPointRec;
    }
    
    global Database.QueryLocator start(Database.BatchableContext cntx){
        System.debug('Query String : '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext cntx,List<Case>cases){
        List<Case> updateCases = new List<Case>();
        for (Case checkCase: cases)
        {
            if(checkCase.Samanage_Tkt__c != null){
                System.debug('SaManage Ticket No : '+checkCase.Samanage_Tkt__c);
                try{
                    Vitac_CasePeriodicUpdateBatch.getEndpointDetails();
                    HttpRequest request = new HttpRequest();
                    Http http = new Http();
                    request.setHeader('Authorization', authorizationHeader);
                    request.setHeader('Content-Type', 'application/json');
                    String endpointOrig = endpoint + checkCase.Samanage_Tkt__c + '.json';
                    System.debug('end Point : '+endpointOrig);
                    request.setEndpoint(endpointOrig);
                    request.setMethod('GET');
                    
                    HttpResponse response = http.send(request);
                    System.debug('Response Code : '+response.getStatusCode());
                    if (response.getStatusCode() == 200) {
                        Map<String,Object> mapObj = (Map<String,Object>)System.json.deserializeUntyped(response.getBody());
                       	System.debug('==>>>>'+mapObj);
                        Integer samanageTktNumber = (Integer)mapObj.get('id');
                        String state = (String)mapObj.get('state');
                        System.debug('samanageTktNumber:'+samanageTktNumber +'\n Status: ' + state);
                        if(state=='Closed' || state=='Resolved'){
                            checkCase.Status = 'SaManage Ticket - Resolved';
                        }
                        System.debug('Updated Cases List : ' + checkCase);
            			updateCases.add(checkCase);
                      //  Map<String,Object> AssigneeMap = (Map<String,Object>)resMap.get('assignee');
                      //  System.debug('AssigneeMap:'+AssigneeMap);
                      //  assignedTo=(String)AssigneeMap.get('name');
                      //  System.debug('assignedTo:'+assignedTo);
                    }
                }Catch(Exception e){
                    System.debug('Error:' + e.getMessage());
                }
            }//end if
        }//end for
         System.debug('Update Cases Final List : '+ updateCases);
         update updateCases;
    }
    
    global void finish(Database.BatchableContext cntx){
        System.debug('Finished');
    }
}