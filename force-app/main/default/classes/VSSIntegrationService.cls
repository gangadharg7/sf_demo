//Satheesh Bojanapu
//Date: 05/21/2021
//Draft: For making VSS interface calls. All the methods were added here
public class VSSIntegrationService {
    @future(callout=true)
    public static void createWo(String recordId){
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_VSS_Integration__c) ) return;
        createWoData(recordId);
    }
    public static string createWoData(String workOrderId) {
        String strOperation = 'validate Order - ';
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_VSS_Integration__c) ) return'Custom Setting Disabled';
            String responseMessage = 'Started';
            WorkOrder wo=[SELECT Id,VSSExtId__c,Destroy_Transcript_After_Event__c,Participant_Can_Save_Transcript__c,Participant_Can_View_Transcript__c,ServiceContractId,recordType.DeveloperName,Site__c,Account.VSS_Ext_ID__c,Subject,StartDate,EndDate,Time_Zone__c,Additional_Contact_Email__c,Primary_Facility_Id__c,Secondary_Facility_Id__c,Notes__c,TV_Rating__c,Send_Confirmation__c,Conference_Access_Code__c,Conference_Phone__c,Conference_URL__c,Conference_Password__c,Purchase_Order_Number__c,Booking_Contact_Name__c,Booking_Contact_Phone__c,Booking_Contact_Email__c,DoA_Contact_Name__c,DoA_Contact_Phone__c,DoA_Contact_Email__c,Caption_URL__c,Channel__c,View_URL__c,API_Token__c,Delay_In_Seconds__c,Two_Way__c,Participant_Options__c,Transcript_Retention__c FROM WorkOrder WHERE Id= :workOrderId Limit 1];
            WorkOrderLineItem WOLI = [SELECT Service_Contract_Category__c,Record_Count__c,Instructions_for_Delivery__c,Description,Delivery_Method__c,Contract_Line_Item__c,VSS_Service_Type_Id__c,Billing_Service_Contract__c FROM WorkOrderLineItem WHERE WorkOrderId=: workOrderId Limit 1];
            List<End_Point_Configuration__mdt> vssMetaData = [SELECT URL__c,Bearer_Token__c FROM End_Point_Configuration__mdt WHERE DeveloperName = 'VSS_Endpoint' ];            
          //  Contact con = [SELECT FirstName, LastName, Email, Phone FROM Contact WHERE Id=: wo.Booking_Contact__c];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String validateURL=vssMetaData[0].URL__c+'/api/order/validate';
            string requetMethod='POST';
            string reqBody;
            DateTime stDate = wo.StartDate;
            DateTime endDate = wo.EndDate;
            system.debug('StartDate : '+ stDate + '\nEnd Date : '+ endDate);
      //      if(wo.RecordType.DeveloperName=='GV_Realtime' || (wo.RecordType.DeveloperName=='Teleconference' && wo.Site__c == 'GV')){
                request.setEndpoint(validateURL);
                request.setMethod(requetMethod);
                //Standard Message
            	reqBody = '{';
                if(wo.TV_Rating__c != null){
                    reqBody += '"vChipRating": "' + wo.TV_Rating__c + '",';
                }
            	else{
                    reqBody += '"vChipRating": "NONE",';
                }
                if(wo.Account.VSS_Ext_ID__c != null){
                    reqBody += '"customerCode": "' + wo.Account.VSS_Ext_ID__c + '",';
                }else{
                    reqBody += '"customerCode": null,';
                }
            
                if(wo.Primary_Facility_Id__c != null){
                    reqBody += '"primaryFacilityId": "' + wo.Primary_Facility_Id__c + '",';
                }else{
                    reqBody += '"primaryFacilityId": null,';
                }
                if(WOLI.VSS_Service_Type_Id__c != null){
                	reqBody +=  '"serviceId": ' + WOLI.VSS_Service_Type_Id__c + ',';    
                }
                if(wo.Notes__c != null){
                    reqBody +=  '"notes": "' + wo.Notes__c + '",';
                }

            	if(wo.Subject != null){
                    reqBody += '"description": "' + wo.Subject + '",';
                }
            	if(stDate != null){
                    reqBody += '"startTime": "' + stDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '",';
                }
            	if(endDate != null){
                    reqBody += '"endTime": "' + endDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '",';
                }
            	if(wo.Secondary_Facility_Id__c != null){
                    reqBody +='"secondaryFacilityId": ' + wo.Secondary_Facility_Id__c + ',';
                }

                //Non-Tv Message
                reqBody +=  '"groupTag": "",';
            	if(wo.Additional_Contact_Email__c != null){
                     reqBody += '"additionalEmailRecipients": "' + wo.Additional_Contact_Email__c + '",';
                }
                if(wo.Conference_Access_Code__c != null){
                    reqBody += '"conferenceAccessCode": "' + wo.Conference_Access_Code__c + '",';
                }               
                if(wo.Conference_Phone__c != null){
                	reqBody += '"conferenceCallNumber": "' + wo.Conference_Phone__c + '",';
                }
                if(wo.Conference_URL__c != null){
                	reqBody += '"conferenceUrl": "' + wo.Conference_URL__c + '",';    
                }
                if(wo.Conference_Password__c != null){
                    reqBody += '"conferencePassword": "' + wo.Conference_Password__c + '",';
                }
            	if(wo.Purchase_Order_Number__c != null){
                    reqBody += '"costCenter": "' + wo.Purchase_Order_Number__c + '",';
                }
                
                reqBody += '"bookingContactInfo": {';
            	//reqBody = reqBody + '"lastName": "' + wo.Booking_Contact_Name__c + '",';
            	reqBody += '"lastName": "TEST LN Only",';// update the payloade for dynamic data
            	if(wo.Booking_Contact_Name__c != null){
                    reqBody +='"firstName": "' + wo.Booking_Contact_Name__c + '",';
                }
            	if(wo.Booking_Contact_Phone__c != null){
                    reqBody +=  '"phoneNumber": "' + wo.Booking_Contact_Phone__c + '",';
                }
                if(wo.Booking_Contact_Email__c != null){
                    reqBody += '"emailAddress": "' + wo.Booking_Contact_Email__c + '"';
                }else{
                    reqBody += '"emailAddress": null';
                }
                reqBody += '},';
                
                reqBody += '"dayOfAirContactInfo": {';
             	reqBody += '"lastName": "TEST LN Only",';// update the payloade for dynamic data
                //reqBody = reqBody + '"lastName": "' + wo.DoA_Contact_Name__c + '",';
                if(wo.DoA_Contact_Name__c != null){
                	reqBody += '"firstName": "' + wo.DoA_Contact_Name__c + '",';    
                }
            	if(wo.DoA_Contact_Phone__c != null){
                    reqBody += '"phoneNumber": "' + wo.DoA_Contact_Phone__c + '",';
                }
                if(wo.DoA_Contact_Email__c != null){
                    reqBody += '"emailAddress": "' + wo.DoA_Contact_Email__c + '"';
                }else{
                    reqBody += '"emailAddress": null';
                }
               	reqBody += '},';
                //StreamText
                 /* Anupama commented as streamtext is on hold as of now
                reqBody = reqBody + '"adobeIntegration": false,';//boolean
                reqBody = reqBody + '"delayInSeconds": null,';//Integer
                reqBody = reqBody + '"eventName": "",';
                reqBody = reqBody + '"eventPassword": "",';
                reqBody = reqBody + '"streamTextUrl": "",';
                reqBody = reqBody + '"streamTextWriter": "",';
                reqBody = reqBody + '"requireLogin": false,';//boolean
                reqBody = reqBody + '"loginParticipants": "",';
                reqBody = reqBody + '"webPlayer": false,';//boolean
                reqBody = reqBody + '"youTubeIntegration": false,';//boolean
                reqBody = reqBody + '"youTubeCaptionUrl": "",';
                reqBody = reqBody + '"zoomIntegration": false,';//boolean
                reqBody = reqBody + '"zoomCaptionUrl": "",';*/
            
                //Youtube
                if(wo.Caption_URL__c != null){
                    reqBody +=  '"captionUrl": "' + wo.Caption_URL__c + '",';
                }
            	if(wo.Channel__c != null){
                    reqBody += '"channel": "' + wo.Channel__c + '",';
                }
            	if(wo.View_URL__c != null){
                    reqBody += '"viewUrl": "' + wo.View_URL__c + '",';
                }
            	if(wo.API_Token__c != null){
                    reqBody += '"youTubeApiToken": "' + wo.API_Token__c + '",';
                }
                
                //ICS
                if(wo.Two_Way__c != null){
                    reqBody += '"twoWay": ' + wo.Two_Way__c + ',';//boolean
                }
            	reqBody += '"transcriptDetails": {';
            	if(wo.Participant_Can_Save_Transcript__c != null)
            		reqBody += '"participantCanSave": ' + wo.Participant_Can_Save_Transcript__c;//boolean
            	else
                    reqBody += '"participantCanSave": false';
            	if(wo.Destroy_Transcript_After_Event__c != null){
                    reqBody += ',';
                    reqBody += '"destroyAfterward": ' + wo.Destroy_Transcript_After_Event__c;//boolean
                }
            if(wo.Participant_Can_View_Transcript__c != null){
                reqBody += ',';
                reqBody +='"participantCanView": ' + wo.Participant_Can_View_Transcript__c ;//boolean
            }
            reqBody += '},';
            	if(wo.Time_Zone__c != null){
                	reqBody += '"timeZone": "' + wo.Time_Zone__c + '",';    
                }
            if(wo.Send_Confirmation__c != null)
                reqBody += '"sendConfirmationEmail": ' + wo.Send_Confirmation__c;
            else
               	reqBody += '"sendConfirmationEmail": false'; // mandatory param
            	reqBody += '}';//end of payload
                
            	request.setHeader('Authorization', 'Bearer '+vssMetaData[0].Bearer_Token__c);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                // Set the body as a JSON object
                system.debug('Req Body :: ' + reqBody);
                request.setBody(reqBody);
                request.setTimeout(120000);
                HttpResponse response = http.send(request);
                system.debug('response.getStatusCode() :: '+response.getStatusCode());
                system.debug('Response Body :: '+response.getBody());
                responseMessage = 'validate order call status : ' + response.getStatus();
                if(response.getStatusCode() == 200){
                    String resultSet = response.getBody();               
                    Map<String,Object> mapObj = (Map<String,Object>)Json.deserializeUntyped(resultSet);
                    Boolean isValidFlag = (Boolean)mapObj.get('isValid');
                    system.debug('isValidFlag:' + isValidFlag);
                    if(isValidFlag){
                        string createURL = vssMetaData[0].URL__c+'/api/order/create';
                        system.debug('create URL : '+ createURL);
                        HttpRequest req = new HttpRequest();
                        req.setEndpoint(createURL);
                        req.setMethod('POST');
                        req.setHeader('Authorization', 'Bearer '+vssMetaData[0].Bearer_Token__c);
                        req.setHeader('Content-Type', 'application/json');
                        req.setHeader('Accept', 'application/json');
                        // Set the body as a JSON object
                        req.setBody(reqBody);
                        req.setTimeout(120000);
                        strOperation = 'create Order - ';
                        HttpResponse createResp = http.send(req);
                        system.debug('createResponse.getStatusCode() :: '+createResp.getStatusCode());
                        system.debug('Create Response Body :: '+createResp.getBody());
                        responseMessage = 'create order call status : ' + response.getStatus();
                        if(createResp.getStatusCode() == 201){
                            if(cs.Debug_Success_Message__c)
                                new ApexDebugLog().createLog(new ApexDebugLog.Information('VSSIntegrationService','createWoData','URL : '+createURL+',\n'+'Method : '+requetMethod+',\n'+ 'Req Body : '+reqBody,'createWoData Request','Integration','Response Code : '+createResp.getStatusCode()+',\n'+ 'Response Body : '+createResp.getBody(),'Work Order'));
                            Map<String,Object> eventObj = (Map<String,Object>)Json.deserializeUntyped(createResp.getBody());
                            Integer eventId = (Integer)eventObj.get('id');
                            system.debug('eventId:' + eventId);
                            wo.VSSExtId__c=string.valueof(eventId);
                            update wo;
                            
                            // Call the Flow to send out mail on successful interface call
                            Map<String, Object> params = new Map<String, Object>();
                            params.put('WorkOrderId', wo.Id);
                         //   params.put('WOLIs', WOLI);
                         //   new ApexDebugLog().createLog(new ApexDebugLog.Information('VSSIntegrationService','createWoData_MailConfirmation','Work Order Record Set Parameter : '+wo+',\n'+ 'Work Order Line Record Set Parameter : '+WOLI,'Parameters to the flow','Integration','Send_Work_Order_Email Flow Successfully called','Work Order'));
                            System.debug('Parameters being Passed =>>> '+ params);
                            Flow.Interview.Send_Work_Order_Email sendMail = new Flow.Interview.Send_Work_Order_Email(params);
                            sendMail.start();
                            
                        }//end of if for success log
                        else{
                            new ApexDebugLog().createLog(new ApexDebugLog.Error('VSSIntegrationService','createWoData','URL : '+createURL+',\n'+'Method : '+requetMethod+',\n'+ 'Req Body : '+reqBody,'Create Response Code : '+createResp.getStatusCode()+',\n'+ 'Create Response Body : '+createResp.getBody(), 'createWoData Request', 'Work Order', strOperation + 'unexpected status code on order interface'));
                        }//end of else for apex debug log error
                    }//end of valid response call
                  //Apex Debug Log
                  if(cs.Debug_Success_Message__c)
                   	new ApexDebugLog().createLog(new ApexDebugLog.Information('VSSIntegrationService','createWoData','URL : '+validateURL+',\n'+'Method : '+requetMethod+',\n'+ 'Req Body : '+reqBody,'validateWoData Request','Integration','Response Code : '+response.getStatusCode()+',\n'+ 'Response Body : '+response.getBody(),'Work Order'));
                }//end of success response of validate method
                else{
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('VSSIntegrationService','createWoData','URL : '+validateURL+',\n'+'Method : '+requetMethod+',\n'+ 'Req Body : '+reqBody,'Response Code : '+response.getStatusCode()+',\n'+ 'Response Body : '+response.getBody(),'createWoData Request','Work Order', strOperation + 'Unexpected status code on Order interface'));
                }
          //  }//Record type close
            return responseMessage;
        }
        catch(Exception Ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VSSIntegrationService','createWoData', workOrderId, Ex,'Work Order', strOperation + 'Exception on validate/create order Interface.'));
            return Ex.getmessage();
        }
    }
