@IsTest
private class ccLogicCartPlaceExtensionTest {

    @IsTest
    private static void testplaceOrder(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        ccrz__E_Order__c order=[Select Id From ccrz__E_Order__c WHERE ccrz__Account__c=:customerContact.AccountId];
        system.runAs(testUser) {
    
          Map<String, Object> lineData =
            new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ID => cart.Id,
                ccrz.ccApiCart.ORDER_ID => order.Id
            };
    
        Test.startTest();
        Test.setMock(WebServiceMock.class, new MockSAPGateway());
        ccrz.ccLogicCartPlace logicCart = new ccrz.ccLogicCartPlace();
        Map<String, Object> testInput = logicCart.processInput(lineData);
        ccLogicCartPlaceExtension addToExt = new ccLogicCartPlaceExtension();
        Map<String, Object> testResults = addToExt.placeOrder(testInput);
        System.debug(testResults);
        Test.stopTest();
        } 
    }

    @IsTest
    private static void testCreatePA(){
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PACreateMock());
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.Order_Type__c = 'Price Agreement';
        update cart;
        ccrz__E_Order__c order=[Select Id From ccrz__E_Order__c WHERE ccrz__Account__c=:customerContact.AccountId];
        system.runAs(testUser) {
    
          Map<String, Object> lineData =
            new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ID => cart.Id,
                ccrz.ccApiCart.ORDER_ID => order.Id
            };
    
        Test.startTest();
        ccrz.ccLogicCartPlace logicCart = new ccrz.ccLogicCartPlace();
        Map<String, Object> testInput = logicCart.processInput(lineData);
        ccLogicCartPlaceExtension addToExt = new ccLogicCartPlaceExtension();
        Map<String, Object> testResults = addToExt.placeOrder(testInput);
        System.debug(testResults);
        Test.stopTest();
        } 
    }

    @IsTest
    private static void testRevisePA(){
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PAReviseMock());
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
        cart.Order_Type__c = 'Revise Price Agreement';
        update cart;
        ccrz__E_Order__c order=[Select Id From ccrz__E_Order__c WHERE ccrz__Account__c=:customerContact.AccountId];
        system.runAs(testUser) {
    
          Map<String, Object> lineData =
            new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ID => cart.Id,
                ccrz.ccApiCart.ORDER_ID => order.Id
            };
    
        Test.startTest();
        ccrz.ccLogicCartPlace logicCart = new ccrz.ccLogicCartPlace();
        Map<String, Object> testInput = logicCart.processInput(lineData);
        ccLogicCartPlaceExtension addToExt = new ccLogicCartPlaceExtension();
        Map<String, Object> testResults = addToExt.placeOrder(testInput);
        System.debug(testResults);
        Test.stopTest();
        } 
    }

    @testSetup static void setupTestData() {

        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id =: customerContact.AccountId ];
        acct.GE_LGT_EM_SAP_Customer_Number__c = 'testing';
        update acct;
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
            insert cart;

            ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart.Id;
            cartItem.ccrz__Quantity__c = 1;
            cartItem.ccrz__SubAmount__c = 10;
            cartItem.ccrz__Price__c = 1.00;
            cartItem.ccrz__cartItemType__c = 'Major';
            cartItem.ccrz__ProductType__c = 'Product';
            cartItem.ccrz__Product__c = product.Id;
            insert cartItem;

            ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
                ccrz__Account__c = customerContact.AccountId,
                ccrz__EncryptedId__c = 'ORD-00000',
                ccrz__OriginatedCart__c = cart.Id,
                ccrz__Contact__c = customerContact.Id
            );
            insert testOrder;

            ccrz__E_TransactionPayment__c tp = new ccrz__E_TransactionPayment__c();
            tp.ccrz__AccountType__c = 'po';
            tp.ccrz__TransactionCode__c='ACCEPT';
            tp.ccrz__AccountNumber__c = '4100';
            tp.ccrz__CCOrder__c = testOrder.Id;
            tp.ccrz__Storefront__c = 'DefaultStore';
            tp.ccrz__PaymentType__c = '8675309';
            tp.ccrz__Contact__c = customerContact.Id;
            insert tp;
            

            ccrz__E_OrderItem__c orderItem = new ccrz__E_OrderItem__c(
                ccrz__OrderLineType__c = 'Major',
                ccrz__Product__c = product.Id,
                ccrz__Order__c = testOrder.Id,
                ccrz__Price__c = 10,
                ccrz__Quantity__c = 1,
                ccrz__SubAmount__c = 10,
                ccrz__OrderItemId__c=cartItem.Id);
                insert orderItem;
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