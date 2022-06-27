/**
 * Created by D on 25/03/2021.
 */

@IsTest
public class TestCommunity {
    @testSetup
    public static void setupData() {
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
    public static void testCommunityOpenClass() {
        TestDataFactory.createContact('Test', 'Test', 'test@test.com', true);
        TestDataFactory.createAccount('Test Account',  true);

       

        communityOpenClass.getRelatedAccounts([SELECT Id FROM Contact LIMIT 1].Id, 'Agent');
        communityOpenClass.getRelatedAccounts([SELECT Id FROM Contact LIMIT 1].Id, 'Customer');
        communityOpenClass.getUserPerMissionSet([SELECT Id FROM Contact LIMIT 1].Id);
        communityOpenClass.getAgentAccounts([SELECT Id FROM Contact LIMIT 1].Id);
        communityOpenClass.getSoldToAccounts([SELECT Id FROM Account LIMIT 1].Id);
        communityOpenClass.getAccountName([SELECT Id FROM Account LIMIT 1].Id);
        communityOpenClass.fetchCommunityContentData('test', 'test');
		communityOpenClass.fetchAlertBar('test', 'Distributor');
        communityOpenClass.fetchAlertBar('test', 'Agent');
        
        communityOpenClass.getOpenOrders([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent');
        communityOpenClass.getOpenOrders([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Customer');
        communityOpenClass.getOpenOrders([SELECT Id FROM Account LIMIT 1].Id, ' ', 'Agent');
        communityOpenClass.getAllOpenOrders([SELECT Id FROM Account LIMIT 1].Id);
        /*communityOpenClass.getParentOrders([SELECT Id FROM Account LIMIT 1].Id);
        communityOpenClass.getAllParentOrders([SELECT Id FROM Account LIMIT 1].Id);
        communityOpenClass.getAllOpenOrdersWithLimitAndOffset([SELECT Id FROM Account LIMIT 1].Id, 0, 1);
        communityOpenClass.getPriceAgreements([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent', '0001934200');
        communityOpenClass.getPriceAgreements([SELECT Id FROM Account LIMIT 1].Id, ' ', 'Agent', '0001934200');
        communityOpenClass.getPriceAgreements(' ',[SELECT Id FROM Account LIMIT 1].Id, 'Agent', '0001934200');
        communityOpenClass.getOpenReturns([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent');
        communityOpenClass.getOpenReturns([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Customer');
        communityOpenClass.getOpenReturns([SELECT Id FROM Account LIMIT 1].Id, null, 'Agent');*/
    }
    
    @isTest
    public static void testCommunityOpenClass2(){
        TestDataFactory.createContact('Test', 'Test', 'test@test.com', true);
        TestDataFactory.createAccount('Test Account',  true);
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

      
        
        communityOpenClass.getParentOrders([SELECT Id FROM Account LIMIT 1].Id);
        communityOpenClass.getAllParentOrders([SELECT Id FROM Account LIMIT 1].Id);
        communityOpenClass.getAllOpenOrdersWithLimitAndOffset([SELECT Id FROM Account LIMIT 1].Id, 0, 1);
        communityOpenClass.getPriceAgreements([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent', '0001934200');
        communityOpenClass.getPriceAgreements([SELECT Id FROM Account LIMIT 1].Id, ' ', 'Agent', '0001934200');
        communityOpenClass.getPriceAgreements(' ',[SELECT Id FROM Account LIMIT 1].Id, 'Agent', '0001934200');
        communityOpenClass.getOpenReturns([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent');
        communityOpenClass.getOpenReturns([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Customer');
        communityOpenClass.getOpenReturns([SELECT Id FROM Account LIMIT 1].Id, null, 'Agent');
        communityOpenClass.getUserProfile(testUser.id);
    	communityOpenClass.getUserType(testUser.id);	
    }

    @isTest
    public static void testCommunityOpenClass3(){
        TestDataFactory.createContact('Test', 'Test', 'test@test.com', true);
        TestDataFactory.createAccount('Test Account',  true);
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        communityOpenClass.getOpenCases([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent');
        communityOpenClass.getOpenCases([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Customer');
        communityOpenClass.getOpenCases([SELECT Id FROM Account LIMIT 1].Id, ' ', 'Agent');
        communityOpenClass.getOpenCases([SELECT Id FROM Account LIMIT 1].Id, ' ', 'Customer');
      
    }

    @isTest
    public static void testCommunityOpenClass4(){
        TestDataFactory.createContact('Test', 'Test', 'test@test.com', true);
        TestDataFactory.createAccount('Test Account',  true);
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select Id, AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        Connect_Logins__c conL = new Connect_Logins__c();
        conL.Delegated_User__c = testUser.Id;
        conL.Contact__c = customerContact.Id;
        conL.Login_Date_Time__c = Datetime.now();
        insert conL;

        customerContact.Impersonate_Mode__c = true;

        SAP_Price_Agreement__c sa = new SAP_Price_Agreement__c();
        sa.Name = '123456';
        sa.Expiration_Date__c = Date.Today().addDays(30);
        insert sa;
        
		communityOpenClass.checkPAItem('123456');
        communityOpenClass.checkPAHeader('123456');
        
        //communityOpenClass.loggedInAsUserCheck();
        communityOpenClass.connectLogins(customerContact.Id);
        communityOpenClass.updateContactInfo(customerContact);   
        List<String> emptyList = new List<String>();
        communityOpenClass.getPdfDownloadLink(emptyList);
    }

    @IsTest
    public static void testCommunityCases() {
        TestDataFactory.createAccount('Test Account',  true);

        CommunityCases.CaseQuery cq = new CommunityCases.CaseQuery();
        cq.accountId = [SELECT Id FROM Account LIMIT 1].Id;
        cq.searchText = 'test';
        CommunityCases.getCases(cq);
        
        CommunityCases.CaseQuery cq1 = new CommunityCases.CaseQuery();
        cq1.accountId = [SELECT Id FROM Account LIMIT 1].Id;
        cq1.soldToId = [SELECT Id FROM Account LIMIT 1].Id;
        cq1.searchText = 'test';
        CommunityCases.getCases(cq1);
        
        CommunityCases.CaseQuery cq2 = new CommunityCases.CaseQuery();
        cq2.soldToId = [SELECT Id FROM Account LIMIT 1].Id;
        cq2.searchText = 'test';
        CommunityCases.getCases(cq2);
    }

    @IsTest
    public static void testCommunityContentController() {
        TestDataFactory.createAccount('test', true);
        Map<String, Object> testMap = new Map<String, Object>();
        testMap.put('Test', 'Test');

        CommunityContentController.getCommunityContent(testMap);
        CommunityContentController.getToolsCommunityContentId();
        CommunityContentController.getCommSalesKits([SELECT Id FROM Account LIMIT 1].Id);
        CommunityContentController.getCommMedia([SELECT Id FROM Account LIMIT 1].Id);
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
        System.debug('acc: ' + acc);
        SAP_Price_Agreement__c pa = new SAP_Price_Agreement__c(Agreement_No__c = PRICE_AGREEMENT_NUMBER, Bill_To_Customer_No__c = PRICE_AGREEMENT_BILL_TO_CUSTOMER_NO, Extended_Description__c = 'extended test desc');
        insert pa;


        /*Account account = TestDataFactory.createAccount('TestAccount', false );
        account.GE_LGT_Rep_Code__c = 'LGT_rep_code';
        insert account;
        Contact contact = TestDataFactory.createContact(account.Id, 'First', 'LastContact', 'testcontact@test.com', true);*/
        Test.startTest();
        //User usr = TestDataFactory.createUser(contact.Id, 'LastTest', 'asdf@test.com', 'asdf@test.com', 'System Administrator', 'Application Administrator', 'Application Administrator', true);

        User user=[Select Id, AccountId From User Where Email='test@example.com' LIMIT 1];
        System.debug('user: ' + user);
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

    // OrderController function is tested in OrderControllerTest.testGetAccount() method

    @IsTest
    public static void testCommunityOpenReturnsController() {
        final String RANDOM_SEARCH_STRING = '1';
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Account testAccountDis = new Account(Name = 'Test Account - DIS');
        insert testAccountDis;

        CommunityOpenReturnsController.OrderQuery oq = new CommunityOpenReturnsController.OrderQuery();
        oq.accountId = testAccount.Id;
        oq.soldToId = testAccountDis.Id;
        oq.searchText = RANDOM_SEARCH_STRING;
        CommunityOpenReturnsController.getOpenReturns(oq);
        List<Order> orders = CommunityOpenReturnsController.getOpenReturns(oq);
        System.assertNotEquals(null, orders);
    }

    @IsTest
    public static void testCommunityOpenOrderController() {
        final String RANDOM_SEARCH_STRING = '1';
        final Integer QUERY_LIMIT = 1;
        final Integer QUERY_OFFSET = 100;
        final Date FROM_DATE = System.now().date().addDays(-300);
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Account testAccountDis = new Account(Name = 'Test Account - DIS');
        insert testAccountDis;

        CommunityOpenOrderController.OrderQuery oq = new CommunityOpenOrderController.OrderQuery();
        oq.accountId = testAccount.Id;
        oq.soldToId = testAccountDis.Id;
        oq.searchText = RANDOM_SEARCH_STRING;
        oq.queryLimit = QUERY_LIMIT;
        oq.queryOffset = QUERY_OFFSET;
        oq.fromDate = FROM_DATE;
        List<Order> orders = CommunityOpenOrderController.getOrders(oq);
        System.assertNotEquals(null, orders);
    }

    @IsTest
    public static void testCommunityNotificationsClass() {


        final String RANDOM_SEARCH_STRING = 'Status';
        final Integer QUERY_LIMIT = 1;
        final Integer QUERY_OFFSET = 100;
        final Date FROM_DATE = System.now().date().addDays(-300);
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Account testAccountDis = new Account(Name = 'Test Account - DIS');
        insert testAccountDis;

        CommunityNotificationsClass.OrderQuery oq = new CommunityNotificationsClass.OrderQuery();
        oq.accountId = testAccount.Id;
        oq.soldToId = testAccountDis.Id;
        oq.searchText = RANDOM_SEARCH_STRING;
        oq.queryLimit = QUERY_LIMIT;
        oq.queryOffset = QUERY_OFFSET;
        oq.fromDate = FROM_DATE;
        List<Connect_Notification__c> orders = CommunityNotificationsClass.getAllNotifications(oq);
        System.assertNotEquals(null, orders);

        CommunityNotificationsClass.getNotifications([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Agent');
        CommunityNotificationsClass.getNotifications([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM Account LIMIT 1].Id, 'Customer');
        CommunityNotificationsClass.getNotifications([SELECT Id FROM Account LIMIT 1].Id, null, 'Agent');

    }
    
    @isTest
    Static void communityProductDeatilControllerTest(){
        Community_Content__c commCon = new Community_Content__c();
        commCon.Title__c = 'Content Test';
        commCon.Name = commCon.Title__c;
        commCon.Persona__c = 'All';
        commCon.Listing_Start_Date__c = date.today();
        commCon.Listing_End_Date__c = date.today();
        commCon.Accordion_Header__c = 'Accordion Test';
        commCon.Content_Type__c = 'Infographic';
        commCon.Description__c = 'This is a Test';
        commCon.Subtitle_1_Header__c = 'Applications';
        commCon.Subtitle_1_Description__c= '1. Testing';
        commCon.Subtitle_2_Header__c = 'Features';
        commCon.Subtitle_2_Description__c = '1. New';
        commCon.Hyperlink_System_Name__c = 'SFDC - Community Page';
        insert commCon;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture12'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        content.IsMajorVersion = true;
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body - Document'); 
        content.VersionData=bodyBlob; 
        insert content;
        
        ContentVersion conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content.Id];
        
        Community_Content_Sales_Kit__c commSales = new Community_Content_Sales_Kit__c();
        commSales.Community_Content__c = commCon.Id;
        commSales.Portal_User_Type__c = 'All';
        commSales.Name = 'Test Sales Kit';
        commSales.Content_Id__c = conDoc.ContentDocumentId;
        insert commSales;
        
        Community_Content_Media__c commMedia = new Community_Content_Media__c();
        commMedia.Name = 'Test Media';
        commMedia.Type__c = 'Image Link';
        commMedia.Community_Content__c = commCon.Id;
        insert commMedia;
        
        List<Community_Content_Sales_Kit__c> skList = [SELECT Content_Id__c from Community_Content_Sales_Kit__c where Community_Content__c =: commCon.Id];
        String targetEmail = 'matthew.gugumuck@gecurrent.com';
        test.startTest();
        	CommunityProductDetailController.getProductDetails(commCon.Id);
        	CommunityProductDetailController.sendFilesInEmail(skList,targetEmail);
        test.stopTest();
        
        
        
        
    }
}