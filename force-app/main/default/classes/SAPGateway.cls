/*---------------------------------------------------------------------------------
Name:       SAPGateway.cls
Purpose:    Gateway Pattern providing uniform interface into SAP SOAP services.
			Provides singlular point to update
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description
-------     -------         ----getrealtime----------          -----------------------------
1.0         Devang          22-Nov-2020           Initial Development
---------------------------------------------------------------------------------*/
public class SAPGateway implements SAPGatewayInterface {
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

	public ReportSubscriptionController.Response getReportSubscriptionsSAP(ReportSubscriptionController.Request request) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getReportSubscriptionsSAP');

		ReportSubscriptionController.Response response = new ReportSubscriptionController.Response();
		gecurrentCom480Myacccall3N4RprtSub.HTTPS_Port port = new gecurrentCom480Myacccall3N4RprtSub.HTTPS_Port();
		port.inputHttpHeaders_x=new Map<String,String>();
		port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		port.endpoint_x = endpointMap.get('REPORT_SUBSCRIPTIONS');
		port.timeout_x = 120000;

		try {
			sapComSapRfcFunctionsRprtSub.x_xGEL_xSFB2B_REPORT_SUBSCRIPT3_Response_element response_x = new sapComSapRfcFunctionsRprtSub.x_xGEL_xSFB2B_REPORT_SUBSCRIPT3_Response_element();
			response_x = port.SI_SFB2B_MyAccCall3_480_OB_Sync_N4(request.cutOrdRep,
					request.dailyCommReport,
					request.dueDtCGEReport,
					request.invByBill,
					request.modType,
					request.monthlyCommReport,
					request.openOrdRep,
					request.orderLineReport,
					request.orderShipReport,
					request.priceMismatch,
					request.ssoAcct,
					request.ssoEmail,
					request.ssoGESSOUID);

			system.debug('response_x '+response_x);

			if (response_x != null) {
				response.message = response_x.E_MESSAGE;
				response.ssoGESSOUID = response_x.E_XXSSO_GESSOUID;
			}
		} catch (System.CalloutException cex) {
			System.debug('SAPGateway getReportSubscriptionsSAP' + cex.getMessage());
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','getReportSubscriptionsSAP');

		}

