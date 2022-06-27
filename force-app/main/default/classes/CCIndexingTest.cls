/*
Name - CCIndexingTest
Method- executeTest
Purpose - Test class for CCIndexing
*/  

@isTest
public class CCIndexingTest {
    static testMethod void testIndexing() {
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'test unsubscribe test';
        env.fromAddress = 'user@acme.com';
        // Call the class and test it with the data in the testMethod.
        Test.startTest();
        CCIndexing.CCADminTask();
        Test.stopTest();      
    }
        
}