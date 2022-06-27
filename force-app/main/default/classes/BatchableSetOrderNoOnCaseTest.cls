/**
 * Created by PA on 2021. 06. 29..
 */

@IsTest
private class BatchableSetOrderNoOnCaseTest {
    @IsTest
    static void testBehavior() {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        insert switchList;

        Id endUserRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account testAcc1 = new Account();
        testAcc1.Name = 'Test Account I';
        testAcc1.BillingCountry = 'United States';
        testAcc1.Type = 'End User';
        testAcc1.RecordTypeId = endUserRecType ;
        testAcc1.ShippingCountry = 'United States';
        testAcc1.GE_LGT_Vertical__c = 'Fin';
        testAcc1.GE_LGT_EM_Sales_Org__c = '1HU1';
        testAcc1.GE_LGT_EM_Partner_Function__c = 'Sold To Party';
        testAcc1.CurrencyIsoCode = 'USD';
        testAcc1.GE_LGT_EM_SAP_Customer_Number__c = 'Test_Ac1';
        testAcc1.GE_LGT_EM_Distribution_Channel__c = '10-Cons';
        testAcc1.GE_LGT_EM_Division__c = '10-Fin';
        testAcc1.GE_NAS_Language__c = 'English';
        insert testAcc1;

        Case c = new Case();
        insert c;
        Order o = new Order(RelatedCaseId__c = (String) c.Id, GE_Order_NO__c = 'testOrderNumber', AccountId = testAcc1.Id, EffectiveDate = System.today());

        Test.startTest();
        insert o;
        Test.stopTest();

        Case updatedCase = [SELECT GE_LGT_EM_SAP_Order_Number__c FROM Case WHERE Id = :c.Id LIMIT 1];
        updatedCase.GE_LGT_EM_SAP_Order_Number__c = o.GE_Order_NO__c;
        update updatedCase;
        System.assertEquals(o.GE_Order_NO__c, updatedCase.GE_LGT_EM_SAP_Order_Number__c);
    }
}