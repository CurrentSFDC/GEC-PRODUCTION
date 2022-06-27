@IsTest
private class CheckoutActionsTest {

	@IsTest 
	private static void testSubmitPA(){
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
                ccrz__Account__c = customerContact.AccountId,
                ccrz__EncryptedId__c = 'ORD-00000',
                ccrz__OriginatedCart__c = cart.Id,
                ccrz__Contact__c = customerContact.Id
            );
            insert testOrder;
		system.runAs(testUser){
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
           // ctx.data = testOrder.ccrz__EncryptedId__c;
            //ctx.success = true;
			Test.startTest();
			CheckoutActions.submitPA(ctx, cart.Id);
			Test.stopTest();
		}
		ccrz__E_Order__c orderAfterPlace = [SELECT ccrz__OriginatedCart__c FROM ccrz__E_Order__c WHERE ccrz__EncryptedId__c = 'ORD-00000'];
			System.debug(orderAfterPlace);
	}

	@IsTest
	private static void updateShipFieldsTest(){
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
			CheckoutActions.updateShipFields(ctx, true, 'Test', 'Z5',  '2022-12-25', 'Instructions Test','','','',true,true);
			ccrz__E_Cart__c cartAfterUpdate = [SELECT Id, Requested_Delivery_Date__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
			System.assertEquals(Date.valueOf('2022-12-25'), cartAfterUpdate.Requested_Delivery_Date__c);
		}
		
	}

    
    @IsTest
	private static void updateShipFields1Test(){
		//User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		//Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		//ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
			//context setup
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ccrz.cc_CallContext.initRemoteContext(ctx);
			CheckoutActions.updateShipFields(ctx, true,null,null,null, null,null,null,null,null,null);
			
            //ccrz__E_Cart__c cartAfterUpdate = [SELECT Id, Requested_Delivery_Date__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
			//System.assertEquals(Date.valueOf('2022-12-25'), cartAfterUpdate.Requested_Delivery_Date__c);
	//	}
		
	}
    
    
	@IsTest
	private static void updateZ002Test(){
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
			CheckoutActions.updateZ002(ctx);
			ccrz__E_Cart__c cartAfterUpdate = [SELECT Id, Is_Z002__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
			System.assertEquals(true, cartAfterUpdate.Is_Z002__c);
		}
	}
    
	@IsTest
	private static void updateGeneralFieldsTest(){
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
			Map<String, Object> formDataTest = new Map<String, Object>(); 
			formDataTest.put('projectName','Project Name Test');
            formDataTest.put('lotPricing','on');
            formDataTest.put('lotPricingAmount','1');

			formDataTest.put('projectDescription','Project Description Test');
			formDataTest.put('orderReason','Order Reason Test');
			formDataTest.put('serialNumber','13456788');
			formDataTest.put('strategicAccount','13456788');
			formDataTest.put('validFrom','2021-01-01');
			formDataTest.put('validTo','2021-01-01');
			Map<String, Object> projectAddressTest = new Map<String, Object>();
			projectAddressTest.put('countryCode','US');
			projectAddressTest.put('city','Seven Hills');
			projectAddressTest.put('state','Ohio');
			projectAddressTest.put('stateCode','OH');
			projectAddressTest.put('postalCode','44131');
			CheckoutActions.updateGeneralFields(ctx, formDataTest,projectAddressTest);
			ccrz__E_Cart__c cartAfterUpdate = [SELECT Id, Project_Name__c FROM ccrz__E_Cart__c WHERE ccrz__Account__c = : customerContact.AccountId];
			//System.assertEquals('Project Name Test', cartAfterUpdate.Project_Name__c);
		}
		
	}
    
    @IsTest
    private static void getCustSegmentTest(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.getCustSegment(ctx);
          Test.stopTest();  
        }
        
    }
    
    @IsTest
    private static void getrelatedRepCodesTest(){
    	User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.getrelatedRepCodes(ctx,customerContact.id);
          Test.stopTest();  
        }
        
    }
     @IsTest
    private static void getSelRepCodeTest(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.getSelRepCode(ctx);
          Test.stopTest();  
        }
        
    }
    
     @IsTest
    private static void clearAddressTest(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.clearAddress(ctx);
          Test.stopTest();  
        }
        
    }
     @IsTest
    private static void getsoldToAddTest(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.getsoldToAdd(ctx);
          Test.stopTest();  
        }
        
    }
     @IsTest
    private static void clearShippingDetailsTest(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.clearShippingDetails(ctx);
          Test.stopTest();  
        }
        
    }
    
     @IsTest
    private static void cleardefaultShippingDetailsTest(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        
        
        ccrz__E_ContactAddr__c conZ002 = new ccrz__E_ContactAddr__c();
         	 conZ002.ccrz__CompanyName__c = 'Acumen';
             conZ002.ccrz__City__c = 'McLean';
             conZ002.ccrz__Country__c = 'United States';
             conZ002.ccrz__State__c = 'Virginia';
             conZ002.ccrz__PostalCode__c = '22102';
             conZ002.ccrz__AddressFirstline__c = '8280 Greensboro Dr #400';
            insert conZ002;
      
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
            cart.ccrz__Account__c = customerContact.AccountId;
            cart.ccrz__Name__c = 'testCart';
        	cart.Is_Z002__c = false;
        	cart.ccrz__ShipTo__c=conZ002.id;
            insert cart;
        
           	cart.Is_Z002__c = true;       	
        	//cart1.id = cart.id;
            update cart;
        
        conZ002.ccrz__CompanyName__c='';
            conZ002.ccrz__City__c='';
            conZ002.ccrz__Country__c='';
            conZ002.ccrz__State__c='';
            conZ002.ccrz__PostalCode__c='';
            conZ002.ccrz__AddressFirstline__c='';
			update conZ002;
        
      /*  if(!cart.Is_Z002__c){
            ccrz__E_ContactAddr__c conZ0022 = [SELECT ccrz__CompanyName__c,ccrz__City__c,ccrz__Country__c,ccrz__State__c,ccrz__PostalCode__c,ccrz__AddressFirstline__c FROM ccrz__E_ContactAddr__c];
            cart.Is_Z002__c=true;
            update cart;
        }*/
        	
        
		//ccrz__E_Cart__c cart1 = [SELECT Id, ccrz__EncryptedId__c,Is_Z002__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart' limit 1];
		system.runAs(testUser){
			//context setup
		

			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.cleardefaultShippingDetails(ctx);
          Test.stopTest();  
        }
        
    }
    
     @IsTest
    private static void getAllrelatedZ002AddTest(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Account Acc = new Account(Name = 'TestAcc');
            acc.Account_Group__c = 'ZEAG';
            acc.Customer_Segmentation__c = 'Test1';
        Insert Acc;
        Contact customerContact = [Select id From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		customerContact.AccountId=Acc.id;
        update customerContact;
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		cart.ccrz__Contact__c = customerContact.id;
        update cart;
        system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.getAllrelatedZ002Add(ctx);
          Test.stopTest();  
        }
        
    }
    
    @IsTest
    private static void getAllrelatedZ002Add1Test(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Account Acc = new Account(Name = 'TestAcc');
            acc.Account_Group__c = 'ZEAG';
            acc.Customer_Segmentation__c = 'Test1';
        Insert Acc;
        Contact customerContact = [Select id From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		customerContact.AccountId=Acc.id;
        update customerContact;
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		cart.ccrz__Contact__c = customerContact.id;
        update cart;
        system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.getAllrelatedZ002Add(ctx);
          Test.stopTest();  
        }
        
    }
    
    
    @IsTest
    private static void saveShippingDetailsTest(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.saveShippingDetails(ctx,'Test','Test','Test','Test','Test','Test','Test','Test');
          Test.stopTest();  
        }
        
    }
    
    @IsTest
    private static void saveShippingDetails1Test(){
    User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		system.runAs(testUser){
			//context setup
			
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ctx.currentCartId = cart.ccrz__EncryptedId__c;
			ccrz.cc_CallContext.initRemoteContext(ctx);
            Test.startTest();

        CheckoutActions.saveShippingDetails(ctx,'','','','','','','Test','Test');
          Test.stopTest();  
        }
        
    }

	@testSetup static void setupTestData() {

        b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		system.runAs(testUser){
            Account Acc = new Account(Name = 'TestAcc');
            acc.ConnectFixtureAgents__c = 'Test';
            acc.Customer_Segmentation__c = 'Test1';
        Insert Acc;
            
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
       // Agreement_Number__c='Test';
          //  testOrder.Order_Type__c='Test';
           // testOrder.SAP_Message__c='Test';
        //   SAP_Order_Number__c='123';
          // testOrder.Order_Type__c = 'Purchase Order';
            insert testOrder;
		system.runAs(testUser){
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			Test.startTest();
			CheckoutActions.getSAPOrderNo(ctx, testOrder.Id);
			Test.stopTest();
		}
		
	}

 @IsTest 
	private static void getusermailtest(){
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
                ccrz__Account__c = customerContact.AccountId,
                ccrz__EncryptedId__c = 'ORD-00000',
                ccrz__OriginatedCart__c = cart.Id,
                ccrz__Contact__c = customerContact.Id
            );
            insert testOrder;
		system.runAs(testUser){
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
           // ctx.data = testOrder.ccrz__EncryptedId__c;
            //ctx.success = true;
			Test.startTest();
			CheckoutActions.getusermail(ctx, testUser.id);
			Test.stopTest();
        }  
    }
  @IsTest 
	private static void getvalidPotest(){
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account act = [Select id From Account Where ID =:customerContact.AccountId];
        order testOrder = new order();
        
        testorder.Sold_To__c=customerContact.AccountId;
        testorder.Customer_PO_Number__c='123';
        testorder.account=act;

            //insert testOrder;
        String soldto=customerContact.AccountId;
		system.runAs(testUser){
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			ctx.effAccountId = customerContact.AccountId;
			ctx.portalUserId = testUser.Id;
			ccrz.cc_CallContext.initRemoteContext(ctx);

			Test.startTest();
			CheckoutActions.validateUniquePO(ctx,'123',soldto);
			Test.stopTest();
        }  
    }

	@IsTest
	private static void testGetOrderInfoById() {
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
				ccrz__Account__c = customerContact.AccountId,
				ccrz__EncryptedId__c = 'ORD-00000',
				ccrz__OriginatedCart__c = cart.Id,
				ccrz__Contact__c = customerContact.Id,
				Agreement_Number__c = '1234567890',
				ccrz__BuyerFirstName__c = 'Test',
				ccrz__BuyerLastName__c = 'Test',
				ccrz__BuyerPhone__c = '000-000-0000',
				ccrz__BuyerEmail__c = 'test@test.com'
		);
		insert testOrder;
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			// ctx.data = testOrder.ccrz__EncryptedId__c;
			//ctx.success = true;
			Test.startTest();
			CheckoutActions.getOrderInfoById(ctx, testOrder.Id);
        CheckoutActions.StrategicAccounts(ctx);
			Test.stopTest();
	}

	@IsTest
	private static void testcartOrigin() {
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
				ccrz__Account__c = customerContact.AccountId,
				ccrz__EncryptedId__c = 'ORD-00000',
				ccrz__OriginatedCart__c = cart.Id,
				ccrz__Contact__c = customerContact.Id,
				Agreement_Number__c = '1234567890',
				ccrz__BuyerFirstName__c = 'Test',
				ccrz__BuyerLastName__c = 'Test',
				ccrz__BuyerPhone__c = '000-000-0000',
				ccrz__BuyerEmail__c = 'test@test.com'
		);
		insert testOrder;
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
			ctx.storefront = 'DefaultStore';
			// ctx.data = testOrder.ccrz__EncryptedId__c;
			//ctx.success = true;
			Test.startTest();
			CheckoutActions.getCartOrigin(ctx, cart.Id);
			Test.stopTest();
	}

	@IsTest
	private static void testOrderItemInfo() {
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
		Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
		ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
		ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
				ccrz__Account__c = customerContact.AccountId,
				ccrz__EncryptedId__c = 'ORD-00000',
				ccrz__OriginatedCart__c = cart.Id,
				ccrz__Contact__c = customerContact.Id,
				Agreement_Number__c = '1234567890'
		);
		insert testOrder;
		ccrz__E_Product__c product = [SELECT Id FROM ccrz__E_Product__C LIMIT 1];
		ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
		cartItem.ccrz__Cart__c = cart.Id;
		cartItem.ccrz__Quantity__c = 1;
		cartItem.ccrz__Price__c = 1.00;
		cartItem.ccrz__cartItemType__c = 'Major';
		cartItem.ccrz__ProductType__c = 'Product';
		cartItem.ccrz__Product__c = product.Id;
		cartItem.Agreement_Number__c = '1234567890';
		insert cartItem;
		ccrz__E_OrderItem__c orderItem = new ccrz__E_OrderItem__c(
				ccrz__OrderLineType__c = 'Major',
				ccrz__Product__c = product.Id,
				ccrz__Order__c = testOrder.Id,
				ccrz__Price__c = 10,
				ccrz__Quantity__c = 1,
				ccrz__SubAmount__c = 10,
				ccrz__OrderItemId__c=cartItem.Id,
				Requested_Delivery_Date__c = Date.today(),
				Type_Marks__c = 'T00',
				Comments__c = 'This is a unit test',
				Agreement_Number__c = '1234567890');
		insert orderItem;
		ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
		ctx.storefront = 'DefaultStore';
		// ctx.data = testOrder.ccrz__EncryptedId__c;
		//ctx.success = true;
		Test.startTest();
		String reqD = CheckoutActions.getItemReqDeviveryDate(ctx, orderItem.Id).data.toString();
		String typeM = CheckoutActions.getItemTypeMarks(ctx, orderItem.Id).data.toString();
		String comment = CheckoutActions.getItemComment(ctx, orderItem.Id).data.toString();
		String agreementNo = CheckoutActions.getOrderItemPriceAgreementNumber(ctx, orderItem.Id).data.toString();
		Test.stopTest();
		System.assertEquals(CheckoutActions.formatDate(Date.today()), reqD);
		System.assertEquals('T00', typeM);
		System.assertEquals('This is a unit test', comment);
		System.assertEquals('1234567890', agreementNo);
	}
    @IsTest
	private static void StrategicAccounts_NewTest() {
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
            Account Acc = new Account(Name = 'TestAcc');
            acc.GE_LGT_EM_SAP_Customer_Number__c = 'Test1';
        		ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();

        Insert Acc;
			Test.startTest();
			CheckoutActions.StrategicAccounts_New(ctx, acc.Id);
			Test.stopTest();
	}

    
}