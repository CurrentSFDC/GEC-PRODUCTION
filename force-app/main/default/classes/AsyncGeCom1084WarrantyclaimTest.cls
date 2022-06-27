@isTest
private class AsyncGeCom1084WarrantyclaimTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new AsyncGeCom1084WarrantyclaimMock1());
        AsyncGecurrentComCom1084Warrantyclaim.AsyncHTTPS_Port geAPPort = new AsyncGecurrentComCom1084Warrantyclaim.AsyncHTTPS_Port();
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER ishead;
       // sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADE ishead= new sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADE();
        //sapComDocumentSapRfcFunctionsWC.IT_ITEM_element ititem = new sapComDocumentSapRfcFunctionsWC.IT_ITEM_element();
        sapComDocumentSapRfcFunctionsWC.IT_ITEM_element ititem;
        
        System.Continuation cont = new System.Continuation(12);
        cont.state='sd';
        cont.Timeout=20;
        
        geAPPort.beginSI_SFB2B_WarrantyClaim_1084_OB_SYNC(cont, ishead, ititem);
        sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element reap = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element();
      
        
     }
    private class AsyncGeCom1084WarrantyclaimMock1 implements WebServiceMock {
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