public class OrderTriggerHandler {
	public void onBeforeUpdate(List<ccrz__E_Order__c> updatedOrders) {
		String orderId = '';

		for(ccrz__E_Order__c order : updatedOrders) {
			if (order.Resubmit_Order__c == true) {
				orderId=order.Id;
				break;
			}
		}

		if(!String.isEmpty(orderId)) {
			createOrderFuture(orderId);
		}
	}

	@future(callout=true)
    public static void createOrderFuture(String orderId){
        ccrz__E_Order__c newOrder=[Select 
        Id,
        Name,
        Partial_Ship__c,
        Ship_Not_Before_Date__c,
       	Ship_Complete__c,
        ccrz__CurrencyISOCode__c,
        Carrier_Account__c,
        Delivery_Block__c,
        Order_Reason__c,
        Project_Name__c,
        Project_City__c,
        Project_State__c,
        Project_Country__c,
        Project_Description__c,
        Project_Postal_Code__c,
        Requested_Delivery_Date__c,
        Strategic_Account__c,
        Sold_To_Account__c,
        Serial_Number__c,
        SAP_Order_Number__c,
        Order_Type__c,
        Revise_Agreement_Number__c,
        Agreement_Number__c,
        SAP_Message__c,
        SAP_Approved__c,
        Valid_From__c,
        Valid_To__c,
        Delivery_Contact_Name__c,
        Delivery_Contact_Phone__c,
        ccrz__BuyerFirstName__c,
        ccrz__BuyerLastName__c,
        ccrz__BuyerEmail__c,
        ccrz__BuyerPhone__c,
        ccrz__OriginatedCart__r.Id,
        ccrz__OriginatedCart__r.Lot_Pricing__c,
        ccrz__OriginatedCart__r.Lot_Pricing_Amount__c,
        ccrz__OriginatedCart__r.Agreement_Number__c,
        ccrz__OriginatedCart__r.Agent_Rep_Code__c,
        ccrz__OriginatedCart__r.Project_Description__c,
        ccrz__OriginatedCart__r.Sample_Order__c,
        ccrz__OriginatedCart__r.Shipping_Instructions__c,
        ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_Order_Block__c,
        ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__OriginatedCart__r.ccrz__Account__r.Account_Group__c,
                ccrz__OriginatedCart__r.ccrz__Account__r.Customer_Segmentation__c,
        ccrz__OriginatedCart__r.Is_Z002__c,
        ccrz__OriginatedCart__r.Z002Address__c,
        ccrz__OriginatedCart__r.ShippingType__c,
        ccrz__OriginatedCart__r.Ship_Complete__c,
        ccrz__OriginatedCart__r.Ship_Not_Before_Date__c,
        ccrz__OriginatedCart__r.Strategic_Account_L__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__ShipTo__r.ccrz__AddressFirstline__c,
        ccrz__ShipTo__r.ccrz__AddressSecondline__c, 
        ccrz__ShipTo__r.ccrz__StateISOCode__c, 
        ccrz__ShipTo__r.ccrz__City__c, 
        ccrz__ShipTo__r.ccrz__PostalCode__c, 
        ccrz__ShipTo__r.ccrz__CountryISOCode__c, 
        ccrz__ShipTo__r.ccrz__FirstName__c, 
        ccrz__ShipTo__r.ccrz__LastName__c,
        ccrz__Contact__r.Email,
        ccrz__Contact__r.Phone,
        ccrz__Contact__r.Name,
        ccrz__Contact__r.Account.Account_Group__c,
        ccrz__Contact__r.Account.GE_LGT_Rep_Code__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Distribution_Channel__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Division__c,
        ccrz__Contact__r.Account.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__Contact__r.GE_LGT_EM_SAP_Customer_No__c,
        ccrz__Contact__r.Account.GE_LGT_EM_Sales_Org__c,
        (Select Id, ccrz__AccountNumber__c From ccrz__TransactionPayments__r)
        From ccrz__E_Order__c Where Id=:orderId];

        List<ccrz__E_OrderItem__c> orderItems = [
            SELECT Id, 
                ccrz__Price__c,
                ccrz__Quantity__c,
                ccrz__OrderItemStatus__c,
                ccrz__Product__r.ccrz__SKU__c,
                ccrz__Product__r.MaterialDescription__c,
                ccrz__ItemTotal__c,
                ccrz__SubAmount__c,
                ccrz__UnitOfMeasure__c,
                ccrz__OrderItemId__c,
                Requested_Delivery_Date__c,
                Comments__c,
                ccrz__Comments__c,
            	Type_Marks__c,
            	Agreement_Number__c,
                ccrz__ExtSKU__c,
                (SELECT Id,
                    ccrz__Price__c,
                    ccrz__Quantity__c,
                    ccrz__OrderItemStatus__c,
                    ccrz__ItemTotal__c,
                    ccrz__SubAmount__c,
                    ccrz__Product__r.ccrz__SKU__c,
                    ccrz__Product__r.MaterialDescription__c,
                    ccrz__UnitOfMeasure__c,
                    ccrz__OrderItemId__c,
                    Requested_Delivery_Date__c,
                    Comments__c,
                    ccrz__Comments__c
                FROM ccrz__Order_Items__r)
            FROM ccrz__E_OrderItem__c
            WHERE ccrz__OrderLineType__c = 'Major'
            AND ccrz__Order__c = :orderId];
			List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();
            Set<Id> cartItemIds = new Set<Id>();
            for(ccrz__E_OrderItem__c oi:orderItems){
                cartItemIds.add(Id.valueOf(oi.ccrz__OrderItemId__c));
            }
            List<ccrz__E_CartItem__c> cartItems = [Select Id, Requested_Delivery_Date__c, ccrz__Comments__c FROM ccrz__E_CartItem__c WHERE Id IN: cartItemIds];
            Map<Id, ccrz__E_CartItem__c> cartItemMap = new Map<Id,ccrz__E_CartItem__c>();
            for(ccrz__E_CartItem__c ci:cartItems){
                cartItemMap.put(ci.Id,ci);
            }
            for(ccrz__E_OrderItem__c oi:orderItems){
                ccrz__E_CartItem__c ci=cartItemMap.get(Id.valueOf(oi.ccrz__OrderItemId__c));
                oi.Requested_Delivery_Date__c=ci.Requested_Delivery_Date__c;
                oi.Comments__c=ci.ccrz__Comments__c;
            }

            SAPGateway gateway = new SAPGateway();
            String salesNumber=gateway.createOrder(newOrder, orderItems);
            if(salesNumber!='SAPServiceException'){
                newOrder.Resubmission_Attempts__c=0;
                newOrder.SAP_Order_Number__c=salesNumber;
				newOrder.Resubmit_Order__c=false;
				ordersToUpdate.add(newOrder);
            }else{
                newOrder.Resubmission_Attempts__c=(newOrder.Resubmission_Attempts__c+1);
				newOrder.Resubmit_Order__c=true;
				ordersToUpdate.add(newOrder);
            }
			
			if(!Test.isRunningTest()){
				System.enqueueJob(new OrderUpdateQueueable(ordersToUpdate));
			}
        
    }

