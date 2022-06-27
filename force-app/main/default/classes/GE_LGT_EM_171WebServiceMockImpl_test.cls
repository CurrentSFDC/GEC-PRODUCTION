/**********************
Murugan TechMahindra

Webservice Class
***********************/


@isTest
global class GE_LGT_EM_171WebServiceMockImpl_test implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
        gelightingComFi171SfdcComplaintcase.RecordSet_element RecordSetEle = new gelightingComFi171SfdcComplaintcase.RecordSet_element();
        List<gelightingComFi171SfdcComplaintcase.RecordSet_element> RecordSetResponse = new List<gelightingComFi171SfdcComplaintcase.RecordSet_element>();
        List<gelightingComFi171SfdcComplaintcase.RecordSet_element> ListRecordSet = new List<gelightingComFi171SfdcComplaintcase.RecordSet_element>();
        gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases request_x = new gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases();
        Map<String, gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases> response_map_x = new Map<String, gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases>();
        gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases response_x;
        RecordSetEle.CaseType='test data'; 
        RecordSetEle.CaseIDNumber='test data';
        RecordSetEle.DocumentNumber='test data';
        RecordSetEle.CustomerNumber='test data';
        ListRecordSet.add(RecordSetEle);
        request_x.RecordSet=ListRecordSet;//RecordSetResponse; 
     
        response.put('response_x',request_x); 
        
      
   }
}