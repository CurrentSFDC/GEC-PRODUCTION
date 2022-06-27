/*
Name - SC0_OrderDelete
Author - Andras
Purpose - Schedule class of GE_LGT_Batch_OrderDeletion
Created Date - April-2019
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
global class SC0_OrderDelete  implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new GE_LGT_Batch_OrderDeletion());
    }
    
}