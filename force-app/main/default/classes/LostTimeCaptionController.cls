public with sharing class LostTimeCaptionController {
    @AuraEnabled(cacheable=true)

    public static List<Lost_Caption_Time__c> getLostTime(String captionId){ 
        Lost_Caption_Time__c[] caseRec= [SELECT case__c from Lost_Caption_Time__c where id=:captionId ];
        String caseId = caseRec[0].case__c;
        return [select id, Time_Difficulty_Began__c, Time_Difficulty_Ended__c, Hours__c, Name, Minutes__c, Seconds__c, Case__c
                FROM Lost_Caption_Time__c
                WHERE Case__c =:caseId
                ORDER by CreatedDate DESC ];
    }

    @AuraEnabled(cacheable=true)

    public static List<Lost_Caption_Time__c> refreshLostTime(String caseId){ 
        return [select id, Time_Difficulty_Began__c, Time_Difficulty_Ended__c, Hours__c, Name, Minutes__c, Seconds__c, Case__c
                FROM Lost_Caption_Time__c
                WHERE Case__c =:caseId
                ORDER by CreatedDate DESC ];
    }

    @AuraEnabled()

    public static void deleteLostTime(list<Id> lstLostIds){
        try {
                list<Lost_Caption_Time__c> lstCaptionTimesToDelete = new list<Lost_Caption_Time__c>();
                System.debug('lstConIds ====> '+lstLostIds);
                for(Id idLost : lstLostIds) {
                    lstCaptionTimesToDelete.add(new Lost_Caption_Time__c(Id = idLost));
                }
                if(!lstCaptionTimesToDelete.isEmpty()) {
                    delete lstCaptionTimesToDelete;
                }
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}