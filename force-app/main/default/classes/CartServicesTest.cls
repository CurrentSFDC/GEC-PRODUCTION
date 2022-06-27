@IsTest 
public with sharing class CartServicesTest {
    
    

    @IsTest public static void testGetters(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id];
        
        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

            Map<String, Object> invalidSkuMap = new Map<String, Object>{
                'sku' => '123',
                'price' => 10.00,
                'qty' => 1,
                'cartId' => cart.Id
            };

            String cartId = CartServices.getActiveCartId();
            List<ccrz__E_CartItem__c> extSkus = CartServices.getCartItemExtSkusByCartId(cart.Id);
            ccrz__E_CartItem__c cartItem2 = CartServices.getCartItemById((String)cartItem.Id); 
            Test.startTest(); 
            CartServices.convertItemToExtPricing((String)cartItem.Id, cart.Id, 1.00);
            CartServices.changeSoldTo(cart.Id,customerContact.AccountId);
                CartServices.StrategicAccount(cart.Id,customerContact.AccountId);
            Test.stopTest();
        }
    }
    @isTest
    static void getCartItemsToUpdateTest() {
		
		ccrz__E_Cart__c  cr = new  ccrz__E_Cart__c();
       // cr.Name = 'Cart34';
        insert cr;
        Set<ccrz__E_CartItem__c> setCart = new Set<ccrz__E_CartItem__c>();
        
        
        ccrz__E_CartItem__c cci = new ccrz__E_CartItem__c();
        	cci.ccrz__Quantity__c = 2;
            cci.ccrz__Price__c = 220;
            cci.Small_Order_Fee__c = 20;
            cci.ccrz__SubAmount__c = 2;
            cci.ccrz__PricingType__c = 'auto';
            cci.Agreement_Number__c = '98765';
        	cci.ccrz__Cart__c = cr.Id;
        
        
        insert cci;     
        
        Set<Id> name = new Set<Id>();
        name.add(cci.Id);
        
        Test.startTest();
        CartServices.getCartItemsToUpdate(name);
        Test.stopTest();
        
                
       
    }
	@isTest 
    static void getCartByIdTest(){
       // SAP_Price_Agreement__c priceAgreement = [SELECT Description__c,Valid_From__c,Expiration_Date__c FROM SAP_Price_Agreement__c WHERE Agreement_No__c =: agreementNo];
        
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.ccrz__EncryptedId__c = cart.id;
        Test.startTest();
        		ccrz__E_Cart__c cart1 = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart1'];

        CartServices.getCartById(cart.id);
        CartServices.deleteRPA(cart1.id);
       // CartServices.setValidDates(cart1.id);
       CartServices.changeAgreementNumber(cart.id,'test');
        Test.stopTest();
        
    }

    @IsTest public static void testInvalidSku(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id];

        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

            Map<String, Object> invalidSkuMap = new Map<String, Object>{
                'sku' => '123',
                'price' => 10.00,
                'qty' => 1,
                'cartId' => cart.Id
            };

            Test.startTest();
            CartServices.addInvalidSku(invalidSkuMap);
            Test.stopTest();
        }
    }

    @IsTest public static void testAddExt(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id]; 
        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

            Test.startTest();
            CartServices.addExtPricedItem(cart.Id, 'Test SKU', 1, 10.00);
            Test.stopTest();
        }
    }

   /* @IsTest public static void testChangeAgreementNumber(){

		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
            Test.startTest();
            //CartServices.changeAgreementNumber(cart.Id, 'testing');
            cart = [SELECT Id, ccrz__EncryptedId__c, Agreement_Number__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
            System.assertEquals('null', cart.Agreement_Number__c);
            Test.stopTest();
    }*/
    

    @IsTest public static void testChangeOrderType(){

		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
            Test.startTest();
            CartServices.changeOrderType(cart.Id, 'testing');
            cart = [SELECT Id, ccrz__EncryptedId__c, Order_Type__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
            System.assertEquals('Purchase Order', cart.Order_Type__c);
            CartServices.changeOrderType(cart.Id, 'Price Agreement');
            cart = [SELECT Id, ccrz__EncryptedId__c, Order_Type__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
            System.assertEquals('Price Agreement', cart.Order_Type__c);
            Test.stopTest();
    }

    @IsTest public static void testChangeSoldTo(){

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
            Test.startTest();
            CartServices.changeSoldTo(cart.Id, (String)customerContact.AccountId);
            cart = [SELECT Id, ccrz__EncryptedId__c, Sold_To_Account__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
            System.assertEquals((String)customerContact.AccountId, cart.Sold_To_Account__c);
            Test.stopTest();
    }

    @IsTest public static void testChangeCartItemAgreementNo(){

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id];
            Test.startTest();
            CartServices.changeCartItemAgreementNo(cartItem.Id, 'testNumber');
            cartItem=[Select Id, Agreement_Number__c From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id];
            System.assertEquals('testNumber', cartItem.Agreement_Number__c);
            Test.stopTest();
    }

    @IsTest public static void testConvertAttr(){

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_Product__c product = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = 'Test SKU'];
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart.Id;
            cartItem.ccrz__Quantity__c = 1;
            cartItem.ccrz__Price__c = 0;
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__PricingType__c = 'attrGroup';
            cartItem.ccrz__Product__c = product.Id;
            insert cartItem;

            ccrz__E_Attribute__c attr = new ccrz__E_Attribute__c(ccrz__AttributeID__c = 'testAttr', Name = 'EA', ccrz__DisplayName__c = 'EA', ccrz__EffectiveStart__c = System.now(), ccrz__EffectiveEnd__c = System.now());
            insert attr;

            ccrz__E_CartItem__c cartItem2 = new ccrz__E_CartItem__c();
            cartItem2.ccrz__Cart__c = cart.Id;
            cartItem2.ccrz__Quantity__c = 1;
            cartItem2.ccrz__Price__c = 1.0;
            cartItem2.ccrz__cartItemType__c = 'Minor';
            cartItem2.ccrz__ProductType__c = 'Product';
            cartItem2.ccrz__PricingType__c = 'auto';
            cartItem2.ccrz__ParentCartItem__c = cartItem.Id;
            cartItem2.ccrz__Product__c = product.Id;
            cartItem2.ccrz__PrimaryAttr__c = attr.Id;
            insert cartItem2;

            SAP_Price_Agreement_Item__c pa = new SAP_Price_Agreement_Item__c(Agreement_No__c='testPA', Price_Per_EA__c = 2.0);
            insert pa;

            
            Test.startTest();
            CartServices.convertItemToExtPricingAttr(cartItem.Id, cart.Id , pa);
            Test.stopTest();

            cartItem=[Select ccrz__Price__c From ccrz__E_CartItem__c Where Id =: cartItem2.Id];
            System.assertEquals(2.0, cartItem.ccrz__Price__c);
    }

    @testSetup static void setupTestData() {

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
            cart.Strategic_Account_L__c=customerContact.AccountId;
            cart.Sold_To_Account__c=customerContact.AccountId;
            cart.ccrz__Name__c = 'testCart';
            insert cart;
            
            ccrz__E_Cart__c cart1 = new ccrz__E_Cart__c();
            cart1.ccrz__Account__c = customerContact.AccountId;
            cart1.ccrz__Name__c = 'testCart1';
            insert cart1;

            ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart.Id;
            cartItem.ccrz__Quantity__c = 1;
            cartItem.ccrz__Price__c = 1.00;
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__Product__c = product.Id;
			insert cartItem;
             Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
            SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        pa.Customer_List__c = 'dummy,dummy,0000000123,dummy';
        insert pa;

        } 
    }
}