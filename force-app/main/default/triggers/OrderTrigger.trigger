/*
Name - OrderTrigger
Test Class - OrderTriggerHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Trigger on Order to update values
Date - May-2016
*/
trigger OrderTrigger on Order (before insert,before update,After insert,After update,Before delete,After delete)
{
  //below CustomSetting will help us get downtime for a given user during business hours
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    if(!AdminOverrideUser.Switch_Off_Trigger__c){


	TriggerSwitch__c orderSetting = TriggerSwitch__c.getInstance('OrderTrigger');

    if(!(orderSetting != NULL && orderSetting.isActive__c == False)){

        if(Trigger.isUpdate && Trigger.isBefore){
            OrderTriggerHelper.updateGEOppID(trigger.new,trigger.oldMap);
            //***********************Method will check for cuurency miss match on order,if true then flag will be set to true (KAFZY-1900)***************/
            OrderTriggerHelper.checkCurrencyMismatch(trigger.new,trigger.oldMap);
        }

        if (Trigger.isInsert && Trigger.isAfter) {
            OrderTriggerHelper.checkOrderIdSetOnCase(trigger.new);
        }

        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
            OrderTriggerHelper.updateOrderDetails(trigger.new,trigger.oldMap);
            OrderTriggerHelper.updateRecordTypeForSAPOrders(trigger.new);
            //Added code for ticket No:KAFZY-1851
            OrderTriggerHelper.POrecievedEstiamtedorderstoCommit(trigger.new);
            //order owner must as opportunity owner for ticket NO:1953
              OrderTriggerHelper.updateRecordOwnerasOptyOwner(trigger.new);
        }

        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
            OrderTriggerHelperForRollupAcc.rollupOnAcc(trigger.new);
           //OrderTriggerHelper.updateOpportunity(trigger.new);
        }

        if(Trigger.isDelete && Trigger.isAfter){
           // OrderTriggerHelper.updateOpportunity(trigger.old);
        }
    }
     //CheckRecursive.stopExecutionOfRestrictShipDates = FALSE;
    List<Order> oldOrderList, newOrderList;
    Map<id, Order> oldOrderMap, newOrderMap;
     if ( trigger.isAfter ){

        if ( trigger.isInsert ){
            newOrderList = trigger.new;
            newOrderMap = trigger.newMap;
        }

        if ( trigger.isUpdate ){
            newOrderList = trigger.new;
            newOrderMap = trigger.newMap;
            oldOrderList = trigger.old;
            oldOrderMap = trigger.oldMap;
        }

        if ( trigger.isDelete ){
            oldOrderList = trigger.old;
            oldOrderMap = trigger.oldMap;
        }

        OrderMethods.updateOptyFromOrder(oldOrderList, newOrderList, oldOrderMap, newOrderMap);
    }

   }
}