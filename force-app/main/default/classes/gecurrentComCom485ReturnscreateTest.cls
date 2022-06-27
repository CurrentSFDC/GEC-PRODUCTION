@isTest
private class gecurrentComCom485ReturnscreateTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new gecurrentComCom485ReturnscreateMock1());
        gecurrentComCom485Returnscreate.HTTPS_Port geAPPort = new gecurrentComCom485Returnscreate.HTTPS_Port();
       // System.assertNotEquals(null, geAPPort.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6('','','','','','','','','','','','','','','',null,null,null) );
      sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element geAPPort1 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element();
      sapComDocumentSapRfcFunctions_DUP.IT_HEAD_COMMENTS_element headelement;
        sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element itelement;
        sapComDocumentSapRfcFunctions_DUP.IT_RETURN_ITEMS_element returnlement;
        geAPPort.SI_SFB2B_ReturnsCreate_485_OB_SYNC('Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test',headelement,itelement,returnlement);
	}
    private with sharing class gecurrentComCom485ReturnscreateMock1 implements WebServiceMock {
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