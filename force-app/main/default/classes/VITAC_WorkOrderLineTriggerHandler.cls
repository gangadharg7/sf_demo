public with sharing class VITAC_WorkOrderLineTriggerHandler {
    private static VITAC_WorkOrderLineTriggerHandler woliHandlerInstance = null;
    
    //Static method that returns the instance of the WorkOrderLineTriggerHelper class.
    //This will avoid creating multiple instances of the same object 
    public static VITAC_WorkOrderLineTriggerHandler getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(woliHandlerInstance == null) woliHandlerInstance = new VITAC_WorkOrderLineTriggerHandler();
        return woliHandlerInstance;
    }
    
   public void delegateProcessing() {
        //VITAC_WorkOrderLineTriggerHelper woliHelper = VITAC_WorkOrderLineTriggerHelper.getInstance();
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                //woliHelper.setDefaults();
            }
            if (Trigger.isUpdate) {
                //calls here
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                //calls here
            }
        }
    }
}