/*----------------------------------------------------------------------
Name:       InvoicePDFController.cls
Purpose:    Call SAP For Invoice PDFs
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Nate Kanyok     29-Dec-2020             Initial Development 
----------------------------------------------------------------------*/
public class InvoicePDFController {


    @AuraEnabled(cacheable=false)
	public static Response getInvoicePDF(String invNumber){
        Request req = new Request();
        req.invNumber = invNumber;
        SAPGateway service = new SAPGateway();
        Response resp = service.getInvoicePDF(req);
       System.debug(req.invNumber);
       System.debug('Checkpoint');
       system.debug(req);
       System.debug('Checkpoint');

        //Blob blobData = EncodingUtil.convertFromHex(resp.hexData);   
        // SAP gives base64. If not use below code to convert hex to base64
        // if(resp != null && resp.hexData != null && String.isNotBlank(resp.hexData)) {    
        //     //resp.base64Data = EncodingUtil.base64Encode(EncodingUtil.convertFromHex(resp.hexData));
        // }

        return resp;
       // system.debug(service.getInvoicePDF(req));

    }

    public class Request{    
        @AuraEnabled
        public String invNumber {get; set;}
    }
    
    public class Response{    
        @AuraEnabled
        public String hexData {get; set;}
        @AuraEnabled
        public Blob blobData {get; set;}
        @AuraEnabled
        public String base64Data {get; set;}
        @AuraEnabled
        public String message {get; set;}
    }


}