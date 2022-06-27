/*---------------------------------------------------------------------------------
Name:       DeliveryNotesPDFControllerTest.cls
Purpose:    Test Class for DeliveryNotesPDFController.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Jan-2020           Initial Development 
---------------------------------------------------------------------------------*/
@isTest
private class DeliveryNotesPDFControllerTest{

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
        Test.setMock(WebServiceMock.class, new SAPGatewayPDFTest.DeliveryNotesPDFMock());
        
        DeliveryNotesPDFController.Request req = new DeliveryNotesPDFController.Request();       
        DeliveryNotesPDFController.Response res =  null;
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.StartTest();
            System.runAs(user) {
                res = DeliveryNotesPDFController.getPDF('12345');
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}

}