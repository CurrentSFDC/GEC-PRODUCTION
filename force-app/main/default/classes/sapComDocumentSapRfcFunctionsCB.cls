//Generated by wsdl2apex

public class sapComDocumentSapRfcFunctionsCB {
    public class x_xGEL_xHYBRIS_ITEM_DATA {
        public String POSNR;
        public String FKIMG;
        public String VRKME;
        public String FBUDA;
        public String KNUMA_REQ;
        public String ZECUSNO;
        public String ZECUSNAME;
        public String ZSHPTYP;
        public String ZGEINVNO;
        public String SHKZG;
        public String MATNR;
        public String ZCUSINV;
        public String PARVW;
        public String KUNNR;
        public String KBETR;
        public String MATID;
        public String UOMID;
        public String TRACKITM;
        public String PRSDT;
        public String VBELV;
        public String KWERT_1;
        public String KWERT_2;
        public String KWERT_3;
        private String[] POSNR_type_info = new String[]{'POSNR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] FKIMG_type_info = new String[]{'FKIMG','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] VRKME_type_info = new String[]{'VRKME','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] FBUDA_type_info = new String[]{'FBUDA','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KNUMA_REQ_type_info = new String[]{'KNUMA_REQ','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] ZECUSNO_type_info = new String[]{'ZECUSNO','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] ZECUSNAME_type_info = new String[]{'ZECUSNAME','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] ZSHPTYP_type_info = new String[]{'ZSHPTYP','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] ZGEINVNO_type_info = new String[]{'ZGEINVNO','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] SHKZG_type_info = new String[]{'SHKZG','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] MATNR_type_info = new String[]{'MATNR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] ZCUSINV_type_info = new String[]{'ZCUSINV','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] PARVW_type_info = new String[]{'PARVW','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KUNNR_type_info = new String[]{'KUNNR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KBETR_type_info = new String[]{'KBETR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] MATID_type_info = new String[]{'MATID','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] UOMID_type_info = new String[]{'UOMID','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] TRACKITM_type_info = new String[]{'TRACKITM','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] PRSDT_type_info = new String[]{'PRSDT','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] VBELV_type_info = new String[]{'VBELV','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KWERT_1_type_info = new String[]{'KWERT_1','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KWERT_2_type_info = new String[]{'KWERT_2','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KWERT_3_type_info = new String[]{'KWERT_3','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'POSNR','FKIMG','VRKME','FBUDA','KNUMA_REQ','ZECUSNO','ZECUSNAME','ZSHPTYP','ZGEINVNO','SHKZG','MATNR','ZCUSINV','PARVW','KUNNR','KBETR','MATID','UOMID','TRACKITM','PRSDT','VBELV','KWERT_1','KWERT_2','KWERT_3'};
    }
    public class x_xGEL_xHY_CLAIM_CREATE_element {
        public sapComDocumentSapRfcFunctionsCB.x_xGEL_xHYBRIS_HEADER_DATA I_HEADER_DATA;
        public sapComDocumentSapRfcFunctionsCB.IT_ITEM_DATA_element IT_ITEM_DATA;
        private String[] I_HEADER_DATA_type_info = new String[]{'I_HEADER_DATA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] IT_ITEM_DATA_type_info = new String[]{'IT_ITEM_DATA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'I_HEADER_DATA','IT_ITEM_DATA'};
    }
    public class x_xGEL_xHY_CLAIM_CREATE_Response_element {
        public String E_BATCH;
        public String E_ERROR;
        public String E_VBELN;
        public String E_XBLNR;
        public String E_ZUONR;
        public sapComDocumentSapRfcFunctionsCB.IT_ITEM_DATA_element IT_ITEM_DATA;
        private String[] E_BATCH_type_info = new String[]{'E_BATCH','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] E_ERROR_type_info = new String[]{'E_ERROR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] E_VBELN_type_info = new String[]{'E_VBELN','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] E_XBLNR_type_info = new String[]{'E_XBLNR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] E_ZUONR_type_info = new String[]{'E_ZUONR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] IT_ITEM_DATA_type_info = new String[]{'IT_ITEM_DATA','urn:sap-com:document:sap:rfc:functions',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'E_BATCH','E_ERROR','E_VBELN','E_XBLNR','E_ZUONR','IT_ITEM_DATA'};
    }
    public class x_xGEL_xHYBRIS_HEADER_DATA {
        public String CRTYP;
        public String FKDAT;
        public String KUNRE;
        public String XBLNR;
        public String ZUONR;
        public String CROGN;
        public String SUBAMT;
        public String SUBCUR;
        public String VKORG;
        public String VTWEG;
        public String SPART;
        public String BATCH;
        public String BTCDT;
        public String KUNAG;
        public String KTONR;
        private String[] CRTYP_type_info = new String[]{'CRTYP','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] FKDAT_type_info = new String[]{'FKDAT','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KUNRE_type_info = new String[]{'KUNRE','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] XBLNR_type_info = new String[]{'XBLNR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] ZUONR_type_info = new String[]{'ZUONR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] CROGN_type_info = new String[]{'CROGN','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] SUBAMT_type_info = new String[]{'SUBAMT','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] SUBCUR_type_info = new String[]{'SUBCUR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] VKORG_type_info = new String[]{'VKORG','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] VTWEG_type_info = new String[]{'VTWEG','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] SPART_type_info = new String[]{'SPART','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] BATCH_type_info = new String[]{'BATCH','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] BTCDT_type_info = new String[]{'BTCDT','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KUNAG_type_info = new String[]{'KUNAG','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] KTONR_type_info = new String[]{'KTONR','urn:sap-com:document:sap:rfc:functions',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'CRTYP','FKDAT','KUNRE','XBLNR','ZUONR','CROGN','SUBAMT','SUBCUR','VKORG','VTWEG','SPART','BATCH','BTCDT','KUNAG','KTONR'};
    }
    public class IT_ITEM_DATA_element {
        public sapComDocumentSapRfcFunctionsCB.x_xGEL_xHYBRIS_ITEM_DATA[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'item'};
    }
}