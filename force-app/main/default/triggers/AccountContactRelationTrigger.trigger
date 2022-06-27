/**
 * Created by PA on 2021. 04. 21..
 */

trigger AccountContactRelationTrigger on AccountContactRelation (after insert) {
   
    if (Trigger.isInsert && Trigger.isAfter) {
        
      
        
        List<AccountContactRelation> listToInsert = new List<AccountContactRelation>();
        for (AccountContactRelation acr : Trigger.New){
            if(acr.B2B_Agent_flag__c == true){
                listToInsert.add(acr);
            }
        }
        new AccountContactRelationship().assignRelationship(listToInsert);
        
        new AccountSharingController().shareChildAccountsFromAccountContactRelationInsert(Trigger.new);
        
    }

    
    
    
}