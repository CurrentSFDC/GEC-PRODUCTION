@isTest
private class gecurrentComCom1084WarrantyclaimTest  {
    @isTest static void testCallout() {             
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new gecurrentComCom1084WarrantyclaimMock1());
        gecurrentComCom1084Warrantyclaim.HTTPS_Port geAPPort = new gecurrentComCom1084Warrantyclaim.HTTPS_Port();
		 sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element obj = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element(); 
   
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER obj1 = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER ();
        sapComDocumentSapRfcFunctionsWC.IT_ITEM_element obj2 = new sapComDocumentSapRfcFunctionsWC.IT_ITEM_element();
        
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER ishead;
         sapComDocumentSapRfcFunctionsWC.IT_ITEM_element ititem;
        geAPPort.SI_SFB2B_WarrantyClaim_1084_OB_SYNC(ishead, ititem);
    }
    
    private with sharing class gecurrentComCom1084WarrantyclaimMock1 implements WebServiceMock {
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