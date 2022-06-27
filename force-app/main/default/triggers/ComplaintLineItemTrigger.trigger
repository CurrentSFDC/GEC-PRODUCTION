trigger ComplaintLineItemTrigger on GE_LGT_EM_ComplaintLineItem__c (before insert,before update,after insert,after update,after delete) {
    //below CustomSetting will help us get downtime for a given user during business hours
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    if(!AdminOverrideUser.Switch_Off_Trigger__c) {
        if(TriggerSwitch__c.getInstance('ComplaintLineItemTrigger').isActive__c) {
            // before events
            if(trigger.isBefore){
                //before Insert event
                if(trigger.isInsert){
                    ComplaintLineItemMethods.methodsToInvokeOnBeforeInsert(Trigger.New);
                }
                // before Update event
                if(trigger.isUpdate){
                    ComplaintLineItemMethods.methodsToInvokeOnBeforeUpdate(Trigger.New, Trigger.NewMap, Trigger.Old, trigger.OldMap);
                }
            }
            // after events
            if(trigger.isAfter){
                // after Insert event
                if(trigger.isInsert){
                    ComplaintLineItemMethods.methodsToInvokeOnAfterInsert(Trigger.New, Trigger.NewMap);
                }
                // after update event
                if(trigger.isUpdate){
                    ComplaintLineItemMethods.methodsToInvokeOnAfterUpdate(Trigger.New, Trigger.NewMap, Trigger.Old, trigger.OldMap);
                }
                // after Delete event
                if(trigger.isDelete){
                    ComplaintLineItemMethods.methodsToInvokeOnAfterDelete(Trigger.Old, trigger.OldMap);
                }
            }
        }
    }
}