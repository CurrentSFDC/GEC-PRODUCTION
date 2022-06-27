//Generated by wsdl2apex

public class gelightingComCom433Crdbmemorequest {
    public class RecordSet_element {
        public String ComplaintNumber;
        public String ComplaintLineItemNo;
        public String SAPInvoiceNumber;
        public String SAPInvoiceLineItemNo;
        public String ApprovedQuantity;
        public String ApprovedPrice;
        public String ApprovedPriceUnit;
        public String SAPCustomerNumber;
        public String DocType;
        public String CategoryCode;
        public String SalesOrg;
        public String Division;
        public String DistributionChannel;
        public String RejectCode;
        public String BlockCR;
        public String MaterialNumber;
        public String POType;
        public String ManualInvoiceNo;
        private String[] ComplaintNumber_type_info = new String[]{'ComplaintNumber','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] ComplaintLineItemNo_type_info = new String[]{'ComplaintLineItemNo','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] SAPInvoiceNumber_type_info = new String[]{'SAPInvoiceNumber','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] SAPInvoiceLineItemNo_type_info = new String[]{'SAPInvoiceLineItemNo','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] ApprovedQuantity_type_info = new String[]{'ApprovedQuantity','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] ApprovedPrice_type_info = new String[]{'ApprovedPrice','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] ApprovedPriceUnit_type_info = new String[]{'ApprovedPriceUnit','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] SAPCustomerNumber_type_info = new String[]{'SAPCustomerNumber','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] DocType_type_info = new String[]{'DocType','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] CategoryCode_type_info = new String[]{'CategoryCode','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] SalesOrg_type_info = new String[]{'SalesOrg','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] Division_type_info = new String[]{'Division','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] DistributionChannel_type_info = new String[]{'DistributionChannel','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] RejectCode_type_info = new String[]{'RejectCode','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] BlockCR_type_info = new String[]{'BlockCR','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] MaterialNumber_type_info = new String[]{'MaterialNumber','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] POType_type_info = new String[]{'POType','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] ManualInvoiceNo_type_info = new String[]{'ManualInvoiceNo','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:gelighting.com:COM_433:CrDbMemoRequest','false','false'};
        private String[] field_order_type_info = new String[]{'ComplaintNumber','ComplaintLineItemNo','SAPInvoiceNumber','SAPInvoiceLineItemNo','ApprovedQuantity','ApprovedPrice','ApprovedPriceUnit','SAPCustomerNumber','DocType','CategoryCode','SalesOrg','Division','DistributionChannel','RejectCode','BlockCR','MaterialNumber','POType','ManualInvoiceNo'};
    }
    public class DT_SFDC_CrDbMemoRequest {
        public gelightingComCom433Crdbmemorequest.RecordSet_element[] RecordSet;
        private String[] RecordSet_type_info = new String[]{'RecordSet','urn:gelighting.com:COM_433:CrDbMemoRequest',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:gelighting.com:COM_433:CrDbMemoRequest','false','false'};
        private String[] field_order_type_info = new String[]{'RecordSet'};
    }
    public class SI_SFDC_CrDbMemoRequest_433_OB_ASYNCPort {
     
        //public String endpoint_x = 'https://circuits1.gelighting.com/XISOAPAdapter/MessageServlet?channel=:BC_SFDC:COM_433_SFDC_CrDbMemoRequest_SOAP_SCC1&amp;amp;version=3.0&amp;amp;Sender.Service=BC_SFDC&amp;amp;Interface=urn%3Agelighting.com%3ACOM_433%3ACrDbMemoRequest%5ESI_SFDC_CrDbMemoRequest_433_OB_ASYNC&amp;version=3.0&amp;Sender.Service=BC_SFDC&amp;Interface=urn%3Agelighting.com%3ACOM_433%3ACrDbMemoRequest%5ESI_SFDC_CrDbMemoRequest_433_OB_ASYNC&version=3.0&Sender.Service=BC_SFDC&Interface=urn%3Agelighting.com%3ACOM_433%3ACrDbMemoRequest%5ESI_SFDC_CrDbMemoRequest_433_OB_ASYNC';
         // SITNA endpoint
       // public String endpoint_x = 'https://circuits1.gelighting.com/XISOAPAdapter/MessageServlet?channel=:BC_SFDC:COM_433_SFDC_CrDbMemoRequest_SOAP_SCC1&version=3.0&Sender.Service=BC_SFDC&Interface=urn%3Agelighting.com%3ACOM_433%3ACrDbMemoRequest%5ESI_SFDC_CrDbMemoRequest_433_OB_ASYNC';
       // Prod endpoint
          public String endpoint_x = 'https://circuit1.gelighting.com/XISOAPAdapter/MessageServlet?channel=:BC_SFDC:COM_433_SFDC_CrDbMemoRequest_SOAP_SCC&amp;version=3.0&amp;Sender.Service=BC_SFDC&amp;Interface=urn%3Agelighting.com%3ACOM_433%3ACrDbMemoRequest%5ESI_SFDC_CrDbMemoRequest_433_OB_ASYNC';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:gelighting.com:COM_433:CrDbMemoRequest', 'gelightingComCom433Crdbmemorequest'};
        public gelightingComCom433Crdbmemorequest.RecordSet_element[] SI_SFDC_CrDbMemoRequest_433_OB_ASYNC(gelightingComCom433Crdbmemorequest.RecordSet_element[] RecordSet) {
            gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest request_x = new gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest();
            request_x.RecordSet = RecordSet;
            gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest response_x;
            Map<String, gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest> response_map_x = new Map<String, gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:gelighting.com:COM_433:CrDbMemoRequest',
              'MT_SFDC_CrDbMemoRequest',
              'urn:gelighting.com:COM_433:CrDbMemoRequest',
              'MT_SFDC_CrDbMemoRequest',
              'gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RecordSet;
        }
    }
}