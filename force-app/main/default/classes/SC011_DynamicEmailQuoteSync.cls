/*
Name - SC011_DynamicEmailQuoteSync
Author - Neel
Purpose - Schedule class of BA011_DynamicEmailQuoteSync
Testclass :BA011_DynamicEmailQuoteSync_Test
Created Date - April -2018
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By        Date      Comments

*/
global class SC011_DynamicEmailQuoteSync implements Schedulable 

{
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new BA011_DynamicEmailQuoteSync());
    }
    
    
}