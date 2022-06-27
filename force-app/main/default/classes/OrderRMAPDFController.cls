/*---------------------------------------------------------------------------------
Name:       OrderRMAPDFController.cls
Purpose:    Call SAP For Order RMA pdf
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          18-Jan-2021           Initial Development 
---------------------------------------------------------------------------------*/
public  class OrderRMAPDFController {

    @AuraEnabled(cacheable=false)
	public static Response getPDF(String ordNumber){
        Request req = new Request();
        req.ordNumber = ordNumber;
        SAPGatewayPDF service = new SAPGatewayPDF();
        Response resp = service.getOrderRMAPDF(req);

        return resp;
    }

    public class Request{    
        @AuraEnabled
        public String ordNumber {get; set;}
    }
    
    public class Response{    
        @AuraEnabled
        public String hexData {get; set;}
        @AuraEnabled
        public String base64Data {get; set;}
        @AuraEnabled
        public String message {get; set;}
    }
}