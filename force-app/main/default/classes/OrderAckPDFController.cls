/*---------------------------------------------------------------------------------
Name:       OrderAckPDFController.cls
Purpose:    Call SAP For Order Acknowledegement pdf
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          18-Jan-2021           Initial Development 
---------------------------------------------------------------------------------*/
public  class OrderAckPDFController {

    @AuraEnabled(cacheable=false)
	public static Response getPDF(String ordNumber){
        Request req = new Request();
        req.ordNumber = ordNumber;
        SAPGatewayPDF service = new SAPGatewayPDF();
        Response resp = service.getOrderAckPDF(req);

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

    @AuraEnabled
    public static String prepEmail(String emailAddress, String ccAddresses, String orderNumber, Id orderId, String pdfData, String type){
        
        System.debug('Passed Email Address(es): '+emailAddress);
        System.debug('Passed Email CC Address(es): '+ccAddresses);
        List<String> ccAdd = new List<String>();

        if(ccAddresses != null){
            ccAdd = ccAddresses.split(',');
        } else {
            ccAdd = null;
        }
        
        String docType = type;

        if (docType == 'Order') {
            docType = 'Order Confirmation';
        }

        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(pdfData);
        // cv.Title = orderNumber + ' - Order Confirmation';
        cv.Title = docType + ' - ' + orderNumber;
        // cv.PathOnClient = orderNumber + ' - Order Confirmation.pdf';
        cv.PathOnClient = docType + ' - ' + orderNumber + '.pdf';
        cv.IsMajorVersion = true;
        insert cv;
            
  
        
        

        System.debug('Content Version Entered: '+cv.Id);

       

        ContentVersion cvDoc = [SELECT Title,PathOnClient, FileType,
                                                VersionData 
                                          FROM ContentVersion 
                                          WHERE Id =: cv.Id  
                                           ];
          Blob Data = cvDoc.VersionData;

        EmailTemplate et = [select Id, Subject, HtmlValue, Body from EmailTemplate where name = 'PDF Emails'];
        System.debug('Found Email Template: '+et.Id);

        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no.reply@gecurrent.com'];


        System.debug('Email Template HTML Value: '+et.HtmlValue);
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(cvDoc.Title+'.'+cvDoc.FileType);
        efa.setBody(Data);

        //System.debug('Email Attachment: '+efa);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {emailAddress};
        if(ccAdd != null){
            message.setCcAddresses(ccAdd);
        }
        message.setTemplateID(et.Id);
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(owea.get(0).Id);
        // message.setSubject('PDF Copy of Order Confirmation');
        message.setSubject('PDF Copy of ' + docType);
        message.setHtmlBody(et.HtmlValue);
        //message.setWhatId(orderId);
        message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        return 'Email Sent';


        

    }
}