public class ReturnWSDLCallDisp {
    @future(callout=true) 
public static void getOrderDtl(ID disp1){
     Dispute_Request__c disp =[select id,Invoice__c,Case__c,Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c,Sold_To__r.GE_LGT_EM_Sales_Org__c, Original_Order__c,Discrepancy_Total__c,Customer_PO__c FROM Dispute_Request__c WHERE Id=:disp1 Limit 1];
     Case caseDet = [Select ID,Comments,SAP_Customer_Number__c,Sold_To_Account__c,eLight_Reason_for_Return__c from Case where ID=:disp.Case__c Limit 1];
     List <Shipment_Detail__c> casePro = [Select ID,SAP_Material__c,Price_Agreement__c,Invoiced_Price__c,Discrepancy_Qty__c,GE_NAS_Product_Code__c,GE_NAS_Unit_of_Measure__c from Shipment_Detail__c where Dispute_Request__c=:disp.Id AND Approved__c = true];
     Order ord1 = [Select ID,Sold_To__c,Agent_rep_code__c,ShipToName__c,ShippingAddress,ShipToStreet2__c,Type,OrderNumber,Order_Req_Delivery_Date__c from Order where ID=:disp.Original_Order__c Limit 1];
    //Account accDet = [Select GE_LGT_EM_SAP_Customer_Number__c from Account where ID=:caseDet.Sold_To_Account__c Limit 1];

    Address ad=ord1.ShippingAddress;
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
    
    // Case__c retReas = [ SELECT Return_Code__c FROM Case__c where Name=:caseDet.eLight_Reason_for_Return__c Limit 1];

     
      DateTime todaysDate = System.today();
      String todaysDateStr = todaysDate.format('yyyy-MM-dd');
      //system.debug(caseDet);
           String I_BILL_BLOCK='';
            String I_DIST_CHANNEL='';
           String I_DIVISION='';
           String I_EXT_AGENT='';
           if(disp.Original_Order__c !=Null){
        	 Order ord = [Select ID,Agent_rep_code__c from Order where ID=:disp.Original_Order__c Limit 1];
            if(ord.Agent_rep_code__c != null){
              I_EXT_AGENT=ord.Agent_rep_code__c;
            } else {
              I_EXT_AGENT = '';
            }
           } 
   		   
           String I_HEAD_COMMENTS=caseDet.Comments;
            String I_INT_REP='';
           String I_INV_NUMBER=disp.Invoice__c;
           String I_RBLOCK='';
           if(caseDet.Comments != Null){
              I_RBLOCK='01';
           }
   
           String I_REF_DOC_NUMBER='';
          String I_REQ_FOR_REPLACMENT='N';
           String I_RETURN_PO_NUMBER= disp.Customer_PO__c;
           //String I_RETURN_REASON=retReas.Return_Code__c;
          String I_RETURN_REASON='C02';
           String I_RETURN_REQ_DATE=todaysDateStr;
            String I_SALES_ORG=sales_org;
			    String I_SFDC_CASE_NUMBER=String.valueOf(disp.Case__c);
           //String I_SFDC_CASE_NUMBER='';
           String I_SHIPTO_ADDRESS1='';
            String I_SHIPTO_ADDRESS2='';
           String I_SHIPTO_CITY='';
           String I_SHIPTO_COUNTRY='';
           String I_SHIPTO_NAME='';
           String I_SHIPTO_POSTALCODE='';
           String I_SHIPTO_STATE='';
           String I_SHIP_TO= '';
           //String I_SOLD_TO='0000881000';
            String I_SOLD_TO= sold_to_new;
            String I_USER_ROLE='REGISTERED';
           // String IT_HEAD_COMMENTS=Null;
           // String IT_ITEM_COMMENTS=Null; 
           // String IT_RETURN_ITEMS=Null;
            
         //  List <gecurrentComCom485aReturnrequestUpd.HTTPS_Port> wsdl = new List<gecurrentComCom485aReturnrequestUpd.HTTPS_Port>();
    
           sapComDocumentSapRfcFunctionsUpd.IT_ITEM_COMMENTS_element IT_ITEM_COMMENTS = new sapComDocumentSapRfcFunctionsUpd.IT_ITEM_COMMENTS_element();
           sapComDocumentSapRfcFunctionsUpd.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS = new sapComDocumentSapRfcFunctionsUpd.IT_HEAD_COMMENTS_element();
            
          //   result = wsdl.SI_SFB2B_ReturnsCreate_485_OB_SYNC(I_REQ_FOR_REPLACMENT, I_RETURN_PO_NUMBER, I_RETURN_REASON, I_RETURN_REQ_DATE, I_SFDC_CASE_NUMBER, I_SOLD_TO, I_USER_ROLE);
         
        sapComDocumentSapRfcFunctionsUpd.IT_RETURN_ITEMS_element IT_RETURN_ITEMS = new sapComDocumentSapRfcFunctionsUpd.IT_RETURN_ITEMS_element();
        List <sapComDocumentSapRfcFunctionsUpd.x_xGEL_xHY_RETURN_ITEM> ret = new List<sapComDocumentSapRfcFunctionsUpd.x_xGEL_xHY_RETURN_ITEM>();
        
    for (integer i=0; i<casePro.size();i++){
        sapComDocumentSapRfcFunctionsUpd.x_xGEL_xHY_RETURN_ITEM ret1 = new sapComDocumentSapRfcFunctionsUpd.x_xGEL_xHY_RETURN_ITEM();

        String num = casePro[i].SAP_Material__c;          

          if(num.isNumeric()){
            
            ret1.PART_NUMBER= String.valueOf(num).leftPad(18, '0');
            system.debug('Part Number: '+ret1.PART_NUMBER);
           } else {
             ret1.PART_NUMBER = casePro[i].SAP_Material__c;  
           }


          

    		    //ret1.PART_NUMBER=casePro[i].SAP_Material__c;
             ret1.QUANTITY= String.valueOf(casePro[i].Discrepancy_Qty__c);
             ret1.UOM=casePro[i].GE_NAS_Unit_of_Measure__c;
             //ret1.PRICELIST=casePro[i].Price_Agreement__c;
             ret1.REQ_PRICE=String.valueOf(casePro[i].Invoiced_Price__c);
           	 ret.add(ret1);  
    }
         IT_RETURN_ITEMS.item=ret;
            
        sapComDocumentSapRfcFunctionsUpd.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element response_x = new sapComDocumentSapRfcFunctionsUpd.x_xGEL_xSFB2B_RETURNS_CREATE_Response_element();
            
            
           gecurrentComCom485aReturnrequestUpd apcall = new gecurrentComCom485aReturnrequestUpd();
            Blob headerValue = Blob.valueOf('' + ':' + ''); 
            
            gecurrentComCom485aReturnrequestUpd.HTTPS_Port wsdl = new gecurrentComCom485aReturnrequestUpd.HTTPS_Port();
            
            wsdl.inputHttpHeaders_x=new Map<String,String>();
            wsdl.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        	wsdl.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
        	//wsdl.inputHttpHeaders_x.put('Host', 'genesisq3.gecurrent.com');
           // wsdl.endpoint_x = 'callout:SAP_SOAP/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_ReturnsCreate_485_OB_SYNC&interfaceNamespace=urn:gecurrent.com:COM_485:ReturnsCreate';
           	wsdl.endpoint_x = 'callout:SAP_SOAP/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_ReturnsCreate_485A_OB_SYNC&interfaceNamespace=urn:gecurrent.com:COM_485A:ReturnRequest';

        	wsdl.timeout_x=120000;
            
           try{
          system.debug('EXECUTING WSDL CALL....');  
        	response_x= wsdl.SI_SFB2B_ReturnsCreate_485A_OB_SYNC(I_BILL_BLOCK, I_DIST_CHANNEL, I_DIVISION, I_EXT_AGENT, I_HEAD_COMMENTS, I_INT_REP, I_INV_NUMBER, I_RBLOCK, I_REF_DOC_NUMBER, I_REQ_FOR_REPLACMENT, I_RETURN_PO_NUMBER, I_RETURN_REASON, I_RETURN_REQ_DATE, I_SALES_ORG, I_SFDC_CASE_NUMBER,  I_SHIPTO_ADDRESS1, I_SHIPTO_ADDRESS2, I_SHIPTO_CITY, I_SHIPTO_COUNTRY, I_SHIPTO_NAME, I_SHIPTO_POSTALCODE, I_SHIPTO_STATE, I_SHIP_TO, I_SOLD_TO, I_USER_ROLE,IT_HEAD_COMMENTS,IT_ITEM_COMMENTS,IT_RETURN_ITEMS);
          system.debug('Response from SAP: '+response_x.E_SALES_ORDER);
          system.debug('Error Message from SAP: '+response_x.E_ERR_MESSAGE);
  
        } catch (Exception e){
            System.debug('gg8****' + e.getMessage());
            
        }   
        
      Dispute_Request__c dispute=new Dispute_Request__c(ID=disp1); 
      //system.debug('Response from SAP: '+response_x.E_SALES_ORDER);
      dispute.Order__c = string.valueOf(response_x.E_SALES_ORDER);
      if(response_x.E_ERR_MESSAGE != null){
        dispute.SAP_Message__C = response_x.E_ERR_MESSAGE;
      }
      RecursiveTriggerHandler.isFirstTime = false;
      update dispute;
    //Return response_x.E_SALES_ORDER;
  }

}