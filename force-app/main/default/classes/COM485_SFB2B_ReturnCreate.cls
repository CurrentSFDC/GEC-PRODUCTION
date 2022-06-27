/**
 * Created by PA on 2021. 07. 19..
 */

public with sharing class COM485_SFB2B_ReturnCreate {
    public class x_xGEL_xSFB2B_RETURN_CREATE_element {
        public String I_BILL_BLOCK;
        public String I_CUSTOMER;
        public String I_DELIVERY_BLOCK;
        public String I_DIST_CHANNEL;
        public String I_DIVISION;
        public String I_EXT_AGENT;
        public String I_HEAD_COMMENTS;
        public String I_INT_REP;
        public String I_INV_NUMBER;
        public String I_ORDER_REASON;
        public String I_ORDER_TYPE;
        public String I_PO_NUM;
        public String I_REF_DOC_NUMBER;
        public String I_REQ_DATE;
        public String I_REQ_FOR_REPLACMENT;
        public String I_SALES_ORG;
        public String I_SFDC_CASE_NUMBER;
        public String I_SHIPTO_ADDRESS1;
        public String I_SHIPTO_ADDRESS2;
        public String I_SHIPTO_CITY;
        public String I_SHIPTO_COUNTRY;
        public String I_SHIPTO_NAME;
        public String I_SHIPTO_POSTALCODE;
        public String I_SHIPTO_STATE;
        public String I_SHIP_TO;
        public String I_USER_TYPE;
        public COM485_SFB2B_ReturnCreate.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS;
        public COM485_SFB2B_ReturnCreate.IT_ITEM_COMMENTS_element IT_ITEM_COMMENTS;
        public COM485_SFB2B_ReturnCreate.IT_RETURN_ITEMS_element IT_RETURN_ITEMS;
        private String[] I_BILL_BLOCK_type_info = new String[]{'I_BILL_BLOCK','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_CUSTOMER_type_info = new String[]{'I_CUSTOMER','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_DELIVERY_BLOCK_type_info = new String[]{'I_DELIVERY_BLOCK','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_DIST_CHANNEL_type_info = new String[]{'I_DIST_CHANNEL','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_DIVISION_type_info = new String[]{'I_DIVISION','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_EXT_AGENT_type_info = new String[]{'I_EXT_AGENT','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_HEAD_COMMENTS_type_info = new String[]{'I_HEAD_COMMENTS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_INT_REP_type_info = new String[]{'I_INT_REP','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_INV_NUMBER_type_info = new String[]{'I_INV_NUMBER','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_ORDER_REASON_type_info = new String[]{'I_ORDER_REASON','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] I_ORDER_TYPE_type_info = new String[]{'I_ORDER_TYPE','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_PO_NUM_type_info = new String[]{'I_PO_NUM','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] I_REF_DOC_NUMBER_type_info = new String[]{'I_REF_DOC_NUMBER','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_REQ_DATE_type_info = new String[]{'I_REQ_DATE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] I_REQ_FOR_REPLACMENT_type_info = new String[]{'I_REQ_FOR_REPLACMENT','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] I_SALES_ORG_type_info = new String[]{'I_SALES_ORG','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SFDC_CASE_NUMBER_type_info = new String[]{'I_SFDC_CASE_NUMBER','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SHIPTO_ADDRESS1_type_info = new String[]{'I_SHIPTO_ADDRESS1','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SHIPTO_ADDRESS2_type_info = new String[]{'I_SHIPTO_ADDRESS2','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SHIPTO_CITY_type_info = new String[]{'I_SHIPTO_CITY','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SHIPTO_COUNTRY_type_info = new String[]{'I_SHIPTO_COUNTRY','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SHIPTO_NAME_type_info = new String[]{'I_SHIPTO_NAME','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SHIPTO_POSTALCODE_type_info = new String[]{'I_SHIPTO_POSTALCODE','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SHIPTO_STATE_type_info = new String[]{'I_SHIPTO_STATE','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_SHIP_TO_type_info = new String[]{'I_SHIP_TO','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] I_USER_TYPE_type_info = new String[]{'I_USER_TYPE','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] IT_HEAD_COMMENTS_type_info = new String[]{'IT_HEAD_COMMENTS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] IT_ITEM_COMMENTS_type_info = new String[]{'IT_ITEM_COMMENTS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] IT_RETURN_ITEMS_type_info = new String[]{'IT_RETURN_ITEMS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'I_BILL_BLOCK','I_CUSTOMER','I_DELIVERY_BLOCK','I_DIST_CHANNEL','I_DIVISION','I_EXT_AGENT','I_HEAD_COMMENTS','I_INT_REP','I_INV_NUMBER','I_ORDER_REASON','I_ORDER_TYPE','I_PO_NUM','I_REF_DOC_NUMBER','I_REQ_DATE','I_REQ_FOR_REPLACMENT','I_SALES_ORG','I_SFDC_CASE_NUMBER','I_SHIPTO_ADDRESS1','I_SHIPTO_ADDRESS2','I_SHIPTO_CITY','I_SHIPTO_COUNTRY','I_SHIPTO_NAME','I_SHIPTO_POSTALCODE','I_SHIPTO_STATE','I_SHIP_TO','I_USER_TYPE','IT_HEAD_COMMENTS','IT_ITEM_COMMENTS','IT_RETURN_ITEMS'};
    }
    public class IT_RETURN_ITEMS_element {
        public COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_ITEM[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class x_xGEL_xSFB2B_RETURN_CREATE_Response_element {
        public String E_ERR_MESSAGE;
        public String E_SALES_ORDER;
        public COM485_SFB2B_ReturnCreate.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS;
        public COM485_SFB2B_ReturnCreate.IT_ITEM_COMMENTS_element IT_ITEM_COMMENTS;
        public COM485_SFB2B_ReturnCreate.IT_RETURN_ITEMS_element IT_RETURN_ITEMS;
        private String[] E_ERR_MESSAGE_type_info = new String[]{'E_ERR_MESSAGE','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] E_SALES_ORDER_type_info = new String[]{'E_SALES_ORDER','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] IT_HEAD_COMMENTS_type_info = new String[]{'IT_HEAD_COMMENTS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] IT_ITEM_COMMENTS_type_info = new String[]{'IT_ITEM_COMMENTS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] IT_RETURN_ITEMS_type_info = new String[]{'IT_RETURN_ITEMS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'E_ERR_MESSAGE','E_SALES_ORDER','IT_HEAD_COMMENTS','IT_ITEM_COMMENTS','IT_RETURN_ITEMS'};
    }
    public class IT_HEAD_COMMENTS_element {
        public COM485_SFB2B_ReturnCreate.x_xGEL_xHY_ORDER_TEXT[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class x_xGEL_xHY_ORDER_TEXT {
        public String ITEM;
        public String TEXT;
        private String[] ITEM_type_info = new String[]{'ITEM','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] TEXT_type_info = new String[]{'TEXT','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'ITEM','TEXT'};
    }
    public class x_xGEL_xSFB2B_RETURN_ITEM {
        public String ITEM_NUMBER;
        public String PART_NUMBER;
        public String QUANTITY;
        public String UOM;
        public String REQ_PRICE;
        public String CURRENCY_x;
        public String ITEM_COMMENTS;
        public String AGENT;
        private String[] ITEM_NUMBER_type_info = new String[]{'ITEM_NUMBER','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] PART_NUMBER_type_info = new String[]{'PART_NUMBER','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] QUANTITY_type_info = new String[]{'QUANTITY','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] UOM_type_info = new String[]{'UOM','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] REQ_PRICE_type_info = new String[]{'REQ_PRICE','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] CURRENCY_x_type_info = new String[]{'CURRENCY','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] ITEM_COMMENTS_type_info = new String[]{'ITEM_COMMENTS','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] AGENT_type_info = new String[]{'AGENT','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'ITEM_NUMBER','PART_NUMBER','QUANTITY','UOM','REQ_PRICE','CURRENCY_x','ITEM_COMMENTS','AGENT'};
    }
    public class IT_ITEM_COMMENTS_element {
        public COM485_SFB2B_ReturnCreate.x_xGEL_xHY_ORDER_TEXT[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class HTTPS_Port {
        public String endpoint_x = 'callout:SAP_SOAP/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_ReturnsCreate_485_OB_SYNC&interfaceNamespace=urn%3Agecurrent.com%3ACOM_485%3AReturnsCreate';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions', 'COM485_SFB2B_ReturnCreate', 'urn:gecurrent.com:COM_485:ReturnsCreate', 'COM485_SFB2B_ReturnCreate'};
        public COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_Response_element SI_SFB2B_ReturnsCreate_485_OB_SYNC(AttributeElement paramPackage) {
            COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_element request_x = new COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_element();
            request_x.I_BILL_BLOCK = paramPackage.I_BILL_BLOCK;
            request_x.I_CUSTOMER = paramPackage.I_CUSTOMER;
            request_x.I_DELIVERY_BLOCK = paramPackage.I_DELIVERY_BLOCK;
            request_x.I_DIST_CHANNEL = paramPackage.I_DIST_CHANNEL;
            request_x.I_DIVISION = paramPackage.I_DIVISION;
            request_x.I_EXT_AGENT = paramPackage.I_EXT_AGENT;
            request_x.I_HEAD_COMMENTS = paramPackage.I_HEAD_COMMENTS;
            request_x.I_INT_REP = paramPackage.I_INT_REP;
            request_x.I_INV_NUMBER = paramPackage.I_INV_NUMBER;
            request_x.I_ORDER_REASON = paramPackage.I_ORDER_REASON;
            request_x.I_ORDER_TYPE = paramPackage.I_ORDER_TYPE;
            request_x.I_PO_NUM = paramPackage.I_PO_NUM;
            request_x.I_REF_DOC_NUMBER = paramPackage.I_REF_DOC_NUMBER;
            request_x.I_REQ_DATE = paramPackage.I_REQ_DATE;
            request_x.I_REQ_FOR_REPLACMENT = paramPackage.I_REQ_FOR_REPLACMENT;
            request_x.I_SALES_ORG = paramPackage.I_SALES_ORG;
            request_x.I_SFDC_CASE_NUMBER = paramPackage.I_SFDC_CASE_NUMBER;
            request_x.I_SHIPTO_ADDRESS1 = paramPackage.I_SHIPTO_ADDRESS1;
            request_x.I_SHIPTO_ADDRESS2 = paramPackage.I_SHIPTO_ADDRESS2;
            request_x.I_SHIPTO_CITY = paramPackage.I_SHIPTO_CITY;
            request_x.I_SHIPTO_COUNTRY = paramPackage.I_SHIPTO_COUNTRY;
            request_x.I_SHIPTO_NAME = paramPackage.I_SHIPTO_NAME;
            request_x.I_SHIPTO_POSTALCODE = paramPackage.I_SHIPTO_POSTALCODE;
            request_x.I_SHIPTO_STATE = paramPackage.I_SHIPTO_STATE;
            request_x.I_SHIP_TO = paramPackage.I_SHIP_TO;
            request_x.I_USER_TYPE = paramPackage.I_USER_TYPE;
            request_x.IT_HEAD_COMMENTS = paramPackage.IT_HEAD_COMMENTS;
            request_x.IT_ITEM_COMMENTS = paramPackage.IT_ITEM_COMMENTS;
            request_x.IT_RETURN_ITEMS = paramPackage.IT_RETURN_ITEMS;
            COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_Response_element response_x;
            Map<String, COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_Response_element> response_map_x = new Map<String, COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_Response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                            'http://sap.com/xi/WebService/soap1.1',
                            'urn:sap-com:document:sap:rfc:functions',
                            '_-GEL_-SFB2B_RETURN_CREATE',
                            'urn:sap-com:document:sap:rfc:functions',
                            '_-GEL_-SFB2B_RETURN_CREATE.Response',
                            'COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
    public class AttributeElement{
        public String
                I_BILL_BLOCK,
                I_CUSTOMER,
                I_DELIVERY_BLOCK,
                I_DIST_CHANNEL,
                I_DIVISION,
                I_EXT_AGENT,
                I_HEAD_COMMENTS,
                I_INT_REP,
                I_INV_NUMBER,
                I_ORDER_REASON,
                I_ORDER_TYPE,
                I_PO_NUM,
                I_REF_DOC_NUMBER,
                I_REQ_DATE,
                I_REQ_FOR_REPLACMENT,
                I_SALES_ORG,
                I_SFDC_CASE_NUMBER,
                I_SHIPTO_ADDRESS1,
                I_SHIPTO_ADDRESS2,
                I_SHIPTO_CITY,
                I_SHIPTO_COUNTRY,
                I_SHIPTO_NAME,
                I_SHIPTO_POSTALCODE,
                I_SHIPTO_STATE,
                I_SHIP_TO,
                I_USER_TYPE;
        public COM485_SFB2B_ReturnCreate.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS;
        public COM485_SFB2B_ReturnCreate.IT_RETURN_ITEMS_element IT_RETURN_ITEMS;
        public COM485_SFB2B_ReturnCreate.IT_ITEM_COMMENTS_element IT_ITEM_COMMENTS;
    }
}