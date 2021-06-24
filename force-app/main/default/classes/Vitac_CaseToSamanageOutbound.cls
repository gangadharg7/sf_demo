global class Vitac_CaseToSamanageOutbound {
    
    public static case cs;
    public static string userNamePassword;
    public static String endpoint;
    public static string responseMessage;
    public static string authorizationHeader;
    public static Blob headerValue;
    public static string samanageTktNumber;
    public static string ExternalNumber;
    public static String state;
    public Static String assigneeId; 
    public static String assignedTo;
    public static String integartionUser=userInfo.getUserId();
    
    public static End_Point_Configuration__mdt getEndpointDetails(){
        
        End_Point_Configuration__mdt endPointRec = [select MasterLabel,DeveloperName,Password__c,UserName__c,URL__c from End_Point_Configuration__mdt where masterLabel='Samanage_Endpoint' LIMIT 1];
        if(endPointRec <> NULL){
            userNamePassword = endPointRec.UserName__c+':'+endPointRec.Password__c;
            headerValue = Blob.valueOf(userNamePassword);
            authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        }
        if(endPointRec <> NULL){
            endpoint=endPointRec.URL__c + '/incidents.json';
            System.debug(endpoint);
        }
        System.debug('END POINT:'+endPointRec);
        return endPointRec;
    }
    
    public void caseDetailsReq(List<Case> csRec ){
        Case cs = csRec[0];
        System.debug('cs:=====>' + cs);
        calltoSamanage(cs.id,cs.Subject,cs.Description,cs.Status,cs.Priority,cs.Type,cs.Sub_Type__c,cs.Site__c,cs.Comments,cs.Samanage_Assigned_To__c,cs.Samanage_Tkt__c);
    }
    
    @future (callout=true)
    global Static void calltoSamanage(String caseId,String Subject,String Description, String Priority,String Status,String Type,String SubType,String Site,String Comments,String integrationUsr, String SamanageTicketNumber){
       
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        
        System.debug('caseId ===>:' + caseId);
        HttpRequest requestParam = new HttpRequest();
        try{
            getEndpointDetails();
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            if(Subject <> NULL){
                gen.WriteStringField('name', Subject);
            }
            if(Description <> NULL){
                gen.WriteStringField('Description', Description);
            }
            if(Priority <> NULL){
                gen.WriteStringField('Status', Priority);
            }
            if(Status <> NULL){
                gen.WriteStringField('Priority', Status);
            }
            if(Type <> NULL){
                gen.WriteStringField('category ', Type);
            }
            if(SubType <> NULL){
                gen.WriteStringField('subcategory', SubType);
            }
            if(Site <> NULL){
                gen.WriteStringField('site', Site);
            }
            if(Comments <> NULL){
                gen.WriteStringField('Comments', Comments);
            }
            if(integartionUser <> NULL){
                gen.WriteStringField('requester', integartionUser);
            }
            if(SamanageTicketNumber <> NULL){
                gen.WriteStringField('SamanageTicketNumber', SamanageTicketNumber);
            }
            gen.writeEndObject();
            String jsonString = (String)gen.getAsString();
            
            requestParam.setEndpoint(endpoint);
            
            requestParam.setHeader('Content-Type', 'application/json;charset=UTF-8');
            requestParam.setHeader('Authorization', authorizationHeader);
            
            requestParam.setMethod('POST');
            requestParam.setBody(jsonString);
            System.debug('jsonString:'+jsonString);
            System.debug('endpoint:'+endpoint);
            System.debug('authorizationHeader:'+authorizationHeader);
            
            Http httpObj = new Http();
            
            HttpResponse res = httpObj.send(requestParam);
            System.debug('Status code:'+res.getStatusCode());
            
            if(res.getStatusCode()==200){
                
                String resultSet=res.getBody();
                System.debug('ResultSet:'+resultSet);
                
                Map<String,Object> resMap = (Map<String,Object>)Json.deserializeUntyped(resultSet);
                System.debug('==>>>>'+resMap);
                Integer ExternalNumber = (Integer)resMap.get('number');
                System.debug('samanageTktNumber:'+ExternalNumber);
                Integer samanageTktNumber = (Integer)resMap.get('id');
                System.debug('samanageTktId:'+samanageTktNumber);
                Map<String,Object> AssigneeMap = (Map<String,Object>)resMap.get('assignee');
                System.debug('AssigneeMap:'+AssigneeMap);
                assignedTo=(String)AssigneeMap.get('name');
                System.debug('assignedTo:'+assignedTo);

                if(samanageTktNumber != null || assignedTo != null){
                    updateToCase(samanageTktNumber, caseId, assignedTo, ExternalNumber);
                    sendAttachment(caseId);
                    
                    //send the attachment to samanage
                   	
                    if(cs.Debug_Success_Message__c){
                        System.debug('Log Success Message into Apex Debug Log');
                        new ApexDebugLog().createLog(new ApexDebugLog.Information('Vitac_CaseToSamanageOutbound','calltoSamanage','URL : '+endPoint+',\n'+'Method :' + 'POST' +' , ' + 'Request Body :' + jsonString,'Update Case Status','Integration','Response Code : '+res.getStatusCode()+',\n'+ 'Response Body :' + res.getBody(),'Case'));
                    }
                    return;
                } 
            }       

        }Catch(Exception e){
            System.debug('Exception while calling calltoSamanage API:'+e.getMessage());
            new ApexDebugLog().createLog(new ApexDebugLog.Error('Vitac_CaseToSamanageOutbound','calltoSamanage', caseId, e,'SAManage Case Update','Exception while updating case status from SA Manage to Salesforce.'));
        }
    }
    
    public class assignee{
        public String name;
    }
    
    global static void updateToCase(Integer samanageTktNumber, String caseId, String assignedTo, Integer ExternalNumber){
        
        System.debug('=======Update Case Object========');
        HttpResponse result = new HttpResponse();
        List<Case> caseList = [Select Id,Samanage_Tkt__c,Samanage_Assigned_To__c, Subject, Samanage_External_Id__c from Case where Id =: caseId];
        if(caseList.size() > 0){
            Case caseObj = caseList[0];
            caseObj.Samanage_Tkt__c = String.valueOf(samanageTktNumber);
            caseObj.Samanage_External_Id__c = String.valueOf(ExternalNumber);
            caseObj.Samanage_Assigned_To__c = assignedTo;
            update caseObj;
            System.debug('Case Asignee Status Updated Successfully. Case Id:' + caseId);
        }
    } 
    
    public static void sendAttachment(String caseId){
        System.debug('send attachment block');
        try{
            ContentDocumentLink cdl = [SELECT ContentDocumentId, Id FROM ContentDocumentLink WHERE LinkedEntityId =: caseId ];
            String ContentDocumentId = cdl.ContentDocumentId;
            
            System.debug('ContentDocumentId:' + ContentDocumentId);
            if(ContentDocumentId != null){
                ContentVersion cv = [SELECT FileExtension,Title,VersionData FROM ContentVersion WHERE ContentDocumentId =: ContentDocumentId];
                String FileExtension = cv.FileExtension;
                String Title = cv.Title;
                Blob VersionData = cv.VersionData;
                String versionTemp = EncodingUtil.base64Encode(VersionData);
                System.debug('versionTemp:' + versionTemp);
                Blob fileContentBlob = EncodingUtil.base64Decode(versionTemp);
                //System.debug('fileContent:' + fileContentBlob.toString());
                
                Blob fileBlob = Blob.valueof(fileContentBlob.toString());
               	Submit(Title, 'text/plain', fileBlob);
               	//WebserviceHelper.uploadFiles(fileContentBlob);
               
            }
        }catch(Exception e){
            System.debug('Exception:' + e);
        }
    }
    
    public static HttpResponse Submit(String fileName, String fileMimeType, blob fileBlob) {
        HttpResponse response = new HttpResponse();
        System.debug('Submit method');
        try {
            getEndpointDetails();
            string contentType = vNHttpFormBuilder.GetContentType();
            //string json = GetJson(request, Credentials);
    		System.debug('Step 1');
            //  Compose the form
            string form64 = '';
           
            form64 += vNHttpFormBuilder.WriteBoundary();
            form64 += vNHttpFormBuilder.WriteBodyParameter('file[attachable_type]', 'Incident');
            form64 += vNHttpFormBuilder.WriteBoundary();
            form64 += vNHttpFormBuilder.WriteBodyParameter('file[attachable_id]', '73513274');
            form64 += vNHttpFormBuilder.WriteBoundary();
            //form64 += vNHttpFormBuilder.WriteBodyParam(cd, fileBlob);

           	vNHttpFormBuilder.WriteFileResult result = vNHttpFormBuilder.WriteFile('file', 'a2.txt', 'text/plain', fileBlob);
            form64 += result.Content;
            form64 += vNHttpFormBuilder.WriteBoundary(result.EndingType);
    
            //Blob formBlob = Blob.valueof(form64);
           
           blob formBlob = EncodingUtil.base64Decode(form64);
            System.debug('formBlob:' + formBlob);
            string contentLength = string.valueOf(formBlob.size());
    		System.debug('Step 3');
            //  Compose the http request
            HttpRequest httpRequest = new HttpRequest();
    		httpRequest.setHeader('Content-Type','multipart/form-data');
            httpRequest.setHeader('Authorization', authorizationHeader);
            httpRequest.setBodyAsBlob(formBlob);
            httpRequest.setEndpoint('https://api.samanage.com/attachments.json');
            httpRequest.setHeader('Connection', 'keep-alive');
            httpRequest.setHeader('Content-Length', contentLength);
           // httpRequest.setHeader('Content-Type', contentType);
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);
    		System.debug('Step 4');
            Http httpObject = new Http();
            response = httpObject.send(httpRequest);
    		System.debug('Step 5');
            System.debug('Status code:' + response.getStatusCode());
            System.debug('Response body:' + response.getBody());
            return response;
        } catch (Exception e) {
            System.debug('Exception:' + e);
        }
        return response;
    }
    
    public static void uploadFile(Attachment file){
          String boundary = '__boundary__xxx';
          String header = '--'+boundary+'n'
             + 'Content-Disposition: form-data; name="data"; filename="'+file.name
             +'"nContent-Type: application/octet-streamnn';
         
          String footer = 'n--'+boundary+'--';
           
          String body = EncodingUtil.base64Encode(file.Body); //encodes the blob into a base64 encoded String
           
          body = header + body + footer;
           
          HttpRequest req = new HttpRequest();
          req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
          req.setMethod('POST');
          req.setEndpoint('https://api.samanage.com/attachments.json');   //COOL site to test form uploads
          req.setBody(body);
          req.setTimeout(60000);
          req.setHeader('Content-Length',String.valueof(body.length()));
          req.setHeader('Authorization', 'Basic c2FsZXNmb3JjZS5pdHNtaW50ZWdyYXRpb25Adml0YWMuY29tOmVWZXJnZUAxMjM=');
           
          Http http = new Http();
          HttpResponse httpRes = http.send(req);
          System.debug('httpRes.getStatusCode():' + httpRes.getStatusCode());
      		//return http.send(req);
     }
}