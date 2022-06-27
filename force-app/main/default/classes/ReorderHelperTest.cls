@isTest
public with sharing class ReorderHelperTest {
    @isTest
    public static void ReorderHelperTest() {

        //community user setup
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account ac = [SELECT Id FROM Account WHERE Id = :customerContact.AccountId];
    
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
        ccrz__E_Product__c prod = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = 'test1'];
        ccrz__E_CartItem__c cartItem = [SELECT Id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c =: cart.Id LIMIT 1];

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

        Order o1 = new Order(PriceBook2Id = pb.Id, Status = 'Draft', AccountId = ac.Id, Agent_Account__c = ac.Id, Sold_To__c = ac.Id, CurrencyIsoCode = 'USD', EffectiveDate = Date.today().addDays(-1));
        insert o1;
        OrderItem oi1 = new OrderItem(OrderId = o1.Id, SKU__c = 'test1', Quantity = 1, PricebookEntryId = pbe.Id, unitPrice = 10.00, Agreement_Quote__c = 'test');
        insert oi1;  
        OrderItem oi2 = new OrderItem(OrderId = o1.Id, SKU__c = 'sku', Quantity = 1, PricebookEntryId = pbe.Id, unitPrice = 10.00, Agreement_Quote__c = 'test');
        insert oi2;

        //context setup
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(ctx);

        system.runAs(testUser) {

            ReorderHelper rh = new ReorderHelper(o1.Id);
            List<Map<String,Object>> activeCartData = new List<Map<String,Object>>{
                new Map<String,Object>{
                    'sfid' => cartItem.Id
                }
            };
            rh.clearCart(cart.Id, activeCartData);

            Test.startTest();
            System.assertNotEquals(null, rh.reorder());  
            System.assertNotEquals(null, rh.reorderURL());
            rh.updateInvalidCartItems(cart.ccrz__EncryptedId__c,New List<String>{'sku'});
            Test.stopTest();
        }    
    }

    @isTest
    public static void ReorderHelperTest2() {

        //community user setup
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account ac = [SELECT Id FROM Account WHERE Id = :customerContact.AccountId];

        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
        ccrz__E_Product__c prod = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = 'test1'];
        ccrz__E_CartItem__c cartItem = [SELECT Id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c =: cart.Id LIMIT 1];

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

        Order o1 = new Order(PriceBook2Id = pb.Id, Status = 'Draft', AccountId = ac.Id, Agent_Account__c = ac.Id, Sold_To__c = ac.Id, CurrencyIsoCode = 'USD', EffectiveDate = Date.today().addDays(-1));
        insert o1;
        OrderItem oi1 = new OrderItem(OrderId = o1.Id, SKU__c = 'test1', Quantity = 1, PricebookEntryId = pbe.Id, unitPrice = 10.00, Agreement_Quote__c = 'test');
        insert oi1;
        OrderItem oi2 = new OrderItem(OrderId = o1.Id, SKU__c = 'sku', Quantity = 1, PricebookEntryId = pbe.Id, unitPrice = 10.00, Agreement_Quote__c = 'test');
        insert oi2;

        //context setup
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = 'DefaultStore';
        ctx.effAccountId = customerContact.AccountId;
        ctx.portalUserId = testUser.Id;
        //ctx.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(ctx);

        system.runAs(testUser) {

            ReorderHelper rh = new ReorderHelper(o1.Id);


            Test.startTest();
            System.assertNotEquals(null, rh.reorder());
            System.assertNotEquals(null, rh.reorderURL());
            Test.stopTest();
        }
    }

    

    @testSetup static void setupTestData() {

        b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT Id, GE_LGT_Rep_Code__c FROM Account WHERE ID =: customerContact.AccountId];
        acct.GE_LGT_Rep_Code__c = 'testing';
        update acct;
        ExceptionLoggingFramework__c elf = new ExceptionLoggingFramework__c();
		elf.Enabled__c=true;
		elf.EmailNotificationEnabled__c=true;
		insert elf;
		system.runAs(testUser){

            ccrz__E_Attribute__c attribute = new ccrz__E_Attribute__c(Name = 'Unit of Measure');
            insert attribute;
            ccrz__E_Product__c product = new ccrz__E_Product__c();
			product.ccrz__SKU__c = 'sku';
			product.ccrz__ProductId__c = '543513-340';
			product.Name = 'Test Product';
			product.ccrz__Quantityperunit__c = 1;
			product.ccrz__Storefront__c = 'DefaultStore';
			product.ccrz__ProductStatus__c = 'Released';
			product.ccrz__InventoryType__c = 'STANDARD';
			product.ccrz__ProductType__c = 'Product';
            product.ccrz__PrimaryAttr__c = attribute.id;
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
            
            SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Fixture_Agent__c = customerContact.AccountId, Agreement_No__c = 'test', Name = 'test PA', Expiration_Date__c = System.today().addDays(1));
            pa.Customer_List__c = 'dummy,dummy,0000000123,dummy';
            insert pa;


            SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = 'test', Material_No__c = 'sku', Price_Per_EA__c = 10.00, Price_Agreement__c = pa.Id);
            insert pai;
        } 
    }
}