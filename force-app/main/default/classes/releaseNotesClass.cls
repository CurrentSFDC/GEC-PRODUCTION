public without sharing class releaseNotesClass {
   @AuraEnabled(Cacheable=true)
   public static List<Connect_Release_Notes__c> getReleaseNotes(Boolean active, Boolean isCurrent, String releaseType){
     List<String> type = releaseType.split(',');   
     System.debug('TYPE LIST: '+type);
     List<Connect_Release_Notes__c> releaseNotes = [SELECT Id, Name, Release_Date__c, Show_In_Connect__c, Current_Version__c, Category__c, Revision__c, Release_Version__c, Type__c, User_Description__c FROM Connect_Release_Notes__c 
        WHERE Show_In_Connect__c =: active AND Current_Version__c =: isCurrent AND Category__c IN :type
        ORDER BY Release_Date__c DESC];

        return releaseNotes;
   }

   @AuraEnabled(Cacheable=true)
   public static List<Connect_Release_Note_Item__c> getNoteItems(String noteId){
        List<Connect_Release_Note_Item__c> releaseNoteItems = [SELECT Id, Name, Type__c, Module__c, Sub_Module__c, Connect_Release_Note__c, Item_Number__c, Description__c FROM Connect_Release_Note_Item__c WHERE Connect_Release_Note__c =: noteId];

        return releaseNoteItems;
   }
}