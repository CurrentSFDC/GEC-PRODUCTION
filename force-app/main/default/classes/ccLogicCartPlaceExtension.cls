global without sharing class ccLogicCartPlaceExtension extends ccrz.ccLogicCartPlace {
    global override Map<String, Object> placeOrder(Map<String, Object> inputData){
        Map<String, Object> outputData = super.placeOrder(inputData);
        system.debug(outputData);
        String orderId=(String)outputData.get(ccrz.ccApiCart.ORDER_ID);
        if(!String.isEmpty(orderId)){
            createOrderFuture(orderId);
        }
        return outputData;
    }

    @future(callout=true)
    private static void createOrderFuture(String orderId){
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
        ccrz__OriginatedCart__r.Agreement_Number__c,
        ccrz__OriginatedCart__r.Agent_Rep_Code__c,                           
        ccrz__OriginatedCart__r.Lot_Pricing_Amount__c,
        ccrz__OriginatedCart__r.Project_Description__c,
        ccrz__OriginatedCart__r.Sample_Order__c,
        ccrz__OriginatedCart__r.Shipping_Instructions__c,
        ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__OriginatedCart__r.Sold_To_Account__r.GE_LGT_EM_Order_Block__c,                           
        ccrz__OriginatedCart__r.Is_Z002__c,
        ccrz__OriginatedCart__r.Z002Address__c,
        ccrz__OriginatedCart__r.ShippingType__c,                           
        ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__OriginatedCart__r.ccrz__Account__r.Account_Group__c,
        ccrz__OriginatedCart__r.ccrz__Account__r.Customer_Segmentation__c,
        ccrz__OriginatedCart__r.ccrz__Account__r.GE_LGT_EM_Sales_Org__c,
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
        ccrz__ShipTo__r.ccrz__CompanyName__c,                            
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
            	ccrz__PricingType__c,
                Requested_Delivery_Date__c,
                Comments__c,
                ccrz__Comments__c,
                Agreement_Number__c,
                ccrz__ExtSKU__c,
            	ccrz__ExtName__c,
                Type_Marks__c,
                ccrz__OrderLineType__c,
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
                 	ccrz__PrimaryAttr__r.Name,
                    Requested_Delivery_Date__c,
                    Comments__c,
                    ccrz__Comments__c,
                    ccrz__OrderLineType__c
                FROM ccrz__Order_Items__r)
            FROM ccrz__E_OrderItem__c
            WHERE ccrz__OrderLineType__c = 'Major'
            AND ccrz__Order__c = :orderId];

            Set<Id> cartItemIds = new Set<Id>();
            for(ccrz__E_OrderItem__c oi:orderItems){
                cartItemIds.add(Id.valueOf(oi.ccrz__OrderItemId__c));
            }
            List<ccrz__E_CartItem__c> cartItems = [Select Id, Type_Marks__c, Requested_Delivery_Date__c, ccrz__Comments__c, Agreement_Number__c FROM ccrz__E_CartItem__c WHERE Id IN: cartItemIds];
            Map<Id, ccrz__E_CartItem__c> cartItemMap = new Map<Id,ccrz__E_CartItem__c>();
            for(ccrz__E_CartItem__c ci:cartItems){
                cartItemMap.put(ci.Id,ci);
            }
            for(ccrz__E_OrderItem__c oi:orderItems){
                ccrz__E_CartItem__c ci=cartItemMap.get(Id.valueOf(oi.ccrz__OrderItemId__c));
                oi.Requested_Delivery_Date__c=ci.Requested_Delivery_Date__c;
                oi.Type_Marks__c = ci.Type_Marks__c;
                oi.Comments__c=ci.ccrz__Comments__c;
                oi.Agreement_Number__c = ci.Agreement_Number__c;
            }
          // update orderItems;
        if(newOrder.Order_Type__c == 'Price Agreement' || newOrder.Order_Type__c == 'One Time Price Agreement'){
            System.debug('submitting PA');
            PriceAgreementController.PriceAgreementCreateResponse resp = PriceAgreementController.PriceAgreementCreateNew(newOrder, orderItems);
            System.debug(resp);
            newOrder.Agreement_Number__c = resp.agreement;
            newOrder.SAP_Message__c = resp.message;
            newOrder.SAP_Approved__c = resp.approved;
            update newOrder;
            update orderItems;
        }
        else if(newOrder.Order_Type__c == 'Revise Price Agreement'){
            System.debug('submitting PA Revision');
            PriceAgreementController.PriceAgreementCreateResponse resp = PriceAgreementController.PriceAgreementRevise(newOrder, orderItems);
            newOrder.Agreement_Number__c = resp.agreement;
            newOrder.SAP_Message__c = resp.message;
            newOrder.SAP_Approved__c = resp.approved;
            update newOrder;
            update orderItems;
        }
        else{
            SAPGateway gateway = new SAPGateway();
            if(!Test.isRunningTest()) {
            String salesNumber=gateway.createOrder(newOrder, orderItems);
            if(salesNumber.contains('Msg~')){
                newOrder.SAP_Message__c = salesNumber.split('~')[1];
            }
            else if(salesNumber!='SAPServiceException'){
                newOrder.Resubmission_Attempts__c=0;
                newOrder.SAP_Order_Number__c=salesNumber;
                newOrder.Resubmit_Order__c=false;
                newOrder.Agreement_Number__c= newOrder.ccrz__OriginatedCart__r.Agreement_Number__c;
            }else{
                newOrder.Resubmission_Attempts__c=(newOrder.Resubmission_Attempts__c+1);
                newOrder.Resubmit_Order__c=true;
            }
            }
            update newOrder;
            update orderItems;
        }
        
    }
}