	/*@future(callout=true)
	public static void pushOrdersToSAP(List<Id> orderIds) {
		List<ccrz__E_Order__c> orders = orderDA.getOrdersByIDs(orderIds);

		List<Id> accountIDs = new List<Id>();
		for(ccrz__E_Order__c order : orders) {
			if(order.ccrz__EffectiveAccountID__c != null) {
				accountIDs.add(order.ccrz__EffectiveAccountID__c);
			} else {
				accountIDs.add(order.ccrz__Account__c);
			}
		}

		Map<Id, SAPAccount> accountToSAPNumber = factory.createForAccounts(accountIds);
		List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();

		for(ccrz__E_Order__c order : orders) {
			SAPGateway.SAPOrderCreate orderCreate = new SAPGateway.SAPOrderCreate();
			String accId;
			if(order.ccrz__EffectiveAccountID__c != null) {
				accId = order.ccrz__EffectiveAccountID__c;
			} else {
				accId = order.ccrz__Account__c;
			}
			SAPAccount sap_account = accountToSAPNumber.get(accId);
			order.SAP_Sales_Area__c = sap_account.SalesOrg;
			order.Resubmission_Attempts__c = 0;

			orderCreate.sfid = order.Id;
			orderCreate.Account = sap_account;
			orderCreate.ShipTo = order.ccrz__ShipTo__r.ccrz__Partner_Id__c;
			orderCreate.ShippingInstructions = order.ccrz__ShipTo__r.ccrz__ShippingComments__c;
			orderCreate.Customer_Email = order.ccrz__BuyerEmail__c;
			ccrz__E_TransactionPayment__c payment = order.ccrz__TransactionPayments__r[0];

			if(payment.ccrz__AccountType__c == 'po') {
				orderCreate.PONumber = payment.ccrz__AccountNumber__c;
			} else {
				orderCreate.AuthCode = payment.ccrz__TransactionCode__c;
				orderCreate.TransactionId = payment.ccrz__TransactionPaymentId__c;
				orderCreate.TokenId = payment.ccrz__Token__c;
			}

			for(ccrz__E_OrderItem__c item : order.ccrz__E_OrderItems__r) {
				SAPGateway.OrderItem orderItem = new SAPGateway.OrderItem();
				orderItem.Guid = item.Id;
				orderItem.Sku = item.ccrz__Product__r.ccrz__SKU__c;
				orderItem.Quantity = calculateQuantity(item.ccrz__Quantity__c, item.ccrz__Product__r);
				orderCreate.OrderItems.add(orderItem);
			}

			try {
				SAPGateway.SAPOrderComplete createdOrder = service.createOrder(orderCreate);
				order.SAP_Order_Number__c = createdOrder.OrderNumber;
				order.Resubmit_Order__c = false;
				ordersToUpdate.add(order);
			} catch(SAPGateway.SAPServiceException ex) {
				order.Resubmit_Order__c = true;
				ordersToUpdate.add(order);
			}
		}

		if(!Test.isRunningTest()){
			System.enqueueJob(new OrderUpdateQueueable(ordersToUpdate));
		}
	}*/
}