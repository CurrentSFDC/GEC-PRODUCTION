//Generated by wsdl2apex

public class gelightingComFi171SfdcComplaintcase {
    public class DT_SFDC_ComplaintCases {
        public gelightingComFi171SfdcComplaintcase.RecordSet_element[] RecordSet;
        private String[] RecordSet_type_info = new String[]{'RecordSet','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:gelighting.com:FI_171:SFDC_ComplaintCases','false','false'};
        private String[] field_order_type_info = new String[]{'RecordSet'};
    }
    public class RecordSet_element {
        public String CaseType;
        public String CaseIDNumber;
        public String DocumentType;
        public String PostingKey;
        public String PostingDate;
        public String DocumentDate;
        public String EntryDate;
        public String CustomerNumber;
        public String DocumentNumber;
        public String LineItem;
        public String BillingDocumentNo;
        public String TestRun;
        public String CompanyCode;
        public String FiscalYear;
        private String[] CaseType_type_info = new String[]{'CaseType','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] CaseIDNumber_type_info = new String[]{'CaseIDNumber','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] DocumentType_type_info = new String[]{'DocumentType','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] PostingKey_type_info = new String[]{'PostingKey','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] PostingDate_type_info = new String[]{'PostingDate','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] DocumentDate_type_info = new String[]{'DocumentDate','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] EntryDate_type_info = new String[]{'EntryDate','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] CustomerNumber_type_info = new String[]{'CustomerNumber','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] DocumentNumber_type_info = new String[]{'DocumentNumber','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] LineItem_type_info = new String[]{'LineItem','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] BillingDocumentNo_type_info = new String[]{'BillingDocumentNo','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] TestRun_type_info = new String[]{'TestRun','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] CompanyCode_type_info = new String[]{'CompanyCode','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] FiscalYear_type_info = new String[]{'FiscalYear','urn:gelighting.com:FI_171:SFDC_ComplaintCases',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:gelighting.com:FI_171:SFDC_ComplaintCases','false','false'};
        private String[] field_order_type_info = new String[]{'CaseType','CaseIDNumber','DocumentType','PostingKey','PostingDate','DocumentDate','EntryDate','CustomerNumber','DocumentNumber','LineItem','BillingDocumentNo','TestRun','CompanyCode','FiscalYear'};
    }
    public class SI_SFDC_ComplaintCases_171_OB_ASYNCPort {
       // Prod endpoint
        public String endpoint_x = 'https://circuit1.gelighting.com/XISOAPAdapter/MessageServlet?channel=:BC_SFDC:FI_171_SFDC_ComplaintCases_SOAP_SCC&amp;version=3.0&amp;Sender.Service=BC_SFDC&amp;Interface=urn%3Agelighting.com%3AFI_171%3ASFDC_ComplaintCases%5ESI_SFDC_ComplaintCases_171_OB_ASYNC';
       // SITNA endpoint
       // public String endpoint_x = 'https://circuits1.gelighting.com/XISOAPAdapter/MessageServlet?channel=:BC_SFDC:FI_171_SFDC_ComplaintCases_SOAP_SCC1&version=3.0&Sender.Service=BC_SFDC&Interface=urn%3Agelighting.com%3AFI_171%3ASFDC_ComplaintCases%5ESI_SFDC_ComplaintCases_171_OB_ASYNC';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:gelighting.com:FI_171:SFDC_ComplaintCases', 'gelightingComFi171SfdcComplaintcase'};
        public gelightingComFi171SfdcComplaintcase.RecordSet_element[] SI_SFDC_ComplaintCases_171_OB_ASYNC(gelightingComFi171SfdcComplaintcase.RecordSet_element[] RecordSet) {
            gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases request_x = new gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases();
            gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases response_x;
            request_x.RecordSet = RecordSet;
            Map<String, gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases> response_map_x = new Map<String, gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:gelighting.com:FI_171:SFDC_ComplaintCases',
              'MT_SFDC_ComplaintCases',
              'urn:gelighting.com:FI_171:SFDC_ComplaintCases',
              'MT_SFDC_ComplaintCases',
              'gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RecordSet;
        }
    }
}