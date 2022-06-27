@isTest
private class AsyncGecur485aReturnrequestUpdTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new AsyncGecurrentComCom485aReturnrequestUpdMock1());
        AsyncGecurrentComCom485aReturnrequestUpd.AsyncHTTPS_Port geAPPort = new AsyncGecurrentComCom485aReturnrequestUpd.AsyncHTTPS_Port();
        sapComDocumentSapRfcFunctionsUpd.IT_HEAD_COMMENTS_element headcomm;
        sapComDocumentSapRfcFunctionsUpd.IT_ITEM_COMMENTS_element itemcomm;
        sapComDocumentSapRfcFunctionsUpd.IT_RETURN_ITEMS_element returnitem;
        System.Continuation cont = new System.Continuation(12);
        cont.state='sd';
        cont.Timeout=20;
        
        geAPPort.beginSI_SFB2B_ReturnsCreate_485A_OB_SYNC(cont,'Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test', headcomm, itemcomm, returnitem);
        sapComDocumentSapRfcFunctionsUpd.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element reap = new sapComDocumentSapRfcFunctionsUpd.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element();
      
        
     }
    private class AsyncGecurrentComCom485aReturnrequestUpdMock1 implements WebServiceMock {
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
 
                sapComDocumentSapRfcFunctionsUpd.x_xGEL_xSFB2B_RETURNS_CREATE_element r
                 = new sapComDocumentSapRfcFunctionsUpd.x_xGEL_xSFB2B_RETURNS_CREATE_element();
         response.put('response_x', r); 
    }
}
}