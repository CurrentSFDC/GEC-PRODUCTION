public with sharing class CaseTimeTracking {
	
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getTimeTrackers(id caseId){
        return [SELECT Current_Status__c, SUM(Status_Time__c) TotalTime, COUNT(id) TotalRecords, SUM(Hours__c) TotalHours, SUM(Days__c) TotalDays, SUM(Minutes__c) TotalMinutes FROM Time_Tracking__c WHERE Case__c =:caseId GROUP BY Current_Status__c];
    }
    
}