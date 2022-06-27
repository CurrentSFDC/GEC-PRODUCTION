/*
Name - GE_LGT_Batch_StQuote_Deletion_Schedule 
Test Class - GE_LGT_Batch_StQuote_Deletion_Test
Author - Sai Tandra
Purpose - To Schedule GE_LGT_Batch_StQuote_Deletion
Date - March-2017
*/
global class GE_LGT_Batch_StQuote_Deletion_Schedule  implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new GE_LGT_Batch_StQuote_Deletion(),1000);
    }
}