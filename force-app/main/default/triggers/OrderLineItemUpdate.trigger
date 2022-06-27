/*
Name - OrderLineItemUpdate
Test Class - OrderLineItemUpdateHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Trigger on OrderItem to update values
Date - May-2016
*/
trigger OrderLineItemUpdate on OrderItem (before insert,before update) 
{
    if(TriggerSwitch__c.getInstance('OrderLineItemUpdate').isActive__c)
    {
        OrderLineItemUpdateHelper olih=new OrderLineItemUpdateHelper();
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        {
            olih.UpdateOrderLineItems(Trigger.New);
        }
    }
}