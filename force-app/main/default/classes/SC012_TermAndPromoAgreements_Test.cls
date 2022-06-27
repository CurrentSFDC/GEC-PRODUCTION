@isTest
public with sharing class SC012_TermAndPromoAgreements_Test {
    public static testMethod void testschedule() {
		Test.StartTest();
		SC012_TermAndPromoAgreements testsche = new SC012_TermAndPromoAgreements();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}