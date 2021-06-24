public class VITAC_WorkOrderLineTriggerHelper {
    private static VITAC_WorkOrderLineTriggerHelper woliHelperInstance = null;
    
    //Static method that returns the instance of the WorkOrderLineTriggerHelper class.
    //This will avoid creating multiple instances of the same object 
    public static VITAC_WorkOrderLineTriggerHelper getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(woliHelperInstance == null) woliHelperInstance = new VITAC_WorkOrderLineTriggerHelper();
        return woliHelperInstance;
    }
 

    //This method is used to default values
    public void setDefaults(){
        /*
        List<WorkOrderLineItem> newWOLIList = (List<WorkOrderLineItem>)Trigger.new;
        for(WorkOrderLineItem woli: newWOLIList) {
            if(woli.SF_Ext_Id__c == null){
               woli.SF_Ext_Id__c = 'WO-' + getUUID();
            }
            if(woli.Submit_Date__c == null){
               woli.Submit_Date__c = system.now();
            }
        }
		*/
    }
   
    public void updateAccount(){
        /*
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
	*/
    }      
}