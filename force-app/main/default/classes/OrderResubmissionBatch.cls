global class OrderResubmissionBatch	implements Database.Batchable <SObject>, Schedulable, Database.AllowsCallouts {

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			Select 
        Id,
        Name,
        Partial_Ship__c,
        Ship_Not_Before_Date__c,
        Ship_Complete__c,    
        ccrz__CurrencyISOCode__c,
        Carrier_Account__c,
        Delivery_Block__c,
        Delivery_Contact_Phone__c,
        Delivery_Contact_Name__c,
        ccrz__BuyerFirstName__c,
        ccrz__BuyerLastName__c,
        ccrz__BuyerEmail__c,
        ccrz__BuyerPhone__c,    
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
				FROM ccrz__E_Order__c
			WHERE Resubmit_Order__c = true
			AND Resubmission_Attempts__c < 3
			AND ccrz__OrderStatus__c = 'Order Submitted'
		]);
	}

	global void execute(Database.BatchableContext context, List<ccrz__E_Order__c> orders) {
		List<Id> orderIds = new List<Id>();
		for(ccrz__E_Order__c order : orders) {
			orderIds.add(order.Id);
		}

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
				ccrz__ExtSKU__c,
            	ccrz__ExtName__c,
                ccrz__Order__c,
                Type_Marks__c,
                Agreement_Number__c,
            	ccrz__OriginalItemPrice__c,
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
                    ccrz__Comments__c,
                    Type_Marks__c,
                    Agreement_Number__c
                FROM ccrz__Order_Items__r)
            FROM ccrz__E_OrderItem__c
            WHERE ccrz__OrderLineType__c = 'Major'
			AND ccrz__Order__c IN: orderIds];
			Map<Id,List<ccrz__E_OrderItem__c>> orderOIMap= new Map<Id,List<ccrz__E_OrderItem__c>>();
			
			for(ccrz__E_OrderItem__c oi:orderItems){
				if(!orderOIMap.containsKey(oi.ccrz__Order__c)){
					List<ccrz__E_OrderItem__c> oiList=new List<ccrz__E_OrderItem__c>();
					oiList.add(oi);
					orderOIMap.put(oi.ccrz__Order__c, oiList);
				}else{
					List<ccrz__E_OrderItem__c> oiList=orderOIMap.get(oi.ccrz__Order__c);
					oiList.add(oi);
					orderOIMap.put(oi.ccrz__Order__c, oiList);
				}
			}
			for(ccrz__E_Order__c newOrder : orders) {
			List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();
            Set<Id> cartItemIds = new Set<Id>();
            for(ccrz__E_OrderItem__c oi:orderOIMap.get(newOrder.Id)){
                cartItemIds.add(Id.valueOf(oi.ccrz__OrderItemId__c));
            }
            List<ccrz__E_CartItem__c> cartItems = [Select Id, Requested_Delivery_Date__c, ccrz__Comments__c FROM ccrz__E_CartItem__c WHERE Id IN: cartItemIds];
            Map<Id, ccrz__E_CartItem__c> cartItemMap = new Map<Id,ccrz__E_CartItem__c>();
            for(ccrz__E_CartItem__c ci:cartItems){
                cartItemMap.put(ci.Id,ci);
            }
            for(ccrz__E_OrderItem__c oi:orderOIMap.get(newOrder.Id)){
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
	}

	global void finish(Database.BatchableContext context) {
		List<ccrz__E_Order__c> failedOrders = [
			SELECT Id
			FROM ccrz__E_Order__c
			WHERE Resubmission_Attempts__c >= 3
			AND Resubmit_Order__c = true
		];
		if(!failedOrders.isEmpty()){
				OrgWideEmailAddress owa = [SELECT  id,
						DisplayName,
						Address
				FROM OrgWideEmailAddress 
				LIMIT 1];
				EmailTemplate template = 
				[SELECT Id
				FROM EmailTemplate
				WHERE DeveloperName = 'CC_Order_Submission_Failed'];

				List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
				Map<String, Failed_Order_Submission_Email_Address__mdt> customMetaDataEmail = new Map<String, Failed_Order_Submission_Email_Address__mdt>();
				List<String> emails = new List<String>();
				for(Failed_Order_Submission_Email_Address__mdt mdt : customMetaDataEmail.values()) {
					emails.add(mdt.Email_Address__c);
				}

				for(ccrz__E_Order__c ord : failedOrders) {
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					mail.setTemplateID(template.Id);
					mail.setSaveAsActivity(false);
					mail.setOrgWideEmailAddressId(owa.Id);
					mail.setToAddresses(emails);
					mail.setWhatId(ord.Id);
					allmsg.add(mail);
				}

				Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
		}
	}

	public void execute(SchedulableContext ctx) {
		OrderResubmissionBatch batch = new OrderResubmissionBatch();
		Database.executeBatch(batch);
	}
}