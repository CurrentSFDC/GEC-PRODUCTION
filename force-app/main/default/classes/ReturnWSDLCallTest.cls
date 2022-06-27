@isTest
private with sharing class ReturnWSDLCallTest {
    
    /*@isTest
    private static void getOrderDtlTest1(){
            new ReturnWSDLCall.getOrderDtl();
    }*/

    
    @isTest
    private static void getOrderDtlTest(){
        
        
        Case ca = new Case();
        insert ca;
        
        List<Dispute_Request__c> drList = new List<Dispute_Request__c>();
        Dispute_Request__c dr = new Dispute_Request__c();
        dr.Case__c = ca.Id;
        dr.Customer_PO__c = 'PO44';
        dr.Discrepancy_Total__c = 990;
        drList.add(dr);
        insert drList;
        
        List<Dispute_Request__c> disList = [Select Case__c, Customer_PO__c, Discrepancy_Total__c from Dispute_Request__c where Case__c=:dr.Case__c];
        for(Dispute_Request__c dis: disList){
            String I_BILL_BLOCK='';
            String I_DIST_CHANNEL='';
           String I_DIVISION='';
            String I_EXT_AGENT='';
           String I_HEAD_COMMENTS='';
            String I_INT_REP='';
           String I_INV_NUMBER='';
           String I_RBLOCK='';
           String I_REF_DOC_NUMBER='';
          String I_REQ_FOR_REPLACMENT='N';
           String I_RETURN_PO_NUMBER= 'test';
           String I_RETURN_REASON='C02';
           String I_RETURN_REQ_DATE='2020-12-01';
            String I_SALES_ORG='';
			String I_SFDC_CASE_NUMBER= (String) dis.Case__c;
           String I_SHIPTO_ADDRESS1='';
            String I_SHIPTO_ADDRESS2='';
           String I_SHIPTO_CITY='';
           String I_SHIPTO_COUNTRY='';
           String I_SHIPTO_NAME='';
           String I_SHIPTO_POSTALCODE='';
           String I_SHIPTO_STATE='';
           String I_SHIP_TO='';
            String I_SOLD_TO='0000881000';
            
            sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element IT_ITEM_COMMENTS = new sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element();
           sapComDocumentSapRfcFunctions_DUP.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS = new sapComDocumentSapRfcFunctions_DUP.IT_HEAD_COMMENTS_element();
            
            sapComDocumentSapRfcFunctions_DUP.IT_RETURN_ITEMS_element IT_RETURN_ITEMS = new sapComDocumentSapRfcFunctions_DUP.IT_RETURN_ITEMS_element();
        List <sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM> ret = new List<sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM>();
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM ret1 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM();
             ret1.PART_NUMBER='000000000000069117';
             ret1.QUANTITY= '1';
             ret1.UOM='USD';
             ret1.REQ_PRICE='3.00';
           	 ret.add(ret1);      
         IT_RETURN_ITEMS.item=ret;
            
            sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element response_x = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element();
            
            
           gecurrentComCom485Returnscreate apcall = new gecurrentComCom485Returnscreate();
            Blob headerValue = Blob.valueOf('' + ':' + ''); 
            
            gecurrentComCom485Returnscreate.HTTPS_Port wsdl = new gecurrentComCom485Returnscreate.HTTPS_Port();
            
            wsdl.inputHttpHeaders_x=new Map<String,String>();
            wsdl.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        	wsdl.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
        	wsdl.inputHttpHeaders_x.put('Host', 'genesisq1.gecurrent.com');
            wsdl.endpoint_x = 'callout:SAP_SOAP/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_ReturnsCreate_485_OB_SYNC&interfaceNamespace=urn:gecurrent.com:COM_485:ReturnsCreate';
           	

        	wsdl.timeout_x=120000;
            
               try{           
        	// wsdl.SI_SFB2B_ReturnsCreate_485_OB_SYNC(I_BILL_BLOCK, I_DIST_CHANNEL, I_DIVISION, I_EXT_AGENT, I_HEAD_COMMENTS, I_INT_REP, I_INV_NUMBER, I_RBLOCK, I_REF_DOC_NUMBER, I_REQ_FOR_REPLACMENT, I_RETURN_PO_NUMBER, I_RETURN_REASON, I_RETURN_REQ_DATE, I_SALES_ORG, I_SFDC_CASE_NUMBER, I_SHIPTO_ADDRESS1, I_SHIPTO_ADDRESS2, I_SHIPTO_CITY, I_SHIPTO_COUNTRY, I_SHIPTO_NAME, I_SHIPTO_POSTALCODE, I_SHIPTO_STATE, I_SHIP_TO, I_SOLD_TO, I_USER_ROLE,IT_HEAD_COMMENTS,IT_ITEM_COMMENTS,IT_RETURN_ITEMS);
               
  
        } catch (Exception e){
            System.debug('gg8****' + e.getMessage());
            
        }
        }
        Test.startTest();
        ReturnWSDLCall.getOrderDtl(dr.Case__c);
        Test.stopTest();
        
    }


}