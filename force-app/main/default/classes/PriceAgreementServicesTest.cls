@isTest
public with sharing class PriceAgreementServicesTest {
    
    @isTest public static void testPAQueries(){

        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        Test.startTest();

        List<SAP_Price_Agreement__c> test1 = PriceAgreementServices.searchPriceAgreementAgent(acct.Id);
        System.assertEquals(3, test1.size());

        // List<SAP_Price_Agreement__c> test2 = PriceAgreementServices.searchPriceAgreementCustomer(acct.Id);
        // System.assertEquals(1, test2.size());

        List<SAP_Price_Agreement_Item__c> test3 = PriceAgreementServices.getValidPriceAgreementItems('test', 'sku');
        System.assertEquals(0, test3.size());

        List<SAP_Price_Agreement_Item__c> test4 = PriceAgreementServices.getItemsByAgreementNo('test');
        //System.assertEquals(1, test4.size());

        Set<String> skus = new Set<String>();
        skus.add('sku');
        Map<String,Boolean> mapSkuPA =  PriceAgreementServices.isPriceAgreementValidForTheseProducts(acct.Id, skus);
        //System.assertEquals(true, mapSkuPA.get('sku'));

        Test.stopTest();
    }

    @isTest public static void testNewPACustomerQuery(){

        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        acct.GE_LGT_EM_SAP_Customer_Number__c = 'dummy';
        acct.SAP_Parent_Customer_No__c = '0000000999_n3';
        update acct;

        Test.startTest();
        List<SAP_Price_Agreement__c> agreements = PriceAgreementServices.searchPriceAgreementCustomer(acct.Id);
        System.assertEquals(0, agreements.size());
        Test.stopTest();
    }

    @isTest public static void testNewPACustomerQueryParent(){

        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        Test.startTest();
        List<SAP_Price_Agreement__c> agreements = PriceAgreementServices.searchPriceAgreementCustomer(acct.Id);
        System.assertEquals(0, agreements.size());
        agreements = PriceAgreementServices.searchPriceAgreementCustomerOld(acct.Id);
        //getItemsByAgreementNoAndSkus();  
        Test.stopTest();
    }

    @testSetup static void setupTestData() {
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();

        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        acct.GE_LGT_EM_SAP_Customer_Number__c = '0000000123';
        update acct;

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        pa.Customer_List__c = 'dummy,dummy,0000000123,dummy';
        insert pa;

        SAP_Price_Agreement__c pa2 = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test2', Name = 'test PA2', Expiration_Date__c = System.today().addDays(1));
        pa2.Customer_List__c = '0000000123, dummy';
        insert pa2;

        SAP_Price_Agreement__c pa3 = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test3', Name = 'test PA3', Expiration_Date__c = System.today().addDays(1));
        pa2.Customer_List__c = '0000000999, dummy';
        insert pa3;

        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = 'test', Material_No__c = 'sku');
        insert pai;
    }
}