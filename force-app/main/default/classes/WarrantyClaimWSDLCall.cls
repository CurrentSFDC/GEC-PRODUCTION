public class WarrantyClaimWSDLCall {

@future(callout=true) 
public static void getOrderDtl(ID disp1){
    
    Dispute_Request__c disp =[select id,Case__c,Original_Order__c,Discrepancy_Total__c,Customer_PO__c,Sold_To__c from Dispute_Request__c where ID=:disp1 Limit 1];
   	Case caseDet = [Select ID,CaseNumber,eLight_Requestor_Name__c,Requestor_Email__c,Comments,SAP_Customer_Number__c,Sold_To_Account__c,AccountId,Account.Account_Group__c,eLight_Reason_for_Return__c,eLight_Address_2__c,Site_Contact_Name__c from Case where ID=:disp.Case__c Limit 1];
    List<Shipment_Detail__c> casePro = new List<Shipment_Detail__c>([Select ID,SAP_Material__c,Discrepancy_Qty__c,Install_Date__c,Installed_Qty__c,Non_Finished_Good_SKU__c from Shipment_Detail__c where Dispute_Request__c=:disp.Id AND Approved__c = true]);
    Account accDet = [Select GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Distribution_Channel__c,GE_LGT_EM_Division__c from Account where ID=:caseDet.AccountId Limit 1];
    if(disp.Original_Order__c!=null){
    	Order ord = [Select ID,Sold_To__c,Agent_rep_code__c,ShipToName__c,ShippingAddress,ShipToStreet2__c,Type,OrderNumber,Order_Req_Delivery_Date__c from Order where ID=:disp.Original_Order__c Limit 1];
    }
    //Case__c retReas = [ SELECT Return_Code__c FROM Case__c where Name=:caseDet.eLight_Reason_for_Return__c Limit 1];

     //Sold to check starts here
     	String sold_to_new='';
    	if(disp.Sold_To__c != Null){
         Account acc= [Select GE_LGT_EM_SAP_Customer_Number__c from Account where Id=:disp.Sold_To__c];
    		  sold_to_new = acc.GE_LGT_EM_SAP_Customer_Number__c;      
    	}
    
      DateTime todaysDate = System.today();
      String todaysDateStr = todaysDate.format('yyyyMMdd');
      //DateTime InstDate = casePro.Install_Date__c;
      //String InsDate = InstDate.format('yyyy-MM-dd');
    
    
    
    //Setting up the header data by creating the header object
    sapComDocumentSapRfcFunctionsWC2.x_xGEL_xSFB2B_ST_GCRS_HEADER IS_HEADER = new sapComDocumentSapRfcFunctionsWC2.x_xGEL_xSFB2B_ST_GCRS_HEADER();
    //List<sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER> head = new List <sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER>();
   // sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER head1 = new sapComDocumentSapRfcFunctionsWC.x_xGEL_xST_GCRS_HYBRIS_HEADER();
    IS_HEADER.PO_NUMBER=disp.Customer_PO__c;
    IS_HEADER.SOLD_TO=sold_to_new;
    IS_HEADER.SHIP_TO=sold_to_new;
    IS_HEADER.VKORG=accDet.GE_LGT_EM_Sales_Org__c;
    IS_HEADER.VTWEG=accDet.GE_LGT_EM_Distribution_Channel__c;
    IS_HEADER.SPART=accDet.GE_LGT_EM_Division__c;
    IS_HEADER.ERDAT=todaysDateStr;
    IS_HEADER.END_USER=caseDet.Site_Contact_Name__c;
    IS_HEADER.SHIP_TO_NAME=caseDet.Site_Contact_Name__c;
    
    //Address split logic start here
    if(caseDet.eLight_Address_2__c != null){
        System.debug('Case Address Entry: '+caseDet.eLight_Address_2__c);
        String[] addr = caseDet.eLight_Address_2__c.split(',');
        if(addr.size()>0){
            String[] newaddr0 = addr[0].split('\n');
            System.debug('First Split: '+newaddr0);
            String[] newaddr= new String[]{};
            String[] newaddr1=new String[]{};
            if(newaddr0.size()>0){
            	IS_HEADER.SHIP_TO_STREET1 = newaddr0[0];
                System.debug('STREET: '+newaddr0[0]);
            }
            if(newaddr0.size()>1){
            	IS_HEADER.SHIP_TO_CITY=newaddr0[1];
                System.debug('CITY: '+newaddr0[1]);
            }
            if(addr.size()>1){
            	newaddr = addr[1].split(' ');
            }
            if(newaddr.size()>1){
            	IS_HEADER.SHIP_TO_STATE = newaddr[1];
            }
            if(newaddr.size()>3){
            	newaddr1 = newaddr[3].split('\n');
            }
            else{
                 newaddr1 = newaddr[newaddr.size()-1].split('\n');
            }
            if(newaddr1.size()>0){
            	IS_HEADER.SHIP_TO_ZIP = newaddr1[0];
            }
            if(newaddr1.size()>1){
            	IS_HEADER.SHIP_TO_COUNTRY = newaddr1[1];
            }    
          }  
    }
    //Address split ends here
    
    IS_HEADER.COMMENTS=caseDet.Comments;
    IS_HEADER.BSARK = 'CONN';
    IS_HEADER.USER_NAME=caseDet.eLight_Requestor_Name__c;
    IS_HEADER.USER_EMAIL=caseDet.Requestor_Email__c;
    IS_HEADER.ANALYSIS_FLAG='2';
    IS_HEADER.SAFETY_ISSUE_FL='N';
    if(caseDet.Account.Account_Group__c == 'ZEAG'){
        IS_HEADER.I_EXT_AGENT = caseDet.SAP_Customer_Number__c;
    } else {
        IS_HEADER.I_EXT_AGENT = ''; 
    }
    System.debug('Setting EXT AGENT: '+caseDet.SAP_Customer_Number__c);
    
    //Setting up the Item data by creating the header object
     sapComDocumentSapRfcFunctionsWC2.IT_ITEM_element IT_ITEM = new sapComDocumentSapRfcFunctionsWC2.IT_ITEM_element();
     List <sapComDocumentSapRfcFunctionsWC2.x_xGEL_xST_GCRS_HYBRIS_ITEM> ret = new List <sapComDocumentSapRfcFunctionsWC2.x_xGEL_xST_GCRS_HYBRIS_ITEM>();
    for(integer i=0; i<casePro.size();i++){
     sapComDocumentSapRfcFunctionsWC2.x_xGEL_xST_GCRS_HYBRIS_ITEM ret1= new sapComDocumentSapRfcFunctionsWC2.x_xGEL_xST_GCRS_HYBRIS_ITEM();   
		DateTime InstDate = casePro[i].Install_Date__c;
        String InsDate = InstDate.format('yyyyMMdd');
        ret1.POSNR=String.valueOf(i*10+10);
        if(casePro[i].Non_Finished_Good_SKU__c!=null){
			ret1.MATNR=casePro[i].Non_Finished_Good_SKU__c;
        }
        else{
            ret1.MATNR=casePro[i].SAP_Material__c;
        }
    	ret1.KWMENG=String.valueOf(casePro[i].Discrepancy_Qty__c);
    	ret1.INSTL_QTY=Integer.valueOf(casePro[i].Installed_Qty__c);
    	ret1.FAIL_QTY=Integer.valueOf(casePro[i].Discrepancy_Qty__c);
    	ret1.COMPLNT1_CD='1';
    	ret1.COMPLNT2_CD='5';
    	ret1.INSTL_DAT=InsDate;
    	ret.add(ret1);
    }
    	IT_ITEM.item=ret;
    
    
    sapComDocumentSapRfcFunctionsWC2.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element response_x = new sapComDocumentSapRfcFunctionsWC2.x_xGEL_xSFB2B_GCRS_ORDER_CREATE_Response_element();
    
     gecurrentComCom1084WarrantyclaimWC2 apcall = new gecurrentComCom1084WarrantyclaimWC2();
     Blob headerValue = Blob.valueOf('' + ':' + ''); 
            
   	gecurrentComCom1084WarrantyclaimWC2.HTTPS_Port wsdl = new gecurrentComCom1084WarrantyclaimWC2.HTTPS_Port();
            
    wsdl.inputHttpHeaders_x=new Map<String,String>();
    wsdl.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
    wsdl.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
    //wsdl.inputHttpHeaders_x.put('Host', 'genesisq3.gecurrent.com');
    wsdl.endpoint_x = 'callout:SAP_SOAP/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_WarrantyClaim_1084_OB_SYNC&interfaceNamespace=urn:gecurrent.com:COM_1084:WarrantyClaim';
           	

   wsdl.timeout_x=120000;
    system.debug('IS_HEADER: '+IS_HEADER);
    system.debug('IT_ITEM: '+IT_ITEM);

    
     try{           
        	response_x= wsdl.SI_SFB2B_WarrantyClaim_1084_OB_SYNC(IS_HEADER, IT_ITEM);
            system.debug(response_x);  
  
        } catch (Exception e){
            System.debug('gg8****' + e.getMessage());
            
        }
    
      Dispute_Request__c dispute=new Dispute_Request__c(ID=disp1); 
      system.debug(response_x.EV_ORDER_NUMBER);
      dispute.Order__c = string.valueOf(response_x.EV_ORDER_NUMBER);
      dispute.SAP_Message__c = string.valueOf(response_x.EV_ERROR_MESSAGE);

      RecursiveTriggerHandler.isFirstTime = false;
      update dispute;
}

}