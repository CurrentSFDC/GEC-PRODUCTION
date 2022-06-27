@isTest
public with sharing class ccLogicCartValidateExtensionTest {
    @isTest
    public static void testProcessInput(){
        User testUser = [Select Id, Profile.Name From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        ccrz__E_Cart__c cart = [SELECT ccrz__EncryptedId__c, Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart' LIMIT 1];

        Map<String, Object> inputData = new Map<String, Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPICart.CART_ID => cart.Id,
            ccrz.ccApiCart.CART_IDLIST => new Set<String>{(String)cart.Id}
            //ccrz.ccAPICart.CART_ENCID => cart.ccrz__EncryptedId__c
        };
        System.runAs(testUser){
            ccLogicCartValidateExtension instance = new ccLogicCartValidateExtension();
            System.assertNotEquals(null,instance.processInput(inputData));
        }
    }

    @testSetup static void setupTestData() {

        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id =: customerContact.AccountId ];

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
            cart.ccrz__Name__c = 'testCart';
            cart.Serial_Number__c='12345678';
            cart.Strategic_Account__c='12345678';
            cart.ccrz__Contact__c=customerContact.Id;
            insert cart;

            ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart.Id;
            cartItem.ccrz__Quantity__c = 1;
            cartItem.ccrz__Price__c = 1.00;
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__Product__c = product.Id;
            insert cartItem;   
    }
}