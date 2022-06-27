/*----------------------------------------------------------------------
Name:       AfterShipController.cls
Purpose:    Call AfterShip Service For Shipment Information
------------------------------History----------------------------------
Version     Author          Date                    Detail Description
-------     -------         --------------          ------------------
1.0         Devang          12-Dec-2020             Initial Development
----------------------------------------------------------------------*/


public without sharing class OrderController {
    @testVisible private static SAPGateway service = new SAPGateway();



    @TestVisible private static Account getAccount(){
        Id userId = UserInfo.getUserId();

        User u = [SELECT Id, ContactId, Email, AccountId FROM User WHERE Id = : userId];
        Account account = [
				SELECT Id,
						Name,
                        GE_LGT_EM_SAP_Customer_Number__c,
                        GE_LGT_EM_Sales_Org__c,
                        GE_LGT_EM_Division__c,
                        GE_LGT_EM_Distribution_Channel__c,
                        Delivering_Plant__c,
                        Account_Group__c,
                        GE_LGT_Rep_Code__c
				FROM Account
				WHERE Id = :u.AccountId
        ];
        return account;
    }

    @AuraEnabled
    public static order getOrder(String orderId){
        
        Map<String, String> orderSourceGet = new Map<String, String>();
			for(Order_Source__mdt os:[SELECT MasterLabel, DeveloperName FROM Order_Source__mdt]){
				orderSourceGet.put(os.MasterLabel,os.DeveloperName);
			}
        
        Map<String, String> orderTypeGet = new Map<String, String>();
			for(Order_Type__mdt ot:[SELECT MasterLabel, Description__c FROM Order_Type__mdt]){
				orderTypeGet.put(ot.MasterLabel,ot.Description__c);
			}

        
        Order order = [
            SELECT Id,
                    Type,
                    GE_Order_NO__c,
                    Customer_PO_Number__c,
            		EffectiveDate,
                    Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c,
                    Sold_To__r.GE_LGT_EM_Sales_Org__c,
                    Sold_To__r.GE_LGT_EM_Division__c,
                    Sold_To__r.GE_LGT_EM_Distribution_Channel__c,
                    Sold_To__r.Delivering_Plant__c,
                    Sold_To__r.Account_Group__c,
                    Sold_To__r.GE_LGT_Rep_Code__c,
                    Agent_Account__r.Name,
            		Agent_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
                    Sold_To__r.Name,
                    Strategic_Account__c,
                    Strategic_Account__r.Name,
                    Strategic_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
                    BillingAddress,
                    ShippingAddress,
                    BlockDescription__c,
            		CreditStatus__c,
                    Incomplete__c,
                    GBSTK__c,
            		OrderSourceCode__c,
            		TotalAmount,
            		CurrencyIsoCode,
            		TotalCommission__c,
            		SURCHARGES__c
            FROM Order
            WHERE Id = :orderId
        ];
        
        
            order.OrderSourceCode__c=orderSourceGet.get(order.OrderSourceCode__c);
            order.Type=orderTypeGet.get(order.Type);
        
        if (order.CreditStatus__c == 'Blocked' || order.BlockDescription__c == 'Under investigation') {
            
            order.BlockDescription__c = 'Blocked' ;
            
        }
        
        else {
            
            order.BlockDescription__c = 'Not Blocked';
            
        }
        
            return order;

    }

    @AuraEnabled
    public static List<OrderItem> getItemDetails(String orderId){
        return [SELECT Id, Agreement_Quote__c,CurrencyIsoCode, RequestedDeliveryDate__c, ADPPrice__c,UnitOfMeasure__c, SAPInvoiceNumber__c, Order_Line_Number__c, UnitPrice, Quantity FROM OrderItem WHERE OrderId =: orderId];
    }

    //Method to perform a callout and return an soap response
	@AuraEnabled(cacheable=false)
	public static OrderDetails getDetails(String orderId){

        Account acc = getAccount();
        Order ord = getOrder(orderId);
        OrderRequest req = new OrderRequest();
        //req.orderNumber = '0000854216';
        //req.salesOrg = '1US1';
        //system.debug('Testing');

        req.orderNumber = ord.GE_Order_NO__c;
        System.debug('req.orderNumber-----------------------'+req.orderNumber);
        req.salesOrg = ord.Sold_To__r.GE_LGT_EM_Sales_Org__c;
        System.debug('req.salesOrg-----------------------'+req.salesOrg);
        OrderDetails response = service.orderDisplay(req);
        System.debug('response-----------------'+response);
        response.userAccountGroup = acc.Account_Group__c;
        System.debug('response-----------------'+response);


        OrderDetails od = new OrderDetails();
        List<ET_SCHEDULE_DATA_ITEM> sdiList = new List<ET_SCHEDULE_DATA_ITEM>();
        ET_SCHEDULE_DATA_ITEM sd = new ET_SCHEDULE_DATA_ITEM();
        sd.ORDER_NUMBER = '0000854216';
        sd.ITEM_NUMBER = '000010';
        sd.DEL_NUMBER = '0051930074';
        sd.DEL_ITEM_NUMBER = '000010';
        sd.QUANTITY = '12.00';
        sd.SALES_UNIT = 'EA';
        sd.CARRIER_NAME = 'FEDEX GROUND';
        sd.SHIPPED_FROM = 'Mira Loma MDC';
        sd.INVOICE_NUMBER = '1170968263';
        sd.INVOICE_ITEM = '000170';
        sd.INVOICE_DATE = '2020-04-03';
        sd.CONFIRMED = 'Y';
        sd.EST_SHIP_DATE = '2020-04-03';
        sd.EST_DEL_DATE = '2020-04-07';
        sd.ACT_SHIP_DATE = '2020-04-03';
        sd.ACT_DEL_DATE = '2020-04-07';
        sd.TRACKING_NUMBER = '153705794927';
        sd.SHIPMENT_NUMBER = '0001386916';
        sdiList.add(sd);

        ET_SCHEDULE_DATA_ITEM sd1 = new ET_SCHEDULE_DATA_ITEM();
        sd1.ORDER_NUMBER = '0000854216';
        sd1.ITEM_NUMBER = '000010';
        sd1.DEL_NUMBER = '0051930089';
        sd1.DEL_ITEM_NUMBER = '000010';
        sd1.QUANTITY = '12.00';
        sd1.SALES_UNIT = 'EA';
        sd1.CARRIER_NAME = 'HMES';
        sd1.SHIPPED_FROM = 'Mira Loma MDC';
        sd1.INVOICE_NUMBER = '1170968263';
        sd1.INVOICE_ITEM = '000170';
        sd1.INVOICE_DATE = '2020-04-03';
        sd1.CONFIRMED = 'Y';
        sd1.EST_SHIP_DATE = '2020-04-03';
        sd1.EST_DEL_DATE = '2020-04-07';
        sd1.ACT_SHIP_DATE = '2020-04-03';
        sd1.ACT_DEL_DATE = '2020-04-07';
        sd1.TRACKING_NUMBER = '10883728625';
        sd1.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd1);


        ET_SCHEDULE_DATA_ITEM sd2 = new ET_SCHEDULE_DATA_ITEM();
        sd2.ORDER_NUMBER = '0000854216';
        sd2.ITEM_NUMBER = '000010';
        sd2.DEL_NUMBER = '0051930089';
        sd2.DEL_ITEM_NUMBER = '000010';
        sd2.QUANTITY = '12.00';
        sd2.SALES_UNIT = 'EA';
        sd2.CARRIER_NAME = 'FEDERAL EXPRESS PM';
        sd2.SHIPPED_FROM = 'Mira Loma MDC';
        sd2.INVOICE_NUMBER = '1170968263';
        sd2.INVOICE_ITEM = '000170';
        sd2.INVOICE_DATE = '2020-04-03';
        sd2.CONFIRMED = 'Y';
        sd2.EST_SHIP_DATE = '2020-04-03';
        sd2.EST_DEL_DATE = '2020-04-07';
        sd2.ACT_SHIP_DATE = '2020-04-03';
        sd2.ACT_DEL_DATE = '2020-04-07';
        sd2.TRACKING_NUMBER = '10883740793';
        sd2.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd2);

        ET_SCHEDULE_DATA_ITEM sd3 = new ET_SCHEDULE_DATA_ITEM();
        sd3.ORDER_NUMBER = '926841';
        sd3.ITEM_NUMBER = '000010';
        sd3.DEL_NUMBER = '0051930089';
        sd3.DEL_ITEM_NUMBER = '000010';
        sd3.QUANTITY = '12.00';
        sd3.SALES_UNIT = 'EA';
        sd3.CARRIER_NAME = 'FEDEX GROUND';
        sd3.SHIPPED_FROM = 'Mira Loma MDC';
        sd3.INVOICE_NUMBER = '1170968263';
        sd3.INVOICE_ITEM = '000170';
        sd3.INVOICE_DATE = '2020-04-03';
        sd3.CONFIRMED = 'Y';
        sd3.EST_SHIP_DATE = '2020-04-03';
        sd3.EST_DEL_DATE = '2020-04-07';
        sd3.ACT_SHIP_DATE = '2020-04-03';
        sd3.ACT_DEL_DATE = '2020-04-07';
        sd3.TRACKING_NUMBER = '945996426090';
        sd3.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd3);

        ET_SCHEDULE_DATA_ITEM sd4 = new ET_SCHEDULE_DATA_ITEM();
        sd4.ORDER_NUMBER = '926841';
        sd4.ITEM_NUMBER = '000010';
        sd4.DEL_NUMBER = '0051930089';
        sd4.DEL_ITEM_NUMBER = '000010';
        sd4.QUANTITY = '12.00';
        sd4.SALES_UNIT = 'EA';
        sd4.CARRIER_NAME = 'SAIA';
        sd4.SHIPPED_FROM = 'Mira Loma MDC';
        sd4.INVOICE_NUMBER = '1170968263';
        sd4.INVOICE_ITEM = '000170';
        sd4.INVOICE_DATE = '2020-04-03';
        sd4.CONFIRMED = 'Y';
        sd4.EST_SHIP_DATE = '2020-04-03';
        sd4.EST_DEL_DATE = '2020-04-07';
        sd4.ACT_SHIP_DATE = '2020-04-03';
        sd4.ACT_DEL_DATE = '2020-04-07';
        sd4.TRACKING_NUMBER = '104619064806';
        sd4.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd4);


        ET_SCHEDULE_DATA_ITEM sd5 = new ET_SCHEDULE_DATA_ITEM();
        sd5.ORDER_NUMBER = '926841';
        sd5.ITEM_NUMBER = '000010';
        sd5.DEL_NUMBER = '0051930089';
        sd5.DEL_ITEM_NUMBER = '000010';
        sd5.QUANTITY = '12.00';
        sd5.SALES_UNIT = 'EA';
        sd5.CARRIER_NAME = 'ESTES EXPRESS';
        sd5.SHIPPED_FROM = 'Mira Loma MDC';
        sd5.INVOICE_NUMBER = '1170968263';
        sd5.INVOICE_ITEM = '000170';
        sd5.INVOICE_DATE = '2020-04-03';
        sd5.CONFIRMED = 'Y';
        sd5.EST_SHIP_DATE = '2020-04-03';
        sd5.EST_DEL_DATE = '2020-04-07';
        sd5.ACT_SHIP_DATE = '2020-04-03';
        sd5.ACT_DEL_DATE = '2020-04-07';
        sd5.TRACKING_NUMBER = '0552440943';
        sd5.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd5);
		System.debug('sdiList---------------'+sdiList);
        od.scheduleData = sdiList;
        //return od;

        for (ET_SALES_ITEM_DATA_ITEM item : response.salesItemData) {
            if (item.CURRENCY_x == 'USD') {
                item.CURRENCY_y = '$';
            }
            else if (item.CURRENCY_x == 'CAD') {
                item.CURRENCY_y = 'CA$';
            }
            else {
                item.CURRENCY_y = item.CURRENCY_x;
            }
        }
        /*For UOM*/
        List<UOM_Mapping__mdt> obj = [SELECT Code__c,Label, Order__c from UOM_Mapping__mdt ORDER BY Order__c NULLS LAST];//quering metadata
        Map<String,String> mapObj = new  Map<String,String>();

        for(UOM_Mapping__mdt obj1 : obj){

           mapObj.put(obj1.Code__c, obj1.Label);


        }
        for (ET_SALES_ITEM_DATA_ITEM item : response.salesItemData) {
            if (item.SALES_UNIT != null) {
               item.SALES_UNIT = mapObj.get(item.SALES_UNIT);

            }
        }
        /*For Quantity Ordered field*/
        for (ET_SALES_ITEM_DATA_ITEM item : response.salesItemData) {
            if (item.Quantity != null) {

                Integer myintval = Integer.valueOf(item.QUANTITY);
                item.QUANTITY = String.valueOf(myintval);
                System.debug('WHOLE NO.***********'+myintval);

            }
        }
        /*For Quantity Shipped field*/
        for (ET_SALES_ITEM_DATA_ITEM item : response.salesItemData) {
            if (item.QTY_SHIPPED != null) {

                Integer myintvalShip = Integer.valueOf(item.QTY_SHIPPED);
                item.QTY_SHIPPED = String.valueOf(myintvalShip);
                System.debug('WHOLE NO.***********'+myintvalShip);

            }
        }
        /*For Extended Price format*/
        for (ET_SALES_ITEM_DATA_ITEM item : response.salesItemData) {
           if (item.ITEM_NET_VALUE != null) {
               if(item.ITEM_NET_VALUE.isNumeric()){
                   Integer curVar = Integer.valueOf(item.ITEM_NET_VALUE);
                   item.ITEM_NET_VALUE = String.valueOf(curVar.format());
                   system.debug('ITEM_NET_VALUE____'+item.ITEM_NET_VALUE);
               }else{
                   String curVar = String.valueOf(item.ITEM_NET_VALUE);
                   item.ITEM_NET_VALUE = curVar;
                   system.debug('value is decimal only');
                   system.debug('decimal value is '+item.ITEM_NET_VALUE);
               }

        	//String curVar = String.valueOf(Integer.valueOf(item.ITEM_NET_VALUE));
            //item.ITEM_NET_VALUE = curVar;

        	system.debug('curVar------'+item.ITEM_NET_VALUE);
        	}
        }
        /*For Price per Unit format*/
        for (ET_SALES_ITEM_DATA_ITEM item : response.salesItemData) {
           if (item.UNIT_PRICE != null) {
        	//Integer curVar = Integer.valueOf(item.UNIT_PRICE);
            //item.UNIT_PRICE = String.valueOf(curVar.format());

               if(item.UNIT_PRICE.isNumeric()){
                   Integer curVar = Integer.valueOf(item.UNIT_PRICE);
                   item.UNIT_PRICE = String.valueOf(curVar.format());
                   system.debug('item.UNIT_PRICE'+item.UNIT_PRICE);
               }else{
                   String curVar = String.valueOf(item.UNIT_PRICE);
                   item.UNIT_PRICE = curVar;
                   system.debug('value is decimal only');
                   system.debug('decimal value is '+item.UNIT_PRICE);
               }
        	system.debug('curVar------'+item.UNIT_PRICE);
        	}
        }
        /*For Product Code format*/
        for (ET_SALES_ITEM_DATA_ITEM item : response.salesItemData) {
           if (item.PRODUCT_NUMBER != null) {

               if(item.PRODUCT_NUMBER.isNumeric()){
                String curVar = String.valueOf(Integer.valueOf(item.PRODUCT_NUMBER));
                item.PRODUCT_NUMBER = curVar;
                system.debug('curVar------'+item.PRODUCT_NUMBER);
               }

               else{
                   String curVar = String.valueOf(item.PRODUCT_NUMBER);
                   item.PRODUCT_NUMBER = curVar;
                   System.debug('item.PRODUCT_NUMBER'+item.PRODUCT_NUMBER);
               }




        	}
        }
        /*For Req Del Date format in Order Detail page*/
        for (ET_SALES_HEADER_DATA_ITEM item : response.salesHeaderData) {
            System.debug('Request Del date');
           if (item.REQ_DEL_DATE != null) {
               if(item.REQ_DEL_DATE == '0000-00-00'){
                   system.debug('item.REQ_DEL_DATE-----------'+item.REQ_DEL_DATE);
                   item.REQ_DEL_DATE = null;
               }else{
               System.debug('********');
                Date dt = Date.valueOf(item.REQ_DEL_DATE );
                   system.debug('dt'+dt);
                Date dtTodayDate = dt;
                Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
                //Datetime dtTodayDateTime = '12-12-2020';
                string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                system.debug('Date in MM/DD/YYYY format:'+strDate);
                   item.REQ_DEL_DATE = strDate;
                system.debug('item.REQ_DEL_DATE_____-----'+item.REQ_DEL_DATE);
               }
        	}
        }
        /*For Estimated Ship Date format*/
        for (ET_SCHEDULE_DATA_ITEM  item : response.scheduleData) {
           if (item.EST_SHIP_DATE != null) {
               if(item.EST_SHIP_DATE == '0000-00-00'){
                   system.debug('item.EST_SHIP_DATE-----------'+item.EST_SHIP_DATE);
                   item.EST_SHIP_DATE = null;
               }else{
                system.debug('item.EST_SHIP_DATE-----------'+item.EST_SHIP_DATE);
        		Date dt = Date.valueOf(item.EST_SHIP_DATE);
                system.debug('dt_____'+dt);
        		Date dtTodayDate = dt;
				Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
				//Datetime dtTodayDateTime = '12-12-2020';
				string strDate = dtTodayDateTime.format('MM/dd/yyyy');
				system.debug('Date in MM/DD/YYYY format:'+strDate);
                item.EST_SHIP_DATE = strDate;
                system.debug('item.EST_SHIP_DATE-------'+item.EST_SHIP_DATE);
               }
        	}
		}
        
        /*For Estimated Del Date format*/
        for (ET_SCHEDULE_DATA_ITEM  item : response.scheduleData) {
           if (item.EST_DEL_DATE != null) {
               if(item.EST_DEL_DATE == '0000-00-00'){
                   item.EST_DEL_DATE = null;
               }else{
        		Date dt = Date.valueOf(item.EST_DEL_DATE);
        		Date dtTodayDate = dt;
				Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
				//Datetime dtTodayDateTime = '12-12-2020';
				string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                item.EST_DEL_DATE = strDate;
               }
        	}
		}
        
        /*For INVOICE_DATE format*/
        for (ET_SCHEDULE_DATA_ITEM  item : response.scheduleData) {
           if (item.INVOICE_DATE != null) {
               if(item.INVOICE_DATE == '0000-00-00'){
                   item.INVOICE_DATE = null;
               }else{
        		Date dt = Date.valueOf(item.INVOICE_DATE);
        		Date dtTodayDate = dt;
				Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
				//Datetime dtTodayDateTime = '12-12-2020';
				string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                item.INVOICE_DATE = strDate;
               }
        	}
		}

        /*For  format
        for (ET_SCHEDULE_DATA  item : response.scheduleDataNew) {
           if (item.SHIPPED_FROM != null) {
               item.SHIPPED_FROM = item.SHIPPED_FROM;
               system.debug('Shipped From'+item.SHIPPED_FROM);


        	}
		}*/


        /*For Estimated Del Date format*/
        for (ET_SALES_ITEM_DATA_ITEM  item : response.salesItemData) {
           if (item.SCH_DEL_DATE != null) {
               if(item.SCH_DEL_DATE == '0000-00-00'){
                   system.debug('item.SCH_DEL_DATE-----------'+item.SCH_DEL_DATE);
                   item.SCH_DEL_DATE = null;
               }else{
                Date dt = Date.valueOf(item.SCH_DEL_DATE);
                Date dtTodayDate = dt;
                Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
                //Datetime dtTodayDateTime = '12-12-2020';
                string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                system.debug('Date in MM/DD/YYYY format:'+strDate);
                   item.SCH_DEL_DATE = strDate;
               }
        	}
        }
        /*For Req Del Date format Line level*/
        for (ET_SALES_ITEM_DATA_ITEM  item : response.salesItemData) {
           if (item.REQ_DEL_DATE != null) {
               if(item.REQ_DEL_DATE == '0000-00-00'){
                   system.debug('item.REQ_DEL_DATE-----------'+item.REQ_DEL_DATE);
                   item.REQ_DEL_DATE = null;
               }else{

        	Date dt = Date.valueOf(item.REQ_DEL_DATE);
        	Date dtTodayDate = dt;
			Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
			//Datetime dtTodayDateTime = '12-12-2020';
			string strDate = dtTodayDateTime.format('MM/dd/yyyy');
			system.debug('Date in MM/DD/YYYY format:'+strDate);
               item.REQ_DEL_DATE = strDate;
        	}
           }
        }
        
        /*For FPDD transformation at Line level*/
        /*for (ET_SALES_ITEM_DATA_ITEM  item : response.salesItemData) {
            for(ET_SCHEDULE_DATA_ITEM  itemAdd : response.scheduleData){
                if(item.ITEM_NUMBER==itemAdd.ITEM_NUMBER){
                    if (itemAdd.FPDD != null) {
                        if(itemAdd.FPDD == '0000-00-00'){
                            item.FPDD_y = null;
                        }else{
                            
                            Date dt = Date.valueOf(itemAdd.FPDD);
                            Date dtTodayDate = dt;
                            Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
                            //Datetime dtTodayDateTime = '12-12-2020';
                            string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                            system.debug('Date in MM/DD/YYYY format:'+strDate);
                            item.FPDD_y = strDate;
                        }
                    }
                    Break;
                }    
            }
        }*/
        
        /*For FPDD transformation at Line level*/        
        for (ET_SCHEDULE_DATA_ITEM  item : response.scheduleData) {
           if (item.FPDD != null) {
               if(item.FPDD == '0000-00-00'){
                   item.FPDD = null;
               }else{
        		Date dt = Date.valueOf(item.FPDD);
        		Date dtTodayDate = dt;
				Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
				//Datetime dtTodayDateTime = '12-12-2020';
				string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                item.FPDD = strDate;
               }
        	}
		}
        
        for (ET_SCHEDULE_DATA_ITEM  item : response.scheduleData) {
             
             item.ITEM_NUMBER=item.ITEM_NUMBER.Substring(2);
        }
        
        for (ET_SALES_ITEM_DATA_ITEM  item : response.salesItemData) {
             
             item.ITEM_NUMBER=item.ITEM_NUMBER.Substring(2);
        }


        return response;
	}

    public static OrderDetails getDetailsTest(String orderId,String userId){

        User u = [SELECT Id, ContactId, Email, AccountId FROM User WHERE Id =: userId];
        Account acc = [
                SELECT Id,
                        Name,
                        GE_LGT_EM_SAP_Customer_Number__c,
                        GE_LGT_EM_Sales_Org__c,
                        GE_LGT_EM_Division__c,
                        GE_LGT_EM_Distribution_Channel__c,
                        Delivering_Plant__c,
                        Account_Group__c,
                        GE_LGT_Rep_Code__c
                FROM Account
                WHERE Id = :u.AccountId
        ];

        Order ord = getOrder(orderId);
        OrderRequest req = new OrderRequest();
        //req.orderNumber = '0000854216';
        //req.salesOrg = '1US1';
        //system.debug('Testing');

        req.orderNumber = ord.GE_Order_NO__c;
        req.salesOrg = ord.Sold_To__r.GE_LGT_EM_Sales_Org__c;
        OrderDetails response = service.orderDisplay(req);
        response.userAccountGroup = acc.Account_Group__c;


        OrderDetails od = new OrderDetails();
        List<ET_SCHEDULE_DATA_ITEM> sdiList = new List<ET_SCHEDULE_DATA_ITEM>();
        ET_SCHEDULE_DATA_ITEM sd = new ET_SCHEDULE_DATA_ITEM();
        sd.ORDER_NUMBER = '0000854216';
        sd.ITEM_NUMBER = '000010';
        sd.DEL_NUMBER = '0051930074';
        sd.DEL_ITEM_NUMBER = '000010';
        sd.QUANTITY = '12.00';
        sd.SALES_UNIT = 'EA';
        sd.CARRIER_NAME = 'FEDEX GROUND';
        sd.SHIPPED_FROM = 'Mira Loma MDC';
        sd.INVOICE_NUMBER = '1170968263';
        sd.INVOICE_ITEM = '000170';
        sd.INVOICE_DATE = '2020-04-03';
        sd.CONFIRMED = 'Y';
        sd.EST_SHIP_DATE = '2020-04-03';
        sd.EST_DEL_DATE = '2020-04-07';
        sd.ACT_SHIP_DATE = '2020-04-03';
        sd.ACT_DEL_DATE = '2020-04-07';
        sd.TRACKING_NUMBER = '153705794927';
        sd.SHIPMENT_NUMBER = '0001386916';
        sdiList.add(sd);

        ET_SCHEDULE_DATA_ITEM sd1 = new ET_SCHEDULE_DATA_ITEM();
        sd1.ORDER_NUMBER = '0000854216';
        sd1.ITEM_NUMBER = '000010';
        sd1.DEL_NUMBER = '0051930089';
        sd1.DEL_ITEM_NUMBER = '000010';
        sd1.QUANTITY = '12.00';
        sd1.SALES_UNIT = 'EA';
        sd1.CARRIER_NAME = 'HMES';
        sd1.SHIPPED_FROM = 'Mira Loma MDC';
        sd1.INVOICE_NUMBER = '1170968263';
        sd1.INVOICE_ITEM = '000170';
        sd1.INVOICE_DATE = '2020-04-03';
        sd1.CONFIRMED = 'Y';
        sd1.EST_SHIP_DATE = '2020-04-03';
        sd1.EST_DEL_DATE = '2020-04-07';
        sd1.ACT_SHIP_DATE = '2020-04-03';
        sd1.ACT_DEL_DATE = '2020-04-07';
        sd1.TRACKING_NUMBER = '10883728625';
        sd1.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd1);


        ET_SCHEDULE_DATA_ITEM sd2 = new ET_SCHEDULE_DATA_ITEM();
        sd2.ORDER_NUMBER = '0000854216';
        sd2.ITEM_NUMBER = '000010';
        sd2.DEL_NUMBER = '0051930089';
        sd2.DEL_ITEM_NUMBER = '000010';
        sd2.QUANTITY = '12.00';
        sd2.SALES_UNIT = 'EA';
        sd2.CARRIER_NAME = 'FEDERAL EXPRESS PM';
        sd2.SHIPPED_FROM = 'Mira Loma MDC';
        sd2.INVOICE_NUMBER = '1170968263';
        sd2.INVOICE_ITEM = '000170';
        sd2.INVOICE_DATE = '2020-04-03';
        sd2.CONFIRMED = 'Y';
        sd2.EST_SHIP_DATE = '2020-04-03';
        sd2.EST_DEL_DATE = '2020-04-07';
        sd2.ACT_SHIP_DATE = '2020-04-03';
        sd2.ACT_DEL_DATE = '2020-04-07';
        sd2.TRACKING_NUMBER = '10883740793';
        sd2.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd2);

        ET_SCHEDULE_DATA_ITEM sd3 = new ET_SCHEDULE_DATA_ITEM();
        sd3.ORDER_NUMBER = '926841';
        sd3.ITEM_NUMBER = '000010';
        sd3.DEL_NUMBER = '0051930089';
        sd3.DEL_ITEM_NUMBER = '000010';
        sd3.QUANTITY = '12.00';
        sd3.SALES_UNIT = 'EA';
        sd3.CARRIER_NAME = 'FEDEX GROUND';
        sd3.SHIPPED_FROM = 'Mira Loma MDC';
        sd3.INVOICE_NUMBER = '1170968263';
        sd3.INVOICE_ITEM = '000170';
        sd3.INVOICE_DATE = '2020-04-03';
        sd3.CONFIRMED = 'Y';
        sd3.EST_SHIP_DATE = '2020-04-03';
        sd3.EST_DEL_DATE = '2020-04-07';
        sd3.ACT_SHIP_DATE = '2020-04-03';
        sd3.ACT_DEL_DATE = '2020-04-07';
        sd3.TRACKING_NUMBER = '945996426090';
        sd3.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd3);

        ET_SCHEDULE_DATA_ITEM sd4 = new ET_SCHEDULE_DATA_ITEM();
        sd4.ORDER_NUMBER = '926841';
        sd4.ITEM_NUMBER = '000010';
        sd4.DEL_NUMBER = '0051930089';
        sd4.DEL_ITEM_NUMBER = '000010';
        sd4.QUANTITY = '12.00';
        sd4.SALES_UNIT = 'EA';
        sd4.CARRIER_NAME = 'SAIA';
        sd4.SHIPPED_FROM = 'Mira Loma MDC';
        sd4.INVOICE_NUMBER = '1170968263';
        sd4.INVOICE_ITEM = '000170';
        sd4.INVOICE_DATE = '2020-04-03';
        sd4.CONFIRMED = 'Y';
        sd4.EST_SHIP_DATE = '2020-04-03';
        sd4.EST_DEL_DATE = '2020-04-07';
        sd4.ACT_SHIP_DATE = '2020-04-03';
        sd4.ACT_DEL_DATE = '2020-04-07';
        sd4.TRACKING_NUMBER = '104619064806';
        sd4.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd4);


        ET_SCHEDULE_DATA_ITEM sd5 = new ET_SCHEDULE_DATA_ITEM();
        sd5.ORDER_NUMBER = '926841';
        sd5.ITEM_NUMBER = '000010';
        sd5.DEL_NUMBER = '0051930089';
        sd5.DEL_ITEM_NUMBER = '000010';
        sd5.QUANTITY = '12.00';
        sd5.SALES_UNIT = 'EA';
        sd5.CARRIER_NAME = 'ESTES EXPRESS';
        sd5.SHIPPED_FROM = 'Mira Loma MDC';
        sd5.INVOICE_NUMBER = '1170968263';
        sd5.INVOICE_ITEM = '000170';
        sd5.INVOICE_DATE = '2020-04-03';
        sd5.CONFIRMED = 'Y';
        sd5.EST_SHIP_DATE = '2020-04-03';
        sd5.EST_DEL_DATE = '2020-04-07';
        sd5.ACT_SHIP_DATE = '2020-04-03';
        sd5.ACT_DEL_DATE = '2020-04-07';
        sd5.TRACKING_NUMBER = '0552440943';
        sd5.SHIPMENT_NUMBER = '0001386732';
        sdiList.add(sd5);

        od.scheduleData = sdiList;
        //return od;

        for (ET_SALES_ITEM_DATA_ITEM item : response.salesItemData) {
            if (item.CURRENCY_x == 'USD') {
                item.CURRENCY_y = '$';
            } else {
                item.CURRENCY_y = item.CURRENCY_x;
            }
        }

        return response;
    }



    public class OrderDetails{
        @AuraEnabled
        public List<ET_HEAD_ORDER_TEXT> headComments {get; set;}
        @AuraEnabled
        public List<ET_HEAD_ORDER_TEXT> headShipInstru {get; set;}
        @AuraEnabled
        public List<ET_HEAD_ORDER_TEXT> itemComments {get; set;}
        @AuraEnabled
        public List<ET_SALES_DEL_INV_DATA_ITEM> salesDelInvData {get; set;}
        @AuraEnabled
        public List<ET_SALES_HEADER_DATA_ITEM> salesHeaderData {get; set;}
        @AuraEnabled
        public List<ET_SALES_ITEM_DATA_ITEM> salesItemData {get; set;}
        @AuraEnabled
        public List<ET_SCHEDULE_DATA_ITEM> scheduleData {get; set;}



        @AuraEnabled
        public List<ET_SHIPMENT_HEADER_ITEM> shipmentHeader {get; set;}
        @AuraEnabled
        public List<ET_SHIPMENT_LINES_ITEM> shipmentLines {get; set;}
        @AuraEnabled
        public List<IT_EXT_REP_CODE_ITEM> extRepCode {get; set;}
        @AuraEnabled
        public List<IT_INT_REP_CODE_ITEM> intRepCode {get; set;}
        @AuraEnabled
        public List<IT_EXT_REP_CODE_ITEM> soldTo {get; set;}
        @AuraEnabled
        public List<IT_SALES_ORDER_ITEM> salesOrder {get; set;}
        @AuraEnabled
        public String userAccountGroup {get; set;}
    }

    public class OrderRequest{
        public String orderNumber {get; set;}
        public String salesOrg {get; set;}
    }

    public class ET_HEAD_ORDER_TEXT{
        @AuraEnabled
        public String ITEM {get; set;}
        @AuraEnabled
        public String TEXT {get; set;}
    }

    public class ET_SALES_DEL_INV_DATA_ITEM{
        @AuraEnabled
        public String ORDER_NUMBER {get; set;}
        @AuraEnabled
        public String ITEM_NUMBER {get; set;}
        @AuraEnabled
        public String DEL_NUMBER {get; set;}
        @AuraEnabled
        public String DEL_ITEM_NUMBER {get; set;}
        @AuraEnabled
        public String PRODUCT_NUMBER {get; set;}
        @AuraEnabled
        public String PRODUCT_DESCRIPTION {get; set;}
        @AuraEnabled
        public String INVOICE_NUMBER {get; set;}
        @AuraEnabled
        public String INVOICE_ITEM {get; set;}
        @AuraEnabled
        public String INVOICE_DATE{get; set;}
        @AuraEnabled
        public boolean expanded {get; set;} {expanded = false;}
    }

    public class ET_SALES_HEADER_DATA_ITEM{
        @AuraEnabled
        public String ORDER_NUMBER {get; set;}
        @AuraEnabled
        public String PO_NUMBER {get; set;}
        @AuraEnabled
        public String SOLD_TO_NUMBER {get; set;}
        @AuraEnabled
        public String SOLD_TO_NAME {get; set;}
        @AuraEnabled
        public String ORDER_DATE {get; set;}
        @AuraEnabled
        public String REQ_DEL_DATE {get; set;}
        @AuraEnabled
        public String TOTAL_NET_VALUE {get; set;}
        @AuraEnabled
        public String ORDER_STATUS {get; set;}
        @AuraEnabled
        public String OPPORTUNITY_ID {get; set;}
        @AuraEnabled
        public String EXT_REP_CODE {get; set;}
        @AuraEnabled
        public String INT_REP_CODE {get; set;}
        @AuraEnabled
        public String SHIP_TO_NAME {get; set;}
        @AuraEnabled
        public String SHIP_TO_STREET1 {get; set;}
        @AuraEnabled
        public String SHIP_TO_STREET2 {get; set;}
        @AuraEnabled
        public String SHIP_TO_CITY {get; set;}
        @AuraEnabled
        public String SHIP_TO_STATE {get; set;}
        @AuraEnabled
        public String SHIP_TO_ZIP {get; set;}
        @AuraEnabled
        public String SHIP_TO_COUNTRY {get; set;}
        @AuraEnabled
        public String BILL_TO_NAME {get; set;}
        @AuraEnabled
        public String BILL_TO_STREET1 {get; set;}
        @AuraEnabled
        public String BILL_TO_STREET2 {get; set;}
        @AuraEnabled
        public String BILL_TO_CITY {get; set;}
        @AuraEnabled
        public String BILL_TO_STATE {get; set;}
        @AuraEnabled
        public String BILL_TO_ZIP {get; set;}
        @AuraEnabled
        public String BILL_TO_COUNTRY {get; set;}
        @AuraEnabled
        public String CURRENCY_x {get; set;}
        @AuraEnabled
        public String CURRENCY_y {get; set;}
        @AuraEnabled
        public String SPECIAL_COMMENTS {get; set;}
        @AuraEnabled
        public String TOTAL_COMMISSION {get; set;}
        @AuraEnabled
        public String ORDER_SOURCE {get; set;}
        @AuraEnabled
        public String TOTAL_WEEE {get; set;}
        @AuraEnabled
        public String TOTAL_LIGHT_TAX {get; set;}
        @AuraEnabled
        public String HEAD_DEL_BLOCK {get; set;}
        @AuraEnabled
        public String BLOCK_DESCRIPTION {get; set;}
        @AuraEnabled
        public String CREDIT_STATUS {get; set;}
        @AuraEnabled
        public String SHIP_VIA {get; set;}
        @AuraEnabled
        public String SAMPLE_ORDER_FLAG {get; set;}
        @AuraEnabled
        public String COMP_PART_SHIP {get; set;}
        @AuraEnabled
        public String CARRIER_ACCOUNT_NO {get; set;}
        @AuraEnabled
        public String PROJECT_NAME {get; set;}
        @AuraEnabled
        public String USER_NAME {get; set;}
        @AuraEnabled
        public String USER_EMAIL {get; set;}
        @AuraEnabled
        public String ADD_RECIPIENT_NAME {get; set;}
        @AuraEnabled
        public String ADD_RECIPIENT_EMAIL {get; set;}
        @AuraEnabled
        public String SHIP_LABEL_COMMENTS {get; set;}
        @AuraEnabled
        public String ALLOW_BACK_ORDER {get; set;}
        @AuraEnabled
        public String SHIPMENT_TYPE {get; set;}
        @AuraEnabled
        public String PART_SHIP_ALLOWED {get; set;}
        @AuraEnabled
        public String SHIP_CONTACT_NAME {get; set;}
        @AuraEnabled
        public String SHIP_CONTACT_NUMBER {get; set;}
        @AuraEnabled
        public String SALES_ORG {get; set;}
        @AuraEnabled
        public String DIST_CHANNEL {get; set;}
        @AuraEnabled
        public String DIVISION {get; set;}
        @AuraEnabled
        public String INCOMPLETE {get; set;}
        @AuraEnabled
        public String ORDER_TYPE {get; set;}
        @AuraEnabled
        public String x_xGEL_xCONNECT_ORDNR {get; set;}
        @AuraEnabled
        public boolean expanded {get; set;} {expanded = false;}
    }

    public class ET_SALES_ITEM_DATA_ITEM{
        @AuraEnabled
        public String ORDER_NUMBER {get; set;}
        @AuraEnabled
        public String ITEM_NUMBER {get; set;}
        @AuraEnabled
        public String PRODUCT_NUMBER {get; set;}
        @AuraEnabled
        public String PRODUCT_DESCRIPTION {get; set;}
        @AuraEnabled
        public String CUST_REF_NUMBER {get; set;}
        @AuraEnabled
        public String QUANTITY {get; set;}
        @AuraEnabled
        public String SCH_DEL_DATE {get; set;}
        @AuraEnabled
        public String REQ_DEL_DATE {get; set;}
        @AuraEnabled
        public String UNIT_PRICE {get; set;}
        @AuraEnabled
        public String ITEM_STATUS {get; set;}
        @AuraEnabled
        public String ITEM_NET_VALUE {get; set;}
        @AuraEnabled
        public String CURRENCY_x {get; set;}
        @AuraEnabled
        public String CURRENCY_y {get; set;}
        @AuraEnabled
        public String SALES_UNIT {get; set;}
        @AuraEnabled
        public String ITEM_COMM_PER {get; set;}
        @AuraEnabled
        public String ITEM_COMM_VALUE {get; set;}
        @AuraEnabled
        public String DIRECT_SUB_REASON {get; set;}
        @AuraEnabled
        public String REASONFOR_REJECTION {get; set;}
        @AuraEnabled
        public String PRICE_AGR_NUMBER {get; set;}
        @AuraEnabled
        public String LIST_PRICE {get; set;}
        @AuraEnabled
        public String SPECIAL_INSTRUCTIONS {get; set;}
        @AuraEnabled
        public String PRICE_LIST {get; set;}
        @AuraEnabled
        public String LEAD_TIME {get; set;}
        @AuraEnabled
        public String REQUESTED_PRICE {get; set;}
        @AuraEnabled
        public String CUSTOMER_DESCRIPTION {get; set;}
        @AuraEnabled
        public String WEEE {get; set;}
        @AuraEnabled
        public String LIGHT_TAX {get; set;}
        @AuraEnabled
        public String ITEM_DEL_BLOCK {get; set;}
        @AuraEnabled
        public String BLOCK_DESCRIPTION {get; set;}
        @AuraEnabled
        public String QTY_SHIPPED {get; set;}
        @AuraEnabled
        public String ADP_PRICE {get; set;}
        @AuraEnabled
        public String UOM {get; set;}//line added
        @AuraEnabled
        public String PRICE_VALUE {get; set;}
        @AuraEnabled
        public String PRICE_UNIT {get; set;}
        @AuraEnabled
        public String INCOMPLETE {get; set;}
        @AuraEnabled
        public String OVERAGE_COMMISSION {get; set;}
        @AuraEnabled
        public String STANDARD_COMMISSION {get; set;}
        @AuraEnabled
        public String FPDD_y {get; set;}
        @AuraEnabled
        public boolean expanded {get; set;} {expanded = false;}
    }



    public class ET_SCHEDULE_DATA_ITEM{
        @AuraEnabled
        public String ORDER_NUMBER {get; set;}
        @AuraEnabled
        public String ITEM_NUMBER {get; set;}
        @AuraEnabled
        public String DEL_NUMBER {get; set;}
        @AuraEnabled
        public String DEL_ITEM_NUMBER {get; set;}
        @AuraEnabled
        public String QUANTITY {get; set;}
        @AuraEnabled
        public String SALES_UNIT {get; set;}
        @AuraEnabled
        public String CARRIER_NAME {get; set;}
        @AuraEnabled
        public String SHIPPED_FROM {get; set;}
        @AuraEnabled
        public String UOM {get; set;}//line added
        @AuraEnabled
        public String INVOICE_NUMBER {get; set;}
        @AuraEnabled
        public String INVOICE_ITEM {get; set;}
        @AuraEnabled
        public String INVOICE_DATE {get; set;}
        @AuraEnabled
        public String CONFIRMED {get; set;}
        @AuraEnabled
        public String EST_SHIP_DATE {get; set;}
        @AuraEnabled
        public String EST_DEL_DATE {get; set;}
        @AuraEnabled
        public String ACT_SHIP_DATE {get; set;}
        @AuraEnabled
        public String ACT_DEL_DATE {get; set;}
        @AuraEnabled
        public String TRACKING_NUMBER {get; set;}
        @AuraEnabled
        public String SHIPMENT_NUMBER {get; set;}
        @AuraEnabled
        public String FPDD {get; set;}
        @AuraEnabled
        public boolean expanded {get; set;} {expanded = false;}
    }

    public class ET_SHIPMENT_HEADER_ITEM{
        public String WADAT {get; set;}
        @AuraEnabled
        public String TDLNR {get; set;}
        @AuraEnabled
        public String VTEXT {get; set;}
        @AuraEnabled
        public String TNDR_TRKID {get; set;}
        @AuraEnabled
        public String CARRIER_NAME {get; set;}
        @AuraEnabled
        public String TKNUM {get; set;}
        @AuraEnabled
        public String SHIPPED_FROM {get; set;}
    }

    public class ET_SHIPMENT_LINES_ITEM{
        @AuraEnabled
        public String VBELN {get; set;}
        @AuraEnabled
        public String POSNR {get; set;}
        @AuraEnabled
        public String MATNR {get; set;}
        @AuraEnabled
        public String ARKTX {get; set;}
        @AuraEnabled
        public String LFIMG {get; set;}
        @AuraEnabled
        public String TKNUM {get; set;}
        @AuraEnabled
        public String TPNUM {get; set;}
        @AuraEnabled
        public String VOLUM {get; set;}
        @AuraEnabled
        public String BRGEW {get; set;}
        @AuraEnabled
        public boolean expanded {get; set;} {expanded = false;}
    }

    public class IT_EXT_REP_CODE_ITEM{
        @AuraEnabled
        public String KUNNR {get; set;}
    }

    public class IT_INT_REP_CODE_ITEM{
        @AuraEnabled
        public String PERNR {get; set;}
    }

    public class IT_SALES_ORDER_ITEM{
        @AuraEnabled
        public String VBELN {get; set;}
    }
}