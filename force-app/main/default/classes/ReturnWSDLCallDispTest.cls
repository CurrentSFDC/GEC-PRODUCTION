@isTest
private with sharing class ReturnWSDLCallDispTest {
    
    @isTest
    private static void getOrderDtlTest(){
        Test.startTest();
        Account acc = new Account();
        acc.name = 'acc54321';
        insert acc;
        
		Case ca = new Case();
        ca.Comments = 'TEST';
       // ca.SAP_Customer_Number__c = '';
        ca.Sold_To_Account__c = ca.Id;
        ca.eLight_Reason_for_Return__c = 'Customer Error';
        insert ca;
        //
        //
        //
        	AdminOverride__c adminOverride = new AdminOverride__c();
        adminOverride.Switch_Off_Trigger__c = TRUE;
        insert adminOverride;
        
        Order ord1 = new Order();
        ord1.Name = 'Test Order'; 
        ord1.AccountId = acc.id;
        
        ord1.Sold_To__c = acc.id;
       // ord1.Agent_rep_code__c = '';
        ord1.ShipToName__c = 'abc';
        ord1.ShippingCity = 'abc';
        ord1.ShippingCountry = 'test';
        ord1.ShippingState = 'test';
        ord1.ShippingStreet = 'test';
        //ord1.ShippingAddress = '';
        ord1.ShipToStreet2__c = 'def';
        ord1.Type = 'ZOR';
        //ord.OrderNumber = '';
        ord1.Order_Req_Delivery_Date__c = date.today();
        ord1.EffectiveDate = date.today();
        ord1.Status = 'Draft';
        insert ord1;
        
        ord1.Name = 'order test 54';
        update ord1;
      
       // List<Dispute_Request__c> drList = new List<Dispute_Request__c>();
        Dispute_Request__c dr = new Dispute_Request__c();
        dr.Case__c = ca.Id;
        dr.Original_Order__c = ord1.id;
        dr.Customer_PO__c = 'PO44';
        dr.Discrepancy_Total__c = 990;
       // drList.add(dr);
        insert dr; 

        
        Shipment_Detail__c sd = new Shipment_Detail__c();
       // sd.SAP_Material__c = '';
        sd.Discrepancy_Qty__c = 9;
        sd.GE_NAS_Case_Number__c = ca.Id;
        sd.Dispute_Request__c = dr.Id;       
         insert sd;
        
		
        Dispute_Request__c dr1 = new Dispute_Request__c();
        insert dr1;
        

        
        
        Account acc1 = new Account();
        acc1.name = 'acc54321';
        acc1.GE_LGT_EM_SAP_Customer_Number__c = ord1.Sold_To__c;
        
        insert acc1;
        
        string sold_to_new;
        sold_to_new = acc1.GE_LGT_EM_SAP_Customer_Number__c;
        
        
       
    	Dispute_Request__c disp =[select id,Case__c,Original_Order__c,Discrepancy_Total__c,Customer_PO__c from Dispute_Request__c where ID=:dr.Id Limit 1];
        System.debug('disp@@@@@@@@@@'+disp);
        Case caseDet = [Select ID,Comments,SAP_Customer_Number__c,Sold_To_Account__c,eLight_Reason_for_Return__c from Case where ID=:disp.Case__c Limit 1];
		System.debug('caseDet@@@@@@@@@@'+caseDet);
        Shipment_Detail__c casePro = [Select ID,SAP_Material__c,Discrepancy_Qty__c from Shipment_Detail__c where Dispute_Request__c=:dr.Id Limit 1];
		System.debug('casePro@@@@@@@@@@'+casePro);
        
        Case__c cac = new Case__c();
        cac.Return_Code__c = 'Test';
        cac.Name = caseDet.eLight_Reason_for_Return__c;
        insert cac;
        
        Case__c retReas = [ SELECT Return_Code__c FROM Case__c where Name=:caseDet.eLight_Reason_for_Return__c and id=: cac.Id Limit 1];
        system.debug('retReas**********'+retReas);
        
     
      DateTime todaysDate = System.today();
      String todaysDateStr = todaysDate.format('yyyy-MM-dd');
      //system.debug(caseDet);
           String I_BILL_BLOCK='';
            String I_DIST_CHANNEL='';
           String I_DIVISION='';
           String I_EXT_AGENT='';
           if(disp.Original_Order__c !=Null){
        	 Order ord = [Select ID,Agent_rep_code__c from Order where ID=:disp.Original_Order__c Limit 1];
         	 I_EXT_AGENT=ord.Agent_rep_code__c;
           } 
        String I_HEAD_COMMENTS=caseDet.Comments;
            String I_INT_REP='';
           String I_INV_NUMBER='';
           String I_RBLOCK='';
           if(caseDet.Comments != Null){
              I_RBLOCK='01';
           }
        String I_REF_DOC_NUMBER='';
          String I_REQ_FOR_REPLACMENT='N';
           String I_RETURN_PO_NUMBER= disp.Customer_PO__c;
           //String I_RETURN_REASON=retReas.Return_Code__c;
         //  String I_RETURN_REASON='C02';
           String I_RETURN_REQ_DATE=todaysDateStr;
            String I_SALES_ORG='';
			String I_SFDC_CASE_NUMBER=String.valueOf(disp.Case__c);
           String I_SHIPTO_ADDRESS1='';
            String I_SHIPTO_ADDRESS2='';
           String I_SHIPTO_CITY='';
           String I_SHIPTO_COUNTRY='';
           String I_SHIPTO_NAME='';
           String I_SHIPTO_POSTALCODE='';
           String I_SHIPTO_STATE='';
           String I_SHIP_TO='';
           //String I_SOLD_TO='0000881000';
            String I_SOLD_TO=caseDet.SAP_Customer_Number__c;
            String I_USER_ROLE='REGISTERED';
           // String IT_HEAD_COMMENTS=Null;
           // String IT_ITEM_COMMENTS=Null; 
           // String IT_RETURN_ITEMS=Null;
            
         //  List <gecurrentComCom485Returnscreate.HTTPS_Port> wsdl = new List<gecurrentComCom485Returnscreate.HTTPS_Port>();
    
           sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element IT_ITEM_COMMENTS = new sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element();
           sapComDocumentSapRfcFunctions_DUP.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS = new sapComDocumentSapRfcFunctions_DUP.IT_HEAD_COMMENTS_element();
            
          //   result = wsdl.SI_SFB2B_ReturnsCreate_485_OB_SYNC(I_REQ_FOR_REPLACMENT, I_RETURN_PO_NUMBER, I_RETURN_REASON, I_RETURN_REQ_DATE, I_SFDC_CASE_NUMBER, I_SOLD_TO, I_USER_ROLE);
         
        sapComDocumentSapRfcFunctions_DUP.IT_RETURN_ITEMS_element IT_RETURN_ITEMS = new sapComDocumentSapRfcFunctions_DUP.IT_RETURN_ITEMS_element();
        List <sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM> ret = new List<sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM>();
        sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM ret1 = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xHY_RETURN_ITEM();
             ret1.PART_NUMBER=casePro.SAP_Material__c;
             ret1.QUANTITY= String.valueOf(casePro.Discrepancy_Qty__c);
             ret1.UOM='USD';
             ret1.REQ_PRICE=String.valueOf(disp.Discrepancy_Total__c);
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
        	//response_x= wsdl.SI_SFB2B_ReturnsCreate_485_OB_SYNC(I_BILL_BLOCK, I_DIST_CHANNEL, I_DIVISION, I_EXT_AGENT, I_HEAD_COMMENTS, I_INT_REP, I_INV_NUMBER, I_RBLOCK, I_REF_DOC_NUMBER, I_REQ_FOR_REPLACMENT, I_RETURN_PO_NUMBER, I_RETURN_REASON, I_RETURN_REQ_DATE, I_SALES_ORG, I_SFDC_CASE_NUMBER, I_SHIPTO_ADDRESS1, I_SHIPTO_ADDRESS2, I_SHIPTO_CITY, I_SHIPTO_COUNTRY, I_SHIPTO_NAME, I_SHIPTO_POSTALCODE, I_SHIPTO_STATE, I_SHIP_TO, I_SOLD_TO, I_USER_ROLE,IT_HEAD_COMMENTS,IT_ITEM_COMMENTS,IT_RETURN_ITEMS);
               
  
        } catch (Exception e){
            System.debug('gg8****' + e.getMessage());
            
        }   
        
      Dispute_Request__c dispute=new Dispute_Request__c(ID=dr.Id); 
      system.debug(response_x.E_SALES_ORDER);
      dispute.Order__c = string.valueOf(response_x.E_SALES_ORDER);
      RecursiveTriggerHandler.isFirstTime = false;
      update dispute;
        
        
        ReturnWSDLCallDisp.getOrderDtl(dr.Id);
        invocableReturnWSDLCall.methodInputs argument;
        argument = new invocableReturnWSDLCall.methodInputs();
        argument.disID = dr.Id;
        System.debug('disID is '+dr.Id);
        invocableReturnWSDLCall.callReturnWSDL(new List<invocableReturnWSDLCall.methodInputs>{argument});
        Test.stopTest();

    }


}