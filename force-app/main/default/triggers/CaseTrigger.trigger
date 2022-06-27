trigger CaseTrigger on Case (before insert, after insert, before update, after update,before delete) {
    
    //below CustomSetting will help us get downtime for a given user during business hours
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    System.debug('AdminOverrideUser: '+ AdminOverrideUser + 'Switch Status: '+ AdminOverrideUser.Switch_Off_Trigger__c);
    if(AdminOverrideUser.Switch_Off_Trigger__c == false) {
        TriggerSwitch__c caseSetting = TriggerSwitch__c.getInstance('CaseTrigger');
        if(!(caseSetting != NULL && caseSetting.isActive__c == false)){
            
            // before events
            /*if(trigger.isBefore){
                //before Insert event
                if(trigger.isInsert){
                    system.debug('Trigger');
                    CaseMethods.methodsToInvokeOnBeforeInsert(Trigger.new);
                }
                // before Deleteevent
                if(trigger.isDelete){
                    system.debug('***Before delete event*****');
                    caseMethods.methodsToInvokeOnBeforeDelete(Trigger.old);
                }                
                // before Update event
                if(trigger.isUpdate){
                    caseMethods.methodsToInvokeOnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
            }
            
            // after events
            if(trigger.isAfter){
                // after Insert event
                if(trigger.isInsert){
                    CaseMethods.methodsToInvokeOnAfterInsert(Trigger.new, Trigger.newMap);
                }
                // after update event
                if(trigger.isUpdate){
                    CaseMethods.methodsToInvokeOnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, trigger.oldMap);
                } 
            } */
        }
    }
}