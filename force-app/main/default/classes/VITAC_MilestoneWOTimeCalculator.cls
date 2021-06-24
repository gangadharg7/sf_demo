global class VITAC_MilestoneWOTimeCalculator implements Support.MilestoneTriggerTimeCalculator {   
     global Integer calculateMilestoneTriggerTime(String workOrderId, String milestoneTypeId){

        system.debug('test => ' + VITAC_WorkOrderTriggerHandler.lstNewAux);
        if (VITAC_WorkOrderTriggerHandler.lstNewAux != null){
            Map<Id, WorkOrder> mapCase = new Map<Id, WorkOrder>(VITAC_WorkOrderTriggerHandler.lstNewAux);
            WorkOrder wo = mapCase.get(workOrderId);
            //WorkOrder wo = [SELECT StartDate, Status, Guarantee_Notice_Time__c, Preparation_Notice_Time__c FROM WorkOrder WHERE Id=:workOrderId];
            datetime currentTime = datetime.NOW();

            //in case called when notice time setting is empty, then default to one minute
            Long milliSeconds = 60000;
            string woStatus = wo.Status;
            if (woStatus == 'Not Guaranteed') {
                if (wo.Guarantee_Notice_Time__c != null) {
                    milliSeconds =  wo.StartDate.getTime() - wo.Guarantee_Notice_Time__c.getTime();
                }
            } else {
                if (wo.Preparation_Notice_Time__c != null) {
                    milliSeconds =  wo.StartDate.getTime() - wo.Preparation_Notice_Time__c.getTime(); 
                }
     
            }
            Integer decMinutes = (milliSeconds/60000).intValue();
        
            return decMinutes; 
        } else {
            return null;
        }
     }
}