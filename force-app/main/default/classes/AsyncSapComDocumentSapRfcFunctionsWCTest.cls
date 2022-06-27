@isTest
private class AsyncSapComDocumentSapRfcFunctionsWCTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new AsyncSapComDocumentSapRfcFunctionsWCMock1());
        AsyncSapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_elementFuture geAPPort = new AsyncSapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_elementFuture();
       // sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element reap = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element();
       // System.assertNotEquals(null, geAPPort.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6('','','','','','','','','','','','','','','',null,null,null) );
      geAPPort.getValue();
     }
    private class AsyncSapComDocumentSapRfcFunctionsWCMock1 implements WebServiceMock {
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
 
                sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element r
                 = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element();
         response.put('response_x', r); 
    }
}
}