@isTest
public class SC0_OrderDelete_Test 
{
    static testmethod void testSchedule()
    {
        Test.startTest();
        SC0_OrderDelete schedule=new SC0_OrderDelete();
        schedule.execute(NULL);
        Test.stopTest();
    }
}