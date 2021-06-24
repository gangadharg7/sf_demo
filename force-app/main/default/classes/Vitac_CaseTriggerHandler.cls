/*************************************************************************
*Initial Development: Rahul Nayak	
*Description: This class is a handler class for CaseTrigger apex trigger.
*
*Versions: Versions		 	Names			Date/Chnage Reason
			1.0				Rahul Nayak		Initial Development- if case Status is New take all cases and send to samanage system.
**************************************************************************/
public class Vitac_CaseTriggerHandler {
   public static List<Case> queryCase(Map<Id,Case> newcaseMap,Map<Id,Case> oldCaseMap){
        Vitac_CaseToSamanageOutbound ctso = new Vitac_CaseToSamanageOutbound();
       	Set<Id> caseIdSet=new Set<Id>();
        List<Case> caseListRec=new List<Case>();
       	
        if(!newcaseMap.isEmpty()){
            for(Case cs:newcaseMap.values()){
                System.debug('CaseList Values:'+newcaseMap.values());
                if(oldCaseMap.get(cs.id).Status <> 'SaManage Ticket - Waiting' && cs.Status=='SaManage Ticket - Waiting'){
                    caseListRec.add(cs);
                    caseIdSet.add(cs.id);
                    ctso.caseDetailsReq(caseListRec);
                } 
            } 
        }
        return caseListRec;
    }
}