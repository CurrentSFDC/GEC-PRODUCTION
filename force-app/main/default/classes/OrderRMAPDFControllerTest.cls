/*---------------------------------------------------------------------------------
Name:       OrderRMAPDFControllerTest.cls
Purpose:    Test Class for OrderRMAPDFController.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Jan-2020           Initial Development 
---------------------------------------------------------------------------------*/
@isTest
private class OrderRMAPDFControllerTest{

    private static Account account = new Account();
    private static Contact contact = new Contact();
    private static User user = new User();

    @testSetup
    private static void setupData() {
        account = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(account.Id, 'Test', 'Contact 1', 'test@example.com', true);
        user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);
    }

	@isTest static void testMethod1() {
        Test.setMock(WebServiceMock.class, new SAPGatewayPDFTest.OrderRMAPDFMock());
        
        OrderRMAPDFController.Request req = new OrderRMAPDFController.Request();       
        OrderRMAPDFController.Response res =  null;
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.StartTest();
            System.runAs(user) {
                res = OrderRMAPDFController.getPDF('12345');
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}

}