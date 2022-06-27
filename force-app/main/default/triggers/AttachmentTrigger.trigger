trigger AttachmentTrigger on Attachment (after insert,after delete) 
{
    //.
    if(trigger.isInsert && trigger.isAfter)
    {
        AttachmentTriggerHelper.checkForPilotDoc(trigger.new);
        AttachmentTriggerHelper.updateParent(trigger.New, Trigger.newMap);
        AttachmentTriggerHelper.updateHasAttachmentOnFundRequest(trigger.New, Trigger.newMap); 
    }
    if(trigger.isDelete && trigger.isAfter)
    {
        AttachmentTriggerHelper.checkForPilotDoc(trigger.old);
    }
}