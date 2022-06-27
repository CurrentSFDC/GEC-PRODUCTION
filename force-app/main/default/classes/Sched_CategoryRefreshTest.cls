/*---------------------------------------------------------------------------------
Name:       Sched_CategoryRefreshTest.cls
Purpose:    Test Class for Schedulable Category.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@isTest
private class Sched_CategoryRefreshTest {
	@isTest
	private static void testSchedule() {
		Test.StartTest();
            Sched_CategoryCacheRefresh s = new Sched_CategoryCacheRefresh();
			String sch = '0 0 23 * * ?';
			string JobId = system.schedule('Test Category Refresh', sch, s);
			CronTrigger ct = [SELECT id
									 ,CronExpression
									 ,TimesTriggered
									 ,NextFireTime
							  FROM CronTrigger
							  WHERE id = :jobId];
			System.assertEquals(sch, ct.CronExpression);
			System.assertEquals(0, ct.TimesTriggered);
		test.StopTest();
	}
}