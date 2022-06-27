/*---------------------------------------------------------------------------------
Name:       Sched_ProductSpecRefreshTest.cls
Purpose:    Test Class for Schedulable Product Spec.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@isTest
private class Sched_ProductSpecRefreshTest {
	@isTest
	private static void testSchedule() {
		Test.StartTest();
			sched_ProductSpecRefresh s = new Sched_ProductSpecRefresh();
			String sch = '0 0 23 * * ?';
			string JobId = system.schedule('Test Product Spec Refresh', sch, s);
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