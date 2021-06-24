public class CalculateWOStartEndDate {
//    @InvocableMethod
    public void updateDates(List<WorkOrder> newWOList){
        for(WorkOrder woTemp: newWOList)
        {
            string woID = woTemp.Id;
            List<WorkOrder> workOrderList=[select id, StartDt_Time__c, Time_Zone__c,DurationType,Duration from WorkOrder where Id = :woID];
            if (!workOrderList.isEmpty())
            {
               WorkOrder workOrder=workOrderList[0];
               Datetime startDt = workOrderList[0].StartDt_Time__c;
               string strTZ = workOrderList[0].Time_Zone__c;
               startDt = startDt.addSeconds(UserInfo.getTimeZone().getOffset(startDt)/1000);
               startDt = startDt.addSeconds(-(TimeZone.getTimeZone(strTZ).getOffset(startDt))/1000);                
               workOrder.StartDate = startDt;
               if(workOrder.DurationType == 'Hours'){
                   workOrder.EndDate = startDt.addMinutes((workOrderList[0].Duration*60).intValue());
               }
               else {
                   workOrder.EndDate = startDt.addMinutes((workOrderList[0].Duration).intvalue());
               }             
               update workOrder;
            }
        }

    }
}