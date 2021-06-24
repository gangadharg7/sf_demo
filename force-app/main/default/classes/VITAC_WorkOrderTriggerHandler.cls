public with sharing class VITAC_WorkOrderTriggerHandler {
    private static VITAC_WorkOrderTriggerHandler woHandlerInstance = null;

    //added for MilestoneTimeCalc bulkify needs
    public static List<WorkOrder> lstNewAux;    
    //Static method that returns the instance of the WorkOrderTriggerHelper class.
    //This will avoid creating multiple instances of the same object 
    public static VITAC_WorkOrderTriggerHandler getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(woHandlerInstance == null) woHandlerInstance = new VITAC_WorkOrderTriggerHandler();
        return woHandlerInstance;
    }
    
   public void delegateProcessing() {
        VITAC_WorkOrderTriggerHelper woHelper = VITAC_WorkOrderTriggerHelper.getInstance();
        lstNewAux = (List<WorkOrder>)Trigger.new;
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                woHelper.updateAccount();
                woHelper.setDefaults();
            }
            if (Trigger.isUpdate) {
                
            }

            if (Trigger.isInsert || Trigger.isUpdate) {
                //Code to calculate the OOTB Start and End Date based on what user inputs for Start Date, Start Time and Time Zone
                woHelper.updateDates();
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                woHelper.closeWOMileStone();
            }
        }
    }
}