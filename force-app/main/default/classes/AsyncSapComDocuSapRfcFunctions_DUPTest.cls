@isTest
private class AsyncSapComDocuSapRfcFunctions_DUPTest  {
    @isTest static void testCallout1() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new AsyncSapComDocuSapRfcFunctions_DUPMock1());
        AsyncSapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_elementFuture geAPPort1 = new AsyncSapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_elementFuture();
       // sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element reap = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element();
       // System.assertNotEquals(null, geAPPort.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6('','','','','','','','','','','','','','','',null,null,null) );
      geAPPort1.getValue();
     }
    private class AsyncSapComDocuSapRfcFunctions_DUPMock1 implements WebServiceMock {
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
 
                sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element r
                 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element();
         response.put('response_x', r); 
    }
}
}