@isTest
public with sharing class PASelectionControllerTest {

         @isTest
         public static void testInitPriceAgreementsAgent() {
             // Test: Correct List of PAs are returned for that agent
            User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
            Contact customerContact = [Select AccountId 
                                        From Contact 
                                        Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
            
            Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
            
            acct.GE_LGT_Rep_Code__c = '1234';
            update acct;

            SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
            pa.Customer_List__c = 'dummy,dummy,0000000123,dummy';
            insert pa;

			system.runAs(testUser) {
        
                Test.startTest();
                List<sObject> priceAgreementList = PASelectionController.initPriceAgreements();
                Test.stopTest();
                System.assertEquals(1, priceAgreementList.size(), 'initPriceAgreements returned incorrect results');
        	}             
         }
    
    
    @isTest
    public static void testInitPriceAgreementsCustomer() {
        // Test: Correct List of PAs are returned for that customer
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId 
                                    From Contact 
                                    Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
            
        acct.GE_LGT_Rep_Code__c = '1234';
        update acct;

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        pa.Customer_List__c = 'dummy,dummy,0000000123,dummy';
        insert pa;
        
        system.runAs(testUser) {
            // no u.Account.GE_LGT_Rep_Code__c, so should run as customer
            Test.startTest();
            List<sObject> priceAgreementList = PASelectionController.initPriceAgreements();
            System.assertEquals(1, priceAgreementList.size(), 'initPriceAgreements returned incorrect results');
            Test.stopTest(); 
        }

    }

    @isTest
         public static void testSearchPriceAgreementsAgent() {
             // Test: Correct List of PAs are returned for that agent
            User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
            Contact customerContact = [Select AccountId 
                                        From Contact 
                                        Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
            
            Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
            
            acct.GE_LGT_Rep_Code__c = '1234';
            update acct;

            SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
            pa.Customer_List__c = 'dummy,dummy,0000000123,dummy';
            insert pa;

			system.runAs(testUser) {
                Test.startTest();
                List<sObject> priceAgreementList = PASelectionController.searchForPAs('test');
                System.assertEquals(1, priceAgreementList.size());
                Test.stopTest(); 
        	}             
         }
    
    
    @isTest
    public static void testSearchPriceAgreementsCustomer() {
        // Test: Correct List of PAs are returned for that customer
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId 
                                    From Contact 
                                    Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        Account acct = [SELECT Id, SAP_Parent_Customer_No__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
            
        acct.SAP_Parent_Customer_No__c = '0000000123_test';
        update acct;

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Description__c='test description', Expiration_Date__c = System.today().addDays(1));
        pa.Customer_List__c = 'dummy,dummy,0000000123,dummy';
        insert pa;
        
        system.runAs(testUser) {
            // no u.Account.GE_LGT_Rep_Code__c, so should run as customer
            Test.startTest();
            List<sObject> priceAgreementList = PASelectionController.searchForPAs('test description');
            System.assertEquals(1, priceAgreementList.size());
            Test.stopTest(); 
        }

    }
    

    /*@isTest
    public static void testModify(){
        // Test: Correct URL string is returned for given User
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId 
                                    From Contact 
                                    Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        acct.GE_LGT_Rep_Code__c = '1234';
        update acct;

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        pa.Customer_List__c = 'dummy,dummy,0000000123,dummy';
        insert pa;

        system.runAs(testUser) {
            ccrz__E_Product__c product = new ccrz__E_Product__c();
			product.ccrz__SKU__c = 'Test SKU';
			product.ccrz__ProductId__c = '543513-340';
			product.Name = 'Test Product';
			product.ccrz__Quantityperunit__c = 1;
			product.ccrz__Storefront__c = 'DefaultStore';
			product.ccrz__ProductStatus__c = 'Released';
			product.ccrz__InventoryType__c = 'STANDARD';
			product.ccrz__ProductType__c = 'Product';
            insert product;

            ccrz__E_Product__c product2 = new ccrz__E_Product__c();
			product2.ccrz__SKU__c = 'Test SKU 2';
			product2.ccrz__ProductId__c = '543513-3402';
			product2.Name = 'Test Product 2';
			product2.ccrz__Quantityperunit__c = 1;
			product2.ccrz__Storefront__c = 'DefaultStore';
			product2.ccrz__ProductStatus__c = 'Released';
			product2.ccrz__InventoryType__c = 'STANDARD';
			product2.ccrz__ProductType__c = 'Product';
            insert product2;

			ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
            cart.ccrz__Account__c = customerContact.AccountId;
            cart.ccrz__Name__c = 'testCart';
            insert cart;

            ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart.Id;
            cartItem.ccrz__Quantity__c = 1;
            cartItem.ccrz__Price__c = 1.00;
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__Product__c = product.Id;
            insert cartItem;


            Test.startTest();
            String priceAgreementURL = PASelectionController.modify('test', true);
            Test.stopTest();
            System.assertNotEquals(null, priceAgreementURL);

        }

    }
*/
    
    @testSetup static void setupTestData() {
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
    }

}