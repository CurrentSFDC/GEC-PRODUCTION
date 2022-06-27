/*---------------------------------------------------------------------------------
Name:       sched_ProductIndexRefreshTest.cls
Purpose:    Test Class for Schedulable Product Index.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          06-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@isTest
private class Sched_ProductIndexRefreshTest {
	@isTest
	private static void testSchedule() {
		Test.StartTest();
			Sched_ProductIndexRefresh s = new Sched_ProductIndexRefresh();
			String sch = '0 0 23 * * ?';
			string JobId = system.schedule('Test Product Refresh', sch, s);
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