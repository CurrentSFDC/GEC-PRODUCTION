public with sharing class CaseNotes {
    
	@AuraEnabled(cacheable=true)
    public static List<Case_Notes__c> getAllNotes(Id caseId){
        
        return [SELECT Id, Name, Note__c, Case__r.CaseNumber, Note_Type__c, CreatedDate, Content__c, Subject__c, Created_By__c FROM Case_Notes__c WHERE Case__c =: caseId ORDER BY CreatedDate DESC];
        
        
        /*
        List<ContentDocumentLink> documentLink = [SELECT ContentDocumentId from ContentDocumentLink where LinkedEntityId =: caseId];
        
        Set<Id> contentDocIds = new Set<Id>();
        for(ContentDocumentLink contentDocLink : documentLink){
            contentDocIds.add(contentDocLink.ContentDocumentId);
        }
        
        List<Id> contentDocIdList = new List<Id>(contentDocIds);
      */ 
        
        //return [SELECT Title, TextPreview, String.valueOf(Content), CreatedDate, Owner.Name FROM ContentNote where Id IN :contentDocIdList ORDER BY CreatedDate DESC ];
         
        
        
       
    
    	//SObject[] queryParentObject = Database.query('SELECT Id, CaseNumber,Status, (SELECT Id, Title, Body FROM Notes) FROM Case where Id =: caseId');
    	//return queryParentObject;
    }
    
   
}