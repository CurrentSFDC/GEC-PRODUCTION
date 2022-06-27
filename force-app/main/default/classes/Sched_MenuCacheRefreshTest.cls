/*---------------------------------------------------------------------------------
Name:       Sched_MenuCacheRefreshTest.cls
Purpose:    Test Class for Schedulable Menu Cache.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@isTest
private class Sched_MenuCacheRefreshTest {
	@isTest
	private static void testSchedule() {
		Test.StartTest();
			Sched_MenuCacheRefresh s = new Sched_MenuCacheRefresh();
			String sch = '0 0 23 * * ?';
			string JobId = system.schedule('Test Menu Refresh', sch, s);
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