/*
Name - GE_LGT_AccountAgentDeletion_Schedule
Test Class - GE_LGT_AccountAgentBatchDeletion_Test
Author - Shyam Prasad Nayakula
Purpose - To Schedule batch "GE_LGT_AccountAgentBatchDeletion"
Date - July-2016
*/
global class GE_LGT_AccountAgentDeletion_Schedule implements Schedulable
{
	global void execute(SchedulableContext SC) 
    {
		Database.executeBatch(new GE_LGT_AccountAgentBatchDeletion());
    }

}