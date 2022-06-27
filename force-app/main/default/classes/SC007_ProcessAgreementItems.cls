/*
Name - SC007_ProcessAgreementItems
Author - Shyam Prasad Nayakula
Purpose - Schedule class of BA007_ProcessAgreementItems
Created Date - October -2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments

*/
global class SC007_ProcessAgreementItems  implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new BA007_ProcessAgreementItems());
    }
    
}