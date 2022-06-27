@isTest
private class GE_LGT_EM_CustomerNameSchedulable_Test 
{
    static testMethod void myUnitTest() 
    {
        Test.startTest();
        String CRON_EXP = '0 0 0 1 1 ? 2050';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new GE_LGT_EM_CustomerNameUpdate_1() );
        
        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2050-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}