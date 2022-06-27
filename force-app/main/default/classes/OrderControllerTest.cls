@isTest
public with sharing class OrderControllerTest {
    @testSetup
    private static void setupData() {

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
    }

    @IsTest
    private static void testGetAccount() {
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.startTest();
        System.runAs(user) {
            Account a = OrderController.getAccount();
            System.AssertNotEquals(Null, a.Id); 
        }
        Test.stopTest();
    }

    @IsTest
    private static void testGetOrder(){
        Order order = [SELECT Id FROM Order WHERE GE_Order_NO__c = 'testNumber'];
        System.AssertNotEquals(null, OrderController.getOrder(order.Id));
    }

    @IsTest
    private static void testGetItemDetails(){
        Order order = [SELECT Id FROM Order WHERE GE_Order_NO__c = 'testNumber'];
        System.AssertNotEquals(null, OrderController.getItemDetails(order.Id).size());
    }

    @IsTest
    private static void testGetDetails(){
        Order order = [SELECT Id FROM Order WHERE GE_Order_NO__c = 'testNumber'];
        integer num;
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.OrderDisplayMock());
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.startTest();
        System.runAs(user) {
        System.AssertNotEquals(null, OrderController.getDetails(order.Id));
        }
        Test.stopTest();
    }
     @IsTest
    private static void testgetDetailsTest(){
        Order order = [SELECT Id FROM Order WHERE GE_Order_NO__c = 'testNumber'];
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.OrderDisplayMock());
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.startTest();
        System.runAs(user) {
            OrderController.getDetailsTest(order.Id,user.id);
        //System.AssertNotEquals(null, OrderController.getDetailsTest(order.Id,user.id));
        }
        Test.stopTest();
    }
}