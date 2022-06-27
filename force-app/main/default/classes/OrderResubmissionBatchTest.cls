@isTest(seeAllData=false)
private class OrderResubmissionBatchTest {

	@isTest
	private static void testOrderResubmission(){
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        List<ccrz__E_Cart__c> cart  = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		List<ccrz__E_Order__c> order =[Select Id,Ship_Not_Before_Date__c From ccrz__E_Order__c WHERE ccrz__Account__c=:customerContact.AccountId];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(UserInfo.getUserId());
        System.debug('###  mail.setTargetObjectId(UserInfo.getUserId()) ' +  UserInfo.getUserId());            
        String[] sendingTo = new String[]{'test@gmail.com'};
        mail.setToAddresses(sendingTo);
        mail.setSubject('Subject');
        mail.setSaveAsActivity(false);
        mail.setHtmlBody('body');
        Messaging.sendEmail(new List<Messaging.Email> {mail});
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new MockSAPGateway());
        OrderResubmissionBatch batch = new OrderResubmissionBatch();
        Database.executeBatch(batch);
       // batch.finish();
        Test.stopTest();
	}

	@IsTest
	private static void testOrderResubmissionSchedule(){

        Test.startTest();
        Test.setMock(WebServiceMock.class, new MockSAPGateway());

		OrderResubmissionBatch sh1 = new OrderResubmissionBatch();

		String sch = '0 0 23 * * ?'; 
		system.schedule('Test Order Resubmission Batch', sch, sh1);
		
		Test.stopTest();
		
	}

	@testSetup static void setupTestData() {

        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id =: customerContact.AccountId ];
        acct.GE_LGT_EM_SAP_Customer_Number__c = 'testing';
        update acct;
        ExceptionLoggingFramework__c elf = new ExceptionLoggingFramework__c();
		elf.Enabled__c=true;
		elf.EmailNotificationEnabled__c=true;
		insert elf;
        system.runAs(testUser){
        ccrz__E_ContactAddr__c defaultShippingAddress = new ccrz__E_ContactAddr__c(
                ccrz__AddressFirstline__c = 'Test Street',
                ccrz__AddressSecondline__c = 'Test Line 2',
                ccrz__City__c = 'City',
                ccrz__StateISOCode__c = 'OH',
                ccrz__PostalCode__c = '11111',
                ccrz__CountryISOCode__c = 'US',
                ccrz__FirstName__c = 'First',
                ccrz__LastName__c = 'Last');
        insert defaultShippingAddress;

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
            cart.Partial_Ship__c=true;
            cart.Carrier_Account__c='Test';
            cart.Delivery_Block__c='Z3';
            cart.Order_Reason__c='Test';
            cart.Order_Type__c = 'Purchase Order';
            cart.Project_Name__c='Test Project';
            cart.Requested_Delivery_Date__c=Date.valueOf('2022-12-25');
            cart.Shipping_Instructions__c='Test Shipping Instructions';
            cart.Serial_Number__c='12345678';
            cart.Strategic_Account__c='12345678';
            cart.ccrz__Contact__c=customerContact.Id;
            cart.ccrz__ShipTo__c=defaultShippingAddress.Id;
            cart.Ship_Not_Before_Date__c=true;   

            insert cart;

            ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart.Id;
            cartItem.ccrz__Quantity__c = 1;
            cartItem.ccrz__Price__c = 1.00;
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__Product__c = product.Id;
            insert cartItem;

            ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
                ccrz__Account__c = customerContact.AccountId,
                ccrz__EncryptedId__c = 'ORD-00000',
                ccrz__OriginatedCart__c = cart.Id,
				ccrz__Contact__c = customerContact.Id,
				ccrz__OrderStatus__c='Order Submitted',
                Resubmit_Order__c=true,
                Resubmission_Attempts__c = 2
            );
           // testOrder.Ship_Not_Before_Date__c = true;
            insert testOrder;

            ccrz__E_OrderItem__c orderItem = new ccrz__E_OrderItem__c(
                ccrz__OrderLineType__c = 'Major',
                ccrz__Product__c = product.Id,
                ccrz__Order__c = testOrder.Id,
                ccrz__Price__c = 10,
                ccrz__Quantity__c = 1,
                ccrz__SubAmount__c = 10,
                ccrz__OrderItemId__c=cartItem.Id);
				insert orderItem;
				
				ccrz__E_OrderItem__c orderItem2 = new ccrz__E_OrderItem__c(
                ccrz__OrderLineType__c = 'Major',
                ccrz__Product__c = product.Id,
                ccrz__Order__c = testOrder.Id,
                ccrz__Price__c = 11,
                ccrz__Quantity__c = 1,
                ccrz__SubAmount__c = 10,
                ccrz__OrderItemId__c=cartItem.Id);
				insert orderItem2;
				
				ccrz__E_TransactionPayment__c tp = new ccrz__E_TransactionPayment__c();
		tp.ccrz__AccountType__c = 'po';
		tp.ccrz__TransactionCode__c='ACCEPT';
		tp.ccrz__AccountNumber__c = '4100';
		tp.ccrz__CCOrder__c = testOrder.Id;
		tp.ccrz__Storefront__c = 'DefaultStore';
		tp.ccrz__PaymentType__c = '8675309';
		tp.ccrz__Contact__c = customerContact.Id;
        insert tp;
        


        ccrz__E_Cart__c cart3 = new ccrz__E_Cart__c();
        cart3.ccrz__Account__c = customerContact.AccountId;
        cart3.ccrz__Name__c = 'testCart';
        cart3.Partial_Ship__c=true;
        cart3.Carrier_Account__c='Test';
        cart3.Delivery_Block__c='Z3';
        cart3.Order_Reason__c='Test';
        cart3.Order_Type__c = 'Purchase Order';
        cart3.Project_Name__c='Test Project';
        cart3.Requested_Delivery_Date__c=Date.valueOf('2022-12-25');
        cart3.Shipping_Instructions__c='Test Shipping Instructions';
        cart3.Serial_Number__c='12345679';
        cart3.Ship_Not_Before_Date__c = true;
        cart3.Strategic_Account__c='12345679';
        cart3.ccrz__Contact__c=customerContact.Id;
        cart3.ccrz__ShipTo__c=defaultShippingAddress.Id;
         cart3.Ship_Not_Before_Date__c=true;   
        insert cart3;

        ccrz__E_CartItem__c cartItem3 = new ccrz__E_CartItem__c();
        cartItem3.ccrz__Cart__c = cart3.Id;
        cartItem3.ccrz__Quantity__c = 1;
        cartItem3.ccrz__Price__c = 1.00;
        cartItem3.ccrz__cartItemType__c = 'Major';
        cartItem3.ccrz__ProductType__c = 'Product';
        cartItem3.ccrz__Product__c = product.Id;
        insert cartItem3;

        ccrz__E_Order__c testOrder3 = new ccrz__E_Order__c(
            ccrz__Account__c = customerContact.AccountId,
            ccrz__EncryptedId__c = 'ORD-00001',
            ccrz__OriginatedCart__c = cart3.Id,
            ccrz__Contact__c = customerContact.Id,
            ccrz__OrderStatus__c='Order Submitted',
            Resubmit_Order__c=true,
            Resubmission_Attempts__c = 3

        );
        insert testOrder3;

        ccrz__E_OrderItem__c orderItem3 = new ccrz__E_OrderItem__c(
            ccrz__OrderLineType__c = 'Major',
            ccrz__Product__c = product.Id,
            ccrz__Order__c = testOrder3.Id,
            ccrz__Price__c = 10,
            ccrz__Quantity__c = 1,
            ccrz__SubAmount__c = 10,
            ccrz__OrderItemId__c=cartItem3.Id);
            insert orderItem3;            

            
            ccrz__E_TransactionPayment__c tp3 = new ccrz__E_TransactionPayment__c();
            tp3.ccrz__AccountType__c = 'po';
            tp3.ccrz__TransactionCode__c='ACCEPT';
            tp3.ccrz__AccountNumber__c = '4100';
            tp3.ccrz__CCOrder__c = testOrder3.Id;
            tp3.ccrz__Storefront__c = 'DefaultStore';
            tp3.ccrz__PaymentType__c = '8675309';
            tp3.ccrz__Contact__c = customerContact.Id;
            insert tp3;

        }    
    }
    
    private class MockSAPGateway implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                sapComDocumentSapRfcFunctions.x_xGEL_xSFB2B_ORDER_CREATE_Response_element response_x =new sapComDocumentSapRfcFunctions.x_xGEL_xSFB2B_ORDER_CREATE_Response_element();
                response_x.E_SALES_NUMBER = '123456';
                response.put('response_x', response_x);
        }
        
	}
	
	


}