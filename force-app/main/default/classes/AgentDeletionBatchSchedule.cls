/*
Name - AgentDeletionBatchSchedule
Test Class - AgentDeletionBatch_Test
Author - Shyam Prasad Nayakula
Purpose - To Schedule AgentDeletionBatchSchedule
Date - Sep-2016
*/
global class AgentDeletionBatchSchedule implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new AgentDeletionBatch());
    }
}