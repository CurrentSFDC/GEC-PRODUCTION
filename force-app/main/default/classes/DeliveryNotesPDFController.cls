/*---------------------------------------------------------------------------------
Name:       DeliveryNotesPDFController.cls
Purpose:    Call SAP For Delivery Notes pdf
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          18-Jan-2021             Initial Development 
---------------------------------------------------------------------------------*/
public  class DeliveryNotesPDFController {

    @AuraEnabled(cacheable=false)
	public static Response getPDF(String invNumber){
        Request req = new Request();
        req.invNumber = invNumber;
        SAPGatewayPDF service = new SAPGatewayPDF();
        Response resp = service.getDeliveryNotesPDF(req);

        return resp;
    }

    public class Request{    
        @AuraEnabled
        public String invNumber {get; set;}
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