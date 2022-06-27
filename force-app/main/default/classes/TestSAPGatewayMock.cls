/*---------------------------------------------------------------------------------
Name:       TestSAPGatewayMock.cls
Purpose:    Test providing Mock services.  			
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          27-Nov-2020           Initial Development 
---------------------------------------------------------------------------------*/

@isTest
private class TestSAPGatewayMock{

	@testSetup static void setup(){
		
	}

	@isTest static void testMethod1() {
		Test.startTest();
		SAPGatewayMock sp = new SAPGatewayMock();
		InventoryController.InventoryRequest inreq = new InventoryController.InventoryRequest();
        System.assertEquals(null, sp.getInventoryAvailability(inreq)); 
        Test.stopTest();
	}

	@isTest static void testMethod2() {
		
		Test.startTest();
		SAPGatewayMock sp = new SAPGatewayMock();
		PriceAgreementController.PriceAgreementRequest preq = new PriceAgreementController.PriceAgreementRequest();
        System.assertEquals(null, sp.getRealTimePricing(preq)); 
        Test.stopTest();
	}

	
	@isTest static void testMethod3() {
		
		Test.startTest();
		SAPGatewayMock sp = new SAPGatewayMock();
		InvoicePDFController.Request ireq = new InvoicePDFController.Request();
        System.assertEquals(null, sp.getInvoicePDF(ireq)); 
        Test.stopTest();
	}
}