@isTest
public class SalsifyProductCalloutBatchScheduleTest {
    @isTest static void testBatch () {
        Test.startTest();
        SalsifyProductCalloutBatchScheduler sh1 = new SalsifyProductCalloutBatchScheduler();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test', sch, sh1); 
        Test.stopTest();
    }
}