@isTest
public with sharing class CartDetailActionsTest {

    // @isTest public static void testApplyCustomPriceAttr(){
    //     List<ccrz__E_CartItem__c> itemsList = [SELECT Id FROM ccrz__E_CartItem__c];
    //     ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
    //     CartDetailActions.applyCustomPriceAttr(ctx, itemsList[0].Id, 100, 2);
    //     ccrz__E_CartItem__c updatedItem = [SELECT Id, ccrz__Quantity__c, ccrz__Price__c FROM ccrz__E_CartItem__c WHERE Id =: itemsList[0].Id];
    //     System.assertEquals(2, updatedItem.ccrz__Quantity__c);
    //     System.assertEquals(100, updatedItem.ccrz__Price__c);
    // }

    @isTest public static void testUpdateQty(){
        List<ccrz__E_CartItem__c> itemsList = [SELECT Id FROM ccrz__E_CartItem__c];
        String json = '{"'+itemsList[0].Id+'": "20"}';
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        CartDetailActions.updateItemQty(ctx, json);
        ccrz__E_CartItem__c updatedItem = [SELECT Id, ccrz__Quantity__c, ccrz__Price__c FROM ccrz__E_CartItem__c WHERE Id =: itemsList[0].Id];
        System.assertEquals(20, updatedItem.ccrz__Quantity__c);
    }

    @isTest public static void testAttributeMapForUnitOfMeasures(){
        List<ccrz__E_Attribute__c> measureList = new List<ccrz__E_Attribute__c>();
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ccrz__E_Attribute__c attr1 = new ccrz__E_Attribute__c(ccrz__AttributeID__c = 'testAttr', Name = 'Unit of Measure', ccrz__DisplayName__c = 'Unit of Measure', ccrz__EffectiveStart__c = System.now(), ccrz__EffectiveEnd__c = System.now());
        insert attr1;
        ccrz__E_Attribute__c attr2 = new ccrz__E_Attribute__c(ccrz__AttributeID__c = 'testAttr', Name = 'EA', ccrz__DisplayName__c = 'EA', ccrz__EffectiveStart__c = System.now(), ccrz__EffectiveEnd__c = System.now(), ccrz__ParentAttribute__c = attr1.Id);
        insert attr2;
        Test.startTest();
        measureList = CartDetailActions.getAttributeMapForUnitOfMeasures(ctx);
        Test.stopTest();        
        System.assertEquals(1, measureList.size());
    }
    @isTest public static void testAttributeMapForUnitOfMeasures1(){
        List<ccrz__E_Attribute__c> measureList = new List<ccrz__E_Attribute__c>();
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ccrz__E_Attribute__c attr1 = new ccrz__E_Attribute__c(ccrz__AttributeID__c = 'testAttr', Name = 'Test', ccrz__DisplayName__c = 'Unit of Measure', ccrz__EffectiveStart__c = System.now(), ccrz__EffectiveEnd__c = System.now());
        insert attr1;
        ccrz__E_Attribute__c attr2 = new ccrz__E_Attribute__c(ccrz__AttributeID__c = 'testAttr', Name = 'EA', ccrz__DisplayName__c = 'EA', ccrz__EffectiveStart__c = System.now(), ccrz__EffectiveEnd__c = System.now(), ccrz__ParentAttribute__c = attr1.Id);
        insert attr2;
        Test.startTest();
        measureList = CartDetailActions.getAttributeMapForUnitOfMeasures(ctx);
        Test.stopTest();         
        System.assertEquals(0, measureList.size());
    }
	
    @isTest public static void testUpdateSampleOrder(){
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c];
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            Test.startTest(); 
            CartDetailActions.updateSampleOrder(ctx, true);
            Test.stopTest();
        }
        cart = [SELECT Id, Sample_Order__c FROM ccrz__E_Cart__c Where Id=:cart.Id];
        System.assertEquals(true, cart.Sample_Order__c);
    }
    
    @isTest public static void testSoldToSearch(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
        acct.GE_LGT_Rep_Code__c='TestRep';
        acct.ConnectFixtureAgents__c='TestRep';
        update acct;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.effAccountId = customerContact.AccountId;

        Test.startTest();
        List<Account> test1 = CartDetailActions.initSearchSoldTo(ctx, customerContact.Id);
        System.assertEquals(1, test1.size());
        Test.stopTest();
    }

    @isTest public static void testPASearchAgent(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        
        insert pa;

        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = 'test', Material_No__c = 'sku', ValidTo__c = System.today().addDays(1) , DeletionFlag__c ='');
        pai.Price_Agreement__c=pa.id;
        
        insert pai;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();

        Test.startTest();
        List<SAP_Price_Agreement__c> test1 = CartDetailActions.initSearchPriceAgreement(ctx, true, acct.Id);
        //System.assertEquals(1, test1.size());
        Test.stopTest();
    }

    @isTest public static void testPASearchCustomer(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        acct.GE_LGT_EM_SAP_Customer_Number__c = 'testNumber';
        update acct;
        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Customer_List__c = 'testNumber,otherTestNumber,blah,blah', Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        insert pa;

        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00,Price_Per_BX__c = 1.00, Price_Per_CV__c = 1.00, Price_Per_EA__c = 1.00, Price_Per_ICV__c = 1.00,  Agreement_No__c = 'test', Material_No__c = 'sku');
        insert pai;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();

        Test.startTest();
        List<SAP_Price_Agreement__c> test1 = CartDetailActions.initSearchPriceAgreement(ctx, false, acct.Id);
        System.assertEquals(0, test1.size());
        Test.stopTest();
    }

    @isTest public static void testApplyPA(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id LIMIT 1];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];

        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        insert pa;
        
        SAP_Price_Agreement_Customers__c pac = new SAP_Price_Agreement_Customers__c(Account__c = acct.Id, SAP_Price_Agreement__c = pa.Id);
        insert pac;

        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = '000000test', Material_No__c = 'Test SKU', ValidTo__c = system.today(), ValidFrom__c = system.today(),Item_Description__c = 'Test SKU');
        insert pai;

		system.runAs(testUser){

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.applyPriceAgreement(ctx, 'test', String.valueOf(cartItem.Id), 'Test SKU');
            Test.stopTest();
        }
    }

    @isTest public static void testApplyPANoValidItems(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id LIMIT 1];
        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
        insert pa;
        
        SAP_Price_Agreement_Customers__c pac = new SAP_Price_Agreement_Customers__c(Account__c = acct.Id, SAP_Price_Agreement__c = pa.Id);
        insert pac;

		system.runAs(testUser){

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.applyPriceAgreement(ctx, 'test', cartItem.Id, 'Test SKU');
            Test.stopTest();
        }
    }

    @isTest public static void testApplyCustomPrice(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id LIMIT 1];
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.applyCustomPrice(ctx, cartItem.Id, 1.00);
            CartDetailActions.applyQuantIncr(ctx, cartItem.Id, 1.00);
            CartDetailActions.applyQuantDecr(ctx, cartItem.Id, 1.00);
            Test.stopTest();
        }
    }

    @isTest public static void testChangeOrderType(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.changeOrderType(ctx, 'Price Agreement');
            Test.stopTest();
        }
    }
    
    @isTest public static void testchangeSoldToOnCart(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            //CartDetailActions.changeSoldToOnCart(ctx, customerContact.AccountId,cart.ccrz__EncryptedId__c);
            Test.stopTest();
        }
    }
    
    @isTest public static void testStrategicAccount(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.StrategicAccount(ctx, customerContact.AccountId,cart.ccrz__EncryptedId__c);
            Test.stopTest();
        }
    }
    
    //sagar changes
     @isTest public static void TestchangeOrderTypeNew(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.changeOrderTypeNew(ctx, 'Price Agreement', cart.id);
            Test.stopTest();
        }
    }
    
    

 @isTest public static void testvalidateOrderBeforeCheckout(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
  		acct.Account_Group__c='ZEAG';
       acct.Customer_Segmentation__c='FD';
       update acct;	
     ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
     cart.ccrz__Account__c= acct.id;
     update cart;
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            Test.setMock(WebServiceMock.class, new gecurrentCom475AgreementpriceMock());
            Test.startTest();
            CartDetailActions.validateOrderBeforeCheckout(ctx, true, '');
            Test.stopTest();
        }
    }

    @isTest public static void testupdateRequestedDeliveryDate(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id Limit 1];
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.updateRequestedDeliveryDate(ctx,cartItem.Id, '2022-12-25', false);
            CartDetailActions.updateRequestedDeliveryDate(ctx,cartItem.Id, '2022-12-25', true);
            Test.stopTest();
        }
    }

    @isTest public static void testupdateTypeMarks(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id Limit 1];
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.updateTypeMarks(ctx,cartItem.Id, 'test type marks', false);
            CartDetailActions.updateTypeMarks(ctx,cartItem.Id, 'test type marks', true);
            Test.stopTest();
        }
    }

    @isTest public static void testChangeSoldTo(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT Id, Name FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();

        Test.startTest();
        ccrz.cc_RemoteActionResult res = CartDetailActions.changeSoldTo(ctx, acct.Id, cart.Id);
        System.assertEquals(true, res.success);
        Test.stopTest();
    }

    @isTest public static void testvalidatePABeforeCheckout(){

        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.Order_Type__c = 'Price Agreement';
        update cart;
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ctx.userIsoCode = 'USD';
            Test.startTest();
            CartDetailActions.validateOrderBeforeCheckout(ctx, false,'');
            Test.stopTest();
        }
    }

    @isTest public static void testvalidateRevisePABeforeCheckout(){

        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.Order_Type__c = 'Revise Price Agreement';
        cart.Agreement_Number__c = 'testNumber';
        update cart;
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ctx.userIsoCode = 'USD';
            Test.startTest();
            CartDetailActions.validateOrderBeforeCheckout(ctx, false,'');
            Test.stopTest();
        }
    }

    @isTest public static void testupdateCartItems(){

        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        List<ccrz__E_CartItem__c> itemsList = [SELECT Id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c =: cart.Id];
        String items = '';
        for(ccrz__E_CartItem__c item : itemsList){
            items += (String)item.Id + ':2,';
        }
        cart.Order_Type__c = 'Revise Price Agreement';
        cart.Agreement_Number__c = 'testNumber';
        update cart;
         
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ctx.userIsoCode = 'USD';
            Test.startTest();
            CartDetailActions.updateCartItems(ctx, items);
            Test.stopTest();
        }
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

            SAP_Price_Agreement_Item__c pa = new SAP_Price_Agreement_Item__c(Agreement_No__c='testPA', Price_Per_EA__c = 2.0, Material_No__c = 'Test SKU');
            insert pa;

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();

            Test.startTest();
            CartDetailActions.applyPriceAgreementAttr(ctx, 'testPA', cartItem.Id, 'Test SKU');
            Test.stopTest();

            cartItem=[Select ccrz__Price__c From ccrz__E_CartItem__c Where Id =: cartItem2.Id];
            System.assertEquals(1.0, cartItem.ccrz__Price__c);
    }

    
    @IsTest public static void testApplyCustomPriceAttr(){

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

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();

            Test.startTest();
            CartDetailActions.applyCustomPriceAttr(ctx, cartItem2.Id, 10.00, 2);
            Test.stopTest();

            cartItem=[Select ccrz__Price__c From ccrz__E_CartItem__c Where Id =: cartItem2.Id];
            System.assertEquals(10.00, cartItem.ccrz__Price__c);
    }




    @testSetup static void setupTestData() {

        b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        // AccountContactRelation relation = new AccountContactRelation(AccountId = customerContact.AccountId, contactId = customerContact.Id);
        // insert relation;
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
            cartItem.ccrz__UnitOfMeasure__c='CV';
            cartItem.ccrz__ExtSKU__c ='1';
            cartItem.ccrz__RequestDate__c=date.today();
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__Product__c = product.Id;
            insert cartItem;
            
            ccrz__E_CartItem__c cartItem2 = new ccrz__E_CartItem__c();
            cartItem2.ccrz__Cart__c = cart.Id;
            cartItem2.ccrz__Quantity__c = 1;
            cartItem2.ccrz__Price__c = 1.00;
            cartItem.ccrz__ExtSKU__c ='1';
            cartItem2.ccrz__UnitOfMeasure__c='CV';
            cartItem2.ccrz__RequestDate__c=date.today();
            
            cartItem2.ccrz__cartItemType__c = 'Major';
            cartItem2.ccrz__ProductType__c = 'Product';
            cartItem2.ccrz__Product__c = product.Id;
			insert cartItem2;
        } 
    }
    
    //TCS changes
    
   @IsTest public static void TestapplyHeaderPriceAgreement(){
            
                 Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());
   //ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
       User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
       // Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
       Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
  		acct.Account_Group__c='ZEAG';
       acct.Customer_Segmentation__c='FD';
       update acct;
       ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c,Sold_To_Account__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.ccrz__Account__c = acct.id;
       update cart;
		 ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id Limit 1];

           
			//ccrz__E_Cart__c cart1 =CartServices.getCartById(CartServices.getActiveCartId());
		//ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c,Sold_To_Account__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
       //ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c, Sold_To_Account__c FROM ccrz__E_Cart__c WHERE id =: cart1.id];
       // cart.Sold_To_Account__c = acc.id;
          //   system.debug(cart.Sold_To_Account__c);
       // system.runAs(testUser) {
		 //  ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
          cart.Sold_To_Account__c = customerContact.AccountId;
            update cart;
     system.debug(cart.ID);			
		//ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        //ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id Limit 1];
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
                       Test.startTest(); 
			CartDetailActions.applyHeaderPriceAgreement(ctx, true, '123456'); 
           // CartDetailActions.applyHeaderPriceAgreement(ctx, false, '123456'); 
            Test.stopTest();
        }
    }
    
     @IsTest public static void TestapplyHeaderPriceAgreement1(){
            
                 Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());
   //ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
       User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
       // Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
       Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
  		acct.Account_Group__c='Z001';
       acct.Customer_Segmentation__c='FD';
         acct.GE_LGT_EM_Distribution_Channel__c='test';
       update acct;
       ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c,Sold_To_Account__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.ccrz__Account__c = acct.id;
       update cart;
		 ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id Limit 1];

           
			//ccrz__E_Cart__c cart1 =CartServices.getCartById(CartServices.getActiveCartId());
		//ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c,Sold_To_Account__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
       //ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c, Sold_To_Account__c FROM ccrz__E_Cart__c WHERE id =: cart1.id];
       // cart.Sold_To_Account__c = acc.id;
          //   system.debug(cart.Sold_To_Account__c);
       // system.runAs(testUser) {
		 //  ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
          cart.Sold_To_Account__c = customerContact.AccountId;
            update cart;
     system.debug(cart.ID);			
		//ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        //ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id Limit 1];
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
                       Test.startTest(); 
			CartDetailActions.applyHeaderPriceAgreement(ctx, true, '123456'); 
           // CartDetailActions.applyHeaderPriceAgreement(ctx, false, '123456'); 
            Test.stopTest();
        }
    }
    @isTest public static void testUpdateQty1(){
        List<ccrz__E_CartItem__c> itemsList = [SELECT Id FROM ccrz__E_CartItem__c];
        String json = '{"'+itemsList[0].Id+'", "20"}';
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        CartDetailActions.updateItemQty(ctx, json);
       // ccrz__E_CartItem__c updatedItem = [SELECT Id, ccrz__Quantity__c, ccrz__Price__c FROM ccrz__E_CartItem__c WHERE Id =: itemsList[0].Id];
       // System.assertEquals(20, updatedItem.ccrz__Quantity__c);
    }
    @isTest public static void initSoldToByEffIDTest(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
        acct.GE_LGT_Rep_Code__c='TestRep';
        acct.ConnectFixtureAgents__c='TestRep';
        update acct;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.effAccountId = customerContact.AccountId;

        Test.startTest();
        CartDetailActions.initSoldToByEffID(ctx);
       // System.assertEquals(1, test1.size());
        Test.stopTest();
    }
    
         @isTest public static void applyCustomQuantTest(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id Limit 1];
             decimal qty = 10.00;
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.applyCustomQuant(ctx,cartItem.Id,qty);
          //  CartDetailActions.updateTypeMarks(ctx,cartItem.Id, 'test type marks', true);
            Test.stopTest();
        }
    }
         @isTest public static void updateCartAccountTest(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem=[Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c=:cart.Id Limit 1];
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
 
            Test.startTest(); 
            CartDetailActions.updateCartAccount(ctx,customerContact.AccountId);
            Test.stopTest();
        }
    }

    @isTest public static void testpriceAgreementToModifiedCart(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
        acct.Account_Group__c='ZEAG';
        acct.Customer_Segmentation__c='FD';
        update acct;




        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.ccrz__Account__c= acct.id;
        update cart;
        system.runAs(testUser){

            SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = acct.Id, Agreement_No__c = '1234', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));

            insert pa;
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;

            Test.startTest();
            CartDetailActions.priceAgreementToModifiedCart(ctx,'1234', true);
            Test.stopTest();
        }
    }

    @isTest public static void testReorder(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct=[Select Id, GE_LGT_Rep_Code__c From Account Where Id=:customerContact.AccountId];
        acct.Account_Group__c='ZEAG';
        acct.Customer_Segmentation__c='FD';
        update acct;

        //GE Current trigger switches
        List<TriggerSwitch__c> switchList = new List<TriggerSwitch__c>{};
        switchList.add(TestDataUtil.createTriggerSwitch('OrderTrigger', False));
        switchList.add(TestDataUtil.createTriggerSwitch('OrderLineItemUpdate', False));
        switchList.add(TestDataUtil.createTriggerSwitch('Update_Pricebook2ids', False));
        Insert switchList;

        //GE Current standard Order setup
        PriceBook2 pb = TestDataUtil.createPriceBook('testBook');
        insert pb;

        PriceBook2 pb2 = TestDataUtil.createPriceBook('LED');
        insert pb2;

        Product2 p = TestDataUtil.createProduct('testProduct');
        insert p;

        PricebookEntry pbe = TestDataUtil.createPriceBookEntry((String)pb.Id, p);
        pbe.UseStandardPrice = false;
        insert pbe;

        Order o1 = new Order(PriceBook2Id = pb.Id, Status = 'Draft', AccountId = acct.Id, Agent_Account__c = acct.Id, Sold_To__c = acct.Id, CurrencyIsoCode = 'USD', EffectiveDate = Date.today().addDays(-1));
        insert o1;
        OrderItem oi1 = new OrderItem(OrderId = o1.Id, SKU__c = 'test1', Quantity = 1, PricebookEntryId = pbe.Id, unitPrice = 10.00, Agreement_Quote__c = 'test');
        insert oi1;
        OrderItem oi2 = new OrderItem(OrderId = o1.Id, SKU__c = 'sku', Quantity = 1, PricebookEntryId = pbe.Id, unitPrice = 10.00, Agreement_Quote__c = 'test');
        insert oi2;


        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.ccrz__Account__c= acct.id;
        update cart;
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;

            Test.startTest();
            CartDetailActions.reorder(ctx,o1.id);
            Test.stopTest();
        }
    }
    @isTest public static void testdeleteRevisePrice(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c];
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;

            Test.startTest();
            CartDetailActions.deleteRevisePrice(ctx,cart.id);
            Test.stopTest();
        }
    }
    
}