/**
 * Created on 2021. 03. 26..
 */

@IsTest
private class TestCommunityPriceAgreementController {
    @testSetup public static void setup() {

        //GE Current trigger switches
        List<TriggerSwitch__c> switchList = new List<TriggerSwitch__c>{};
        switchList.add(TestDataUtil.createTriggerSwitch('OrderTrigger', False));
        switchList.add(TestDataUtil.createTriggerSwitch('OrderLineItemUpdate', False));
        insert switchList;
        PriceBook2 pb = TestDataUtil.createPriceBook('testBook');
        insert pb;

        Account account = TestDataFactory.createAccount('Test Account ', true);
        account.GE_LGT_EM_Sales_Org__c = '1US1';
        update account;
        Contact contact = TestDataFactory.createContact(account.Id, 'Test', 'Contact 1', 'test@example.com', true);
        User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
                'Agent B2B Storefront Registered Users', true);
        Order order = new Order(AccountId = account.Id, Status = 'Draft', GE_Order_NO__c = 'testNumber', Sold_To__c = account.Id, EffectiveDate = Date.today(), Pricebook2Id = pb.Id, OwnerId=user.Id);
        insert order;

        // OrderItem oi = new OrderItem(OrderId = order.Id, Quantity = 1, UnitPrice = 1.00, PriceBookEntryId = );
        // insert oi;

        Account account2 = TestDataFactory.createAccount('Test Account 2', true);
        Contact contact2 = TestDataFactory.createContact(account2.Id, 'Test', 'Contact 2', 'test2@example.com', true);
        User user2 = TestDataFactory.createCommunityUser(contact2.Id, contact2.FirstName, contact2.LastName, contact2.Email, TestDataFactory.getRandomUsername(),
                'Agent B2B Storefront Registered Users', true);
        Order order2 = new Order(AccountId = account2.Id, Status = 'Draft', GE_Order_NO__c = 'testNumber', Sold_To__c = account2.Id, EffectiveDate = Date.today(), Pricebook2Id = pb.Id, OwnerId=user2.Id);
        insert order2;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        System.runAs ( thisUser ) {
            Account acc = new Account(
                    Name = 'name'
            );
            insert acc;

            Contact con = new Contact (
                    AccountId = acc.id,
                    FirstName='u',
                    LastName = 'portalTestUser2',
                    Email = 'email2@email.em'
            );
            insert con;
            System.debug([SELECT id FROM Profile WHERE UserLicense.Name='Customer Community Plus' LIMIT 1].id);
            User portalUser = new User(
                    profileId = [SELECT id FROM Profile WHERE UserLicense.Name='Customer Community Plus' LIMIT 1].id,
                    username = 'newUser@yahoo.com',
                    email = 'pb@ff.com',
                    emailencodingkey = 'UTF-8',
                    localesidkey = 'en_US',
                    languagelocalekey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles',
                    alias='nuser',
                    lastname='lastname',
                    contactId = con.id
            );
            insert portalUser;
        }
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

