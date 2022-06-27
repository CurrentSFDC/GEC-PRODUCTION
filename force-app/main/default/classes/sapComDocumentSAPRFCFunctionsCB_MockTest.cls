@isTest
private class sapComDocumentSAPRFCFunctionsCB_MockTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new sapComDocumentSapRfcFunctionsCB_MOCK());
        sapComDocumentSapRfcFunctionsCB.x_xGEL_xHYBRIS_ITEM_DATA gePAPort = new sapComDocumentSapRfcFunctionsCB.x_xGEL_xHYBRIS_ITEM_DATA();
        //--System.assertNotEquals(null, gePAPort.SI_SFB2B_ProductAvailability_701_OB_SYNC_N2('','','','','','','','', '','','','', null, null, null, null));
       
        //AsyncGecurrentCom701ProductAvailability.AsyncHTTPS_Port asyncGePAPort = new AsyncGecurrentCom701ProductAvailability.AsyncHTTPS_Port();
        //System.assertNotEquals(null, asyncGePAPort.beginSI_SFB2B_ProductAvailability_701_OB_SYNC_N1(null,'','','N','','','','','','', '','', null, null, null, null));
        
        //AsyncSapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LIS_Response_elementFuture elem = new AsyncSapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LIS_Response_elementFuture();
        //sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LIS_Response_element getValue = elem.getValue();

     }
}