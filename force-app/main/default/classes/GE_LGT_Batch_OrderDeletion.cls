global class GE_LGT_Batch_OrderDeletion implements Database.Batchable<SObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        ID recTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        datetime last24Hrs = datetime.now().addHours(-24);
        system.debug('Time::::'+last24Hrs );
        return Database.getQueryLocator([SELECT id,isPriceBookNotInSync__c FROM Order WHERE (LASTMODIFIEDDATE >=:last24Hrs
                                         AND RecordTypeID=:recTypeID) OR (SAP_Currency_Mismatch__c=TRUE AND RecordTypeID=:recTypeID)
                                        OR isPriceBookNotInSync__c=TRUE]);
    }
    global void execute(Database.BatchableContext BC, List<SObject> batchOrderRecords)
    {
        system.debug('Order batch program starts!!!!');
        List<Order> delListOrder = new List<Order>();
        for(Order orderVar : [SELECT id,SAP_Currency_Mismatch__c,isPriceBookNotInSync__c , (select id from OrderItems) FROM order where id in :batchOrderRecords ])
        {
            System.debug('orderVar.OrderItems:'+orderVar.OrderItems+':'+orderVar.OrderItems.size());
            if(orderVar.OrderItems==null || orderVar.OrderItems.isEmpty() || orderVar.SAP_Currency_Mismatch__c==true || orderVar.isPriceBookNotInSync__c)
            {
                system.debug('Order to be Deleted ::: '+orderVar.id);
                delListOrder.add(orderVar);
            }
        }
        if(!delListOrder.isEmpty())
        {
            system.debug('Order barch program starts - Its not empty!!!!');
            Database.delete(delListOrder,false);
        }     
    }
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}