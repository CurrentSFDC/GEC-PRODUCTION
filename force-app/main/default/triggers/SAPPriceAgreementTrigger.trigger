/*
Name - SAPPriceAgreementTrigger
Helper Class - SAPPriceAgreementTriggerHelper
Test Class - SAPPriceAgreementTrigger_Test
Author - Shyam Prasad Nayakula
Purpose - Trigger on SAP Price Aggrement Object
Created Date - July-2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments
Pavan Kumar Mudiganti    7/21/2017        Added method in before logic to check GE Opportunity No 
*/
trigger SAPPriceAgreementTrigger on SAP_Price_Agreement__c (before insert,before update,before delete,after insert,after update,after delete) 
{    
    
    if(trigger.isBefore)
    {
         if(trigger.isInsert || trigger.isUpdate)
            SAPPriceAgreementTriggerHelper.updateFieldsOnCreateOrUpdate(trigger.new);
        if(!trigger.isDelete) 
        {
            if (trigger.isUpdate)
            {
                SAPPriceAgreementTriggerHelper.updateFieldsOnCreate(trigger.new);
                SAPPriceAgreementTriggerHelper.clearGeOppId(trigger.new,trigger.oldMap);
            }
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            SAPPriceAgreementTriggerHelper.createOrUpdateQuotes(trigger.new);
        }
            
        if(trigger.isUpdate){
            SAPPriceAgreementTriggerHelper.updateExistingQuotes(trigger.new,trigger.oldMap);
            
        }
        
    }
}