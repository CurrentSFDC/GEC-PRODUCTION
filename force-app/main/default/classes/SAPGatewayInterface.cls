/*---------------------------------------------------------------------------------
Name:       SAPGatewayInterface.cls
Purpose:    Gateway interface into SAP SOAP services.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description
-------     -------         --------------          -----------------------------
1.0         Devang          27-Nov-2020             Initial Development
---------------------------------------------------------------------------------*/

public interface SAPGatewayInterface {
    InventoryController.InventoryResponse getInventoryAvailability(InventoryController.InventoryRequest request);
    PriceAgreementController.PriceAgreementResponse getRealTimePricing(PriceAgreementController.PriceAgreementRequest request);
    //InvoicePDFController.Response getInvoicePDF(InvoicePDFController.Request request);
}