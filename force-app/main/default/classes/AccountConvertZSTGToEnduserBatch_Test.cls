@isTest
public class AccountConvertZSTGToEnduserBatch_Test 
{
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void AccountConvertZSTGTest()
    {
        //Inserting Account of Record Type SAP Account - Strategic with Customer Active Flag as TRUE
        ID recACCSAS=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.GE_LGT_EM_CustomerActiveFlag__c=False;
        acc.RecordTypeId=recACCSAS;
        insert acc;
        
        //Initilizating the batch class AccountSheduleingForZSTGToEnduser to convert the Account to End User
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,new AccountSheduleingForZSTGToEnduser());
        Test.stopTest();
        
       
    }
}