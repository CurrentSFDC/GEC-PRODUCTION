global class SheduleDeleteAccountsByflags implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        Id AccountBatchForBlockAccountsByRepcodesBatchId= Database.executeBatch(new DeleteAccountsByflags(), 50); 
    }
}