/**
 * Created by PA on 2021. 04. 28..
 */

@IsTest
private class SoldToAccountLookupControllerTest {
    @IsTest
    static void testBehavior() {
        Account a2 = new Account(Name = 'Test1',
                GE_LGT_EM_Sales_Org__c = '20HU',
                GE_LGT_EM_Distribution_Channel__c = '10',
                GE_LGT_EM_Division__c = '20',
                GE_LGT_EM_SAP_Customer_Number__c = 'TestCustN2');
        insert a2;
        SoldToAccountLookupController.getSoldToAccounts('test',a2.id);
        SoldToAccountLookupController.getSoldToAccount(a2.id);
        SoldToAccountLookupController.getSoldToAccountByHeadId(a2.id);
    }
}