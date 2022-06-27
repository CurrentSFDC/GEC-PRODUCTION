public class ReplaceWSDLCallDisp {
    @future(callout=true) 
    public static void getOrderDtlreplace(ID disp1){
        Dispute_Request__c disp =[select id,Case__c,Original_Order__c,Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c,Sold_To__r.GE_LGT_EM_Sales_Org__c, Sold_To__c, Discrepancy_Total__c,Customer_PO__c,SAP_Doc_Type__c from Dispute_Request__c where ID=:disp1 Limit 1];
        Case caseDet = [Select ID,Comments,SAP_Customer_Number__c,Sold_To_Account__c,eLight_Reason_for_Return__c,ContactId,AccountID  from Case where ID=:disp.Case__c Limit 1];
        List<Shipment_Detail__c> casePro = [Select ID,SAP_Material__c,Discrepancy_Qty__c,GE_NAS_Product_Code__c,GE_NAS_Unit_of_Measure__c,Discrepancy_Total__c,Invoiced_Price__c from Shipment_Detail__c where Dispute_Request__c=:disp.Id];
        Account accDet = [Select GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Distribution_Channel__c,GE_LGT_EM_Division__c,GE_LGT_EM_Sales_Org__c from Account where ID=:disp.Sold_To__c Limit 1];
        Order ord = [Select ID,Sold_To__c,Agent_rep_code__c,ShipToName__c,ShippingAddress,ShipToStreet2__c,Type,OrderNumber,Order_Req_Delivery_Date__c from Order where ID=:disp.Original_Order__c Limit 1];
        Contact con = [SELECT id,Email,Phone,Name,FirstName,LastName FROM Contact where ID=:caseDet.ContactId Limit 1];
		       
        //Case__c retReas = [ SELECT Return_Code__c FROM Case__c where Name=:caseDet.eLight_Reason_for_Return__c Limit 1];
        
        Address ad=ord.ShippingAddress;
        
        //Sold to check starts here
      String sold_to_new = disp.Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c;
      System.debug('Sending Sold To: '+sold_to_new);

      String sales_org = disp.Sold_To__r.GE_LGT_EM_Sales_Org__c;
      System.debug('Sending Sales Org: '+sales_org);
     	/*String sold_to_new='';
    	if(ord1.Sold_To__c != Null){
         Account acc1= [Select GE_LGT_EM_SAP_Customer_Number__c from Account where Id=:ord1.Sold_To__c];
    		  sold_to_new = acc1.GE_LGT_EM_SAP_Customer_Number__c;      
           
    	}*/
        
        gecurrentComCom472OrdercreateN3.GEOrderInfoWrapper ordInfWrap= new  gecurrentComCom472OrdercreateN3.GEOrderInfoWrapper();
        
        //ordInfWrap.I_AGENT_CODE='DT5';
		ordInfWrap.I_AGENT_CODE=caseDet.SAP_Customer_Number__c;
		ordInfWrap.I_AGREEMENT='';
        ordInfWrap.I_BACK_ORDER_FLAG='';
        ordInfWrap.I_CARRIER_ACCOUNT='';
        //ordInfWrap.I_CONTACT_EMAIL='';
        ordInfWrap.I_CONTACT_EMAIL=con.Email;
		//ordInfWrap.I_CONTACT_PHONE='';
		ordInfWrap.I_CONTACT_PHONE=con.Phone;
        //ordInfWrap.I_CUSTOMER='DT5';
        ordInfWrap.I_CUSTOMER=sold_to_new;
        //ordInfWrap.I_CUSTOMER_CONTACT='abc';
        ordInfWrap.I_CUSTOMER_CONTACT=con.Name;
        //ordInfWrap.I_DELIVERY_BLOCK='Z3';
        ordInfWrap.I_DELIVERY_BLOCK='';
        //ordInfWrap.I_DIST_CHENNEL='';
        ordInfWrap.I_DIST_CHENNEL=accDet.GE_LGT_EM_Distribution_Channel__c;
        //ordInfWrap.I_DIVISION='10';
        ordInfWrap.I_DIVISION=accDet.GE_LGT_EM_Division__c;
        //ordInfWrap.I_EMAIL_ADDRESS='';
        ordInfWrap.I_EMAIL_ADDRESS=con.Email;
        ordInfWrap.I_HEADER_TEXT='';
        //ordInfWrap.I_ORDER_FLAG='Y';
        ordInfWrap.I_ORDER_FLAG='';
        ordInfWrap.I_ORDER_NUMBER='';
        //ordInfWrap.I_ORDER_NUMBER=ord.OrderNumber;
        //ordInfWrap.I_ORDER_REASON='To Test';
        ordInfWrap.I_ORDER_REASON='';
        //ordInfWrap.I_ORDER_TYPE='ZSAM';
        ordInfWrap.I_ORDER_TYPE=disp.SAP_Doc_Type__c;
        //ordInfWrap.I_PARTIAL_SHIP='N';
        ordInfWrap.I_PARTIAL_SHIP='';
        //ordInfWrap.I_PO_NUM='PO1899';
        ordInfWrap.I_PO_NUM=disp.Customer_PO__c;
        ordInfWrap.I_PROJECT_NAME='';
        //ordInfWrap.I_REQ_DATE='2021-01-09';
        //ordInfWrap.I_REQ_DATE=String.valueof(ord.Order_Req_Delivery_Date__c);
        //ordInfWrap.I_SALES_ORG='1US1';
        ordInfWrap.I_SALES_ORG=accDet.GE_LGT_EM_Sales_Org__c;
        ordInfWrap.I_SERIAL_NUMBER='';
        //ordInfWrap.I_SFDC_CASE_NUMBER='';
        ordInfWrap.I_SFDC_CASE_NUMBER=String.valueOf(disp.Case__c);
        ordInfWrap.I_SHIPMENT_TYPE='';
        //ordInfWrap.I_SHIPTO_ADDRESS1='9 Appold Street';
        ordInfWrap.I_SHIPTO_ADDRESS1=ad.getStreet();
        //ordInfWrap.I_SHIPTO_ADDRESS2='';
        //ordInfWrap.I_SHIPTO_ADDRESS2=ord.ShipToStreet2__c;
        //ordInfWrap.I_SHIPTO_CITY='Florida';
        ordInfWrap.I_SHIPTO_CITY=ad.getCity();
        //ordInfWrap.I_SHIPTO_COUNTRY='USA';
        ordInfWrap.I_SHIPTO_COUNTRY=ad.getCountry();
        //ordInfWrap.I_SHIPTO_NAME='abc';
        ordInfWrap.I_SHIPTO_NAME=ord.ShipToName__c;
        //ordInfWrap.I_SHIPTO_POSTALCODE='32104';
        ordInfWrap.I_SHIPTO_POSTALCODE=ad.getPostalCode();
        ordInfWrap.I_SHIPTO_STATE=ad.getState();
        //ordInfWrap.I_SHIPTO_STATE=ad.getState();
        //ordInfWrap.I_SHIP_CONTACT_NAME='abc';
        ordInfWrap.I_SHIP_CONTACT_NAME=con.FirstName+con.LastName;
        ordInfWrap.I_SHIP_CONTACT_NUMBER='';
        ordInfWrap.I_SHIP_INSTRUCTION='';
        //ordInfWrap.I_SHIP_TO='DT5';
        ordInfWrap.I_SHIP_TO=sold_to_new;
        ordInfWrap.I_SHIP_VIA='';
        ordInfWrap.I_STRATEGIC_ACC='';
        ordInfWrap.I_USER_TYPE='Agent';
        
        sapComDocumentSapRfcFunctions.ET_ITEMOUT_element ET_ITEMOUT1 =new sapComDocumentSapRfcFunctions.ET_ITEMOUT_element();
        sapComDocumentSapRfcFunctions.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS1 =new sapComDocumentSapRfcFunctions.IT_HEAD_COMMENTS_element();
        sapComDocumentSapRfcFunctions.IT_HEAD_SHIP_INSTRU_element IT_HEAD_SHIP_INSTRU1 =new sapComDocumentSapRfcFunctions.IT_HEAD_SHIP_INSTRU_element();
        sapComDocumentSapRfcFunctions.IT_ITEMIN_element IT_ITEMIN1 =new sapComDocumentSapRfcFunctions.IT_ITEMIN_element();
        sapComDocumentSapRfcFunctions.IT_ITEM_COMMENTS_element IT_ITEM_COMMENTS1 =new sapComDocumentSapRfcFunctions.IT_ITEM_COMMENTS_element();
        
        
        
        List <sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_ITEM> rep = new List<sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_ITEM>();
       
        //rep1.ITEM='10';
        for (integer i=0; i<casePro.size();i++){
            
             sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_ITEM rep1 = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_ITEM();
        //ccrz__E_Product__c prod= [SELECT id,MaterialDescription__c FROM ccrz__E_Product__c where ccrz__SKU__c=:cp.SAP_Material__c Limit 1]; 
        
        rep1.ITEM=String.valueOf(i*10+10);
        //rep1.PART_NUMBER='93104290';
        rep1.PART_NUMBER=casePro[i].SAP_Material__c;
        //rep1.QUANTITY= '2';
        rep1.QUANTITY=String.valueOf(casePro[i].Discrepancy_Qty__c);
        //rep1.UOM='USD';
        rep1.UOM=casePro[i].GE_NAS_Unit_of_Measure__c;
        rep1.PRICE=String.valueOf(casePro[i].Invoiced_Price__c);
        //rep1.PRICE=String.valueOf(cp.Discrepancy_Total__c);
        //rep1.DESCRIPTION='ABV3048T585CQVSTKQW';
        rep1.DESCRIPTION=casePro[i].GE_NAS_Product_Code__c;
        rep.add(rep1);   
        }
        system.debug(rep);
        IT_ITEMIN1.item=rep;
        
        ordInfWrap.ET_ITEMOUT=ET_ITEMOUT1;
        ordInfWrap.IT_HEAD_COMMENTS=IT_HEAD_COMMENTS1;
        ordInfWrap.IT_HEAD_SHIP_INSTRU=IT_HEAD_SHIP_INSTRU1;
        ordInfWrap.IT_ITEMIN=IT_ITEMIN1;
        ordInfWrap.IT_ITEM_COMMENTS=IT_ITEM_COMMENTS1;
        
        /*sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element IT_ITEM_COMMENTS = new sapComDocumentSapRfcFunctions_DUP.IT_ITEM_COMMENTS_element();
sapComDocumentSapRfcFunctions_DUP.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS = new sapComDocumentSapRfcFunctions_DUP.IT_HEAD_COMMENTS_element();

//   result = wsdl.SI_SFB2B_ReturnsCreate_485_OB_SYNC(I_REQ_FOR_REPLACMENT, I_RETURN_PO_NUMBER, I_RETURN_REASON, I_RETURN_REQ_DATE, I_SFDC_CASE_NUMBER, I_SOLD_TO, I_USER_ROLE);

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
Blob headerValue = Blob.valueOf('' + ':' + ''); &*/
        //sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element response_x = new sapComDocumentSapRfcFunctions_DUP.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element();
        sapComDocumentSapRfcFunctions.x_xGEL_xSFB2B_ORDER_CREATE_Response_element response_x =new sapComDocumentSapRfcFunctions.x_xGEL_xSFB2B_ORDER_CREATE_Response_element();
        gecurrentComCom472OrdercreateN3.HTTPS_Port wsdl = new gecurrentComCom472OrdercreateN3.HTTPS_Port();
        
        wsdl.inputHttpHeaders_x=new Map<String,String>();
        wsdl.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        wsdl.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
        //wsdl.inputHttpHeaders_x.put('Host', 'genesisq3.gecurrent.com');
        wsdl.endpoint_x = 'callout:SAP_SOAP/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_OrderCreate_472_OB_SYNC_N3&interfaceNamespace=urn:gecurrent.com:COM_472:OrderCreate_N3';
        
        
        wsdl.timeout_x=120000;
        
        try{         
            
            response_x= wsdl.SI_SFB2B_OrderCreate_472_OB_SYNC_N3(ordInfWrap);
            
            
        } catch (Exception e){
            System.debug('gg8****' + e.getMessage());
            
        }   
        
      Dispute_Request__c dispute=new Dispute_Request__c(ID=disp1); 
      system.debug(response_x.E_SALES_NUMBER);
      dispute.Order__c = string.valueOf(response_x.E_SALES_NUMBER);
      RecursiveTriggerHandler.isFirstTime = false;
      update dispute;
    }
}