		return response;
	}

	public InvoicePDFController.Response getInvoicePDF(InvoicePDFController.Request request) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getInvoicePDF');

		InvoicePDFController.Response response = new InvoicePDFController.Response();
		gecurrentCom484Invoicepdfgenrat.HTTPS_Port port = new gecurrentCom484Invoicepdfgenrat.HTTPS_Port();
		port.inputHttpHeaders_x=new Map<String,String>();
		port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		port.endpoint_x = endpointMap.get('INVOICE_PDF');
		port.timeout_x = 120000;

		try {
			sapComDocSapRfcFunctionsInvPdf.x_xGEL_xSFB2B_INVOICE_PDF_GENRAT_Response_element response_x = new sapComDocSapRfcFunctionsInvPdf.x_xGEL_xSFB2B_INVOICE_PDF_GENRAT_Response_element();

			response_x = port.SI_SFB2B_InvoicePDFGenrat_484_OB_SYNC(request.invNumber);
			if(response_x != null){
				response.hexData = response_x.E_HEXDATA;
				response.base64Data = response_x.E_PDFDATA;
				response.message = response_x.E_MESSAGE;
			}

		} catch (System.CalloutException cex) {
			System.debug('step' + cex.getMessage());
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','getInvoicePDF');

		}

		return response;
	}

	public InventoryController.InventoryResponse getInventoryAvailability(InventoryController.InventoryRequest request) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getInventoryAvailability');

		InventoryController.InventoryResponse response = new InventoryController.InventoryResponse();
		gecurrentCom701ProductAvailability.HTTPS_Port port = new gecurrentCom701ProductAvailability.HTTPS_Port();
		port.inputHttpHeaders_x=new Map<String,String>();
		port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		//TODO - need to remove hardcoded host value
		//port.inputHttpHeaders_x.put('Host', 'genesisq1.gecurrent.com');
		port.endpoint_x = endpointMap.get('PRODUCT_AVAILABILITY');

		port.timeout_x = 120000;

		try {
			String I_AGREEMENT = request.agreement;
			String I_ORDER_TYPE = '';


			sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LS2_Response_element response_x = new sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVAILABLE_PRICE_LS2_Response_element();
			sapComDocSapRfcFunctionsPA.ET_BOM_DETAILS_element ET_BOM_DETAILS = new sapComDocSapRfcFunctionsPA.ET_BOM_DETAILS_element();
			sapComDocSapRfcFunctionsPA.ET_MATERIALS_element ET_MATERIALS = new sapComDocSapRfcFunctionsPA.ET_MATERIALS_element();
			sapComDocSapRfcFunctionsPA.ET_QTY_ON_HAND_element ET_QTY_ON_HAND = new sapComDocSapRfcFunctionsPA.ET_QTY_ON_HAND_element();
			sapComDocSapRfcFunctionsPA.IT_MATERIALS_element IT_MATERIALS = new sapComDocSapRfcFunctionsPA.IT_MATERIALS_element();

			List<sapComDocSapRfcFunctionsPA.x_xGEL_xHY_AVAILABLE_PRICE_PROD> elList =  new List<sapComDocSapRfcFunctionsPA.x_xGEL_xHY_AVAILABLE_PRICE_PROD>();

			for(InventoryController.Inventory inv : request.inventoryList) {
				sapComDocSapRfcFunctionsPA.x_xGEL_xHY_AVAILABLE_PRICE_PROD el = new sapComDocSapRfcFunctionsPA.x_xGEL_xHY_AVAILABLE_PRICE_PROD();

				el.LINE_ITEM = String.valueOf(inv.lineItem);
				el.MATERIAL = inv.material;
				el.QUANTITY = String.valueOf(inv.quantity);
				el.UOM = inv.UOM;
				el.DESCRIPTION = inv.description;
				el.REQ_DEL_DATE = request.reqDelDate;
				elList.add(el);
			}
			IT_MATERIALS.item = elList;


			response_x = port.SI_SFB2B_ProductAvailability_701_OB_SYNC_N2(request.agent, '',  request.customer, I_ORDER_TYPE,
					request.poleType, request.poNumber, request.poType, request.reqDelDate, request.spart, request.userType,
					request.salesOrg, request.distChannel,
					ET_BOM_DETAILS,
					ET_MATERIALS,
					ET_QTY_ON_HAND,
					IT_MATERIALS);



			system.debug(response_x);

			ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'getInventoryAvailability');


			if(response_x != null){
				response.agent = response_x.E_AGENT;
				response.customerName = response_x.E_CUST_NAME;
				response.customer = response_x.E_CUTOMER;
				response.message = response_x.E_MESSAGE;
				response.orderType = response_x.E_ORDER_TYPE;
				response.poleType = response_x.E_POLE_TYPE;
				response.poNumber = response_x.E_PO_NUMBER;
				response.poType = response_x.E_PO_TYPE;
				response.reqDelDate = response_x.E_REQ_DEL_DATE;
				response.spart = response_x.E_SPART;
				response.userType = response_x.E_USER_TYPE;
				response.salesOrg = response_x.E_VKORG;
				response.division = response_x.E_VTWEG;
                
				List<sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVA_PRICE_PROD_OUT> prList = null;
				List<sapComDocSapRfcFunctionsPA.x_xGEL_xHY_MATNR_QTY> qtyList = null;

				if(response_x.ET_MATERIALS != null && response_x.ET_MATERIALS.item != null ){

					prList = response_x.ET_MATERIALS.item;
				}
				if(response_x.ET_QTY_ON_HAND != null && response_x.ET_QTY_ON_HAND.item != null ){

					qtyList = response_x.ET_QTY_ON_HAND.item;
				}

				system.debug(qtyList);
				Map<String,List<InventoryController.Inventory>> inventoryMap = new Map<String,List<InventoryController.Inventory>>();

				// add all requsted to map
				for(InventoryController.Inventory inv : request.inventoryList) {
					List<InventoryController.Inventory> inventoryList = new List<InventoryController.Inventory>();
					String material = '';
					if(String.isNotBlank(inv.material)){
						material = ('00000000000000000000' + inv.material).right(18);
						//System.debug('step' + material + '****');
						InventoryController.Inventory invTmp = new InventoryController.Inventory();
						invTmp.SKU = material;
						invTmp.material = material;
						inventoryList.add(invTmp);
						inventoryMap.put(material, inventoryList);
					}
				}

				if(qtyList != null){
					for(sapComDocSapRfcFunctionsPA.x_xGEL_xHY_MATNR_QTY  qty : qtyList){
						String material = '';
						material = ('00000000000000000000' + qty.MATERIAL_ENTERED).right(18);
						List<InventoryController.Inventory> inventoryList = null;
						if(inventoryMap != null){
							if(inventoryMap.get(material) !=  null){
								inventoryList = inventoryMap.get(material);

							} else {
								inventoryList = new List<InventoryController.Inventory>();

								inventoryMap.put(material, inventoryList);
							}

							if(inventoryList != null){
								InventoryController.Inventory inv = new InventoryController.Inventory();
								inv.SKU = material;
								inv.warehouseCode =  qty.PLANT;
								inv.warehouseName = qty.PLANT_NAME;
								inv.material = material;
								inv.quantity = Integer.valueOf(qty.QUANTITY);

								if(qty.PLANT.equalsIgnoreCase(request.defaultWarehouseCode)){

									inv.isDefaultWarehouse = true;
								} else {
									inv.isDefaultWarehouse = false;
								}
								inventoryList.add(inv);
							}
						}
					}
				}

				if(prList != null){
					for(sapComDocSapRfcFunctionsPA.x_xGEL_xSFB2B_AVA_PRICE_PROD_OUT pr : prList){
						String material = '';
						material = ('00000000000000000000' + pr.MATERIAL_ENTERED).right(18);
						List<InventoryController.Inventory> inventoryList = null;
						//System.debug('step MATERIAL_ENTERED****' + pr.MATERIAL_ENTERED + '****');
						if(inventoryMap.get(material) == null){
							inventoryList = new List<InventoryController.Inventory>();

							inventoryMap.put(material, inventoryList);
						} else {
							inventoryList = inventoryMap.get(material);
						}


						if(inventoryList != null){
							for(InventoryController.Inventory inv : inventoryList){

								if(inv.material == material){

									inv.leadTime = pr.LEAD_TIME;
									if(String.isNotBlank(pr.LINE_NUMBER)){
										inv.lineItem = Integer.valueOf(pr.LINE_NUMBER);
									}
									if(String.isNotBlank(pr.QTY_ON_HAND)){
										inv.quantityOnHand = Integer.valueOf(pr.QTY_ON_HAND);
									}
									if(String.isNotBlank(pr.WAREHOUSE_AVAILABILITY)){
										inv.totalQuantity = Integer.valueOf(pr.WAREHOUSE_AVAILABILITY);
									}
									inv.UOM = pr.UOM;
									if(String.isNotBlank(pr.ADP_PRICE)){
										inv.adpPrice = Decimal.valueOf(pr.ADP_PRICE);
									}
									if(String.isNotBlank(pr.MAX_PRICE)){
										inv.maxPrice = Decimal.valueOf(pr.MAX_PRICE);
									}
									if(String.isNotBlank(pr.UNIT_PRICE)){
										inv.unitPrice = Decimal.valueOf(pr.UNIT_PRICE);
									}
									if(String.isNotBlank(pr.PRICE_AGREMENT_VALUE)){
										inv.priceAgreementValue = Decimal.valueOf(pr.PRICE_AGREMENT_VALUE);
									}
									inv.priceAgreement = pr.PRICE_AGREMENT;
									inv.currencyISOCode = pr.CURRENCY_x;
									if(String.isNotBlank(pr.ROUNDED_QTY)){
										inv.roundedQty = Integer.valueOf(pr.ROUNDED_QTY);
									}
									if(String.isNotBlank(pr.REQ_QTY)){
										inv.reqQty = Integer.valueOf(pr.REQ_QTY);
									}
                                    inv.IsQuickstock = request.IsQuickstock;
								}
							}
							inventoryList = InventoryController.getWarehouseNames(inventoryList);
						}
					}
				}
				//response.inventoryList = InventoryController.getWarehouseNames(inventoryList);

				response.inventoryMap =  inventoryMap;
			}
		} catch (System.CalloutException cex) {
			System.debug('step' + cex.getMessage());
			System.debug('step' + cex.getLineNumber());
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','getInventoryAvailability');

		}

		return response;
	}

	public PriceAgreementController.PriceAgreementResponse getRealTimePricing(PriceAgreementController.PriceAgreementRequest request) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'getRealTimePricing');


		PriceAgreementController.PriceAgreementResponse response = new PriceAgreementController.PriceAgreementResponse();
		gecurrentCom475Agreementprice.HTTPS_Port port = new gecurrentCom475Agreementprice.HTTPS_Port();
		port.inputHttpHeaders_x=new Map<String,String>();
		port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		port.endpoint_x = endpointMap.get('PRICE_AGREEMENT_VALIDATE');
		port.timeout_x = 120000;

		try {

			String I_INT_REP = '';

			sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element response_x = new sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element();
			sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element ET_MATERIALS_OUT  = new sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element();
			sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element ET_SCHEDULELINE_DATA = new sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element();
			sapComDocSapRfcFunctionsAP.IT_MATERIALS_element IT_MATERIALS = new sapComDocSapRfcFunctionsAP.IT_MATERIALS_element();

			List<sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS> pmList =  new List<sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS>();
			Map<String, PriceAgreementController.PriceAgreementItem> lineNumToItemMap = new Map<String, PriceAgreementController.PriceAgreementItem>();

			for(PriceAgreementController.PriceAgreementItem pai : request.priceAgreementItemList) {
				sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS pm = new sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS();

				lineNumToItemMap.put(String.valueOf(pai.lineNumber), pai);
				pm.LINE_NUMBER = String.valueOf(pai.lineNumber);
				pm.PART_NUMBER = pai.material;
				pm.QUANTITY = String.valueOf(pai.quantity);
				pm.AGREEMENT=pai.agreement;
				pm.SALES_UNIT = UtilityClass.convertUomLabelToUomCode(pai.UOM);
				if(pai.requestedPrice != 0){
					pm.REQUESTED_PRICE = String.valueOf(pai.requestedPrice);
				}
				pm.CURRENCY_x = pai.currencyISOCode;
				pm.PART_DESCRIPTION = pai.description;
				pm.REQ_DEL_DATE = pai.reqDelDate;
				pmList.add(pm);
			}
			IT_MATERIALS.item = pmList;


			System.debug('SAP call request parameters ' + request);

			response_x = port.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6(request.agreement,request.agrDate,request.callType,
					request.distChannel, request.division, request.extAgent,
					I_INT_REP, request.orderFlag, request.orderReason,
					request.orderType, request.poNumber, request.salesOrg,
					request.customer, request.userType, request.validateFlag,
					ET_MATERIALS_OUT, ET_SCHEDULELINE_DATA, IT_MATERIALS);

			system.debug('***getCpuTime()***'+Limits.getCpuTime());
			//System.debug('response_x=' +  response_x);
			System.debug('PriceAgreementSAPResponse\n'+JSON.serializePretty(response_x));

			ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'getRealTimePricing');


			if(response_x != null){

				response.agreement =  request.agreement;
				response.agrDate =  request.agrDate;
				response.distChannel =  request.distChannel;
				response.division =  request.division;
				response.orderFlag =  request.orderFlag;
				response.orderReason =  request.orderReason;
				response.orderType =  request.orderType;
				response.poNumber =  request.poNumber;
				response.salesOrg =  request.salesOrg;
				response.customer =  request.customer;
				response.userType =  request.userType;
				response.errMessage = response_x.E_ERR_MESSAGE;
				response.poDuplicate = response_x.E_PO_DUPLICATE;

				List<sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT> paoList = null;

				if(response_x.ET_MATERIALS_OUT != null && response_x.ET_MATERIALS_OUT.item != null ){
					paoList = response_x.ET_MATERIALS_OUT.item;
				}

				List<PriceAgreementController.PriceAgreementItem> priceAgreementList = new List<PriceAgreementController.PriceAgreementItem>();

				if(paoList != null){
					for(sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT pao : paoList){
						PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
						if(String.isNotBlank(pao.LINE_NUMBER)){
							pai.lineNumber = Integer.valueOf(pao.LINE_NUMBER);
						}
						String trimmedLineNum = String.valueOf(Integer.valueOf(pao.LINE_NUMBER));
						System.debug('step'+ trimmedLineNum);

						try{
							pai.SKU = lineNumToItemMap.get(trimmedLineNum).SKU;
						}
						catch(Exception e){
							pai.SKU = pao.PART_NUMBER;
						}
						pai.material = pao.PART_NUMBER;
						pai.description = pao.PART_DESCRIPTION;

						if(String.isNotBlank(pao.QUANTITY)){
							pai.quantity = Integer.valueOf(pao.QUANTITY);
						}
						/*if(String.isNotBlank(pao.QTY_ON_HAND)){
							pai.quantityOnHand = Integer.valueOf(pao.QTY_ON_HAND);
						}
						if(String.isNotBlank(pao.WAREHOUSE_AVAILABILITY)){
							pai.warehouseAvailability = Integer.valueOf(pao.WAREHOUSE_AVAILABILITY);
						}*/
						if(String.isNotBlank(pao.ADP)){
							pai.adpPrice = Decimal.valueOf(pao.ADP);
						}

						if(String.isNotBlank(pao.ADP_PERC)){
							pai.globalCommission = Decimal.valueOf(pao.ADP_PERC);
						}
						if(String.isNotBlank(pao.FLOOR_PRICE)){
							pai.floorPrice = Decimal.valueOf(pao.FLOOR_PRICE);
						}
						if(String.isNotBlank(pao.FLOOR_PERC)){
							pai.floorCommission = Decimal.valueOf(pao.FLOOR_PERC);
						}
						if(String.isNotBlank(pao.SLIDING_COM)){
							pai.slidingCommission = Decimal.valueOf(pao.SLIDING_COM);
						}
						if(String.isNotBlank(pao.SLIDING_COM_PERC)){
							pai.slidingCommissionPercentage = Decimal.valueOf(pao.SLIDING_COM_PERC);
						}
						if(String.isNotBlank(pao.OVERAGE_AMOUNT)){
							pai.overageAmount = Decimal.valueOf(pao.OVERAGE_AMOUNT);
						}
						if(String.isNotBlank(pao.OVERAGE_PERC_AMNT)){
							pai.overagePercentageAmount = Decimal.valueOf(pao.OVERAGE_PERC_AMNT);
						}
						if(String.isNotBlank(pao.OVERAGE_PERC_PERC)){
							pai.overagePercentagePerc = Decimal.valueOf(pao.OVERAGE_PERC_PERC);
						}
						if(!String.isNotEmpty(pao.ZFRE)){
							pai.zfre = Decimal.valueOf(pao.ZFRE);
						}

						pai.UOM = pao.SALES_UNIT;

						if(String.isNotBlank(pao.REQUESTED_PRICE)){
							pai.requestedPrice = Decimal.valueOf(pao.REQUESTED_PRICE);
						}
						if(String.isNotBlank(pao.BOOKP_PRICE)){
							pai.bookPrice = Decimal.valueOf(pao.BOOKP_PRICE);
						}
						pai.leadTime = pao.LEAD_TIME;
						if(String.isNotBlank(pao.AVAILABLE_QTY)){
							pai.availableQty = Integer.valueOf(pao.AVAILABLE_QTY);
						}
						if(String.isNotBlank(pao.COMMISON)){
							pai.commission = Decimal.valueOf(pao.COMMISON);
							system.debug(pao.COMMISON_PER);
							if(String.isNotBlank(pao.COMMISON_PER) && pao.COMMISON_PER!='0'){
								pai.commissionPer = Decimal.valueOf(pao.COMMISON_PER);
							}else if(pao.REQUESTED_PRICE!='0'){
								pai.commissionPer = (Decimal.valueOf(pao.COMMISON)/Decimal.valueOf(pao.REQUESTED_PRICE))*100;
							}
						}
						pai.weeeLamp = pao.WEEE_LAMP;
						pai.weeeLight = pao.WEEE_LIGHT;
						pai.weeeLampIr = pao.WEEE_LAMP_IR;
						pai.message = pao.MESSAGE;
						pai.substitueMaterial = pao.SUBSTITUTE_MATERIAL;
						pai.countryOfOrigin = pao.COUNTRY_OF_ORIGIN;
						pai.substitueReason = pao.SUBSTITUTION_REASON;
						pai.reasonRej = pao.REASON_REJ;
						pai.reasonRejText  = pao.REASON_REJ_TEXT;
						pai.agreement = pao.PRICE_AGREMENT;
						pai.productHierarchy = pao.PRODUCT_HIERARCHY;
						pai.plant = pao.PLANT;
						pai.currencyISOCode = pao.CURRENCY_x;
						if(String.isNotBlank(pao.EXTENDED_PRICE)){
							pai.extendedPrice = Decimal.valueOf(pao.EXTENDED_PRICE);
						}
						if(String.isNotBlank(pao.ROUNDED_QTY)){
							pai.roundedQty = Integer.valueOf(pao.ROUNDED_QTY);
						}
						if(String.isNotBlank(pao.STANDARD_PACK_QTY)){
							pai.standardPackQty = Integer.valueOf(pao.STANDARD_PACK_QTY);
						}
						if(String.isNotBlank(pao.PALLET_QTY)){
							pai.palletQty = Integer.valueOf(pao.PALLET_QTY);
						}
						if(String.isNotBlank(pao.UK_PALLET_QTY)){
							pai.ukPalletQty = Integer.valueOf(pao.UK_PALLET_QTY);
						}
						pai.lightTax =  pao.LIGHT_TAX;
						System.debug('step' +  pao.PRICE_AGREMENT);
						System.debug('step' +  pao.PRICE_AGREMENT_VALUE);
						if(String.isNotBlank(pao.PRICE_AGREMENT_VALUE)){
							System.debug('step' +  pao.PRICE_AGREMENT_VALUE);
							pai.priceAgreementValue = Decimal.valueOf(pao.PRICE_AGREMENT_VALUE);
						}
						System.debug('step NET_CREDIT ' +  pao.NET_CREDIT);
						if(String.isNotBlank(pao.NET_CREDIT)){
							pai.netCredit = Decimal.valueOf(pao.NET_CREDIT);
						}
						priceAgreementList.add(pai);
					}
				}
				response.priceAgreementItemList = priceAgreementList;

			}

		} catch (System.CalloutException cex) {
			System.debug('step' + cex);
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','getRealTimePricing');

		}
		System.debug('step');
		return response;
	}

	public String createOrder(ccrz__E_Order__c newOrder, List<ccrz__E_OrderItem__c> orderItems){
		gecurrentComCom472OrdercreateN3.HTTPS_Port stub = new gecurrentComCom472OrdercreateN3.HTTPS_Port();
		stub.inputHttpHeaders_x=new Map<String,String>();

		String endpointURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SAP_SOAP'].Endpoint.removeStart('https://');


		// String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
		// stub.inputHttpHeaders_x.put('Authorization', authorizationHeader);
		stub.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		stub.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
		stub.inputHttpHeaders_x.put('Host', endpointURL);

		stub.endpoint_x = endpointMap.get('CREATE_ORDER');

		stub.timeout_x=120000;

		try{
			gecurrentComCom472OrdercreateN3.GEOrderInfoWrapper orderInfoWrapper=new gecurrentComCom472OrdercreateN3.GEOrderInfoWrapper();
			/*orderInfoWrapper.I_AGENT_CODE = newOrder.ccrz__Contact__r.Account.GE_LGT_Rep_Code__c;
            if(newOrder.ccrz__Contact__r.Account.Account_Group__c!='ZEAG'){
				orderInfoWrapper.I_AGENT_CODE = newOrder.ccrz__OriginatedCart__r.Agent_Rep_Code__c;
			}*/

			orderInfoWrapper.I_AGENT_CODE ='';
			if(newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.Account_Group__c=='ZEAG' && newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.Customer_Segmentation__c=='FD'){
				orderInfoWrapper.I_AGENT_CODE = newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;

			}
			else {
				orderInfoWrapper.I_AGENT_CODE = newOrder.ccrz__OriginatedCart__r.Agent_Rep_Code__c;
			}
			orderInfoWrapper.I_AGREEMENT = newOrder.ccrz__OriginatedCart__r.Agreement_Number__c;
			//orderInfoWrapper.I_AGREEMENT = null;
			//orderInfoWrapper.I_BACK_ORDER_FLAG = null;
			orderInfoWrapper.I_CARRIER_ACCOUNT = newOrder.Carrier_Account__c;
			//orderInfoWrapper.I_CONTACT_EMAIL = newOrder.ccrz__Contact__r.Email;
			//orderInfoWrapper.I_CONTACT_PHONE = newOrder.ccrz__Contact__r.Phone;
            orderInfoWrapper.I_CONTACT_EMAIL = newOrder.ccrz__BuyerEmail__c;
			orderInfoWrapper.I_CONTACT_PHONE = newOrder.ccrz__BuyerPhone__c;
            
			/*if(!String.isBlank(newOrder.Delivery_Contact_Phone__c)){
				orderInfoWrapper.I_CONTACT_PHONE = newOrder.Delivery_Contact_Phone__c;
			}*/
			orderInfoWrapper.I_CONNECT_ORDNR=newOrder.Name;

			if(!String.isBlank(newOrder.Sold_To_Account__c)){
				orderInfoWrapper.I_CUSTOMER = newOrder.Sold_To_Account__c;
			}
			else{
				orderInfoWrapper.I_CUSTOMER = newOrder.ccrz__Contact__r.Account.GE_LGT_EM_SAP_Customer_Number__c;
			}

			/*orderInfoWrapper.I_CUSTOMER_CONTACT = newOrder.ccrz__ShipTo__r.ccrz__FirstName__c+' '+newOrder.ccrz__ShipTo__r.ccrz__LastName__c;
			if(!String.isBlank(newOrder.Delivery_Contact_Name__c)){
				orderInfoWrapper.I_CUSTOMER_CONTACT = newOrder.Delivery_Contact_Name__c;
			}*/
            
            orderInfoWrapper.I_CUSTOMER_CONTACT = newOrder.ccrz__BuyerFirstName__c+' '+newOrder.ccrz__BuyerLastName__c;
			
            system.debug(newOrder.Delivery_Block__c);
			//if(newOrder.Delivery_Block__c!=null){
			//	orderInfoWrapper.I_DELIVERY_BLOCK = newOrder.Delivery_Block__c;
			//}else{
			//	orderInfoWrapper.I_DELIVERY_BLOCK ='';
			//}
			if(newOrder.Ship_Not_Before_Date__c){
				orderInfoWrapper.I_DELIVERY_BLOCK = 'Z3';
			}else{
				orderInfoWrapper.I_DELIVERY_BLOCK = '';
			}

			//orderInfoWrapper.I_EMAIL_ADDRESS = newOrder.ccrz__Contact__r.Email;
			orderInfoWrapper.I_EMAIL_ADDRESS = newOrder.ccrz__BuyerEmail__c;
			//orderInfoWrapper.I_HEADER_TEXT = null;
			orderInfoWrapper.I_ORDER_FLAG = 'Y';
			//orderInfoWrapper.I_ORDER_NUMBER = null;
			system.debug(newOrder.ccrz__OriginatedCart__r.Sample_Order__c);
			system.debug(newOrder.Order_Reason__c);
			if(newOrder.ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_Order_Block__c=='Z1'){
				//orderInfoWrapper.I_ORDER_REASON = newOrder.Order_Reason__c;
				orderInfoWrapper.I_ORDER_REASON = 'N01';
				orderInfoWrapper.I_ORDER_TYPE = 'ZSAM';
			}else{
				orderInfoWrapper.I_ORDER_TYPE = 'ZOR';
			}
			if(newOrder.Ship_Complete__c){
				orderInfoWrapper.I_PARTIAL_SHIP = 'N';
			}
			else{
				orderInfoWrapper.I_PARTIAL_SHIP = 'Y';
			}
			system.debug(orderInfoWrapper.I_PARTIAL_SHIP);
			orderInfoWrapper.I_PO_NUM = newOrder.ccrz__TransactionPayments__r[0].ccrz__AccountNumber__c;
			orderInfoWrapper.I_PROJECT_NAME = newOrder.Project_Name__c;
			orderInfoWrapper.I_REQ_DATE = String.valueOf(newOrder.Requested_Delivery_Date__c);
			//orderInfoWrapper.I_SALES_ORG = newOrder.ccrz__Contact__r.Account.GE_LGT_EM_Sales_Org__c;
			orderInfoWrapper.I_DIST_CHENNEL = newOrder.ccrz__Contact__r.Account.GE_LGT_EM_Distribution_Channel__c;
			orderInfoWrapper.I_DIVISION = newOrder.ccrz__Contact__r.Account.GE_LGT_EM_Division__c;
			
			if(!String.isBlank(newOrder.Sold_To_Account__c)){
				System.debug('newOrder.Sold_To_Account__c: '+newOrder.Sold_To_Account__c);
				//newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.
				System.debug('newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_Sales_Org__c: '+newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_Sales_Org__c);
				//System.debug('newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c: '+newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c);
				//System.debug('newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_Division__c: '+newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_Division__c);
				//Account accountSalesOrg = [SELECT Id, GE_LGT_EM_Sales_Org__c FROM Account WHERE GE_LGT_EM_SAP_Customer_Number__c=:newOrder.Sold_To_Account__c];
				orderInfoWrapper.I_SALES_ORG = newOrder.ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_Sales_Org__c;
			}
			else{
				orderInfoWrapper.I_SALES_ORG = newOrder.ccrz__Contact__r.Account.GE_LGT_EM_Sales_Org__c;
			}
			system.debug('orderInfoWrapper.I_SALES_ORG: '+orderInfoWrapper.I_SALES_ORG);

			orderInfoWrapper.I_SERIAL_NUMBER = newOrder.Serial_Number__c;
			//orderInfoWrapper.I_SFDC_CASE_NUMBER = null;
			/*orderInfoWrapper.I_SHIPMENT_TYPE = null;
			orderInfoWrapper.I_SHIPTO_ADDRESS1 = newOrder.ccrz__ShipTo__r.ccrz__AddressFirstline__c;
			orderInfoWrapper.I_SHIPTO_ADDRESS2 = newOrder.ccrz__ShipTo__r.ccrz__AddressSecondline__c;
			orderInfoWrapper.I_SHIPTO_CITY = newOrder.ccrz__ShipTo__r.ccrz__City__c;
			orderInfoWrapper.I_SHIPTO_COUNTRY = newOrder.ccrz__ShipTo__r.ccrz__CountryISOCode__c;
			orderInfoWrapper.I_SHIPTO_NAME = newOrder.ccrz__ShipTo__r.ccrz__FirstName__c+' '+newOrder.ccrz__ShipTo__r.ccrz__LastName__c;
			orderInfoWrapper.I_SHIPTO_POSTALCODE = newOrder.ccrz__ShipTo__r.ccrz__PostalCode__c;
			orderInfoWrapper.I_SHIPTO_STATE = newOrder.ccrz__ShipTo__r.ccrz__StateISOCode__c;
			orderInfoWrapper.I_SHIP_CONTACT_NAME = newOrder.ccrz__ShipTo__r.ccrz__FirstName__c+' '+newOrder.ccrz__ShipTo__r.ccrz__LastName__c;
			orderInfoWrapper.I_SHIP_CONTACT_NUMBER = newOrder.ccrz__Contact__r.Phone;
			orderInfoWrapper.I_SHIP_INSTRUCTION = null;
			orderInfoWrapper.I_SHIP_TO = newOrder.ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
			system.debug(newOrder.ccrz__OriginatedCart__r.Is_Z002__c);
			if(newOrder.ccrz__OriginatedCart__r.Is_Z002__c){
				orderInfoWrapper.I_SHIP_VIA = '01';
			}else{
				orderInfoWrapper.I_SHIP_VIA = '04';
			}*/

            orderInfoWrapper.I_SHIP_CONTACT_NAME = newOrder.Delivery_Contact_Name__c;
		    orderInfoWrapper.I_SHIP_CONTACT_NUMBER = newOrder.Delivery_Contact_Phone__c;
			LIST<String> tempAdd = new LIST<String>();
			//if(String.isBlank(newOrder.ccrz__OriginatedCart__r.Z002Address__c)){
			if(newOrder.ccrz__OriginatedCart__r.ShippingType__c=='Drop Ship'){
				orderInfoWrapper.I_SHIPMENT_TYPE = null;
				orderInfoWrapper.I_SHIPTO_ADDRESS1 = newOrder.ccrz__ShipTo__r.ccrz__AddressFirstline__c;
				orderInfoWrapper.I_SHIPTO_ADDRESS2 = newOrder.ccrz__ShipTo__r.ccrz__AddressSecondline__c;
				orderInfoWrapper.I_SHIPTO_CITY = newOrder.ccrz__ShipTo__r.ccrz__City__c;
				orderInfoWrapper.I_SHIPTO_COUNTRY = newOrder.ccrz__ShipTo__r.ccrz__CountryISOCode__c;
				orderInfoWrapper.I_SHIPTO_NAME = newOrder.ccrz__ShipTo__r.ccrz__CompanyName__c;
				orderInfoWrapper.I_SHIPTO_POSTALCODE = newOrder.ccrz__ShipTo__r.ccrz__PostalCode__c;
				orderInfoWrapper.I_SHIPTO_STATE = newOrder.ccrz__ShipTo__r.ccrz__StateISOCode__c;
				//orderInfoWrapper.I_SHIP_CONTACT_NAME = newOrder.ccrz__ShipTo__r.ccrz__FirstName__c+' '+newOrder.ccrz__ShipTo__r.ccrz__LastName__c;
				//orderInfoWrapper.I_SHIP_CONTACT_NUMBER = newOrder.ccrz__Contact__r.Phone;
				orderInfoWrapper.I_SHIP_INSTRUCTION = null;
				orderInfoWrapper.I_SHIP_TO = newOrder.ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
				string shippingnotesstr= newOrder.ccrz__OriginatedCart__r.Shipping_Instructions__c;
				
				string shippingInstructions = newOrder.ccrz__OriginatedCart__r.Shipping_Instructions__c;
				if (shippingInstructions.contains('Next Day Air') || shippingInstructions.contains('2nd Day Air')) {
					orderInfoWrapper.I_SHIP_VIA = '03';
				} else {
				orderInfoWrapper.I_SHIP_VIA = '04';
				}
			}else if(newOrder.ccrz__OriginatedCart__r.ShippingType__c=='Z002'){

				orderInfoWrapper.I_SHIPMENT_TYPE = null;
				orderInfoWrapper.I_SHIPTO_ADDRESS1 = null;
				orderInfoWrapper.I_SHIPTO_ADDRESS2 = null;
				orderInfoWrapper.I_SHIPTO_CITY = null;
				orderInfoWrapper.I_SHIPTO_COUNTRY = null;
				orderInfoWrapper.I_SHIPTO_NAME = null;
				orderInfoWrapper.I_SHIPTO_POSTALCODE = null;
				orderInfoWrapper.I_SHIPTO_STATE = null;
				//orderInfoWrapper.I_SHIP_CONTACT_NAME = null;
				//orderInfoWrapper.I_SHIP_CONTACT_NUMBER = null;
				orderInfoWrapper.I_SHIP_INSTRUCTION = null;

				string shippingInstructions = newOrder.ccrz__OriginatedCart__r.Shipping_Instructions__c;
				if (shippingInstructions.contains('Next Day Air') || shippingInstructions.contains('2nd Day Air')) {
					orderInfoWrapper.I_SHIP_VIA = '03';
				} else {
				orderInfoWrapper.I_SHIP_VIA = '01';
				}
				tempAdd=newOrder.ccrz__OriginatedCart__r.Z002Address__c.split('\\;');
				orderInfoWrapper.I_SHIP_TO = tempAdd[tempAdd.size()-1];

			}

			else if(newOrder.ccrz__OriginatedCart__r.ShippingType__c=='Will Call'){
				orderInfoWrapper.I_SHIPMENT_TYPE = null;
				orderInfoWrapper.I_SHIPTO_ADDRESS1 = null;
				orderInfoWrapper.I_SHIPTO_ADDRESS2 = null;
				orderInfoWrapper.I_SHIPTO_CITY = null;
				orderInfoWrapper.I_SHIPTO_COUNTRY = null;
				orderInfoWrapper.I_SHIPTO_NAME = null;
				orderInfoWrapper.I_SHIPTO_POSTALCODE = null;
				orderInfoWrapper.I_SHIPTO_STATE = null;
				//orderInfoWrapper.I_SHIP_CONTACT_NAME = null;
				//orderInfoWrapper.I_SHIP_CONTACT_NUMBER = null;
				orderInfoWrapper.I_SHIP_INSTRUCTION = null;
				orderInfoWrapper.I_SHIP_VIA = '02';
				orderInfoWrapper.I_SHIP_TO = newOrder.ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;


			}

			//orderInfoWrapper.I_STRATEGIC_ACC = newOrder.Strategic_Account__c;
			orderInfoWrapper.I_STRATEGIC_ACC = newOrder.ccrz__OriginatedCart__r.Strategic_Account_L__r.GE_LGT_EM_SAP_Customer_Number__c;
           // system.debug('Strategic Account'+orderInfoWrapper.I_STRATEGIC_ACC);
			
			/*if(newOrder.ccrz__Contact__r.Account.Account_Group__c=='ZEAG'){
				orderInfoWrapper.I_USER_TYPE = 'Agent';
			}else if(newOrder.ccrz__Contact__r.Account.Account_Group__c=='Z001'){
				orderInfoWrapper.I_USER_TYPE = 'Customer';
			}*/
            
            Id userId = UserInfo.getUserId();
            User effUser=[Select id,User_Type__c from user where id=:userId];
            
            if(effUser!=null){
                if(effUser.User_Type__c=='Agent'){
                    orderInfoWrapper.I_USER_TYPE = 'AGENT';
                } 
                else if(effUser.User_Type__c=='Distributor'){
                    orderInfoWrapper.I_USER_TYPE = 'CUSTOMER';                    
                }
                else {
                    orderInfoWrapper.I_USER_TYPE = '';
                }
                
            }
            
			orderInfoWrapper.ET_ITEMOUT = null;
			
			
			//orderInfoWrapper.IT_HEAD_COMMENTS = null;
			
			orderInfoWrapper.IT_HEAD_COMMENTS = new sapComDocumentSapRfcFunctions.IT_HEAD_COMMENTS_element();
			List<sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT> headCommentsList = new List<sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT>();
			
			if(!String.isEmpty(newOrder.Project_Description__c)){
				system.debug('newOrder.Project_Description__c: '+ newOrder.Project_Description__c);
				if(newOrder.Project_Description__c.length() < 132) {
					sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT comment = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT();
					comment.TEXT=newOrder.Project_Description__c;
					headCommentsList.add(comment);
				} else {

					if(newOrder.Project_Description__c.length() <= 255) {
						sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT comment1 = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT();
						sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT comment2 = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT();

						comment1.TEXT=newOrder.Project_Description__c.subString(0, 132);
						headCommentsList.add(comment1);
						comment2.TEXT=newOrder.Project_Description__c.subString(132, newOrder.Project_Description__c.length());
						headCommentsList.add(comment2);
					}
				}
			}
			system.debug('headCommentsList: '+ headCommentsList);
			if(!headCommentsList.isEmpty()){
				orderInfoWrapper.IT_HEAD_COMMENTS.item = headCommentsList;
			}

			orderInfoWrapper.IT_ITEMIN = new sapComDocumentSapRfcFunctions.IT_ITEMIN_element();
			orderInfoWrapper.IT_HEAD_SHIP_INSTRU = new sapComDocumentSapRfcFunctions.IT_HEAD_SHIP_INSTRU_element();
			orderInfoWrapper.IT_HEAD_SHIP_INSTRU.item = new List<sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT>();
			sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT newInstructions = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT();
			//newInstructions.TEXT=newOrder.ccrz__OriginatedCart__r.Shipping_Instructions__c;
             string shippingnotesstr= newOrder.ccrz__OriginatedCart__r.Shipping_Instructions__c;
            If (shippingnotesstr.length() < 95) {
                sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT newInstructions1 = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT();
			newInstructions1.TEXT=shippingnotesstr;
 			orderInfoWrapper.IT_HEAD_SHIP_INSTRU.item.add(newInstructions1);
                                system.debug('shipping notes array'+orderInfoWrapper.IT_HEAD_SHIP_INSTRU.item); 
                system.debug('shipping notes array1'+orderInfoWrapper.IT_HEAD_SHIP_INSTRU.item); 

			} else {
			 do {
               sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT newInstructions2 = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT();
			newInstructions2.TEXT=shippingnotesstr.subString(0, 95);  
 			orderInfoWrapper.IT_HEAD_SHIP_INSTRU.item.add(newInstructions2);  
 			 shippingnotesstr = shippingnotesstr.subString(95, shippingnotesstr.length());
 				} while (shippingnotesstr.length() > 95);
               sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT newInstructions3 = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT();
			newInstructions3.TEXT=shippingnotesstr;
 			orderInfoWrapper.IT_HEAD_SHIP_INSTRU.item.add(newInstructions3); 
                system.debug('shipping notes array'+orderInfoWrapper.IT_HEAD_SHIP_INSTRU.item); 
				}
         
			
			orderInfoWrapper.IT_ITEMIN = new sapComDocumentSapRfcFunctions.IT_ITEMIN_element();
			orderInfoWrapper.IT_ITEMIN.item= new List<sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_ITEM>();
			orderInfoWrapper.IT_ITEM_COMMENTS = new sapComDocumentSapRfcFunctions.IT_ITEM_COMMENTS_element();
			orderInfoWrapper.IT_ITEM_COMMENTS.item= new List<sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT>();
			Integer itemNum=1;
			for(ccrz__E_OrderItem__c oi:orderItems){
				sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_ITEM sapOI= new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_ITEM();
				sapOI.ITEM=String.valueOf(itemNum);
				if(oi.ccrz__Product__r.ccrz__SKU__c == 'requestedSku'){
					//sapOI.PART_NUMBER='INVALIDCAT';
					sapOI.PART_NUMBER='';
					sapOI.DESCRIPTION=oi.ccrz__ExtName__c;
					/*if(oi.ccrz__OriginalItemPrice__c!=0.01){
						sapOI.PART_NUMBER='VALIDCAT';
					}*/

				}
				else{
					sapOI.PART_NUMBER=oi.ccrz__Product__r.ccrz__SKU__c;
					sapOI.DESCRIPTION=oi.ccrz__Product__r.MaterialDescription__c;
				}

				sapOI.QUANTITY=String.valueOf(oi.ccrz__Quantity__c);
				if(oi.ccrz__Price__c == 0 && newOrder.ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_Order_Block__c!='Z1'){
					sapOI.PRICE=String.valueOf('0.01');
				}else {
					sapOI.PRICE=String.valueOf(oi.ccrz__Price__c);
				}
				sapOI.LABELLING_MARKS = oi.Type_Marks__c;
				sapOI.UOM = UtilityClass.convertUomLabelToUomCode(oi.ccrz__UnitOfMeasure__c);
				sapOI.REQ_DATE=String.valueOf(oi.Requested_Delivery_Date__c);
				//sapOI.LABELLING_MARKS=oi.Comments__c;
				sapOI.PRICELIST = oi.Agreement_Number__c;

				sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT newComment = new sapComDocumentSapRfcFunctions.x_xGEL_xHY_ORDER_TEXT();
				if(null != oi.ccrz__Comments__c && oi.ccrz__Comments__c != ''){
					newComment.ITEM = String.valueOf(itemNum);
					newComment.TEXT=oi.ccrz__Comments__c;
				} else {
					newComment.ITEM = String.valueOf(itemNum);
					newComment.TEXT=oi.Comments__c;
				}
				orderInfoWrapper.IT_ITEM_COMMENTS.item.add(newComment);
				orderInfoWrapper.IT_ITEMIN.item.add(sapOI);
				itemNum+=1;
			}
			system.debug('orderInfoWrapper '+orderInfoWrapper);
            if(!Test.isRunningTest()) {
				sapComDocumentSapRfcFunctions.x_xGEL_xSFB2B_ORDER_CREATE_Response_element resp = stub.SI_SFB2B_OrderCreate_472_OB_SYNC_N3(orderInfoWrapper);
				system.debug('resp '+resp);
				if(resp.E_SALES_NUMBER.trim()!='0'){
					return resp.E_SALES_NUMBER.trim();
				}
				if(resp.E_MESSAGE!=null){
					return 'Msg~'+resp.E_MESSAGE;
				}
            }
		} catch (System.CalloutException cex){
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','createOrder');
			System.debug('step' +cex.getMessage());
			System.debug('step' + cex.getLineNumber());
		}
		return null;
	}

	public OrderController.OrderDetails orderDisplay(OrderController.OrderRequest req){

		Warehouse__mdt[] warehouseRecords = [Select Code__c, Order_Cutoff__c, Location__c from Warehouse__mdt];
		String endpointURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SAP_SOAP'].Endpoint.removeStart('https://');

		gecurrentCom479Orderdisplay.HTTPS_Port stub = new gecurrentCom479Orderdisplay.HTTPS_Port();
		//gecurrentComCom479Orderdisplay.HTTPS_Port stub = new gecurrentComCom479Orderdisplay.HTTPS_Port();
		stub.inputHttpHeaders_x=new Map<String,String>();
		stub.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		stub.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
		stub.inputHttpHeaders_x.put('Host', endpointURL);

		stub.endpoint_x = endpointMap.get('ORDER_DISPLAY');
		system.debug('endpoint dbg: '+endpointMap.get('ORDER_DISPLAY'));
		stub.timeout_x=120000;

		sapComDocSapRfcFunctionsOD.ET_HEAD_COMMENTS_element ET_HEAD_COMMENTS = new sapComDocSapRfcFunctionsOD.ET_HEAD_COMMENTS_element();
		sapComDocSapRfcFunctionsOD.ET_HEAD_SHIP_INSTRU_element ET_HEAD_SHIP_INSTRU = new sapComDocSapRfcFunctionsOD.ET_HEAD_SHIP_INSTRU_element();
		sapComDocSapRfcFunctionsOD.ET_ITEM_COMMENTS_element ET_ITEM_COMMENTS = new sapComDocSapRfcFunctionsOD.ET_ITEM_COMMENTS_element();
		sapComDocSapRfcFunctionsOD.ET_SALES_DEL_INV_DATA_element ET_SALES_DEL_INV_DATA = new sapComDocSapRfcFunctionsOD.ET_SALES_DEL_INV_DATA_element();
		sapComDocSapRfcFunctionsOD.ET_SALES_HEADER_DATA_element ET_SALES_HEADER_DATA = new sapComDocSapRfcFunctionsOD.ET_SALES_HEADER_DATA_element();
		sapComDocSapRfcFunctionsOD.ET_SALES_ITEM_DATA_element ET_SALES_ITEM_DATA = new sapComDocSapRfcFunctionsOD.ET_SALES_ITEM_DATA_element();
		sapComDocSapRfcFunctionsOD.ET_SCHEDULE_DATA_element ET_SCHEDULE_DATA = new sapComDocSapRfcFunctionsOD.ET_SCHEDULE_DATA_element();
		sapComDocSapRfcFunctionsOD.ET_SHIPMENT_HEADER_element ET_SHIPMENT_HEADER = new sapComDocSapRfcFunctionsOD.ET_SHIPMENT_HEADER_element();
		sapComDocSapRfcFunctionsOD.ET_SHIPMENT_LINES_element ET_SHIPMENT_LINES = new sapComDocSapRfcFunctionsOD.ET_SHIPMENT_LINES_element();
		sapComDocSapRfcFunctionsOD.IT_DIST_CHENNEL_element IT_DIST_CHENNEL = new sapComDocSapRfcFunctionsOD.IT_DIST_CHENNEL_element();
		sapComDocSapRfcFunctionsOD.IT_DIVISION_element IT_DIVISION = new sapComDocSapRfcFunctionsOD.IT_DIVISION_element();
		sapComDocSapRfcFunctionsOD.IT_EXT_REP_CODE_element IT_EXT_REP_CODE = new sapComDocSapRfcFunctionsOD.IT_EXT_REP_CODE_element();
		sapComDocSapRfcFunctionsOD.IT_INT_REP_CODE_element IT_INT_REP_CODE = new sapComDocSapRfcFunctionsOD.IT_INT_REP_CODE_element();
		sapComDocSapRfcFunctionsOD.IT_SALES_ORDER_element IT_SALES_ORDER = new sapComDocSapRfcFunctionsOD.IT_SALES_ORDER_element();
		sapComDocSapRfcFunctionsOD.IT_SALES_ORG_element IT_SALES_ORG = new sapComDocSapRfcFunctionsOD.IT_SALES_ORG_element();
		sapComDocSapRfcFunctionsOD.IT_SOLD_TO_element IT_SOLD_TO = new sapComDocSapRfcFunctionsOD.IT_SOLD_TO_element();

		sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORDERS orderItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORDERS();
		orderItem.VBELN = req.orderNumber;
		IT_SALES_ORDER.item = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORDERS>();
		IT_SALES_ORDER.item.add(orderItem);

		sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORG orgItem = new sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORG();
		orgItem.VKORG = req.salesOrg;
		IT_SALES_ORG.item = new List<sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORG>();
		IT_SALES_ORG.item.add(orgItem);

		sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_ORDER_DISPLAY_Response_element response_x = new sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_ORDER_DISPLAY_Response_element();
		response_x = stub.SI_SFB2B_OrderDisplay_479_OB_SYNC(ET_HEAD_COMMENTS, ET_HEAD_SHIP_INSTRU, ET_ITEM_COMMENTS, ET_SALES_DEL_INV_DATA,
				ET_SALES_HEADER_DATA, ET_SALES_ITEM_DATA, ET_SCHEDULE_DATA, ET_SHIPMENT_HEADER,
				ET_SHIPMENT_LINES, IT_DIST_CHENNEL, IT_DIVISION, IT_EXT_REP_CODE, IT_INT_REP_CODE,
				IT_SALES_ORDER, IT_SALES_ORG, IT_SOLD_TO);
		// System.debug('the response:');
		// System.debug(response_x);

		OrderController.OrderDetails orderDetails = new OrderController.OrderDetails();

		List<OrderController.ET_HEAD_ORDER_TEXT> headComments = new List<OrderController.ET_HEAD_ORDER_TEXT>();
		OrderController.ET_HEAD_ORDER_TEXT reqComment;
		if(response_x.ET_HEAD_COMMENTS.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT resComment : response_x.ET_HEAD_COMMENTS.item){
				reqComment = new OrderController.ET_HEAD_ORDER_TEXT();
				if(resComment.ITEM != null) reqComment.ITEM = resComment.ITEM;
				if(resComment.TEXT != null) reqComment.TEXT = resComment.TEXT;
				headComments.add(reqComment);
			}
		}
		orderDetails.headComments = headComments;

		List<OrderController.ET_HEAD_ORDER_TEXT> headShipInstru = new List<OrderController.ET_HEAD_ORDER_TEXT>();
		OrderController.ET_HEAD_ORDER_TEXT reqInstru;
		if(response_x.ET_HEAD_SHIP_INSTRU.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT resInstru : response_x.ET_HEAD_SHIP_INSTRU.item){
				reqInstru = new OrderController.ET_HEAD_ORDER_TEXT();
				if(resInstru.ITEM != null) reqInstru.ITEM = resInstru.ITEM;
				if(resInstru.TEXT != null) reqInstru.TEXT = resInstru.TEXT;
				headShipInstru.add(reqInstru);
			}
		}
		orderDetails.headShipInstru = headShipInstru;

		List<OrderController.ET_HEAD_ORDER_TEXT> itemComments = new List<OrderController.ET_HEAD_ORDER_TEXT>();
		OrderController.ET_HEAD_ORDER_TEXT reqItemComment;
		if(response_x.ET_ITEM_COMMENTS.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_ORDER_TEXT resItemComment : response_x.ET_ITEM_COMMENTS.item){
				reqItemComment = new OrderController.ET_HEAD_ORDER_TEXT();
				if(resItemComment.ITEM != null) reqItemComment.ITEM = resItemComment.ITEM;
				if(resItemComment.TEXT != null) reqItemComment.TEXT = resItemComment.TEXT;
				itemComments.add(reqItemComment);
			}
		}
		orderDetails.itemComments = itemComments;

		List<OrderController.ET_SALES_DEL_INV_DATA_ITEM> salesDelInvData = new List<OrderController.ET_SALES_DEL_INV_DATA_ITEM>();
		OrderController.ET_SALES_DEL_INV_DATA_ITEM reqDelInvItem;
		if(response_x.ET_SALES_DEL_INV_DATA.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_DEL_INV_DATA resDelInvItem : response_x.ET_SALES_DEL_INV_DATA.item){
				reqDelInvItem = new OrderController.ET_SALES_DEL_INV_DATA_ITEM();
				if(resDelInvItem.ORDER_NUMBER != null) reqDelInvItem.ORDER_NUMBER = resDelInvItem.ORDER_NUMBER;
				if(resDelInvItem.ITEM_NUMBER != null) reqDelInvItem.ITEM_NUMBER = resDelInvItem.ITEM_NUMBER;
				if(resDelInvItem.DEL_NUMBER != null) reqDelInvItem.DEL_NUMBER = resDelInvItem.DEL_NUMBER;
				if(resDelInvItem.DEL_ITEM_NUMBER != null) reqDelInvItem.DEL_ITEM_NUMBER = resDelInvItem.DEL_ITEM_NUMBER;
				if(resDelInvItem.PRODUCT_NUMBER != null) reqDelInvItem.PRODUCT_NUMBER = resDelInvItem.PRODUCT_NUMBER;
				if(resDelInvItem.PRODUCT_DESCRIPTION != null) reqDelInvItem.PRODUCT_DESCRIPTION = resDelInvItem.PRODUCT_DESCRIPTION;
				if(resDelInvItem.INVOICE_NUMBER != null) reqDelInvItem.INVOICE_NUMBER = resDelInvItem.INVOICE_NUMBER;
				if(resDelInvItem.INVOICE_ITEM != null) reqDelInvItem.INVOICE_ITEM = resDelInvItem.INVOICE_ITEM;
				if(resDelInvItem.INVOICE_DATE != null) reqDelInvItem.INVOICE_DATE = resDelInvItem.INVOICE_DATE;
				salesDelInvData.add(reqDelInvItem);
			}
		}
		orderDetails.salesDelInvData = salesDelInvData;

		List<OrderController.ET_SALES_HEADER_DATA_ITEM> salesHeaderData = new List<OrderController.ET_SALES_HEADER_DATA_ITEM>();
		OrderController.ET_SALES_HEADER_DATA_ITEM reqSalesHeaderItem = new OrderController.ET_SALES_HEADER_DATA_ITEM();
		if(response_x.ET_SALES_HEADER_DATA.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SALES_HEADER_DATA resSalesHeaderItem : response_x.ET_SALES_HEADER_DATA.item){
				reqSalesHeaderItem = new OrderController.ET_SALES_HEADER_DATA_ITEM();
				if(resSalesHeaderItem.ORDER_NUMBER != null) reqSalesHeaderItem.ORDER_NUMBER = resSalesHeaderItem.ORDER_NUMBER;
				if(resSalesHeaderItem.PO_NUMBER != null) reqSalesHeaderItem.PO_NUMBER = resSalesHeaderItem.PO_NUMBER;
				if(resSalesHeaderItem.SOLD_TO_NUMBER != null) reqSalesHeaderItem.SOLD_TO_NUMBER = resSalesHeaderItem.SOLD_TO_NUMBER;
				if(resSalesHeaderItem.SOLD_TO_NAME != null) reqSalesHeaderItem.SOLD_TO_NAME = resSalesHeaderItem.SOLD_TO_NAME;
				if(resSalesHeaderItem.ORDER_DATE != null) reqSalesHeaderItem.ORDER_DATE = resSalesHeaderItem.ORDER_DATE;
				if(resSalesHeaderItem.REQ_DEL_DATE != null) reqSalesHeaderItem.REQ_DEL_DATE = resSalesHeaderItem.REQ_DEL_DATE;
				if(resSalesHeaderItem.TOTAL_NET_VALUE != null) reqSalesHeaderItem.TOTAL_NET_VALUE = resSalesHeaderItem.TOTAL_NET_VALUE;
				if(resSalesHeaderItem.ORDER_STATUS != null) reqSalesHeaderItem.ORDER_STATUS = resSalesHeaderItem.ORDER_STATUS;
				if(resSalesHeaderItem.OPPORTUNITY_ID != null) reqSalesHeaderItem.OPPORTUNITY_ID = resSalesHeaderItem.OPPORTUNITY_ID;
				if(resSalesHeaderItem.EXT_REP_CODE != null) reqSalesHeaderItem.EXT_REP_CODE = resSalesHeaderItem.EXT_REP_CODE;
				if(resSalesHeaderItem.INT_REP_CODE != null) reqSalesHeaderItem.INT_REP_CODE = resSalesHeaderItem.INT_REP_CODE;
				if(resSalesHeaderItem.SHIP_TO_NAME != null) reqSalesHeaderItem.SHIP_TO_NAME = resSalesHeaderItem.SHIP_TO_NAME;
				if(resSalesHeaderItem.SHIP_TO_STREET1 != null) reqSalesHeaderItem.SHIP_TO_STREET1 = resSalesHeaderItem.SHIP_TO_STREET1;
				if(resSalesHeaderItem.SHIP_TO_STREET2 != null) reqSalesHeaderItem.SHIP_TO_STREET2 = resSalesHeaderItem.SHIP_TO_STREET2;
				if(resSalesHeaderItem.SHIP_TO_CITY != null) reqSalesHeaderItem.SHIP_TO_CITY = resSalesHeaderItem.SHIP_TO_CITY;
				if(resSalesHeaderItem.SHIP_TO_STATE != null) reqSalesHeaderItem.SHIP_TO_STATE = resSalesHeaderItem.SHIP_TO_STATE;
				if(resSalesHeaderItem.SHIP_TO_ZIP != null) reqSalesHeaderItem.SHIP_TO_ZIP = resSalesHeaderItem.SHIP_TO_ZIP;
				if(resSalesHeaderItem.SHIP_TO_COUNTRY != null) reqSalesHeaderItem.SHIP_TO_COUNTRY = resSalesHeaderItem.SHIP_TO_COUNTRY;
				if(resSalesHeaderItem.BILL_TO_NAME != null) reqSalesHeaderItem.BILL_TO_NAME = resSalesHeaderItem.BILL_TO_NAME;
				if(resSalesHeaderItem.BILL_TO_STREET1 != null) reqSalesHeaderItem.BILL_TO_STREET1 = resSalesHeaderItem.BILL_TO_STREET1;
				if(resSalesHeaderItem.BILL_TO_STREET2 != null) reqSalesHeaderItem.BILL_TO_STREET2 = resSalesHeaderItem.BILL_TO_STREET2;
				if(resSalesHeaderItem.BILL_TO_CITY != null) reqSalesHeaderItem.BILL_TO_CITY = resSalesHeaderItem.BILL_TO_CITY;
				if(resSalesHeaderItem.BILL_TO_STATE != null) reqSalesHeaderItem.BILL_TO_STATE = resSalesHeaderItem.BILL_TO_STATE;
				if(resSalesHeaderItem.BILL_TO_ZIP != null) reqSalesHeaderItem.BILL_TO_ZIP = resSalesHeaderItem.BILL_TO_ZIP;
				if(resSalesHeaderItem.BILL_TO_COUNTRY != null) reqSalesHeaderItem.BILL_TO_COUNTRY = resSalesHeaderItem.BILL_TO_COUNTRY;
				if(resSalesHeaderItem.CURRENCY_x != null) reqSalesHeaderItem.CURRENCY_x = resSalesHeaderItem.CURRENCY_x;
				if(resSalesHeaderItem.SPECIAL_COMMENTS != null) reqSalesHeaderItem.SPECIAL_COMMENTS = resSalesHeaderItem.SPECIAL_COMMENTS;
				if(resSalesHeaderItem.TOTAL_COMMISSION != null) reqSalesHeaderItem.TOTAL_COMMISSION = resSalesHeaderItem.TOTAL_COMMISSION;
				if(resSalesHeaderItem.ORDER_SOURCE != null) reqSalesHeaderItem.ORDER_SOURCE = resSalesHeaderItem.ORDER_SOURCE;
				if(resSalesHeaderItem.TOTAL_WEEE != null) reqSalesHeaderItem.TOTAL_WEEE = resSalesHeaderItem.TOTAL_WEEE;
				if(resSalesHeaderItem.TOTAL_LIGHT_TAX != null) reqSalesHeaderItem.TOTAL_LIGHT_TAX = resSalesHeaderItem.TOTAL_LIGHT_TAX;
				if(resSalesHeaderItem.HEAD_DEL_BLOCK != null) reqSalesHeaderItem.HEAD_DEL_BLOCK = resSalesHeaderItem.HEAD_DEL_BLOCK;
				if(resSalesHeaderItem.BLOCK_DESCRIPTION != null) reqSalesHeaderItem.BLOCK_DESCRIPTION = resSalesHeaderItem.BLOCK_DESCRIPTION;
				if(resSalesHeaderItem.CREDIT_STATUS != null) reqSalesHeaderItem.CREDIT_STATUS = resSalesHeaderItem.CREDIT_STATUS;
				if(resSalesHeaderItem.SHIP_VIA != null) reqSalesHeaderItem.SHIP_VIA = resSalesHeaderItem.SHIP_VIA;
				if(resSalesHeaderItem.SAMPLE_ORDER_FLAG != null) reqSalesHeaderItem.SAMPLE_ORDER_FLAG = resSalesHeaderItem.SAMPLE_ORDER_FLAG;
				if(resSalesHeaderItem.COMP_PART_SHIP != null) reqSalesHeaderItem.COMP_PART_SHIP = resSalesHeaderItem.COMP_PART_SHIP;
				if(resSalesHeaderItem.CARRIER_ACCOUNT_NO != null) reqSalesHeaderItem.CARRIER_ACCOUNT_NO = resSalesHeaderItem.CARRIER_ACCOUNT_NO;
				if(resSalesHeaderItem.PROJECT_NAME != null) reqSalesHeaderItem.PROJECT_NAME = resSalesHeaderItem.PROJECT_NAME;
				if(resSalesHeaderItem.USER_NAME != null) reqSalesHeaderItem.USER_NAME = resSalesHeaderItem.USER_NAME;
				if(resSalesHeaderItem.USER_EMAIL != null) reqSalesHeaderItem.USER_EMAIL = resSalesHeaderItem.USER_EMAIL;
				if(resSalesHeaderItem.ADD_RECIPIENT_NAME != null) reqSalesHeaderItem.ADD_RECIPIENT_NAME = resSalesHeaderItem.ADD_RECIPIENT_NAME;
				if(resSalesHeaderItem.ADD_RECIPIENT_EMAIL != null) reqSalesHeaderItem.ADD_RECIPIENT_EMAIL = resSalesHeaderItem.ADD_RECIPIENT_EMAIL;
				if(resSalesHeaderItem.SHIP_LABEL_COMMENTS != null) reqSalesHeaderItem.SHIP_LABEL_COMMENTS = resSalesHeaderItem.SHIP_LABEL_COMMENTS;
				if(resSalesHeaderItem.ALLOW_BACK_ORDER != null) reqSalesHeaderItem.ALLOW_BACK_ORDER = resSalesHeaderItem.ALLOW_BACK_ORDER;
				if(resSalesHeaderItem.SHIPMENT_TYPE != null) reqSalesHeaderItem.SHIPMENT_TYPE = resSalesHeaderItem.SHIPMENT_TYPE;
				if(resSalesHeaderItem.PART_SHIP_ALLOWED != null) reqSalesHeaderItem.PART_SHIP_ALLOWED = resSalesHeaderItem.PART_SHIP_ALLOWED;
				if(resSalesHeaderItem.SHIP_CONTACT_NAME != null) reqSalesHeaderItem.SHIP_CONTACT_NAME = resSalesHeaderItem.SHIP_CONTACT_NAME;
				if(resSalesHeaderItem.SHIP_CONTACT_NUMBER != null) reqSalesHeaderItem.SHIP_CONTACT_NUMBER = resSalesHeaderItem.SHIP_CONTACT_NUMBER;
				if(resSalesHeaderItem.SALES_ORG != null) reqSalesHeaderItem.SALES_ORG = resSalesHeaderItem.SALES_ORG;
				if(resSalesHeaderItem.DIST_CHANNEL != null) reqSalesHeaderItem.DIST_CHANNEL = resSalesHeaderItem.DIST_CHANNEL;
				if(resSalesHeaderItem.DIVISION != null) reqSalesHeaderItem.DIVISION = resSalesHeaderItem.DIVISION;
				if(resSalesHeaderItem.INCOMPLETE != null) reqSalesHeaderItem.INCOMPLETE = resSalesHeaderItem.INCOMPLETE;
				if(resSalesHeaderItem.ORDER_TYPE != null) reqSalesHeaderItem.ORDER_TYPE = resSalesHeaderItem.ORDER_TYPE;
				if(resSalesHeaderItem.x_xGEL_xCONNECT_ORDNR != null) reqSalesHeaderItem.x_xGEL_xCONNECT_ORDNR = resSalesHeaderItem.x_xGEL_xCONNECT_ORDNR;
				salesHeaderData.add(reqSalesHeaderItem);
			}
		}
		orderDetails.salesHeaderData = salesHeaderData;

		List<OrderController.ET_SALES_ITEM_DATA_ITEM> salesItemData = new List<OrderController.ET_SALES_ITEM_DATA_ITEM>();
		OrderController.ET_SALES_ITEM_DATA_ITEM reqSalesItem;
		if(response_x.ET_SALES_ITEM_DATA.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ITEM_DATA resSalesItemData : response_x.ET_SALES_ITEM_DATA.item){
				reqSalesItem = new OrderController.ET_SALES_ITEM_DATA_ITEM();
				if(resSalesItemData.ORDER_NUMBER != null) reqSalesItem.ORDER_NUMBER = resSalesItemData.ORDER_NUMBER;
				if(resSalesItemData.ITEM_NUMBER != null) reqSalesItem.ITEM_NUMBER = resSalesItemData.ITEM_NUMBER;
				if(resSalesItemData.PRODUCT_NUMBER != null) reqSalesItem.PRODUCT_NUMBER = resSalesItemData.PRODUCT_NUMBER;
				if(resSalesItemData.PRODUCT_DESCRIPTION != null) reqSalesItem.PRODUCT_DESCRIPTION = resSalesItemData.PRODUCT_DESCRIPTION;
				if(resSalesItemData.CUST_REF_NUMBER != null) reqSalesItem.CUST_REF_NUMBER = resSalesItemData.CUST_REF_NUMBER;
				if(resSalesItemData.QUANTITY != null) reqSalesItem.QUANTITY = resSalesItemData.QUANTITY;
				if(resSalesItemData.SCH_DEL_DATE != null) reqSalesItem.SCH_DEL_DATE = resSalesItemData.SCH_DEL_DATE;
				if(resSalesItemData.REQ_DEL_DATE != null) reqSalesItem.REQ_DEL_DATE = resSalesItemData.REQ_DEL_DATE;
				if(resSalesItemData.UNIT_PRICE != null) reqSalesItem.UNIT_PRICE = resSalesItemData.UNIT_PRICE;
				if(resSalesItemData.ITEM_STATUS != null) reqSalesItem.ITEM_STATUS = resSalesItemData.ITEM_STATUS;
				if(resSalesItemData.ITEM_NET_VALUE != null) reqSalesItem.ITEM_NET_VALUE = resSalesItemData.ITEM_NET_VALUE;
				if(resSalesItemData.CURRENCY_x != null) reqSalesItem.CURRENCY_x = resSalesItemData.CURRENCY_x;
				if(resSalesItemData.SALES_UNIT != null) reqSalesItem.SALES_UNIT = resSalesItemData.SALES_UNIT;
				if(resSalesItemData.ITEM_COMM_PER != null) reqSalesItem.ITEM_COMM_PER = resSalesItemData.ITEM_COMM_PER;
				if(resSalesItemData.ITEM_COMM_VALUE != null) reqSalesItem.ITEM_COMM_VALUE = resSalesItemData.ITEM_COMM_VALUE;
				if(resSalesItemData.DIRECT_SUB_REASON != null) reqSalesItem.DIRECT_SUB_REASON = resSalesItemData.DIRECT_SUB_REASON;
				if(resSalesItemData.REASONFOR_REJECTION != null) reqSalesItem.REASONFOR_REJECTION = resSalesItemData.REASONFOR_REJECTION;
				if(resSalesItemData.PRICE_AGR_NUMBER != null) reqSalesItem.PRICE_AGR_NUMBER = resSalesItemData.PRICE_AGR_NUMBER;
				if(resSalesItemData.LIST_PRICE != null) reqSalesItem.LIST_PRICE = resSalesItemData.LIST_PRICE;
				if(resSalesItemData.SPECIAL_INSTRUCTIONS != null) reqSalesItem.SPECIAL_INSTRUCTIONS = resSalesItemData.SPECIAL_INSTRUCTIONS;
				if(resSalesItemData.PRICE_LIST != null) reqSalesItem.PRICE_LIST = resSalesItemData.PRICE_LIST;
				if(resSalesItemData.LEAD_TIME != null) reqSalesItem.LEAD_TIME = resSalesItemData.LEAD_TIME;
				if(resSalesItemData.REQUESTED_PRICE != null) reqSalesItem.REQUESTED_PRICE = resSalesItemData.REQUESTED_PRICE;
				if(resSalesItemData.CUSTOMER_DESCRIPTION != null) reqSalesItem.CUSTOMER_DESCRIPTION = resSalesItemData.CUSTOMER_DESCRIPTION;
				if(resSalesItemData.WEEE != null) reqSalesItem.WEEE = resSalesItemData.WEEE;
				if(resSalesItemData.LIGHT_TAX != null) reqSalesItem.LIGHT_TAX = resSalesItemData.LIGHT_TAX;
				if(resSalesItemData.ITEM_DEL_BLOCK != null) reqSalesItem.ITEM_DEL_BLOCK = resSalesItemData.ITEM_DEL_BLOCK;
				if(resSalesItemData.BLOCK_DESCRIPTION != null) reqSalesItem.BLOCK_DESCRIPTION = resSalesItemData.BLOCK_DESCRIPTION;
				if(resSalesItemData.QTY_SHIPPED != null) reqSalesItem.QTY_SHIPPED = resSalesItemData.QTY_SHIPPED;
				if(resSalesItemData.ADP_PRICE != null) reqSalesItem.ADP_PRICE = resSalesItemData.ADP_PRICE;
				if(resSalesItemData.PRICE_VALUE != null) reqSalesItem.PRICE_VALUE = resSalesItemData.PRICE_VALUE;
				if(resSalesItemData.PRICE_UNIT != null) reqSalesItem.PRICE_UNIT = resSalesItemData.PRICE_UNIT;
				if(resSalesItemData.INCOMPLETE != null) reqSalesItem.INCOMPLETE = resSalesItemData.INCOMPLETE;
                if(resSalesItemData.OVERAGE_COMMISSION != null) reqSalesItem.OVERAGE_COMMISSION = resSalesItemData.OVERAGE_COMMISSION;
				if(resSalesItemData.STANDARD_COMMISSION != null) reqSalesItem.STANDARD_COMMISSION = resSalesItemData.STANDARD_COMMISSION;

				salesItemData.add(reqSalesItem);
			}
		}
		orderDetails.salesItemData = salesItemData;

		List<OrderController.ET_SCHEDULE_DATA_ITEM> scheduleData = new List<OrderController.ET_SCHEDULE_DATA_ITEM>();
		OrderController.ET_SCHEDULE_DATA_ITEM reqScheduleDataItem;
		if(response_x.ET_SCHEDULE_DATA.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SCHEDULE_LINE_DATA resScheduleDataItem : response_x.ET_SCHEDULE_DATA.item){
				reqScheduleDataItem = new OrderController.ET_SCHEDULE_DATA_ITEM();
				if(resScheduleDataItem.ORDER_NUMBER != null) reqScheduleDataItem.ORDER_NUMBER = resScheduleDataItem.ORDER_NUMBER;
				if(resScheduleDataItem.ITEM_NUMBER != null) reqScheduleDataItem.ITEM_NUMBER = resScheduleDataItem.ITEM_NUMBER;
				if(resScheduleDataItem.DEL_NUMBER != null) reqScheduleDataItem.DEL_NUMBER = resScheduleDataItem.DEL_NUMBER;
				if(resScheduleDataItem.DEL_ITEM_NUMBER != null) reqScheduleDataItem.DEL_ITEM_NUMBER = resScheduleDataItem.DEL_ITEM_NUMBER;
				if(resScheduleDataItem.QUANTITY != null) reqScheduleDataItem.QUANTITY = resScheduleDataItem.QUANTITY;
				if(resScheduleDataItem.SALES_UNIT != null) reqScheduleDataItem.SALES_UNIT = resScheduleDataItem.SALES_UNIT;
				if(resScheduleDataItem.CARRIER_NAME != null) reqScheduleDataItem.CARRIER_NAME = resScheduleDataItem.CARRIER_NAME;
				if(resScheduleDataItem.SHIPPED_FROM != null) reqScheduleDataItem.SHIPPED_FROM = getWarehouseLocation(warehouseRecords, resScheduleDataItem.SHIPPED_FROM);
				if(resScheduleDataItem.INVOICE_NUMBER != null) reqScheduleDataItem.INVOICE_NUMBER = resScheduleDataItem.INVOICE_NUMBER;
				if(resScheduleDataItem.INVOICE_ITEM != null) reqScheduleDataItem.INVOICE_ITEM = resScheduleDataItem.INVOICE_ITEM;
				if(resScheduleDataItem.INVOICE_DATE != null) reqScheduleDataItem.INVOICE_DATE = resScheduleDataItem.INVOICE_DATE;
				if(resScheduleDataItem.CONFIRMED != null) reqScheduleDataItem.CONFIRMED = resScheduleDataItem.CONFIRMED;
				if(resScheduleDataItem.EST_SHIP_DATE != null) reqScheduleDataItem.EST_SHIP_DATE = resScheduleDataItem.EST_SHIP_DATE;
				if(resScheduleDataItem.EST_DEL_DATE != null) reqScheduleDataItem.EST_DEL_DATE = resScheduleDataItem.EST_DEL_DATE;
				if(resScheduleDataItem.ACT_SHIP_DATE != null) reqScheduleDataItem.ACT_SHIP_DATE = resScheduleDataItem.ACT_SHIP_DATE;
				if(resScheduleDataItem.ACT_DEL_DATE != null) reqScheduleDataItem.ACT_DEL_DATE = resScheduleDataItem.ACT_DEL_DATE;
				if(resScheduleDataItem.TRACKING_NUMBER != null) reqScheduleDataItem.TRACKING_NUMBER = resScheduleDataItem.TRACKING_NUMBER;
				if(resScheduleDataItem.SHIPMENT_NUMBER != null) reqScheduleDataItem.SHIPMENT_NUMBER = resScheduleDataItem.SHIPMENT_NUMBER;
				if(resScheduleDataItem.FPDD != null) reqScheduleDataItem.FPDD = resScheduleDataItem.FPDD;
				scheduleData.add(reqScheduleDataItem);
			}
		}
		orderDetails.scheduleData = scheduleData;

		List<OrderController.ET_SHIPMENT_HEADER_ITEM> shipmentHeader = new List<OrderController.ET_SHIPMENT_HEADER_ITEM>();
		OrderController.ET_SHIPMENT_HEADER_ITEM reqShipmentHeaderItem;
		if(response_x.ET_SHIPMENT_HEADER.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xSDOM_SHIPMENT_HEAD resShipmentHeaderItem : response_x.ET_SHIPMENT_HEADER.item){
				reqShipmentHeaderItem = new OrderController.ET_SHIPMENT_HEADER_ITEM();
				if(resShipmentHeaderItem.WADAT != null) reqShipmentHeaderItem.WADAT = resShipmentHeaderItem.WADAT;
				if(resShipmentHeaderItem.TDLNR != null) reqShipmentHeaderItem.TDLNR = resShipmentHeaderItem.TDLNR;
				if(resShipmentHeaderItem.VTEXT != null) reqShipmentHeaderItem.VTEXT = resShipmentHeaderItem.VTEXT;
				if(resShipmentHeaderItem.TNDR_TRKID != null) reqShipmentHeaderItem.TNDR_TRKID = resShipmentHeaderItem.TNDR_TRKID;
				if(resShipmentHeaderItem.CARRIER_NAME != null) reqShipmentHeaderItem.CARRIER_NAME = resShipmentHeaderItem.CARRIER_NAME;
				if(resShipmentHeaderItem.TKNUM != null) reqShipmentHeaderItem.TKNUM = resShipmentHeaderItem.TKNUM;
				shipmentHeader.add(reqShipmentHeaderItem);
			}
		}
		orderDetails.shipmentHeader = shipmentHeader;

		List<OrderController.ET_SHIPMENT_LINES_ITEM> shipmentLines = new List<OrderController.ET_SHIPMENT_LINES_ITEM>();
		OrderController.ET_SHIPMENT_LINES_ITEM reqShipmentLinesItem;
		if(response_x.ET_SHIPMENT_LINES.item != null){
			for(sapComDocSapRfcFunctionsOD.x_xGEL_xSFB2B_SDOM_SHIPMENT_LINES resShipmentLinesItem : response_x.ET_SHIPMENT_LINES.item){
				reqShipmentLinesItem = new OrderController.ET_SHIPMENT_LINES_ITEM();
				if(resShipmentLinesItem.VBELN != null) reqShipmentLinesItem.VBELN = resShipmentLinesItem.VBELN;
				if(resShipmentLinesItem.POSNR != null) reqShipmentLinesItem.POSNR = resShipmentLinesItem.POSNR;
				if(resShipmentLinesItem.MATNR != null) reqShipmentLinesItem.MATNR = resShipmentLinesItem.MATNR;
				if(resShipmentLinesItem.ARKTX != null) reqShipmentLinesItem.ARKTX = resShipmentLinesItem.ARKTX;
				if(resShipmentLinesItem.LFIMG != null) reqShipmentLinesItem.LFIMG = resShipmentLinesItem.LFIMG;
				if(resShipmentLinesItem.TKNUM != null) reqShipmentLinesItem.TKNUM = resShipmentLinesItem.TKNUM;
				if(resShipmentLinesItem.TPNUM != null) reqShipmentLinesItem.TPNUM = resShipmentLinesItem.TPNUM;
				if(resShipmentLinesItem.VOLUM != null) reqShipmentLinesItem.VOLUM = resShipmentLinesItem.VOLUM;
				if(resShipmentLinesItem.BRGEW != null) reqShipmentLinesItem.BRGEW = resShipmentLinesItem.BRGEW;
				shipmentLines.add(reqShipmentLinesItem);
			}
		}
		orderDetails.shipmentLines = shipmentLines;

		List<OrderController.IT_EXT_REP_CODE_ITEM> extRepCode = new List<OrderController.IT_EXT_REP_CODE_ITEM>();
		OrderController.IT_EXT_REP_CODE_ITEM reqExtRepCodeItem;
		if(response_x.IT_EXT_REP_CODE != null){
			if(response_x.IT_EXT_REP_CODE.item != null){
				for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_EXT_AGENTS resExtRepCodeItem : response_x.IT_EXT_REP_CODE.item){
					reqExtRepCodeItem = new OrderController.IT_EXT_REP_CODE_ITEM();
					if(resExtRepCodeItem.KUNNR != null) reqExtRepCodeItem.KUNNR = resExtRepCodeItem.KUNNR;
					extRepCode.add(reqExtRepCodeItem);
				}
			}
		}
		orderDetails.extRepCode = extRepCode;

		List<OrderController.IT_INT_REP_CODE_ITEM> intRepCode = new List<OrderController.IT_INT_REP_CODE_ITEM>();
		OrderController.IT_INT_REP_CODE_ITEM reqIntRepCodeItem;
		if(response_x.IT_INT_REP_CODE != null){
			if(response_x.IT_INT_REP_CODE.item != null){
				for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_INT_REPS resIntRepCodeItem : response_x.IT_INT_REP_CODE.item){
					reqIntRepCodeItem = new OrderController.IT_INT_REP_CODE_ITEM();
					if(resIntRepCodeItem.PERNR != null) reqIntRepCodeItem.PERNR = resIntRepCodeItem.PERNR;
					extRepCode.add(reqExtRepCodeItem);
				}
			}
		}
		orderDetails.intRepCode = intRepCode;

		List<OrderController.IT_EXT_REP_CODE_ITEM> soldTo = new List<OrderController.IT_EXT_REP_CODE_ITEM>();
		OrderController.IT_EXT_REP_CODE_ITEM reqSoldToItem;
		if(response_x.IT_SOLD_TO != null){
			if(response_x.IT_SOLD_TO.item != null){
				for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_EXT_AGENTS resSoldToItem : response_x.IT_SOLD_TO.item){
					reqSoldToItem = new OrderController.IT_EXT_REP_CODE_ITEM();
					if(resSoldToItem.KUNNR != null) reqSoldToItem.KUNNR = resSoldToItem.KUNNR;
					extRepCode.add(reqSoldToItem);
				}
			}
		}
		orderDetails.soldTo = soldTo;

		List<OrderController.IT_SALES_ORDER_ITEM> salesOrder = new List<OrderController.IT_SALES_ORDER_ITEM>();
		OrderController.IT_SALES_ORDER_ITEM reqSalesOrderItem;
		if(response_x.IT_SALES_ORDER != null){
			if(response_x.IT_SALES_ORDER.item != null){
				for(sapComDocSapRfcFunctionsOD.x_xGEL_xHY_SALES_ORDERS resSalesOrderItem : response_x.IT_SALES_ORDER.item){
					reqSalesOrderItem = new OrderController.IT_SALES_ORDER_ITEM();
					if(resSalesOrderItem.VBELN != null) reqSalesOrderItem.VBELN = resSalesOrderItem.VBELN;
					salesOrder.add(reqSalesOrderItem);
				}
			}
		}
		orderDetails.salesOrder = salesOrder;

		return orderDetails;
	}

	public PriceAgreementController.PriceAgreementResponse priceAgreementValidate(PriceAgreementController.PriceAgreementRequest request) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'priceAgreementValidate');
		system.debug('PriceAgreementRequest '+request);

		PriceAgreementController.PriceAgreementResponse response = new PriceAgreementController.PriceAgreementResponse();
		gecurrentCom475Agreementprice.HTTPS_Port port = new gecurrentCom475Agreementprice.HTTPS_Port();
		port.inputHttpHeaders_x=new Map<String,String>();
		port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		port.endpoint_x = endpointMap.get('PRICE_AGREEMENT_VALIDATE');
		port.timeout_x = 120000;

		try {

			String I_INT_REP = '';

			sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element response_x = new sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element();
			sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element ET_MATERIALS_OUT  = new sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element();
			sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element ET_SCHEDULELINE_DATA = new sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element();
			sapComDocSapRfcFunctionsAP.IT_MATERIALS_element IT_MATERIALS = new sapComDocSapRfcFunctionsAP.IT_MATERIALS_element();

			List<sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS> pmList =  new List<sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS>();
			Map<String, PriceAgreementController.PriceAgreementItem> lineNumToItemMap = new Map<String, PriceAgreementController.PriceAgreementItem>();

			for(PriceAgreementController.PriceAgreementItem pai : request.priceAgreementItemList) {
				sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS pm = new sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS();

				lineNumToItemMap.put(String.valueOf(pai.lineNumber), pai);
				pm.LINE_NUMBER = String.valueOf(pai.lineNumber);
				if(pai.material == 'requestedSku'){
					pm.PART_NUMBER = '';
					pm.PART_DESCRIPTION = pai.material;
				}
				else{
					pm.PART_NUMBER = pai.material;
					pm.PART_DESCRIPTION = pai.description;
				}

				pm.QUANTITY = String.valueOf(pai.quantity);
				pm.SALES_UNIT = UtilityClass.convertUomLabelToUomCode(pai.UOM);
				pm.CURRENCY_x = pai.currencyISOCode;

				//pm.PART_DESCRIPTION = pai.material;
				pm.REQ_DEL_DATE = pai.reqDelDate;
				pm.REQUESTED_PRICE = String.valueOf(pai.requestedPrice);
				pmList.add(pm);
			}
			IT_MATERIALS.item = pmList;


			response_x = port.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6(request.agreement,request.agrDate,request.callType,
					request.distChannel, request.division, request.extAgent,
					I_INT_REP, request.orderFlag, request.orderReason,
					request.orderType, request.poNumber, request.salesOrg,
					request.customer, request.userType, request.validateFlag,
					ET_MATERIALS_OUT, ET_SCHEDULELINE_DATA, IT_MATERIALS);

			ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'getRealTimePricing');
			system.debug('response_x: '+response_x);

			if(response_x != null){

				response.agreement =  request.agreement;
				response.agrDate =  request.agrDate;
				response.distChannel =  request.distChannel;
				response.division =  request.division;
				response.orderFlag =  request.orderFlag;
				response.orderReason =  request.orderReason;
				response.orderType =  request.orderType;
				response.poNumber =  request.poNumber;
				response.salesOrg =  request.salesOrg;
				response.customer =  request.customer;
				response.userType =  request.userType;
				response.errMessage = response_x.E_ERR_MESSAGE;
				response.poDuplicate = response_x.E_PO_DUPLICATE;

				List<sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT> paoList = null;

				if(response_x.ET_MATERIALS_OUT != null && response_x.ET_MATERIALS_OUT.item != null ){
					paoList = response_x.ET_MATERIALS_OUT.item;
				}

				List<PriceAgreementController.PriceAgreementItem> priceAgreementList = new List<PriceAgreementController.PriceAgreementItem>();

				if(paoList != null){
					for(sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT pao : paoList){
						PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
						if(String.isNotBlank(pao.LINE_NUMBER)){
							pai.lineNumber = Integer.valueOf(pao.LINE_NUMBER);
						}

						String trimmedLineNum = String.valueOf(Integer.valueOf(pao.LINE_NUMBER));
						System.debug('trimming line num 1');
						System.debug(trimmedLineNum);
						System.debug(lineNumToItemMap.keySet());
						System.debug(lineNumToItemMap.get(trimmedLineNum));
						if((lineNumToItemMap.get(trimmedLineNum) != null) && (String.isNotBlank(lineNumToItemMap.get(trimmedLineNum).material))){
							pai.SKU = lineNumToItemMap.get(trimmedLineNum).material;
						}
						//pai.SKU = pao.PART_NUMBER;
						pai.material = pao.PART_NUMBER;
						pai.description = pao.PART_DESCRIPTION;

						if(String.isNotBlank(pao.QUANTITY)){
							pai.quantity = Integer.valueOf(pao.QUANTITY);
						}
						if(String.isNotBlank(pao.QTY_ON_HAND)){
							pai.quantityOnHand = Integer.valueOf(pao.QTY_ON_HAND);
						}
						if(String.isNotBlank(pao.WAREHOUSE_AVAILABILITY)){
							pai.warehouseAvailability = Integer.valueOf(pao.WAREHOUSE_AVAILABILITY);
						}
						if(String.isNotBlank(pao.ADP)){
							pai.adpPrice = Decimal.valueOf(pao.ADP);
						}

						if(String.isNotBlank(pao.ADP_PERC)){
							pai.globalCommission = Decimal.valueOf(pao.ADP_PERC);
						}
						if(String.isNotBlank(pao.FLOOR_PRICE)){
							pai.floorPrice = Decimal.valueOf(pao.FLOOR_PRICE);
						}
						if(String.isNotBlank(pao.FLOOR_PERC)){
							pai.floorCommission = Decimal.valueOf(pao.FLOOR_PERC);
						}
						if(String.isNotBlank(pao.SLIDING_COM)){
							pai.slidingCommission = Decimal.valueOf(pao.SLIDING_COM);
						}
						if(String.isNotBlank(pao.SLIDING_COM_PERC)){
							pai.slidingCommissionPercentage = Decimal.valueOf(pao.SLIDING_COM_PERC);
						}
						if(String.isNotBlank(pao.OVERAGE_AMOUNT)){
							pai.overageAmount = Decimal.valueOf(pao.OVERAGE_AMOUNT);
						}
						if(String.isNotBlank(pao.OVERAGE_PERC_AMNT)){
							pai.overagePercentageAmount = Decimal.valueOf(pao.OVERAGE_PERC_AMNT);
						}
						if(String.isNotBlank(pao.OVERAGE_PERC_PERC)){
							pai.overagePercentagePerc = Decimal.valueOf(pao.OVERAGE_PERC_PERC);
						}

						pai.UOM = pao.SALES_UNIT;

						if(String.isNotBlank(pao.REQUESTED_PRICE)){
							pai.requestedPrice = Decimal.valueOf(pao.REQUESTED_PRICE);
						}
						if(String.isNotBlank(pao.BOOKP_PRICE)){
							pai.bookPrice = Decimal.valueOf(pao.BOOKP_PRICE);
						}
						pai.leadTime = pao.LEAD_TIME;
						if(String.isNotBlank(pao.AVAILABLE_QTY)){
							pai.availableQty = Integer.valueOf(pao.AVAILABLE_QTY);
						}
						if(String.isNotBlank(pao.COMMISON)){
							pai.commission = Decimal.valueOf(pao.COMMISON);
						}
						if(String.isNotBlank(pao.COMMISON_PER)){
							pai.commissionPer = Decimal.valueOf(pao.COMMISON_PER);
						}
						pai.weeeLamp = pao.WEEE_LAMP;
						pai.weeeLight = pao.WEEE_LIGHT;
						pai.weeeLampIr = pao.WEEE_LAMP_IR;
						pai.message = pao.MESSAGE;
						pai.substitueMaterial = pao.SUBSTITUTE_MATERIAL;
						pai.countryOfOrigin = pao.COUNTRY_OF_ORIGIN;
						pai.substitueReason = pao.SUBSTITUTION_REASON;
						pai.reasonRej = pao.REASON_REJ;
						pai.reasonRejText  = pao.REASON_REJ_TEXT;
						pai.agreement = pao.PRICE_AGREMENT;
						pai.productHierarchy = pao.PRODUCT_HIERARCHY;
						pai.plant = pao.PLANT;
						pai.currencyISOCode = pao.CURRENCY_x;
						if(String.isNotBlank(pao.EXTENDED_PRICE)){
							pai.extendedPrice = Decimal.valueOf(pao.EXTENDED_PRICE);
						}
						if(String.isNotBlank(pao.ROUNDED_QTY)){
							pai.roundedQty = Integer.valueOf(pao.ROUNDED_QTY);
						}
						if(String.isNotBlank(pao.STANDARD_PACK_QTY)){
							pai.standardPackQty = Integer.valueOf(pao.STANDARD_PACK_QTY);
						}
						if(String.isNotBlank(pao.PALLET_QTY)){
							pai.palletQty = Integer.valueOf(pao.PALLET_QTY);
						}
						if(String.isNotBlank(pao.UK_PALLET_QTY)){
							pai.ukPalletQty = Integer.valueOf(pao.UK_PALLET_QTY);
						}
						pai.lightTax =  pao.LIGHT_TAX;
						if(String.isNotBlank(pao.PRICE_AGREMENT_VALUE)){
							pai.priceAgreementValue = Decimal.valueOf(pao.PRICE_AGREMENT_VALUE);
						}
						if(String.isNotBlank(pao.NET_CREDIT)){
							pai.netCredit = Decimal.valueOf(pao.NET_CREDIT);
						}
						priceAgreementList.add(pai);
					}
				}
				response.priceAgreementItemList = priceAgreementList;

			}

		} catch (System.CalloutException cex) {
			System.debug('step' + cex);
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','orderDisplay');

		}
		System.debug('alexdebug');
		System.debug(response);
		return response;
	}

	public PriceAgreementController.PriceAgreementResponse revisePriceAgreementValidate(PriceAgreementController.PriceAgreementRequest request) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'priceAgreementValidate');


		PriceAgreementController.PriceAgreementResponse response = new PriceAgreementController.PriceAgreementResponse();
		gecurrentCom475Agreementprice.HTTPS_Port port = new gecurrentCom475Agreementprice.HTTPS_Port();
		port.inputHttpHeaders_x=new Map<String,String>();
		port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		port.endpoint_x = endpointMap.get('PRICE_AGREEMENT_VALIDATE');
		port.timeout_x = 120000;

		try {

			String I_INT_REP = '';

			sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element response_x = new sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGREEMENT_PRICE_C2_Response_element();
			sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element ET_MATERIALS_OUT  = new sapComDocSapRfcFunctionsAP.ET_MATERIALS_OUT_element();
			sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element ET_SCHEDULELINE_DATA = new sapComDocSapRfcFunctionsAP.ET_SCHEDULELINE_DATA_element();
			sapComDocSapRfcFunctionsAP.IT_MATERIALS_element IT_MATERIALS = new sapComDocSapRfcFunctionsAP.IT_MATERIALS_element();

			List<sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS> pmList =  new List<sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS>();
			Map<String, PriceAgreementController.PriceAgreementItem> lineNumToItemMap = new Map<String, PriceAgreementController.PriceAgreementItem>();

			for(PriceAgreementController.PriceAgreementItem pai : request.priceAgreementItemList) {
				sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS pm = new sapComDocSapRfcFunctionsAP.x_xGEL_xHY_AGR_PRICE_MATERIALS();

				lineNumToItemMap.put(String.valueOf(pai.lineNumber), pai);
				pm.LINE_NUMBER = String.valueOf(pai.lineNumber);
				if(pai.material == 'requestedSku'){
					pm.PART_NUMBER = '';
					pm.PART_DESCRIPTION = pai.material;
				}
				else{
					pm.PART_NUMBER = pai.material;
					pm.PART_DESCRIPTION = pai.description;
				}
				pm.QUANTITY = String.valueOf(pai.quantity);
				pm.SALES_UNIT = UtilityClass.convertUomLabelToUomCode(pai.UOM);
				pm.CURRENCY_x = pai.currencyISOCode;
				pm.REQ_DEL_DATE = pai.reqDelDate;
				pm.REQUESTED_PRICE = String.valueOf(pai.requestedPrice);
				pm.AGREEMENT = pai.agreement;
				pmList.add(pm);
			}
			IT_MATERIALS.item = pmList;


			response_x = port.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6(request.agreement,request.agrDate,request.callType,
					request.distChannel, request.division, request.extAgent,
					I_INT_REP, request.orderFlag, request.orderReason,
					request.orderType, request.poNumber, request.salesOrg,
					request.customer, request.userType, request.validateFlag,
					ET_MATERIALS_OUT, ET_SCHEDULELINE_DATA, IT_MATERIALS);

			ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'getRealTimePricing');


			if(response_x != null){

				response.agreement =  request.agreement;
				response.agrDate =  request.agrDate;
				response.distChannel =  request.distChannel;
				response.division =  request.division;
				response.orderFlag =  request.orderFlag;
				response.orderReason =  request.orderReason;
				response.orderType =  request.orderType;
				response.poNumber =  request.poNumber;
				response.salesOrg =  request.salesOrg;
				response.customer =  request.customer;
				response.userType =  request.userType;
				response.errMessage = response_x.E_ERR_MESSAGE;
				response.poDuplicate = response_x.E_PO_DUPLICATE;

				List<sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT> paoList = null;

				if(response_x.ET_MATERIALS_OUT != null && response_x.ET_MATERIALS_OUT.item != null ){
					paoList = response_x.ET_MATERIALS_OUT.item;
				}

				List<PriceAgreementController.PriceAgreementItem> priceAgreementList = new List<PriceAgreementController.PriceAgreementItem>();

				if(paoList != null){
					for(sapComDocSapRfcFunctionsAP.x_xGEL_xSFB2B_AGR_PRICE_MAT_OUT pao : paoList){
						PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
						if(String.isNotBlank(pao.LINE_NUMBER)){
							pai.lineNumber = Integer.valueOf(pao.LINE_NUMBER);
						}

						if((lineNumToItemMap.get(String.valueOf(pai.lineNumber)) != null) && (String.isNotBlank(lineNumToItemMap.get(String.valueOf(pai.lineNumber)).material))){
							pai.SKU = lineNumToItemMap.get(String.valueOf(pai.lineNumber)).material;
						}

						//pai.SKU = pao.PART_NUMBER;
						pai.material = pao.PART_NUMBER;
						pai.description = pao.PART_DESCRIPTION;

						if(String.isNotBlank(pao.QUANTITY)){
							pai.quantity = Integer.valueOf(pao.QUANTITY);
						}
						if(String.isNotBlank(pao.QTY_ON_HAND)){
							pai.quantityOnHand = Integer.valueOf(pao.QTY_ON_HAND);
						}
						if(String.isNotBlank(pao.WAREHOUSE_AVAILABILITY)){
							pai.warehouseAvailability = Integer.valueOf(pao.WAREHOUSE_AVAILABILITY);
						}
						if(String.isNotBlank(pao.ADP)){
							pai.adpPrice = Decimal.valueOf(pao.ADP);
						}

						if(String.isNotBlank(pao.ADP_PERC)){
							pai.globalCommission = Decimal.valueOf(pao.ADP_PERC);
						}
						if(String.isNotBlank(pao.FLOOR_PRICE)){
							pai.floorPrice = Decimal.valueOf(pao.FLOOR_PRICE);
						}
						if(String.isNotBlank(pao.FLOOR_PERC)){
							pai.floorCommission = Decimal.valueOf(pao.FLOOR_PERC);
						}
						if(String.isNotBlank(pao.SLIDING_COM)){
							pai.slidingCommission = Decimal.valueOf(pao.SLIDING_COM);
						}
						if(String.isNotBlank(pao.SLIDING_COM_PERC)){
							pai.slidingCommissionPercentage = Decimal.valueOf(pao.SLIDING_COM_PERC);
						}
						if(String.isNotBlank(pao.OVERAGE_AMOUNT)){
							pai.overageAmount = Decimal.valueOf(pao.OVERAGE_AMOUNT);
						}
						if(String.isNotBlank(pao.OVERAGE_PERC_AMNT)){
							pai.overagePercentageAmount = Decimal.valueOf(pao.OVERAGE_PERC_AMNT);
						}
						if(String.isNotBlank(pao.OVERAGE_PERC_PERC)){
							pai.overagePercentagePerc = Decimal.valueOf(pao.OVERAGE_PERC_PERC);
						}

						pai.UOM = pao.SALES_UNIT;

						if(String.isNotBlank(pao.REQUESTED_PRICE)){
							pai.requestedPrice = Decimal.valueOf(pao.REQUESTED_PRICE);
						}
						if(String.isNotBlank(pao.BOOKP_PRICE)){
							pai.bookPrice = Decimal.valueOf(pao.BOOKP_PRICE);
						}
						pai.leadTime = pao.LEAD_TIME;
						if(String.isNotBlank(pao.AVAILABLE_QTY)){
							pai.availableQty = Integer.valueOf(pao.AVAILABLE_QTY);
						}
						if(String.isNotBlank(pao.COMMISON)){
							pai.commission = Decimal.valueOf(pao.COMMISON);
						}
						if(String.isNotBlank(pao.COMMISON_PER)){
							pai.commissionPer = Decimal.valueOf(pao.COMMISON_PER);
						}
						pai.weeeLamp = pao.WEEE_LAMP;
						pai.weeeLight = pao.WEEE_LIGHT;
						pai.weeeLampIr = pao.WEEE_LAMP_IR;
						pai.message = pao.MESSAGE;
						pai.substitueMaterial = pao.SUBSTITUTE_MATERIAL;
						pai.countryOfOrigin = pao.COUNTRY_OF_ORIGIN;
						pai.substitueReason = pao.SUBSTITUTION_REASON;
						pai.reasonRej = pao.REASON_REJ;
						pai.reasonRejText  = pao.REASON_REJ_TEXT;
						pai.agreement = pao.PRICE_AGREMENT;
						pai.productHierarchy = pao.PRODUCT_HIERARCHY;
						pai.plant = pao.PLANT;
						pai.currencyISOCode = pao.CURRENCY_x;
						if(String.isNotBlank(pao.EXTENDED_PRICE)){
							pai.extendedPrice = Decimal.valueOf(pao.EXTENDED_PRICE);
						}
						if(String.isNotBlank(pao.ROUNDED_QTY)){
							pai.roundedQty = Integer.valueOf(pao.ROUNDED_QTY);
						}
						if(String.isNotBlank(pao.STANDARD_PACK_QTY)){
							pai.standardPackQty = Integer.valueOf(pao.STANDARD_PACK_QTY);
						}
						if(String.isNotBlank(pao.PALLET_QTY)){
							pai.palletQty = Integer.valueOf(pao.PALLET_QTY);
						}
						if(String.isNotBlank(pao.UK_PALLET_QTY)){
							pai.ukPalletQty = Integer.valueOf(pao.UK_PALLET_QTY);
						}
						pai.lightTax =  pao.LIGHT_TAX;
						if(String.isNotBlank(pao.PRICE_AGREMENT_VALUE)){
							pai.priceAgreementValue = Decimal.valueOf(pao.PRICE_AGREMENT_VALUE);
						}
						if(String.isNotBlank(pao.NET_CREDIT)){
							pai.netCredit = Decimal.valueOf(pao.NET_CREDIT);
						}
						priceAgreementList.add(pai);
					}
				}
				response.priceAgreementItemList = priceAgreementList;

			}

		} catch (System.CalloutException cex) {
			System.debug('step' + cex);
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','revisePriceAgreementValidate');

		}
		System.debug('alexdebug');
		System.debug(response);
		return response;
	}

	public PriceAgreementController.PriceAgreementCreateResponse priceAgreementCreate(PriceAgreementController.PriceAgreementRequest request) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'priceAgreementCreate');

		PriceAgreementController.PriceAgreementCreateResponse response = new PriceAgreementController.PriceAgreementCreateResponse();
		gecurrentCom475AgreementcreateN4.HTTPS_Port port = new gecurrentCom475AgreementcreateN4.HTTPS_Port();
		port.inputHttpHeaders_x=new Map<String,String>();
		port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		port.endpoint_x = endpointMap.get('PRICE_AGREEMENT_CREATE');
		port.timeout_x = 120000;

		try {

			String I_INT_REP = '';

			sapComDocSapRfcFunctionsAPCreate.x_xGEL_xSFB2B_AGREEMENT_CREATE_Response_element response_x = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xSFB2B_AGREEMENT_CREATE_Response_element();
			sapComDocSapRfcFunctionsAPCreate.x_xGEL_xS_IPCRASP_COMP_FIELDS I_AGCOMP = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xS_IPCRASP_COMP_FIELDS();
			sapComDocSapRfcFunctionsAPCreate.IT_ADDITIONAL_element IT_ADDITIONAL  = new sapComDocSapRfcFunctionsAPCreate.IT_ADDITIONAL_element();
			sapComDocSapRfcFunctionsAPCreate.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS = new sapComDocSapRfcFunctionsAPCreate.IT_HEAD_COMMENTS_element();
			sapComDocSapRfcFunctionsAPCreate.IT_MATERIALS_element IT_MATERIALS = new sapComDocSapRfcFunctionsAPCreate.IT_MATERIALS_element();
			sapComDocSapRfcFunctionsAPCreate.IT_TEXT_element IT_TEXT = new sapComDocSapRfcFunctionsAPCreate.IT_TEXT_element();
			sapComDocSapRfcFunctionsAPCreate.IT_SOLD_TO_element IT_SOLD_TO = new sapComDocSapRfcFunctionsAPCreate.IT_SOLD_TO_element();
			sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_EXT_AGENTS soldToItem = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_EXT_AGENTS();
			soldToItem.KUNNR = request.soldTo;
			IT_SOLD_TO.item = new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_EXT_AGENTS>();
			IT_SOLD_TO.item.add(soldToItem);


			List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_PRICE_MATERIALS> pmList =  new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_PRICE_MATERIALS>();
			List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS> commentsList = new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS>();
			List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS> headCommentsList = new List<sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS>();
			if(!String.isEmpty(request.comments)){
				sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS comment = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS();
				comment.LINE_COMMENTS=request.comments;
				headCommentsList.add(comment);
			}
			for(PriceAgreementController.PriceAgreementItem pai : request.priceAgreementItemList) {
				sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_PRICE_MATERIALS pm = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_PRICE_MATERIALS();
				sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS comment = new sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS();
				pm.LINE_NUMBER = String.valueOf(pai.lineNumber);
				if(!String.isEmpty(pai.lineComments)){
					comment.LINE_NUMBER = String.valueOf(pai.lineNumber);
					if(pai.material == 'requestedSku'){
						comment.PART_NUMBER = 'INVALIDCAT';
					}
					else{
						comment.PART_NUMBER = pai.material;
					}
					comment.LINE_COMMENTS=pai.lineComments;
					commentsList.add(comment);
				}
				if(pai.material == 'requestedSku'){
					pm.PART_NUMBER = 'INVALIDCAT';
					pm.PART_DESCRIPTION = pai.material;
				}
				else{
					pm.PART_NUMBER = pai.material;
					pm.PART_DESCRIPTION = pai.description;
				}

				pm.QUANTITY = String.valueOf(pai.quantity);
				pm.SALES_UNIT = UtilityClass.convertUomLabelToUomCode(pai.UOM);
				pm.CURRENCY_x = pai.currencyISOCode;
				//pm.REQ_DEL_DATE = pai.reqDelDate;
				pm.REQUESTED_PRICE = String.valueOf(pai.requestedPrice);
				//pm.AGREEMENT = pai.agreement;
				pmList.add(pm);
			}
			IT_MATERIALS.item = pmList;
			if(!headCommentsList.isEmpty()){
				IT_HEAD_COMMENTS.item = headCommentsList;
			}
			if(!commentsList.isEmpty()){
				IT_TEXT.item = commentsList;
			}

			response_x = port.SI_HYBRIS_AgreementCreate_475_OB_SYNC_N4(I_AGCOMP, request.agreementType, request.city, request.comments,
					request.description, request.distChannel, request.division, request.endUser, request.extDescription, request.extRepNumber,
					I_INT_REP,request.lbrepnumber, request.opportunityId, request.province, request.salesOrg, request.soldTo, request.state, request.strategicAccount,
					request.userEmail, request.userName, request.userType, request.validFrom, request.validTo, request.zipCode, IT_ADDITIONAL,
					IT_HEAD_COMMENTS, IT_MATERIALS, IT_SOLD_TO, IT_TEXT);

			if(response_x != null){

				response.agreement =  response_x.E_AGREEMENT;
				response.approved = response_x.E_APPROVED;
				response.message = response_x.E_MESSAGE;
				if(response_x.IT_ADDITIONAL != null && response_x.IT_ADDITIONAL.item != null){
					List<PriceAgreementController.IpCraspCompFields> responseItems = new List<PriceAgreementController.IpCraspCompFields>();
					PriceAgreementController.IpCraspCompFields responseItem;
					for(sapComDocSapRfcFunctionsAPCreate.x_xGEL_xS_IPCRASP_COMP_FIELDS item : response_x.IT_ADDITIONAL.item){
						responseItem = new PriceAgreementController.IpCraspCompFields();
						responseItem.manufacturer = item.ZMANUFACTURER;
						responseItem.distributor = item.ZDISTRIBUTOR;
						responseItem.datab = item.ZDATAB;
						responseItem.datbi = item.ZDATBI;
						responseItem.mthdObtd = item.ZMTHD_OBTD;
						responseItem.name = item.ZNAME;
						responseItem.title = item.ZTITLE;
						responseItem.company = item.ZCOMPANY;
						responseItem.comment = item.ZCOMMENT;
						responseItems.add(responseItem);
					}
					response.additional = responseItems;
				}

				if(response_x.IT_HEAD_COMMENTS != null && response_x.IT_HEAD_COMMENTS.item != null){
					List<PriceAgreementController.AgrLineComments> responseHeaderComments = new List<PriceAgreementController.AgrLineComments>();
					PriceAgreementController.AgrLineComments responseHeaderComment;
					for(sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS item : response_x.IT_HEAD_COMMENTS.item){
						responseHeaderComment = new PriceAgreementController.AgrLineComments();
						responseHeaderComment.lineNumber = item.LINE_NUMBER;
						responseHeaderComment.partNumber = item.PART_NUMBER;
						responseHeaderComment.lineComments = item.LINE_COMMENTS;
						responseHeaderComments.add(responseHeaderComment);
					}
					response.headComments = responseHeaderComments;
				}

				if(response_x.IT_MATERIALS != null && response_x.IT_MATERIALS.item != null){
					List<PriceAgreementController.AgrPriceMaterials> responseMaterials = new List<PriceAgreementController.AgrPriceMaterials>();
					PriceAgreementController.AgrPriceMaterials responseMaterial;
					for(sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_PRICE_MATERIALS item : response_x.IT_MATERIALS.item){
						responseMaterial = new PriceAgreementController.AgrPriceMaterials();
						responseMaterial.lineNumber = item.LINE_NUMBER;
						responseMaterial.partNumber = item.PART_NUMBER;
						responseMaterial.partDescription = item.PART_DESCRIPTION;
						responseMaterial.quantity = item.QUANTITY;
						responseMaterial.salesUnit = item.SALES_UNIT;
						responseMaterial.requestedPrice = item.REQUESTED_PRICE;
						responseMaterial.currencyType = item.CURRENCY_x;
						responseMaterial.agreement = item.AGREEMENT;
						responseMaterial.reqDelDate = item.REQ_DEL_DATE;
						responseMaterials.add(responseMaterial);
					}
					response.materials = responseMaterials;
				}

				if(response_x.IT_SOLD_TO != null && response_x.IT_SOLD_TO.item != null){
					List<PriceAgreementController.ExtAgents> responseSoldTos = new List<PriceAgreementController.ExtAgents>();
					PriceAgreementController.ExtAgents responseSoldTo;
					for(sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_EXT_AGENTS item : response_x.IT_SOLD_TO.item){
						responseSoldTo = new PriceAgreementController.ExtAgents();
						responseSoldTo.kunnr = item.KUNNR;
						responseSoldTos.add(responseSoldTo);
					}
					response.soldTo = responseSoldTos;
				}

				if(response_x.IT_TEXT != null && response_x.IT_TEXT.item != null){
					List<PriceAgreementController.AgrLineComments> responseTexts = new List<PriceAgreementController.AgrLineComments>();
					PriceAgreementController.AgrLineComments responseText;
					for(sapComDocSapRfcFunctionsAPCreate.x_xGEL_xHY_AGR_LINE_COMMENTS item : response_x.IT_TEXT.item){
						responseText = new PriceAgreementController.AgrLineComments();
						responseText.lineNumber = item.LINE_NUMBER;
						responseText.partNumber = item.PART_NUMBER;
						responseText.lineComments = item.LINE_COMMENTS;
						responseTexts.add(responseText);
					}
					response.text = responseTexts;
				}
			}

		} catch (System.CalloutException cex) {
			System.debug('step ' + cex);
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','priceAgreementCreate');

		}
		System.debug('alexdebug');
		System.debug(response);
		return response;
	}

	public PriceAgreementController.PriceAgreementCreateResponse priceAgreementRevise(PriceAgreementController.PriceAgreementRequest request) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'priceAgreementRevise');

		PriceAgreementController.PriceAgreementCreateResponse response = new PriceAgreementController.PriceAgreementCreateResponse();
		gecurrentComCom4031Priceagreementext.HTTPS_Port port = new gecurrentComCom4031Priceagreementext.HTTPS_Port();
		port.inputHttpHeaders_x=new Map<String,String>();
		port.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		port.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		port.endpoint_x = endpointMap.get('PRICE_AGREEMENT_REVISE');
		port.timeout_x = 120000;

		try {

			String I_INT_REP = '';

			sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xSFB2B_AGREEMENT_REVISION_Response_element response_x = new sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xSFB2B_AGREEMENT_REVISION_Response_element();
			sapComDocumentSapRfcFunctionsPARevise.IT_LINE_COMMENTS_element IT_LINE_COMMENTS = new sapComDocumentSapRfcFunctionsPARevise.IT_LINE_COMMENTS_element();
			sapComDocumentSapRfcFunctionsPARevise.IT_HEAD_COMMENTS_element IT_HEAD_COMMENTS = new sapComDocumentSapRfcFunctionsPARevise.IT_HEAD_COMMENTS_element();
			sapComDocumentSapRfcFunctionsPARevise.IT_MATERIALS_element IT_MATERIALS = new sapComDocumentSapRfcFunctionsPARevise.IT_MATERIALS_element();
			sapComDocumentSapRfcFunctionsPARevise.IT_TEXT_element IT_TEXT = new sapComDocumentSapRfcFunctionsPARevise.IT_TEXT_element();
			List<sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_PRICE_MATERIALS> pmList =  new List<sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_PRICE_MATERIALS>();


			List<sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS> headCommentsList = new List<sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS>();
			if(!String.isEmpty(request.comments)){
				sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS comment = new sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS();
				comment.LINE_COMMENTS=request.comments;
				headCommentsList.add(comment);
			}


			for(PriceAgreementController.PriceAgreementItem pai : request.priceAgreementItemList) {
				sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_PRICE_MATERIALS pm = new sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_PRICE_MATERIALS();

				pm.LINE_NUMBER = String.valueOf(pai.lineNumber);
				if(pai.material == 'requestedSku'){
					pm.PART_NUMBER = '';
					pm.PART_DESCRIPTION = pai.material;
				}
				else{
					pm.PART_NUMBER = pai.material;
					pm.PART_DESCRIPTION = pai.description;
				}
				pm.QUANTITY = String.valueOf(pai.quantity);
				pm.SALES_UNIT = UtilityClass.convertUomLabelToUomCode(pai.UOM);
				pm.CURRENCY_x = pai.currencyISOCode;
				//pm.REQ_DEL_DATE = pai.reqDelDate;
				pm.REQUESTED_PRICE = String.valueOf(pai.requestedPrice);
				//pm.AGREEMENT = pai.agreement;
				pmList.add(pm);
			}

			if(!headCommentsList.isEmpty()){
				IT_HEAD_COMMENTS.item = headCommentsList;
			}
			System.debug('priceAgreementRevise() IT_HEAD_COMMENTS: ' + IT_HEAD_COMMENTS);

			IT_MATERIALS.item = pmList;

			response_x = port.SI_SFB2B_AgreementRevision_4031_OB_SYNC(request.agreement, request.agreementAction,'',request.city,request.comments,
					request.description,'', request.extDescription, request.extRepNumber, I_INT_REP,'', request.opportunityId,'',
					request.soldTo,request.state, request.strategicAccount,request.userEmail, request.userName, request.userType, request.validFrom, request.validTo,request.zipCode,
					IT_HEAD_COMMENTS, IT_LINE_COMMENTS, IT_MATERIALS, IT_TEXT);

			if(response_x != null){

				response.agreement =  response_x.E_AGREEMENT;
				response.approved = response_x.E_APPROVED;
				response.message = response_x.E_MESSAGE;

				if(response_x.IT_HEAD_COMMENTS != null && response_x.IT_HEAD_COMMENTS.item != null){
					List<PriceAgreementController.AgrLineComments> responseHeaderComments = new List<PriceAgreementController.AgrLineComments>();
					PriceAgreementController.AgrLineComments responseHeaderComment;
					for(sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS item : response_x.IT_HEAD_COMMENTS.item){
						responseHeaderComment = new PriceAgreementController.AgrLineComments();
						responseHeaderComment.lineNumber = item.LINE_NUMBER;
						responseHeaderComment.partNumber = item.PART_NUMBER;
						responseHeaderComment.lineComments = item.LINE_COMMENTS;
						responseHeaderComments.add(responseHeaderComment);
					}
					response.headComments = responseHeaderComments;
				}


				if(response_x.IT_LINE_COMMENTS != null && response_x.IT_LINE_COMMENTS.item != null){
					List<PriceAgreementController.AgrLineComments> responseLineComments = new List<PriceAgreementController.AgrLineComments>();
					PriceAgreementController.AgrLineComments responseLineComment;
					for(sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_LINE_COMMENTS item : response_x.IT_LINE_COMMENTS.item){
						responseLineComment = new PriceAgreementController.AgrLineComments();
						responseLineComment.lineNumber = item.LINE_NUMBER;
						responseLineComment.partNumber = item.PART_NUMBER;
						responseLineComment.lineComments = item.LINE_COMMENTS;
						responseLineComments.add(responseLineComment);
					}
					response.headComments = responseLineComments;
				}

				if(response_x.IT_MATERIALS != null && response_x.IT_MATERIALS.item != null){
					List<PriceAgreementController.AgrPriceMaterials> responseMaterials = new List<PriceAgreementController.AgrPriceMaterials>();
					PriceAgreementController.AgrPriceMaterials responseMaterial;
					for(sapComDocumentSapRfcFunctionsPARevise.x_xGEL_xHY_AGR_PRICE_MATERIALS item : response_x.IT_MATERIALS.item){
						responseMaterial = new PriceAgreementController.AgrPriceMaterials();
						responseMaterial.lineNumber = item.LINE_NUMBER;
						responseMaterial.partNumber = item.PART_NUMBER;
						responseMaterial.partDescription = item.PART_DESCRIPTION;
						responseMaterial.quantity = item.QUANTITY;
						responseMaterial.salesUnit = item.SALES_UNIT;
						responseMaterial.requestedPrice = item.REQUESTED_PRICE;
						responseMaterial.currencyType = item.CURRENCY_x;
						responseMaterial.agreement = item.AGREEMENT;
						responseMaterial.reqDelDate = item.REQ_DEL_DATE;
						responseMaterials.add(responseMaterial);
					}
					response.materials = responseMaterials;
				}
			}

		} catch (System.CalloutException cex) {
			System.debug('step' + cex);
			ExceptionLogger.newExceptionLog(cex,'SAPGateway','priceAgreementRevise');

		}
		System.debug('alexdebug');
		System.debug(response);
		return response;
	}

	public ClaimBackController.ClaimBackCreateResponse sendClaimBackToSap(ClaimBackController.ClaimBackHeader header, List<ClaimBackController.ClaimBackItem> itemList){
		gecurrentCom4535ClaimBack.HTTPS_Port caller = new gecurrentCom4535ClaimBack.HTTPS_Port();
		//gecurrentCom4535ClaimBack.HTTPS_Port asyncCaller = new gecurrentCom4535ClaimBack.HTTPS_Port();
		gecurrentCom4535ClaimBack.DT_SFB2B_Claim_back_Credit_Request cbRequest = new gecurrentCom4535ClaimBack.DT_SFB2B_Claim_back_Credit_Request();

		caller.inputHttpHeaders_x=new Map<String,String>();
		caller.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		caller.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');

		caller.endpoint_x = endpointMap.get('CLAIM_BACK_ASYNC');
		caller.timeout_x = 120000;


		List<gecurrentCom4535ClaimBack.Recordset_element> sapHeaderItems = new List<gecurrentCom4535ClaimBack.Recordset_element>();

		gecurrentCom4535ClaimBack.Recordset_element sapHeader = new gecurrentCom4535ClaimBack.Recordset_element();

		sapHeader.SequenceNo = '';
		sapHeader.RecordType = 'H';
		sapHeader.Soldto_ItemNo = header.soldToNumber;
		sapHeader.ReferenceNo_MaterialNo = header.referenceNumber;
		sapHeader.ClaimDate_ClaimQty = formatDate(System.today(), '');
		sapHeader.ClaimType_AgreementRequested = 'ZCCL';
		sapHeader.ClaimOrigin_CustomerInvoiceNo = 'L';
		sapHeader.BatchID_CustomerInvoiceDate = formatDate(System.today(), '');
		sapHeader.Salesorg_IntostockPricePerunit = header.salesOrg;
		sapHeader.DistChannel_ClaimbackPricePerunit = header.distributionChannel;
		sapHeader.Division_ExpectedClaimperunit = header.division;
		sapHeader.EndCustNo = '';
		sapHeader.EndCustName = '';
		sapHeader.EndCustomerStreet = '';
		sapHeader.EndCustCity = '';
		sapHeader.EndCustState = '';
		sapHeader.EndCustZipcode = '';
		sapHeader.EndCustCountry = '';
		sapHeader.ShipmentType = '';
		sapHeader.ItemType = '';
		sapHeader.UPCCode = '';
		sapHeader.MaterialDescriptionforGEProductcode = '';
		sapHeader.MaterialDescriptionforUPCCode = '';

		sapHeaderItems.add(sapHeader);


		gecurrentCom4535ClaimBack.Recordset_element sapItem = new gecurrentCom4535ClaimBack.Recordset_element();
		Integer i = 0;
		system.debug('itemList '+itemList);
		for (ClaimBackController.ClaimBackItem item : itemList) {
			sapItem = new gecurrentCom4535ClaimBack.Recordset_element();
			sapItem.SequenceNo = '';
			sapItem.RecordType = 'I';
			sapItem.Soldto_ItemNo = String.valueOf(item.lineNumber);
			sapItem.ReferenceNo_MaterialNo = item.materialNumber;
			sapItem.ClaimDate_ClaimQty = String.valueOf(Math.abs(Integer.valueOf(item.quantity)));
			sapItem.ClaimType_AgreementRequested = item.priceAgreementNumber;
			sapItem.ClaimOrigin_CustomerInvoiceNo = item.endCustomerInvoiceNumber;
			sapItem.BatchID_CustomerInvoiceDate = item.invoiceDate;
			sapItem.Salesorg_IntostockPricePerunit = item.replacementPricePerUnit;
			sapItem.DistChannel_ClaimbackPricePerunit = item.priceAgreementPricePerUnit;
			//sapItem.Division_ExpectedClaimperunit = item.requestedCredit;
			sapItem.Division_ExpectedClaimperunit = sapItem.Division_ExpectedClaimperunit = String.valueOf(Decimal.valueOf(item.requestedCredit) / Math.abs(Decimal.valueOf(item.quantity)));
			sapItem.EndCustNo = item.endCustomerNumber;
			sapItem.EndCustName = item.endCustomerName;
			sapItem.EndCustomerStreet = '';
			sapItem.EndCustCity = '';
			sapItem.EndCustState = '';
			sapItem.EndCustZipcode = '';
			sapItem.EndCustCountry = '';
			sapItem.ShipmentType = item.shippingType;
			sapItem.ItemType = (Decimal.valueOf(item.replacementPricePerUnit) - Decimal.valueOf(item.priceAgreementPricePerUnit) >=0 && Integer.valueOf(item.quantity)>=0) ? 'ZTAN' : 'ZNEG';
			sapItem.UPCCode = '';
			sapItem.MaterialDescriptionforGEProductcode = '';
			sapItem.MaterialDescriptionforUPCCode = '';

			sapHeaderItems.add(sapItem);
		}

		cbRequest.Recordset = sapHeaderItems;
		system.debug('sapHeaderItems '+JSON.serializePretty(sapHeaderItems));
		String RecordSetResponse = caller.SI_SFB2B_Claim_back_Credit_Request_4535_OB_ASYNC(sapHeaderItems);


		system.debug('RecordSetResponse '+RecordSetResponse);
		//sapResponse = caller.SI_HYBRIS_SubmitCall_4535_OB_SYNC(sapHeader, sapItems);
		ClaimBackController.ClaimBackCreateResponse response = new ClaimBackController.ClaimBackCreateResponse();

		return response;
	}

    public ClaimSearchController.ClaimSearchResponse searchClaims(ClaimSearchController.ClaimSearchRequest request){
        System.debug(JSON.serializePretty(request));
        ClaimSearchController.ClaimSearchResponse response = new ClaimSearchController.ClaimSearchResponse();
        sapComDocumentSapRfcFunctionsCS.x_xGEL_xSFB2B_CLAIM_SEARCH_Response_element sapResponse;
        gecurrentCom4794Claimsearch.HTTPS_Port caller = new gecurrentCom4794Claimsearch.HTTPS_Port();
        caller.inputHttpHeaders_x=new Map<String,String>();
		caller.inputHttpHeaders_x.put('Content-Type','text/xml;charset=UTF-8');
		caller.inputHttpHeaders_x.put('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
		caller.endpoint_x = endpointMap.get('CLAIM_SEARCH');
		caller.timeout_x = 120000;

        sapComDocumentSapRfcFunctionsCS.IT_CLAIM_NUM_element IT_CLAIM_NUM = new sapComDocumentSapRfcFunctionsCS.IT_CLAIM_NUM_element();
        if(String.isNotBlank(request.claimNumber)){
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_NUM IT_CLAIM_NUMItem = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_NUM();
            IT_CLAIM_NUMItem.VBELN = request.claimNumber;
            IT_CLAIM_NUM.item = new List<sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_NUM>{IT_CLAIM_NUMItem};
        }

        sapComDocumentSapRfcFunctionsCS.IT_CLAIM_TYP_element IT_CLAIM_TYP = new sapComDocumentSapRfcFunctionsCS.IT_CLAIM_TYP_element();
        sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_TYP IT_CLAIM_TYPItem = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_TYP();
        IT_CLAIM_TYPItem.CRTYP = 'ZCCL';
        IT_CLAIM_TYP.item = new List<sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_TYP>{IT_CLAIM_TYPItem};

        sapComDocumentSapRfcFunctionsCS.IT_DIST_CHNL_element IT_DIST_CHNL = new sapComDocumentSapRfcFunctionsCS.IT_DIST_CHNL_element();
        if(String.isNotBlank(request.distributionChannel)){
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_DIST_CHNL IT_DIST_CHNLItem = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_DIST_CHNL();
            IT_DIST_CHNLItem.VTWEG = request.distributionChannel;
            IT_DIST_CHNL.item = new List<sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_DIST_CHNL>{IT_DIST_CHNLItem};
        }

        sapComDocumentSapRfcFunctionsCS.IT_DIV_element IT_DIV = new sapComDocumentSapRfcFunctionsCS.IT_DIV_element();
        if(String.isNotBlank(request.division)){
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_DIVISON IT_DIVItem = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_DIVISON();
            IT_DIVItem.SPART = request.division;
            IT_DIV.item = new List<sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_DIVISON>{IT_DIVItem};
        }

        sapComDocumentSapRfcFunctionsCS.IT_REF_NUM_element IT_REF_NUM = new sapComDocumentSapRfcFunctionsCS.IT_REF_NUM_element();
        if(String.isNotBlank(request.referenceNumber)){
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_REF_NUM IT_REF_NUMItem = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_REF_NUM();
            IT_REF_NUMItem.XBLNR = request.referenceNumber;
            IT_REF_NUM.item = new List<sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_REF_NUM>{IT_REF_NUMItem};
        }

        sapComDocumentSapRfcFunctionsCS.IT_SALES_ORG_element IT_SALES_ORG = new sapComDocumentSapRfcFunctionsCS.IT_SALES_ORG_element();
        if(String.isNotBlank(request.salesOrg)){
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_SALES_ORG IT_SALES_ORGItem = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_SALES_ORG();
            IT_SALES_ORGItem.VKORG = request.salesOrg;
            IT_SALES_ORG.item = new List<sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_SALES_ORG>{IT_SALES_ORGItem};
        }

        sapComDocumentSapRfcFunctionsCS.IT_SOLD_TO_element IT_SOLD_TO = new sapComDocumentSapRfcFunctionsCS.IT_SOLD_TO_element();
        if(String.isNotBlank(request.soldToNumber)){
            sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_SOLD_TO IT_SOLD_TOItem = new sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_SOLD_TO();
            IT_SOLD_TOItem.KUNAG = request.soldToNumber;
            IT_SOLD_TO.item = new List<sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_SOLD_TO>{IT_SOLD_TOItem};
        }

        try{
            sapResponse = caller.SI_SFB2B_ClaimsSearch_4794_OB_SYNC(
                request.dateFrom,
                request.dateTo,
                request.materialNumber,
                new sapComDocumentSapRfcFunctionsCS.ET_CLAIM_DETAILS_element(),
                new sapComDocumentSapRfcFunctionsCS.IT_ASSIGN_NUM_element(),
                IT_CLAIM_NUM,
                IT_CLAIM_TYP,
                IT_DIST_CHNL,
                IT_DIV,
                IT_REF_NUM,
                IT_SALES_ORG,
                IT_SOLD_TO,
                new sapComDocumentSapRfcFunctionsCS.IT_TRANSMISSION_element());
        }
        catch(CalloutException e){
            System.debug(e.getMessage() + ': ' + e.getStackTraceString());
            response.message = 'ERROR: ' + e.getMessage();
        }

        System.debug(JSON.serializePretty(sapResponse));

        if(String.isNotBlank(sapResponse.E_MESSAGE)){
            response.message = sapResponse.E_MESSAGE;
        }
        else{
            response.message = 'OK';
            response.claims = new List<ClaimSearchController.ClaimSearchResponseItem>();
            ClaimSearchController.ClaimSearchResponseItem tempItem;
            for(sapComDocumentSapRfcFunctionsCS.x_xGEL_xST_CLAIM_DETAILS sapResponseItem : sapResponse.ET_CLAIM_DETAILS.item){
                tempItem = new ClaimSearchController.ClaimSearchResponseItem();
                tempItem.claimNumber = sapResponseItem.CLAIM_NUM;
                tempItem.claimDate = Date.valueOf(sapResponseItem.CLAIM_DATE);
                tempItem.claimedTotalAmount = Decimal.valueOf(sapResponseItem.CLAIM_TOT_AMT);
                tempItem.distributionChannel = sapResponseItem.DIST_CHANNEL;
                tempItem.division = sapResponseItem.DIV;
                tempItem.salesOrg = sapResponseItem.SALES_ORG;
                tempItem.invoiceAmount = Decimal.valueOf(sapResponseItem.INVOICE_AMT);
                try {
					tempItem.invoiceDate = Date.valueOf(sapResponseItem.INVOICE_DATE);
				} catch (Exception ex) {
					system.debug(ex.getStackTraceString());
				}
                tempItem.invoiceNum = sapResponseItem.INVOIC_NUM;
                tempItem.jobName = sapResponseItem.TRANSMISSION;
                tempItem.referenceNumber = sapResponseItem.REF_NUM;
                tempItem.soldToNumber = sapResponseItem.CUSTOMER;
                tempItem.submittedAmount = Decimal.valueOf(sapResponseItem.SUBMIT_AMT);
                response.claims.add(tempItem);
            }
        }

        return response;
    }

	private String getWarehouseLocation(Warehouse__mdt[] warehouseRecords, String orderShipFromLocation){
		String warehouseLocation = '';
		if(String.isNotBlank(orderShipFromLocation)){
			for(Warehouse__mdt record:warehouseRecords) {
				if(orderShipFromLocation == record.Code__c){
					warehouseLocation = record.Location__c;
					break;
				}
			}
		}
		return warehouseLocation;
	}

	private String formatDate(Date d, String s) {
		return ((Datetime)d).format('YYYY' + s + 'MM' + s + 'dd');
	}

	public class SAPServiceException extends Exception { }
	public class OrderNotFoundException extends Exception { }
	public class SOAPFaultException extends Exception { }
}