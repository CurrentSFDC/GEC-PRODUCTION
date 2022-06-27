@isTest
public class SC007_ProcessAgreementItems_test {

    static testmethod void testSchedule()
    {
        Test.startTest();
        SC007_ProcessAgreementItems schedule=new SC007_ProcessAgreementItems();
        schedule.execute(NULL);
       Test.stopTest();
    }
}