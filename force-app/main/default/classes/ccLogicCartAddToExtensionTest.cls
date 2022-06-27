@isTest
public with sharing class ccLogicCartAddToExtensionTest {

  @IsTest public static void testNonDupe(){

    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
    Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
    
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

			ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
			cart.ccrz__Account__c = customerContact.AccountId;
      insert cart;

      ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
      cartItem.ccrz__Cart__c = cart.Id;
      cartItem.ccrz__Quantity__c = 1;
      cartItem.ccrz__Price__c = 1.00;
      cartItem.ccrz__cartItemType__c = 'Major';
      cartItem.ccrz__ProductType__c = 'Product';
      cartItem.ccrz__Product__c = product.Id;
      insert cartItem;


      List<Map<String, Object>> lineData = new List<Map<String, Object>>{
        new Map<String, Object>{
            ccrz.ccApiCart.LINE_DATA_SKU => 'test1',
            ccrz.ccApiCart.LINE_DATA_QUANTITY => 1,
            ccrz.ccApiCart.LINE_DATA_PRICE => 10.00,
            ccrz.ccAPICart.LINE_DATA_EXT_NAME => 'testExtName',
            ccrz.ccAPICart.LINE_DATA_EXT_SKU => 'testExtSku'
        }
    };

    Map<String, Object> cartItemsToAdd = new Map<String, Object> {
        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
        ccrz.ccApiCart.IS_PART_OF_BUNDLE => false,
        ccrz.ccApiCart.CURR_LINE_DATA => lineData[0],
        ccrz.ccApiCart.CURR_CARTITEM => cartItem
    };

    ccrz.ccLogicCartAddTo addTo = new ccrz.ccLogicCartAddTo();

    Map<String, Object> testInput = addTo.handlePricing(cartItemsToAdd);

    Test.startTest();
    ccLogicCartAddToExtension addToExt = new ccLogicCartAddToExtension();
    Map<String, Object> testResults = addToExt.priceExternalItem(testInput);
    System.debug(testResults);
    Test.stopTest();
    } 
  }

  @IsTest public static void testDupe(){

    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
    Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
    
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

			ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
			cart.ccrz__Account__c = customerContact.AccountId;
      insert cart;

      ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
      cartItem.ccrz__Cart__c = cart.Id;
      cartItem.ccrz__Quantity__c = 1;
      cartItem.ccrz__Price__c = 1.00;
      cartItem.ccrz__cartItemType__c = 'Major';
      cartItem.ccrz__ProductType__c = 'Product';
      cartItem.ccrz__Product__c = product.Id;
      cartItem.ccrz__ExtSKU__c = 'Test SKU';
      insert cartItem;

      List<Map<String, Object>> lineData = new List<Map<String, Object>>{
        new Map<String, Object>{
            ccrz.ccApiCart.LINE_DATA_SKU => 'Test SKU',
            ccrz.ccApiCart.LINE_DATA_QUANTITY => 1,
            ccrz.ccApiCart.LINE_DATA_PRICE => 10.00,
            ccrz.ccAPICart.LINE_DATA_EXT_NAME => 'testExtName',
            ccrz.ccAPICart.LINE_DATA_EXT_SKU => 'Test SKU'
        }
    };

    Map<String, Object> cartItemsToAdd = new Map<String, Object> {
        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
        ccrz.ccApiCart.IS_PART_OF_BUNDLE => false,
        ccrz.ccApiCart.CURR_LINE_DATA => lineData[0],
        ccrz.ccApiCart.CURR_CARTITEM => cartItem
    };

    ccrz.ccLogicCartAddTo addTo = new ccrz.ccLogicCartAddTo();

    Map<String, Object> testInput = addTo.handlePricing(cartItemsToAdd);

    Test.startTest();
    ccLogicCartAddToExtension addToExt = new ccLogicCartAddToExtension();
    Map<String, Object> testResults = addToExt.priceExternalItem(testInput);
    System.debug(testResults);
    Test.stopTest();
    } 
  }
  @testSetup static void setupTestData() {
      b2bTestSetup.setupPortalUsers();
      b2bTestSetup.setupPricelist();
  }
}