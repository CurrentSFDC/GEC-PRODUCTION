@isTest
public class SC003_AttachProductToQLItems_Test 
{
    static testmethod void testSchedule()
    {
        Test.startTest();
        //Database.executeBatch(new BA002_SyncQuoteWithSAPQuote());
        SC003_AttachProductToQLItems schedule=new SC003_AttachProductToQLItems();
        schedule.execute(NULL);
        Test.stopTest();
    }
}