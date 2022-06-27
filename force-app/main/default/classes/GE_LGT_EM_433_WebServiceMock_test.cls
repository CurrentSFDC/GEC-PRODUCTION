/**
Test Class for Webservice  
Murugan 

**/

@isTest
global class GE_LGT_EM_433_WebServiceMock_test implements WebServiceMock {
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
 
    gelightingComCom433Crdbmemorequest.RecordSet_element RecordSet1 = new gelightingComCom433Crdbmemorequest.RecordSet_element();
    list<gelightingComCom433Crdbmemorequest.RecordSet_element>listresponse=new list<gelightingComCom433Crdbmemorequest.RecordSet_element>();
    gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest response_x;
    Map<String, gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest> response_map_x = new Map<String, gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest>();
    gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest request_x = new gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest();
    list<gelightingComCom433Crdbmemorequest.RecordSet_element>listresponse1=new list<gelightingComCom433Crdbmemorequest.RecordSet_element>(); 
    RecordSet1.ComplaintNumber='test data';
    RecordSet1.ComplaintLineItemNo='test data';
    RecordSet1.SAPInvoiceNumber='test data';
    RecordSet1.SAPInvoiceLineItemNo='test data';
    RecordSet1.ManualInvoiceNo='321455';
    listresponse.add(RecordSet1);
    request_x.RecordSet=listresponse;
   
    response.put('response_x',request_x);
    
   }
}