/*----------------------------------------------------------------------
Name:       PriceAgreementController.cls
Purpose:    Call SAP For Price Agreement Validation, Order Simulate
------------------------------History----------------------------------
Version     Author          Date                    Detail Description
-------     -------         --------------          ------------------
1.0         Devang          02-Dec-2020           Initial Development
----------------------------------------------------------------------*/
global with sharing class PriceAgreementController {
    public static final String UOM_PC = 'PC';
    @TestVisible private static SAPGateway service = new SAPGateway();

    @TestVisible private static Account getAccount(){
        Id userId = UserInfo.getUserId();

        User u = [SELECT Id, ContactId,  Account.Id FROM User WHERE Id = : userId];

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
                WHERE Id = :u.Account.Id
        ];
        return account;
    }

    @TestVisible private static Account getAccountById(Id accountId){

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
                WHERE Id = :accountId
        ];
        return account;
    }

    @TestVisible private static Account getEffectiveAccount(String effectiveAccountId){

        Account account = [
                SELECT Id,
                        Name,
                        GE_LGT_EM_SAP_Customer_Number__c,
                        GE_LGT_EM_Sales_Org__c,
                        GE_LGT_EM_Division__c,
                        GE_LGT_EM_Distribution_Channel__c,
                        Delivering_Plant__c,
                        Account_Group__c,
                        Customer_Segmentation__c,
                        GE_LGT_Rep_Code__c
                FROM Account
                WHERE Id = :effectiveAccountId
        ];
        return account;
    }

    @RemoteAction
    global static List<Account> getAccType(ccrz.cc_RemoteActionContext ctx, String accId){
        return [SELECT Account_Group__c FROM Account WHERE Id =: accId];
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPricingUOM(ccrz.cc_RemoteActionContext ctx, String sku) {

        if(!Test.isRunningTest()) {
            ccrz.cc_CallContext.initRemoteContext(ctx);
        }
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        res.inputContext = ctx;

        System.debug('sku  =' + sku);
        try {
            Map<String, Decimal> pr = new Map<String, Decimal>();
            for (Pricing_UOM__c p : UOMServices.getUOMsForProduct(sku, null)) {
                pr.put(p.UOM__c, p.Multiplier__c);
            }
            System.debug('**response=' +  pr);
            res.data = pr;
            res.success = true;
        }
        catch(FailedCalloutException e){
            res.data = e.getMessage();
        }

        ccrz.ccLog.close(res);
        return res;
    }





    @RemoteAction
    global static ccrz.cc_RemoteActionResult getRealTimePricing(ccrz.cc_RemoteActionContext ctx, String priceAgreementItemsJSON,String agentID, String CustID, String callType, Boolean isSample) {
        List<PriceAgreementItem> priceAgreementItems = (List<PriceAgreementItem>) JSON.deserialize(priceAgreementItemsJSON, List<PriceAgreementItem>.class);
        System.debug('priceAgreementItems\n'+JSON.serializePretty(priceAgreementItems));
        String sToday = Datetime.now().format('yyyyMMdd');
        if(!Test.isRunningTest()) {
            ccrz.cc_CallContext.initRemoteContext(ctx);
        }

        system.debug('currAccountId'+ccrz.cc_CallContext.currAccountId);
        system.debug('effAccountId'+ccrz.cc_CallContext.effAccountId);
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        res.inputContext = ctx;

        //Account acc = getAccountById(ccrz.cc_CallContext.currAccountId);
        Account acc;
        if(String.isNotBlank(agentID)){
            acc = getAccountById(agentID);
        } else if(String.isNotBlank(CustID)){
            acc = getAccountById(CustID);
        } else {
            acc = getAccountById(ccrz.cc_CallContext.currAccountId);
        }
        try {
            Account effAcc;
            PriceAgreementRequest req = new PriceAgreementRequest();

            /*req.customer = acc.GE_LGT_EM_SAP_Customer_Number__c;

            if(ccrz.cc_CallContext.currAccountId != ccrz.cc_CallContext.effAccountId){
                //Get Effective Account Customer Number
                Account effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
                if (effAcc != null && String.isNotBlank(effAcc.GE_LGT_EM_SAP_Customer_Number__c)){
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    // System.debug('Customer SAP Number ' + req.customer);
                }
            }

            if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG' && String.isNotBlank(acc.GE_LGT_Rep_Code__c) ){
                req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = acc.GE_LGT_EM_SAP_Customer_Number__c;
            } else {
                req.agent = '';
                req.extAgent = '';
            }*/

            req.customer = '';
            req.agent = '';
            req.extAgent='';
            if(String.isNotBlank(agentID)){
                effAcc = getEffectiveAccount(agentID);
                if(String.isNotBlank(effAcc.Account_Group__c) && effAcc.Account_Group__c == 'ZEAG' &&
                        (effAcc.Customer_Segmentation__c=='FD' || effAcc.Customer_Segmentation__c=='Fixture')){
                    req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }
            else if(String.isNotBlank(CustID)){
                effAcc = getEffectiveAccount(CustID);
                if(effAcc.Account_Group__c == 'ZEAG' &&
                        (effAcc.Customer_Segmentation__c=='FD' || effAcc.Customer_Segmentation__c=='Fixture')) {
                    req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }


            if(String.isNotBlank(CustID)){

                effAcc = getEffectiveAccount(CustID);
                if(effAcc.Account_Group__c == 'Z001') {
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }
            req.agreement = '';
            req.callType = callType;
            req.salesOrg = acc.GE_LGT_EM_Sales_Org__c;
            req.division = acc.GE_LGT_EM_Division__c;
            req.distChannel = acc.GE_LGT_EM_Distribution_Channel__c;
            req.orderFlag = 'N';
            req.orderReason = '';
            req.orderType = '';
            req.poNumber = '';
            req.userType = '';
            req.validateFlag = '';
            /*effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
            if(effAcc.Account_Group__c == 'ZEAG'){
				req.userType = 'Agent';
			}else if(effAcc.Account_Group__c=='Z001'){
				req.userType = 'Customer';
            } else {
                req.userType = '';
            }*/

            Id userId = UserInfo.getUserId();
            User effUser=[Select id,User_Type__c from user where id=:userId];

            if(effUser!=null){
                if(effUser.User_Type__c=='Agent'){
                    req.userType = 'AGENT';
                }
                else if(effUser.User_Type__c=='Distributor'){
                    req.userType = 'CUSTOMER';
                }
                else {
                    req.userType = '';
                }

            }
            List<PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementItem>();
            Integer lineNumber = 0;
            for (PriceAgreementItem priceAgreementItem : priceAgreementItems) {
                lineNumber += 1;
                //TODO hardcoded quantity and currencyiso code
                priceAgreementItem.quantity = 1;
                priceAgreementItem.currencyISOCode = ctx.userIsoCode;
                priceAgreementItem.lineNumber = lineNumber;
                priceAgreementItem.reqDelDate = sToday;
                priceAgreementItemList.add(priceAgreementItem);
            }
            req.priceAgreementItemList = priceAgreementItemList;
            System.debug('Sample Order: '+isSample);
            System.debug('priceAgreementRequest\n'+JSON.serializePretty(req));
            PriceAgreementResponse  resp;
            if(isSample){
                resp  = new PriceagreementResponse();
                resp.agreement =  req.agreement;
				resp.agrDate =  req.agrDate;
				resp.distChannel =  req.distChannel;
				resp.division =  req.division;
				resp.orderFlag =  req.orderFlag;
				resp.orderReason =  req.orderReason;
				resp.orderType =  req.orderType;
				resp.poNumber =  req.poNumber;
				resp.salesOrg =  req.salesOrg;
				resp.customer =  req.customer;
				resp.userType =  req.userType;
				resp.errMessage = '';
				resp.poDuplicate = '';

                List<PriceAgreementController.PriceAgreementItem> priceAgreementList = new List<PriceAgreementController.PriceAgreementItem>();
                System.debug('req.priceAgreementItemList.size(): '+req.priceAgreementItemList.size());
                for (PriceAgreementItem priceAgreementItem : priceAgreementItems){

                    PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
                    
                    pai.adpPrice = 0.0;
                    pai.floorPrice = 0.0;
                    pai.requestedPrice = 0;
				    pai.bookPrice = 0.0;
                    pai.extendedPrice = 0.0;
                    
                    pai.UOM = priceAgreementItem.UOM;
                    pai.description = priceAgreementItem.description;
                    
                    pai.lineNumber = priceAgreementItem.lineNumber;
				    pai.SKU = priceAgreementItem.SKU;
				    pai.material = priceAgreementItem.material;
				    
				    pai.quantity = 1;
				    pai.globalCommission = 0;
				    pai.floorCommission = 0;
				    pai.slidingCommission = 0;
				    pai.slidingCommissionPercentage = 0;
				    pai.overageAmount = 0;
				    pai.overagePercentageAmount = 0;
				    pai.overagePercentagePerc = 0;
				    pai.zfre = priceAgreementItem.zfre;
				    
				    pai.availableQty = 0;
				    pai.leadTime = '0';
				    pai.commission = 0;
				    pai.commissionPer = priceAgreementItem.commissionPer;
				    pai.weeeLamp = '0';
				    pai.weeeLight = '0';
				    pai.weeeLampIr = '0';
				    pai.message = '';
				    pai.substitueMaterial = '';
				    pai.countryOfOrigin = '';
				    pai.substitueReason = '';
				    pai.reasonRej = '';
				    pai.reasonRejText  = '';
				    pai.agreement = priceAgreementItem.agreement;
				    pai.productHierarchy = '';
				    pai.plant = '';
				    pai.currencyISOCode = priceAgreementItem.currencyISOCode;
				    pai.roundedQty = 0;
				    pai.standardPackQty = 0;
				    pai.palletQty = 0;
				    pai.ukPalletQty = 0;
				    pai.lightTax =  priceAgreementItem.lightTax;
				    pai.priceAgreementValue = 0;
				    pai.netCredit = 0;
                    
                    priceAgreementList.add(pai);
                }
                resp.priceAgreementItemList = priceAgreementList;
            } else {
                resp = service.getRealTimePricing(req);
            }
            
            System.debug('PriceAgreementResponse\n'+JSON.serializePretty(resp));
            res.data = resp;
            res.success = true;
        }
        catch(FailedCalloutException e){
            res.data = e.getMessage();
        }

        ccrz.ccLog.close(res);
        return res;
    }

    @RemoteAction
    global static List<Account> initSearchSoldTo(ccrz.cc_RemoteActionContext ctx, String contactId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        List<Account> relatedAccounts = new List<Account>();

        try{
            relatedAccounts = AccountServices.getRelatedAccountsByContactId(contactId);
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return relatedAccounts;
    }

    public static PriceAgreementResponse validatePriceAgreement(String isoCode, String cartId){

        //String isoCode = ctx.userIsoCode;
        //String cartId = CartServices.getActiveCartId();

        String sToday = Datetime.now().format('yyyyMMdd');
        //Account acc = getAccountById(ccrz.cc_CallContext.currAccountId));
        PriceAgreementResponse resp;
        try {
            PriceAgreementRequest req = new PriceAgreementRequest();
            /*req.customer = acc.GE_LGT_EM_SAP_Customer_Number__c;

            if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG' && String.isNotBlank(acc.GE_LGT_Rep_Code__c) ){
                req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = acc.GE_LGT_EM_SAP_Customer_Number__c;
            } else {
                req.agent = '';
                req.extAgent = '';
            }*/

            ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());

            req.customer = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.soldTo = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.agreement = '';
            req.callType = 'A';
            req.salesOrg = cart.ccrz__Account__r.GE_LGT_EM_Sales_Org__c;
            req.division = cart.ccrz__Account__r.GE_LGT_EM_Division__c;
            req.distChannel = cart.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c;
            req.orderFlag = 'N';
            req.orderReason = '';
            req.orderType = 'ZOR';
            req.poNumber = '';
            //req.validateFlag = 'Y';
            //W-000356 ===Adding Agreement_Number__c in request
            //ccrz__E_Cart__c cart = [SELECT Sold_To_Account__c,Agreement_Number__c FROM ccrz__E_Cart__c WHERE Id =: cartId];
            //req.soldTo = cart.Sold_To_Account__c;
            req.agreement = cart.Agreement_Number__c;
            if(cart.ccrz__Account__r.Account_Group__c == 'ZEAG'){
                req.userType = 'Agent';
            }else if(cart.ccrz__Account__r.Account_Group__c=='Z001'){
                req.userType = 'Customer';
            } else {
                req.userType = '';
            }

            List<PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementItem>();
            integer lineNumber = 0;
            system.debug('getCartItemExtSkusByCartId');
            List<ccrz__E_CartItem__c> cartItems = CartServices.getCartItemExtSkusByCartId(cartId);
            for(ccrz__E_CartItem__c item : cartItems){
                if(item.ccrz__PricingType__c == 'attrGroup') continue;

                PriceAgreementItem pai = new PriceAgreementItem();
                lineNumber += 1;
                pai.material = '';
                if(String.isNotBlank(item.ccrz__ExtSKU__c) && item.ccrz__cartItemType__c == 'Major'){
                    pai.material = item.ccrz__ExtSKU__c;
                }
                else{
                    pai.material = item.ccrz__Product__r.ccrz__SKU__c;
                }

                //fix for attr item sku formatting
                if(item.ccrz__cartItemType__c == 'Minor'){
                    pai.material = pai.material.replace('-','');
                }

                //TODO hardcoded quantity and currencyiso code
                pai.quantity = (Integer)item.ccrz__Quantity__c;
                pai.currencyISOCode = isoCode;
                pai.lineNumber = lineNumber;
                pai.UOM = item.ccrz__UnitOfMeasure__c;
                pai.reqDelDate =  sToday;
                pai.requestedPrice = item.ccrz__Price__c;

                priceAgreementItemList.add(pai);
            }
            req.priceAgreementItemList = priceAgreementItemList;

            System.debug('**request=' +  req);

            resp = service.priceAgreementValidate(req);

            System.debug('**response=' +  resp);
        }
        catch(FailedCalloutException e){
        }
        return resp;
    }

    public static PriceAgreementResponse revisePriceAgreementValidate(String isoCode, String cartId){

        //String isoCode = ctx.userIsoCode;
        //String cartId = CartServices.getActiveCartId();

        String sToday = Datetime.now().format('yyyyMMdd');
        //Account acc = getAccountById(ccrz.cc_CallContext.currAccountId));
        PriceAgreementResponse resp;
        try {
            PriceAgreementRequest req = new PriceAgreementRequest();
            /*req.customer = acc.GE_LGT_EM_SAP_Customer_Number__c;

            if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG' && String.isNotBlank(acc.GE_LGT_Rep_Code__c) ){
                req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = acc.GE_LGT_EM_SAP_Customer_Number__c;
            } else {
                req.agent = '';
                req.extAgent = '';
            }*/

            ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());

            req.customer = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.soldTo = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;

            req.agent ='';
            req.extAgent = '';
            if(cart.ccrz__Account__r.Account_Group__c=='ZEAG' &&
                    (cart.ccrz__Account__r.Customer_Segmentation__c=='FD' || cart.ccrz__Account__r.Customer_Segmentation__c=='Fixture')){
                req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            }

            req.callType = 'A';
            req.salesOrg = cart.ccrz__Account__r.GE_LGT_EM_Sales_Org__c;
            req.division = cart.ccrz__Account__r.GE_LGT_EM_Division__c;
            req.distChannel = cart.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c;
            req.orderFlag = 'N';
            req.orderReason = '';
            req.orderType = 'ZOR';
            req.poNumber = '';
            //req.validateFlag = 'Y';

            //ccrz__E_Cart__c cart = [SELECT Sold_To_Account__c, Agreement_Number__c FROM ccrz__E_Cart__c WHERE Id =: cartId];

            //req.soldTo = cart.Sold_To_Account__c;
            req.agreement = cart.Agreement_Number__c;

            if(cart.ccrz__Account__r.Account_Group__c == 'ZEAG'){
                req.userType = 'Agent';
            }else if(cart.ccrz__Account__r.Account_Group__c=='Z001'){
                req.userType = 'Customer';
            } else {
                req.userType = '';
            }

            List<PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementItem>();
            integer lineNumber = 0;
            system.debug('getCartItemExtSkusByCartId');
            List<ccrz__E_CartItem__c> cartItems = CartServices.getCartItemExtSkusByCartId(cartId);
            for(ccrz__E_CartItem__c item : cartItems){

                if(item.ccrz__PricingType__c == 'attrGroup') continue;

                PriceAgreementItem pai = new PriceAgreementItem();
                lineNumber += 1;
                if(String.isNotBlank(item.ccrz__ExtSKU__c) && item.ccrz__cartItemType__c == 'Major'){
                    pai.material = item.ccrz__ExtSKU__c;
                }
                else{
                    pai.material = item.ccrz__Product__r.ccrz__SKU__c;
                }

                pai.agreement = cart.Agreement_Number__c;
                pai.quantity = (Integer)item.ccrz__Quantity__c;
                pai.currencyISOCode = isoCode;
                pai.lineNumber = lineNumber;
                pai.UOM = item.ccrz__UnitOfMeasure__c;
                pai.reqDelDate =  sToday;
                pai.requestedPrice = item.ccrz__Price__c;

                priceAgreementItemList.add(pai);
            }
            req.priceAgreementItemList = priceAgreementItemList;

            // System.debug('**request=' +  req);

            resp = service.revisePriceAgreementValidate(req);

            // System.debug('**response=' +  resp);
        }
        catch(FailedCalloutException e){
        }
        return resp;
    }

    public static PriceAgreementCreateResponse PriceAgreementCreateNew(ccrz__E_Order__c order, List<ccrz__E_OrderItem__c> orderItems){

        String sToday = Datetime.now().format('yyyyMMdd');
        Account acc = order.ccrz__Contact__r.Account;
        PriceAgreementCreateResponse resp;
        try {
            PriceAgreementRequest req = new PriceAgreementRequest();
            /*req.customer = acc.GE_LGT_EM_SAP_Customer_Number__c;

            if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG' && String.isNotBlank(acc.GE_LGT_Rep_Code__c) ){
                req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extRepNumber = acc.GE_LGT_EM_SAP_Customer_Number__c;
            } else {
                req.agent = '';
                req.extAgent = '';
            }*/

            //Changes by Ravi Singh for SAP call issue W-000898
            //ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
            ccrz__E_Cart__c cart =CartServices.getCartById(order.ccrz__OriginatedCart__r.Id);

            req.customer = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.soldTo = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;

            /*	req.agent ='';
                req.extAgent = '';
            //CON-173 changes by Sagar
            if(cart.ccrz__Account__r.Account_Group__c=='ZEAG' && cart.ccrz__Account__r.Customer_Segmentation__c=='FD'){
                 // if(cart.ccrz__Account__r.Account_Group__c=='ZEAG'){
                    req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extRepNumber= cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                 }*/
            req.agent = '';
            req.extAgent = '';
            req.lbrepnumber ='';
            if (cart.ccrz__Account__r.Account_Group__c == 'ZEAG'){
                if(cart.ccrz__Account__r.Customer_Segmentation__c == 'FD' || cart.ccrz__Account__r.Customer_Segmentation__c == 'Fixture') {
                    req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extRepNumber= cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                }
                else if(cart.ccrz__Account__r.Customer_Segmentation__c == 'LB' || cart.ccrz__Account__r.Customer_Segmentation__c == 'Lamp'){
                    req.lbrepnumber=cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }

            req.callType = 'A';
            req.salesOrg = cart.ccrz__Account__r.GE_LGT_EM_Sales_Org__c;
            req.division = cart.ccrz__Account__r.GE_LGT_EM_Division__c;
            req.distChannel = cart.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c;
            req.orderFlag = 'N';
            req.orderReason = '';
            req.orderType = 'ZOR';
            req.poNumber = '';
            //req.validateFlag = 'Y';
            //req.userEmail = order.ccrz__Contact__r.Email;
            req.userEmail = order.ccrz__BuyerEmail__c;
            //req.userName = order.ccrz__Contact__r.Name;
            req.userName=order.ccrz__BuyerFirstName__c+' '+order.ccrz__BuyerLastName__c;
            req.validFrom = sToday;

            if(order.Valid_To__c != null){
                Date d = order.Valid_To__c;
                Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
                String dateString = dt.format('yyyy-MM-dd');
                req.validTo = dateString;
            }
            else{
                req.validTo = sToday;
            }

            //req.soldTo = order.Sold_To_Account__c;
            req.city = order.Project_City__c;
            req.province = order.Project_State__c;
            req.state = order.Project_State__c;
            req.zipCode = order.Project_Postal_Code__c;
            req.strategicAccount = order.ccrz__OriginatedCart__r.Strategic_Account_L__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.description = order.Project_Name__c;
            //req.endUser = order.Project_Name__c;
            //req.opportunityId = order.Project_Name__c;
            //Changes by Ravi Singh as per ticket W-000898
            req.extDescription = order.Project_Name__c;


            //req.agreement = order.Agreement_Number__c;
            if(order.Order_Type__c == 'Price Agreement'){
                req.agreementType = 'ZPRJ';
            }
            else if(order.Order_Type__c == 'One Time Price Agreement'){
                req.agreementType = 'ZOTP';
            }

            /*if(cart.ccrz__Account__r.Account_Group__c == 'ZEAG'){
				req.userType = 'Agent';
			}else if(cart.ccrz__Account__r.Account_Group__c=='Z001'){
				req.userType = 'Customer';
            } else {
                req.userType = '';
            }*/

            Id userId = UserInfo.getUserId();
            User effUser=[Select id,User_Type__c from user where id=:userId];

            if(effUser!=null){
                if(effUser.User_Type__c=='Agent'){
                    req.userType = 'AGENT';
                }
                else if(effUser.User_Type__c=='Distributor'){
                    req.userType = 'CUSTOMER';
                }
                else {
                    req.userType = '';
                }

            }

            List<PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementItem>();
            integer lineNumber = 0;
            for(ccrz__E_OrderItem__c item : orderItems){
                if(item.ccrz__PricingType__c == 'attrGroup'){
                    for(ccrz__E_OrderItem__c minorItem : item.ccrz__Order_Items__r){
                        PriceAgreementItem pai = new PriceAgreementItem();
                        lineNumber += 1;
                        pai.material = minorItem.ccrz__Product__r.ccrz__SKU__c;
                        pai.SKU = minorItem.ccrz__Product__r.ccrz__SKU__c;
                        pai.description = minorItem.ccrz__Product__r.MaterialDescription__c;
                        pai.quantity = (Integer)minorItem.ccrz__Quantity__c;
                        pai.currencyISOCode = order.ccrz__CurrencyISOCode__c;
                        pai.lineNumber = lineNumber;
                        pai.UOM = minorItem.ccrz__PrimaryAttr__r.Name;
                        pai.reqDelDate =  String.valueOf(item.Requested_Delivery_Date__c);
                        pai.requestedPrice = minorItem.ccrz__Price__c;
                        pai.lineComments = item.Comments__c;
                        priceAgreementItemList.add(pai);
                    }
                    continue;
                }

                PriceAgreementItem pai = new PriceAgreementItem();
                lineNumber += 1;
                if(String.isNotBlank(item.ccrz__ExtSKU__c)){
                    pai.material = item.ccrz__ExtSKU__c;
                    pai.SKU = item.ccrz__ExtSKU__c;
                }
                else{
                    pai.material = item.ccrz__Product__r.ccrz__SKU__c;
                    pai.SKU = item.ccrz__Product__r.ccrz__SKU__c;
                }

                pai.description = item.ccrz__Product__r.MaterialDescription__c;

                if(item.ccrz__Product__r.ccrz__SKU__c == 'requestedSku'){
                    //pai.material='INVALIDCAT';
                    pai.material='';
                    pai.description=item.ccrz__ExtName__c;
                    /*if(item.ccrz__OriginalItemPrice__c!=0.01){
                        pai.material='VALIDCAT';
                    }*/
                }
                //fix for attr item sku formatting
                if(item.ccrz__OrderLineType__c == 'Minor'){
                    pai.material = pai.material.replace('-','');
                    pai.SKU = pai.SKU.replace('-','');
                }

                pai.quantity = (Integer)item.ccrz__Quantity__c;
                pai.currencyISOCode = order.ccrz__CurrencyISOCode__c;
                pai.lineNumber = lineNumber;
                pai.UOM = item.ccrz__UnitOfMeasure__c;
                pai.reqDelDate =  String.valueOf(item.Requested_Delivery_Date__c);
                pai.requestedPrice = item.ccrz__Price__c;
                pai.lineComments = item.Comments__c;

                priceAgreementItemList.add(pai);
            }
            req.priceAgreementItemList = priceAgreementItemList;
            String lotPricingComments='';
            if(order.ccrz__OriginatedCart__r.Lot_Pricing__c){
                lotPricingComments='Lot Pricing: Yes Lot Pricing Amount: $'+order.ccrz__OriginatedCart__r.Lot_Pricing_Amount__c;
            }/*else{
                lotPricingComments='Lot Pricing: No';

            }*/

            if(String.isNotBlank(order.ccrz__OriginatedCart__r.Project_Description__c) && order.ccrz__OriginatedCart__r.Project_Description__c!=null){
                if(order.ccrz__OriginatedCart__r.Lot_Pricing__c){
                    req.comments=lotPricingComments+' '+order.ccrz__OriginatedCart__r.Project_Description__c;
                }
                else{
                    req.comments=order.ccrz__OriginatedCart__r.Project_Description__c;
                }
            }


            System.debug('**request=' +  req);

            resp = service.priceAgreementCreate(req);

            System.debug('**response=' +  resp);
        }
        catch(FailedCalloutException e){
        }
        return resp;
    }

    public static PriceAgreementCreateResponse PriceAgreementRevise(ccrz__E_Order__c order, List<ccrz__E_OrderItem__c> orderItems){

        String sToday = Datetime.now().format('yyyyMMdd');
        Account acc = order.ccrz__Contact__r.Account;
        PriceAgreementCreateResponse resp;
        try {
            PriceAgreementRequest req = new PriceAgreementRequest();
            /*req.customer = acc.GE_LGT_EM_SAP_Customer_Number__c;

            if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG' && String.isNotBlank(acc.GE_LGT_Rep_Code__c) ){
                req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extRepNumber = acc.GE_LGT_EM_SAP_Customer_Number__c;
            } else {
                req.agent = '';
                req.extAgent = '';
            }*/

            //Changes by Ravi Singh for SAP call issue W-000898
            //ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
            ccrz__E_Cart__c cart =CartServices.getCartById(order.ccrz__OriginatedCart__r.Id);

            req.customer = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.soldTo = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;

            /*	req.agent ='';
                req.extAgent = '';
            //CON-173 changes by Sagar
            if(cart.ccrz__Account__r.Account_Group__c=='ZEAG' && cart.ccrz__Account__r.Customer_Segmentation__c=='FD'){
                    req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extRepNumber= cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                 }*/
            req.agent = '';
            req.extAgent = '';
            req.lbrepnumber ='';
            if (cart.ccrz__Account__r.Account_Group__c == 'ZEAG'){
                if(cart.ccrz__Account__r.Customer_Segmentation__c == 'FD' ||
                        cart.ccrz__Account__r.Customer_Segmentation__c== 'Fixture') {
                    req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extRepNumber= cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                }
                //This Revise PA change (for LB) rolled back as per Business feedback by Sagar
                //else if(cart.ccrz__Account__r.Customer_Segmentation__c == 'LB'){
                //  req.lbrepnumber=cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                //}
            }

            req.agreementAction = 'R';
            req.salesOrg = cart.ccrz__Account__r.GE_LGT_EM_Sales_Org__c;
            req.division = cart.ccrz__Account__r.GE_LGT_EM_Division__c;
            req.distChannel = cart.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c;
            req.orderFlag = 'N';
            req.orderReason = '';
            req.orderType = 'ZOR';
            req.poNumber = '';
            //req.validateFlag = 'Y';
            //req.userEmail = order.ccrz__Contact__r.Email;
            req.userEmail = order.ccrz__BuyerEmail__c;
            //req.userName = order.ccrz__Contact__r.Name;
            req.userName=order.ccrz__BuyerFirstName__c+' '+order.ccrz__BuyerLastName__c;
            req.validFrom = sToday;


            if(order.Valid_To__c != null){
                Date d = order.Valid_To__c;
                Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
                String dateString = dt.format('yyyy-MM-dd');
                req.validTo = dateString;
            }
            else{
                req.validTo = sToday;
            }


            //req.soldTo = order.Sold_To_Account__c;
            req.city = order.Project_City__c;
            req.province = order.Project_State__c;
            req.state = order.Project_State__c;
            req.zipCode = order.Project_Postal_Code__c;
            req.comments = order.ccrz__OriginatedCart__r.Project_Description__c;
            req.strategicAccount = order.ccrz__OriginatedCart__r.Strategic_Account_L__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.description = order.Project_Name__c;
            //req.endUser = order.Project_Name__c;
            //req.opportunityId = order.Project_Name__c;
            req.extDescription = order.Project_Name__c;

            req.agreement = order.Revise_Agreement_Number__c;

            /*if(cart.ccrz__Account__r.Account_Group__c == 'ZEAG'){
				req.userType = 'Agent';
			}else if(cart.ccrz__Account__r.Account_Group__c=='Z001'){
				req.userType = 'Customer';
            } else {
                req.userType = '';
            }*/

            Id userId = UserInfo.getUserId();
            User effUser=[Select id,User_Type__c from user where id=:userId];

            if(effUser!=null){
                if(effUser.User_Type__c=='Agent'){
                    req.userType = 'AGENT';
                }
                else if(effUser.User_Type__c=='Distributor'){
                    req.userType = 'CUSTOMER';
                }
                else {
                    req.userType = '';
                }

            }

            List<PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementItem>();
            integer lineNumber = 0;


            for(ccrz__E_OrderItem__c item : orderItems){
                if(item.ccrz__PricingType__c == 'attrGroup'){
                    for(ccrz__E_OrderItem__c minorItem : item.ccrz__Order_Items__r){
                        PriceAgreementItem pai = new PriceAgreementItem();
                        lineNumber += 1;
                        pai.material = minorItem.ccrz__Product__r.ccrz__SKU__c;
                        pai.SKU = minorItem.ccrz__Product__r.ccrz__SKU__c;
                        pai.description = minorItem.ccrz__Product__r.MaterialDescription__c;
                        pai.quantity = (Integer)minorItem.ccrz__Quantity__c;
                        pai.currencyISOCode = order.ccrz__CurrencyISOCode__c;
                        pai.lineNumber = lineNumber;
                        pai.UOM = minorItem.ccrz__PrimaryAttr__r.Name;
                        pai.reqDelDate =  String.valueOf(item.Requested_Delivery_Date__c);
                        pai.requestedPrice = minorItem.ccrz__Price__c;
                        pai.lineComments = item.Comments__c;

                        priceAgreementItemList.add(pai);
                    }
                    continue;
                }

                PriceAgreementItem pai = new PriceAgreementItem();
                lineNumber += 1;
                if(String.isNotBlank(item.ccrz__ExtSKU__c)){
                    pai.material = item.ccrz__ExtSKU__c;
                    pai.SKU = item.ccrz__ExtSKU__c;
                    pai.description = item.ccrz__Product__r.MaterialDescription__c;
                }
                else{
                    pai.material = item.ccrz__Product__r.ccrz__SKU__c;
                    pai.SKU = item.ccrz__Product__r.ccrz__SKU__c;
                }

                /* if(item.ccrz__Product__r.ccrz__SKU__c == 'requestedSku'){
					pai.material='INVALIDCAT';
					pai.description=item.ccrz__ExtName__c;
                    if(item.ccrz__OriginalItemPrice__c!=0.01){
                        pai.material='VALIDCAT';
                    }
                }*/
                if(item.ccrz__Product__r.ccrz__SKU__c == 'requestedSku'){
                    pai.material=item.ccrz__ExtSKU__c;
                    pai.description=item.ccrz__ExtName__c;

                }

                pai.quantity = (Integer)item.ccrz__Quantity__c;
                pai.currencyISOCode = order.ccrz__CurrencyISOCode__c;
                pai.lineNumber = lineNumber;
                pai.UOM = item.ccrz__UnitOfMeasure__c;
                pai.reqDelDate =  String.valueOf(item.Requested_Delivery_Date__c);
                pai.requestedPrice = item.ccrz__Price__c;
                pai.lineComments = item.Comments__c;
                pai.agreement = order.Agreement_Number__c;

                priceAgreementItemList.add(pai);
            }
            req.priceAgreementItemList = priceAgreementItemList;

            System.debug('**request=' +  req);

            resp = service.priceAgreementRevise(req);

            System.debug('**response=' +  resp);
        }
        catch(FailedCalloutException e){
        }
        return resp;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getRealTimePricingForInvalidCatalogNo(ccrz.cc_RemoteActionContext ctx, String catalogNo, String agentID,String CustID, String callType1) {

        String sToday = Datetime.now().format('yyyyMMdd');

        if(!Test.isRunningTest()) {
            ccrz.cc_CallContext.initRemoteContext(ctx);
        }
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        res.inputContext = ctx;

        System.debug('catalogNo =' + catalogNo);

        //Account acc = getAccountById(ccrz.cc_CallContext.currAccountId);
        Account acc;
        if(String.isNotBlank(agentID)){
            acc = getAccountById(agentID);
        } else if(String.isNotBlank(CustID)){
            acc = getAccountById(CustID);
        } else {
            acc = getAccountById(ccrz.cc_CallContext.currAccountId);
        }

        System.debug('account data = ' +  acc.GE_LGT_EM_SAP_Customer_Number__c + '|' + acc.GE_LGT_EM_Division__c + '|' +  acc.GE_LGT_EM_Distribution_Channel__c + '|' +  acc.GE_LGT_EM_Sales_Org__c + '|'  +  acc.Delivering_Plant__c);

        try {

            Account effAcc;
            //ProductList productList = (ProductList)JSON.deserialize(productsJSON, ProductList.class);

            System.debug('getRealTimePricingForInvalidCatalogNo');
            System.debug('ccrz.cc_CallContext.effAccountId =' + ccrz.cc_CallContext.effAccountId + ' **** ccrz.cc_CallContext.currAccountId =' + ccrz.cc_CallContext.currAccountId);

            PriceAgreementRequest req = new PriceAgreementRequest();
            /*req.customer = acc.GE_LGT_EM_SAP_Customer_Number__c;

            if(ccrz.cc_CallContext.currAccountId != ccrz.cc_CallContext.effAccountId){
                //Get Effective Account Customer Number
                Account effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
                if (effAcc != null && String.isNotBlank(effAcc.GE_LGT_EM_SAP_Customer_Number__c)){
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    System.debug('Customer SAP Number ' + req.customer);
                }
            }

            if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG' && String.isNotBlank(acc.GE_LGT_Rep_Code__c) ){
                req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = acc.GE_LGT_EM_SAP_Customer_Number__c;
            } else {
                req.agent = '';
                req.extAgent = '';
            }*/

            System.debug('agentID:'+agentID);
            System.debug('CustID:'+CustID);

            req.customer = '';
            req.agent = '';
            req.extAgent='';
            if(String.isNotBlank(agentID)){
                effAcc = getEffectiveAccount(agentID);
                if(String.isNotBlank(effAcc.Account_Group__c) && effAcc.Account_Group__c == 'ZEAG' &&
                        (effAcc.Customer_Segmentation__c=='FD' || effAcc.Customer_Segmentation__c=='Fixture')){
                    req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }
            else if(String.isNotBlank(CustID)){
                effAcc = getEffectiveAccount(CustID);
                if(effAcc.Account_Group__c == 'ZEAG' &&
                        (effAcc.Customer_Segmentation__c=='FD' || effAcc.Customer_Segmentation__c=='Fixture')) {
                    req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }


            if(String.isNotBlank(CustID)){

                effAcc = getEffectiveAccount(CustID);
                if(effAcc.Account_Group__c == 'Z001') {
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }


            req.agreement = '';
            req.callType = callType1;
            req.salesOrg = acc.GE_LGT_EM_Sales_Org__c;
            req.division = acc.GE_LGT_EM_Division__c;
            req.distChannel = acc.GE_LGT_EM_Distribution_Channel__c;
            req.orderFlag = 'N';
            req.orderReason = '';
            req.orderType = '';
            req.poNumber = '';
            req.userType = '';
            req.validateFlag = '';
            /*effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
            if(effAcc.Account_Group__c == 'ZEAG'){
				req.userType = 'Agent';
			}else if(effAcc.Account_Group__c=='Z001'){
				req.userType = 'Customer';
            } else {
                req.userType = '';
            }*/

            Id userId = UserInfo.getUserId();
            User effUser=[Select id,User_Type__c from user where id=:userId];

            if(effUser!=null){
                if(effUser.User_Type__c=='Agent'){
                    req.userType = 'AGENT';
                }
                else if(effUser.User_Type__c=='Distributor'){
                    req.userType = 'CUSTOMER';
                }
                else {
                    req.userType = '';
                }

            }

            // System.debug('step');
            // These changes are done by Sahil Goura for CON-201(line 942-963)
            List<GE_LGT_EM_MaterialMaster__c> prod=[select id,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_MaterialDescription__c, GE_LGT_EM_ProductHierarchy__c from GE_LGT_EM_MaterialMaster__c where GE_LGT_EM_SAP_MaterialNumber__c =:catalogNo OR GE_LGT_EM_MaterialDescription__c =:catalogNo];
            String NewProduct;
            if(prod.size() > 0){
                System.debug('prod0' + prod[0].GE_LGT_EM_ProductHierarchy__c);
                NewProduct = prod[0].GE_LGT_EM_ProductHierarchy__c.substring(0,3);
                System.debug('NewProduct' + NewProduct);
                //String str=NewProduct.substring(0,2);
                //System.debug('str' + str);
            }

            System.debug('NewProduct' + NewProduct);
            System.debug(':ccrz.cc_CallContext.effAccountId' + ccrz.cc_CallContext.effAccountId);

            List<CustomerProductFamily__c> prod2 = [select SAPCustomerNumber__c from CustomerProductFamily__c WHERE (ProductFamily1__c =:NewProduct OR ProductFamily2__c =: NewProduct OR ProductFamily3__c =: NewProduct OR ProductFamily4__c =: NewProduct OR ProductFamily5__c =: NewProduct OR ProductFamily6__c =: NewProduct OR ProductFamily7__c =: NewProduct OR ProductFamily8__c =: NewProduct OR ProductFamily9__c =: NewProduct OR ProductFamily10__c =: NewProduct OR ProductFamily11__c =: NewProduct OR ProductFamily12__c =: NewProduct OR ProductFamily13__c =: NewProduct OR ProductFamily14__c =: NewProduct OR ProductFamily15__c =: NewProduct OR ProductFamily16__c =: NewProduct OR ProductFamily17__c =: NewProduct OR ProductFamily18__c =: NewProduct OR ProductFamily19__c =: NewProduct OR ProductFamily20__c =: NewProduct) AND SAPCustomerNumber__c =:ccrz.cc_CallContext.effAccountId];
            System.debug('prod2size' + prod2.size());
            if (prod2.size() == 0 && prod.size() > 0){

                res.data = 'The selected account is not authorized to purchase this product.';
                res.success = false;

                return res;
            }

            List<PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementItem>();
            integer lineNumber = 0;

            PriceAgreementItem pai = new PriceAgreementItem();
            System.debug('catalogNo=' + catalogNo);
            lineNumber += 1;
            pai.description = catalogNo.touppercase();
            pai.material = '';
            //TODO hardcoded quantity and currencyiso code
            if(prod.size()>0){

                pai.description= prod[0].GE_LGT_EM_MaterialDescription__c;
                pai.material =prod[0].GE_LGT_EM_SAP_MaterialNumber__c;

            }
            pai.quantity = 1;
            pai.currencyISOCode = ctx.userIsoCode;
            pai.lineNumber = lineNumber;
            pai.UOM = UOM_PC;
            pai.reqDelDate =  sToday;

            priceAgreementItemList.add(pai);

            req.priceAgreementItemList = priceAgreementItemList;

            System.debug('**request=' +  req);

            PriceAgreementResponse  resp = service.getRealTimePricing(req);

            System.debug('**response=' +  resp);
            res.data = resp;
            res.success = true;
        }
        catch(FailedCalloutException e){
            res.data = e.getMessage();
        }

        ccrz.ccLog.close(res);
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getRealTimePricingForMultipleInvalidCatalogNo(ccrz.cc_RemoteActionContext ctx, List<String> catalogNoList, String agentID,String CustID, String callType1) {

        String sToday = Datetime.now().format('yyyyMMdd');
        if(!Test.isRunningTest()) {
            ccrz.cc_CallContext.initRemoteContext(ctx);
        }
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        res.inputContext = ctx;
        System.debug('catalogNo =' + catalogNoList);
        //Account acc = getAccountById(ccrz.cc_CallContext.currAccountId);
        Account acc;
        if(String.isNotBlank(agentID)){
            acc = getAccountById(agentID);
        } else if(String.isNotBlank(CustID)){
            acc = getAccountById(CustID);
        } else {
            acc = getAccountById(ccrz.cc_CallContext.currAccountId);
        }
        System.debug('account data = ' +  acc.GE_LGT_EM_SAP_Customer_Number__c + '|' + acc.GE_LGT_EM_Division__c + '|' +  acc.GE_LGT_EM_Distribution_Channel__c + '|' +  acc.GE_LGT_EM_Sales_Org__c + '|'  +  acc.Delivering_Plant__c);

        try {
            Account effAcc;
            System.debug('getRealTimePricingForInvalidCatalogNo');
            System.debug('ccrz.cc_CallContext.effAccountId =' + ccrz.cc_CallContext.effAccountId + ' **** ccrz.cc_CallContext.currAccountId =' + ccrz.cc_CallContext.currAccountId);
            PriceAgreementRequest req = new PriceAgreementRequest();
            System.debug('agentID:'+agentID);
            System.debug('CustID:'+CustID);

            req.customer = '';
            req.agent = '';
            req.extAgent='';
            if(String.isNotBlank(agentID)){
                effAcc = getEffectiveAccount(agentID);
                if(String.isNotBlank(effAcc.Account_Group__c) && effAcc.Account_Group__c == 'ZEAG' &&
                        (effAcc.Customer_Segmentation__c=='FD' || effAcc.Customer_Segmentation__c=='Fixture')){
                    req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }
            else if(String.isNotBlank(CustID)){
                effAcc = getEffectiveAccount(CustID);
                if(effAcc.Account_Group__c == 'ZEAG' &&
                        (effAcc.Customer_Segmentation__c=='FD' || effAcc.Customer_Segmentation__c=='Fixture')) {
                    req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.extAgent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }

            if(String.isNotBlank(CustID)){
                effAcc = getEffectiveAccount(CustID);
                if(effAcc.Account_Group__c == 'Z001') {
                    req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                }
            }

            req.agreement = '';
            req.callType = callType1;
            req.salesOrg = acc.GE_LGT_EM_Sales_Org__c;
            req.division = acc.GE_LGT_EM_Division__c;
            req.distChannel = acc.GE_LGT_EM_Distribution_Channel__c;
            req.orderFlag = 'N';
            req.orderReason = '';
            req.orderType = '';
            req.poNumber = '';
            req.userType = '';
            req.validateFlag = '';

            Id userId = UserInfo.getUserId();
            User effUser=[Select id,User_Type__c from user where id=:userId];

            if(effUser!=null){
                if(effUser.User_Type__c=='Agent'){
                    req.userType = 'AGENT';
                }
                else if(effUser.User_Type__c=='Distributor'){
                    req.userType = 'CUSTOMER';
                }
                else {
                    req.userType = '';
                }
            }

            List<MultCatalougeSearchResponse> multCatalougeSearchResponseList = new List<MultCatalougeSearchResponse>();

            for(String catalogNo : catalogNoList){
                MultCatalougeSearchResponse multCatalougeSearchResponse = new MultCatalougeSearchResponse();

                if(catalogNo!=''){

                    List<GE_LGT_EM_MaterialMaster__c> prod=[select id,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_MaterialDescription__c, GE_LGT_EM_ProductHierarchy__c from GE_LGT_EM_MaterialMaster__c where GE_LGT_EM_SAP_MaterialNumber__c =:catalogNo OR GE_LGT_EM_MaterialDescription__c =:catalogNo];
                    String NewProduct;
                    if(prod.size() > 0){
                        System.debug('prod0' + prod[0].GE_LGT_EM_ProductHierarchy__c);
                        NewProduct = prod[0].GE_LGT_EM_ProductHierarchy__c.substring(0,3);
                        System.debug('NewProduct' + NewProduct);
                    }

                    System.debug('NewProduct' + NewProduct);
                    System.debug(':ccrz.cc_CallContext.effAccountId' + ccrz.cc_CallContext.effAccountId);

                    List<CustomerProductFamily__c> prod2 = [select SAPCustomerNumber__c from CustomerProductFamily__c WHERE (ProductFamily1__c =:NewProduct OR ProductFamily2__c =: NewProduct OR ProductFamily3__c =: NewProduct OR ProductFamily4__c =: NewProduct OR ProductFamily5__c =: NewProduct OR ProductFamily6__c =: NewProduct OR ProductFamily7__c =: NewProduct OR ProductFamily8__c =: NewProduct OR ProductFamily9__c =: NewProduct OR ProductFamily10__c =: NewProduct OR ProductFamily11__c =: NewProduct OR ProductFamily12__c =: NewProduct OR ProductFamily13__c =: NewProduct OR ProductFamily14__c =: NewProduct OR ProductFamily15__c =: NewProduct OR ProductFamily16__c =: NewProduct OR ProductFamily17__c =: NewProduct OR ProductFamily18__c =: NewProduct OR ProductFamily19__c =: NewProduct OR ProductFamily20__c =: NewProduct) AND SAPCustomerNumber__c =:ccrz.cc_CallContext.effAccountId];
                    System.debug('prod2size' + prod2.size());
                    multCatalougeSearchResponse.objectError=false;
                    if (prod2.size() == 0 && prod.size() > 0){
                        //res.data = 'The selected account is not authorized to purchase this product.';
                        //res.success = false;
                        multCatalougeSearchResponse.objectError=true;
                        multCatalougeSearchResponse.objectErrorMessage='The selected account is not authorized to purchase this product.';
                        multCatalougeSearchResponseList.add(multCatalougeSearchResponse);
                        continue;
                    }

                    List<PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementItem>();
                    integer lineNumber = 0;

                    PriceAgreementItem pai = new PriceAgreementItem();
                    System.debug('catalogNo=' + catalogNo);
                    lineNumber += 1;
                    pai.description = catalogNo.touppercase();
                    pai.material = '';
                    //TODO hardcoded quantity and currencyiso code
                    if(prod.size()>0){
                        pai.description= prod[0].GE_LGT_EM_MaterialDescription__c;
                        pai.material =prod[0].GE_LGT_EM_SAP_MaterialNumber__c;
                    }
                    pai.quantity = 1;
                    pai.currencyISOCode = ctx.userIsoCode;
                    pai.lineNumber = lineNumber;
                    pai.UOM = UOM_PC;
                    pai.reqDelDate =  sToday;

                    priceAgreementItemList.add(pai);
                    req.priceAgreementItemList = priceAgreementItemList;

                    System.debug('**request=' +  req);
                    PriceAgreementResponse  resp = service.getRealTimePricing(req);
                    System.debug('**response=' +  resp);

                    multCatalougeSearchResponse.SKU = resp.SKU;
                    multCatalougeSearchResponse.agent = resp.agent;
                    multCatalougeSearchResponse.extAgent = resp.extAgent;
                    multCatalougeSearchResponse.agreement = resp.agreement;
                    multCatalougeSearchResponse.customer = resp.customer;
                    multCatalougeSearchResponse.agrDate = resp.agrDate;
                    multCatalougeSearchResponse.distChannel = resp.distChannel;
                    multCatalougeSearchResponse.division = resp.division;
                    multCatalougeSearchResponse.orderFlag = resp.orderFlag;
                    multCatalougeSearchResponse.orderReason = resp.orderReason;
                    multCatalougeSearchResponse.orderType = resp.orderType;
                    multCatalougeSearchResponse.poNumber = resp.poNumber;
                    multCatalougeSearchResponse.poType = resp.poType;
                    multCatalougeSearchResponse.salesOrg = resp.salesOrg;
                    multCatalougeSearchResponse.userType = resp.userType;
                    multCatalougeSearchResponse.errMessage = resp.errMessage;
                    multCatalougeSearchResponse.poDuplicate = resp.poDuplicate;
                    multCatalougeSearchResponse.priceAgreementItemList = resp.priceAgreementItemList;

                    multCatalougeSearchResponse.empty=false;
                } else {
                    multCatalougeSearchResponse.empty=true;
                }
                multCatalougeSearchResponseList.add(multCatalougeSearchResponse);
            }
            //end loop and do some logic

            res.data = multCatalougeSearchResponseList;
            res.success = true;
        }
        catch(FailedCalloutException e){
            res.data = e.getMessage();
        }
        ccrz.ccLog.close(res);
        return res;
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult getRealTimePricingForCommissionCalc(ccrz.cc_RemoteActionContext ctx, String sku, String soldTo, String requestedPrice, String currencyISOCode, String operation, String puom, String qty) {

        String sToday = Datetime.now().format('yyyyMMdd');

        if(!Test.isRunningTest()) {
            ccrz.cc_CallContext.initRemoteContext(ctx);
        }
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        res.inputContext = ctx;

        System.debug('getRealTimePricingForCommissionCalc*****' + sku);

        Account acc = getAccountById(ccrz.cc_CallContext.currAccountId);

        System.debug('account data = ' +  acc.GE_LGT_EM_SAP_Customer_Number__c + '|' + acc.GE_LGT_EM_Division__c + '|' +  acc.GE_LGT_EM_Distribution_Channel__c + '|' +  acc.GE_LGT_EM_Sales_Org__c + '|'  +  acc.Delivering_Plant__c);

        try {
            //ProductList productList = (ProductList)JSON.deserialize(productsJSON, ProductList.class);

            System.debug('getRealTimePricingForCommissionCalc');
            System.debug('ccrz.cc_CallContext.effAccountId =' + ccrz.cc_CallContext.effAccountId + ' **** ccrz.cc_CallContext.currAccountId =' + ccrz.cc_CallContext.currAccountId);

            PriceAgreementRequest req = new PriceAgreementRequest();
            req.customer = acc.GE_LGT_EM_SAP_Customer_Number__c;
            Account effAcc;

            System.debug('TEST');
//            if(String.isNotBlank(soldTo)){
//                    System.debug('getRealTimePricingForCommissionCalc soldTo' + soldTo);
//                    System.debug('getRealTimePricingForCommissionCalc effAcc' + ccrz.cc_CallContext.effAccountId);
//                    effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
//                req.soldTo =effAcc.GE_LGT_EM_SAP_Customer_Number__c;
//                    acc = getEffectiveAccount(soldTo);
//                    if (effAcc != null && String.isNotBlank(effAcc.GE_LGT_EM_SAP_Customer_Number__c)){
//                        req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
//                        System.debug('Customer SAP Number ' + req.customer);
//                    }
//            } else {
//                if(ccrz.cc_CallContext.currAccountId != ccrz.cc_CallContext.effAccountId){
            //Get Effective Account Customer Number
//                    effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
//                    acc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
//                    if (effAcc != null && String.isNotBlank(effAcc.GE_LGT_EM_SAP_Customer_Number__c)){
//                        req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
//                    }
//                }
//            }



            req.agreement = '';
            req.callType = 'W';
            req.salesOrg = acc.GE_LGT_EM_Sales_Org__c;
            req.division = acc.GE_LGT_EM_Division__c;
            req.distChannel = acc.GE_LGT_EM_Distribution_Channel__c;
            req.orderFlag = 'N';
            req.orderReason = '';
            req.orderType = '';
            req.poNumber = '';
            req.userType = '';
            req.validateFlag = '';
            acc = getAccountById(ccrz.cc_CallContext.currAccountId);
            effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
            if(String.isBlank(soldTo)){
                req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
                req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
            }
            else {
                req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.customer = acc.GE_LGT_EM_SAP_Customer_Number__c;
                req.soldTo =effAcc.GE_LGT_EM_SAP_Customer_Number__c;
            }
            if(acc.Account_Group__c == 'ZEAG'){
                req.userType = 'Agent';
            }else if(acc.Account_Group__c=='Z001'){
                req.userType = 'Customer';
            } else {
                req.userType = '';
            }
            System.debug('step');
            System.debug('Customer' + req.customer);

            List<PriceAgreementItem> priceAgreementItemList = new List<PriceAgreementItem>();
            integer lineNumber = 0;

            PriceAgreementItem pai = new PriceAgreementItem();
            System.debug('sku=' + sku);
            lineNumber += 10;
            pai.SKU = sku;
            pai.material = sku;
            pai.quantity = Integer.valueOf(qty);
            pai.currencyISOCode = currencyISOCode;
            pai.lineNumber = lineNumber;
            pai.UOM = UOM_PC;
            if(String.isNotBlank(puom)){
                pai.UOM = puom;
            }

            pai.reqDelDate =  sToday;

            if(String.isNotBlank(operation) && operation == 'calccommission'){
                req.callType = 'W';
            }

            if(String.isNotBlank(operation) && operation == 'calccommission' && (requestedPrice != null && String.isNotBlank(requestedPrice))){
                System.debug('requestedPrice=' + requestedPrice);
                pai.requestedPrice = Decimal.valueOf(requestedPrice);
            }

            if((qty != null && String.isNotBlank(qty))) {
                System.debug('qty=' + qty);
                pai.quantity = Integer.valueOf(qty);
            }

            priceAgreementItemList.add(pai);

            req.priceAgreementItemList = priceAgreementItemList;

            System.debug('**request=' +  req);

            PriceAgreementResponse  resp = service.getRealTimePricing(req);

            System.debug('**response=' +  resp);
            res.data = resp;
            res.success = true;
        }
        catch(FailedCalloutException e){
            res.data = e.getMessage();
        }

        ccrz.ccLog.close(res);
        return res;
    }


    public class ProductPA {
        public String SKU;
        public Integer quantity;
    }

    public class ProductList {
        List<ProductPA> products;
    }

    public class PriceAgreementItem{
        public String SKU {get; set;}
        public String material {get; set;}
        public String description {get; set;}
        public Integer lineNumber {get; set;}
        public Integer quantity{get; set;}
        public String UOM {get; set;}
        public Decimal requestedPrice{get; set;}
        public String currencyISOCode {get; set;}
        public String agreement {get; set;}
        public String reqDelDate {get; set;}
        public Integer roundedQty{get; set;}
        public String substitueMaterial{get; set;}
        public String substitueReason{get; set;}
        public String reasonRej{get; set;}
        public String reasonRejText{get; set;}
        public String weeeLamp{get; set;}
        public String weeeLight{get; set;}
        public String weeeLampIr{get; set;}
        public Decimal adpPrice{get; set;}
        public Decimal floorPrice{get; set;}
        public Decimal globalCommission{get; set;}
        public Decimal floorCommission{get; set;}
        public Decimal slidingCommission{get; set;}
        public Decimal slidingCommissionPercentage{get; set;}
        public Decimal overageAmount{get; set;}
        public Decimal overagePercentageAmount{get; set;}
        public Decimal overagePercentagePerc{get; set;}
        public String leadTime {get; set;}
        public Decimal bookPrice{get; set;}
        public Decimal extendedPrice{get; set;}
        public Integer availableQty{get; set;}
        public Integer quantityOnHand{get; set;}
        public Decimal commission{get; set;}
        public Decimal commissionPer{get; set;}
        public Integer standardPackQty{get; set;}
        public Integer warehouseAvailability{get; set;}
        public String message {get; set;}
        public String lightTax{get; set;}
        public String countryOfOrigin {get; set;}
        public Integer palletQty {get; set;}
        public Integer ukPalletQty {get; set;}
        public String plant {get; set;}
        public String productHierarchy {get; set;}
        public Decimal priceAgreementValue{get; set;}
        public Decimal netCredit{get; set;}
        public String lineComments {get; set;}
        public Decimal zfre {get;set;}
    }

    public class PriceAgreementRequest{
        public String agent {get; set;}
        public String extAgent {get; set;}
        public String agreement {get; set;}
        public String agreementType {get; set;}
        public String customer {get; set;}
        public String agrDate {get; set;}
        public String distChannel {get; set;}
        public String division {get; set;}
        public String orderFlag {get; set;}
        public String orderReason {get; set;}
        public String orderType {get; set;}
        public String poNumber {get; set;}
        public String poType {get; set;}
        public String salesOrg {get; set;}
        public String userType {get; set;}
        public String validateFlag {get; set;}
        public String city {get; set;}
        public String comments {get; set;}
        public String description {get; set;}
        public String endUser {get; set;}
        public String extDescription {get; set;}
        public String extRepNumber {get; set;}
        public String intRepNumber {get; set;}
        public String lbrepnumber { get; set; }
        public String opportunityId {get; set;}
        public String province {get; set;}
        public String state {get; set;}
        public String strategicAccount {get; set;}
        public String userEmail {get; set;}
        public String userName {get; set;}
        public String validFrom {get; set;}
        public String validTo {get; set;}
        public String zipCode {get; set;}
        public String callType {get; set;}
        public String soldTo {get; set;}
        public String agreementAction {get; set;}
        public List<PriceAgreementItem> priceAgreementItemList {get; set;}
    }

    public class PriceAgreementResponse{
        public String SKU {get; set;}
        public String agent {get; set;}
        public String extAgent {get; set;}
        public String agreement {get; set;}
        public String customer {get; set;}
        public String agrDate {get; set;}
        public String distChannel {get; set;}
        public String division {get; set;}
        public String orderFlag {get; set;}
        public String orderReason {get; set;}
        public String orderType {get; set;}
        public String poNumber {get; set;}
        public String poType {get; set;}
        public String salesOrg {get; set;}
        public String userType {get; set;}
        public String errMessage {get; set;}
        public String poDuplicate {get; set;}
        public List<PriceAgreementItem> priceAgreementItemList {get; set;}
    }

    public class MultCatalougeSearchResponse{
        public String SKU {get; set;}
        public String agent {get; set;}
        public String extAgent {get; set;}
        public String agreement {get; set;}
        public String customer {get; set;}
        public String agrDate {get; set;}
        public String distChannel {get; set;}
        public String division {get; set;}
        public String orderFlag {get; set;}
        public String orderReason {get; set;}
        public String orderType {get; set;}
        public String poNumber {get; set;}
        public String poType {get; set;}
        public String salesOrg {get; set;}
        public String userType {get; set;}
        public String errMessage {get; set;}
        public String poDuplicate {get; set;}
        public List<PriceAgreementItem> priceAgreementItemList {get; set;}
        public Boolean empty {get; set;}
        public Boolean objectError {get; set;}
        public String objectErrorMessage {get; set;}
    }

    public class PriceAgreementCreateResponse{
        public String agreement {get; set;}
        public String approved {get; set;}
        public String message {get; set;}
        public List<IpCraspCompFields> additional {get; set;}
        public List<AgrLineComments> headComments {get; set;}
        public List<AgrPriceMaterials> materials {get; set;}
        public List<ExtAgents> soldTo {get; set;}
        public List<AgrLineComments> text {get; set;}
    }

    public class IpCraspCompFields{
        public String manufacturer {get; set;}
        public String distributor {get; set;}
        public String datab {get; set;}
        public String datbi {get; set;}
        public String mthdObtd {get; set;}
        public String name {get; set;}
        public String title {get; set;}
        public String company {get; set;}
        public String comment {get; set;}
    }

    public class AgrLineComments{
        public String lineNumber {get; set;}
        public String partNumber {get; set;}
        public String lineComments {get; set;}
    }

    public class AgrPriceMaterials{
        public String lineNumber {get; set;}
        public String partNumber {get; set;}
        public String partDescription {get; set;}
        public String quantity {get; set;}
        public String salesUnit {get; set;}
        public String requestedPrice {get; set;}
        public String currencyType {get; set;}
        public String agreement {get; set;}
        public String reqDelDate {get; set;}
    }

    public class ExtAgents{
        public String kunnr {get; set;}
    }

    public class FailedCalloutException extends Exception {}
}