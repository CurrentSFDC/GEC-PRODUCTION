/**
 * Created by PA on 2021. 06. 16..
 */

public with sharing class CaseRgaPdfController {

    public static Response getPDF(String ordNumber){
        Request req = new Request();
        req.orderNumber = ordNumber;
        SAPGatewayPDF service = new SAPGatewayPDF();
        Response resp = service.getCaseRgaPdf(req);

        return resp;
    }

    public class Request{
        public String orderNumber {get; set;}
    }

    public class Response{
        public Boolean hasError { get; set; }
        public String hexData {get; set;}
        public String base64Data {get; set;}
        public String message {get; set;}
        public String caseNo {get; set;}
    }

    //test orderNo = '40134384')
    @AuraEnabled
    public static String getRgaDoc(String caseId){

        CaseRgaPdfController.Response resp;
        try {

            //CHANGE TO DISUPUTE REQUEST
            Dispute_Request__c d = [SELECT Id, Connect_Request__c, Order__c FROM Dispute_Request__c WHERE Id =: caseId LIMIT 1];
            System.debug('Dispute Request - ORDER received from APEX: '+d.Order__c);
            if (d.Order__c == '') {
                resp = new Response();
                resp.hasError = true;
                resp.message = 'There\'s no order number for this Case. Please try again later.' ;
                return JSON.serialize(resp);
            }

            //resp =  getPDF('40134384');

            resp =  getPDF(d.Order__c);
            resp.caseNo = d.Order__c;
            resp.hasError = false;

        /*
            Case c = [SELECT Id, CaseNumber, GE_LGT_EM_SAP_Order_Number__c FROM Case WHERE Id = :caseId LIMIT 1];
            if (c.GE_LGT_EM_SAP_Order_Number__c == null) {
                resp = new Response();
                resp.hasError = true;
                resp.message = 'There\'s no order number for this Case. Please try again later.' ;
                return JSON.serialize(resp);
            }

            //resp =  getPDF('40134384');

            resp =  getPDF(c.GE_LGT_EM_SAP_Order_Number__c);
            resp.caseNo = c.CaseNumber;
            resp.hasError = false;
        */
        }
    catch (Exception e){
            resp = new Response();
            resp.hasError = true;
            resp.message = 'Something went wrong. Please try again a few minutes later.';
        }

    

        system.debug('B64 data:' + resp.base64Data);
        if (resp.base64Data == null) {return JSON.serialize(resp);}

        Attachment attach = new Attachment();
        attach.contentType = 'application/pdf';
        attach.name = resp.caseNo + '_RGA_doc.pdf';
        attach.parentId = caseId;
        attach.body = EncodingUtil.base64Decode(resp.base64Data);
        insert attach;

        return JSON.serialize(resp);
    }
}