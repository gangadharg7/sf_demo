public class VITAC_WOMilestoneUtils {
    public static void completeMilestone(List<Id> woIds, 
            String milestoneName, DateTime complDate) {  
    List<EntityMilestone> wmsToUpdate = [select Id, completionDate
            from EntityMilestone wm
            where ParentEntityId in :woIds and wm.MilestoneType.Name=:milestoneName 
            and completionDate = null limit 1];
    //System.debug('here0');
    if (wmsToUpdate.isEmpty() == false){
        for (EntityMilestone wm : wmsToUpdate){
            wm.completionDate = complDate;
            }
        update wmsToUpdate;
        }
    }
}