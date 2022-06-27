/**
 * Created by Tamas on 7/14/2021.
 */

@IsTest
private class TestCaseRgaPdfController {
    @IsTest
    static void testBehavior() {

        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;

        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id );
        insert cas;

        CaseRgaPdfController.getRgaDoc(cas.Id);
    }


    static testMethod void service_call() {

        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;

        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id,GE_LGT_EM_SAP_Order_Number__c = '20-Professional' );
        insert cas;

        Dispute_Request__c dis = new Dispute_Request__c(Case__c = cas.Id, Transaction_ID__c = 'aff | Return | id3326.2999999970198');
        insert dis;

        Test.setMock(WebServiceMock.class, new getCaseRgaPdfMock());

        CaseRgaPdfController.Request req = new CaseRgaPdfController.Request();
        //req.ordNumber = '12345';
        SAPGatewayPDF service = new SAPGatewayPDF();
        CaseRgaPdfController.Response res =  null;
        Test.startTest();
        CaseRgaPdfController.getRgaDoc(dis.Id);
        Test.StopTest();
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