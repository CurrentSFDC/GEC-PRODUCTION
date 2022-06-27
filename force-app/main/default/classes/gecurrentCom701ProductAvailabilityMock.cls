/*---------------------------------------------------------------------------------
Name:       gecurrentCom701ProductAvailabilityMock.cls
Purpose:    Mock Class for Product Availability.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          30-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/

public class gecurrentCom701ProductAvailabilityMock implements WebServiceMock {
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
 
                sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LS2_Response_element r
                 = new sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LS2_Response_element();
         response.put('response_x', r); 
    }
}