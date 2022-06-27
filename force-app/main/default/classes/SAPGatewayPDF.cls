/*---------------------------------------------------------------------------------
Name:       SAPGatewayPDF.cls
Purpose:    Gateway Pattern providing uniform interface into SAP SOAP PDF services. 
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          18-Jan-2021           Initial Development 
---------------------------------------------------------------------------------*/
public class SAPGatewayPDF {
	private Map<String, String> endpointMap {
		get
		{
			Map<String, String> endpointMapGet = new Map<String, String>();
			for(SAP_Service__mdt sap:[SELECT MasterLabel, Endpoint__c FROM SAP_Service__mdt]){
				endpointMapGet.put(sap.MasterLabel,sap.Endpoint__c);
			}
			return endpointMapGet;
		}
		set;
    }
    
    public OrderAckPDFController.Response getOrderAckPDF(OrderAckPDFController.Request request) {
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getOrderAckPDF');		
    
        OrderAckPDFController.Response response = new OrderAckPDFController.Response();
        gecurrentCom750Orderacknowledgeme.HTTPS_Port port = new gecurrentCom750Orderacknowledgeme.HTTPS_Port();
        port.inputHttpHeaders_x=new Map<String,String>();
        port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
    
        port.endpoint_x = endpointMap.get('ORDER_ACK_PDF');
        port.timeout_x = 120000;		
    
        try {
            sapComDocSapRfcFunctionsOAck.x_xGEL_xSFB2B_ORDACK_PDF_Response_element response_x = new sapComDocSapRfcFunctionsOAck.x_xGEL_xSFB2B_ORDACK_PDF_Response_element();
    
            response_x = port.SI_SFB2B_OrderAck_750_OB_SYNC(request.ordNumber);
            if(response_x != null){
                response.hexData = response_x.E_HEXDATA;
                response.base64Data = response_x.E_PDFDATA;
                response.message = response_x.E_MESSAGE;
            }
            
        } catch (System.CalloutException cex) {
            System.debug('gg8****' + cex.getMessage());
            ExceptionLogger.newExceptionLog(cex,'SAPGatewayPDF','getOrderAckPDF');            
            throw new SOAPFaultException();
        }       
    
        return response;
    }
    
    public DeliveryNotesPDFController.Response getDeliveryNotesPDF(DeliveryNotesPDFController.Request request) {
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getDeliveryNotesPDF');		
    
        DeliveryNotesPDFController.Response response = new DeliveryNotesPDFController.Response();
        gecurrentCom751Deliverymail.HTTPS_Port port = new gecurrentCom751Deliverymail.HTTPS_Port();
        port.inputHttpHeaders_x=new Map<String,String>();
        port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
    
        port.endpoint_x = endpointMap.get('DELIVERY_NOTES_PDF');
        port.timeout_x = 120000;		
    
        try {
            sapComDocSapRfcFunctionsDM.x_xGEL_xSFB2B_PACKLST_PDF_Response_element response_x = new sapComDocSapRfcFunctionsDM.x_xGEL_xSFB2B_PACKLST_PDF_Response_element();
    
            response_x = port.SI_SFB2B_DeliveryMail_751_OB_SYNC(request.invNumber);
            if(response_x != null){
                response.hexData = response_x.E_HEXDATA;
                response.base64Data = response_x.E_PDFDATA;
                response.message = response_x.E_MESSAGE;
            }
            
        } catch (System.CalloutException cex) {
            System.debug('gg8****' + cex.getMessage());  
            ExceptionLogger.newExceptionLog(cex,'SAPGatewayPDF','getDeliveryNotesPDF');               
            throw new SOAPFaultException();
        }       
    
        return response;
    }

