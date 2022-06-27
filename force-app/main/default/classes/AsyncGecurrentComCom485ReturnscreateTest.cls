@isTest
private class AsyncGecurrentComCom485ReturnscreateTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new AsyncGecurrentComCom485ReturnscreateMock1());
        AsyncGecurrentComCom485Returnscreate.AsyncHTTPS_Port geAPPort = new AsyncGecurrentComCom485Returnscreate.AsyncHTTPS_Port();
       // System.assertNotEquals(null, geAPPort.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6('','','','','','','','','','','','','','','',null,null,null) );
	   
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_element geAPPort1 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_element();
		System.Continuation cont = new System.Continuation(12);
        cont.state='sd';
        cont.Timeout=20;
        sapComDocumentSapRfcFunctions_DUP.IT_HEAD_COMMENTS_element headelement;
        sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element itelement;
        sapComDocumentSapRfcFunctions_DUP.IT_RETURN_ITEMS_element returnlement;
        geAPPort.beginSI_SFB2B_ReturnsCreate_485_OB_SYNC(cont,'Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test',headelement,itelement,returnlement);
	}
    
    private with sharing class AsyncGecurrentComCom485ReturnscreateMock1 implements WebServiceMock {
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