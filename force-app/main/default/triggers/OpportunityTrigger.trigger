/***********************************************************************************************
*   Trigger Name    : OpportunityTrigger 
*   Date            : 
*   Author          : 
*   Object          : Opportunity
*   Helper Class    : OpportunityMethods
*   Test Class      :OpportunityTriggerHelper_Test,OpportunityRollUpHandler_Test
**************************************************************************************************/
trigger OpportunityTrigger on Opportunity (Before insert,Before update,After insert,After Update, After Delete,after undelete)
{
    //below CustomSetting will help us get downtime for a given user during business hours
   AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
   
   if(!AdminOverrideUser.Switch_Off_Trigger__c)
   {
    if(TriggerSwitch__c.getInstance('OpportunityTrigger').isActive__c)
        {
    system.debug('###OpportunityTrigger starts!!###');
    //variables to contain trigger context data
    Map<id, Opportunity> oldOppMap, newOppMap;
    List<Opportunity> newoppList,oldOppList;
    if(trigger.isBefore){
        system.debug('###trigger.isBefore on Opportunity :'+trigger.isBefore);
        if(trigger.isinsert){
            newoppList=trigger.new;
            newOppMap=trigger.newmap;
            //Before Insert
            OpportunityMethods.methodsToInvokeOnBeforeInsert(newoppList,newOppMap);
        }
        if(trigger.isupdate){
            newoppList=trigger.new;
            newOppMap=trigger.newmap;
            oldOppMap=trigger.oldmap;
            oldOppList=trigger.old;
            //before Update
            OpportunityMethods.methodsToInvokeOnBeforeUpdate(newoppList,newOppMap,oldOppList,oldOppMap);
        }
        if(trigger.isupdate||trigger.isinsert){
            newoppList=trigger.new;
            newOppMap=trigger.newmap;
            oldOppMap=trigger.isupdate?trigger.oldmap:null;
            oldOppList=trigger.isupdate?trigger.old:null;
            //Before insert or Update
            OpportunityMethods.methodsToInvokeOnBeforeInsertAndUpdate(newoppList,newOppMap,oldOppList,oldOppMap);
        }
        
    }
    if(trigger.isAfter){
        system.debug('###trigger.isAfter on Opportunity :'+trigger.isAfter);
        if(trigger.isinsert){
            newoppList=trigger.new;
            newOppMap=trigger.newmap;
            //After Insert
            OpportunityMethods.methodsToInvokeOnAfterInsert(newoppList,newOppMap);
        }
        if(trigger.isupdate){
            newoppList=trigger.new;
            newOppMap=trigger.newmap;
            oldOppMap=trigger.oldmap;
            oldOppList=trigger.old;
            //after Update
            OpportunityMethods.methodsToInvokeOnAfterUpdate(newoppList,newOppMap,oldOppList,oldOppMap);
        }
        if(trigger.isupdate||trigger.isinsert){
            newoppList=trigger.new;
            newOppMap=trigger.newmap;
            oldOppMap=trigger.isupdate?trigger.oldmap:null;
            oldOppList=trigger.isupdate?trigger.old:null;
            //after Insert and Update
            OpportunityMethods.methodsToInvokeOnAfterInsertAndUpdate(newoppList,newOppMap,oldOppList,oldOppMap);
        }
        if(trigger.isdelete){
            oldOppMap=trigger.oldmap;
            oldOppList=trigger.old;
            //After delete
            OpportunityMethods.methodsToInvokeOnAfterDelete(oldOppList,oldOppMap);
        }
        if(trigger.isundelete){
            newoppList=trigger.new;
            newOppMap=trigger.newmap;
            //after Undelete
            OpportunityMethods.methodsToInvokeOnAfterUndelete(newoppList,newOppMap);
        }
    }
    }
    }
    
    system.debug('SOQL Consumption in Trigger ::  ' +Limits.getQueries());  
    system.debug('###OpportunityTrigger Ends!!###');
}