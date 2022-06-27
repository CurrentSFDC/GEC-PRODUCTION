@isTest
global with sharing class PriceAgreementToCartTest {
    
    @isTest public static void testSingleSku(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1), Extended_Description__c = 'Welcome to the test description field');
        insert pa;
        
        SAP_Price_Agreement_Customers__c pac = new SAP_Price_Agreement_Customers__c(Account__c = acct.Id, SAP_Price_Agreement__c = pa.Id);
        insert pac;

        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = 'test', Material_No__c = 'Test SKU', Quantity__c = 1);
        insert pai;

        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            PriceAgreementToCart patc = new PriceAgreementToCart('test');
            patc.toCart(true);
            Test.stopTest();
        }
    }
    
    @isTest public static void testSingleSku1(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1), Extended_Description__c = 'Welcome to the test description field');
        insert pa;
        
        SAP_Price_Agreement_Customers__c pac = new SAP_Price_Agreement_Customers__c(Account__c = acct.Id, SAP_Price_Agreement__c = pa.Id);
        insert pac;

        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = 'test', Material_No__c = 'Test SKU', Quantity__c = 1);
        insert pai;

        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            PriceAgreementToCart patc = new PriceAgreementToCart('test');
            patc.toCart(false);
            Test.stopTest();
        }
    }

    @isTest public static void testMultipleSkus(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1),Extended_Description__c = 'Welcome to the test description field');
        insert pa;
        
        SAP_Price_Agreement_Customers__c pac = new SAP_Price_Agreement_Customers__c(Account__c = acct.Id, SAP_Price_Agreement__c = pa.Id);
        insert pac;

        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = 'test', Material_No__c = 'Test SKU', Quantity__c = 1);
        insert pai;

        system.runAs(testUser) {
            Test.startTest(); 
            PriceAgreementToCart patc = new PriceAgreementToCart('test');
            patc.toCart(new List<String> {'test SKU'});
            Test.stopTest();
        }
    }

    @isTest public static void testClearCart(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        insert pa;
        
        SAP_Price_Agreement_Customers__c pac = new SAP_Price_Agreement_Customers__c(Account__c = acct.Id, SAP_Price_Agreement__c = pa.Id);
        insert pac;

        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = 'test', Material_No__c = 'Test SKU', Quantity__c = 1);
        insert pai;

        system.runAs(testUser) {
          
            List<Map<String,Object>> activeCartData = new List<Map<String,Object>>{
                new Map<String,Object>{
                    'sfid' => cartItem.Id
                }
            };


            Test.startTest(); 

            PriceAgreementToCart patc = new PriceAgreementToCart('test');
            patc.clearCart(cart.Id, activeCartData);
            patc.toUrl(true);
            Test.stopTest();
        }
    }

   @testSetup public static void setupTestData() {

        b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		system.runAs(testUser){
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
}