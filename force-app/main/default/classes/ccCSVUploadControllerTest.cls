@isTest
public with sharing class ccCSVUploadControllerTest {

	@isTest
	public static void parseCSV_AddsItemsToExistingCart() {
		String csvFile = 'Catalog No.,Quantity\n';
		csvFile += 'MD12345,3\nMD123456,4\n';

		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
		cart.ccrz__Account__c = customerContact.AccountId;
		cart.ccrz__Name__c = 'testCart';
		insert cart;
		ccrz__E_Cart__c cartQuery = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];

            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.storefront = 'DefaultStore';
            ctx.currentCartId = cartQuery.ccrz__EncryptedId__c;
            ctx.effAccountId=customerContact.AccountId;
			ccCSVUploadController.parseCSV(ctx, csvFile, false);
	}

	@testSetup static void setupTestData() {

		b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		ccrz__E_Attribute__c attr = new ccrz__E_Attribute__c(ccrz__AttributeID__c = 'testAttr', Name = 'EA', ccrz__DisplayName__c = 'EA', ccrz__EffectiveStart__c = System.now(), ccrz__EffectiveEnd__c = System.now());
            insert attr;
		List<ccrz__E_Product__c> prodList = new List<ccrz__E_Product__c>();
		ccrz__E_Product__c p = [Select Id, MaterialDescription__c, ccrz__SKU__c, ccrz__PrimaryAttr__c From ccrz__E_Product__c  WHERE Name='test1'];
		p.MaterialDescription__c = 'MD12345';
        p.Name='MD12345';
		p.ccrz__PrimaryAttr__c=attr.Id;
		prodList.add(p);
		p = [Select Id, MaterialDescription__c, ccrz__SKU__c From ccrz__E_Product__c  WHERE Name='test2'];
		p.MaterialDescription__c='MD123456';
		prodList.add(p);

		ccrz__E_Product__c p3 = p.clone(false,false,false,false);
				p3.MaterialDescription__c = 'MD1234567';
				p3.name = 'MD1234567';
				p3.ccrz__SKU__c = 'MD1234567';

		ccrz__E_Product__c p4 = p.clone(false,false,false,false);
				p4.MaterialDescription__c = 'MD12345678';
				p4.Name = 'MD12345678';
				p4.ccrz__SKU__c = 'MD12345678';

		prodList.add(p3);
		prodList.add(p4);

		upsert prodList;
		List<Pricing_UOM__c> pl = (List<Pricing_UOM__c>)TestDataFactory.createPricingUOM(prodList.get(0).Id, prodList.get(0).ccrz__SKU__c);

    }

	@isTest
	public static void additionalTest() {
		String csvFile = 'Catalog No.,Quantity,UOM,Type Marks\n' +
				'MD12345,10,Piece,typemark\n' +
				'MD123456,10,Piece,typemark\n' +
				'MD1234567,10,Piece,typemark\n' +
				'MD12345678,1,Piece';

		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
		cart.ccrz__Account__c = customerContact.AccountId;
		cart.ccrz__Name__c = 'testCart';
		insert cart;
		ccrz__E_Cart__c cartQuery = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];

		ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
		ctx.storefront = 'DefaultStore';
		ctx.currentCartId = cartQuery.ccrz__EncryptedId__c;
		ctx.effAccountId=customerContact.AccountId;
		ccCSVUploadController.parseCSV(ctx, csvFile, false);
	}

	@isTest
	public static void additionalTestWrongUom() {
		String csvFile = 'Catalog No.,Quantity,UOM,Type Marks\n' +
				'MD12345,10,Peice,typemark\n' +
				'MD123456,10,Peice,typemark\n' +
				'MD1234567,10,Peice,typemark\n' +
				'MD12345678,1,Peice';

		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
		cart.ccrz__Account__c = customerContact.AccountId;
		cart.ccrz__Name__c = 'testCart';
		insert cart;
		ccrz__E_Cart__c cartQuery = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];

		ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
		ctx.storefront = 'DefaultStore';
		ctx.currentCartId = cartQuery.ccrz__EncryptedId__c;
		ctx.effAccountId=customerContact.AccountId;
		ccCSVUploadController.parseCSV(ctx, csvFile, false);
	}
}