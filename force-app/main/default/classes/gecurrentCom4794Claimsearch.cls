//Generated by wsdl2apex

public class gecurrentCom4794Claimsearch {
    public class HTTPS_Port {
        public String endpoint_x = 'https://curelp3q00.sap.gecurrent.net:50101/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_ClaimsSearch_4794_OB_SYNC&interfaceNamespace=urn%3Agecurrent.com%3ACOM_4794%3AClaimSearch';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:gecurrent.com:COM_4794:ClaimSearch', 'gecurrentCom4794Claimsearch', 'urn:sap-com:document:sap:rfc:functions', 'sapComDocumentSapRfcFunctionsCS'};
        public sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_Response_element SI_SFB2B_ClaimsSearch_4794_OB_SYNC(
            String I_DATE_FROM,
            String I_DATE_TO,
            String I_MAT_NUM,
            sapComDocumentSapRfcFunctionsCS.ET_CLAIM_DETAILS_element ET_CLAIM_DETAILS,
            sapComDocumentSapRfcFunctionsCS.IT_ASSIGN_NUM_element IT_ASSIGN_NUM,
            sapComDocumentSapRfcFunctionsCS.IT_CLAIM_NUM_element IT_CLAIM_NUM,
            sapComDocumentSapRfcFunctionsCS.IT_CLAIM_TYP_element IT_CLAIM_TYP,
            sapComDocumentSapRfcFunctionsCS.IT_DIST_CHNL_element IT_DIST_CHNL,
            sapComDocumentSapRfcFunctionsCS.IT_DIV_element IT_DIV,
            sapComDocumentSapRfcFunctionsCS.IT_REF_NUM_element IT_REF_NUM,
            sapComDocumentSapRfcFunctionsCS.IT_SALES_ORG_element IT_SALES_ORG,
            sapComDocumentSapRfcFunctionsCS.IT_SOLD_TO_element IT_SOLD_TO,
            sapComDocumentSapRfcFunctionsCS.IT_TRANSMISSION_element IT_TRANSMISSION
        ) {
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_element request_x = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_element();
            request_x.I_DATE_FROM = I_DATE_FROM;
            request_x.I_DATE_TO = I_DATE_TO;
            request_x.I_MAT_NUM = I_MAT_NUM;
            request_x.ET_CLAIM_DETAILS = ET_CLAIM_DETAILS;
            request_x.IT_ASSIGN_NUM = IT_ASSIGN_NUM;
            request_x.IT_CLAIM_NUM = IT_CLAIM_NUM;
            request_x.IT_CLAIM_TYP = IT_CLAIM_TYP;
            request_x.IT_DIST_CHNL = IT_DIST_CHNL;
            request_x.IT_DIV = IT_DIV;
            request_x.IT_REF_NUM = IT_REF_NUM;
            request_x.IT_SALES_ORG = IT_SALES_ORG;
            request_x.IT_SOLD_TO = IT_SOLD_TO;
            request_x.IT_TRANSMISSION = IT_TRANSMISSION;
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_Response_element response_x;
            Map<String, sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_Response_element> response_map_x = new Map<String, sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_Response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:sap-com:document:sap:rfc:functions',
              '_-GEL_-SFB2B_CLAIM_SEARCH',
              'urn:sap-com:document:sap:rfc:functions',
              '_-GEL_-SFB2B_CLAIM_SEARCH.Response',
              'sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}