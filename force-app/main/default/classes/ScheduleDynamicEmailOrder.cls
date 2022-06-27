/*
Name - ScheduleDynamicEmailOrder
Author - Roja 
Purpose - Schedule class of DynamicEmailOrder
Testclass :DynamicEmailOrder_Test
Created Date - April -2018*/



global class ScheduleDynamicEmailOrder implements Schedulable {
    
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new DynamicEmailOrder());
    }
    

}