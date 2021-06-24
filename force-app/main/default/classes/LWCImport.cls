public with sharing class LWCImport {
    @AuraEnabled
    public static String readCSVFile(Id idContentDocument){
        List<SObject> lstWO = new List<SObject>(); 
        //holds list of WorkOrderLineItem
        List<SObject> lstWlineItems = new List<SObject>(); 
        //final list for insertion
        SObject[] sobjList = new List<SObject>(); 
        String strInsertError = '';

        //holds WorkOrderId and External Id in a Map
        Map<String,String> WoWLineItemMap = new Map<String,String>();
        String tempExt = '';

        if(idContentDocument != null) {
            
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

            for(Integer i = 1; i < lstCSVLines.size(); i++){
                WorkOrder WorkOrderObj = new WorkOrder(); 
    
                list<String> csvRowData = lstCSVLines[i].split(',');
                System.debug('csvRowData====> '+csvRowData);
                WorkOrderObj.Invoicee_Name__c = csvRowData[2]; //Invoicee
                WorkOrderObj.Subject = csvRowData[4]; //Program Name
                WorkOrderObj.Airing_Network__c = csvRowData[3]; //Client
                WorkOrderObj.Time_Zone__c = 'America/New_York'; //TimeZone default to EST API Name: America/New_York
                String csvDuration = csvRowData[6];//Duration
                String[] arrDuration     = csvDuration.split(':');
                Integer duration = Integer.valueOf(arrDuration[0]) * 60 + Integer.valueOf(arrDuration[1]);
				String action = csvRowData[18];
                if(action == 'Add'){
                    WorkOrderObj.Action_Code__c = 'New Order';
                }
                else if(action == 'Delete'){
                    WorkOrderObj.Action_Code__c = 'Cancel Order';
                }
                else{
                    WorkOrderObj.Action_Code__c = 'New Order';
                }
                WorkOrderObj.Duration = duration;
                WorkOrderObj.DurationType = 'Minutes';
                WorkOrderObj.RTM_Length__c = String.valueOf(duration); //Text
				WorkOrderObj.Event_Start_Date__c = date.parse(csvRowData[0]);
                String TimeString = csvRowData[5];
                String Regex      = '(\\d{1,2}):(\\d{1,2}) ([PA]M)';
                Pattern p         = Pattern.compile( Regex );
                Matcher m         = p.matcher( TimeString );
                if ( m.matches() ){
                    Integer Hours = Integer.valueOf( m.group(1) );
                    Integer Minutes = Integer.valueOf( m.group(2) );
                    String PmShiftString = m.group(3);
                    Integer PmShifting;
                    if(PmShiftString == 'PM'){
                        Hours= Hours+12 ;
                    }
                    WorkOrderObj.Event_Start_Time__c = Time.newInstance( Hours , Minutes , 0 , 0 );           
                }
                else {
                    WorkOrderObj.Event_Start_Time__c = Time.newInstance(10,30,0,0); 
                }

                tempExt = csvRowData[7]+String.ValueOf(Integer.valueOf(math.rint(math.random()*1000000)));
                WorkOrderObj.VSSExtId__c = tempExt; //Change it later based on unique key. This is only for POC

                //WoWLineItemMap.put(WorkOrderObj.AccountId,WorkOrderObj.VSSExtId__c); // add to map

                lstWO.add(WorkOrderObj);
                //WorkOrderLineItemObj.PricebookEntryId =csvRowData[7];

                WorkOrder woReference = new WorkOrder(
                    VSSExtId__c =tempExt); 
                system.debug('Size '+csvRowData.size());
                for(Integer iLine = 42; iLine < 47 && iLine < csvRowData.size(); iLine++){
                    String deliverable=csvRowData[iLine];
                    if(deliverable.trim() != ''){
                    	WorkOrderLineItem WorkOrderLineItemObj = new WorkOrderLineItem(); 
                		WorkOrderLineItemObj.WorkOrder = woReference; 
                    	WorkOrderLineItemObj.RTM_Category__c =csvRowData[41];
                		WorkOrderLineItemObj.RTM_Language__c =csvRowData[40];
                    	WorkOrderLineItemObj.RTMExtId__c = csvRowData[iLine];
                 		lstWlineItems.add(WorkOrderLineItemObj);
                    }  
                }
 
            }
            //add WorkOrder and WorkOrderLineItem list
            sobjList.addAll(lstWO);
            sobjList.addAll(lstWlineItems);

            try{    
                if(!sobjList.isEmpty()) {
                    Database.SaveResult[] results = Database.insert(sobjList);
                    //insert sobjList;
                    for (Integer i = 0; i < results.size(); i++) {
                        if (results[i].isSuccess()) 
                        {
                        System.debug('Successfully created ID: ' + results[i].getId());
                        strInsertError=strInsertError+' Result '+i+': '+results[i].getId()+'\n';
                        } 
                        else 
                        {
                         System.debug('Error: could not create sobject ' + 'for array element ' + i + '.');
                         strInsertError = 'The error reported was: ' + results[i].getErrors()[0].getMessage() + '\n';
                         System.debug(strInsertError);
                        }
                      } 
                      System.debug('strInsertError=' + strInsertError);
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } 
        }
        return strInsertError;    
    }
}