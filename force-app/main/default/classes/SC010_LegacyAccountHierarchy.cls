/*
Name - SC010_LegacyAccountHierarchy
Author - Neel
Purpose - Schedule class of BA010_LegacyAccountHierarchy
Created Date - April -2018
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By        Date      Comments

*/
global class SC010_LegacyAccountHierarchy implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new BA010_LegacyAccountHierarchy());
    }
    
}