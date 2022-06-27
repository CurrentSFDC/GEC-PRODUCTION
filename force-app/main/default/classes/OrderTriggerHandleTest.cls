@isTest
public with sharing class OrderTriggerHandleTest {

    private static Account account = new Account();
	private static Contact contact = new Contact();
	private static User user = new User();
    private static ccrz__E_Product__c product = new ccrz__E_Product__c();
    //private static ccrz__OriginatedCart__c oc = new ccrz__OriginatedCart__c();
    private static ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
    
    @testSetup static void setupTestData() {
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
            cart.Shipping_Instructions__c='NA';
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
        
        
        /*
        account = TestDataFactory.createAccount('Test Account ', true);
        account.Account_Group__c='ZEAG';
        account.Customer_Segmentation__c='LB';
        update account;
        
		contact = TestDataFactory.createContact(account.Id, 'Test', 'Contact 1', 'test@example.com', true);
		user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(), 'Agent B2B Storefront Registered Users', true);        
		product = new ccrz__E_Product__c();
			product.ccrz__SKU__c = 'Test SKU';
			product.ccrz__ProductId__c = '543513-340';
			product.Name = 'Test Product';
			product.ccrz__Quantityperunit__c = 1;
			product.ccrz__Storefront__c = 'DefaultStore';
			product.ccrz__ProductStatus__c = 'Released';
			product.ccrz__InventoryType__c = 'STANDARD';
			product.ccrz__ProductType__c = 'Product';
            insert product;
*/
    }
    
    @IsTest
    private static void testOrderResubmissionSchedule(){
        
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact c = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_CartItem__c cartItem = [Select Id From ccrz__E_CartItem__c Where ccrz__Cart__c = :cart.Id];
        //Account a = [SELECT Id FROM Account WHERE Name='Test Account'];
        //Account account = TestDataFactory.createAccount('Test Account ', true);
		//Contact c = [SELECT Id,AccountId FROM Contact WHERE Email='test@example.com']; 
        ccrz__E_Product__c product = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = 'Test SKU' LIMIT 1];

		/*cart = new ccrz__E_Cart__c();
		cart.ccrz__Account__c = a.Id;
		cart.Sold_To_Account__c = a.Id;
		cart.Agreement_Number__c= 'testNumber';
		cart.Order_Type__c = 'Price Agreement';
		cart.Valid_To__c = Date.today();
		insert cart;*/

		/*ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
		cartItem.ccrz__Cart__c = cart.Id;
		cartItem.ccrz__Quantity__c = 1;
		cartItem.ccrz__Price__c = 1.00;
		cartItem.ccrz__cartItemType__c = 'Major';
		cartItem.ccrz__ProductType__c = 'Product';
		cartItem.ccrz__Product__c = product.Id;
		insert cartItem;*/
        
        
        ccrz__E_Order__c order = new ccrz__E_Order__c(
                ccrz__Account__c = c.AccountId,
                ccrz__EncryptedId__c = 'ORD-00000',
                ccrz__OriginatedCart__c = cart.Id,
                ccrz__Contact__c = c.Id,
                SAP_Order_Number__c='123',
                Agreement_Number__c='Test',
            	Resubmit_Order__c = true

        );
   		insert order;
        
        ccrz__E_TransactionPayment__c tp = new ccrz__E_TransactionPayment__c();
            tp.ccrz__AccountType__c = 'po';
            tp.ccrz__TransactionCode__c='ACCEPT';
            tp.ccrz__AccountNumber__c = '4100';
            tp.ccrz__CCOrder__c = order.Id;
            tp.ccrz__Storefront__c = 'DefaultStore';
            tp.ccrz__PaymentType__c = '8675309';
            tp.ccrz__Contact__c = c.Id;
            insert tp;
        
		//ccrz__E_OrderItem__c oi = new ccrz__E_OrderItem__c(ccrz__Order__c = order.Id, ccrz__Product__c = product.Id, ccrz__ExtSKU__c = 'testing', ccrz__Quantity__c = 1, ccrz__Price__c = 1.00, ccrz__SubAmount__c = 1.00);
		
        ccrz__E_OrderItem__c oi = new ccrz__E_OrderItem__c(
				ccrz__OrderLineType__c = 'Major',
				ccrz__Product__c = product.Id,
				ccrz__Order__c = order.Id,
				ccrz__Price__c = 10,
				ccrz__Quantity__c = 1,
				ccrz__SubAmount__c = 10,
				ccrz__OrderItemId__c=cartItem.Id,
				Requested_Delivery_Date__c = Date.today(),
				Type_Marks__c = 'T00',
				Comments__c = 'This is a unit test',
				Agreement_Number__c = '1234567890');
        oi.Type_Marks__c='Test';
        insert oi;
        
        System.debug('Cart ID: '+cart.Id);
        System.debug('Originated Cart C ID: '+order.ccrz__OriginatedCart__c);
        System.debug('Originated Cart R ID: '+order.ccrz__OriginatedCart__r);
        System.debug('Originated Cart R Acc C ID: '+order.ccrz__OriginatedCart__r.ccrz__Account__c);
        System.debug('Customer_Segmentation__c: '+order.ccrz__OriginatedCart__r.ccrz__Account__r.Customer_Segmentation__c);
        System.debug('Account_Group__c: '+order.ccrz__OriginatedCart__r.ccrz__Account__r.Account_Group__c);      
        
        //System.debug('order.ccrz__TransactionPayments__r[0]: '+order.ccrz__TransactionPayments__r[0]);
        //System.debug('order.ccrz__TransactionPayments__r[0].ccrz__AccountNumber__c: '+order.ccrz__TransactionPayments__r[0].ccrz__AccountNumber__c);
        
        
        if(null != order.ccrz__OriginatedCart__r){
            system.debug('non null originated cart');
        } else {
            system.debug('null originated cart');
        }
        
        if(null != order.ccrz__OriginatedCart__r.ccrz__Account__r){
            system.debug('non null originated cart Account');
        } else {
            system.debug('null originated cart Account');
        }
        
        List<ccrz__E_Order__c> updatedOrders = new List<ccrz__E_Order__c>();
        updatedOrders.add(order);
        
        OrderTriggerHandler oth = new OrderTriggerHandler();
        //OrderTriggerHandler.createOrderFuture(order.Id);
        oth.onBeforeUpdate(updatedOrders);
    }
}