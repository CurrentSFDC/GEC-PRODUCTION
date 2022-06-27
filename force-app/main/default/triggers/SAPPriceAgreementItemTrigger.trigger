/*
Name - SAPPriceAgreementItemTrigger
Helper Class - SAPPriceAgreementItemTriggerHelper
Test Class - SAPPriceAgreementItemTrigger_Test
Author - Shyam Prasad Nayakula
Purpose - Trigger on SAP Price Aggrement Item Object
Created Date - July-2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By				Date			Comments

*/
trigger SAPPriceAgreementItemTrigger on SAP_Price_Agreement_Item__c(before insert,before update,before delete,after insert,after update,after delete) 
{
    if(trigger.isBefore)
    {
       if(trigger.isInsert || trigger.isUpdate)
        {
            SAPPriceAgreementItemTriggerHelper.updateFieldsOnCreateOrUpdate(trigger.new);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            SAPPriceAgreementItemTriggerHelper.createQuoteLineItems(trigger.new);
        }
        if(trigger.isUpdate)
        {
            SAPPriceAgreementItemTriggerHelper.updateQuoteItemsFromPricingAgreementItems(trigger.new);
        }
	}
}