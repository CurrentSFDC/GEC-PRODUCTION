// InventoryControllerTest class
// Test class for the InventoryController class
// ------------------------------------------------------------------
//  Author                    Date         Description
// ------------------------------------------------------------------ 
//  Devang Shah	              27/11/2020   Created
//
@IsTest
public class InventoryControllerTest {
    private static Account account = new Account();
    private static Contact contact = new Contact();
    private static User user = new User();
    private static ccrz__E_Product__c product = new ccrz__E_Product__c();
    private static ccrz__E_ProductInventoryItem__c inventoryItem = new ccrz__E_ProductInventoryItem__c();   

    //EM- @testSetup is run once before the tests are run, no need to run the method every time
    @testSetup
    private static void setupData() {
        account = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(account.Id, 'Test', 'Contact 1', 'test@example.com', true);
        user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);
        //Profile p = [SELECT Id FROM Profile WHERE Name='Agent B2B Storefront Registered Users'];
        //user.ProfileID = p.Id;
        //user.IsActive = true;
        //Insert user;
        product = TestDataFactory.createCCProduct('123456', 'Test product', true);
        System.debug('product id***** '+ product.Id);
        inventoryItem = TestDataFactory.createCCProductInvetoryItem(product.Id, true);
     
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

    @IsTest
	public static void testGetInventoryAvailability() {
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='123456' LIMIT 1];
        List<Id> ids = new List<Id>();
        ids.add(product.Id);
        Test.StartTest();
        System.runAs(user) {
            List<InventoryController.DefaultWarehouseInventory> dwList = InventoryController.get2448HrAvailability('1WML', ids);
            System.assertNotEquals(null, dwList);
        }
		Test.StopTest();
    } 
    
    @IsTest
	public static void testGet2448HrAvailability2() {        
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='123456' LIMIT 1];
        Test.StartTest();
       
        System.runAs(user) {
            
            String quantity = InventoryController.get2448HrAvailability('1WML', product.Id);
            System.AssertEquals('450', quantity); 
        }
		Test.StopTest();
    } 
    
    @IsTest
	public static void testGetInventoryAvailabilityInAllLocations() {
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        ccrz__E_Product__c product = [Select Id From ccrz__E_Product__c Where ccrz__SKU__c='123456' LIMIT 1];
        Test.StartTest();
        System.runAs(user) {
            List<InventoryController.Inventory> invList = InventoryController.getInventoryAvailabilityInAllLocations(product.Id);
            System.assertNotEquals(null, invList);
        }
		Test.StopTest();
    } 
    

    @IsTest
	public static void testGet2448HrAvailability() {        
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account accc=[Select Id From Account Where Name='Test Account' LIMIT 1];
        accc.Account_Group__c='ZEAG';
            accc.Customer_Segmentation__c='FD';
        String agentID= accc.Id;
        String custID=accc.Id;
        String skusJson = '["12377"]';
        String sku ='12377';
        String productsJson = '["a7s3F000000CjvIQAS"]';
        ccrz__E_Product__c p1= new ccrz__E_Product__c();
        p1.ccrz__SKU__c='12377';
        insert p1;
        Test.StartTest();
        System.runAs(user) {
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            //ccrz.cc_RemoteActionResult res = InventoryController.getInventoryAvailability(ctx, skusJson, productsJson);
            
            InventoryController.service = new MockSAPGateway();
           InventoryController.getInventoryAvailability(ctx, skusJson, productsJson,agentID,custID);
          // InventoryController.getInventoryAvailability(sku,agentID,custID);

            // System.assertNotEquals(null, ((InventoryController.InventoryResponse) res.data));
            //System.assertNotEquals(null, ((InventoryController.InventoryResponse) res.data));
        }
		Test.StopTest();
    } 
    
     @IsTest
	public static void testGet2448HrAvailability1() {        
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Account accc=[Select Id From Account Where Name='Test Account' LIMIT 1];
        String agentID= accc.Id;
        String custID=accc.Id;
        String skusJson = '["12377"]';
        String sku ='12377';
        String productsJson = '["a7s3F000000CjvIQAS"]';
        ccrz__E_Product__c p1= new ccrz__E_Product__c();
        p1.ccrz__SKU__c='12377';
        insert p1;
        Test.StartTest();
        System.runAs(user) {
			ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            //ccrz.cc_RemoteActionResult res = InventoryController.getInventoryAvailability(ctx, skusJson, productsJson);
            
            InventoryController.service = new MockSAPGateway();
           InventoryController.getInventoryAvailabilityForComm(sku,agentID,custID);
          // InventoryController.getInventoryAvailability(sku,agentID,custID);

            // System.assertNotEquals(null, ((InventoryController.InventoryResponse) res.data));
            //System.assertNotEquals(null, ((InventoryController.InventoryResponse) res.data));
        }
		Test.StopTest();
    } 
    




    private class MockSAPGateway extends SAPGatewayMock {
		public override InventoryController.InventoryResponse getInventoryAvailability(InventoryController.InventoryRequest request) {
            List<InventoryController.Inventory> invlst = new List<InventoryController.Inventory>();
            InventoryController.Inventory inv = new InventoryController.Inventory();
			inv.adpPrice=1.0;
           // insert inv;
            invlst.add(inv);
               
            Map<String,List<InventoryController.Inventory>> inventoryMap1 = new Map<String,List<InventoryController.Inventory>>();
            inventoryMap1.put('ID', invlst);
                
            InventoryController.InventoryResponse response = new InventoryController.InventoryResponse();
            response.agent = '';
            response.customerName = 'Test';
            response.customer = '0800';
            response.message = '';
            response.orderType = 'N';
            response.poleType = '1';
            response.poNumber = '123';
            response.poType = '';
            response.reqDelDate = '20201127';
            response.spart = '10';
            response.userType = '';
            response.salesOrg = '1US1';
            response.division = '10';
            response.description='';
            response.UOM='';
            response.reqQty=1;
            response.roundedQty=1;
            response.maxPrice=1.0;
            response.adpPrice=1.0;
            response.unitPrice=1.0;
            response.inventoryMap=inventoryMap1;
            return response;
		}
	}
    public static testmethod void InventoryRequestTest(){
        
        InventoryController.InventoryRequest Request = new InventoryController.InventoryRequest();
        Request.agrDate= 'Test';
            Request.orderType='Test';
            Request.poNumber='Test';
            Request.poType='Test';
            
            
    }
}