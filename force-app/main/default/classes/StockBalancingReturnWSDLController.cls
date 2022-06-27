/**
 * Created by PA on 2021. 07. 19..
 */

public with sharing class StockBalancingReturnWSDLController {
    @Future(callout=true)
    public static void createOrderInSAP(Id disputeReqId){
        List<Dispute_Request__c> disputeRequestQueryResult =[ SELECT Case__c,
                Discrepancy_Total__c,
                Customer_PO__c,
                SAP_Doc_Type__c,
                Case__r.eLight_Comments__c,
                Case__r.SAP_Customer_Number__c,
                Case__r.GE_NAS_Sub_Type__c,
                Case__r.Account.GE_LGT_Rep_Code__c,
                Case__r.Sold_To_Account__c,
                Case__r.Sold_To_Account__r.GE_LGT_EM_Division__c,
                Case__r.Sold_To_Account__r.GE_LGT_EM_Distribution_Channel__c,
                Case__r.Sold_To_Account__r.GE_LGT_EM_Sales_Org__c,
                Case__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
                Case__r.GE_NAS_Purchase_Order__c,
                Case__r.eLight_Reason_for_Return__c,
                Case__r.SuppliedEmail,
                Case__r.SuppliedPhone,
        (SELECT SAP_Material__c,
                Invoiced_Price__c,
                Rep_Code__c,
                Discrepancy_Qty__c,
                GE_NAS_Unit_of_Measure1__c,
                CurrencyIsoCode
        FROM Case_Products__r)
        FROM Dispute_Request__c
        WHERE Id = :disputeReqId];

        if (disputeRequestQueryResult.isEmpty()) {return;}

        COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_Response_element response_x = new COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_CREATE_Response_element();

        COM485_SFB2B_ReturnCreate.HTTPS_Port wsdl = new COM485_SFB2B_ReturnCreate.HTTPS_Port();

        String endpointURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SAP_SOAP'].Endpoint.removeStart('https://');

        wsdl.inputHttpHeaders_x=new Map<String,String>();
        wsdl.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        wsdl.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
        wsdl.inputHttpHeaders_x.put('Host', endpointURL);
        wsdl.timeout_x=120000;

        COM485_SFB2B_ReturnCreate.AttributeElement paramToPassSAP = getAttributes(disputeRequestQueryResult[0]);
        try{
            response_x = wsdl.SI_SFB2B_ReturnsCreate_485_OB_SYNC(paramToPassSAP);
        } catch (Exception e){
            System.debug('Error in ReturnsCreate_485 integration:' + e.getStackTraceString());
            System.debug(e.getMessage());
        }
        Dispute_Request__c dispute=new Dispute_Request__c(ID=disputeRequestQueryResult[0].Id);
        system.debug(response_x.E_SALES_ORDER);
        system.debug(response_x.E_ERR_MESSAGE);
        dispute.Order__c = string.valueOf(response_x.E_SALES_ORDER);
        RecursiveTriggerHandler.isFirstTime = false;
        update dispute;
    }

    private static COM485_SFB2B_ReturnCreate.attributeElement getAttributes(Dispute_Request__c disputeRequest){
        COM485_SFB2B_ReturnCreate.attributeElement param = new COM485_SFB2B_ReturnCreate.attributeElement();
        String returnReason = disputeRequest.Case__r.GE_NAS_Sub_Type__c == 'Quick Stock Return' ? 'L10' : 'L09';

        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');

        //set Base Data
        param.I_BILL_BLOCK = '';
        param.I_CUSTOMER = disputeRequest.Case__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
        param.I_DELIVERY_BLOCK = '';
        param.I_DIST_CHANNEL = disputeRequest.Case__r.Sold_To_Account__r.GE_LGT_EM_Distribution_Channel__c;
        param.I_DIVISION = disputeRequest.Case__r.Sold_To_Account__r.GE_LGT_EM_Division__c;
        param.I_EXT_AGENT = '';
        param.I_HEAD_COMMENTS = disputeRequest.Case__r.eLight_Comments__c;
        param.I_INT_REP = '';
        param.I_INV_NUMBER = '';
        param.I_ORDER_REASON = returnReason;
        param.I_ORDER_TYPE = disputeRequest.SAP_Doc_Type__c;
        param.I_PO_NUM = disputeRequest.Case__r.GE_NAS_Purchase_Order__c;
        param.I_REF_DOC_NUMBER = '';
        param.I_REQ_DATE = todaysDateStr;
        param.I_REQ_FOR_REPLACMENT = '';
        param.I_SALES_ORG = disputeRequest.Case__r.Sold_To_Account__r.GE_LGT_EM_Sales_Org__c;
        param.I_SFDC_CASE_NUMBER = disputeRequest.Case__c;
        param.I_SHIPTO_ADDRESS1 = '';
        param.I_SHIPTO_ADDRESS2 = '';
        param.I_SHIPTO_CITY = '';
        param.I_SHIPTO_COUNTRY = '';
        param.I_SHIPTO_NAME = '';
        param.I_SHIPTO_POSTALCODE = '';
        param.I_SHIPTO_STATE = '';
        param.I_SHIP_TO = '';
        param.I_USER_TYPE = 'REGISTERED';

        param.IT_HEAD_COMMENTS = new COM485_SFB2B_ReturnCreate.IT_HEAD_COMMENTS_element();
        param.IT_ITEM_COMMENTS = new COM485_SFB2B_ReturnCreate.IT_ITEM_COMMENTS_element();

        //Add Products
        COM485_SFB2B_ReturnCreate.IT_RETURN_ITEMS_element prodListElement = new COM485_SFB2B_ReturnCreate.IT_RETURN_ITEMS_element();
        List<COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_ITEM> prodList = new List<COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_ITEM>();
        Integer i = 10;
        for(Shipment_Detail__c caseProd : disputeRequest.Case_Products__r){
            COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_ITEM newProd = new COM485_SFB2B_ReturnCreate.x_xGEL_xSFB2B_RETURN_ITEM();
            newProd.ITEM_NUMBER = String.valueOf(i);
            if(caseProd.SAP_Material__c.isNumeric()){
                newProd.PART_NUMBER = '0'.repeat(18-caseProd.SAP_Material__c.length()) + caseProd.SAP_Material__c;
            } else {
                newProd.PART_NUMBER = caseProd.SAP_Material__c;
            }

            newProd.QUANTITY = String.valueOf(caseProd.Discrepancy_Qty__c);
            newProd.REQ_PRICE = String.valueOf(caseProd.Invoiced_Price__c);
            newProd.UOM = caseProd.GE_NAS_Unit_of_Measure1__c;
            newProd.CURRENCY_x  = caseProd.CurrencyIsoCode;
            newProd.ITEM_COMMENTS  = '';
            newProd.AGENT = caseProd.Rep_Code__c;
            prodList.add(newProd);
            i += 10;
        }
        prodListElement.item = prodList;
        param.IT_RETURN_ITEMS = prodListElement;
        System.debug(param);
        return param;
    }
}