@IsTest
public with sharing class ClaimSearchControllerTest {

    @IsTest
    static void testClaimSearchController() {
        Test.setMock(WebServiceMock.class, new GecurrentCom4794ClaimsearchMock());
        ClaimSearchController.ClaimSearchRequest request = new ClaimSearchController.ClaimSearchRequest();
        request.dateFrom = Datetime.now().format('yyyy-MM-dd');
        request.dateTo = Datetime.now().format('yyyy-MM-dd');
        request.materialNumber = 'test';
        request.soldToNumber = 'test';
        request.salesOrg = 'test';
        request.distributionChannel = 'test';
        request.division = 'test';
        request.claimNumber = 'test';
        request.referenceNumber = 'test';
        ClaimSearchController.searchClaims(request);
    }

    public class GecurrentCom4794ClaimsearchMock implements WebServiceMock {

        public void doInvoke(Object param1, Object param2, Map<String, Object> response, String param4, String param5, String param6, String param7, String param8, String param9) {
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_Response_element r = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_Response_element();
            sapComDocumentSapRfcFunctionsCS.ET_CLAIM_DETAILS_element claimDetails = new sapComDocumentSapRfcFunctionsCS.ET_CLAIM_DETAILS_element();
            claimDetails.item = new List<sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_DETAILS>();
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_DETAILS detail = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_DETAILS();
            detail.CLAIM_NUM = '';
            detail.CLAIM_DATE = Datetime.now().format('yyyy-MM-dd');
            detail.REF_NUM = '';
            detail.SALES_ORG = '';
            detail.DIST_CHANNEL = '';
            detail.DIV = '';
            detail.CUSTOMER = '';
            detail.CLAIM_TOT_AMT = '1';
            detail.SUBMIT_AMT = '1';
            detail.POSTING_BLOCK = '';
            detail.ASSIGN_NUM = '';
            detail.TRANSMISSION = '';
            detail.INVOICE_DATE = Datetime.now().format('yyyy-MM-dd');
            detail.INVOIC_NUM = '';
            detail.INVOICE_AMT = '1';
            r.ET_CLAIM_DETAILS = claimDetails;
            claimDetails.item.add(detail);
            response.put('response_x', r);
        }
    }
}