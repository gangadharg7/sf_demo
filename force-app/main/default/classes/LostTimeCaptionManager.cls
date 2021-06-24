public with sharing class LostTimeCaptionManager {
    @AuraEnabled(cacheable=true)

    public static List<Lost_Caption_Time__c> getLostTime(Integer numberofRecords){ 
        return [select id, Time_Difficulty_Began__c, Time_Difficulty_Ended__c, Hours__c, Name, Minutes__c, Seconds__c, Case__c
                FROM Lost_Caption_Time__c
                ORDER by CreatedDate DESC ];
    }
}