    public AgreementPDFController.Response getAgreementPDF(AgreementPDFController.Request request) {
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getAgreementPDF');		
    
        AgreementPDFController.Response response = new AgreementPDFController.Response();
        gecurrentCom486AgrPDF.HTTPS_Port port = new gecurrentCom486AgrPDF.HTTPS_Port();
        port.inputHttpHeaders_x=new Map<String,String>();
        port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
    
        port.endpoint_x = endpointMap.get('AGREEMENT_PDF');
        port.timeout_x = 120000;		
    
        try {
            sapComDocSapRfcFunctionsAgrPDF.x_xGEL_xSFB2B_AGREEMENT_PDF_GEN_Response_element response_x = new sapComDocSapRfcFunctionsAgrPDF.x_xGEL_xSFB2B_AGREEMENT_PDF_GEN_Response_element();
    
            response_x = port.SI_SFB2B_AgreementPDFGenarate_486_OB_SYNC(request.agrNumber);
            if(response_x != null){
                response.hexData = response_x.E_HEXDATA;
                response.base64Data = response_x.E_PDFDATA;
                response.message = response_x.E_MESSAGE;
            }
            
        } catch (System.CalloutException cex) {
            System.debug('gg8****' + cex.getMessage());   
            ExceptionLogger.newExceptionLog(cex,'SAPGatewayPDF','getAgreementPDF');          
            throw new SOAPFaultException();
        }       
    
        return response;
    }

    public OrderRMAPDFController.Response getOrderRMAPDF(OrderRMAPDFController.Request request) {
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getOrderRMAPDF');		
    
        OrderRMAPDFController.Response response = new OrderRMAPDFController.Response();
        gecurrentCom4757RMA.HTTPS_Port port = new gecurrentCom4757RMA.HTTPS_Port();
        port.inputHttpHeaders_x=new Map<String,String>();
        port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
    
        port.endpoint_x = endpointMap.get('ORDER_RMA_PDF');
        port.timeout_x = 120000;		
    
        try {
            sapComDocSapRfcFunctionsRMA.x_xGEL_xSFB2B_PRINT_RET_ORDER_Response_element response_x = new sapComDocSapRfcFunctionsRMA.x_xGEL_xSFB2B_PRINT_RET_ORDER_Response_element();
            sapComDocSapRfcFunctionsRMA.x_xGEL_xSDOMPRINT_ORDERCONF_HI I_HEADER = new sapComDocSapRfcFunctionsRMA.x_xGEL_xSDOMPRINT_ORDERCONF_HI();
            I_HEADER.ORDERNR = request.ordNumber;
            response_x = port.SI_SFB2B_eLight_RGARMA_LetterPrintPDF_4757_OB_SYNC(I_HEADER);
            if(response_x != null){
                response.hexData = response_x.E_HEXDATA_1;
                response.base64Data = response_x.E_PDFDATA;                
            }
            
        } catch (System.CalloutException cex) {
            System.debug('gg8****' + cex.getMessage());  
            ExceptionLogger.newExceptionLog(cex,'SAPGatewayPDF','getOrderRMAPDF');           
            throw new SOAPFaultException();
        }
        return response;
    }


    public CaseRgaPdfController.Response getCaseRgaPdf(CaseRgaPdfController.Request request) {
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getCaseRgaPdf');

        CaseRgaPdfController.Response response = new CaseRgaPdfController.Response();
        gecurrentCom4757RMA.HTTPS_Port port = new gecurrentCom4757RMA.HTTPS_Port();
        port.inputHttpHeaders_x=new Map<String,String>();
        port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
        port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

        port.endpoint_x = endpointMap.get('RGADocument_4757');
        port.timeout_x = 120000;

        try {
            sapComDocSapRfcFunctionsRMA.x_xGEL_xSFB2B_PRINT_RET_ORDER_Response_element response_x = new sapComDocSapRfcFunctionsRMA.x_xGEL_xSFB2B_PRINT_RET_ORDER_Response_element();
            sapComDocSapRfcFunctionsRMA.x_xGEL_xSDOMPRINT_ORDERCONF_HI I_HEADER = new sapComDocSapRfcFunctionsRMA.x_xGEL_xSDOMPRINT_ORDERCONF_HI();
            I_HEADER.ORDERNR = request.orderNumber;
            response_x = port.SI_SFB2B_eLight_RGARMA_LetterPrintPDF_4757_OB_SYNC(I_HEADER);
            if(response_x != null){
                response.hexData = response_x.E_HEXDATA_1;
                response.base64Data = response_x.E_PDFDATA;
            }

        } catch (System.CalloutException cex) {
            System.debug('gg8****' + cex.getMessage());
            ExceptionLogger.newExceptionLog(cex,'SAPGatewayPDF','getCaseRgaPdf');
            throw new SOAPFaultException();
        }
        return response;
    }

    public class SAPServiceException extends Exception { }
	public class OrderNotFoundException extends Exception { }
    public class SOAPFaultException extends Exception { }
}