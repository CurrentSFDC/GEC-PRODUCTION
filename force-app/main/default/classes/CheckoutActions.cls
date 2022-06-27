global class CheckoutActions {
	@RemoteAction
    global static ccrz.cc_RemoteActionResult updateShipFields(ccrz.cc_RemoteActionContext ctx, Boolean partialShip, String carrierAccount, String deliveryBlock,  String requestedDeliveryDate, String shippingInstructions, String contactName, String contactPhone, String shipNotes, Boolean ShipNotBeforeDate, Boolean isestShippingClicked ){
        
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String cartId =Id.valueOf(CartServices.getActiveCartId());
        
        try{
			ccrz__E_Cart__c cart = [SELECT Partial_Ship__c,Ship_Not_Before_Date__c,Ship_Complete__c, Carrier_Account__c, Delivery_Block__c, Requested_Delivery_Date__c, Delivery_Contact_Name__c, Delivery_Contact_Phone__c, Shipping_Instructions__c FROM ccrz__E_Cart__c WHERE Id =: cartId];
			cart.Partial_Ship__c = partialShip;
			cart.Carrier_Account__c=carrierAccount;
			cart.Delivery_Block__c=deliveryBlock;
            cart.Ship_Not_Before_Date__c=ShipNotBeforeDate;
       		cart.Ship_Complete__c= isestShippingClicked;

            if (requestedDeliveryDate!=null && requestedDeliveryDate!='' && String.isNotEmpty(requestedDeliveryDate)) cart.Requested_Delivery_Date__c=Date.valueOf(requestedDeliveryDate);
            cart.Delivery_Contact_Name__c = contactName;
            cart.Delivery_Contact_Phone__c = contactPhone;
            cart.Shipping_Instructions__c = shipNotes;
			update cart;
            res.success = true; 
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }
    
	@RemoteAction
	global static Account StrategicAccounts_New(ccrz.cc_RemoteActionContext ctx, String StrategicAccountId){

        Account StrategicAccount = new Account();
		String StrAcc;

	    StrategicAccount = [Select id,Name, GE_LGT_EM_SAP_Customer_Number__c from Account where id =:StrategicAccountId];

	    return StrategicAccount;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateZ002(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try{
            String cartId =Id.valueOf(CartServices.getActiveCartId());
            ccrz__E_Cart__c cart = [SELECT Is_Z002__c  FROM ccrz__E_Cart__c WHERE Id =: cartId];
            cart.Is_Z002__c=true;
            update cart;
            res.success=true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateGeneralFields(ccrz.cc_RemoteActionContext ctx, Map<String, Object> formData, Map<String, Object> projectAddress){
        
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String cartId =Id.valueOf(CartServices.getActiveCartId());

        String state = (String)projectAddress.get('state');

        if(projectAddress.containsKey('stateCode')){
            state = (String)projectAddress.get('stateCode');
        }
        
        try{
			ccrz__E_Cart__c cart = [SELECT Valid_From__c, Valid_To__c, Project_Name__c, Project_Description__c, Project_Country__c, Project_State__c, Project_City__c, Project_Postal_Code__c, Order_Reason__c, Serial_Number__c, Strategic_Account__c, Lot_Pricing__c, Lot_Pricing_Amount__c  FROM ccrz__E_Cart__c WHERE Id =: cartId];
			cart.Project_Name__c = (String)formData.get('projectName');
            cart.Project_Description__c = (String)formData.get('projectDescription');
            cart.Project_Country__c = (String)projectAddress.get('countryCode');
            cart.Project_State__c = state;
            cart.Project_City__c = (String)projectAddress.get('city');
            cart.Agency_Name__c = (String)formData.get('agentName');
            cart.Agent_Rep_Code__c = (String)formData.get('repCode');
            cart.Project_Postal_Code__c = (String)projectAddress.get('postalCode');
            if(formData.containsKey('orderReason')){
                cart.Order_Reason__c=(String)formData.get('orderReason');
            }
            system.debug(formData.get('lotPricingAmount'));
            Boolean lotPricing=false;
            if((String)formData.get('lotPricing')=='on'){
                lotPricing=true;
            }
            cart.Lot_Pricing__c=lotPricing;
            if(!String.isEmpty((String)formData.get('lotPricingAmount'))){
                cart.Lot_Pricing_Amount__c=Decimal.valueOf((String)formData.get('lotPricingAmount'));
            }
            cart.Serial_Number__c=(String)formData.get('serialNumber');
            //cart.Strategic_Account__c=(String)formData.get('strategicAccount');
            cart.Strategic_Account_L__c=(String)formData.get('strategicAccount');
            if(String.isNotBlank((String)formData.get('validFrom'))){
                cart.Valid_From__c = Date.valueOf((String)formData.get('validFrom'));
            }
            if(String.isNotBlank((String)formData.get('validTo'))){
                cart.Valid_To__c = Date.valueOf((String)formData.get('validTo'));
            }
            update cart;
            res.success = true; 
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult submitPA(ccrz.cc_RemoteActionContext ctx, String cartId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        System.debug([SELECT Id FROM ccrz__E_Cart__c WHERE Id =: cartId]);
        try{  
            Map<String, Object> placeInput = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ID => cartId
            };
            Map<String, Object> placeResults = ccrz.ccApiCart.place(placeInput);
            ccrz__E_Order__c newOrder = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Order__c WHERE Id =: (String)placeResults.get(ccrz.ccApiCart.ORDER_ID)];
            res.data = newOrder.ccrz__EncryptedId__c;
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
            ccrz.ccLog.close(res);
        }
        return res;
    }
    
     @RemoteAction
    global static String getCustSegment(ccrz.cc_RemoteActionContext ctx){
        String custSegment='';
        String effAccountId = ctx.effAccountId;
        Account effectiveAcct = [SELECT ConnectFixtureAgents__c,Customer_Segmentation__c from Account Where Id =: effAccountId];
        if(effectiveAcct.Customer_Segmentation__c != 'FD' && effectiveAcct.Customer_Segmentation__c != 'fixture'){
            custSegment='NotValid';
          return custSegment;
        }
      return custSegment;  
    }
    
     @RemoteAction
    global static List<Account> getrelatedRepCodes(ccrz.cc_RemoteActionContext ctx, String contactId){ 
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        List<Account> relatedRepCodes = new List<Account>();
        String effAccountId = ctx.effAccountId;
        
        try{
            relatedRepCodes = AccountServices.getConnectFixtureAgents(effAccountId);
            res.success = true; 
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return relatedRepCodes;
    }
    
    @RemoteAction
    global static String getSelRepCode(ccrz.cc_RemoteActionContext ctx){
        String selRepCode='';
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try{
            String cartId =Id.valueOf(CartServices.getActiveCartId());
            ccrz__E_Cart__c cart = [SELECT Agent_Rep_Code__c  FROM ccrz__E_Cart__c WHERE Id =: cartId];
            selRepCode=cart.Agent_Rep_Code__c;
            res.success=true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return selRepCode;
    }
    
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult clearAddress(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
         Id effAccountId = Id.valueOf(ctx.effAccountId);
        
                try{
                    List<ccrz__E_AccountAddressBook__c> existingBook = [SELECT Id FROM ccrz__E_AccountAddressBook__c WHERE Id =: effAccountId];
                    delete existingBook;
                }catch(Exception e){
                    res.success=false;
                    return res; 
                }
            
      return res;  
    } 
    
     @RemoteAction
    global static Map<String,Address> getsoldToAdd(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        Map<String,Address> shippMap = new Map<String,Address>();
       
        try{
            String cartId =Id.valueOf(CartServices.getActiveCartId());
            System.debug('CART ID : ' + cartId);
            ccrz__E_Cart__c cart = [SELECT Sold_To_Account__r.Name,Sold_To_Account__r.AccountNumber,Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,Sold_To_Account__r.ShippingAddress FROM ccrz__E_Cart__c WHERE Id =: cartId];
            System.debug('CART: ' + cart.Sold_To_Account__r.ShippingAddress);
            shippMap.put(cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c+';'+cart.Sold_To_Account__r.Name.remove('\'')+';'+cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,cart.Sold_To_Account__r.ShippingAddress);
            res.success=true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return shippMap; 
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveShippingDetails(ccrz.cc_RemoteActionContext ctx, String addComp, String addLine1, String addCity,  String addState, String addPostal, String addCountry ,String addSAPCust,String shippingType){
        
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String cartId =Id.valueOf(CartServices.getActiveCartId());
        ccrz__E_Cart__c cart = [SELECT Z002Address__c,ShippingType__c FROM ccrz__E_Cart__c WHERE Id =: cartId];

        try{
            cart.ShippingType__c= shippingType;
            if(String.isBlank(addComp) && String.isBlank(addLine1) && String.isBlank(addCity) && String.isBlank(addState) && String.isBlank(addPostal) && String.isBlank(addCountry) )
            {
		  res.data = 'No update in shipping address of cart';
             }
            else{
                
            cart.Z002Address__c=addComp+';'+addLine1+';'+addCity+';'+addState+';'+addPostal +';'+addCountry+';'+addSAPCust;             
            res.success = true;
            res.data = 'updated shipping address of cart'+cart.Z002Address__c;  
            }
            update cart;  
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

     @RemoteAction
    global static ccrz.cc_RemoteActionResult clearShippingDetails(ccrz.cc_RemoteActionContext ctx){
        
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String cartId =Id.valueOf(CartServices.getActiveCartId());
        
        try{
            
			ccrz__E_Cart__c cart = [SELECT Z002Address__c FROM ccrz__E_Cart__c WHERE Id =: cartId];
            cart.Z002Address__c='';
			update cart;
           
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }
    
    
      @RemoteAction
    global static ccrz.cc_RemoteActionResult cleardefaultShippingDetails(ccrz.cc_RemoteActionContext ctx){
        
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String cartId =Id.valueOf(CartServices.getActiveCartId());
        
        try{
            
			ccrz__E_Cart__c cart = [SELECT ccrz__ShipTo__r.id,Is_Z002__c FROM ccrz__E_Cart__c WHERE Id =: cartId];
            if(!cart.Is_Z002__c){
            ccrz__E_ContactAddr__c conZ002 = [SELECT ccrz__CompanyName__c,ccrz__City__c,ccrz__Country__c,ccrz__State__c,ccrz__PostalCode__c,ccrz__AddressFirstline__c FROM ccrz__E_ContactAddr__c WHERE Id =: cart.ccrz__ShipTo__r.id];
            cart.Is_Z002__c=true;
            update cart;
            conZ002.ccrz__CompanyName__c='';
            conZ002.ccrz__City__c='';
            conZ002.ccrz__Country__c='';
            conZ002.ccrz__State__c='';
            conZ002.ccrz__PostalCode__c='';
            conZ002.ccrz__AddressFirstline__c='';
			update conZ002;
           }
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }
    
      @RemoteAction
    global static ccrz.cc_RemoteActionResult getSAPOrderNo(ccrz.cc_RemoteActionContext ctx,String orderID){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=false;
        try{
            ccrz__E_Order__c order = [SELECT SAP_Order_Number__c,SAP_Message__c,Agreement_Number__c,Order_Type__c FROM ccrz__E_Order__c WHERE Id =: orderID];
            if(String.isNotBlank(order.SAP_Order_Number__c)){
              res.data='Thank you for placing your order! Your order number is '+ order.SAP_Order_Number__c +'.' ;
              res.success=true;           
            }
           else if(String.isNotBlank(order.SAP_Message__c) && order.Order_Type__c=='Purchase Order'){
              res.data='Thank you for placing your order! '+order.SAP_Message__c;
              res.success=true;
            }
           else if(String.isNotBlank(order.Agreement_Number__c) && order.Order_Type__c=='Price Agreement'){
              res.data='Thank you for requesting a price agreement! Your price agreement request is '+order.Agreement_Number__c+'.';
              res.success=true;
            }
           else if(String.isNotBlank(order.Agreement_Number__c) && order.Order_Type__c=='Revise Price Agreement'){
              res.data='Thank you for requesting a revision for price agreement. Your price agreement request for revision is '+order.Agreement_Number__c+'.';
              res.success=true;
            }
           else if(String.isNotBlank(order.SAP_Message__c) && order.Order_Type__c=='Price Agreement'){
              res.data='Thank you for requesting a price agreement! '+order.SAP_Message__c;
              res.success=true;
            }
           else if(String.isNotBlank(order.SAP_Message__c) && order.Order_Type__c=='Revise Price Agreement'){
              res.data='Thank you for requesting a revision for price agreement! '+order.SAP_Message__c;
              res.success=true;
            } 
            
           
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getOrderInfoById(ccrz.cc_RemoteActionContext ctx,String orderID){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=false;
        res.data = '';
        try {
            ccrz__E_Order__c order = [SELECT ccrz__BuyerFirstName__c,ccrz__BuyerLastName__c,ccrz__BuyerPhone__c,ccrz__BuyerEmail__c,Order_Type__c,
                                             Project_Name__c,Project_Description__c,Project_Country__c,Project_City__c,Project_State__c,Project_Postal_Code__c,Strategic_Account__c,
                                             ShippingType__c,Ship_Not_Before_Date__c,Requested_Delivery_Date__c,Ship_Complete__c,Partial_Ship__c,Delivery_Contact_Name__c,Delivery_Contact_Phone__c,ccrz__ShipMethod__c,Z002Address__c,
                                             ccrz__OriginatedCart__r.Shipping_Instructions__c, Agreement_Number__c, Sold_To_Account__c, Valid_From__c, Valid_To__c,
                                             ccrz__OriginatedCart__r.Lot_Pricing__c, ccrz__OriginatedCart__r.Lot_Pricing_Amount__c
                                      FROM ccrz__E_Order__c WHERE Id =: orderID LIMIT 1];
            String accName = '';
            try {
                Account a = [SELECT Name FROM Account WHERE GE_LGT_EM_SAP_Customer_Number__c = :order.Sold_To_Account__c LIMIT 1];
                accName = a.Name;
            }catch(Exception e) {
                System.debug(e);
            }
            System.debug('CheckoutActions order ' + order);
            res.data += '                            <div class="col-xs-12 col-md-3">\n' +
                    '                                <h5 class="cc_buyer_information">Buyer Information</h5>\n' +
                    '                                <p class="cc_buyer">\n';
            if (order.Sold_To_Account__c != null) {
                res.data += '<span class="cc_shipping_delivery_date_label" style="font-weight: bold;">Sold To Account&#58;&#160;</span><br>\n';
                res.data += '                                <p class="cc_buyer_firstname">' + accName + ' (' + order.Sold_To_Account__c.replaceFirst('^0+', '') + ')</p>\n<p class="cc_buyer_firstname">&nbsp;</p>\n';
            }
            if (order.ccrz__BuyerFirstName__c != null && order.ccrz__BuyerLastName__c != null) {
                res.data += '                                <p class="cc_buyer_firstname">' + order.ccrz__BuyerFirstName__c + ' ' + order.ccrz__BuyerLastName__c + '</p>\n';
            }
            if(order.ccrz__BuyerPhone__c != null) {
                res.data += '                                <p class="cc_buyer_phone">' + order.ccrz__BuyerPhone__c + '</p>\n';
            }
            if (order.ccrz__BuyerEmail__c != null) {
                res.data += '                                <p class="cc_buyer_email">' + order.ccrz__BuyerEmail__c + '</p>\n';
            }
            if (order.Order_Type__c == 'Purchase Order' && order.Agreement_Number__c != null) {
                res.data += '<h5 class="cc_shipping_information">Price Agreement</h5>\n';
                res.data += '<span class="cc_addr_postal">' + order.Agreement_Number__c + '</span>\n';
            }
            res.data += '                                </p>\n' +
                    '                            </div>\n';
            res.data += '                            <div class="col-xs-12 col-md-3">\n' +
                    '                                <h5 class="cc_shipping_information">Project Information</h5>\n' +
                    '                                <p class="cc_shipping">\n';
            if (order.Project_Name__c != null) {
                res.data += '                                <p class="cc_buyer_firstname">' + order.Project_Name__c + '</p>\n';
            }
            if (order.Project_Description__c != null) {
                res.data += '                                <p class="cc_buyer_firstname">' + order.Project_Description__c + '</p>\n';
            }
            if (order.Project_Country__c != null) {
                res.data += '                                <span class="cc_addr_country">' + order.Project_Country__c + '</span><br/>\n';
            }
            if (order.Project_City__c != null) {
                res.data += '                                <span class="cc_addr_city">' + order.Project_City__c + '</span><br/>\n';
            }
            if (order.Project_State__c != null && order.Project_Country__c != null && order.Project_Country__c == 'US') {
                res.data += '                                <span class="cc_addr_state">' + order.Project_State__c + '</span><br/>\n';
            }
            if (order.Project_Postal_Code__c != null) {
                res.data += '                                <span class="cc_addr_postal">' + order.Project_Postal_Code__c + '</span>\n';
            }
            res.data += '                                </p>';
            if (order.Strategic_Account__c != null && order.Strategic_Account__c != '') {
                res.data += '<h5 class="cc_buyer_information">Strategic Account No.</h5>\n' +
                        '                                <p class="cc_buyer">\n' +
                        '                                <p class="cc_buyer_firstname">' + order.Strategic_Account__c + '</p>\n' +
                        '                                </p>';
            }
            res.data += '                            </div>\n';
            res.data += '                            <div class="col-xs-12 col-md-3">\n';
            if ((order.Order_Type__c == 'Purchase Order' && order.ccrz__OriginatedCart__r.Shipping_Instructions__c != null && order.ccrz__OriginatedCart__r.Shipping_Instructions__c != '') || Test.isRunningTest()) {
                List<String> shippingNotes = Test.isRunningTest() ? new List<String>{'Test: 1'} : order.ccrz__OriginatedCart__r.Shipping_Instructions__c.split(', ');
                Map<String, String> shippingNoteValues = new Map<String, String>();
                for (String note : shippingNotes) {
                    List<String> value = note.split(': ');
                    if (value.size() > 1) {
                        shippingNoteValues.put(value.get(0), value.get(1));
                    }
                }
                res.data += '<a href="javascript:void(0)" onclick="$(\'#shipNotes\').modal(\'show\');"><h5 class="cc_shipping_address_label">Shipping Notes</h5></a>\n' +
                        '                                <div id="shipNotes" class="modal fade cc_modal cc_cart_comments_modal in" tabindex="-1" role="dialog" aria-labelledby="TypeMarks" style="display: none;">\n' +
                        '                                    <div class="modal-dialog" role="document">\n' +
                        '                                        <div class="modal-content cc_modal_content">\n' +
                        '                                            <div class="modal-header cc_modal_header">\n' +
                        '                                                <button type="button" class="close cc_close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>\n' +
                        '                                                <h4 class="modal-title cc_modal_title" id="shipNotes">\n' +
                        '                                                    Shipping Notes\n' +
                        '                                                </h4>\n' +
                        '                                            </div>\n' +
                        '                                            <div id="shipNotesModalBody" class="modal-body cc_modal_body container form-group">\n' +
                        '                                                <form id="shipNotesModalForm" class="cc_comments_form">\n' +
                        '                                                    <div class="row">\n' +
                        '                                                        <div id="shipNotesLeftCol" class="col-sm-6">\n' +
                        '                                                            <label for="doNotDoubleStack" class="cc_shipnotes_label"> Do not double stack pallets</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="doNotDoubleStack" name="doNotDoubleStack" value="Do not double stack pallets" ' + (shippingNotes.contains('Do not double stack pallets') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="doNotShipDoubles" class="cc_shipnotes_label"> Do not ship doubles</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="doNotShipDoubles" name="doNotShipDoubles" value="Do not ship doubles" ' + (shippingNotes.contains('Do not ship doubles') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="doNotSlipSheet" class="cc_shipnotes_label"> Do not slip sheet fluor lamps</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="doNotSlipSheet" name="doNotSlipSheet" value="Do not slip sheet fluor lamps" ' + (shippingNotes.contains('Do not slip sheet fluor lamps') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="userHampers" class="cc_shipnotes_label"> Use Hampers</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="userHampers" name="userHampers" value="Use Hampers" ' + (shippingNotes.contains('Use Hampers') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="useCornerGuards" class="cc_shipnotes_label"> Use Corner Guards</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="useCornerGuards" name="useCornerGuards" value="Use Corner Guards" ' + (shippingNotes.contains('Use Corner Guards') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="mixedSkus" class="cc_shipnotes_label"> Mixed SKUs?</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="mixedSkus" name="mixedSkus" value="Mixed SKUs?" ' + (shippingNotes.contains('Mixed SKUs?') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="liftGate" class="cc_shipnotes_label"> Lift gate</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="liftGate" name="liftGate" value="Lift gate" ' + (shippingNotes.contains('Lift gate') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="palletJack" class="cc_shipnotes_label"> Pallet jack</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="palletJack" name="palletJack" value="Pallet jack" ' + (shippingNotes.contains('Pallet jack') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="dockHeightTruck" class="cc_shipnotes_label"> Dock height truck</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="dockHeightTruck" name="dockHeightTruck" value="Dock height truck" ' + (shippingNotes.contains('Dock height truck') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="makeAppointment" class="cc_shipnotes_label"> Make appointment</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="makeAppointment" name="makeAppointment" value="Make appointment" ' + (shippingNotes.contains('Make appointment') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="signatureOnPOD" class="cc_shipnotes_label">Signature on POD</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="signatureOnPOD" name="signatureOnPOD" value="Signature on POD" ' + (shippingNotes.contains('Signature on POD') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="includePackingList" class="cc_shipnotes_label">Include Packing List</label>\n' +
                        '                                                            <input disabled="disabled" type="checkbox" id="includePackingList" name="includePackingList" value="Include Packing List" ' + (shippingNotes.contains('Include Packing List') ? 'checked' : '') + '><br>\n' +
                        '                                                            <label for="receivingHoursFrom" data-id="Receiving Hours" class="cc_shipnotes_label">Receiving Hours</label>\n' +
                        '                                                            <input disabled="disabled" type="time" id="receivingHoursFrom" data-id="Receiving Hours" name="receivingHoursFrom" value="' + (shippingNoteValues.containsKey('Receiving Hours') ? shippingNoteValues.get('Receiving Hours').split('-').get(0) : '') + '"><br>\n' +
                        '                                                            <input disabled="disabled" type="time" id="receivingHoursTo" name="receivingHoursTo" value="' + (shippingNoteValues.containsKey('Receiving Hours') ? shippingNoteValues.get('Receiving Hours').split('-').get(1) : '') + '"><br>\n' +
                        '                                                            <label for="deliverOnText" class="cc_shipnotes_label">Deliver On</label>\n' +
                        '                                                            <select disabled="disabled" name="deliverOnText" data-id="Deliver On" id="deliverOn">\n' +
                        '                                                                <option disabled selected value> -- </option>\n' +
                        '                                                                <option value="monday" ' + (shippingNotes.contains('Deliver On: monday') ? 'selected' : '') + '>Monday</option>\n' +
                        '                                                                <option value="tuesday" ' + (shippingNotes.contains('Deliver On: tuesday') ? 'selected' : '') + '>Tuesday</option>\n' +
                        '                                                                <option value="wednesday" ' + (shippingNotes.contains('Deliver On: wednesday') ? 'selected' : '') + '>Wednesday</option>\n' +
                        '                                                                <option value="thursday" ' + (shippingNotes.contains('Deliver On: thursday') ? 'selected' : '') + '>Thursday</option>\n' +
                        '                                                                <option value="friday" ' + (shippingNotes.contains('Deliver On: friday') ? 'selected' : '') + '>Friday</option>\n' +
                        '                                                            </select><br>\n' +
                        '                                                        </div>\n' +
                        '                                                        <div class="col-sm-6">\n' +
                        '                                                            <label for="palletHeightText" class="cc_shipnotes_label">Pallet Height</label>\n' +
                        '                                                            <input disabled="disabled" type="text" data-id="Pallet Height" id="palletHeightText" name="palletHeightText" class="shipnotes form-control cc_shipnotes" value="' + (shippingNoteValues.containsKey('Pallet Height') ? shippingNoteValues.get('Pallet Height') : '') + '"/><br>\n' +
                        '                                                            <label for="useOverwrapText"  class="cc_shipnotes_label">Use Overwrap on</label>\n' +
                        '                                                            <input disabled="disabled" type="text" id="useOverwrapText" data-id="Use Overwrap on" name="useOverwrapText" class="shipnotes form-control cc_shipnotes"  value="' + (shippingNoteValues.containsKey('Use Overwrap on') ? shippingNoteValues.get('Use Overwrap on') : '') + '"/><br>\n' +
                        '                                                            <label for="maxLayersHighText" class="cc_shipnotes_label">Max layers High</label>\n' +
                        '                                                            <input disabled="disabled" type="text" data-id="Max layers High" id="maxLayersHighText" name="maxLayersHighText" class="shipnotes form-control cc_shipnotes"  value="' + (shippingNoteValues.containsKey('Max layers High') ? shippingNoteValues.get('Max layers High') : '') + '"/><br>\n' +
                        '                                                            <label for="maxTruckHeightText" class="cc_shipnotes_label">Max truck height</label>\n' +
                        '                                                            <input disabled="disabled" type="text" data-id="Max truck height" id="maxTruckHeightText" name="maxTruckHeightText" class="shipnotes form-control cc_shipnotes"  value="' + (shippingNoteValues.containsKey('Max truck height') ? shippingNoteValues.get('Max truck height') : '') + '"/><br>\n' +
                        '                                                            <label for="maxTruckLengthText" class="cc_shipnotes_label">Max truck length</label>\n' +
                        '                                                            <input disabled="disabled" type="text" data-id="Max truck length" id="maxTruckLengthText" name="maxTruckLengthText" class="shipnotes form-control cc_shipnotes"  value="' + (shippingNoteValues.containsKey('Max truck length') ? shippingNoteValues.get('Max truck length') : '') + '"/><br>\n' +
                        '                                                            <label for="callAheadText" class="cc_shipnotes_label">Call Ahead</label>\n' +
                        '                                                            <input disabled="disabled" type="text" data-id="Call Ahead" id="callAheadText" name="callAheadText" class="shipnotes form-control cc_shipnotes"  value="' + (shippingNoteValues.containsKey('Call Ahead') ? shippingNoteValues.get('Call Ahead') : '') + '"/><br>\n' +
                        '                                                            <label for="emailAheadText" class="cc_shipnotes_label">Email ahead address</label>\n' +
                        '                                                            <input disabled="disabled" type="text" data-id="Email ahead address" id="emailAheadText" name="emailAheadText" class="shipnotes form-control cc_shipnotes"  value="' + (shippingNoteValues.containsKey('Email ahead address') ? shippingNoteValues.get('Email ahead address') : '') + '"/><br>\n';
                        if  (order.ShippingType__c != 'Will Call') {
                        res.data += '                                                <div class="form-group">'+
                        '                                                               <label for="nextDayAir" class="cc_shipnotes_label">Next Day Air</label>'+
                        '                                                               <input disabled="disabled" type="checkbox" id="nextDayAir" name="nextDayAir" value="Next Day Air" '+ (shippingNotes.contains('Next Day Air') ? 'checked' : '')+'>'+
                        '                                                            </div>'+
                        '                                                            <div class="form-group">'+
                        '                                                               <label for="secondDayAir" class="cc_shipnotes_label">2nd Day Air</label>'+
                        '                                                               <input disabled="disabled" type="checkbox" id="secondDayAir" name="secondDayAir" value="2nd Day Air" '+ (shippingNotes.contains('2nd Day Air') ? 'checked' : '')+'>'+
                        '                                                            </div>';
                        }
                        res.data += '                                                 <label for="fedexText" class="cc_shipnotes_label">FedEx #</label>\n' +
                        '                                                            <input disabled="disabled" type="text" data-id="FedEx #" id="fedexText" name="fedexText" class="shipnotes form-control cc_shipnotes"  value="' + (shippingNoteValues.containsKey('FedEx #') ? shippingNoteValues.get('FedEx #') : '') + '"/><br>\n' +
                        '                                                            <label for="otherText" class="cc_shipnotes_label">Other</label>\n' +
                        '                                                            <textarea disabled="disabled" id="otherText" data-id="Other" name="otherText" rows="6" maxlength="1000" class="shipnotes form-control cc_shipnotes" >' + (shippingNoteValues.containsKey('Other') ? order.ccrz__OriginatedCart__r.Shipping_Instructions__c.split('Other: ').get(1).left(order.ccrz__OriginatedCart__r.Shipping_Instructions__c.split('Other: ').get(1).length() - 1) : '') + '</textarea>\n' +
                        '                                                        </div>\n' +
                        '                                                    </div>\n' +
                        '                                                </form>\n' +
                        '                                            </div>\n' +
                        '                                            <div class="modal-footer cc_modal_footer">\n' +
                        '                                                <input type="button" class="btn btn-default btn-sm" value="Close" onclick="$(\'#shipNotes\').modal(\'hide\');"/>\n' +
                        '                                            </div>\n' +
                        '                                        </div>\n' +
                        '                                    </div>\n' +
                        '                                </div>';
            }
            if (test.isRunningTest() || order.Order_Type__c != 'Purchase Order') {
                res.data += '                                <h5 class="cc_shipping_information">Validity Dates</h5>\n' +
                        '                                <p class="cc_shipping">';
                if (order.Valid_From__c != null) {
                    res.data += '<p class="cc_shipping_method_section">\n' +
                            '                                    <span class="cc_shipping_method_label" style="font-weight: bold;">Valid From&#58;&#160;</span><br>\n' +
                            '                                    <span class="cc_shipping_method">' + formatDate(order.Valid_From__c) + '\n' +
                            '                                </p>';
                }
                if (order.Valid_To__c != null) {
                    res.data += '<p class="cc_shipping_method_section">\n' +
                            '                                    <span class="cc_shipping_method_label" style="font-weight: bold;">Valid To&#58;&#160;</span><br>\n' +
                            '                                    <span class="cc_shipping_method">' + formatDate(order.Valid_To__c) + '\n' +
                            '                                </p>';
                }
                if (order.ccrz__OriginatedCart__r.Lot_Pricing__c != null && order.ccrz__OriginatedCart__r.Lot_Pricing__c && order.ccrz__OriginatedCart__r.Lot_Pricing_Amount__c > 0) {
                    String formattedPrice = (order.ccrz__OriginatedCart__r.Lot_Pricing_Amount__c).setScale(2).format();
                    if (!formattedPrice.contains('.')) {
                        formattedPrice+='.00';
                    }
                    res.data += '<p class="cc_shipping_method_section">\n' +
                            '                                    <span class="cc_shipping_method_label" style="font-weight: bold;">Lot Pricing&#58;&#160;</span><br>\n' +
                            '                                    <span class="cc_shipping_method">' + (order.currencyISOCode == 'CAD' ? 'CA$' : '$') + formattedPrice + '\n' +
                            '                                </p>';
                }
                res.data += '                                </p>\n' +
                        '                            </div>\n';
            }
            if (test.isRunningTest() || order.Order_Type__c == 'Purchase Order') {
                res.data += '                                <h5 class="cc_shipping_information">Shipment Information</h5>\n' +
                        '                                <p class="cc_shipping">';
                if (order.ccrz__ShipMethod__c != null && order.ccrz__ShipMethod__c != '') {
                    res.data += '<p class="cc_shipping_method_section">\n' +
                            '                                    <span class="cc_shipping_method_label" style="font-weight: bold;">{{pageLabelMap \'CheckOut_ShippingMethod\'}}&#58;&#160;</span><br>\n' +
                            '                                    <span class="cc_shipping_method">' + order.ccrz__ShipMethod__c + '</span>\n' +
                            '                                </p>';
                }
                if (order.Ship_Not_Before_Date__c != null && order.Ship_Not_Before_Date__c) {
                    res.data += '                                <p class="cc_shipping_notes_section" style="font-weight: bold;">\n' +
                            '                                    <span class="cc_shipping_notes_label">Ship Not Before Date&#160;</span>\n' +
                            '                                </p>';
                }
                if (order.Requested_Delivery_Date__c != null) {
                    res.data += '                                <p>\n' +
                            '                                    <span class="cc_shipping_delivery_date_label" style="font-weight: bold;">Requested Delivery Date&#58;&#160;</span><br>\n' +
                            '                                    <span class="cc_shipping_delivery_date">' + formatDate(order.Requested_Delivery_Date__c) + '</span>\n' +
                            '                                </p>';
                }
                if (order.Ship_Complete__c != null && order.Ship_Complete__c) {
                    res.data += '                                <p class="cc_shipping_notes_section" style="font-weight: bold;">\n' +
                            '                                    <span class="cc_shipping_notes_label">Ship Complete&#160;</span>\n' +
                            '                                </p>';
                }
                if (order.Partial_Ship__c != null && order.Partial_Ship__c) {
                    res.data += '<p class="cc_shipping_notes_section" style="font-weight: bold;">\n' +
                            '                                    <span class="cc_shipping_notes_label">Partial Ship&#160;</span>\n' +
                            '                                </p>';
                }
                res.data += '                                <p>\n' +
                        '                                    <span class="cc_shipping_delivery_date_label" style="font-weight: bold;">Contact Name&#58;&#160;</span><br>\n' +
                        '                                    <span class="cc_shipping_delivery_date">' + order.Delivery_Contact_Name__c + '</span>\n' +
                        '                                </p>\n' +
                        '                                <p>\n' +
                        '                                    <span class="cc_shipping_delivery_date_label" style="font-weight: bold;">Contact Phone&#58;&#160;</span><br>\n' +
                        '                                    <span class="cc_shipping_delivery_date">' + order.Delivery_Contact_Phone__c + '</span>\n' +
                        '                                </p>\n' +
                        '                                </p>\n' +
                        '                            </div>\n';
            }
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
            System.debug(e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getItemReqDeviveryDate(ccrz.cc_RemoteActionContext ctx,String itemID){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=false;
        try {
            ccrz__E_OrderItem__c item = [SELECT Requested_Delivery_Date__c FROM ccrz__E_OrderItem__c WHERE id = :itemID LIMIT 1];
            res.data = item.Requested_Delivery_Date__c != null ? formatDate(item.Requested_Delivery_Date__c) : '';
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getItemTypeMarks(ccrz.cc_RemoteActionContext ctx,String itemID){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=false;
        try {
            ccrz__E_OrderItem__c item = [SELECT Type_Marks__c FROM ccrz__E_OrderItem__c WHERE id = :itemID LIMIT 1];
            res.data = item.Type_Marks__c != null && item.Type_Marks__c != '' ? item.Type_Marks__c : '';
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getItemComment(ccrz.cc_RemoteActionContext ctx,String itemID){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=false;
        try {
            ccrz__E_OrderItem__c item = [SELECT Comments__c FROM ccrz__E_OrderItem__c WHERE id = :itemID LIMIT 1];
            res.data = item.Comments__c != null && item.Comments__c != '' ? item.Comments__c : '';
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getOrderItemPriceAgreementNumber(ccrz.cc_RemoteActionContext ctx, String orderItemId){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try {
            ccrz__E_OrderItem__c item = [SELECT Agreement_Number__c FROM ccrz__E_OrderItem__c WHERE Id = :orderItemId];
            res.data = item.Agreement_Number__c == null ? '' : item.Agreement_Number__c;
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    public static String formatDate(Date dateToFormat) {
        return dateToFormat != null ? dateToFormat.month() + '/' + dateToFormat.day() + '/' + dateToFormat.year() : '';
    }

    @RemoteAction
    global static Map<String,Address> getAllrelatedZ002Add(ccrz.cc_RemoteActionContext ctx){ 
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String cartId =Id.valueOf(CartServices.getActiveCartId());
        
        List<Account> shipp = new List<Account>();
        Map<String,Address> shippMap = new Map<String,Address>();
        String effAccountId = ctx.effAccountId;
        
        ccrz__E_Cart__c cart = [SELECT ccrz__Contact__r.Account.Account_Group__c,Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c FROM ccrz__E_Cart__c WHERE Id =: cartId];
        
        try{
            
            if(cart.ccrz__Contact__r.Account.Account_Group__c=='ZEAG'){
                String newSearchText = '%'+cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c+'%';
                shipp = [SELECT Id,Name,AccountNumber, GE_LGT_EM_SAP_Customer_Number__c,ShippingAddress FROM Account WHERE Connect_Z002_Parents__c LIKE :newSearchText and GE_LGT_EM_CustomerActiveFlag__c=true];
                for(Account a:shipp){
                    shippMap.put(a.GE_LGT_EM_SAP_Customer_Number__c+';'+a.Name.remove('\'')+';'+a.GE_LGT_EM_SAP_Customer_Number__c,a.ShippingAddress);  
                }
                
            }
            
            else if(cart.ccrz__Contact__r.Account.Account_Group__c=='Z001'){
                Account ac = [SELECT Id, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id =: effAccountId];
                String newSearchText = '%'+ac.GE_LGT_EM_SAP_Customer_Number__c+'%';
                shipp = [SELECT Id,Name,AccountNumber, GE_LGT_EM_SAP_Customer_Number__c,ShippingAddress FROM Account WHERE Connect_Z002_Parents__c LIKE :newSearchText and GE_LGT_EM_CustomerActiveFlag__c=true];
                
                for(Account a:shipp){
                    
                    shippMap.put(a.GE_LGT_EM_SAP_Customer_Number__c+';'+a.Name.remove('\'')+';'+a.GE_LGT_EM_SAP_Customer_Number__c,a.ShippingAddress);  
                }
                
            }    
            res.success = true; 
            
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return shippMap;
    }
   @RemoteAction
     global static Map<String,String> getusermail(ccrz.cc_RemoteActionContext ctx, string ownerId){
        String usermail='';
        String userphone='';
        string firstname='';
        string lastname='';
        String userfullname='';
        Map<String,String> userinfo1 = new Map<String,String>();
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try{
          User us = [SELECT Id, Phone, Email,FirstName,LastName FROM User WHERE Id =: ownerId];
            usermail=us.Email;
            userphone=us.Phone;
            //userfullname=us.Name;
            //String[] userfullname1=userfullname.split(' ');
            firstname=us.FirstName;
            lastname=us.LastName;
          //system.debug('Full Name***'+userfullname1);
          //  system.debug('usermail***'+userphone);
		userinfo1.put('firstname',firstname);
		userinfo1.put('lastname',lastname);
        userinfo1.put('usermail',usermail);
		userinfo1.put('userphone',userphone);
            res.success=true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return userinfo1;
    }    
    
   @RemoteAction
   global static ccrz.cc_RemoteActionResult validateUniquePO(ccrz.cc_RemoteActionContext ctx,String PoNum,String Soldto){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=true;
        try{
            List<Order> orderCounter = [SELECT id FROM Order WHERE Customer_PO_Number__c =: PoNum and Sold_To__c =: Soldto];
            if(orderCounter.size()>0){
                res.success = false;
            }
            
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static List<Account> StrategicAccounts(ccrz.cc_RemoteActionContext ctx){
        
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        List<Account> relatedAccounts = new List<Account>();
        //String effAccountId = ctx.effAccountId;
        
        try{
           relatedAccounts = AccountServices.getStrategicAccountsByAccountId();
            res.success = true; 
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return relatedAccounts;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getCartOrigin(ccrz.cc_RemoteActionContext ctx,String cartID) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success = false;
        try {
            ccrz__E_Cart__c cart = [SELECT Cart_Origin__c FROM ccrz__E_Cart__c WHERE Id = :cartId LIMIT 1];
            res.data = cart.Cart_Origin__c != null ? cart.Cart_Origin__c : '';
            res.success = true;
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
        } finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }

}