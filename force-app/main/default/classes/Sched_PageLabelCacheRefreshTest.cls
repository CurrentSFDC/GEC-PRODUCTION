/*---------------------------------------------------------------------------------
Name:       Sched_PageLabelCacheRefreshTest.cls
Purpose:    Test Class for Schedulable Product Spec.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@isTest
private class Sched_PageLabelCacheRefreshTest {

    private static void setupData() {
        ccrz.ccApiTestData.setupData(new Map<String,Map<String,Object>>{
            ccrz.ccApiTestData.STOREFRONT_SETTINGS => new Map<String,Object> {
                    'DefaultStore' => new Map<String,Object> {}
            },
            ccrz.ccApiTestData.APPLICATION_SETTINGS => new Map<String, Object> {}
        });
    }

	@isTest
	private static void testSchedule() {
		Test.StartTest();
        Sched_PageLabelCacheRefresh s = new Sched_PageLabelCacheRefresh();
			String sch = '0 0 23 * * ?';
			string JobId = system.schedule('Test Page Label Refresh', sch, s);
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