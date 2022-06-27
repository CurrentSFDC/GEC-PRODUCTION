@isTest
    global class sapComDocumentSapRfcFunctionsCB_MOCK implements WebServiceMock {

        
            global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
            sapComDocumentSapRfcFunctionsCB.x_xGEL_xHY_CLAIM_CREATE_Response_element r = 
            new sapComDocumentSapRfcFunctionsCB.x_xGEL_xHY_CLAIM_CREATE_Response_element();
            response.put('response_x', r);  
           }
   
    }