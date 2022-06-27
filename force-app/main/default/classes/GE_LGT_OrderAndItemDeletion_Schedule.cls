/*
Name - GE_LGT_OrderAndItemDeletion_Schedule 
Test Class - GE_LGT_AccountAgentBatchDeletion_Test
Author - Neel Singh
Purpose - To Schedule two batch classes:
GE_LGT_Batch_OrderDeletion
GE_LGT_Batch_OrderLineItem_Deletion
Date - Sept-2016
*/
global class GE_LGT_OrderAndItemDeletion_Schedule implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new GE_LGT_Batch_OrderDeletion());
        Database.executeBatch(new GE_LGT_Batch_OrderLineItem_Deletion());
    }
    
}