trigger RMATrigger on RMA__c (After Insert ,After Update) {
    If(trigger.IsAfter){
        If(trigger.IsInsert){
            RMATriggerHelper.createRMAMultipleChildRecords(Trigger.New,false,null);
        }
        If(trigger.IsUpdate){
           RMATriggerHelper.createRMAMultipleChildRecords(Trigger.New,True,Trigger.OldMap);
        }
    }

}