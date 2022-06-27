/*---------------------------------------------------------------------------------
Name:       SAPGatewayPDFTest.cls
Purpose:    Test Class for SAP SOAP services.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Jan-2020           Initial Development 
---------------------------------------------------------------------------------*/
@IsTest
public class SAPGatewayPDFTest {
    private static Account account = new Account();
    private static Contact contact = new Contact();
    private static User user = new User();

    @testSetup
    private static void setupData() {
        account = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(account.Id, 'Test', 'Contact 1', 'test@example.com', true);
        user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);

        //EmailTemplate e = new EmailTemplate (developerName = 'PDF_Emails', FolderId = '00D2F000000FWJDUA4', TemplateType= 'Text', Name = 'PDF Emails'); // plus any other fields that you want to set

//insert e;
    }

    @isTest
	private static void getOrderAckPDF() {

		Test.setMock(WebServiceMock.class, new OrderAckPDFMock());

        OrderAckPDFController.Request req = new OrderAckPDFController.Request();
        req.ordNumber = '12345';
        SAPGatewayPDF service = new SAPGatewayPDF();
        OrderAckPDFController.Response res =  null;
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.StartTest();
            System.runAs(user) {
                res = service.getOrderAckPDF(req);
            }		
		Test.StopTest();
        OrderAckPDFController.prepEmail('matthew.gugumuck@gecurrent.com', null, req.ordNumber, null, res.base64Data, 'Order');

		System.assertNotEquals(res, null);
    }
    
    @isTest
    private static void getDeliveryNotesPDF() {

		Test.setMock(WebServiceMock.class, new DeliveryNotesPDFMock());

        DeliveryNotesPDFController.Request req = new DeliveryNotesPDFController.Request();
        req.invNumber = '12345';
        SAPGatewayPDF service = new SAPGatewayPDF();
        DeliveryNotesPDFController.Response res =  null;
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.StartTest();
            System.runAs(user) {
                res = service.getDeliveryNotesPDF(req);
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}

    public class OrderAckPDFMock implements WebServiceMock {
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

            sapComDocSapRfcFunctionsOAck.x_xGEL_xSFB2B_ORDACK_PDF_Response_element response_x
            = new sapComDocSapRfcFunctionsOAck.x_xGEL_xSFB2B_ORDACK_PDF_Response_element();
            response_x.E_HEXDATA = '';
            response_x.E_MESSAGE = '';
            response_x.E_PDFDATA = 'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwog' +
            'IC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAv' +
            'TWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0K' +
            'Pj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAg' +
            'L1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+' +
            'PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9u' +
            'dAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2Jq' +
            'Cgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJU' +
            'CjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVu' +
            'ZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4g' +
            'CjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAw' +
            'MDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9v' +
            'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G';
            response.put('response_x', response_x); 
        }
    }



    public class DeliveryNotesPDFMock implements WebServiceMock {
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

            sapComDocSapRfcFunctionsDM.x_xGEL_xSFB2B_PACKLST_PDF_Response_element response_x
            = new sapComDocSapRfcFunctionsDM.x_xGEL_xSFB2B_PACKLST_PDF_Response_element();
            response_x.E_HEXDATA = '';
            response_x.E_MESSAGE = '';
            response_x.E_PDFDATA = 'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwog' +
            'IC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAv' +
            'TWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0K' +
            'Pj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAg' +
            'L1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+' +
            'PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9u' +
            'dAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2Jq' +
            'Cgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJU' +
            'CjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVu' +
            'ZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4g' +
            'CjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAw' +
            'MDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9v' +
            'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G';
            response.put('response_x', response_x); 
        }
    }


    @isTest
    private static void getAgreementPDF() {

		Test.setMock(WebServiceMock.class, new AgreementPDFMock());

        AgreementPDFController.Request req = new AgreementPDFController.Request();
        req.agrNumber = '12345';
        SAPGatewayPDF service = new SAPGatewayPDF();
        AgreementPDFController.Response res =  null;
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.StartTest();
            System.runAs(user) {
                res = service.getAgreementPDF(req);
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}


    public class AgreementPDFMock implements WebServiceMock {
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

            sapComDocSapRfcFunctionsAgrPDF.x_xGEL_xSFB2B_AGREEMENT_PDF_GEN_Response_element response_x
            = new sapComDocSapRfcFunctionsAgrPDF.x_xGEL_xSFB2B_AGREEMENT_PDF_GEN_Response_element();
            response_x.E_HEXDATA = '';
            response_x.E_MESSAGE = '';
            response_x.E_PDFDATA = 'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwog' +
            'IC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAv' +
            'TWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0K' +
            'Pj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAg' +
            'L1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+' +
            'PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9u' +
            'dAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2Jq' +
            'Cgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJU' +
            'CjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVu' +
            'ZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4g' +
            'CjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAw' +
            'MDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9v' +
            'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G';
            response.put('response_x', response_x); 
        }
    }

    @isTest
    private static void getOrderRMAPDF() {

		Test.setMock(WebServiceMock.class, new OrderRMAPDFMock());

        OrderRMAPDFController.Request req = new OrderRMAPDFController.Request();
        req.ordNumber = '12345';
        SAPGatewayPDF service = new SAPGatewayPDF();
        OrderRMAPDFController.Response res =  null;
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.StartTest();
            System.runAs(user) {
                res = service.getOrderRMAPDF(req);
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}

    public class OrderRMAPDFMock implements WebServiceMock {
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

            sapComDocSapRfcFunctionsRMA.x_xGEL_xSFB2B_PRINT_RET_ORDER_Response_element response_x
            = new sapComDocSapRfcFunctionsRMA.x_xGEL_xSFB2B_PRINT_RET_ORDER_Response_element();
            response_x.E_HEXDATA_1 = '';            
            response_x.E_PDFDATA = 'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwog' +
            'IC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAv' +
            'TWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0K' +
            'Pj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAg' +
            'L1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+' +
            'PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9u' +
            'dAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2Jq' +
            'Cgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJU' +
            'CjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVu' +
            'ZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4g' +
            'CjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAw' +
            'MDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9v' +
            'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G';
            response.put('response_x', response_x); 
        }
    }
    
    
     @isTest
    private static void getCaseRgaPdf() {

		Test.setMock(WebServiceMock.class, new getCaseRgaPdfMock());

        CaseRgaPdfController.Request req = new CaseRgaPdfController.Request();
        //req.ordNumber = '12345';
        SAPGatewayPDF service = new SAPGatewayPDF();
        CaseRgaPdfController.Response res =  null;
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.StartTest();
            System.runAs(user) {
                res = service.getCaseRgaPdf(req);
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}

    public class getCaseRgaPdfMock implements WebServiceMock {
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

           sapComDocSapRfcFunctionsRMA.x_xGEL_xSFB2B_PRINT_RET_ORDER_Response_element response_x = new sapComDocSapRfcFunctionsRMA.x_xGEL_xSFB2B_PRINT_RET_ORDER_Response_element();
            response_x.E_HEXDATA_1 = '';            
            response_x.E_PDFDATA = 'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwog' +
            'IC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAv' +
            'TWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0K' +
            'Pj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAg' +
            'L1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+' +
            'PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9u' +
            'dAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2Jq' +
            'Cgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJU' +
            'CjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVu' +
            'ZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4g' +
            'CjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAw' +
            'MDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9v' +
            'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G';
            response.put('response_x', response_x); 
        }
    }
    
}