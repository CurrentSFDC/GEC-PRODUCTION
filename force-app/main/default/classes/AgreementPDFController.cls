/*---------------------------------------------------------------------------------
Name:       AgreementPDFController.cls
Purpose:    Call SAP For Agreement pdf
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description
-------     -------         --------------          -----------------------------
1.0         Devang          18-Jan-2021             Initial Development
---------------------------------------------------------------------------------*/
public class AgreementPDFController {

    @AuraEnabled(Cacheable=false)
    public static Response getPDF(String agrNumber) {
        Request req = new Request();
        req.agrNumber = agrNumber;
        SAPGatewayPDF service = new SAPGatewayPDF();
        Response resp = service.getAgreementPDF(req);

        return resp;
    }

    public class Request {
        @AuraEnabled
        public String agrNumber { get; set; }
    }

    public class Response {
        @AuraEnabled
        public String hexData { get; set; }
        @AuraEnabled
        public String base64Data { get; set; }
        @AuraEnabled
        public String message { get; set; }
    }
}