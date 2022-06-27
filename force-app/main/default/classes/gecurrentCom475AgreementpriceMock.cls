public with sharing class gecurrentCom475AgreementpriceMock implements WebServiceMock {
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
 
                sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element r
                 = new sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element();
         response.put('response_x', r); 
    }
}