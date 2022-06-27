/*----------------------------------------------------------------------
Name:       gecurrentCom484InvoicePDFTes.cls
Purpose:    Test class for WSDL generated apex class
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Nate Kanyok     31-Dec-2020             Mimic gecurrentCom701ProductAvailabilityTest
----------------------------------------------------------------------*/
@isTest
private class gecurrentCom484InvoicePDFTest {
    @isTest
    static void testCallout(){
        Test.setMock(WebServiceMock.class, new gecurrentCom484InvoicePDFMock());
        gecurrentCom484Invoicepdfgenrat.HTTPS_Port geInvoicePort = new gecurrentCom484Invoicepdfgenrat.HTTPS_Port();
        System.assertNotEquals(null, geInvoicePort.SI_SFB2B_InvoicePDFGenrat_484_OB_SYNC(''));
    }

}