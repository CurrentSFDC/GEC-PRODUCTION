trigger OpportunityKeyPlayerTrigger on CDT_Opportunity_Key_Player__c (After insert,After Update,After Delete) {
 If((Trigger.isinsert||Trigger.isUpdate) && trigger.isAfter)
 {
 OpportunityKeyPlayerTriggerhelper.opportunityfieldUpdate(Trigger.New);
 }

 If(Trigger.isdelete && trigger.isAfter)
 {
 OpportunityKeyPlayerTriggerhelper.opportunityfieldupdatewithnull(trigger.Old );
 }
 
}