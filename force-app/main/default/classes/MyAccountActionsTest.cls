@isTest
public with sharing class MyAccountActionsTest {
    
    @isTest
    private static void testUpdateAddress(){
        ccrz__E_ContactAddr__c ca = [SELECT Id FROM ccrz__E_ContactAddr__c WHERE ccrz__AddressFirstline__c = 'address1'];
        ccrz__E_AccountAddressBook__c ab = [SELECT Id FROM ccrz__E_AccountAddressBook__c WHERE ccrz__E_ContactAddress__c =: ca.Id];
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        String json ='{"bookSfid":"'+String.valueOf(ab.id)+'","sfid":"'+String.valueOf(ca.Id)+'","addressBean":{"partnerId":"","sfid":"'+String.valueOf(ca.Id)+'","firstName":"Test","lastName":"address","companyName":"test","phone":"2342342342","address1":"Test","countryCode":"US","state":"Ohio","city":"Aurora","postalCode":"44202","country":"United States"},"addressTypes":[{"addressType":"Shipping","isDefault":false},{"isDefault":false}],"isDefault":false}';
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.effAccountId = customerContact.AccountId;

        Test.startTest();
        MyAccountActions.updateAddress(ctx, json);
        Test.stopTest();
        List<ccrz__E_ContactAddr__c> addrs = [SELECT Id FROM ccrz__E_ContactAddr__c];
        List<ccrz__E_AccountAddressBook__c> books = [SELECT Id FROM ccrz__E_AccountAddressBook__c];
        System.assertEquals(1, addrs.size());
        System.assertEquals(1, books.size());
        System.assertNotEquals(ca.Id, addrs[0].Id);
        System.assertNotEquals(ab.Id, books[0].Id);
    }

    @isTest
    private static void testGetPhone(){
        ccrz__E_ContactAddr__c ca = [SELECT Id FROM ccrz__E_ContactAddr__c WHERE ccrz__AddressFirstline__c = 'address1'];
        ccrz__E_AccountAddressBook__c ab = [SELECT Id FROM ccrz__E_AccountAddressBook__c WHERE ccrz__E_ContactAddress__c =: ca.Id];
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        String json = '[{"addressBean":{"address1":"Test","addrReadOnly":false,"city":"Aurora","companyName":"test","country":"United States","countryCode":"US","dayTime":"2342342342","firstName":"Test","lastName":"address","postalCode":"44202","sfdcName":"000691","sfid":"a722D00000075hkQAA","state":"Ohio"},"addressTypes":[{"addressType":"Shipping","isDefault":false,"typeReadOnly":false}],"bookSfid":"a6f2D000000BUNgQAO","city":"Aurora","contactName":"address, Test","country":"United States","defaultAddressType":"Shipping","sfid":"'+ca.Id+'"}]';

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.effAccountId = customerContact.AccountId;

        Test.startTest();
        MyAccountActions.getPhone(ctx, json);
        Test.stopTest();
    }

    @testSetup static void setupTestData() {

        b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        ccrz__E_ContactAddr__c newAddress = new ccrz__E_ContactAddr__c();
        newAddress.ccrz__AddressFirstline__c='address1';
        newAddress.ccrz__City__c='city';
        newAddress.ccrz__CompanyName__c='companyName';
        newAddress.ccrz__Country__c='country';
        newAddress.ccrz__CountryISOCode__c='US';
        newAddress.ccrz__FirstName__c='firstName';
        newAddress.ccrz__LastName__c='lastName';
        newAddress.ccrz__Partner_Id__c='partnerId';
        newAddress.ccrz__DaytimePhone__c='phone';
        newAddress.ccrz__PostalCode__c='postalCode';
        newAddress.ccrz__State__c='state';
        insert newAddress;

        ccrz__E_AccountAddressBook__c bookEntry = new ccrz__E_AccountAddressBook__c();
        bookEntry.ccrz__Account__c = customerContact.AccountId;
        bookEntry.ccrz__AccountId__c = String.valueOf(customerContact.AccountId);
        bookEntry.ccrz__AddressType__c = 'Shipping';
        bookEntry.ccrz__Default__c = true;
        bookEntry.ccrz__E_ContactAddress__c = newAddress.Id;
        insert bookEntry;
    }
}