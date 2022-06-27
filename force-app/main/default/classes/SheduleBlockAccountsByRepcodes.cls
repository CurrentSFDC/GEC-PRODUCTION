global class SheduleBlockAccountsByRepcodes implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        Id AccountBatchForBlockAccountsByRepcodesBatchId= Database.executeBatch(new BlockAccountsByRepcodes(), 50); 
    }
}