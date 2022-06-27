global class AccountSheduleingForZSTGToEnduser implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        Id AccountBatchForZSTGToEnduserId= Database.executeBatch(new AccountConvertZSTGToEnduserBatch(), 1000); 
    }
}