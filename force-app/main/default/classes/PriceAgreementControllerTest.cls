// PriceAgreementControllerTest class
// Test class for the PriceAgreementController class
// ------------------------------------------------------------------
//  Author                    Date         Description
// ------------------------------------------------------------------
//  Devang Shah	              08/12/2020   Created
//
@IsTest 
public with sharing class PriceAgreementControllerTest {
    private static Account account = new Account();
    private static Contact contact = new Contact();
    private static User user = new User();
    private static ccrz__E_Product__c product = new ccrz__E_Product__c();
    
    //EM- @testSetup is run once before the tests are run, no need to run the method every time
    @testSetup
    private static void setupData() {
        
        account = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(account.Id, 'Test', 'Contact 1', 'test@example.com', true);
        user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);
        product = TestDataFactory.createCCProduct('123456', 'Test product', true);
        ExceptionLoggingFramework__c elf = new ExceptionLoggingFramework__c();
        elf.Enabled__c=true;
        elf.EmailNotificationEnabled__c=true;
        insert elf;   
        
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
            cart.ccrz__Account__c = account.Id;
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
            
            ccrz__E_CartItem__c cartItem2 = new ccrz__E_CartItem__c();
            cartItem2.ccrz__Cart__c = cart.Id;
            cartItem2.ccrz__Quantity__c = 1;
            cartItem2.ccrz__Price__c = 1.00;
            cartItem2.ccrz__cartItemType__c = 'Major';
            cartItem2.ccrz__ProductType__c = 'Product';
            cartItem2.ccrz__Product__c = product.Id;
			insert cartItem2;
    }

    @IsTest
    private static void testGetAccount() {
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.startTest();
        System.runAs(user) {
            Account a = InventoryController.getAccount();
            System.AssertNotEquals(Null, a.Id); 
        }
        Test.stopTest();
    }

    @isTest public static void testSoldToSearch(){

        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Contact c = [SELECT AccountId FROM Contact WHERE Email='test@example.com'];

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.effAccountId = c.AccountId;

        Test.startTest();
        List<Account> test1 = PriceAgreementController.initSearchSoldTo(ctx, c.Id);
        Test.stopTest();
    }

    @IsTest
	public static void testGetRealTimePricingRemoteAction() {  
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());      
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name='Test Account'];
        string calltype='o';
        String agentID= a.id;
        String custId= a.id;   
        String skusJson = '[{"material": "12377","UOM": "BX"}]';
           // '["SKU":12377"]';
        String productsJson = '["a7s3F000000CjvIQAS"]';
        Test.StartTest();
        System.runAs(user) {
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = a.Id;
            PriceAgreementController.service = new SAPGateway();
            ccrz.cc_RemoteActionResult res = PriceAgreementController.getRealTimePricing(ctx, skusJson,agentID,custId,calltype, true);
            res = PriceAgreementController.getRealTimePricing(ctx, skusJson,agentID,custId,calltype, false);
            System.assertNotEquals(null, ((PriceAgreementController.PriceAgreementResponse) res.data));
			PriceAgreementController.getAccType(ctx,a.id);            
        }
		Test.StopTest();
    }


    @IsTest
    public static void testGetPricingUOM(){
       
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name='Test Account'];
        ccrz__E_Product__c product = [SELECT Id, ccrz__SKU__c FROM ccrz__E_Product__c WHERE ccrz__SKU__c = '123456' LIMIT 1];
        List<Pricing_UOM__c> pl = (List<Pricing_UOM__c>)TestDataFactory.createPricingUOM(product.Id, '123456');   
        Test.StartTest();
        System.runAs(user) {
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
   
            ccrz.cc_RemoteActionResult res = PriceAgreementController.getPricingUOM(ctx, product.ccrz__SKU__c);
            System.assertNotEquals(null, ((Map<String, Decimal>) res.data));            
        }
		    Test.StopTest();
    }


    
    @IsTest
    public static void testPAValidate(){
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name='Test Account'];
        ccrz__E_Product__c product = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = '123456' LIMIT 1];

        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
            cart.ccrz__Account__c = a.Id;
            cart.Sold_To_Account__c = a.Id;
            cart.Agreement_Number__c= 'testNumber';
            cart.OwnerId=user.Id;
      insert cart;

      ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
      cartItem.ccrz__Cart__c = cart.Id;
      cartItem.ccrz__Quantity__c = 1;
      cartItem.ccrz__Price__c = 1.00;
      cartItem.ccrz__cartItemType__c = 'Major';
      cartItem.ccrz__ProductType__c = 'Product';
      cartItem.ccrz__Product__c = product.Id;
      insert cartItem;

      Test.startTest();
      System.runAs(user){
        PriceAgreementController.PriceAgreementResponse resp = PriceAgreementController.validatePriceAgreement('USD', (String)cart.Id);
      }
      Test.stopTest();
    }

    @IsTest
    public static void testRevisePAValidate(){
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name='Test Account'];
        ccrz__E_Product__c product = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = '123456' LIMIT 1];

        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
            cart.ccrz__Account__c = a.Id;
            cart.Sold_To_Account__c = a.Id;
            cart.Agreement_Number__c= 'testNumber';
            cart.OwnerId=user.Id;
      insert cart;

      ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
      cartItem.ccrz__Cart__c = cart.Id;
      cartItem.ccrz__Quantity__c = 1;
      cartItem.ccrz__Price__c = 1.00;
      cartItem.ccrz__cartItemType__c = 'Major';
      cartItem.ccrz__ProductType__c = 'Product';
      cartItem.ccrz__Product__c = product.Id;
      insert cartItem;

      Test.startTest();
      System.runAs(user){
        PriceAgreementController.PriceAgreementResponse resp = PriceAgreementController.revisePriceAgreementValidate('USD', (String)cart.Id);
      }
      Test.stopTest();
    }

    @IsTest
    public static void testPACreate(){
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PACreateMock());
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name='Test Account'];
        Contact c = [SELECT Id FROM Contact WHERE Email='test@example.com'];
        ccrz__E_Product__c product = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = '123456' LIMIT 1];

        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
            cart.ccrz__Account__c = a.Id;
            cart.Sold_To_Account__c = a.Id;
            cart.Agreement_Number__c= 'testNumber';
            cart.Order_Type__c = 'Price Agreement';
            cart.Valid_To__c = Date.today();
      insert cart;

      ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
      cartItem.ccrz__Cart__c = cart.Id;
      cartItem.ccrz__Quantity__c = 1;
      cartItem.ccrz__Price__c = 1.00;
      cartItem.ccrz__cartItemType__c = 'Major';
      cartItem.ccrz__ProductType__c = 'Product';
      cartItem.ccrz__Product__c = product.Id;
      insert cartItem;

      ccrz__E_Order__c order = new ccrz__E_Order__c(ccrz__Contact__c = c.Id, ccrz__OriginatedCart__c = cart.Id);
      insert order;
      ccrz__E_OrderItem__c oi = new ccrz__E_OrderItem__c(ccrz__Order__c = order.Id, ccrz__Product__c = product.Id, ccrz__ExtSKU__c = 'testing', ccrz__Quantity__c = 1, ccrz__Price__c = 1.00, ccrz__SubAmount__c = 1.00);
      insert oi;

      ccrz__E_Order__c newOrder=[Select 
        Id,
        Name,
        Partial_Ship__c,
        ccrz__CurrencyISOCode__c,
        Carrier_Account__c,
        Delivery_Block__c,
        Order_Reason__c,
        Project_Name__c,
        Project_City__c,
        Project_State__c,
        Project_Country__c,
        Project_Description__c,
        Project_Postal_Code__c,
        Requested_Delivery_Date__c,
        Strategic_Account__c,
        Sold_To_Account__c,
        Serial_Number__c,
        SAP_Order_Number__c,
        Order_Type__c,
        Revise_Agreement_Number__c,
        Agreement_Number__c,
        SAP_Message__c,
        SAP_Approved__c,
        Valid_From__c,
        Valid_To__c,
        ccrz__BuyerFirstName__c,
        ccrz__BuyerLastName__c,
        ccrz__BuyerEmail__c,
        ccrz__BuyerPhone__c,                             
        ccrz__OriginatedCart__r.Lot_Pricing__c,
        ccrz__OriginatedCart__r.Lot_Pricing_Amount__c,
        ccrz__OriginatedCart__r.Project_Description__c,
        ccrz__OriginatedCart__r.Sample_Order__c,
        ccrz__OriginatedCart__r.Shipping_Instructions__c,
        ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__OriginatedCart__r.Strategic_Account_L__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__OriginatedCart__r.Is_Z002__c,
        ccrz__ShipTo__r.ccrz__AddressFirstline__c, 
        ccrz__ShipTo__r.ccrz__AddressSecondline__c, 
        ccrz__ShipTo__r.ccrz__StateISOCode__c, 
        ccrz__ShipTo__r.ccrz__City__c, 
        ccrz__ShipTo__r.ccrz__PostalCode__c, 
        ccrz__ShipTo__r.ccrz__CountryISOCode__c, 
        ccrz__ShipTo__r.ccrz__FirstName__c, 
        ccrz__ShipTo__r.ccrz__LastName__c,
        ccrz__Contact__r.Email,
        ccrz__Contact__r.Phone,
        ccrz__Contact__r.Name,
        ccrz__Contact__r.Account.Account_Group__c,
        ccrz__Contact__r.Account.GE_LGT_Rep_Code__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Distribution_Channel__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Division__c,
        ccrz__Contact__r.Account.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__Contact__r.GE_LGT_EM_SAP_Customer_No__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Sales_Org__c,
        (Select Id, ccrz__AccountNumber__c From ccrz__TransactionPayments__r)
        From ccrz__E_Order__c Where Id=:order.Id];
      Test.startTest();
      System.runAs(user){
        PriceAgreementController.PriceAgreementCreateResponse resp = PriceAgreementController.PriceAgreementCreateNew(newOrder, new List<ccrz__E_OrderItem__c>{oi});
      }
      Test.stopTest();
    }

    @IsTest
    public static void testPARevise(){
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PAReviseMock());
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name='Test Account'];
        a.Account_Group__c= 'ZEAG';
        update a;
        Contact c = [SELECT Id FROM Contact WHERE Email='test@example.com'];
        ccrz__E_Product__c product = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = '123456' LIMIT 1];

        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
            cart.ccrz__Account__c = a.Id;
            cart.Sold_To_Account__c = a.Id;
            cart.Agreement_Number__c= 'testNumber';
            cart.Order_Type__c = 'Price Agreement';
            cart.Valid_To__c = Date.today();
      insert cart;

      ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
      cartItem.ccrz__Cart__c = cart.Id;
      cartItem.ccrz__Quantity__c = 1;
      cartItem.ccrz__Price__c = 1.00;
      cartItem.ccrz__cartItemType__c = 'Major';
      cartItem.ccrz__ProductType__c = 'Product';
      cartItem.ccrz__Product__c = product.Id;
      insert cartItem;

      ccrz__E_Order__c order = new ccrz__E_Order__c(ccrz__Contact__c = c.Id, ccrz__OriginatedCart__c = cart.Id);
      insert order;
      ccrz__E_OrderItem__c oi = new ccrz__E_OrderItem__c(ccrz__Order__c = order.Id, ccrz__Product__c = product.Id, ccrz__ExtSKU__c = 'testing', ccrz__Quantity__c = 1, ccrz__Price__c = 1.00, ccrz__SubAmount__c = 1.00);
      insert oi;

      ccrz__E_Order__c newOrder=[Select 
        Id,
        Name,
        Partial_Ship__c,
        ccrz__CurrencyISOCode__c,
        Carrier_Account__c,
        Delivery_Block__c,
        Order_Reason__c,
        Project_Name__c,
        Project_City__c,
        Project_State__c,
        Project_Country__c,
        Project_Description__c,
        Project_Postal_Code__c,
        Requested_Delivery_Date__c,
        Strategic_Account__c,
        Sold_To_Account__c,
        Serial_Number__c,
        SAP_Order_Number__c,
        Order_Type__c,
        Revise_Agreement_Number__c,
        Agreement_Number__c,
        SAP_Message__c,
        SAP_Approved__c,
        Valid_From__c,
        Valid_To__c,
        ccrz__BuyerFirstName__c,
        ccrz__BuyerLastName__c,
        ccrz__BuyerEmail__c,
        ccrz__BuyerPhone__c,                         
        ccrz__OriginatedCart__r.Lot_Pricing__c,
        ccrz__OriginatedCart__r.Lot_Pricing_Amount__c,
        ccrz__OriginatedCart__r.Project_Description__c,
        ccrz__OriginatedCart__r.Sample_Order__c,
        ccrz__OriginatedCart__r.Shipping_Instructions__c,
        ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__OriginatedCart__r.Strategic_Account_L__r.GE_LGT_EM_SAP_Customer_Number__c,                         
        ccrz__OriginatedCart__r.Is_Z002__c,
        ccrz__ShipTo__r.ccrz__AddressFirstline__c, 
        ccrz__ShipTo__r.ccrz__AddressSecondline__c, 
        ccrz__ShipTo__r.ccrz__StateISOCode__c, 
        ccrz__ShipTo__r.ccrz__City__c, 
        ccrz__ShipTo__r.ccrz__PostalCode__c, 
        ccrz__ShipTo__r.ccrz__CountryISOCode__c, 
        ccrz__ShipTo__r.ccrz__FirstName__c, 
        ccrz__ShipTo__r.ccrz__LastName__c,
        ccrz__Contact__r.Email,
        ccrz__Contact__r.Phone,
        ccrz__Contact__r.Name,
        ccrz__Contact__r.Account.Account_Group__c,
        ccrz__Contact__r.Account.GE_LGT_Rep_Code__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Distribution_Channel__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Division__c,
        ccrz__Contact__r.Account.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__Contact__r.GE_LGT_EM_SAP_Customer_No__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Sales_Org__c,
        (Select Id, ccrz__AccountNumber__c From ccrz__TransactionPayments__r)
        From ccrz__E_Order__c Where Id=:order.Id];

      Test.startTest();
      System.runAs(user){
        PriceAgreementController.PriceAgreementCreateResponse resp = PriceAgreementController.PriceAgreementRevise(newOrder, new List<ccrz__E_OrderItem__c>{oi});
      }
      Test.stopTest();
    }

    @IsTest
	public static void testGetRealTimePricingForInvalidCatalogNoRemoteAction() {  
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());      
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name='Test Account'];
        string calltype1='o';
        String agentID= a.id;
        String custId= a.id; 
        String catalogNumber = '["1234420"]';
        List<String> catalogNumberList = new List<String>();
        catalogNumberList.add('1234420');
        Test.StartTest();
        System.runAs(user) {
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = a.Id;
            PriceAgreementController.service = new SAPGateway();
            ccrz.cc_RemoteActionResult res = PriceAgreementController.getRealTimePricingForInvalidCatalogNo(ctx, catalogNumber,agentID,custId,calltype1);
            System.assertNotEquals(null, ((PriceAgreementController.PriceAgreementResponse) res.data));            
        	ccrz.cc_RemoteActionResult res1 = PriceAgreementController.getRealTimePricingForMultipleInvalidCatalogNo(ctx, catalogNumberList,agentID,custId,calltype1);
        }
		Test.StopTest();
    }

    @IsTest
	public static void testGetRealTimePricingForCommissionCalcRemoteAction() {  
    Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());      
    User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
    Account a = [SELECT Id FROM Account WHERE Name='Test Account'];   
    Test.StartTest();
    System.runAs(user) {
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.effAccountId = a.Id;
        PriceAgreementController.service = new SAPGateway();
        ccrz.cc_RemoteActionResult res = PriceAgreementController.getRealTimePricingForCommissionCalc(ctx, '12377', a.Id, '100.00', 'USD', 'calccommission', 'PC', '1');
        System.assertNotEquals(null, ((PriceAgreementController.PriceAgreementResponse) res.data));            
    }
    Test.StopTest();
  }




    private class MockSAPGateway extends SAPGatewayMock {
		public override PriceAgreementController.PriceAgreementResponse getRealTimePricing(PriceAgreementController.PriceAgreementRequest request) {
            PriceAgreementController.PriceAgreementResponse response = new PriceAgreementController.PriceAgreementResponse();
            response.agent = 'DT5';
            response.extAgent = 'DT5';
            response.distChannel = '20';
            response.customer = '0800';
            response.division = '10';
            response.orderType = 'N';            
            response.poNumber = '123';
            response.poType = '';
            response.agrDate = '20201127';
            response.userType = '';
            response.salesOrg = '1US1';
            response.division = '10';
            response.SKU = '12377';
            response.agreement = '123';
            response.userType = 'Agent';
            response.orderFlag = 'N';
            response.orderReason = 'Test';


            

            List<PriceAgreementController.PriceAgreementItem> priceAgreementList = new List<PriceAgreementController.PriceAgreementItem>();
            PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
            
            pai.SKU = '12377';
            pai.material = '';
            pai.description = '1234420';
            pai.lineNumber = 00010;
            pai.quantity= 100; 
            pai.UOM = 'PC';
            pai.requestedPrice= 300;
            pai.currencyISOCode = 'USD';
            pai.agreement = '';
            pai.reqDelDate = '20201230';
            pai.roundedQty = 6;
            pai.substitueMaterial = '';
            pai.substitueReason = '';
            pai.reasonRej = '';
            pai.reasonRejText = '';
            pai.weeeLamp = '';
            pai.weeeLight = '';
            pai.weeeLampIr = '';
            pai.adpPrice = 550.00;
            pai.floorPrice = 500.00;
            pai.globalCommission = 20.00;
            pai.floorCommission = 2.00;
            pai.leadTime = '5';       
            pai.bookPrice= 600.00;
            pai.extendedPrice= 100.00;
            pai.availableQty= 500;
            pai.quantityOnHand= 300;
            pai.commission= 50.00;
            pai.commissionPer= 5.00;
            pai.message = 'Text';          
            pai.netCredit= 50.00;
            pai.lineComments = '';
            pai.countryOfOrigin = 'India';
            pai.productHierarchy = 'PH1';
            pai.plant = '1WML';
            
            pai.slidingCommission  = 20.00;   
            pai.slidingCommissionPercentage = 2.00;
            pai.standardPackQty= 6;
            pai.warehouseAvailability = 500; 
            pai.overagePercentagePerc= 2.00;
            pai.lightTax= '10';            
            pai.palletQty = 30;
            pai.priceAgreementValue= 100;
            pai.ukPalletQty = 6;            
            pai.overageAmount= 20.00;
            
            priceAgreementList.add(pai);
            response.priceAgreementItemList = priceAgreementList;
            return response;
        }
    }
     public static testmethod void IpCraspCompFieldstest(){
     PriceAgreementController.IpCraspCompFields a = new PriceAgreementController.IpCraspCompFields();
     a.manufacturer='Test';
     a.distributor='Test';
     a.datab ='Test';
     a.datbi ='Test';
     a.mthdObtd ='Test';
         a.name='Test';
     a.title ='Test';
     a.company ='Test';
     a.comment ='Test';
   }
}