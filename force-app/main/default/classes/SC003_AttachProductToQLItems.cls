/*
Name - SC003_AttachProductToQLItems 
Test Class - BA003_AttachProductToQLItems_Test
Author - Shyam
Purpose - To Schedule the batch BA003_AttachProductToQLItems
Date - April-2017
*/
global class SC003_AttachProductToQLItems  implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Database.executeBatch(new BA003_AttachProductToQLItems());
    }
}