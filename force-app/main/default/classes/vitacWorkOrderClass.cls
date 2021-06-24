public class vitacWorkOrderClass {
    public void updateDates(List<WorkOrder> newWOList){
        for(WorkOrder wo: newWOList)
            {
                Datetime startDt = wo.StartDt_Time__c; 
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
            }
    }

}