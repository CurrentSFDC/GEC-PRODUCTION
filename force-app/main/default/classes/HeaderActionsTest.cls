@isTest
public with sharing class HeaderActionsTest {

    @testSetup
    private static void setupData() {
        b2bTestSetup.setupPortalUsers();

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

    @isTest
    public static void testGetRepCode(){
        Account account = TestDataFactory.createAccount('Test Account ', true);
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        HeaderActions.getRepCode(ctx, (String)account.Id);
    }

    @isTest
    public static void testGetProfId(){
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        HeaderActions.getProfId(ctx, UserInfo.getUserId());
    }

    @isTest
    public static void testGetPerSet(){
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        HeaderActions.getPerSet(ctx, UserInfo.getUserId());
    }

    @isTest
    public static void testGetRelatedAccountsOfUser(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select Id,AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		
        //system.runAs(testUser) {

          //  system.runAs(testUser) {
                ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
                ctx.storefront = 'DefaultStore';
                ctx.effAccountId = customerContact.AccountId;
                ctx.portalUserId = testUser.Id;
                HeaderActions.getRelatedAccountsOfUser(ctx);
                HeaderActions.resetImpersonateFlag(ctx, customerContact.Id);
            //}
        //}


    }

    @isTest
    public static void testGetRelatedAccountsOfUserAgent(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        customerContact.Portal_User_Type__c = 'Agent';
        update customerContact;

        Account agent = [SELECT Id FROM Account WHERE Id=:customerContact.AccountId];
        agent.Account_Group__c = 'ZEAG';
        agent.GE_LGT_EM_CustomerActiveFlag__c = true;
        update agent;


        system.runAs(testUser) {

            system.runAs(testUser) {
                ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
                ctx.storefront = 'DefaultStore';
                ctx.effAccountId = customerContact.AccountId;
                ctx.portalUserId = testUser.Id;
                HeaderActions.getRelatedAccountsOfUser(ctx);

            }
        }


    }

    @isTest
    static void getUomCodeLabelMap() {

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN (Select ContactId From User Where Id = :testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        //ccrz__E_CartItem__c cartItem = [Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c = :cart.Id];

        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);

            HeaderActions.getUomCodeLabelMap(ctx);
        }

    }
    @isTest
    static void getCartByIdTest() {
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN (Select ContactId From User Where Id = :testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        //ccrz__E_CartItem__c cartItem = [Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c = :cart.Id];

        system.runAs(testUser) {

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.effAccountId = customerContact.AccountId;
            ctx.portalUserId = testUser.Id;
            ctx.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(ctx);


            String cartId = CartServices.getActiveCartId();
            HeaderActions.getCart(ctx, (String) cart.Id);
        }
    }

    @IsTest
    private static void getSAPOrderNoTest(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
                ccrz__Account__c = customerContact.AccountId,
                ccrz__EncryptedId__c = 'ORD-00000',
                ccrz__OriginatedCart__c = cart.Id,
                ccrz__Contact__c = customerContact.Id,
                SAP_Order_Number__c='123',
                Agreement_Number__c='Test'

        );
        insert testOrder;
        system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            Test.startTest();
            HeaderActions.getSAPOrderNo(ctx, testOrder.Id);
            Test.stopTest();
        }

    }
}