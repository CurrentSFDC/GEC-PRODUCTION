/*---------------------------------------------------------------------------------
Name:       SAPGatewayMock.cls
Purpose:    Gateway providing Mock services.  			
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          27-Nov-2020           Initial Development 
---------------------------------------------------------------------------------*/

public virtual class SAPGatewayMock implements SAPGatewayInterface {

	public virtual InventoryController.InventoryResponse getInventoryAvailability(InventoryController.InventoryRequest request) {
		return null;
	} 
	
	public virtual PriceAgreementController.PriceAgreementResponse getRealTimePricing(PriceAgreementController.PriceAgreementRequest request){
		return null;
	}
	
	public virtual InvoicePDFController.Response getInvoicePDF(InvoicePDFController.Request request){
		return null;
	}
}