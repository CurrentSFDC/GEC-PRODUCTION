/***********************************************************************************************
*   Trigger Name      : OpportunitySupportRequestTrigger
*   Date            : 7/03/2017
*   Author          : Satish Babu
*   Object          : Opportunity_Support_Request__c
*   Purpose         : These Trigger will fire on OpportunitySupportRequest.
*   Company        : TechMahindra
**************************************************************************************************/
trigger OpportunitySupportRequestTrigger on Opportunity_Support_Request__c (before Insert, before Update,after update,after insert,before delete) {
 
    //below CustomSetting will help us get downtime for a given user during business hours
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    if(!AdminOverrideUser.Switch_Off_Trigger__c) {
        if(TriggerSwitch__c.getInstance('OpportunitySupportRequestTrigger').isActive__c) {
            OpportunitySupportRequestMethods OSRMethod = new OpportunitySupportRequestMethods();
            // before events
            if(trigger.isBefore){
                //before Insert event
                if(trigger.isInsert){
                    OSRMethod.methodsToInvokeOnBeforeInsert(Trigger.New);
                }
                // before Update event
                if(trigger.isUpdate){
                    OSRMethod.methodsToInvokeOnBeforeUpdate(Trigger.New ,Trigger.OldMap);
                    
                }
                // before Delete event
                if(trigger.isDelete){
                    OSRMethod.methodsToInvokeOnBeforeDelete(Trigger.Old);
                }
                
            }
            // after events
            if(trigger.isAfter){
                // after Insert event
                if(trigger.isInsert){
                   OSRMethod.methodsToInvokeOnAfterInsert(Trigger.New);
                }
                // after update event
                if(trigger.isUpdate){
                    OSRMethod.methodsToInvokeOnAfterUpdate();
                }
                // after Delete event
                /*if(trigger.isDelete){
                    OpportunitySupportRequestMethods.methodsToInvokeOnAfterDelete();
                }*/
            }
        }
    }
}