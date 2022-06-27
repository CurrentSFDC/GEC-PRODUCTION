@isTest
public with sharing class gecurrentComCom472OrdercreateN3Test {
    @isTest
    public static void test(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new MockSAPGateway());
        gecurrentComCom472OrdercreateN3.HTTPS_Port port = new gecurrentComCom472OrdercreateN3.HTTPS_Port();
        gecurrentComCom472OrdercreateN3.GEOrderInfoWrapper wrap = new gecurrentComCom472OrdercreateN3.GEOrderInfoWrapper();
        sapComDocumentSapRfcFunctions.x_xGEL_xSFB2B_ORDER_CREATE_Response_element resp = port.SI_SFB2B_OrderCreate_472_OB_SYNC_N3(wrap);
        Test.stopTest();
    }

    private class MockSAPGateway implements WebServiceMock {
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
                sapComDocumentSapRfcFunctions.x_xGEL_xSFB2B_ORDER_CREATE_Response_element response_x =new sapComDocumentSapRfcFunctions.x_xGEL_xSFB2B_ORDER_CREATE_Response_element();
                response_x.E_SALES_NUMBER = '123456';
                response.put('response_x', response_x);
        }
        
	}


}