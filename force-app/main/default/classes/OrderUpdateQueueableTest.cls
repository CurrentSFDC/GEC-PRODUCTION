@isTest
public with sharing class OrderUpdateQueueableTest {
    @isTest
    public static void test(){
        ccrz__E_Order__c o = [SELECT Id, Agreement_Number__c FROM ccrz__E_Order__c WHERE ccrz__EncryptedId__c = 'ORD-00000'];
        o.Agreement_Number__c = 'after';

        Test.startTest();        
        System.enqueueJob(new OrderUpdateQueueable(new List<ccrz__E_Order__c>{o}));
        Test.stopTest();

        ccrz__E_Order__c o2 = [SELECT Id, Agreement_Number__c FROM ccrz__E_Order__c WHERE ccrz__EncryptedId__c = 'ORD-00000'];
        System.assertEquals('after', o2.Agreement_Number__c);
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
            cart.Order_Type__c = 'Purchase Order';
            insert cart;

        ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
            ccrz__Account__c = customerContact.AccountId,
            ccrz__EncryptedId__c = 'ORD-00000',
            ccrz__OriginatedCart__c = cart.Id,
            ccrz__Contact__c = customerContact.Id,
            Agreement_Number__c = 'before'
        );
        insert testOrder;
    }
}