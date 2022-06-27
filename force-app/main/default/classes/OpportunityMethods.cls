/***********************************************************************************************
*   Class Name      : OpportunityMethods 
*   Date            : 
*   Author          : 
*   Object          : Opportunity
*   Purpose         : These methods fire on Opportunity.
*   Test Class      : OpportunityTriggerHelper_Test , OpportunityRollUpHandler_Test
**************************************************************************************************/
public without sharing class OpportunityMethods {
   
    //Contain methods to invoke "before insert" Event On Opportunity
    public static void methodsToInvokeOnBeforeInsert(List<Opportunity> newOppList,Map<Id,Opportunity> newOppMap){
        
        OpportunityTriggerHelper.fillFields(newOppList);
        
        OpportunityTriggerHelper.mapRecordTypeToOpty(newOppList);
        
        OpportunityTriggerHelper.nullifyclosingRequirements(newOppList);
        
    }
    
    //Contain methods to invoke "after insert" Event On Opportunity
    public static void methodsToInvokeOnAfterInsert(List<Opportunity> newOppList,Map<Id,Opportunity> newOppMap){
        
        OpportunityRollUpHandler.handlePortfolio(newOppList);
        
        OpportunityRollUpHandler.rollupOnAccount(newOppList);
        
       // OpportunityRollUpHandler.estimatedOrderCreation(newOppList);
        
        OpportunityTriggerHelper.insOppTeamMemberFromOpp(newOppList, newOppMap, null);
        
        OpportunityTriggerHelper.cloneOppContactRoles(newOppList);
    }
    
    //Contain methods to invoke "before insert" and Update" Events On Opportunity
    public static void methodsToInvokeOnBeforeInsertAndUpdate(List<Opportunity> newOppList,Map<Id,Opportunity> newOppMap,List<Opportunity> oldOppList,Map<Id,Opportunity> oldOppMap){
        
        
    }
   
    
    //Contain methods to invoke "after  insert and update" Event On Opportunity
    public static void methodsToInvokeOnAfterInsertAndUpdate(List<Opportunity> newOppList,Map<Id,Opportunity> newOppMap,List<Opportunity> oldOppList,Map<Id,Opportunity> oldOppMap){
        
        OpportunityTriggerHelper.createContactRole(newOppList,oldOppMap);
    }
    
    
    //Contain methods to invoke "before update" Event On Opportunity
    public static void methodsToInvokeOnBeforeUpdate(List<Opportunity> newOppList,Map<Id,Opportunity> newOppMap,List<Opportunity> oldOppList,Map<Id,Opportunity> oldOppMap){
        
        OpportunityTriggerHelper.optyOrderProductValidations(newOppList,oldOppMap);
        
        OpportunityTriggerHelper.calculatePushCount(newOppList,oldOppMap);
        OpportunityTriggerHelper.validationsOnIE(newOppList);
       OpportunityTriggerHelper.mapPriceBookToOpty(newOppList,oldOppMap);
        OpportunityTriggerHelper.preventStageAdvancement(newOppList, oldOppMap); //This method will prevent stage advancement if there is no contact role(s) associated to oppty
      OpportunityTriggerHelper.ClosedlostPOvalidation(newOppList, oldOppMap); //285
        OpportunityTriggerHelper.UpdateTypeonOpp(newOppList, oldOppMap);
        
    }
    
    //Contain methods to invoke "after update" Event On Opportunity
    public static void methodsToInvokeOnAfterUpdate(List<Opportunity> newOppList,Map<Id,Opportunity> newOppMap,List<Opportunity> oldOppList,Map<Id,Opportunity> oldOppMap){
        
        
        OpportunityRollUpHandler.handlePortfolioInUpdate(newOppList,oldOppMap);
        
        OpportunityRollUpHandler.rollupOnAccountAtOptyupdate(newOppList,oldOppMap);
        
        OpportunityRollUpHandler.accountUpdateOnOrder(newOppMap,oldOppMap);
        
        OpportunityRollUpHandler.orderOwnerChangeIfOptyOwnerChange(newOppMap,oldOppMap);
        
        OpportunityTriggerHelper.updateSKUFromQuoteLineItem(newOppList);
        
        
        if (StaticVariables.insertTeamMemberFromOpp = true )
        {
            OpportunityTriggerHelper.insOppTeamMemberFromOpp(newOppList, newOppMap, oldOppMap);   
        } 
        
    }
    
    //Contain methods to invoke "after delet" Event On Opportunity
    public static void methodsToInvokeOnAfterDelete(List<Opportunity> oldOppList,Map<Id,Opportunity> oldOppMap){
    
        OpportunityRollUpHandler.handlePortfolio(oldOppList);
        
        OpportunityRollUpHandler.rollupOnAccount(oldOppList);
        
    }
    
    
    //Contain methods to invoke "after Undelete" Event On Opportunity
    public static void methodsToInvokeOnAfterUndelete(List<Opportunity> newOppList,Map<Id,Opportunity> newOppMap){
    
    
        OpportunityRollUpHandler.handlePortfolio(newOppList);
        
        OpportunityRollUpHandler.rollupOnAccount(newOppList);
        
    }
    
}