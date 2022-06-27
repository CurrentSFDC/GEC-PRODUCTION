/*---------------------------------------------------------------------------------
Name:       SAPGatewayTest.cls
Purpose:    Test Class for SAP SOAP services.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          28-Nov-2020           Initial Development 
---------------------------------------------------------------------------------*/
@isTest
public class SAPGatewayTest {
	@isTest
	private static void getInventoryAvailability() {
		Test.setMock(WebServiceMock.class, new ProductAvailabilityMock());
		
        String skusJson = '["12377"]';
        String productsJson = '["a7s3F000000CjvIQAS"]';
        Account acct = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(acct.Id, 'Test', 'Contact 1', 'test@example.com', true);
        User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);
        //Profile p = [SELECT Id FROM Profile WHERE Name='Agent B2B Storefront Registered Users'];
        //user.ProfileID = p.Id;
        //user.IsActive = true;
        //Insert user;

        String sToday = Datetime.now().format('yyyyMMdd');

        InventoryController.InventoryRequest req = new InventoryController.InventoryRequest();        
        req.customer = '0000000175';
        req.reqDelDate = sToday;
        req.poleType = '1';
        req.agreement = '';
        req.spart = '10';        
        req.salesOrg = '1US1';
        req.division = '10';
        req.distChannel = '20';
        req.agent = '';
        req.defaultWarehouseCode = '1WML';
        InventoryController.Inventory inv = new InventoryController.Inventory(); 
        inv.material = '12377';                
        inv.quantity = 1;
        inv.lineItem = 10;
        inv.UOM = 'PC'; 
        List<InventoryController.Inventory> inventoryList = new List<InventoryController.Inventory>();           
        inventoryList.add(inv);
        req.inventoryList = inventoryList;

        SAPGateway service = new SAPGateway();
        InventoryController.InventoryResponse res =  null;
        Test.StartTest();
            System.runAs(user) {
                res = service.getInventoryAvailability(req);
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}

    public class ProductAvailabilityMock implements WebServiceMock {
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

            sapComDocSapRfcFunctionsPA.ET_BOM_DETAILS_element ET_BOM_DETAILS = new sapComDocSapRfcFunctionsPA.ET_BOM_DETAILS_element();
            sapComDocSapRfcFunctionsPA.ET_MATERIALS_element ET_MATERIALS = new sapComDocSapRfcFunctionsPA.ET_MATERIALS_element();
            sapComDocSapRfcFunctionsPA.ET_QTY_ON_HAND_element ET_QTY_ON_HAND = new sapComDocSapRfcFunctionsPA.ET_QTY_ON_HAND_element();
            sapComDocSapRfcFunctionsPA.IT_MATERIALS_element IT_MATERIALS = new sapComDocSapRfcFunctionsPA.IT_MATERIALS_element();
            
            List<sapComDocSapRfcFunctionsPA.x_xGEL_xHY_AVAILABLE_PRICE_PROD> elList =  new List<sapComDocSapRfcFunctionsPA.x_xGEL_xHY_AVAILABLE_PRICE_PROD>();
            sapComDocSapRfcFunctionsPA.x_xGEL_xHY_AVAILABLE_PRICE_PROD el = new sapComDocSapRfcFunctionsPA.x_xGEL_xHY_AVAILABLE_PRICE_PROD();
				
            el.LINE_ITEM = '10';
            el.MATERIAL = '12377';
            el.QUANTITY = '450';
            el.UOM = 'PC';
            el.DESCRIPTION = 'Test';							
            el.REQ_DEL_DATE = '20201127';					
            elList.add(el);
            IT_MATERIALS.item = elList;
            
            List<sapComDocSapRfcFunctionsPA.x_xGEL_xHY_MATNR_QTY> qtyList = new List<sapComDocSapRfcFunctionsPA.x_xGEL_xHY_MATNR_QTY>();
            sapComDocSapRfcFunctionsPA.x_xGEL_xHY_MATNR_QTY  qty  = new sapComDocSapRfcFunctionsPA.x_xGEL_xHY_MATNR_QTY();
            qty.MATERIAL_ENTERED = '000000000000012377';				
            qty.PLANT = '1WML';
            qty.PLANT_NAME = 'Maria Loma';           
            qty.QUANTITY = '450';
            qtyList.add(qty);

            sapComDocSapRfcFunctionsPA.x_xGEL_xHY_MATNR_QTY  qty1  = new sapComDocSapRfcFunctionsPA.x_xGEL_xHY_MATNR_QTY();
            qty1.MATERIAL_ENTERED = '000000000000012377';				
            qty1.PLANT = '1WAL';
            qty1.PLANT_NAME = 'Atlanta MDC';           
            qty1.QUANTITY = '450';
            qtyList.add(qty);
            ET_QTY_ON_HAND.item = qtyList;

            List<sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVA_PRICE_PROD_OUT> prList = new List<sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVA_PRICE_PROD_OUT>();
            sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVA_PRICE_PROD_OUT pr = new sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVA_PRICE_PROD_OUT();

            pr.LINE_NUMBER =  '0010';
            pr.MATERIAL_ENTERED =  '000000000000012377';
            pr.DESCRIPTION =  'Test';
            pr.LEAD_TIME =  '';
            pr.QTY_ON_HAND =  '45';
            pr.QTY_ON_HAND_6WCH =  '45';
            pr.QTY_ON_HAND_6WRV =  '45';
            pr.QTY_ON_HAND_6MBU =  '45';
            pr.QTY_ON_HAND_6WWC =  '45';
            pr.QTY_ON_HAND_6WOV =  '45';
            pr.RESERVE_QTY_1 =  '45';
            pr.RESERVE_QTY_2 =  '45';
            pr.UOM = 'PC';
            pr.ADP_PRICE =  '90.50';
            pr.MAX_PRICE =   '190.50';
            pr.STANDARD_PACK_QTY =  '8';
            pr.CUST_REF_NUMBER =  '123';
            pr.PRICE_AGREMENT = '';
            pr.UNIT_PRICE =  '90.50';
            pr.CURRENCY_x =  'USD';
            pr.DEL_DATE =  '20201127';
            pr.WAREHOUSE_AVAILABILITY =  '2000';
            pr.SUBSTITUTE_MATERIAL =  '';
            pr.ROUNDED_QTY =  '10';
            pr.REQ_QTY =  '20';
            pr.REASON_REJ =  '';
            pr.REASON_REJ_TEXT =  '';
            pr.SUBSTITUTION_REASON =  '';
            pr.MESSAGE =  '';
            pr.WEEE_LAMP =  '';
            pr.WEEE_LIGHT =  '';
            pr.WEEE_LAMP_IR =  '';
            pr.LIGHT_TAX =  '';
            pr.COUNTRY_OF_ORIGIN =  'India';
            pr.PALLET_QTY =  '30';
            pr.UK_PALLET_QTY =  '30';
            pr.PLANT =  '1WML';
            pr.PRODUCT_HIERARCHY =  'PH1';
            pr.PRICE_AGREMENT_VALUE =  '0';
            prList.add(pr);
            ET_MATERIALS.item = prList;

            sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LS2_Response_element response_x
            = new sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LS2_Response_element();
            response_x.E_AGENT = '';
            response_x.E_CUST_NAME = 'Grove Ltd';
            response_x.E_CUTOMER = '0080000';
            //response_x.E_CALL_TYPE = '';
            response_x.E_ORDER_TYPE = 'N';
            response_x.E_POLE_TYPE = '1';
            response_x.E_PO_NUMBER = '13123';
            response_x.E_PO_TYPE = '10';
            response_x.E_REQ_DEL_DATE = '20201127';
            response_x.E_SPART = '10';
            response_x.E_USER_TYPE = '';
            response_x.E_VKORG = '1US1';
            response_x.E_VTWEG = '20';

            response_x.IT_MATERIALS = IT_MATERIALS;
            response_x.ET_QTY_ON_HAND = ET_QTY_ON_HAND;
            response_x.ET_MATERIALS = ET_MATERIALS;   
            response.put('response_x', response_x); 
        }
    }


	@isTest
	private static void getRealTimePricing() {
		Test.setMock(WebServiceMock.class, new PricingMock());
		
        String skusJson = '["12377"]';
        String productsJson = '["a7s3F000000CjvIQAS"]';
        Account acct = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(acct.Id, 'Test', 'Contact 1', 'test@example.com', true);
        User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);

        String sToday = Datetime.now().format('yyyyMMdd');      
        PriceAgreementController.PriceAgreementRequest req = new PriceAgreementController.PriceAgreementRequest();        
        req.agreement = '';       
        req.salesOrg = '1US1';
        req.division = '10';
        req.distChannel = '20';
        req.orderFlag = 'N';  
        req.orderReason = ''; 
        req.orderType = '';
        req.poNumber = '';
        req.userType = '';
        req.validateFlag = '';

        List<PriceAgreementController.PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementController.PriceAgreementItem>();
        PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
        pai.material = '12377';
        pai.SKU = '12377';
        pai.quantity = 1;
        pai.currencyISOCode = 'USD';     
        pai.lineNumber = 10;
        pai.UOM = 'PC'; 
        pai.reqDelDate =  sToday;    
              
        priceAgreementItemList.add(pai);


        PriceAgreementController.PriceAgreementItem pai2 = new PriceAgreementController.PriceAgreementItem();
        pai2.material = 'ABCDE';
        pai2.SKU = '';
        pai2.description = 'ABCDE';
        pai2.quantity = 1;
        pai2.currencyISOCode = 'USD';     
        pai2.lineNumber = 20;
        pai2.UOM = 'PC'; 
        pai2.reqDelDate =  sToday;    
              
        priceAgreementItemList.add(pai2);
        req.priceAgreementItemList = priceAgreementItemList;
  
        SAPGateway service = new SAPGateway();
        PriceAgreementController.PriceAgreementResponse res;
        Test.StartTest();
            System.runAs(user) {
                res = service.getRealTimePricing(req);
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}

    public class PricingMock implements WebServiceMock {
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
                    
                sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element response_x = new sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element();
                sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element ET_MATERIALS_OUT  = new sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element();
                sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element ET_SCHEDULELINE_DATA = new sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element();
                sapComDocSapRfcFunctionsAP.IT_MATERIALS_element IT_MATERIALS = new sapComDocSapRfcFunctionsAP.IT_MATERIALS_element();
 
                List<sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS> pmList = new List<sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS>();
                sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS pm = new sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS();

                
                pm.LINE_NUMBER = '000010';
                pm.PART_NUMBER = '000000000000012377';
                pm.PART_DESCRIPTION = '';
                pm.QUANTITY = '1';
                pm.SALES_UNIT = 'ST';
                pm.REQUESTED_PRICE = '0';
                pm.CURRENCY_x = 'USD';
                pm.AGREEMENT = '123';
                pm.REQ_DEL_DATE = '2020-12-23';
                pmList.add(pm);
                IT_MATERIALS.item = pmlist;                
                
                List<sapComDocSapRfcFunctionsAP.x_xGEL_xHYBRIS_SCH_LINE> psList = new List<sapComDocSapRfcFunctionsAP.x_xGEL_xHYBRIS_SCH_LINE>();
                sapComDocSapRfcFunctionsAP.x_xGEL_xHYBRIS_SCH_LINE ps = new sapComDocSapRfcFunctionsAP.x_xGEL_xHYBRIS_SCH_LINE();

                ps.ITM_NUMBER = '000010';
                ps.SCHED_LINE = '0002';
                ps.CONFIRMED_QTY = '6.000';
                ps.MAT_AVAIL_DATE = '2020-12-11';
                ps.ISSUE_DATE = '2020-12-15';
                ps.DELIVERY_DATE = '2020-12-23';
                psList.add(ps);
                ET_SCHEDULELINE_DATA.item = psList;
 
                List<sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT> paiList = new List<sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT>();
                sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT pai = new sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT();
                
                pai.LINE_NUMBER = '000010';
                pai.PART_NUMBER = '000000000000012377';
                pai.PART_DESCRIPTION = ' ';
                pai.QUANTITY = '10';
                pai.SALES_UNIT = 'PC';
                pai.REQUESTED_PRICE = '96.55';
                pai.LEAD_TIME = '1';
                pai.FLOOR_PRICE = '55.55';
                pai.FLOOR_PERC = '4';
                pai.ADP = '88.55';
                pai.ADP_PERC = '9';
                pai.SLIDING_COM = '10';
                pai.SLIDING_COM_PERC = '2';
                pai.OVERAGE_AMOUNT = '5';
                pai.OVERAGE_PERC_AMNT = '5';
                pai.OVERAGE_PERC_PERC = '2';
                pai.AVAILABLE_QTY = '100';
                pai.BOOKP_PRICE = '200';
                //pai.COMMISSION = '20';
                pai.COMMISON_PER = '5';
                pai.CURRENCY_x = 'USD';
                pai.EXTENDED_PRICE = '30';
                pai.ROUNDED_QTY = '2';
                pai.REASON_REJ = ' ';
                pai.REASON_REJ_TEXT = ' ';
                pai.SUBSTITUTION_REASON = ' ';
                pai.MESSAGE = ' ';
                pai.QTY_ON_HAND = ' ';
                pai.WAREHOUSE_AVAILABILITY = ' ';
                pai.STANDARD_PACK_QTY = '20';
                pai.SUBSTITUTE_MATERIAL = ' ';
                pai.WEEE_LAMP = ' ';
                pai.WEEE_LIGHT = ' ';
                pai.WEEE_LAMP_IR = ' ';
                pai.LIGHT_TAX = ' ';
                pai.COUNTRY_OF_ORIGIN = ' ';
                pai.PALLET_QTY = ' ';
                pai.UK_PALLET_QTY = ' ';
                pai.PLANT = '1WML';
                pai.PRODUCT_HIERARCHY = ' ';
                pai.PRICE_AGREMENT = '20';
                pai.PRICE_AGREMENT_VALUE = '20';
                pai.NET_CREDIT = '10';
                pai.ZFRE = 'testing';
                paiList.add(pai);

                sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT pai2 = new sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT();

                pai2.LINE_NUMBER = '0000020';
                pai2.PART_NUMBER = 'INVALIDCAT';
                pai2.PART_DESCRIPTION = ' ';
                pai2.QUANTITY = '10';
                pai2.SALES_UNIT = 'PC';
                pai2.REQUESTED_PRICE = '96.55';
                pai2.LEAD_TIME = '1';
                pai2.FLOOR_PRICE = '55.55';
                pai2.FLOOR_PERC = '4';
                pai2.ADP = '88.55';
                pai2.ADP_PERC = '9';
                pai2.SLIDING_COM = '10';
                pai2.SLIDING_COM_PERC = '2';
                pai2.OVERAGE_AMOUNT = '5';
                pai2.OVERAGE_PERC_AMNT = '5';
                pai2.OVERAGE_PERC_PERC = '2';
                pai2.AVAILABLE_QTY = '100';
                pai2.BOOKP_PRICE = '200';
                //pai2.COMMISSION = '20';
                pai2.COMMISON_PER = '5';
                pai2.CURRENCY_x = 'USD';
                pai2.EXTENDED_PRICE = '30';
                pai2.ROUNDED_QTY = '2';
                pai2.REASON_REJ = ' ';
                pai2.REASON_REJ_TEXT = ' ';
                pai2.SUBSTITUTION_REASON = ' ';
                pai2.MESSAGE = ' ';
                pai2.QTY_ON_HAND = ' ';
                pai2.WAREHOUSE_AVAILABILITY = ' ';
                pai2.STANDARD_PACK_QTY = '20';
                pai2.SUBSTITUTE_MATERIAL = ' ';
                pai2.WEEE_LAMP = ' ';
                pai2.WEEE_LIGHT = ' ';
                pai2.WEEE_LAMP_IR = ' ';
                pai2.LIGHT_TAX = ' ';
                pai2.COUNTRY_OF_ORIGIN = ' ';
                pai2.PALLET_QTY = ' ';
                pai2.UK_PALLET_QTY = ' ';
                pai2.PLANT = '1WML';
                pai2.PRODUCT_HIERARCHY = ' ';
                pai2.PRICE_AGREMENT = '20';
                pai2.PRICE_AGREMENT_VALUE = '20';
                pai2.NET_CREDIT = '10';
                pai2.ZFRE = 'testing';
                paiList.add(pai2);
                ET_MATERIALS_OUT.item = paiList;                      

                response_x.E_ERR_MESSAGE = '';
                response_x.E_PO_DUPLICATE = '';   
                response_x.ET_MATERIALS_OUT = ET_MATERIALS_OUT;
                response_x.ET_SCHEDULELINE_DATA = ET_SCHEDULELINE_DATA;
                response_x.IT_MATERIALS = IT_MATERIALS;   
                response.put('response_x', response_x); 
        }
    }

    @isTest
	private static void validatePA() {
		Test.setMock(WebServiceMock.class, new PricingMock());
		
        Account acct = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(acct.Id, 'Test', 'Contact 1', 'test@example.com', true);
        User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);

        String sToday = Datetime.now().format('yyyyMMdd');      
        PriceAgreementController.PriceAgreementRequest req = new PriceAgreementController.PriceAgreementRequest();        
        req.agreement = '';       
        req.salesOrg = '1US1';
        req.division = '10';
        req.distChannel = '20';
        req.orderFlag = 'N';  
        req.orderReason = ''; 
        req.orderType = 'ZOR';
        req.poNumber = '';
        req.userType = '';
        req.validateFlag = 'Y';
        req.callType = 'A';

        List<PriceAgreementController.PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementController.PriceAgreementItem>();
        PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
        pai.material = '12377';
        pai.SKU = '12377';
        pai.quantity = 1;
        pai.currencyISOCode = 'USD';     
        pai.lineNumber = 10;
        pai.UOM = 'PC'; 
        pai.reqDelDate =  sToday;
              
        priceAgreementItemList.add(pai);
        req.priceAgreementItemList = priceAgreementItemList;
  
        SAPGateway service = new SAPGateway();
        PriceAgreementController.PriceAgreementResponse res =  null;
        Test.StartTest();
            System.runAs(user) {
                res = service.priceAgreementValidate(req);
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
    }
    
    @isTest
	private static void validateRevisePA() {
		Test.setMock(WebServiceMock.class, new PricingMock());
		
        Account acct = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(acct.Id, 'Test', 'Contact 1', 'test@example.com', true);
        User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);

        String sToday = Datetime.now().format('yyyyMMdd');      
        PriceAgreementController.PriceAgreementRequest req = new PriceAgreementController.PriceAgreementRequest();        
        req.agreement = 'testing';       
        req.salesOrg = '1US1';
        req.division = '10';
        req.distChannel = '20';
        req.orderFlag = 'N';  
        req.orderReason = ''; 
        req.orderType = 'ZOR';
        req.poNumber = '';
        req.userType = '';
        req.validateFlag = 'Y';
        req.callType = 'A';

        List<PriceAgreementController.PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementController.PriceAgreementItem>();
        PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
        pai.agreement = 'testing';
        pai.material = '12377';
        pai.quantity = 1;
        pai.currencyISOCode = 'USD';    
        pai.lineNumber = 10;
        pai.UOM = 'PC'; 
        pai.reqDelDate = sToday;
              
        priceAgreementItemList.add(pai);
        req.priceAgreementItemList = priceAgreementItemList;
  
        SAPGateway service = new SAPGateway();
        PriceAgreementController.PriceAgreementResponse res =  null;
        Test.StartTest();
            System.runAs(user) {
                res = service.revisePriceAgreementValidate(req);
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}

    @isTest
	public static void getOrderDisplay() {
        Test.setMock(WebServiceMock.class, new OrderDisplayMock());
        OrderController.OrderRequest req = new OrderController.OrderRequest();
        req.orderNumber = '1234';
        req.salesOrg = '1US1';
        SAPGateway sap = new SAPGateway();

        Test.StartTest();
        OrderController.OrderDetails response = sap.orderDisplay(req);
        System.assertNotEquals(response, null);
    }

    @isTest
	public static void PACreate() {
        Test.setMock(WebServiceMock.class, new PACreateMock());
        PriceAgreementController.PriceAgreementRequest req = new PriceAgreementController.PriceAgreementRequest();
        
        


        String sToday = Datetime.now().format('yyyyMMdd');
            req.customer = 'testing';

            req.agent = 'testing';
            req.extAgent = 'testing';
            req.extRepNumber = 'testing';
            req.callType = 'A';       
            req.salesOrg = 'testing';
            req.division = 'testing';
            req.distChannel = 'testing';
            req.orderFlag = 'N';  
            req.orderReason = ''; 
            req.orderType = 'ZOR';
            req.poNumber = '';
            req.validateFlag = 'Y';
            req.userEmail = 'testing';
            req.userName = 'testing';
            req.validFrom = sToday;
            req.validTo = sToday;
            
            req.soldTo = 'testing';
            req.city = 'testing';
            req.province = 'testing';
            req.state = 'testing';
            req.zipCode = 'testing';
            req.strategicAccount = 'testing';
            req.description = 'testing';
            req.endUser = 'testing';
            req.opportunityId = 'testing';
            req.extDescription = 'testing';
            req.agreementType = 'ZPRJ';
            req.agreementType = 'ZOTP';
            req.userType = 'Agent';  

            List<PriceAgreementController.PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementController.PriceAgreementItem>();

            PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
            pai.material = 'testing';
            pai.SKU = 'testing';
            pai.description = 'testing';
            pai.quantity = 1;
            pai.currencyISOCode = 'testing';
            pai.lineNumber = 10;
            pai.UOM = 'testing';
            pai.reqDelDate =  'testing';
            pai.requestedPrice = 10.00;   
            pai.lineComments = 'testing';
            priceAgreementItemList.add(pai);    
            req.priceAgreementItemList = priceAgreementItemList;

        SAPGateway sap = new SAPGateway();
        Test.StartTest();
        PriceAgreementController.PriceAgreementCreateResponse response = sap.priceAgreementCreate(req);
        System.assertNotEquals(response, null);
        Test.StopTest();
    }

    public class PACreateMock implements WebServiceMock {

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

                sapComDocSapRfcFunctionsAPCreate.x_xGEL_xSFB2B_AGREEMENT_CREATE_Response_element response_x = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xSFB2B_AGREEMENT_CREATE_Response_element();
                response_x.E_AGREEMENT = 'testPA';
                response_x.E_APPROVED = 'testPA';
                response_x.E_MESSAGE = 'testPA';
                
                sapComDocSapRfcFunctionsAPCreate.IT_ADDITIONAL_element IT_ADDITIONAL = new sapComDocSapRfcFunctionsAPCreate.IT_ADDITIONAL_element();
                IT_ADDITIONAL.item = new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xS_IPCRASP_COMP_FIELDS>();
                sapComDocSapRfcFunctionsAPCreate.x_xGEL_xS_IPCRASP_COMP_FIELDS additionalItem = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xS_IPCRASP_COMP_FIELDS();
                additionalItem.ZMANUFACTURER = 'testing';
                additionalItem.ZDISTRIBUTOR = 'testing';
                additionalItem.ZDATAB = 'testing';
                additionalItem.ZDATBI = 'testing';
                additionalItem.ZMTHD_OBTD = 'testing';
                additionalItem.ZNAME = 'testing';
                additionalItem.ZTITLE = 'testing';
                additionalItem.ZCOMPANY = 'testing';
                additionalItem.ZCOMMENT = 'testing';
                IT_ADDITIONAL.item.add(additionalItem);
                response_x.IT_ADDITIONAL = IT_ADDITIONAL;

                sapComDocSapRfcFunctionsAPCreate.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS = new sapComDocSapRfcFunctionsAPCreate.IT_HEAD_COMMENTS_element();
                IT_HEAD_COMMENTS.item = new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS>();
                sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS headCommentsItem = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS();
                headCommentsItem.LINE_NUMBER = 'testing';
                headCommentsItem.PART_NUMBER = 'testing';
                headCommentsItem.LINE_COMMENTS = 'testing';
                IT_HEAD_COMMENTS.item.add(headCommentsItem);
                response_x.IT_HEAD_COMMENTS = IT_HEAD_COMMENTS;

                sapComDocSapRfcFunctionsAPCreate.IT_MATERIALS_element IT_MATERIALS = new sapComDocSapRfcFunctionsAPCreate.IT_MATERIALS_element();
                IT_MATERIALS.item = new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_PRICE_MATERIALS>();
                sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_PRICE_MATERIALS materialsItem = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_PRICE_MATERIALS();
                materialsItem.LINE_NUMBER = 'testing';
                materialsItem.PART_NUMBER = 'testing';
                materialsItem.PART_DESCRIPTION = 'testing';
                materialsItem.QUANTITY = '1';
                materialsItem.SALES_UNIT = 'testing';
                materialsItem.REQUESTED_PRICE = 'testing';
                materialsItem.CURRENCY_x = 'testing';
                materialsItem.AGREEMENT = 'testing';
                materialsItem.REQ_DEL_DATE = '2020-12-23';
                IT_MATERIALS.item.add(materialsItem);
                response_x.IT_MATERIALS = IT_MATERIALS;

                sapComDocSapRfcFunctionsAPCreate.IT_SOLD_TO_element IT_SOLD_TO = new sapComDocSapRfcFunctionsAPCreate.IT_SOLD_TO_element();
                IT_SOLD_TO.item = new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_EXT_AGENTS>();
                sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_EXT_AGENTS soldToItem = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_EXT_AGENTS();
                soldToItem.KUNNR = 'testing';
                IT_SOLD_TO.item.add(soldToItem);
                response_x.IT_SOLD_TO = IT_SOLD_TO;

                sapComDocSapRfcFunctionsAPCreate.IT_TEXT_element IT_TEXT = new sapComDocSapRfcFunctionsAPCreate.IT_TEXT_element();
                IT_TEXT.item = new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS>();
                sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS textItem = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS();
                textItem.LINE_NUMBER = 'testing';
                textItem.PART_NUMBER = 'testing';
                textItem.LINE_COMMENTS = 'testing';
                IT_TEXT.item.add(textItem);
                response_x.IT_TEXT = IT_TEXT;

                response.put('response_x', response_x); 
        }

    }

    public class OrderDisplayMock implements WebServiceMock {
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
                    
                sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_ORDER_DISPLAY_Response_element response_x = new sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_ORDER_DISPLAY_Response_element();
                sapComDocSapRfcFunctionsOD.ET_HEAD_COMMENTS_element ET_HEAD_COMMENTS = new sapComDocSapRfcFunctionsOD.ET_HEAD_COMMENTS_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT> ET_HEAD_COMMENTS_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT>();
                ET_HEAD_COMMENTS.item = ET_HEAD_COMMENTS_ITEMS;
                sapComDocSapRfcFunctionsOD.ET_HEAD_SHIP_INSTRU_element ET_HEAD_SHIP_INSTRU = new sapComDocSapRfcFunctionsOD.ET_HEAD_SHIP_INSTRU_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT> ET_HEAD_SHIP_INSTRU_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT>();
                ET_HEAD_SHIP_INSTRU.item = ET_HEAD_SHIP_INSTRU_ITEMS;
                sapComDocSapRfcFunctionsOD.ET_ITEM_COMMENTS_element ET_ITEM_COMMENTS = new sapComDocSapRfcFunctionsOD.ET_ITEM_COMMENTS_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT> ET_ITEM_COMMENTS_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT>();
                ET_ITEM_COMMENTS.item = ET_ITEM_COMMENTS_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT headComment = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT();
                headComment.ITEM = '000010';
                headComment.TEXT = 'testing';
                ET_HEAD_COMMENTS.item.add(headComment);
                ET_HEAD_SHIP_INSTRU.item.add(headComment);
                ET_ITEM_COMMENTS.item.add(headComment);

                sapComDocSapRfcFunctionsOD.ET_SALES_DEL_INV_DATA_element ET_SALES_DEL_INV_DATA = new sapComDocSapRfcFunctionsOD.ET_SALES_DEL_INV_DATA_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_DEL_INV_DATA> ET_SALES_DEL_INV_DATA_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_DEL_INV_DATA>();
                ET_SALES_DEL_INV_DATA.item = ET_SALES_DEL_INV_DATA_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_DEL_INV_DATA salesDelInvItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_DEL_INV_DATA();
                salesDelInvItem.ORDER_NUMBER = 'testing';
                salesDelInvItem.ITEM_NUMBER = 'testing';
                salesDelInvItem.DEL_NUMBER = 'testing';
                salesDelInvItem.DEL_ITEM_NUMBER = 'testing';
                salesDelInvItem.PRODUCT_NUMBER = '1';
                salesDelInvItem.PRODUCT_DESCRIPTION = 'testing';
                salesDelInvItem.INVOICE_NUMBER = 'testing';
                salesDelInvItem.INVOICE_ITEM = 'testing';
                salesDelInvItem.INVOICE_DATE = 'testing';
                ET_SALES_DEL_INV_DATA.item.add(salesDelInvItem);
                
                sapComDocSapRfcFunctionsOD.ET_SALES_HEADER_DATA_element ET_SALES_HEADER_DATA = new sapComDocSapRfcFunctionsOD.ET_SALES_HEADER_DATA_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SALES_HEADER_DATA> ET_SALES_HEADER_DATA_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SALES_HEADER_DATA>();
                ET_SALES_HEADER_DATA.item = ET_SALES_HEADER_DATA_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SALES_HEADER_DATA salesHeaderItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SALES_HEADER_DATA();
                salesHeaderItem.ORDER_NUMBER = 'testing';
                salesHeaderItem.PO_NUMBER = 'testing';
                salesHeaderItem.SOLD_TO_NUMBER = 'testing';
                salesHeaderItem.SOLD_TO_NAME = 'testing';
                salesHeaderItem.ORDER_DATE = 'testing';
                salesHeaderItem.REQ_DEL_DATE = '2020-12-23';
                salesHeaderItem.TOTAL_NET_VALUE = 'testing';
                salesHeaderItem.ORDER_STATUS = 'testing';
                salesHeaderItem.OPPORTUNITY_ID = 'testing';
                salesHeaderItem.EXT_REP_CODE = 'testing';
                salesHeaderItem.INT_REP_CODE = 'testing';
                salesHeaderItem.SHIP_TO_NAME = 'testing';
                salesHeaderItem.SHIP_TO_STREET1 = 'testing';
                salesHeaderItem.SHIP_TO_STREET2 = 'testing';
                salesHeaderItem.SHIP_TO_CITY = 'testing';
                salesHeaderItem.SHIP_TO_STATE = 'testing';
                salesHeaderItem.SHIP_TO_ZIP = 'testing';
                salesHeaderItem.SHIP_TO_COUNTRY = 'testing';
                salesHeaderItem.BILL_TO_NAME = 'testing';
                salesHeaderItem.BILL_TO_STREET1 = 'testing';
                salesHeaderItem.BILL_TO_STREET2 = 'testing';
                salesHeaderItem.BILL_TO_CITY = 'testing';
                salesHeaderItem.BILL_TO_STATE = 'testing';
                salesHeaderItem.BILL_TO_ZIP = 'testing';
                salesHeaderItem.BILL_TO_COUNTRY = 'testing';
                salesHeaderItem.CURRENCY_x = 'testing';
                salesHeaderItem.SPECIAL_COMMENTS = 'testing';
                salesHeaderItem.TOTAL_COMMISSION = 'testing';
                salesHeaderItem.ORDER_SOURCE = 'testing';
                salesHeaderItem.TOTAL_WEEE = 'testing';
                salesHeaderItem.TOTAL_LIGHT_TAX = 'testing';
                salesHeaderItem.HEAD_DEL_BLOCK = 'testing';
                salesHeaderItem.BLOCK_DESCRIPTION = 'testing';
                salesHeaderItem.CREDIT_STATUS = 'testing';
                salesHeaderItem.SHIP_VIA = 'testing';
                salesHeaderItem.SAMPLE_ORDER_FLAG = 'testing';
                salesHeaderItem.COMP_PART_SHIP = 'testing';
                salesHeaderItem.CARRIER_ACCOUNT_NO = 'testing';
                salesHeaderItem.PROJECT_NAME = 'testing';
                salesHeaderItem.USER_NAME = 'testing';
                salesHeaderItem.USER_EMAIL = 'testing';
                salesHeaderItem.ADD_RECIPIENT_NAME = 'testing';
                salesHeaderItem.ADD_RECIPIENT_EMAIL = 'testing';
                salesHeaderItem.SHIP_LABEL_COMMENTS = 'testing';
                salesHeaderItem.ALLOW_BACK_ORDER = 'testing';
                salesHeaderItem.SHIPMENT_TYPE = 'testing';
                salesHeaderItem.PART_SHIP_ALLOWED = 'testing';
                salesHeaderItem.SHIP_CONTACT_NAME = 'testing';
                salesHeaderItem.SHIP_CONTACT_NUMBER = 'testing';
                salesHeaderItem.SALES_ORG = 'testing';
                salesHeaderItem.DIST_CHANNEL = 'testing';
                salesHeaderItem.DIVISION = 'testing';
                salesHeaderItem.INCOMPLETE = 'testing';
                salesHeaderItem.ORDER_TYPE = 'testing';
                ET_SALES_HEADER_DATA.item.add(salesHeaderItem);
                
                sapComDocSapRfcFunctionsOD.ET_SALES_ITEM_DATA_element ET_SALES_ITEM_DATA = new sapComDocSapRfcFunctionsOD.ET_SALES_ITEM_DATA_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ITEM_DATA> ET_SALES_ITEM_DATA_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ITEM_DATA>();
                ET_SALES_ITEM_DATA.item = ET_SALES_ITEM_DATA_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ITEM_DATA salesItemDataItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ITEM_DATA();
                salesItemDataItem.ORDER_NUMBER = 'testing';
                salesItemDataItem.ITEM_NUMBER = 'testing';
                salesItemDataItem.PRODUCT_NUMBER = '1';
                salesItemDataItem.PRODUCT_DESCRIPTION = 'testing';
                salesItemDataItem.CUST_REF_NUMBER = 'testing';
                salesItemDataItem.QUANTITY = '1';
                salesItemDataItem.SCH_DEL_DATE = '2020-12-23';
                salesItemDataItem.REQ_DEL_DATE = '2020-12-23';
                salesItemDataItem.UNIT_PRICE = '1';
                salesItemDataItem.ITEM_STATUS = 'testing';
                salesItemDataItem.ITEM_NET_VALUE = '1';
                salesItemDataItem.CURRENCY_x = 'testing';
                salesItemDataItem.SALES_UNIT = 'testing';
                salesItemDataItem.ITEM_COMM_PER = 'testing';
                salesItemDataItem.ITEM_COMM_VALUE = 'testing';
                salesItemDataItem.DIRECT_SUB_REASON = 'testing';
                salesItemDataItem.REASONFOR_REJECTION = 'testing';
                salesItemDataItem.PRICE_AGR_NUMBER = 'testing';
                salesItemDataItem.LIST_PRICE = 'testing';
                salesItemDataItem.SPECIAL_INSTRUCTIONS = 'testing';
                salesItemDataItem.PRICE_LIST = 'testing';
                salesItemDataItem.LEAD_TIME = 'testing';
                salesItemDataItem.REQUESTED_PRICE = 'testing';
                salesItemDataItem.CUSTOMER_DESCRIPTION = 'testing';
                salesItemDataItem.WEEE = 'testing';
                salesItemDataItem.LIGHT_TAX = 'testing';
                salesItemDataItem.ITEM_DEL_BLOCK = 'testing';
                salesItemDataItem.BLOCK_DESCRIPTION = 'testing';
                salesItemDataItem.QTY_SHIPPED = '1';
                salesItemDataItem.ADP_PRICE = 'testing';
                salesItemDataItem.PRICE_VALUE = 'testing';
                salesItemDataItem.PRICE_UNIT = 'testing';
                salesItemDataItem.INCOMPLETE = 'testing';
                ET_SALES_ITEM_DATA.item.add(salesItemDataItem);

                sapComDocSapRfcFunctionsOD.ET_SCHEDULE_DATA_element ET_SCHEDULE_DATA = new sapComDocSapRfcFunctionsOD.ET_SCHEDULE_DATA_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SCHEDULE_LINE_DATA> ET_SCHEDULE_DATA_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SCHEDULE_LINE_DATA>();
                ET_SCHEDULE_DATA.item = ET_SCHEDULE_DATA_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SCHEDULE_LINE_DATA scheduleDataItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SCHEDULE_LINE_DATA();
                scheduleDataItem.ORDER_NUMBER = 'testing';
                scheduleDataItem.ITEM_NUMBER = 'testing';
                scheduleDataItem.DEL_NUMBER = 'testing';
                scheduleDataItem.DEL_ITEM_NUMBER = 'testing';
                scheduleDataItem.QUANTITY = '1';
                scheduleDataItem.SALES_UNIT = 'testing';
                scheduleDataItem.CARRIER_NAME = 'testing';
                scheduleDataItem.SHIPPED_FROM = 'testing';
                scheduleDataItem.INVOICE_NUMBER = 'testing';
                scheduleDataItem.INVOICE_ITEM = 'testing';
                scheduleDataItem.INVOICE_DATE = '2020-12-23';
                scheduleDataItem.CONFIRMED = 'testing';
                scheduleDataItem.EST_SHIP_DATE = '2020-12-23';
                scheduleDataItem.EST_DEL_DATE = '2020-12-23';
                scheduleDataItem.ACT_SHIP_DATE = '2020-12-23';
                scheduleDataItem.ACT_DEL_DATE = '2020-12-23';
                scheduleDataItem.TRACKING_NUMBER = 'testing';
                scheduleDataItem.SHIPMENT_NUMBER = 'testing';
                ET_SCHEDULE_DATA.item.add(scheduleDataItem);

                sapComDocSapRfcFunctionsOD.ET_SHIPMENT_HEADER_element ET_SHIPMENT_HEADER = new sapComDocSapRfcFunctionsOD.ET_SHIPMENT_HEADER_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xSDOM_SHIPMENT_HEAD> ET_SHIPMENT_HEADER_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xSDOM_SHIPMENT_HEAD>();
                ET_SHIPMENT_HEADER.item = ET_SHIPMENT_HEADER_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xSDOM_SHIPMENT_HEAD shipmentHeadItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xSDOM_SHIPMENT_HEAD();
                shipmentHeadItem.WADAT = 'testing';
                shipmentHeadItem.TDLNR = 'testing';
                shipmentHeadItem.VTEXT = 'testing';
                shipmentHeadItem.TNDR_TRKID = 'testing';
                shipmentHeadItem.CARRIER_NAME = 'testing';
                shipmentHeadItem.TKNUM = 'testing';
                ET_SHIPMENT_HEADER.item.add(shipmentHeadItem);

                sapComDocSapRfcFunctionsOD.ET_SHIPMENT_LINES_element ET_SHIPMENT_LINES = new sapComDocSapRfcFunctionsOD.ET_SHIPMENT_LINES_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SDOM_SHIPMENT_LINES> ET_SHIPMENT_LINES_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SDOM_SHIPMENT_LINES>();
                ET_SHIPMENT_LINES.item = ET_SHIPMENT_LINES_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SDOM_SHIPMENT_LINES shipmentLinesItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SDOM_SHIPMENT_LINES();
                shipmentLinesItem.VBELN = 'testing';
                shipmentLinesItem.POSNR = 'testing';
                shipmentLinesItem.MATNR = 'testing';
                shipmentLinesItem.ARKTX = 'testing';
                shipmentLinesItem.LFIMG = 'testing';
                shipmentLinesItem.TKNUM = 'testing';
                shipmentLinesItem.TPNUM = 'testing';
                shipmentLinesItem.VOLUM = 'testing';
                shipmentLinesItem.BRGEW = 'testing';
                ET_SHIPMENT_LINES.item.add(shipmentLinesItem);

                sapComDocSapRfcFunctionsOD.IT_DIST_CHENNEL_element IT_DIST_CHENNEL = new sapComDocSapRfcFunctionsOD.IT_DIST_CHENNEL_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_DIST_CHENNEL> IT_DIST_CHENNEL_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_DIST_CHENNEL>();
                IT_DIST_CHENNEL.item = IT_DIST_CHENNEL_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_DIST_CHENNEL distChennelItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_DIST_CHENNEL();
                distChennelItem.VTWEG = 'testing';
                IT_DIST_CHENNEL.item.add(distChennelItem);

                sapComDocSapRfcFunctionsOD.IT_DIVISION_element IT_DIVISION = new sapComDocSapRfcFunctionsOD.IT_DIVISION_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_DIVISION> IT_DIVISION_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_DIVISION>();
                IT_DIVISION.item = IT_DIVISION_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_DIVISION divisionItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_DIVISION();
                divisionItem.SPART = 'testing';
                IT_DIVISION.item.add(divisionItem);

                sapComDocSapRfcFunctionsOD.IT_EXT_REP_CODE_element IT_EXT_REP_CODE = new sapComDocSapRfcFunctionsOD.IT_EXT_REP_CODE_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_EXT_AGENTS> IT_EXT_REP_CODE_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_EXT_AGENTS>();
                IT_EXT_REP_CODE.item = IT_EXT_REP_CODE_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_EXT_AGENTS extAgentsItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_EXT_AGENTS();
                extAgentsItem.KUNNR = 'testing';
                IT_EXT_REP_CODE.item.add(extAgentsItem);

                sapComDocSapRfcFunctionsOD.IT_INT_REP_CODE_element IT_INT_REP_CODE = new sapComDocSapRfcFunctionsOD.IT_INT_REP_CODE_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_INT_REPS> IT_INT_REP_CODE_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_INT_REPS>();
                IT_INT_REP_CODE.item = IT_INT_REP_CODE_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_INT_REPS intRepsItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_INT_REPS();
                intRepsItem.PERNR = 'testing';
                IT_INT_REP_CODE.item.add(intRepsItem);

                sapComDocSapRfcFunctionsOD.IT_SALES_ORDER_element IT_SALES_ORDER = new sapComDocSapRfcFunctionsOD.IT_SALES_ORDER_element();
                List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORDERS> IT_SALES_ORDER_ITEMS = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORDERS>();
                IT_SALES_ORDER.item = IT_SALES_ORDER_ITEMS;
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORDERS salesOrderItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORDERS();
                salesOrderItem.VBELN = 'testing';
                IT_SALES_ORDER.item.add(salesOrderItem);

                sapComDocSapRfcFunctionsOD.IT_SALES_ORG_element IT_SALES_ORG = new sapComDocSapRfcFunctionsOD.IT_SALES_ORG_element();
                sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORG orgItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORG();
                orgItem.VKORG = '1US1';
                IT_SALES_ORG.item = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORG>();
                IT_SALES_ORG.item.add(orgItem); 

                sapComDocSapRfcFunctionsOD.IT_SOLD_TO_element IT_SOLD_TO = new sapComDocSapRfcFunctionsOD.IT_SOLD_TO_element();
                IT_SOLD_TO.item = IT_EXT_REP_CODE.item;

                response_x.E_MESSAGE = '';
                response_x.ET_HEAD_COMMENTS = ET_HEAD_COMMENTS;
                response_x.ET_HEAD_SHIP_INSTRU = ET_HEAD_SHIP_INSTRU;
                response_x.ET_ITEM_COMMENTS = ET_ITEM_COMMENTS;
                response_x.ET_SALES_DEL_INV_DATA = ET_SALES_DEL_INV_DATA;
                response_x.ET_SALES_HEADER_DATA = ET_SALES_HEADER_DATA;
                response_x.ET_SALES_ITEM_DATA = ET_SALES_ITEM_DATA;
                response_x.ET_SCHEDULE_DATA = ET_SCHEDULE_DATA;
                response_x.ET_SHIPMENT_HEADER = ET_SHIPMENT_HEADER;
                response_x.ET_SHIPMENT_LINES = ET_SHIPMENT_LINES;
                response_x.IT_DIST_CHENNEL = IT_DIST_CHENNEL;
                response_x.IT_DIVISION = IT_DIVISION;
                response_x.IT_EXT_REP_CODE = IT_EXT_REP_CODE;
                response_x.IT_INT_REP_CODE = IT_INT_REP_CODE;
                response_x.IT_SALES_ORDER = IT_SALES_ORDER;
                response_x.IT_SALES_ORG = IT_SALES_ORG;
                response_x.IT_SOLD_TO = IT_SOLD_TO;
                response.put('response_x', response_x); 
        }
    }

    @isTest
	public static void PARevise() {
        Test.setMock(WebServiceMock.class, new PAReviseMock());
        PriceAgreementController.PriceAgreementRequest req = new PriceAgreementController.PriceAgreementRequest();
        
        String sToday = Datetime.now().format('yyyyMMdd');
            req.customer = 'testing';
            req.agreementAction = 'R';
            req.agent = 'testing';
            req.extAgent = 'testing';
            req.extRepNumber = 'testing';
            req.callType = 'A';       
            req.salesOrg = 'testing';
            req.division = 'testing';
            req.distChannel = 'testing';
            req.orderFlag = 'N';  
            req.orderReason = ''; 
            req.orderType = 'ZOR';
            req.poNumber = '';
            req.validateFlag = 'Y';
            req.userEmail = 'testing';
            req.userName = 'testing';
            req.validFrom = sToday;
            req.validTo = sToday;
            
            req.soldTo = 'testing';
            req.city = 'testing';
            req.province = 'testing';
            req.state = 'testing';
            req.zipCode = 'testing';
            req.strategicAccount = 'testing';
            req.description = 'testing';
            req.endUser = 'testing';
            req.opportunityId = 'testing';
            req.extDescription = 'testing';
            req.agreementType = 'ZPRJ';
            req.agreementType = 'ZOTP';
            req.userType = 'Agent';  

            List<PriceAgreementController.PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementController.PriceAgreementItem>();

            PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
            pai.material = 'testing';
            pai.SKU = 'testing';
            pai.description = 'testing';
            pai.quantity = 1;
            pai.currencyISOCode = 'testing';
            pai.lineNumber = 10;
            pai.UOM = 'testing';
            pai.reqDelDate =  'testing';
            pai.requestedPrice = 10.00;   
            pai.lineComments = 'testing';
            priceAgreementItemList.add(pai);    
            req.priceAgreementItemList = priceAgreementItemList;

        SAPGateway sap = new SAPGateway();
        Test.StartTest();
        PriceAgreementController.PriceAgreementCreateResponse response = sap.priceAgreementRevise(req);
        System.assertNotEquals(response, null);
        Test.StopTest();
    }

    public class PAReviseMock implements WebServiceMock {

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

                sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xSFB2B_AGREEMENT_REVISION_Response_element response_x = new sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xSFB2B_AGREEMENT_REVISION_Response_element();
                response_x.E_AGREEMENT = 'testPA';
                response_x.E_APPROVED = 'testPA';
                response_x.E_MESSAGE = 'testPA';

                sapComDocumentSapRfcFunctionsPARevise.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS = new sapComDocumentSapRfcFunctionsPARevise.IT_HEAD_COMMENTS_element();
                IT_HEAD_COMMENTS.item = new List<sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS>();
                sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS headCommentsItem = new sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS();
                headCommentsItem.LINE_NUMBER = 'testing';
                headCommentsItem.PART_NUMBER = 'testing';
                headCommentsItem.LINE_COMMENTS = 'testing';
                IT_HEAD_COMMENTS.item.add(headCommentsItem);
                response_x.IT_HEAD_COMMENTS = IT_HEAD_COMMENTS;

                sapComDocumentSapRfcFunctionsPARevise.IT_LINE_COMMENTS_element IT_LINE_COMMENTS = new sapComDocumentSapRfcFunctionsPARevise.IT_LINE_COMMENTS_element();
                IT_LINE_COMMENTS.item = new List<sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS>();
                sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS lineCommentsItem = new sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS();
                lineCommentsItem.LINE_NUMBER = 'testing';
                lineCommentsItem.PART_NUMBER = 'testing';
                lineCommentsItem.LINE_COMMENTS = 'testing';
                IT_LINE_COMMENTS.item.add(lineCommentsItem);
                response_x.IT_LINE_COMMENTS = IT_LINE_COMMENTS;

                sapComDocumentSapRfcFunctionsPARevise.IT_MATERIALS_element IT_MATERIALS = new sapComDocumentSapRfcFunctionsPARevise.IT_MATERIALS_element();
                IT_MATERIALS.item = new List<sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_PRICE_MATERIALS>();
                sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_PRICE_MATERIALS materialsItem = new sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_PRICE_MATERIALS();
                materialsItem.LINE_NUMBER = 'testing';
                materialsItem.PART_NUMBER = 'testing';
                materialsItem.PART_DESCRIPTION = 'testing';
                materialsItem.QUANTITY = '1';
                materialsItem.SALES_UNIT = 'testing';
                materialsItem.REQUESTED_PRICE = 'testing';
                materialsItem.CURRENCY_x = 'testing';
                materialsItem.AGREEMENT = 'testing';
                materialsItem.REQ_DEL_DATE = '2020-12-23';
                IT_MATERIALS.item.add(materialsItem);
                response_x.IT_MATERIALS = IT_MATERIALS;

                response.put('response_x', response_x); 
        }

    }


    @isTest
    private static void testGetReportSubscriptionsSAP(){
        Test.setMock(WebServiceMock.class, new ReportSubscriptionMock());

        Account acct = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(acct.Id, 'Test', 'Contact 1', 'test@example.com', true);
        User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);


        ReportSubscriptionController.Request req = new ReportSubscriptionController.Request();
            req.cutOrdRep = '';
            req.dailyCommReport = '';
            req.dueDtCGEReport = '';
            req.invByBill = '';
            req.modType = '';
            req.monthlyCommReport = '';
            req.openOrdRep = '';
            req.orderLineReport = '';
            req.orderShipReport = '';
            req.priceMismatch = '';
            req.ssoAcct = '';
            req.ssoEmail = '';
            req.ssoGESSOUID = '';

        SAPGateway sap = new SAPGateway();
        Test.StartTest();
        ReportSubscriptionController.Response response = sap.getReportSubscriptionsSAP(req);
        System.assertNotEquals(response, null);
        Test.StopTest();
    }

    public class ReportSubscriptionMock implements WebServiceMock {
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

            sapComSapRfcFunctionsRprtSub.x_xGEL_xSFB2B_REPORT_SUBSCRIPT3_Response_element response_x = new sapComSapRfcFunctionsRprtSub.x_xGEL_xSFB2B_REPORT_SUBSCRIPT3_Response_element();
            response_x.E_MESSAGE = 'testReportSub';
            response_x.E_XXSSO_GESSOUID = 'testReportSub';

            response.put('response_x', response_x); 
        }
    }

     @isTest
     private static void getInvoicePDF() {
        Test.setMock(WebServiceMock.class, new InvoicePDFMock());
         String skusJson = '["12377"]';
         String productsJson = '["a7s3F000000CjvIQAS"]';
        Account acct = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(acct.Id, 'Test', 'Contact 1', 'test@example.com', true);
         User user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);

         Date dateToday = Date.today();
        String sToday = String.valueof(dateToday.year()) + String.valueof(dateToday.month()) + String.valueof(dateToday.day()); 

         InvoicePDFController.Request req = new InvoicePDFController.Request();
         req.invNumber = '123';
        
        SAPGateway service = new SAPGateway();
        InvoicePDFController.Response response = null;
        
        Test.startTest();
        System.runAs(user) {
            response = service.getInvoicePDF(req);
        }
        Test.stopTest();

        System.assertNotEquals(response, null);
     }

     public class InvoicePDFMock implements WebServiceMock {
         public void doInvoke(
             Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseName,
            String responseNS,
             String responseType) {

			 sapComDocSapRfcFunctionsInvPdf.x_xGEL_xSFB2B_INVOICE_PDF_GENRAT_Response_element response_x = new sapComDocSapRfcFunctionsInvPdf.x_xGEL_xSFB2B_INVOICE_PDF_GENRAT_Response_element();
                response_x.E_HEXDATA = 'test';
                response_x.E_MESSAGE = 'test';
                response.put('response_x', response_x); 
 
            }
     }

    @IsTest
    static void testclaimtosap(){

        ID recEDurypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account a = New Account();
        a.Name = 'msat';
        a.type= 'End User';
        a.GE_LGT_Vertical__c = 'Educ';
        a.Site = 'Mayfield';
        a.GE_LGT_EM_SAP_Customer_Number__c='999999';
        a.GE_LGT_EM_Sales_Org__c='1US1';
        a.GE_LGT_EM_Division__c='10';
        a.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        a.GE_LGT_Rep_Code__c='0003rgd';
        a.GE_LGT_District_Manager__c='101013280';
        a.GE_LGT_FAM_AM__c='101013280';
        a.GE_LGT_Regional_Manager__c='101013280';
        insert a;

        GE_LGT_EM_MaterialMaster__c	 mm = new GE_LGT_EM_MaterialMaster__c();
        mm.GE_LGT_EM_SAP_MaterialNumber__c='93130970t';
        mm.GE_LGT_EM_MaterialDescription__c='test1';
        mm.GE_LGT_EM_ProductHierarchy__c='test1';
        insert mm;

        //ID recEDurypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account a1 = New Account();
        a1.Name = 'msat';
        a1.type= 'End User';
        a1.GE_LGT_Vertical__c = 'Educ';
        a1.Site = 'Mayfield';
        a1.GE_LGT_EM_SAP_Customer_Number__c='999999';
        a1.GE_LGT_EM_Sales_Org__c='1US1';
        a1.GE_LGT_EM_Division__c='10';
        a1.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        a1.GE_LGT_Rep_Code__c='0003rgd';
        a1.GE_LGT_District_Manager__c='101013280';
        a1.GE_LGT_FAM_AM__c='101013280';
        a1.GE_LGT_Regional_Manager__c='101013280';
        insert a1;


        List<Map<Object,Object>> lim = new List<Map<Object,Object>>();

        List<Map<String,Object>> lim1 = new List<Map<String,Object>>();

        Map<String,Object> lim1p = new Map<String,Object>();
        lim1p.put('creditPerUnit',11);
        lim1p.put('gecPrice',(Object)1);
        lim1p.put('priceAgreementPrice',(Object)1);
        lim1p.put('materialMaster',mm);

        Map<String, Object> um1 = new Map<String,Object>();

        //itt ha beteszed megvan a coverage csak dob egy conversion hibat.. whyy???
        //lim1.add(lim1p);

        Map<Object,Object> result1 = new Map<Object,Object>();
        result1.put('jobName','qwerty');
        result1.put('products',lim1);
        result1.put('endCustomerAccountNumInfo',um1);
        lim.add(result1);


        Map<String,Object> result = new Map<String,Object>();
        result.put('accountID',a.Id);
        result.put('accountId',a.Id);
        result.put('soldToAccountId',a1.Id);
        result.put('invoices',lim);
        system.debug('result '+result);




        Test.setMock(WebServiceMock.class, new getCaseRgaPdfMock());
        Test.startTest();
        ClaimBackController.sendClaimToSAP(result);
        Test.stopTest();
    }

    public class getCaseRgaPdfMock implements WebServiceMock {
        public void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType
        ) {

            ClaimBackController.ClaimBackCreateResponse response_x = new ClaimBackController.ClaimBackCreateResponse();
            response_x.returnValue = 'OK';
        }
    }
}