    @IsTest
    public static void testCommunityPriceAgreementController() {
        final String PRICE_AGREEMENT_NUMBER = '5';
        final String PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO = '11512';
        
        
        //PriceAgreementToCartTest.setupTestData();
        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = PRICE_AGREEMENT_NUMBER, Material_No__c = 'Test SKU', Quantity__c = 1, UOM__c = 'test');
        insert pai;

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        acc.GE_LGT_Rep_Code__c = null;  // in order to test CommunityPriceAgreementController.getPriceAgreementsByCustomerNumber
        acc.GE_LGT_EM_SAP_Customer_Number__c = PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO;
        update acc;
        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Agreement_No__c = PRICE_AGREEMENT_NUMBER, Bill_To_Customer_No__c = PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO, Extended_Description__c = 'extended test desc');
        insert pa;


        /*Account account = TestDataFactory.createAccount('TestAccount', false );
        account.GE_LGT_Rep_Code__c = 'LGT_rep_code';
        insert account;
        Contact contact = TestDataFactory.createContact(account.Id, 'First', 'LastContact', 'testcontact@test.com', true);*/
        Test.startTest();
        //User usr = TestDataFactory.createUser(contact.Id, 'LastTest', 'asdf@test.com', 'asdf@test.com', 'System Administrator', 'Application Administrator', 'Application Administrator', true);

        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        System.runAs(user) {
            CommunityPriceAgreementController.getPriceAgreements(10);
            CommunityPriceAgreementController.modify(PRICE_AGREEMENT_NUMBER, false);
        }
        Test.stopTest();
    }


    @IsTest
    public static void testCommunityPriceAgreementController2() {
        final String PRICE_AGREEMENT_NUMBER = '5';
        final String PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO = '11512';
        
        

       //PriceAgreementToCartTest.setupTestData();
        SAP_Price_Agreement_Item__c pai = new SAP_Price_Agreement_Item__c(Sales_Price__c = 1.00, Agreement_No__c = PRICE_AGREEMENT_NUMBER, Material_No__c = 'Test SKU', Quantity__c = 1, UOM__c = 'test');
        insert pai;

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        acc.GE_LGT_EM_SAP_Customer_Number__c = PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO;
        update acc;
        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Agreement_No__c = PRICE_AGREEMENT_NUMBER, Bill_To_Customer_No__c = PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO, Extended_Description__c = 'extended test desc');
        insert pa;
        Test.startTest();
        User user=[Select Id From User Where Email='test2@example.com' LIMIT 1];
        System.runAs(user) {
            CommunityPriceAgreementController.getPriceAgreements(10);
            CommunityPriceAgreementController.modify(PRICE_AGREEMENT_NUMBER, false);
        }
        Test.stopTest();
    }


    @IsTest
    public static void testCommunityPriceAgreementController_n() {
        User u = [ SELECT id,ContactId,AccountId FROM User WHERE username = 'newUser@yahoo.com'];
        system.debug(u);
        System.runAs(u) {
            CommunityPriceAgreementController.getPriceAgreements(1);
        }
    }

    @IsTest
    public static void testCommunityPriceAgreementController_v2() {
		final String PRICE_AGREEMENT_NUMBER = '5';
        final String PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO = '11512';


        Account account = TestDataFactory.createAccount('Test Account ', true);
        account.GE_LGT_EM_Sales_Org__c = '1US1';
        account.Customer_Segmentation__c = 'FD';
        update account;
        Contact contact = TestDataFactory.createContact(account.Id, 'Testt', 'Contact 11', 'testtt@example.com', true);
        User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
                'Agent B2B Storefront Registered Users', true);
        User u = [ SELECT id,ContactId,AccountId FROM User WHERE username = 'newUser@yahoo.com'];
        system.debug(u);
		
		Account acc = [SELECT Id,Customer_Segmentation__c FROM Account LIMIT 1];
        acc.Customer_Segmentation__c='FD';
        update acc;
		SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(
			Agreement_No__c = PRICE_AGREEMENT_NUMBER, 
			Bill_To_Customer_No__c = PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO, 
			Extended_Description__c = 'extended test desc', 
			Expiration_Date__c = system.today(), 
			Fixture_Agent__c = acc.Id, 
			Customer_List__c = '0001934200');
        insert pa;

        System.runAs(u) {
            CommunityPriceAgreementController.getPriceAgreementsv2(acc.Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent', '0001934200');
            CommunityPriceAgreementController.getPriceAgreementsv2(acc.Id, ' ', 'Agent', '0001934200');
            CommunityPriceAgreementController.getPriceAgreementsforWidget(acc.Id, ' ', 'Agent', '0001934200');
            CommunityPriceAgreementController.getPriceAgreementsforWidget(acc.Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent', '0001934200');
            
            CommunityPriceAgreementController.getPriceAgreementByAccountSelector(acc.Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent', '0001934200', 5);
        }
    }
    
	@IsTest
    public static void testCommunityPriceAgreementControllerDetail() {
		final String PRICE_AGREEMENT_NUMBER = '5';
        final String PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO = '11512';


        Account account = TestDataFactory.createAccount('Test Account ', true);
        account.GE_LGT_EM_Sales_Org__c = '1US1';
        account.ConnectFixtureAgents__c='123';
        update account;
        Contact contact = TestDataFactory.createContact(account.Id, 'Testt', 'Contact 11', 'testtt@example.com', true);
        User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
                'Agent B2B Storefront Registered Users', true);
        User u = [ SELECT id,ContactId,AccountId FROM User WHERE username = 'newUser@yahoo.com'];
        system.debug(u);
		
		Account acc = [SELECT Id FROM Account LIMIT 1];
		SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(
			Agreement_No__c = PRICE_AGREEMENT_NUMBER, 
			Bill_To_Customer_No__c = PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO, 
			Extended_Description__c = 'extended test desc', 
			Expiration_Date__c = system.today(), 
			Fixture_Agent__c = acc.Id, 
			Customer_List__c = '080000108');
        insert pa;

        System.runAs(u) {
            CommunityPriceAgreementController.getPriceAgreementDetail(pa.id);
            CommunityPriceAgreementController.getCustListDetail(pa.id,'Agent','123');
            CommunityPriceAgreementController.getCustListDetail(pa.id,'Distributor','123');

            
        }
    }    
}