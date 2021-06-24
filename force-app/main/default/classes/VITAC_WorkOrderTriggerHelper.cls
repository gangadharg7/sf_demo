public class VITAC_WorkOrderTriggerHelper {
    private static VITAC_WorkOrderTriggerHelper woHelperInstance = null;
    
    //Static method that returns the instance of the WorkOrderTriggerHelper class.
    //This will avoid creating multiple instances of the same object 
    public static VITAC_WorkOrderTriggerHelper getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(woHelperInstance == null) woHelperInstance = new VITAC_WorkOrderTriggerHelper();
        return woHelperInstance;
    }
    
    //Thiis method is used to update the OOTB Start and End Date based on what user provides for Start Date, Duration and TimeZone
    public void updateDates(){
        List<WorkOrder> newWOList = (List<WorkOrder>)Trigger.new;
        //List<WorkOrder> oldWOList = (List<WorkOrder>)Trigger.oldMap;

        for(WorkOrder wo: newWOList)
            {
                //Datetime startDt = wo.StartDt_Time__c;
                Datetime startDt = Datetime.newInstance(wo.Event_Start_Date__c, wo.Event_Start_Time__c); 
                string strTZ = wo.Time_Zone__c;
                startDt = startDt.addSeconds(UserInfo.getTimeZone().getOffset(startDt)/1000);
                startDt = startDt.addSeconds(-(TimeZone.getTimeZone(strTZ).getOffset(startDt))/1000);                
                wo.StartDate = startDt;
                if(wo.DurationType == 'Hours'){
                    wo.EndDate = startDt.addMinutes((wo.Duration*60).intValue());
                }
                else {
                    wo.EndDate = startDt.addMinutes((wo.Duration).intvalue());
                }
                
                  //get string in EST 24 hour format
                  string workDt = wo.StartDate.format('yyyy-MM-dd HH:mm', 'America/New_York');
                  string strTimeEST = workDt.substring(11,16);
                  wo.RTM_MTime__c = strTimeEST;
                  string strHourValue = strTimeEST.substring(0,2);
                  string strMinute = strTimeEST.substring(3,5);
                  
                  string strStationValue;
                  
                  switch on strHourValue {
                   when '00' {
                       strStationValue = '24';
                       }
                   when '01' {
                       strStationValue = '25';
                       }
                   when '02' {
                       strStationValue = '26';
                       }
                   when '03' {
                       strStationValue = '27';
                       }
                   when else {
                       strStationValue = strHourValue;
                       }
                    }
                  strStationValue = strStationValue + ':' + strMinute;
                  wo.RTM_STime__c = strStationValue;
 
                  //get number of Hours in decimal foramt
                  decimal decSeconds = (wo.EndDate.getTime()-wo.StartDate.getTime())/1000;
                  decimal decHours = ((decSeconds/60)/60);
                  wo.RTM_Hours__c = decHours;
  
                  integer intHours = math.mod(math.floor(decSeconds/3600).intValue(),24); //number of hours
                  integer intMinutes = math.mod(math.floor(decSeconds/60).intValue(),60); //number of minutes
                  wo.RTM_Length__c = '' + intHours + ':' + ('0'+ intMinutes).right(2); 
                  
                  //get string in AM/PM EST format
                  workDt = wo.StartDate.format('yyyy-MM-dd hh:mm a', 'America/New_York');
                  strTimeEST = workDt.substring(11,19);    
                  wo.RTM_Time__c = strTimeEST;

                  //get string in AM/PM EST format
                  workDt = wo.EndDate.format('yyyy-MM-dd hh:mm a', 'America/New_York');
                  strTimeEST = workDt.substring(11,19);    
                  wo.RTM_End_Time__c = strTimeEST;
                  
                  //check for setting cancel date
                  //oldWOList
            
                  //WorkOrder oldWO = Trigger.oldMap.get(wo.Id);
                  /*
                  string oldStatus = oldWO.Status;
                  string newStatus = wo.Status;
                  if ((newStatus == 'Canceled' || newStatus == 'Canceled24') && (oldStatus != 'Canceled' && oldStatus != 'Canceled24')) {
                      if(wo.Cancel_Date__c == null){
                          wo.Cancel_Date__c = system.now();
                      }
                  }
                  */
            }
    }

    //This method is used to default values
    public void setDefaults(){
        List<WorkOrder> newWOList = (List<WorkOrder>)Trigger.new;
        for(WorkOrder wo: newWOList) {
            if(wo.SF_Ext_Id__c == null){
               //wo.SF_Ext_Id__c = 'WO-' + getUUID();
            }
            if(wo.Submit_Date__c == null){
               wo.Submit_Date__c = system.now();
            }
        }
    }
    public void closeWOMileStone(){
        //if (UserInfo.getUserType() == 'Standard'){
        List<WorkOrder> workOrders = (List<WorkOrder>)Trigger.new;
        DateTime completionDate = System.now();
        List<Id> updateWOs = new List<Id>();
        for (WorkOrder w : workOrders){
            if (((w.Status == 'Assigned' || w.Status == 'Canceled'))&&((w.SlaStartDate <= completionDate)&&(w.SlaExitDate == null)))
                updateWOs.add(w.Id);
           
        }
        if (updateWOs.isEmpty() == false) {
            VITAC_WOMilestoneUtils.completeMilestone(updateWOs, 'Guarantee Notice Accepted', completionDate);
            VITAC_WOMilestoneUtils.completeMilestone(updateWOs, 'Guarantee Notice Expired', completionDate);
        } 
    
        //}
    }    
    public void updateAccount(){
        List<WorkOrder> newWOList = (List<WorkOrder>)Trigger.new;
        
        // Collect the value of Invoicee Name in a Set
        Set<String> setInvoiceeName = new Set<String>();
        for(WorkOrder wo : newWOList) {
            // Collect only if InvoiceeName is not null
            if (wo.Invoicee_Name__c != null) {
                setInvoiceeName.add(wo.Invoicee_Name__c);
            }
 
        }
        
       // When there are InvoiceeNames
        if (setInvoiceeName.size() > 0) {
            // Create a Map of setInvoiceeName to Service Contract
            Map<String, ServiceContract> mapInvoiceeNameToServiceContract = new Map<String, ServiceContract>();
            for (ServiceContract servContact : [SELECT Id, AccountId, Name, Pricebook2Id FROM ServiceContract WHERE Name IN :setInvoiceeName]) {
                mapInvoiceeNameToServiceContract.put(servContact.Name, servContact);
            }

         // When there is data in the Map
            if (mapInvoiceeNameToServiceContract.size() > 0) {
                // for each WorkOrder set the Account, Service Contract and PriceBook field
                for(WorkOrder wo : newWOList) {
                    // Set only if InvoiceeName is not null
                    if (wo.Invoicee_Name__c != null) {
                        ServiceContract servContract = mapInvoiceeNameToServiceContract.get(wo.Invoicee_Name__c);
                        if (servContract != null) {
                            wo.AccountId = servContract.AccountId;
                            wo.ServiceContractId = servContract.Id;
                            wo.Pricebook2Id = servContract.Pricebook2Id;
                        }
                    }
                }
            }                
        }
    } 
    
    public static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }    
       
}