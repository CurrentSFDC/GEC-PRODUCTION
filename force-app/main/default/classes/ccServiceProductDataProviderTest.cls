// ccServiceProductDataProviderTest class
// Test class for the ccServiceProductDataProvider class
// ------------------------------------------------------------------
//  Author                    Date         Description
// ------------------------------------------------------------------
//  Devang Shah	              29/12/2020   Created
//

@IsTest
public class ccServiceProductDataProviderTest {

    static final String DEFAULT_OBJECTFIELDS = 'Id';
    @testSetup
    private static void setupData() {
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
        b2bTestSetup.setupCart();
    }

    @IsTest
    static void testGetFieldsMap(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.getFieldsMap(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }

    @IsTest
    static void testFilterMap(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.getFilterMap(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }

    @IsTest
    static void testOrderByMap(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.getOrderByMap(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }
    @IsTest
    static void testTransformOut(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);
            system.debug('TDBG prodid '+productId);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.transformOut(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            Map<String,Object> sUOM= new Map<String,Object>();
            List<Map<String,Object>> allUOM = new List<Map<String,Object>>();
            sUOM.put('UOM','EA');
            sUOM.put('multiplier',1);
            allUOM.add(sUOM);

            Sales_Org_Product__c sOrg = new Sales_Org_Product__c(CC_Product__c=productId);
            sOrg.Minimum_Order_Quantity_in_PC__c=1;
            objs.add(new Map<String, Object>{
                    'sfid' => productId,
                    'SKU' => productId,
                    'pricingUOMS' => allUOM,
                    'salesOrgProduct' => sOrg

            });

            GE_LGT_EM_MaterialMaster__c mm = new GE_LGT_EM_MaterialMaster__c(
                    GE_LGT_EM_ProductFamily__c='PR_testData',
                    CurrencyIsoCode='USD',
                    GE_LGT_EM_SAP_MaterialNumber__c=productId
            );
            insert mm;

            Inventory__c inv = new Inventory__c(
                    QuickStock__c = 10,
                    Stock__c = 10,
                    Plant__c = 'ABC',
                    Material_Master__c = mm.id

            );
            insert inv;

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });
            /*
            SELECT Id,QuickStock__c,Plant__c, Stock__c,Material_Master__r.GE_LGT_EM_SAP_MaterialNumber__c
            FROM Inventory__c
            WHERE Material_Master__r.GE_LGT_EM_SAP_MaterialNumber__c IN :productsByMaterialNumber.keySet()




            */
            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }
    @IsTest
    static void testprepReturn(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.prepReturn(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }
    @IsTest
    static void testfetch(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.fetch(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }
    @IsTest
    static void testgetSubQueryMap(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.getSubQueryMap(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }
    @IsTest
    static void testgetFindFieldsClauseMap(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.getFindFieldsClauseMap(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }
    @IsTest
    static void testgetReturnClauseMap(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.getReturnClauseMap(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }
    @IsTest
    static void testprocessSearchResult(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.processSearchResult(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }
    
    
  
     @IsTest
    static void testrunQuery(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'pdp';
            Map<String,Object> map1 = new Map<String,Object>();
			map1.put('queryString', 'SELECT Id,Name,OwnerId,SKU__c,MaterialType__c, MaterialDescription__c, Product_Family__c, UPC__c,Quickship__c, Total_Standard_Inventory__c, Inventory_Available__c, ECommItemName__c FROM ccrz__E_Product__c ORDER BY  Id limit 100');
                     Map<String, Object> result = instance.runQuery(map1);

          /*  List<Map<String,Object>> objs = new List<Map<String,Object>>();
            objs.add(new Map<String, Object>{
                    'sfid' => productId
            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
*/
            Test.stopTest();

        }
    }
    



    @IsTest
    static void testsearch(){

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

            Test.startTest();
            List<ccrz__E_Product__c> productListSetUp = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='sku' LIMIT 1];
            Id productId = product.Id;
            productListSetUp.add(product);

            ccServiceProductDataProvider instance = new ccServiceProductDataProvider();
            ccrz.cc_CallContext.currUIKey = 'plp';
            Map<String, Object> result = instance.search(new Map<String, Object>{
                    ccrz.ccService.OBJECTFIELDS => 'Id'
            });

            List<Map<String,Object>> objs = new List<Map<String,Object>>();
            Map<String,Object> sUOM= new Map<String,Object>();
            List<Map<String,Object>> allUOM = new List<Map<String,Object>>();
            sUOM.put('UOM','EA');
            sUOM.put('multiplier',1);
			allUOM.add(sUOM);

            Sales_Org_Product__c sOrg = new Sales_Org_Product__c();
            sOrg.Minimum_Order_Quantity_in_PC__c=1;
            objs.add(new Map<String, Object>{
                    'sfid' => productId,
                    'pricingUOMS' => allUOM,
                     'salesOrgProduct' => sOrg

            });

            result  = instance.mergeOtherData(new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTLIST => objs
            });

            System.assertNotEquals((String) result.get(ccrz.ccService.OBJECTFIELDS), DEFAULT_OBJECTFIELDS);
            result = instance.fetch(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });
            System.assertNotEquals(result.size(), 0);
            result  = instance.mergeOtherData(new Map<String, Object> { ccrz.ccService.LISTTYPE => new List<ccrz__E_Product__c>(productListSetUp) });

            Test.stopTest();

        }
    }

}