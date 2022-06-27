/**
 * Created by PA on 2021. 06. 03..
 */

@IsTest
private class CustomerProductFamilyControllerTest {
    @IsTest
    static void testBehavior() {
        Account a1 = new Account(Name = 'Test1',
                GE_LGT_EM_Sales_Org__c = '10HU',
                GE_LGT_EM_Distribution_Channel__c = '20',
                GE_LGT_EM_Division__c = '10',
                GE_LGT_EM_SAP_Customer_Number__c = 'TestCustN1');
        insert a1;

        while([SELECT Unique_Data__c FROM Account WHERE ID = :a1.Id].Unique_Data__c == null){

        }
        System.debug([SELECT Unique_Data__c FROM Account WHERE ID = :a1.Id].Unique_Data__c);
        System.debug(a1);


        CustomerProductFamily__c c1 = new CustomerProductFamily__c(
                Name = a1.Name,
                SalesOrganization__c = a1.GE_LGT_EM_Sales_Org__c,
                DistributionChannel__c = a1.GE_LGT_EM_Distribution_Channel__c,
                Division__c = a1.GE_LGT_EM_Division__c,
                CustomerNumber__c = a1.GE_LGT_EM_SAP_Customer_Number__c,
                CustomerNumberRegionCounty__c = 'HU'
        );
        insert c1;
        System.debug(c1);

        //System.assertEquals(a1.Id, [SELECT SAPCustomerNumber__c FROM CustomerProductFamily__c WHERE Id = :c1.Id].SAPCustomerNumber__c);
    }
}