/*
 * Created By: Gangadhar G.
 * Created Date: May 24, 2021
 * Description: This class sends the work order details to the RT Manager to create. 
*/

public class RTISIntegrationService {
    
    // This method create/ update/ cancel the work order based on the job id, action code by calling external REST API.
    @future(callout=true)
    public static void createWo(String workOrderId){
        String status = null;
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_RTM_Integration__c) ) return;
            
            if(!String.isBlank(workOrderId)){
                Map<String, Object> authMap = AthenticationUtility.getRtAuthDetails();
                String token = (String)authMap.get('token');
                String endPoint = (String)authMap.get('endPoint');
                
                WorkOrder wo = [SELECT RC_Coord__c,RTMExtId__c, Status, WorkOrderNumber, Airing_Network__c, Subject, StartDate, EndDate, Event_Start_Time__c,RTM_End_Time__c, Event_End_Date__c, Treatment_Sheet__c, Primary_Encoder__c, Primary_Audio__c, Language__c, RTM_Error_Text__c, Submit_Date__c, Cancel_Reason__c, Cancel_Date__c, Purchase_Order_Number__c, RTM_Client_Id__c, Contiguous_Group_ID__c, RTM_STime__c, Default_Billing_Minutes__c, Sport_Weekly__c, Invoicing_Override_Minutes__c, Invoicing_Program_Name__c, SF_Ext_Id__c, LastModifiedDate, Notes__c,Action_Code__c FROM WorkOrder where Id =: workOrderId LIMIT 1];
                String jobId = wo.RTMExtId__c;
                String actionCode = wo.Action_Code__c;
                HttpResponse res = null;
                String methodType = null;
                String jsonBody = '{';
                
                if(jobId == null && wo.Action_Code__c == 'New Order'){
                    jobId = '123456';
                }
                HttpRequest httpReq = new HttpRequest();
                httpReq.setHeader('Authorization', 'Bearer ' + token);
                 httpReq.setTimeout(120000);
                Http httpObj = new Http();
                
                // Cancel Order Block
                if(!String.isBlank(jobId) && actionCode == 'Cancel Order'){
                    methodType = 'DELETE';
                    endpoint += 'api/v1/JobSchedules/' + jobId;
                    httpReq.setEndpoint(endpoint);
                    httpReq.setMethod(methodType);  
                    res = httpObj.send(httpReq);
                    if(res.getStatusCode() == 200){
                    	System.debug('Work Order Cancelled Successfully.');
                        if(cs.Debug_Success_Message__c){
                            new ApexDebugLog().createLog(new ApexDebugLog.Information('RTISIntegrationService','createWo','URL : '+endPoint+',\n'+'Method :' + methodType +' , ' + 'Request Body : NA','Delete Request','Integration','Response Code : '+res.getStatusCode()+',\n'+ 'Response Body : Work Order Cancelled Successfully.','Work Order'));
                        }
                    }else{
                        new ApexDebugLog().createLog(new ApexDebugLog.Error('RTISIntegrationService','createWo','URL : '+endPoint+',\n'+'Method : '+methodType+',\n'+ 'Req Body : NA','Response Code : '+res.getStatusCode()+',\n'+ 'Response Body : '+res.getBody(),'createWo Request','Work Order','Unexpected status code while Cancel the Order'));
                    }
                }else{
                    // Create/Update Order Block
                    // mandatory params start
                    jsonBody += '"clientId":"' + wo.Airing_Network__c + '",';
                    jsonBody += '"stime":"' + wo.RTM_STime__c + '",';
                    jsonBody += '"groupId":"' + wo.Contiguous_Group_ID__c + '",';
                    jsonBody += '"rccoord":"' + wo.RC_Coord__c + '",';
                    jsonBody += '"clientPo":"' + wo.Purchase_Order_Number__c + '",';
                    jsonBody += '"invoicee":"' + wo.RTM_Client_Id__c + '",';
                    jsonBody += '"errorText":"' + wo.RTM_Error_Text__c + '",';
                    jsonBody += '"sportCode":"",';// map the field 
                    jsonBody += '"sportWeekly":"' + wo.Sport_Weekly__c + '",';
                    jsonBody += '"linkedCoverageJobId":"",';// map the field 
                    jsonBody += '"invoicingProgramName":"' + wo.Invoicing_Program_Name__c + '",';
                    jsonBody += '"programName":"' + wo.Subject + '",';

                    // for update
                    String startDate = '', endDate = '', submitDate = '', lastModifiedDate = '', cancelDate = '1999-01-01T12:00:00';//hardcoded for not cancelled
                    
                    if(wo.StartDate != null){
                        Datetime dtTime = wo.StartDate;
                        startDate = DateUtility.formatDateTime(dtTime);             
                    }
                    if(wo.EndDate != null){
                        Datetime dtTime = wo.EndDate;
                        endDate = DateUtility.formatDateTime(dtTime);             
                    }
                    if(wo.Submit_Date__c != null){
                        Datetime dtTime = wo.Submit_Date__c;
                        submitDate = DateUtility.formatDateTime(dtTime);
                    }
                    if(wo.Cancel_Date__c != null){
                        Datetime dtTime = wo.Cancel_Date__c;
                        cancelDate = DateUtility.formatDateTime(dtTime);
                    }
                     if(wo.LastModifiedDate != null){
                        Datetime dtTime = wo.LastModifiedDate;
                        lastModifiedDate = DateUtility.formatDateTime(dtTime);
                    }
                    System.debug('submitDate:' + submitDate);
                    System.debug('cancelDate:' + cancelDate);
                    
                    jsonBody += '"bonusMultiplierId":1,';// default to zero
                    jsonBody += '"rushBasis":"' + submitDate + '",';
                    jsonBody += '"cancelDate":"' + cancelDate +'",';
                    jsonBody += '"recUpdated":"' + lastModifiedDate + '",';
                    jsonBody += '"startTime":"' + startDate+ '",';
                    jsonBody += '"endTime":"' + endDate + '",';
                    jsonBody += '"abtstarttime":"2021-01-15T16:30:00",';// no field in SF
                    jsonBody += '"abtendtime":"2021-01-15T16:35:00",';//no field in SF
                    if(!String.isBlank(jobId)){
                        jsonBody += '"jobId":"' + jobId + '",'; // mandatory param only for update/cancel
                    }
                    // mandatory params end
                    if(wo.Treatment_Sheet__c != null){
                        jsonBody += '"treatmentName":"' + wo.Treatment_Sheet__c + '",';
                    }
                    if(wo.Primary_Encoder__c != null){
                        jsonBody += '"encoderConn":"' + wo.Primary_Encoder__c + '",';
                    }
                    if(wo.Primary_Audio__c != null){
                        jsonBody += '"audioConn":"' + wo.Primary_Audio__c + '",';
                    }
                    if(wo.Language__c != null){
                        jsonBody += '"language":0,';//update in application
                    }
                    if(wo.RTM_STime__c != null){
                        jsonBody += '"stime":"' + wo.RTM_STime__c + '",';
                    }
                    if(wo.Default_Billing_Minutes__c != null){
                        jsonBody += '"defaultBillingMinutes":' + wo.Default_Billing_Minutes__c + ',';
                    }
                    if(wo.Invoicing_Override_Minutes__c != null){
                        jsonBody += '"invoicingOverrideMinutes":' + wo.Invoicing_Override_Minutes__c + ',';
                    }
                    if(wo.SF_Ext_Id__c != null){
                        jsonBody += '"sfId":"' + wo.SF_Ext_Id__c + '",';
                    }
                    if(wo.Notes__c != null){
                        jsonBody += '"jobcomment":"' + wo.Notes__c + '",';
                    }
                    if(wo.Status != null){
                        jsonBody += '"recStatus":"' + wo.Status + '",';
                    }

                   
                    //No Fields in Salesforce - Start
                    jsonBody += '"recLock":"",';
                    jsonBody += '"rcstaff":"",';
                    jsonBody += '"rcstatus":"",';
                    jsonBody += '"rccomment":"",';
                    jsonBody += '"outputFilename":"",';
                    jsonBody += '"category":0,';
                    jsonBody += '"prepTime":0,';
                    jsonBody += '"coverageHours":0,';
                    jsonBody += '"waitTime":0,';
                    jsonBody += '"offlineHours":0,';
                    jsonBody += '"capLocation":0,';
                    jsonBody += '"invoice":0,';
                    jsonBody += '"jobRdy":0,';
                    jsonBody += '"jobExtd":0,';
                    jsonBody += '"jobFin":0,';
                    jsonBody += '"xsheet":0,';
                    jsonBody += '"isExportedToTimesheet":false,';
                    jsonBody += '"isSplitCoverage":false,';
                    jsonBody += '"noBillableTime":false,';
                    jsonBody += '"isFlaggedForReview":false,';
                    jsonBody += '"waitingTimeIsBillable":false,';
                    jsonBody += '"filesSent":false,';  
                    //No Fields in Salesforce - End
                    jsonBody += '"wonumber":"' + wo.WorkOrderNumber + '"}';
                    // json body end
                    System.debug('jsonBody:' + jsonBody);
                    System.debug('jobId:' + jobId);

                    if(!String.isBlank(jobId) && wo.Action_Code__c == 'Update Order'){
                        endPoint += 'api/v1/JobSchedules/' + jobId;
                        methodType = 'PUT';
                    }else{
                        endPoint += 'api/v1/JobSchedules';
                        methodType = 'POST';
                    }
                    //HttpRequest httpReq = new HttpRequest();
                    httpReq.setEndpoint(endpoint);
                    //httpReq.setHeader('Authorization', 'Bearer ' + token);
                    httpReq.setMethod(methodType);  
                    httpReq.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    httpReq.setBody(jsonBody);
                    //httpReq.setTimeout(120000);
                    //Http httpObj = new Http();
                    res = httpObj.send(httpReq);
                    System.debug('Status code:' + res.getStatusCode());
                    String resultSet = res.getBody(); 
                     System.debug('Response body:' + resultSet);
                    if(res.getStatusCode() == 200){
                        Map<String,Object> mapObj = (Map<String,Object>)Json.deserializeUntyped(resultSet);
                        jobId = (String)mapObj.get('jobId');
                        System.debug('jobId:' + jobId);
                        // update jobId in WorkOrder for create operation
                        if(methodType == 'POST'){
                            wo.RTMExtId__c = jobId;
                            upsert wo;
                            System.debug('job id from API:' + jobId);
                        }
                        if(cs.Debug_Success_Message__c){
                            new ApexDebugLog().createLog(new ApexDebugLog.Information('RTISIntegrationService','createWo','URL : '+endPoint+',\n'+'Method :' + methodType +' , ' + 'Request Body :' + jsonBody,'Create/ Update Request','Integration','Response Code : '+res.getStatusCode()+',\n'+ 'Response Body :' + res.getBody(),'Work Order'));
                        }
                    }else{
                        Map<String,Object> mapObj = (Map<String,Object>)Json.deserializeUntyped(resultSet);
                        Map<String,Object> errorMap = (Map<String,Object>)mapObj.get('errors');
                        if(errorMap == NULL){
                            String message = (String)mapObj.get('message');
                            System.debug('Exception while getting the data: ' + message);
                        }
                        System.debug('Exception while getting the data: ' + errorMap);
                        new ApexDebugLog().createLog(new ApexDebugLog.Error('RTISIntegrationService','createWo','URL : '+endPoint+',\n'+'Method : '+methodType+',\n'+ 'Req Body : '+jsonBody,'Response Code : '+res.getStatusCode()+',\n'+ 'Response Body : '+res.getBody(),'createWo Request','Work Order','Unexpected status code while Create/ Update Order'));
                    }
                }
            }
    	}catch(Exception ex){
            // Log API exception details info into the Apex Debug Log
            new ApexDebugLog().createLog(new ApexDebugLog.Error('RTISIntegrationService','createWo', workOrderId, ex,'Work Order','Exception while create/update order Interface.'));
            System.debug('Exception while getting facility details:' + ex.getMessage());
        }
    }
}