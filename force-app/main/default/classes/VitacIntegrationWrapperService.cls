public class VitacIntegrationWrapperService {
    @InvocableMethod()
    public static void sendWoDetail(List<WorkOrder> listRequest) {
        // Check Integration Switch settings, if disabled then go back 
        Metadata_Control__c cs = Metadata_Control__c.getInstance();
        if(cs != null && (cs.Disable_All__c || cs.Disable_VSS_Integration__c)) return;
        for(WorkOrder req : listRequest){
            if(req.Site__c=='GV' && req.Action_Code__c=='New Order')
            	VSSIntegrationService.createWo(req.Id);
           else if(req.Site__c=='GV' && req.Action_Code__c=='Update Order')
            	VSSIntegrationService.updateWo(req.Id);
           else if(req.Site__c=='GV' && req.Action_Code__c=='Cancel Order')
            	VSSIntegrationService.cancelWo(req.Id, req.VSSExtId__c, req.AccountId);
           else if(req.Site__c=='CB')
                RTISIntegrationService.createWo(req.Id);
           system.debug('Action Code : ' + req.Action_Code__c + '\nWorkOrder Id : ' + req.Id + '\nVSS External Id : ' + req.VSSExtId__c + '\nCustomer Code : ' + req.AccountId);
        }
   }
}