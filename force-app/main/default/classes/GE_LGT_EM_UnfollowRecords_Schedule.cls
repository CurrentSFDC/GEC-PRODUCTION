public class GE_LGT_EM_UnfollowRecords_Schedule implements Schedulable
{
	public void  execute(SchedulableContext sc)
    {
        Database.executeBatch(new GE_LGT_EM_UnfollowRecords());
    }
}