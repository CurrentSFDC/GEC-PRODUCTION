/*
Name - QuoteTrigger
Helper Class - QuoteTriggerHelper
Test Class - QuoteTriggerTrigger_Test
Author - Shyam Prasad Nayakula
Purpose - Trigger on Quote Object
Created Date - July-2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
trigger QuoteTrigger on Quote (before insert,before update,before delete,after insert,after update,after delete) 
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert || trigger.isUpdate)
        {
            QuoteTriggerHelper.updateQuoteDetails(trigger.new);
            QuoteTriggerHelper.validateExpirationDateCurrency (trigger.new);
            QuoteTriggerHelper.updateQuoteSyncDetails(trigger.new);
        }
        if(trigger.isUpdate)
        {
        }
    }
}