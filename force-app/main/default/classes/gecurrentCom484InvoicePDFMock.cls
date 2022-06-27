/*----------------------------------------------------------------------
Name:       gecurrentCom484InvoicePDFMock.cls
Purpose:    Mock for testing WSDL class
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Nate Kanyok     29-Dec-2020             Mimic gecurrentCom701ProductAvailabilityMock 
----------------------------------------------------------------------*/
public class gecurrentCom484InvoicePDFMock implements WebServiceMock {
    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String requestNS,
        String responseName,
        String responseType) {

            sapComDocSapRfcFunctionsInvPdf.x_xGEL_xSFB2B_INVOICE_PDF_GENRAT_Response_element r
                 = new sapComDocSapRfcFunctionsInvPdf.x_xGEL_xSFB2B_INVOICE_PDF_GENRAT_Response_element();
            response.put('response_x', r);
        }
}