@future(callout=true)
public static void updateWo(String recordId){
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_VSS_Integration__c) ) return;
        updateWoData(recordId);
    }
    public static string updateWoData(String workOrderId) {
        try{
            Metadata_Control__c cs = Metadata_Control__c.getInstance();
            if(cs != null && (cs.Disable_All__c || cs.Disable_VSS_Integration__c) ) return'Custom Setting Disabled';
            String responseMessage = 'Started';
            WorkOrder wo=[SELECT Id,VSSExtId__c,Destroy_Transcript_After_Event__c,Participant_Can_Save_Transcript__c,Participant_Can_View_Transcript__c,ServiceContractId,recordType.DeveloperName,Site__c,Account.VSS_Ext_ID__c,Subject,StartDate,EndDate,Time_Zone__c,Additional_Contact_Email__c,Primary_Facility_Id__c,Secondary_Facility_Id__c,Notes__c,TV_Rating__c,Send_Confirmation__c,Conference_Access_Code__c,Conference_Phone__c,Conference_URL__c,Conference_Password__c,Purchase_Order_Number__c,Booking_Contact_Name__c,Booking_Contact_Phone__c,Booking_Contact_Email__c,DoA_Contact_Name__c,DoA_Contact_Phone__c,DoA_Contact_Email__c,Caption_URL__c,Channel__c,View_URL__c,API_Token__c,Delay_In_Seconds__c,Two_Way__c,Participant_Options__c,Transcript_Retention__c FROM WorkOrder WHERE Id= :workOrderId Limit 1];
            WorkOrderLineItem WOLI = [SELECT VSS_Service_Type_Id__c FROM WorkOrderLineItem WHERE WorkOrderId=: workOrderId];
            List<End_Point_Configuration__mdt> vssMetaData = [SELECT URL__c,Bearer_Token__c FROM End_Point_Configuration__mdt WHERE DeveloperName = 'VSS_Endpoint' ];            
          //  Contact con = [SELECT FirstName, LastName, Email, Phone FROM Contact WHERE Id=: wo.Booking_Contact__c];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String updateURL=vssMetaData[0].URL__c+'/api/order/update';
            string requetMethod='POST';
            string reqBody;
            DateTime stDate = wo.StartDate;
            DateTime endDate = wo.EndDate;
            system.debug('StartDate : '+ stDate + '\nEnd Date : '+ endDate);
      //      if(wo.RecordType.DeveloperName=='GV_Realtime' || (wo.RecordType.DeveloperName=='Teleconference' && wo.Site__c == 'GV')){
                request.setEndpoint(updateURL);
                request.setMethod(requetMethod);
                //Standard Message
                reqBody = '{';
                //reqBody = '{"vChipRating":"TV-14/VS",';
             	if(wo.TV_Rating__c != null){
                    reqBody += '"vChipRating": "' + wo.TV_Rating__c + '",';
                }else{
                    reqBody += '"vChipRating": "NONE",';
                }
                reqBody +='"eventId": "' + wo.VSSExtId__c + '",';//mandatory
               	if(wo.Account.VSS_Ext_ID__c != null){
                    reqBody += '"customerCode": "' + wo.Account.VSS_Ext_ID__c + '",';
                }else{
                    reqBody += '"customerCode": null,';
                }
            	if(WOLI.VSS_Service_Type_Id__c != null){
                    reqBody += '"serviceId": ' + WOLI.VSS_Service_Type_Id__c + ',';
                }
             	//reqBody = reqBody + '"serviceId": 1,';
                if(wo.Notes__c != null){
                    reqBody +='"notes": "' + wo.Notes__c + '",';
                }
                if(wo.Subject != null){
                    reqBody += '"description": "' + wo.Subject + '",';
                }
                if(stDate != null){
                    reqBody += '"startTime": "' + stDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '",';
                }
            	if(endDate != null){
                    reqBody += '"endTime": "' + endDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '",';
                }
            	if(wo.Primary_Facility_Id__c != null){
                    reqBody +='"primaryFacilityId": ' + wo.Primary_Facility_Id__c + ',';
                }
                
            	if(wo.Secondary_Facility_Id__c != null){
                    reqBody +='"secondaryFacilityId": ' + wo.Secondary_Facility_Id__c + ',';
                }
                //Non-Tv Message
                reqBody += '"groupTag": "",';
               	if(wo.Additional_Contact_Email__c != null){
                     reqBody += '"additionalEmailRecipients": "' + wo.Additional_Contact_Email__c + '",';
                }                
            	if(wo.Conference_Access_Code__c != null){
                    reqBody += '"conferenceAccessCode": "' + wo.Conference_Access_Code__c + '",';
                }               
                if(wo.Conference_Phone__c != null){
                	reqBody += '"conferenceCallNumber": "' + wo.Conference_Phone__c + '",';
                }
                if(wo.Conference_URL__c != null){
                	reqBody += '"conferenceUrl": "' + wo.Conference_URL__c + '",';    
                }
                if(wo.Conference_Password__c != null){
                    reqBody += '"conferencePassword": "' + wo.Conference_Password__c + '",';
                }
            	if(wo.Purchase_Order_Number__c != null){
                    reqBody += '"costCenter": "' + wo.Purchase_Order_Number__c + '",';
                }                
           		reqBody += '"bookingContactInfo": {';
            	//reqBody = reqBody + '"lastName": "' + wo.Booking_Contact_Name__c + '",';
            	reqBody += '"lastName": "TEST LN Only",';// update the payloade for dynamic data
            	if(wo.Booking_Contact_Name__c != null){
                    reqBody +='"firstName": "' + wo.Booking_Contact_Name__c + '",';
                }
            	if(wo.Booking_Contact_Phone__c != null){
                    reqBody +=  '"phoneNumber": "' + wo.Booking_Contact_Phone__c + '",';
                }
                if(wo.Booking_Contact_Email__c != null){
                    reqBody += '"emailAddress": "' + wo.Booking_Contact_Email__c + '"';
                }else{
                    reqBody += '"emailAddress": null';
                }
                reqBody += '},';
            
            	reqBody += '"dayOfAirContactInfo": {';
             	reqBody += '"lastName": "TEST LN Only",';// update the payloade for dynamic data
                //reqBody = reqBody + '"lastName": "' + wo.DoA_Contact_Name__c + '",';
                if(wo.DoA_Contact_Name__c != null){
                	reqBody += '"firstName": "' + wo.DoA_Contact_Name__c + '",';    
                }
            	if(wo.DoA_Contact_Phone__c != null){
                    reqBody += '"phoneNumber": "' + wo.DoA_Contact_Phone__c + '",';
                }
                if(wo.DoA_Contact_Email__c != null){
                    reqBody += '"emailAddress": "' + wo.DoA_Contact_Email__c + '"';
                }else{
                    reqBody += '"emailAddress": null';
                }
               	reqBody += '},';
            
                //StreamText
               /* reqBody = reqBody + '"adobeIntegration": false,';//boolean
                reqBody = reqBody + '"delayInSeconds": null,';//Integer
                reqBody = reqBody + '"eventName": "",';
                reqBody = reqBody + '"eventPassword": "",';
                reqBody = reqBody + '"streamTextUrl": "",';
                reqBody = reqBody + '"streamTextWriter": "",';
                reqBody = reqBody + '"requireLogin": false,';//boolean
                reqBody = reqBody + '"loginParticipants": "",';
                reqBody = reqBody + '"webPlayer": false,';//boolean
                reqBody = reqBody + '"youTubeIntegration": false,';//boolean
                reqBody = reqBody + '"youTubeCaptionUrl": "",';
                reqBody = reqBody + '"zoomIntegration": false,';//boolean
                reqBody = reqBody + '"zoomCaptionUrl": "",';*/
                //Youtube
                if(wo.Caption_URL__c != null){
                    reqBody +=  '"captionUrl": "' + wo.Caption_URL__c + '",';
                }
            	if(wo.Channel__c != null){
                    reqBody += '"channel": "' + wo.Channel__c + '",';
                }
            	if(wo.View_URL__c != null){
                    reqBody += '"viewUrl": "' + wo.View_URL__c + '",';
                }
            	if(wo.API_Token__c != null){
                    reqBody += '"youTubeApiToken": "' + wo.API_Token__c + '",';
                }
                //ICS
                if(wo.Two_Way__c != null){
                    reqBody += '"twoWay": ' + wo.Two_Way__c + ',';//boolean
                }
                reqBody += '"transcriptDetails": {';
            	if(wo.Participant_Can_Save_Transcript__c != null)
            		reqBody += '"participantCanSave": ' + wo.Participant_Can_Save_Transcript__c;//boolean
            	else
                    reqBody += '"participantCanSave": false';
            	if(wo.Destroy_Transcript_After_Event__c != null){
                    reqBody += ',';
                    reqBody += '"destroyAfterward": ' + wo.Destroy_Transcript_After_Event__c;//boolean
                }
                if(wo.Participant_Can_View_Transcript__c != null){
                    reqBody += ',';
                    reqBody +='"participantCanView": ' + wo.Participant_Can_View_Transcript__c ;//boolean
                }
                reqBody += '},';
                reqBody += '"timeZone": "' + wo.Time_Zone__c + '",';
            	if(wo.Send_Confirmation__c != null)
                    reqBody += '"sendConfirmationEmail": ' + wo.Send_Confirmation__c;
            	else
                    reqBody += '"sendConfirmationEmail": false';
            	reqBody += '}';//end of payload
                request.setHeader('Authorization', 'Bearer '+vssMetaData[0].Bearer_Token__c);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                // Set the body as a JSON object
                system.debug('Req Body :: '+reqBody);
                request.setBody(reqBody);
                request.setTimeout(120000);
                HttpResponse response = http.send(request);
                system.debug('response.getStatusCode() :: '+response.getStatusCode());
                system.debug('Response Body :: '+response.getBody());
                responseMessage = 'update order call status : ' + response.getStatus();
                if(response.getStatusCode() == 200){
                    String resultSet = response.getBody();               
                    Map<String,Object> mapObj = (Map<String,Object>)Json.deserializeUntyped(resultSet);
                    //Apex Debug Log
                    if(cs.Debug_Success_Message__c)
                    	new ApexDebugLog().createLog(new ApexDebugLog.Information('VSSIntegrationService','updateWoData','URL : '+updateURL+',\n'+'Method : '+requetMethod+',\n'+ 'Req Body : '+reqBody,'updateWoData Request','Integration','Response Code : '+response.getStatusCode()+',\n'+ 'Response Body : '+response.getBody(),'Work Order'));
                }//end of success response of validate method
                else{
                    new ApexDebugLog().createLog(new ApexDebugLog.Error('VSSIntegrationService','updateWoData','URL : '+updateURL+',\n'+'Method : '+requetMethod+',\n'+ 'Req Body : '+reqBody,'Response Code : '+response.getStatusCode()+',\n'+ 'Response Body : '+response.getBody(),'updateWoData Request','Work Order','update Order - Unexpected status code on update Order'));
                }
         //   }//Record type close
            return workOrderId;
        }
        catch(Exception Exupd){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VSSIntegrationService','updateWoData', workOrderId, Exupd,'Work Order','update Order - Exception on update order Interface.'));
            return Exupd.getmessage();
        }
    }//update function closed
    
