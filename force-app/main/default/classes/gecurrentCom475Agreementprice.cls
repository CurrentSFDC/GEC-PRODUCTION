//Generated by wsdl2apex

public class gecurrentCom475Agreementprice {
    public class HTTPS_Port {
        public String endpoint_x = 'https://curelp1d00.sap.gecurrent.net:50001/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6&interfaceNamespace=urn%3Agecurrent.com%3ACOM_475%3AAgreementPriceCall_N6';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:gecurrent.com:COM_475:AgreementPriceCall_N6', 'gecurrentCom475Agreementprice', 'urn:sap-com:document:sap:rfc:functions', 'sapComDocSapRfcFunctionsAP'};
        public sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6(String I_AGREEMENT,String I_AGR_DATE,String I_CALL_TYPE,String I_DIST_CHENNEL,String I_DIVISION,String I_EXT_AGENT,String I_INT_REP,String I_ORDER_FLAG,String I_ORDER_REASON,String I_ORDER_TYPE,String I_PO_NUMBER,String I_SALES_ORG,String I_SOLD_TO,String I_USER_TYPE,String I_VALLIDATE_FLAG,sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element ET_MATERIALS_OUT,sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element ET_SCHEDULELINE_DATA,sapComDocSapRfcFunctionsAP.IT_MATERIALS_element IT_MATERIALS) {
            sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_element request_x = new sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_element();
            request_x.I_AGREEMENT = I_AGREEMENT;
            request_x.I_AGR_DATE = I_AGR_DATE;
            request_x.I_CALL_TYPE = I_CALL_TYPE;
            request_x.I_DIST_CHENNEL = I_DIST_CHENNEL;
            request_x.I_DIVISION = I_DIVISION;
            request_x.I_EXT_AGENT = I_EXT_AGENT;
            request_x.I_INT_REP = I_INT_REP;
            request_x.I_ORDER_FLAG = I_ORDER_FLAG;
            request_x.I_ORDER_REASON = I_ORDER_REASON;
            request_x.I_ORDER_TYPE = I_ORDER_TYPE;
            request_x.I_PO_NUMBER = I_PO_NUMBER;
            request_x.I_SALES_ORG = I_SALES_ORG;
            request_x.I_SOLD_TO = I_SOLD_TO;
            request_x.I_USER_TYPE = I_USER_TYPE;
            request_x.I_VALLIDATE_FLAG = I_VALLIDATE_FLAG;
            request_x.ET_MATERIALS_OUT = ET_MATERIALS_OUT;
            request_x.ET_SCHEDULELINE_DATA = ET_SCHEDULELINE_DATA;
            request_x.IT_MATERIALS = IT_MATERIALS;
            sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element response_x;
            Map<String, sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element> response_map_x = new Map<String, sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element>();
            response_map_x.put('response_x', response_x);
            system.debug(request_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:sap-com:document:sap:rfc:functions',
              '_-GEL_-SFB2B_AGREEMENT_PRICE_C2',
              'urn:sap-com:document:sap:rfc:functions',
              '_-GEL_-SFB2B_AGREEMENT_PRICE_C2.Response',
              'sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}