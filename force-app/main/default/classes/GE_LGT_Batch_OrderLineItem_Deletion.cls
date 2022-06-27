global class GE_LGT_Batch_OrderLineItem_Deletion implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        system.debug('Batch deletion GE_LGT_Batch_OrderLineItem_Deletion started::2 ');     
        return Database.getQueryLocator([select id from OrderItem where SAP_OrderItem_Deletion_Flag__c!=null]);
    }
    global void execute(Database.BatchableContext bc,List<OrderItem> scope)
    {
        system.debug('Scope size ::: '+scope.size());
        if(!scope.isEmpty())
        {
            system.debug(' GE_LGT_Batch_OrderLineItem_Deletion -Inside depetion method');
            Database.delete(scope,false);  
        }     
    }
    global void finish(Database.BatchableContext bc)
    {
        system.debug('OrderItem deletion job executed!!!');
    }
}