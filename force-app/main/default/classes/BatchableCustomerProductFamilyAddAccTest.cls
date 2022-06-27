/**
 * Created by PA on 2021. 06. 03..
 */

@IsTest
private class BatchableCustomerProductFamilyAddAccTest {
    @IsTest
    static void testBehavior() {
        CustomerProductFamily__c c = new CustomerProductFamily__c(
                Name = 'Test1',
                SalesOrganization__c = '10HU',
                DistributionChannel__c = '20',
                Division__c = '10',
                CustomerNumber__c = 'TestCustNr',
                CustomerNumberRegionCounty__c = 'HU'
        );
        insert c;

        Account a = new Account(Name = 'Test1',
                GE_LGT_EM_Sales_Org__c = c.SalesOrganization__c,
                GE_LGT_EM_Distribution_Channel__c = c.DistributionChannel__c,
                GE_LGT_EM_Division__c = c.Division__c,
                GE_LGT_EM_SAP_Customer_Number__c = c.CustomerNumber__c);
        insert a;

        System.assertEquals(null, [SELECT SAPCustomerNumber__c FROM CustomerProductFamily__c WHERE Id = :c.Id].SAPCustomerNumber__c);

        Test.startTest();
        BatchableCustomerProductFamilyAddAccount batch = new BatchableCustomerProductFamilyAddAccount();
        Database.executeBatch(batch, 10);
        Test.stopTest();
        System.assertEquals(a.Id, [SELECT SAPCustomerNumber__c FROM CustomerProductFamily__c WHERE Id = :c.Id].SAPCustomerNumber__c);
    }
}