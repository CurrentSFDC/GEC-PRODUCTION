/**
 * Created by Zsöme on 2021. 06. 14..
 */

@IsTest
private class ccQuickOrderControllerTest {

    @TestSetup
    private static void setupData() {
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
        b2bTestSetup.setupCart();
    }

    @IsTest
    static void testGetSKUByCatalogNumber() {

        User testUser = [SELECT Id,profileid FROM User WHERE Email = 'b2b.contact@gecurrent.com.acumen'];
        system.debug('testUser '+testUser);
        Contact customerContact = [SELECT AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = :customerContact.AccountId];

        system.runAs(testUser) {
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

            ccrz__E_Product__c prod = [SELECT Id, Name, ccrz__SKU__c FROM ccrz__E_Product__c WHERE Name = 'test1' LIMIT 1];
            List<Pricing_UOM__c> pl = (List<Pricing_UOM__c>)TestDataFactory.createPricingUOM(prod.Id, prod.ccrz__SKU__c);


            ccrz.cc_RemoteActionResult rar = ccQuickOrderController.getSKUByCatalogNumber(ctx, new List<String>{'test1'});
            System.debug(rar);
            System.assertEquals('test1', ((Map<String, Object>)(rar.data)).get('test1').toString());
            ccQuickOrderController.CartDataSet cds = new ccQuickOrderController.CartDataSet();
            cds.sku = 'test1';
            cds.qty = '1';
            cds.unitOfMeasure = 'PC';
            ccQuickOrderController.addCartItems(
                    ctx,
                    new List<ccQuickOrderController.CartDataSet>{
                            cds
                    },
                    customerContact.AccountId);
        //test merge
        ccQuickOrderController.addCartItems(
                ctx,
                new List<ccQuickOrderController.CartDataSet>{
                        cds
                },
                customerContact.AccountId);
        }
    }
}