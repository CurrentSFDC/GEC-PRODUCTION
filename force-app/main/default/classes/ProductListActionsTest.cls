@isTest
public class ProductListActionsTest {

    @testSetup
    private static void setupData() {
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
        b2bTestSetup.setupCart();
    }


    @IsTest public static void testCartService(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
        system.debug([select ccrz__Name__c from ccrz__E_Cart__c]);
        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);
            
            

            Test.startTest();
			system.debug([select ccrz__Name__c from ccrz__E_Cart__c]);
            ProductListActions.addInvalidSku(ctx, 'testSku', 10.00, 1,'abc',cart.ccrz__EncryptedId__c,'testSku');
            Test.stopTest();

        }
    }

	@IsTest public static void testCartServiceV2(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
		system.debug(cart);
        //system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

            Test.startTest();

			system.debug(ctx.currentCartId);
            ProductListActions.addInvalidSku(ctx, 'testSku', 10.00, 1,'abc',cart.ccrz__EncryptedId__c,'testSku');
            Test.stopTest();
		
        //}
    }

    @IsTest public static void testCartServiceExternalItem(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
        
       // system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

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
			ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart.Id;
            cartItem.ccrz__Quantity__c = 1;
            cartItem.ccrz__Price__c = 0;
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__PricingType__c = 'attrGroup';
            cartItem.ccrz__Product__c = product.Id;
        cartItem.Type_Marks__c = 'Test';
            insert cartItem;            
            
            Test.startTest();
            ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 1, 10.00,'Test','PC');
            ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 1, 10.00,'Test1','PC');

            //ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 4, 10.00);
            Test.stopTest();

       // }
    }

    @IsTest public static void testCartServiceExternalItem22(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
        
       // system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

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
			ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart.Id;
            cartItem.ccrz__Quantity__c = 1;
            cartItem.ccrz__Price__c = 0;
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__PricingType__c = 'attrGroup';
            cartItem.ccrz__Product__c = product.Id;
			cartItem.ccrz__UnitOfMeasure__c = 'PC';
            insert cartItem;            
            
            Test.startTest();
            ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 1, 10.00,'','PC');
            Test.stopTest();

       // }
    }

	@IsTest public static void testCartServiceExternalItemPart2(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
        
       // system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

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
			            
            
            Test.startTest();
            ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 1, 10.00,'Test','PC');

            //ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 4, 10.00);
            Test.stopTest();

       // }
    }
    
    @IsTest public static void testAddBatchPricedItem(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];

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
            cartItem2.ccrz__SelectedAttr__c = attr.Id;
            insert cartItem2;

            ccrz__E_CartItem__c cartItem3 = new ccrz__E_CartItem__c();
            cartItem3.ccrz__Cart__c = cart.Id;
            cartItem3.ccrz__Quantity__c = 1;
            cartItem3.ccrz__Price__c = 1.0;
            cartItem3.ccrz__cartItemType__c = 'Minor';
            cartItem3.ccrz__ProductType__c = 'Product';
            cartItem3.ccrz__PricingType__c = 'external';
            cartItem3.ccrz__ParentCartItem__c = cartItem.Id;
            cartItem3.ccrz__Product__c = product.Id;
            cartItem3.ccrz__PrimaryAttr__c = attr.Id;
            cartItem3.ccrz__SelectedAttr__c = attr.Id;
            cartItem3.ccrz__UnitOfMeasure__c = 'EA';
            insert cartItem3;
            
            
            String json= '['+
            '        {'+
            '            "attrs": ['+
            '                {'+
            '                    "sfid": "'+attr.Id+'",'+
            '                    "attrId": "a6m2D00000059bxQAA-EA_attr",'+
            '                    "displayName": "<p>EA</p>"'+
            '                }'+
            '            ],'+
            '            "sku": "Test SKU",'+
            '            "qty": "1",'+
            '            "price": 9,'+
            '            "total": 9,'+
            '            "hash": "'+attr.Id+'"'+
            '        }'+
            '    ]';
        
        //system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

            Test.startTest();
            ProductListActions.addBatchPricedItem(ctx, ctx.currentCartId, 'Test SKU', json);
            
            Test.stopTest();

       // }
    }

	@IsTest public static void testAddBatchPricedItemV2(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];

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
            cartItem2.ccrz__SelectedAttr__c = attr.Id;
            insert cartItem2;

            ccrz__E_CartItem__c cartItem3 = new ccrz__E_CartItem__c();
            cartItem3.ccrz__Cart__c = cart.Id;
            cartItem3.ccrz__Quantity__c = 1;
            cartItem3.ccrz__Price__c = 1.0;
            cartItem3.ccrz__cartItemType__c = 'Minor';
            cartItem3.ccrz__ProductType__c = 'Product';
            cartItem3.ccrz__PricingType__c = 'external';
            cartItem3.ccrz__ParentCartItem__c = cartItem.Id;
            cartItem3.ccrz__Product__c = product.Id;
            cartItem3.ccrz__PrimaryAttr__c = attr.Id;
            cartItem3.ccrz__SelectedAttr__c = attr.Id;
            cartItem3.ccrz__UnitOfMeasure__c = 'EA';
            //insert cartItem3;
            
            
            String json= '['+
            '        {'+
            '            "attrs": ['+
            '                {'+
            '                    "sfid": "'+attr.Id+'",'+
            '                    "attrId": "a6m2D00000059bxQAA-EA_attr",'+
            '                    "displayName": "<p>EA</p>"'+
            '                }'+
            '            ],'+
            '            "sku": "Test SKU",'+
            '            "qty": "1",'+
            '            "price": 9,'+
            '            "total": 9,'+
            '            "hash": "'+attr.Id+'"'+
            '        }'+
            '    ]';
        
        //system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

            Test.startTest();
            ProductListActions.addBatchPricedItem(ctx, ctx.currentCartId, 'Test SKU', json);
            
            Test.stopTest();

       // }
    }

    //sagar changes
      @IsTest public static void testCartServiceExternalItem1(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
        
        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

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
		          
            
            Test.startTest();
            ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 1, 10.00,'Test','PC');
            //ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 4, 10.00);
            Test.stopTest();

       }
    }

    @IsTest public static void testCartServiceExternalItemV2(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];

        // system.runAs(testUser) {

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(ctx);

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
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c = cart.Id;
        cartItem.ccrz__Quantity__c = 1;
        cartItem.ccrz__Price__c = 0;
        cartItem.ccrz__cartItemType__c = 'Major';
        cartItem.ccrz__ProductType__c = 'Product';
        cartItem.ccrz__PricingType__c = 'attrGroup';
        cartItem.ccrz__Product__c = product.Id;
        insert cartItem;

        Test.startTest();
        ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 1, 10.00,'Test1','PC');
        ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 1, 10.00,'','PC');
        ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 1, 10.00,'Test1','PC');


        //ProductListActions.addExtPricedItem(ctx, ctx.currentCartId, 'Test SKU', product.Id, 4, 10.00);
        Test.stopTest();

        // }
    }

    @IsTest public static void testCartServiceExternalItemV3(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];

        // system.runAs(testUser) {

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(ctx);

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
        product2.ccrz__SKU__c = 'Test SKU2';
        product2.ccrz__ProductId__c = '543513-341';
        product2.Name = 'Test Product1';
        product2.ccrz__Quantityperunit__c = 1;
        product2.ccrz__Storefront__c = 'DefaultStore';
        product2.ccrz__ProductStatus__c = 'Released';
        product2.ccrz__InventoryType__c = 'STANDARD';
        product2.ccrz__ProductType__c = 'Product';
        insert product2;

        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c = cart.Id;
        cartItem.ccrz__Quantity__c = 1;
        cartItem.ccrz__Price__c = 0;
        cartItem.ccrz__cartItemType__c = 'Major';
        cartItem.ccrz__ProductType__c = 'Product';
        cartItem.ccrz__PricingType__c = 'attrGroup';
        cartItem.ccrz__Product__c = product.Id;
        insert cartItem;

        ccrz__E_CartItem__c cartItem3 = new ccrz__E_CartItem__c();
        cartItem3.ccrz__Cart__c = cart.Id;
        cartItem3.ccrz__Quantity__c = 1;
        cartItem3.ccrz__Price__c = 0;
        cartItem3.ccrz__cartItemType__c = 'Major';
        cartItem3.ccrz__ProductType__c = 'Product';
        cartItem3.ccrz__PricingType__c = 'attrGroup';
        cartItem3.ccrz__Product__c = product2.Id;
        insert cartItem3;

        ccrz__E_CartItem__c cartItem1 = cartItem.clone();
        insert cartItem1;


        Test.startTest();
        try {
            ProductListActions.addExtPricedItemForCommisionWidget(ctx, null, 'Test SKU', product.Id, 1, 10.00,'Test1','PC');
            ProductListActions.addExtPricedItemForCommisionWidget(ctx, '9062I000000QwN2QAK', 'Test SKU', null, 1, 10.00,'Test1','PC');
            ProductListActions.retrieveCartItemWithSameProductId(ctx.currentCartId,product.Id);

        }
        catch (Exception e){
            System.debug('problemo');
        }


        Test.stopTest();

        // }
    }
    @IsTest public static void testRemainingGoods(){
        ProductListActions pla = new ProductListActions();
        pla.isFirst = true;
    }

    @IsTest public static void testCartServiceExternalItemV5(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(ctx);

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
        product2.ccrz__SKU__c = 'Test SKU1';
        product2.ccrz__ProductId__c = '543513-341';
        product2.Name = 'Test Product1';
        product2.ccrz__Quantityperunit__c = 1;
        product2.ccrz__Storefront__c = 'DefaultStore';
        product2.ccrz__ProductStatus__c = 'Released';
        product2.ccrz__InventoryType__c = 'STANDARD';
        product2.ccrz__ProductType__c = 'Product';
        insert product2;

        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c = cart.Id;
        cartItem.ccrz__Quantity__c = 1;
        cartItem.ccrz__Price__c = 0;
        cartItem.ccrz__cartItemType__c = 'Major';
        cartItem.ccrz__ProductType__c = 'Product';
        cartItem.ccrz__PricingType__c = 'attrGroup';
        cartItem.ccrz__Product__c = product.Id;
        cartItem.ccrz__UnitOfMeasure__c ='PC';
        insert cartItem;

        ccrz__E_CartItem__c cartItem3 = new ccrz__E_CartItem__c();
        cartItem3.ccrz__Cart__c = cart.Id;
        cartItem3.ccrz__Quantity__c = 1;
        cartItem3.ccrz__Price__c = 0;
        cartItem3.ccrz__cartItemType__c = 'Major';
        cartItem3.ccrz__ProductType__c = 'Product';
        cartItem3.ccrz__PricingType__c = 'attrGroup';
        cartItem3.ccrz__Product__c = product2.Id;
        cartItem3.ccrz__UnitOfMeasure__c ='PC';
        insert cartItem3;

        ccrz__E_CartItem__c cartItem1 = cartItem.clone();
        insert cartItem1;

        Test.startTest();
        try {
            ProductListActions.addExtPricedItemForCommisionWidget(ctx, cart.ccrz__EncryptedId__c, 'Test SKU', product.Id, 1, 10.00,'Test1','PC');
        }
        catch (Exception e){
            System.debug('problemo');
        }
        Test.stopTest();

    }


    @IsTest public static void testCartServiceExternalItemV4(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(ctx);

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



        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c = cart.Id;
        cartItem.ccrz__Quantity__c = 1;
        cartItem.ccrz__Price__c = 0;
        cartItem.ccrz__cartItemType__c = 'Major';
        cartItem.ccrz__ProductType__c = 'Product';
        cartItem.ccrz__PricingType__c = 'attrGroup';
        cartItem.ccrz__Product__c = product.Id;

        insert cartItem;



        Test.startTest();
        try {
          //  ProductListActions.addExtPricedItemForCommisionWidget(ctx, cart.ccrz__EncryptedId__c, 'Test SKU', product.Id, 1, 10.00,'Test1','PC');
        }
        catch (Exception e){
            System.debug('problemo');
        }
        Test.stopTest();

    }

    // Causes too many SOQL between start and stop test. Needs to be fixed in code.
    @IsTest public static void testCartServiceExternalItemV6(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(ctx);

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
        product2.ccrz__SKU__c = 'Test SKU1';
        product2.ccrz__ProductId__c = '543513-341';
        product2.Name = 'Test Product1';
        product2.ccrz__Quantityperunit__c = 1;
        product2.ccrz__Storefront__c = 'DefaultStore';
        product2.ccrz__ProductStatus__c = 'Released';
        product2.ccrz__InventoryType__c = 'STANDARD';
        product2.ccrz__ProductType__c = 'Product';
        insert product2;

        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c = cart.Id;
        cartItem.ccrz__Quantity__c = 1;
        cartItem.ccrz__Price__c = 0;
        cartItem.ccrz__cartItemType__c = 'Major';
        cartItem.ccrz__ProductType__c = 'Product';
        cartItem.ccrz__PricingType__c = 'attrGroup';
        cartItem.ccrz__Product__c = product.Id;
        cartItem.ccrz__UnitOfMeasure__c ='PC';
        insert cartItem;

        ccrz__E_CartItem__c cartItem3 = new ccrz__E_CartItem__c();
        cartItem3.ccrz__Cart__c = cart.Id;
        cartItem3.ccrz__Quantity__c = 1;
        cartItem3.ccrz__Price__c = 0;
        cartItem3.ccrz__cartItemType__c = 'Major';
        cartItem3.ccrz__ProductType__c = 'Product';
        cartItem3.ccrz__PricingType__c = 'attrGroup';
        cartItem3.ccrz__Product__c = product2.Id;
        cartItem3.ccrz__UnitOfMeasure__c ='PC';
        insert cartItem3;

        ccrz__E_CartItem__c cartItem1 = cartItem.clone();
        insert cartItem1;

        Test.startTest();
        try {
            ProductListActions.addExtPricedItemForCommisionWidget(ctx, cart.ccrz__EncryptedId__c, 'Test SKU', product.Id, 1, 10.00,'Test1','PC');
        }
        catch (Exception e){
            System.debug('problemo');
        }
        Test.stopTest();

    }
    
	@IsTest public static void testCartServiceExternalItemV7(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(ctx);

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
        product2.ccrz__SKU__c = 'Test SKU1';
        product2.ccrz__ProductId__c = '543513-341';
        product2.Name = 'Test Product1';
        product2.ccrz__Quantityperunit__c = 1;
        product2.ccrz__Storefront__c = 'DefaultStore';
        product2.ccrz__ProductStatus__c = 'Released';
        product2.ccrz__InventoryType__c = 'STANDARD';
        product2.ccrz__ProductType__c = 'Product';
        insert product2;

        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c = cart.Id;
        cartItem.ccrz__Quantity__c = 1;
        cartItem.ccrz__Price__c = 0;
        cartItem.ccrz__cartItemType__c = 'Major';
        cartItem.ccrz__ProductType__c = 'Product';
        cartItem.ccrz__PricingType__c = 'attrGroup';
        cartItem.ccrz__Product__c = product.Id;
        cartItem.ccrz__UnitOfMeasure__c ='PC';
        insert cartItem;

        ccrz__E_CartItem__c cartItem3 = new ccrz__E_CartItem__c();
        cartItem3.ccrz__Cart__c = cart.Id;
        cartItem3.ccrz__Quantity__c = 1;
        cartItem3.ccrz__Price__c = 0;
        cartItem3.ccrz__cartItemType__c = 'Major';
        cartItem3.ccrz__ProductType__c = 'Product';
        cartItem3.ccrz__PricingType__c = 'attrGroup';
        cartItem3.ccrz__Product__c = product2.Id;
        cartItem3.ccrz__UnitOfMeasure__c ='PC';
		cartItem.Type_Marks__c = 'Test1';
        insert cartItem3;

        ccrz__E_CartItem__c cartItem1 = cartItem.clone();
        insert cartItem1;

        Test.startTest();
        try {
            ProductListActions.addExtPricedItemForCommisionWidget(ctx, cart.ccrz__EncryptedId__c, 'Test SKU', product.Id, 1, 10.00,'Test1','PC');
            ProductListActions.addExtPricedItemForCommisionWidget(ctx, cart.ccrz__EncryptedId__c, 'Test SKU', product.Id, 1, 10.00,'','PC');
        }
        catch (Exception e){
            System.debug('problemo');
        }
        Test.stopTest();
    }

    @IsTest public static void testCustomOrderBy(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account currentAcc = [SELECT ccrz__E_AccountGroup__c, Delivering_Plant__c FROM Account WHERE Id = :customerContact.AccountId];

        system.debug('currentAcc '+currentAcc);
        currentAcc.Delivering_Plant__c = 'ABC';
        update currentAcc;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        ccrz.cc_CallContext.initRemoteContext(ctx);

        system.debug('currentAcc '+currentAcc);

        ccrz__E_Product__c product = new ccrz__E_Product__c();
        product.ccrz__SKU__c = 'Test SKU';
        product.ccrz__ProductId__c = '543513-340';
        product.Name = 'Test Product';
        product.ccrz__Quantityperunit__c = 1;
        product.ccrz__Storefront__c = 'DefaultStore';
        product.ccrz__ProductStatus__c = 'Released';
        product.ccrz__InventoryType__c = 'STANDARD';
        product.ccrz__ProductType__c = 'Product';
        product.Total_Standard_Inventory__c = 100;
        product.Quickship__c = true;
        insert product;

        Inventory__c inv = new Inventory__c(
                QuickStock__c = 10,
                Stock__c = 10,
                Plant__c = 'ABC',
                CC_Product__c = product.id
        );
        insert inv;

        ccrz__E_Product__c product2 = new ccrz__E_Product__c();
        product2.ccrz__SKU__c = 'Test SKU1';
        product2.ccrz__ProductId__c = '543513-341';
        product2.Name = 'Test Product1';
        product2.ccrz__Quantityperunit__c = 1;
        product2.ccrz__Storefront__c = 'DefaultStore';
        product2.ccrz__ProductStatus__c = 'Released';
        product2.ccrz__InventoryType__c = 'STANDARD';
        product2.ccrz__ProductType__c = 'Product';
        product.Total_Standard_Inventory__c = 200;

        insert product2;

        List<ccrz__e_pricelistitem__c> plItems = [SELECT Id,ccrz__product__c,ccrz__startdate__c,ccrz__enddate__c FROM ccrz__e_pricelistitem__c WHERE ccrz__pricelist__c IN:ProductListActions.getPriceLists()];

        for (ccrz__e_pricelistitem__c pli : plItems) {
            pli.ccrz__product__c =  product.Id;
            pli.ccrz__startdate__c =  system.today();
            pli.ccrz__enddate__c =  system.today();
        }

        update plItems;

        ccrz__E_ProductIndex__c newPISearch = new ccrz__E_ProductIndex__c(
                ccrz__IndexPrice__c = '100',
                ccrz__Locale__c = 'en_US',
                ccrz__PriceLists__c = String.join(new List<Id>(ProductListActions.getPriceLists()), ','),
                ccrz__Product__c = product.id,
                ccrz__ProductName__c = product.Name,
                ccrz__ShortDescription__c = 'vmi',
                ccrz__SKU__c = '1234',
                ccrz__IndexCurrency__c = 'USD',
                ccrz__LastIndex__c = TRUE,
                ccrz__Active__c = True,
                ccrz__category__c = 'a762F0000009r8rQAA',
                ccrz__productstartdate__c = system.today(),
                ccrz__productenddate__c = system.today(),
                ccrz__productstatus__c = 'Released',
                ccrz__categorystartdate__c = system.today(),
                ccrz__categoryenddate__c = system.today(),
                ccrz__productcategorystartdate__c = system.today(),
                ccrz__productcategoryenddate__c = system.today(),
                ccrz__storefront__c = 'DefaultStore'
        );

        insert newPISearch;

        Test.startTest();

            ProductListActions.customOrderBy(ctx, 'DESC', 'SKU_24_48hr__c', new Map<String,String>(), 25,'', 'a762F0000009r8rQAA', 0);
            ProductListActions.customOrderBy(ctx, 'ASC', 'SKU_24_48hr__c', new Map<String,String>(), 25,'', 'a762F0000009r8rQAA', 0);
            ProductListActions.customOrderBy(ctx, 'DESC', 'Total_Standard_Inventory__c', new Map<String,String>(), 25,'', 'a762F0000009r8rQAA', 0);
            ProductListActions.customOrderBy(ctx, 'ASC', 'Total_Standard_Inventory__c', new Map<String,String>(), 25,'', 'a762F0000009r8rQAA', 0);

        Test.stopTest();


    }
}