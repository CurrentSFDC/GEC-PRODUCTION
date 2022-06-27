@isTest
private class sapComDocumentSapRfcFunctions_DUPTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctions_DUPMock1());
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM geAPPort = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM();
       //  System.assertNotEquals(null, geAPPort.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6('','','','','','','','','','','','','','','',null,null,null) );
      
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctions_DUPMock1());
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_ORDER_TEXT geAPPort1 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_ORDER_TEXT();
       
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctions_DUPMock1());
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_ORDER_TEXT geAPPort2 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_ORDER_TEXT();
       
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctions_DUPMock1());
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element geAPPort3 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element();
       
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctions_DUPMock1());
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_element geAPPort4 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_element();
      
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctions_DUPMock1());
        sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element geAPPort5 = new sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element();
      
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctions_DUPMock1());
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM geAPPort6 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM();
      
         
     }
    
    
    private class sapComDocumentSapRfcFunctions_DUPMock1 implements WebServiceMock {
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
 
                sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM r
                 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM();
         response.put('response_x', r); 
    }
}

    
    
    
    
    
    
}