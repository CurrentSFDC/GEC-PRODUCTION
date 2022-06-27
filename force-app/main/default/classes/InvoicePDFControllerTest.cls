@IsTest
public class InvoicePDFControllerTest {
    private static Account account = new Account();
    private static Contact contact = new Contact();
    private static User user = new User();

    @testSetup
    private static void setupData() {
        account = TestDataFactory.createAccount('Test Account ', true);
        Contact contact = TestDataFactory.createContact(account.Id, 'Test', 'Contact 1', 'test@example.com', true);
        user = TestDataFactory.createCommunityUser(contact.Id, contact.FirstName, contact.LastName, contact.Email, TestDataFactory.getRandomUsername(),
        'Agent B2B Storefront Registered Users', true);
    }

    public class InvoicePDFMock implements WebServiceMock {
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

                sapComDocSapRfcFunctionsInvPdf.x_xGEL_xSFB2B_INVOICE_PDF_GENRAT_Response_element response_x
                    = new sapComDocSapRfcFunctionsInvPdf.x_xGEL_xSFB2B_INVOICE_PDF_GENRAT_Response_element();
                    response_x.E_HEXDATA = '';            
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
    private static void testGetInvoicePDF() {

		Test.setMock(WebServiceMock.class, new InvoicePDFMock());

        InvoicePDFController.Request req = new InvoicePDFController.Request();
        req.invNumber = '12345';
        SAPGateway service = new SAPGateway();
        InvoicePDFController.Response res =  null;
        User user=[Select Id From User Where Email='test@example.com' LIMIT 1];
        Test.StartTest();
            System.runAs(user) {
                //res = service.getInvoicePDF(req);
                res = InvoicePDFController.getInvoicePDF('12345');
            }		
		Test.StopTest();

		System.assertNotEquals(res, null);
	}


}