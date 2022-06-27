@isTest
public class B2BCommerceAccountSelectorTest {
@testSetup
    private static void setupData() {
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
        b2bTestSetup.setupCart();
    }
@IsTest
    static void getRelatedAccountsTest(){
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
                   B2BCommerceAccountSelector.getRelatedAccounts(customerContact.id , 'Agent') ;

            Test.stopTest();
        }
    }
    
    @IsTest
    static void getRelatedAccountsTest1(){
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
                   B2BCommerceAccountSelector.getRelatedAccounts(customerContact.id , 'Test') ;

            Test.stopTest();
        }
    }
    
    
    @isTest
    static void getSoldToAccountsTest(){
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
       B2BCommerceAccountSelector.getSoldToAccounts(customerContact.AccountId) ;

            Test.stopTest();
    }
    }
    
    @isTest
    static void getAgentAccountsTest(){
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
       B2BCommerceAccountSelector.getAgentAccounts(customerContact.id) ;

            Test.stopTest();
    }
    }
    
    @isTest
    static void getAccountNameTest(){
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
       B2BCommerceAccountSelector.getAccountName(customerContact.AccountId) ;

            Test.stopTest();
    }
    }
}