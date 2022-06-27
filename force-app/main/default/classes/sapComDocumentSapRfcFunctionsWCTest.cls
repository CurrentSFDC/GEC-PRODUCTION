@isTest
private class sapComDocumentSapRfcFunctionsWCTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctionsWCMock1());
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element geAPPort = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element();
       // System.assertNotEquals(null, geAPPort.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6('','','','','','','','','','','','','','','',null,null,null) );
      
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctionsWCMock1());
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_ITEM geAPPort1 = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_ITEM();
       
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctionsWCMock1());
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_element geAPPort2 = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_element();
       
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctionsWCMock1());
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER geAPPort3 = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER();
       
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctionsWCMock1());
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_ITEM geAPPort4 = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_ITEM();
      
         
     }

private with sharing class sapComDocumentSapRfcFunctionsWCMock1 implements WebServiceMock {
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
 
                sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_ITEM r
                 = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_ITEM();
         response.put('response_x', r); 
    }
}
}