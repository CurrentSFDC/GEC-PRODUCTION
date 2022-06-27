@isTest
public with sharing class SC02_TermAndPromoAgreement_Test {
    public static testMethod void testschedule() {

        Test.StartTest();
        SC012_TermAndPromoAgreements sh1 = new SC012_TermAndPromoAgreements();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); Test.stopTest(); }
}