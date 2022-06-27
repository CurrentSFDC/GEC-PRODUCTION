@isTest
public with sharing class SC_013_connectRelatedAccountRefresh_Test {
    public static testMethod void testschedule() {
		Test.StartTest();
		SC013_connectRelatedAccountRefresh testsche = new SC013_connectRelatedAccountRefresh();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}