@future(callout=true)
public static void cancelWo(String recordId, String extId, String custId){
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_VSS_Integration__c) ) return;
        cancelWoData(recordId, extId, custId);
    }
    public static string cancelWoData(String WorkOrderId, String VssExtId, String AccountId) {
        try{
            // Check Integration Switch settings, if disabled then go back 
        	Metadata_Control__c cs = Metadata_Control__c.getInstance();
        	if(cs != null && (cs.Disable_All__c || cs.Disable_VSS_Integration__c) ) return 'custom settings enabled';
            List<End_Point_Configuration__mdt> vssMetaData = [SELECT URL__c,Bearer_Token__c FROM End_Point_Configuration__mdt WHERE DeveloperName = 'VSS_Endpoint' ];            
            Account acc = [SELECT Name, VSS_Customer_Id__c,VSS_Ext_ID__c FROM Account WHERE Id=: AccountId];
            system.debug('Account Name : ' + acc.Name + 'Account Ext Id : ' + acc.VSS_Customer_Id__c);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String cancelURL=vssMetaData[0].URL__c+'/api/order/cancel';
            string requetMethod='POST';
            string reqBody;
            reqBody = '{"EventId": "' + VssExtId + '",';
            reqBody = reqBody + '"customerCode": "' + acc.VSS_Ext_ID__c + '"}';
            request.setEndpoint(cancelURL);
            request.setMethod(requetMethod);
            request.setHeader('Authorization', 'Bearer '+vssMetaData[0].Bearer_Token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            // Set the body as a JSON object
            request.setBody(reqBody);
            request.setTimeout(120000);
            system.debug('Request Body : ' + reqBody);
            HttpResponse response = http.send(request);
            system.debug('response code : ' + response.getStatusCode() + '\nresponse Message : ' + response.getBody());
            if(response.getStatusCode()==200){
               //Apex Debug Log
               if(cs.Debug_Success_Message__c)
               		new ApexDebugLog().createLog(new ApexDebugLog.Information('VSSIntegrationService','cancelWoData','URL : '+ cancelURL +',\n'+'Method : '+requetMethod+',\n'+ 'Req Body : '+reqBody,'cancelWoData Request','Integration','Response Code : '+response.getStatusCode()+',\n'+ 'Response Body : '+response.getBody(),'Work Order'));
            }
            else{
                new ApexDebugLog().createLog(new ApexDebugLog.Error('VSSIntegrationService','cancelWoData','URL : '+cancelURL+',\n'+'Method : '+requetMethod+',\n'+ 'Req Body : '+reqBody,'Response Code : '+response.getStatusCode()+',\n'+ 'Response Body : '+response.getBody(),'cancelWoData Request','Work Order','cancel Order - Unexpected status code on cancel Order'));
            }
            return workOrderId;
        }
        catch(Exception ExCanc){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('VSSIntegrationService','cancelWoData', workOrderId, ExCanc,'Work Order','cancel Order - Exception on cancel order Interface.'));
            return ExCanc.getmessage();
        }
    }//cancel function closed
}