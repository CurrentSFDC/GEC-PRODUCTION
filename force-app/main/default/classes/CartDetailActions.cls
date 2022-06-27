global with sharing class CartDetailActions {

    @RemoteAction
    global static List<ccrz__E_Attribute__c> getAttributeMapForUnitOfMeasures(ccrz.cc_RemoteActionContext ctx) {

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        List<ccrz__E_Attribute__c> measureList = new List<ccrz__E_Attribute__c>();

        try{
            measureList = [SELECT Id, Name FROM ccrz__E_Attribute__c WHERE ccrz__ParentAttribute__r.Name = 'Unit of Measure'];
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return measureList;
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateItemQty(ccrz.cc_RemoteActionContext ctx, String sfidToQtyJson){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);

        try{
            Map<String, Object> sfidToQty = (Map<String, Object>) JSON.deserializeUntyped(sfidToQtyJson);
            List<ccrz__E_CartItem__c> items = [SELECT Id, ccrz__PricingType__c, ccrz__Quantity__c, ccrz__SubAmount__c, ccrz__Price__c FROM ccrz__E_CartItem__c WHERE Id IN :sfidToQty.keySet()];
            for(ccrz__E_CartItem__c item : items){
                if(item.ccrz__PricingType__c == 'attrGroup') continue;
                item.ccrz__Quantity__c = Integer.valueOf((String)sfidToQty.get(item.Id));
                item.ccrz__SubAmount__c = item.ccrz__Price__c * item.ccrz__Quantity__c;
            }
            update items;
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult changeOrderType(ccrz.cc_RemoteActionContext ctx, String orderType){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        String cartId =Id.valueOf(CartServices.getActiveCartId());

        try{
            CartServices.changeOrderType(cartId, orderType);
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult changeOrderTypeNew(ccrz.cc_RemoteActionContext ctx, String orderType, String cartId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try{
            CartServices.changeOrderType(cartId, orderType);
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult deleteRevisePrice(ccrz.cc_RemoteActionContext ctx,String cartId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        try{
            CartServices.deleteRPA(cartId);
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }


    // @RemoteAction
    // global static ccrz.cc_RemoteActionResult changeSoldTo(ccrz.cc_RemoteActionContext ctx, String soldToName,){

    //     ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);

    //     try{
    //         String cartId =Id.valueOf(CartServices.getActiveCartId());
    //         if(String.isNotBlank(soldToName)){
    //             List<Account> soldToAcct = [SELECT Id FROM Account WHERE Name =: soldToName];
    //             String soldToId = soldToAcct[0].Id;
    //             CartServices.changeSoldTo(cartId, soldToId);
    //         }
    //         else{
    //             CartServices.changeSoldTo(cartId, null);
    //         }
    //         res.success = true; 
    //     }catch(Exception e){
    //         ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
    //     }finally{
    //         ccrz.ccLog.close(res);
    //     }
    //     return res;
    // }



    @RemoteAction
    global static ccrz.cc_RemoteActionResult changeSoldTo(ccrz.cc_RemoteActionContext ctx, String soldToId, String cartId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);

        try{
            res.data=soldToId;
            CartServices.changeSoldTo(cartId, soldToId);
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }
    @RemoteAction
    global static ccrz.cc_RemoteActionResult StrategicAccount(ccrz.cc_RemoteActionContext ctx, String soldToId, String cartId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);

        try{
            res.data=soldToId;
            CartServices.StrategicAccount(cartId, soldToId);
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static List<Account> initSearchSoldTo(ccrz.cc_RemoteActionContext ctx, String contactId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        List<Account> relatedAccounts = new List<Account>();
        String effAccountId = ctx.effAccountId;

        try{
            //relatedAccounts = AccountServices.getRelatedAccountsByContactId(contactId);
            relatedAccounts = AccountServices.getRelatedAccountsByAccountId(effAccountId);
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return relatedAccounts;
    }


    @RemoteAction
    global static Account initSoldToByEffID(ccrz.cc_RemoteActionContext ctx){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        Account soldtoAccounteff = new Account();

        String effAccountId = ctx.effAccountId;

        Account resu;

        try{
            soldtoAccounteff = [Select id,Name, GE_LGT_EM_SAP_Customer_Number__c,Account_Group__c,GE_LGT_EM_Order_Block__c,Customer_Segmentation__c from Account where id =:effAccountId];
            if(soldtoAccounteff.Account_Group__c !='ZEAG'){
                resu=soldtoAccounteff;
                //resu=soldtoAccounteff.Name + ' - ' + soldtoAccounteff.GE_LGT_EM_SAP_Customer_Number__c;

                //Changes by Ravi Singh to optimize performance of this method - Dec 21

                //ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
                String cartId = ctx.currentCartId;
                ccrz__E_Cart__c cart = [SELECT Id,Sold_To_Account__c FROM ccrz__E_Cart__c WHERE id =: cartId OR ccrz__EncryptedId__c=: cartId];
                cart.Sold_To_Account__c=soldtoAccounteff.id;
                update cart;


            }
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return resu;
    }

    @RemoteAction
    global static List<SAP_Price_Agreement__c> initSearchPriceAgreement(ccrz.cc_RemoteActionContext ctx, Boolean isAgent, String accountId){
        //Changes by Ravi Singh on 2021/04/16 for price agreement suggestions
        system.debug('initSearchPriceAgreement() START');
        system.debug('isAgent: '+ isAgent);
        system.debug('accountId: '+ accountId);
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        List<SAP_Price_Agreement__c> agreementList = new List<SAP_Price_Agreement__c>();
        List<SAP_Price_Agreement__c> agreementListAll = new List<SAP_Price_Agreement__c>();

        //String effAccountId = ctx.effAccountId;
        //ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
        try{
            if(isAgent){
                LIST<String> tempAdd = new LIST<String>();
                String soldToSAPCust;
                tempAdd=accountId.split('\\-');
                soldToSAPCust= tempAdd[tempAdd.size()-1].trim();

                // Account soldToid=[Select id,GE_LGT_EM_SAP_Customer_Number__c from Account where GE_LGT_EM_SAP_Customer_Number__c =:soldToSAPCust];
               // Account effRepCode=[Select GE_LGT_Rep_Code__c from Account where id =:cart.ccrz__Account__c];

                Date today = Date.today();

                List<String> customerNos = new List<String>();
                /*   agreementListAll=[SELECT Id,
                   Agreement_No__c,
                   Agent_Number__c,
                   Customer_List__c
                   FROM SAP_Price_Agreement__c WHERE Agent_Number__c=: effRepCode.GE_LGT_Rep_Code__c AND Expiration_Date__c >=: today];
                */
                agreementListAll=[SELECT Id,
                        Agreement_No__c,
                        Agent_Number__c,
                        Customer_List__c
                FROM SAP_Price_Agreement__c WHERE (Agreement_Type__c='ZPRJ' OR Agreement_Type__c='ZOTP') AND Release_Status__c!='Blocked' AND Expiration_Date__c >=: today];


                For(SAP_Price_Agreement__c priceagre :agreementListAll){
                    if(priceagre.Customer_List__c != null){

                        customerNos = priceagre.Customer_List__c.split(',');
                        system.debug('customerNos'+customerNos);
                        system.debug('priceagre'+priceagre);


                        system.debug('soldToSAPCust---'+soldToSAPCust);
                        system.debug('accountId---'+accountId);
                        system.debug('tempAdd---'+tempAdd);

                        //  if(customerNos.contains(priceagre.Customer_List__c)) {
                        if(customerNos.contains(soldToSAPCust)) {
                            system.debug('agreementList'+agreementList);

                            agreementList.add(priceagre);
                        }
                    }
                }

                /*return [SELECT Id, Fixture_Agent__c,
                        Agent_Name__c,
                        Name,
                        Agreement_No__c,
                        Agreement_Type__c,
                        Created_Date_Time__c,
                        CurrencyIsoCode,
                        Customer_Name__c,
                        Description__c,
                        End_User_Customer_No__c,
                        Expiration_Date__c,
                        Extended_Description__c,
                        Grand_Total__c,
                        Last_Modified_DateTime__c,
                        Opportunity_Name__c,
                        Agent_Number__c,
                        Strategic_Account__c,
                        Strategic_Partner_Name__c,
                        Valid_From__c,
                        Fixture_Agent_Integration_Key__c,
                        Agreement_Subtotal__c,
                        Bill_To_Customer_No__c,
                        CreatedById,
                        Currency_ISO__c,
                        Customer_List__c,
                        (SELECT Material_No__c, Agreement_No__c, Expiration_Date__c,
                        Price_Per_BX__c, Price_Per_CV__c, Price_Per_EA__c,
                        Price_Per_ICV__c, Price_Per_PC__c, Sales_Price__c FROM SAP_Price_Agreement_Items__r WHERE ValidTo__c >= TODAY AND DeletionFlag__c !='X')
                        FROM SAP_Price_Agreement__c WHERE Bill_To_Customer_No__c =: soldToSAPCust AND Agent_Number__c=: effRepCode.GE_LGT_Rep_Code__c AND Expiration_Date__c >=: today];
                        //agreementList = PriceAgreementServices.searchPriceAgreementAgent(soldToid.id); */


                /*   List<String> customerNos = new List<String>();
                   for(SAP_Price_Agreement__c priceagre : [SELECT Id, Fixture_Agent__c,
                   Agent_Name__c,
                   Name,
                   Agreement_No__c,
                   Agreement_Type__c,
                   Created_Date_Time__c,
                   CurrencyIsoCode,
                   Customer_Name__c,
                   Description__c,
                   End_User_Customer_No__c,
                   Expiration_Date__c,
                   Extended_Description__c,
                   Grand_Total__c,
                   Last_Modified_DateTime__c,
                   Opportunity_Name__c,
                   Agent_Number__c,
                   Strategic_Account__c,
                   Strategic_Partner_Name__c,
                   Valid_From__c,
                   Fixture_Agent_Integration_Key__c,
                   Agreement_Subtotal__c,
                   Bill_To_Customer_No__c,
                   CreatedById,
                   Currency_ISO__c,
                   Customer_List__c,
                   (SELECT Material_No__c, Agreement_No__c, Expiration_Date__c,
                   Price_Per_BX__c, Price_Per_CV__c, Price_Per_EA__c,
                   Price_Per_ICV__c, Price_Per_PC__c, Sales_Price__c FROM SAP_Price_Agreement_Items__r WHERE ValidTo__c >= TODAY AND DeletionFlag__c !='X')
                   FROM SAP_Price_Agreement__c WHERE Agent_Number__c=: effRepCode.GE_LGT_Rep_Code__c AND Expiration_Date__c >=: today] ){
                       customerNos = priceagre.Customer_List__c.split(',');
                       system.debug('customerNos'+customerNos);
                       system.debug('priceagre'+priceagre);
                    if(customerNos.contains(soldToSAPCust)) {
                           agreementList.add(priceagre);
                       }
                    }
                  // return agreementList;*/

            }
            else{
                agreementList = PriceAgreementServices.searchPriceAgreementCustomer(accountId);
            }
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        system.debug('agreementList: '+ agreementList);
        system.debug('initSearchPriceAgreement() END: ');
        return agreementList;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyPriceAgreement(ccrz.cc_RemoteActionContext ctx, String priceAgreementNo, String cartItemId, String description){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);

        try{
            priceAgreementNo = ('0000000000' + priceAgreementNo).right(10);
            //CON-246 changes by Ravi Singh for material desc
            System.debug('Inside applyPriceAgreement, before calling getValidPriceAgreementItems: '+System.now().format('yyyy-dd-mm HH:mm:ss'));
            List<SAP_Price_Agreement_Item__c> validPAItems = PriceAgreementServices.getValidPriceAgreementItems(priceAgreementNo, description);
            System.debug('Inside applyPriceAgreement, after calling getValidPriceAgreementItems: '+System.now().format('yyyy-dd-mm HH:mm:ss'));
            if(validPAItems.size() == 0){
                res.success = false;
                return res;
            }
            SAP_Price_Agreement_Item__c paItem = validPAItems[0];
            String cartId;
            if(Test.isRunningTest()){
                ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
                cartId = cart.Id;
            }
            else{
                cartId = Id.valueOf(CartServices.getActiveCartId());
            }
            System.debug('Inside applyPriceAgreement, After test if-else: '+System.now().format('yyyy-dd-mm HH:mm:ss'));
            // Decimal price = paItem.Sales_Price__c;
            // code for getting exact UOM price-- Sagar's Change
            Decimal price;
            ccrz__E_CartItem__c cartItem1 = CartServices.getCartItemById(cartItemId);

            String uom = cartItem1.ccrz__UnitOfMeasure__c;
            switch on uom {
                when 'BX' {
                    price = paItem.Price_Per_BX__c;
                }
                when 'CV' {
                    price = paItem.Price_Per_CV__c;
                }
                when 'EA' {
                    price = paItem.Price_Per_EA__c;
                }
                when 'ICV' {
                    price = paItem.Price_Per_ICV__c;
                }
                when 'PC' {
                    price = paItem.Price_Per_PC__c;
                }
                when 'NL' {
                    price = paItem.Price_Per_NL__c;
                }
                when 'NP' {
                    price = paItem.Price_Per_NP__c;
                }
                when else {
                    price = paItem.Sales_Price__c;
                }
            }
                 System.debug('Inside applyPriceAgreement, after switch-case: '+System.now().format('yyyy-dd-mm HH:mm:ss'));
            // ccrz__E_CartItem__c cartItem = CartServices.getCartItemById(cartItemId);
            //system.debug(system.now());
            cartItem1.ccrz__Price__c = price;
            //cartItem1.ccrz__ExtSKU__c = cartItem1.ccrz__Product__r.ccrz__SKU__c;
            cartItem1.ccrz__SubAmount__c = price*cartItem1.ccrz__Quantity__c;
            cartItem1.ccrz__PricingType__c = 'external';
            //system.debug(system.now());
            update cartItem1;
            // CartServices.convertItemToExtPricing(cartItemId, cartId, price);
           System.debug('Inside applyPriceAgreement, before calling changeCartItemAgreementNo: '+System.now().format('yyyy-dd-mm HH:mm:ss'));
            CartServices.changeCartItemAgreementNo(cartItemId, priceAgreementNo);
            System.debug('Inside applyPriceAgreement, after calling changeCartItemAgreementNo: '+System.now().format('yyyy-dd-mm HH:mm:ss'));
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyPriceAgreementAttr(ccrz.cc_RemoteActionContext ctx, String priceAgreementNo, String cartItemId, String sku){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);


        try{
            List<SAP_Price_Agreement_Item__c> validPAItems = PriceAgreementServices.getValidPriceAgreementItems(priceAgreementNo, sku);
            if(validPAItems.size() == 0){
                res.success = false;
                res.data = 'no valid agreements';
                return res;
            }
            SAP_Price_Agreement_Item__c paItem = validPAItems[0];
            String cartId;
            if(Test.isRunningTest()){
                ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
                cartId = cart.Id;
            }
            else{
                cartId = Id.valueOf(CartServices.getActiveCartId());
            }

            CartServices.convertItemToExtPricingAttr(cartItemId, cartId, paItem);
            ccrz__E_CartItem__c parentItem = [SELECT Agreement_Number__c FROM ccrz__E_CartItem__c WHERE Id =: cartItemId];
            parentItem.Agreement_Number__c = priceAgreementNo;
            update parentItem;
            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
            res.data = e.getMessage();
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyCustomPrice(ccrz.cc_RemoteActionContext ctx, String cartItemId, Decimal price){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        system.debug('res**********'+res);

        try{

            String cartId;
            /*if(Test.isRunningTest()){
                ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
                system.debug('cart******************'+cart);
                cartId = cart.Id;
                system.debug('cartId************'+cartId);
            }
            else{*/
            //system.debug(system.now());
            ccrz__E_CartItem__c cartItem = CartServices.getCartItemById(cartItemId);
            //system.debug(system.now());
            cartItem.ccrz__Price__c = price;
            //cartItem.ccrz__ExtSKU__c = cartItem.ccrz__Product__r.ccrz__SKU__c;
            cartItem.ccrz__SubAmount__c = price*cartItem.ccrz__Quantity__c;
            cartItem.ccrz__PricingType__c = 'external';
            //system.debug(system.now());
            update cartItem;
            //system.debug(system.now());
            res.success = true;
            //}

            //CartServices.convertItemToExtPricing(cartItemId, cartId, price);

            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyQuantIncr(ccrz.cc_RemoteActionContext ctx, String cartItemId, Decimal price){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        system.debug('res**********'+res);

        try{

            String cartId;
            /*if(Test.isRunningTest()){
                ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
                system.debug('cart******************'+cart);
                cartId = cart.Id;
                system.debug('cartId************'+cartId);
            }
            else{*/
            //system.debug(system.now());
            ccrz__E_CartItem__c cartItem = CartServices.getCartItemById(cartItemId);
            //system.debug(system.now());
            cartItem.ccrz__Price__c = price;
            //cartItem.ccrz__ExtSKU__c = cartItem.ccrz__Product__r.ccrz__SKU__c;
            cartItem.ccrz__SubAmount__c = price*(cartItem.ccrz__Quantity__c+1);
            cartItem.ccrz__Quantity__c=cartItem.ccrz__Quantity__c+1;
            cartItem.ccrz__PricingType__c = 'external';
            //system.debug(system.now());
            update cartItem;
            //system.debug(system.now());
            res.success = true;
            //}

            //CartServices.convertItemToExtPricing(cartItemId, cartId, price);

            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyQuantDecr(ccrz.cc_RemoteActionContext ctx, String cartItemId, Decimal price){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        system.debug('res**********'+res);

        try{

            String cartId;
            /*if(Test.isRunningTest()){
                ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
                system.debug('cart******************'+cart);
                cartId = cart.Id;
                system.debug('cartId************'+cartId);
            }
            else{*/
            //system.debug(system.now());
            ccrz__E_CartItem__c cartItem = CartServices.getCartItemById(cartItemId);
            //system.debug(system.now());
            cartItem.ccrz__Price__c = price;
            //cartItem.ccrz__ExtSKU__c = cartItem.ccrz__Product__r.ccrz__SKU__c;
            cartItem.ccrz__SubAmount__c = price*(cartItem.ccrz__Quantity__c-1);
            cartItem.ccrz__Quantity__c=cartItem.ccrz__Quantity__c-1;
            cartItem.ccrz__PricingType__c = 'external';
            //system.debug(system.now());
            update cartItem;
            //system.debug(system.now());
            res.success = true;
            //}

            //CartServices.convertItemToExtPricing(cartItemId, cartId, price);

            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyCustomQuant(ccrz.cc_RemoteActionContext ctx, String cartItemId, Decimal quant){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        system.debug('res**********'+res);

        try{

            String cartId;
            /*if(Test.isRunningTest()){
                ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
                system.debug('cart******************'+cart);
                cartId = cart.Id;
                system.debug('cartId************'+cartId);
            }
            else{*/
            //system.debug(system.now());
            ccrz__E_CartItem__c cartItem = CartServices.getCartItemById(cartItemId);
            //system.debug(system.now());
            //cartItem.ccrz__Price__c = price;
            //cartItem.ccrz__ExtSKU__c = cartItem.ccrz__Product__r.ccrz__SKU__c;
            cartItem.ccrz__SubAmount__c = cartItem.ccrz__Price__c*quant;
            cartItem.ccrz__Quantity__c=quant;
            cartItem.ccrz__PricingType__c = 'external';
            //system.debug(system.now());
            update cartItem;
            //system.debug(system.now());
            //res.success = true;
            //}

            //CartServices.convertItemToExtPricing(cartItemId, cartId, price);

            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyCustomPriceAttr(ccrz.cc_RemoteActionContext ctx, String cartItemId, Decimal price, Integer qty){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);

        try{

            ccrz__E_CartItem__c cartItem = CartServices.getCartItemById(cartItemId);
            cartItem.ccrz__Price__c = price;
            //cartItem.ccrz__ExtSKU__c = cartItem.ccrz__Product__r.ccrz__SKU__c;
            cartItem.ccrz__Quantity__c = qty;
            cartItem.ccrz__SubAmount__c = price*qty;
            cartItem.ccrz__PricingType__c = 'external';

            update cartItem;

            res.success = true;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateRequestedDeliveryDate(ccrz.cc_RemoteActionContext ctx, String cartItemId, String requestedDeliveryDate, Boolean sampleOrder){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        ccrz__E_CartItem__c ciUpdate=CartServices.getCartItemById(cartItemId);
        try {
            ciUpdate.Requested_Delivery_Date__c = Date.valueOf(requestedDeliveryDate);
        } catch (Exception e) {
            ciUpdate.Requested_Delivery_Date__c = null;
        }
        update ciUpdate;
        ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
        cart.Sample_Order__c=sampleOrder;
        update cart;
        res.success=true;
        res.data='';
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateTypeMarks(ccrz.cc_RemoteActionContext ctx, String cartItemId, String typeMarks, Boolean sampleOrder){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        ccrz__E_CartItem__c ciUpdate=CartServices.getCartItemById(cartItemId);
        ciUpdate.Type_Marks__c=typeMarks;
        update ciUpdate;
        ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
        cart.Sample_Order__c=sampleOrder;
        update cart;
        res.success=true;
        res.data='';
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateCartItems(ccrz.cc_RemoteActionContext ctx, String items){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        ccrz.ccLog.log(LoggingLevel.Debug,'items',items);
        system.debug(items);
        String itemsNoComma=items.removeEnd(',');
        system.debug(itemsNoComma);
        List<ccrz__E_CartItem__c> updateCIQty= new List<ccrz__E_CartItem__c>();
        for(String item:itemsNoComma.split(',')){
            ccrz__E_CartItem__c ci = new ccrz__E_CartItem__c(Id=item.split(':')[0],ccrz__Quantity__c=Integer.valueOf(item.split(':')[1]));
            updateCIQty.add(ci);
        }
        system.debug(updateCIQty);
        if(!updateCIQty.isEmpty()){
            update updateCIQty;
        }
        res.success=true;
        res.data='';
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateSampleOrder(ccrz.cc_RemoteActionContext ctx, Boolean sampleOrder){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=true;
        res.data='';
        ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
        cart.Sample_Order__c=sampleOrder;
        update cart;

        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateCartAccount(ccrz.cc_RemoteActionContext ctx, String accID){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=true;
        res.data='';
        ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
        cart.ccrz__Account__c=accID;
        update cart;
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyHeaderPriceAgreement(ccrz.cc_RemoteActionContext ctx, Boolean sampleOrder,String priceAgreementNo){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=true;
        res.data='';
        ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());
        System.debug(priceAgreementNo);
        System.debug(cart.Id);
        System.debug(cart.Sold_To_Account__c);

        system.debug('***getCpuTime()***'+Limits.getCpuTime());
        PriceAgreementController.PriceAgreementRequest req = new PriceAgreementController.PriceAgreementRequest();
        //req.customer = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
        /*Account soldToid=[Select GE_LGT_EM_SAP_Customer_Number__c from Account where ID =:cart.Sold_To_Account__c];
         req.customer = soldToid.GE_LGT_EM_SAP_Customer_Number__c;
        if(String.isNotBlank(cart.ccrz__Account__r.Account_Group__c) && cart.ccrz__Account__r.Account_Group__c == 'ZEAG' && String.isNotBlank(cart.ccrz__Account__r.GE_LGT_Rep_Code__c) ){
            req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
        } else {
            req.agent = '';
            req.extAgent = '';
        }*/

        req.agent ='';
        req.extAgent = '';
           	   	if(cart.ccrz__Account__r.Account_Group__c=='ZEAG' &&
                        (cart.ccrz__Account__r.Customer_Segmentation__c=='FD' || cart.ccrz__Account__r.Customer_Segmentation__c=='Fixture')){
            req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
        }
        req.customer = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;
        req.agreement = priceAgreementNo;
        req.salesOrg = cart.ccrz__Account__r.GE_LGT_EM_Sales_Org__c;
        req.division = cart.ccrz__Account__r.GE_LGT_EM_Division__c;
        if(cart.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c!=null){
            req.distChannel = cart.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c;
        }else{
            req.distChannel ='';
        }
        req.orderFlag = 'N';
        if(sampleOrder){
            //req.orderReason = 'Sample Order';
            req.orderType = 'ZSAM';
            req.orderFlag = 'Y';
        }else{
            req.orderType = 'ZOR';
        }
        req.poNumber = '';
        /*if(cart.ccrz__Account__r.Account_Group__c == 'ZEAG'){
            req.userType = 'Agent';
        }else if(cart.ccrz__Account__r.Account_Group__c=='Z001'){
            req.userType = 'Customer';
        } else {
            req.userType = '';
        }*/
        //req.validateFlag = 'Y';
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


        req.agrDate='';
        req.callType='O';


        integer lineNumber = 10;
        Map<Integer,Id> lineNumberToCartItemIdMap = new Map<Integer,Id>();
        req.priceAgreementItemList = new List<PriceAgreementController.PriceAgreementItem>();
        for(ccrz__E_CartItem__c ci: cart.ccrz__E_CartItems__r){
            system.debug(ci.ccrz__Product__r.ccrz__SKU__c);
            system.debug(ci.ccrz__UnitOfMeasure__c);

            PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
            if(ci.ccrz__Product__r.ccrz__SKU__c!=null){

                if(ci.ccrz__Product__r.ccrz__SKU__c=='requestedSku'){
                    pai.description = ci.ccrz__ExtName__c;
                    if(null != ci.ccrz__ExtSKU__c && ci.ccrz__ExtSKU__c != 'INVALIDCAT' && ci.ccrz__ExtSKU__c != 'VALIDCAT' && ci.ccrz__ExtSKU__c != ''){
                        pai.material = ci.ccrz__ExtSKU__c;
                    }
                }
                else{
                    pai.material = ci.ccrz__Product__r.ccrz__SKU__c;
                }
            }
            //TODO hardcoded quantity and currencyiso code
            pai.quantity = Integer.valueOf(ci.ccrz__Quantity__c);
            pai.currencyISOCode = 'USD';
            pai.lineNumber = lineNumber;
            pai.agreement=ci.Agreement_Number__c;
            pai.UOM = UtilityClass.convertUomLabelToUomCode(ci.ccrz__UnitOfMeasure__c);
            if(ci.Requested_Delivery_Date__c!=null){
                Datetime dt = Datetime.newInstance(ci.Requested_Delivery_Date__c.year(), ci.Requested_Delivery_Date__c.month(),ci.Requested_Delivery_Date__c.day());
                String formattedDate = String.ValueOf(ci.Requested_Delivery_Date__c.year()) + String.ValueOf(ci.Requested_Delivery_Date__c.month()).leftPad(2,'0') + String.ValueOf(ci.Requested_Delivery_Date__c.day()).leftPad(2,'0');
                pai.reqDelDate =  formattedDate;
            }else{
                pai.reqDelDate = '';
            }

            req.priceAgreementItemList.add(pai);
            lineNumberToCartItemIdMap.put(lineNumber,ci.Id);
            lineNumber += 10;
        }
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
        System.debug('request=' +  req);
        try{
            SAPGateway service = new SAPGateway();
            PriceAgreementController.PriceAgreementResponse  resp =service.getRealTimePricing(req);
            system.debug(resp);
            system.debug('***getCpuTime()***'+Limits.getCpuTime());
            cart.Agreement_Number__c=resp.agreement;
            update cart;

            Map<Id,Decimal> cartItemPriceAgreementValueUpd=new Map<Id,Decimal>();
            Map<Id,String> cartItemPriceAgreementUpd=new Map<Id,String>();

            if(resp.priceAgreementItemList!=null){
                for(PriceAgreementController.PriceAgreementItem paiResp : resp.priceAgreementItemList){
                    system.debug(paiResp.roundedQty);
                    system.debug(paiResp.quantity);
                    system.debug(paiResp.priceAgreementValue);

                    if(paiResp.priceAgreementValue!=0){
                        cartItemPriceAgreementValueUpd.put(lineNumberToCartItemIdMap.get(paiResp.lineNumber),paiResp.priceAgreementValue);
                    }
                    cartItemPriceAgreementUpd.put(lineNumberToCartItemIdMap.get(paiResp.lineNumber),paiResp.agreement);
                }
                system.debug(cartItemPriceAgreementValueUpd);
                if(!cartItemPriceAgreementValueUpd.isEmpty()){
                    List<ccrz__E_CartItem__c> ciToUpdatePriceValue=CartServices.getCartItemsToUpdate(cartItemPriceAgreementValueUpd.keySet());
                    system.debug(ciToUpdatePriceValue);
                    for(ccrz__E_CartItem__c ci:ciToUpdatePriceValue){
                        if(ci.ccrz__Price__c!=0){
                            ci.ccrz__Price__c=cartItemPriceAgreementValueUpd.get(ci.Id);
                            ci.ccrz__SubAmount__c = cartItemPriceAgreementValueUpd.get(ci.Id) * ci.ccrz__Quantity__c;
                            ci.ccrz__PricingType__c = 'external';
                            //ci.Agreement_Number__c = cartItemPriceAgreementUpd.get(ci.Id);
                        }
                    }
                    system.debug(ciToUpdatePriceValue);
                    update ciToUpdatePriceValue;
                    res.success=false;
                }

            }
            system.debug('***getCpuTime()***'+Limits.getCpuTime());
        }

        catch (System.CalloutException cex) {
            system.debug(cex);
            ExceptionLogger.newExceptionLog(cex,'CartDetailsActions','validateOrderBeforeCheckout');
            res.success=false;
            res.data=cex.getMessage();
        }catch (System.Exception ex) {
            system.debug(ex);
            res.success=false;
            res.data=ex.getMessage();
        }
        finally{
            cart.Sample_Order__c=sampleOrder;
            update cart;
            return res;
        }



        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult validateOrderBeforeCheckout(ccrz.cc_RemoteActionContext ctx, Boolean sampleOrder, String priceAgreementNo){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success=true;
        res.data='';
        ccrz__E_Cart__c cart =CartServices.getCartById(CartServices.getActiveCartId());

        if(priceAgreementNo != null && priceAgreementNo != ''){
            cart.Agreement_Number__c = priceAgreementNo;
        }


        //price agreement validate
        if(cart.Order_Type__c == 'Price Agreement' || cart.Order_Type__c == 'One Time Price Agreement'){
            //Removing SAP call on Cart detail page by Ravi Singh
            //System.debug('validating PA');
            //PriceAgreementController.PriceAgreementResponse  resp = PriceAgreementController.validatePriceAgreement(ctx.userIsoCode, cart.Id);
            //System.debug(resp);

            /*Map<String, String> skuToCartItemIdMap = new Map<String, String>();
            String sku;

            for(ccrz__E_CartItem__c ci: cart.ccrz__E_CartItems__r){
                if(ci.ccrz__ExtSKU__c != null){
                    try{
                        sku = String.valueOf(Long.valueOf(ci.ccrz__ExtSKU__c));
                    }
                    catch(Exception e){
                        sku = (String)ci.ccrz__ExtSKU__c;
                    }
                }
                else{
                    try{
                        sku = String.valueOf(Long.valueOf(ci.ccrz__Product__r.ccrz__SKU__c));
                    }
                    catch(Exception e){
                        sku = (String)ci.ccrz__Product__r.ccrz__SKU__c;
                    }
                }
                skuToCartItemIdMap.put(sku, ci.Id);
            }

            List<String> invalidIds = new List<String>();
            //product validation check. Disabled to allow MTO products (invalidCat)
            // for(PriceAgreementController.PriceAgreementItem item : resp.priceAgreementItemList){
            //     if(item.material == 'INVALIDCAT' || item.message == 'Delisted'){
            //         sku = item.SKU;
            //         invalidIds.add(skuToCartItemIdMap.get(sku));
            //     }
            // }

            if(invalidIds.size() > 0){
                res.success = false;
            }
            res.data = invalidIds;*/
        }

        else if(cart.Order_Type__c == 'Revise Price Agreement'){
            //Removing SAP call on Cart detail page by Ravi Singh
            //System.debug('revising PA');
            //PriceAgreementController.PriceAgreementResponse  resp = PriceAgreementController.revisePriceAgreementValidate(ctx.userIsoCode, cart.Id);
            //System.debug(resp);
            //res.data = resp;

            /*Map<String, String> skuToCartItemIdMap = new Map<String, String>();
            String sku;
            for(ccrz__E_CartItem__c ci: cart.ccrz__E_CartItems__r){
                if(ci.ccrz__ExtSKU__c != null){
                    try{
                        sku = String.valueOf(Long.valueOf(ci.ccrz__ExtSKU__c));
                    }
                    catch(Exception e){
                        sku = (String)ci.ccrz__ExtSKU__c;
                    }
                }
                else{
                    try{
                        sku = String.valueOf(Long.valueOf(ci.ccrz__Product__r.ccrz__SKU__c));
                    }
                    catch(Exception e){
                        sku = (String)ci.ccrz__Product__r.ccrz__SKU__c;
                    }
                }
                skuToCartItemIdMap.put(sku, ci.Id);
            }

            List<String> invalidIds = new List<String>();
            // product validation check. Disabled to allow MTO products (invalidCat)
            // for(PriceAgreementController.PriceAgreementItem item : resp.priceAgreementItemList){
            //     if(item.material == 'INVALIDCAT' || item.message == 'Delisted'){
            //         sku = item.sku;
            //         invalidIds.add(skuToCartItemIdMap.get(sku));
            //     }
            // }
            if(invalidIds.size() > 0){
                res.success = false;
            }
            res.data = invalidIds;*/
        }
        else{
            System.debug('validating order');
            PriceAgreementController.PriceAgreementRequest req = new PriceAgreementController.PriceAgreementRequest();
            //req.customer = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            req.customer = cart.Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c;

            /*if(cart.ccrz__Account__r.Account_Group__c == 'ZEAG' && cart.Sold_To_Account__c!=null){
                Account soldToid=[Select GE_LGT_EM_SAP_Customer_Number__c from Account where ID =:cart.Sold_To_Account__c];
                req.customer = soldToid.GE_LGT_EM_SAP_Customer_Number__c;
                }


            if(String.isNotBlank(cart.ccrz__Account__r.Account_Group__c) && cart.ccrz__Account__r.Account_Group__c == 'ZEAG' && String.isNotBlank(cart.ccrz__Account__r.GE_LGT_Rep_Code__c) ){
                req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            } else {
                req.agent = '';
                req.extAgent = '';
            }*/

            req.agent ='';
            req.extAgent = '';
           	   if(cart.ccrz__Account__r.Account_Group__c=='ZEAG' &&
                       (cart.ccrz__Account__r.Customer_Segmentation__c=='FD' || cart.ccrz__Account__r.Customer_Segmentation__c=='Fixture')){
                req.agent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
                req.extAgent = cart.ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c;
            }
            req.agreement = cart.Agreement_Number__c;
            req.salesOrg = cart.ccrz__Account__r.GE_LGT_EM_Sales_Org__c;
            req.division = cart.ccrz__Account__r.GE_LGT_EM_Division__c;
            if(cart.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c!=null){
                req.distChannel = cart.ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c;
            }else{
                req.distChannel ='';
            }
            req.orderFlag = 'N';
            if(sampleOrder){
                //req.orderReason = 'Sample Order';
                req.orderReason = '';
                req.orderType = 'ZSAM';
                req.orderFlag = 'Y';
            }else{
                req.orderType = 'ZOR';
            }
            req.poNumber = '';
            /*if(cart.ccrz__Account__r.Account_Group__c == 'ZEAG'){
                req.userType = 'Agent';
            }else if(cart.ccrz__Account__r.Account_Group__c=='Z001'){
                req.userType = 'Customer';
            } else {
                req.userType = '';
            }*/
            //req.validateFlag = 'Y';
            req.agrDate='';
            req.callType='O';

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

            integer lineNumber = 10;
            Map<Integer,Id> lineNumberToCartItemIdMap = new Map<Integer,Id>();
            req.priceAgreementItemList = new List<PriceAgreementController.PriceAgreementItem>();
            for(ccrz__E_CartItem__c ci: cart.ccrz__E_CartItems__r){
                system.debug(ci.ccrz__Product__r.ccrz__SKU__c);
                system.debug(ci.ccrz__UnitOfMeasure__c);

                PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
                if(ci.ccrz__Product__r.ccrz__SKU__c!=null){
                    pai.material = ci.ccrz__Product__r.ccrz__SKU__c;
                    if(pai.material=='requestedSku'){
                        pai.description=ci.ccrz__ExtName__c;
                        pai.material='';
                        if(null != ci.ccrz__ExtSKU__c && ci.ccrz__ExtSKU__c != 'INVALIDCAT' && ci.ccrz__ExtSKU__c != 'VALIDCAT' && ci.ccrz__ExtSKU__c != ''){
                            pai.material = ci.ccrz__ExtSKU__c;
                        }
                    }
                }
                //TODO hardcoded quantity and currencyiso code
                pai.quantity = Integer.valueOf(ci.ccrz__Quantity__c);
                pai.currencyISOCode = 'USD';
                pai.lineNumber = lineNumber;
                pai.UOM = UtilityClass.convertUomLabelToUomCode(ci.ccrz__UnitOfMeasure__c);
                if(ci.Requested_Delivery_Date__c!=null){
                    system.debug('RDD '+ci.Requested_Delivery_Date__c);
                    Datetime dt = Datetime.newInstance(ci.Requested_Delivery_Date__c.year(), ci.Requested_Delivery_Date__c.month(),ci.Requested_Delivery_Date__c.day());
                    system.debug('dt '+dt);
                    String formattedDate  = String.ValueOf(ci.Requested_Delivery_Date__c.year()) + String.ValueOf(ci.Requested_Delivery_Date__c.month()).leftPad(2,'0') + String.ValueOf(ci.Requested_Delivery_Date__c.day()).leftPad(2,'0');
                    system.debug('formattedDate '+formattedDate);
                    pai.reqDelDate =  formattedDate;
                }else{
                    pai.reqDelDate = '';
                }

                if(ci.Agreement_Number__c != null){
                    pai.agreement = ci.Agreement_Number__c;
                }

                req.priceAgreementItemList.add(pai);
                lineNumberToCartItemIdMap.put(lineNumber,ci.Id);
                lineNumber += 10;
            }
            system.debug('***getCpuTime()***'+Limits.getCpuTime());
            System.debug('request=' +  req);
            try{
                SAPGateway service = new SAPGateway();
                PriceAgreementController.PriceAgreementResponse  resp =service.getRealTimePricing(req);
                system.debug(resp);

                Map<Id,Decimal> cartItemFeeToUpdateMap=new Map<Id,Decimal>();
                if(resp.errMessage!=null && String.isNotBlank(resp.errMessage)){
                    res.data=resp.errMessage+'. Please contact your Customer Service Representative.';
                }
                else{
                    if(resp.priceAgreementItemList!=null){
                        System.debug('resp.priceAgreementItemList!=null');

                        Map<String, Decimal> paItm = new Map<String, Decimal>();
                        for(PriceAgreementController.PriceAgreementItem paiResp : resp.priceAgreementItemList){
                            if(paiResp.priceAgreementValue > 0){
                                paItm.put(lineNumberToCartItemIdMap.get(paiResp.lineNumber), paiResp.priceAgreementValue);
                            }
                        }
                        if(paItm.size()>0){
                            System.debug('paItm: '+paItm);
                            List<ccrz__E_CartItem__c> items = [SELECT Id, ccrz__PricingType__c, ccrz__Quantity__c, ccrz__SubAmount__c, ccrz__Price__c FROM ccrz__E_CartItem__c WHERE Id IN :paItm.keySet()];
                            for(ccrz__E_CartItem__c item : items){
                                item.ccrz__Price__c = paItm.get(item.Id);
                                item.ccrz__SubAmount__c = item.ccrz__Price__c * item.ccrz__Quantity__c;
                            }
                            update items;
                        } 
                        else {
                            System.debug('else | paItm.size()<0');
                            res.data='';
                        }

                        for(PriceAgreementController.PriceAgreementItem paiResp : resp.priceAgreementItemList){
                            system.debug(paiResp.roundedQty);
                            system.debug(paiResp.quantity);
                            if(paiResp.roundedQty!=paiResp.quantity){
                                res.success=false;
                                res.data+=lineNumberToCartItemIdMap.get(paiResp.lineNumber)+':You must have a minimum quantity of '+String.valueOf(paiResp.roundedQty)+' of this item. The quantity has been updated for you:'+paiResp.roundedQty+',';
                            }
                            system.debug(paiResp.zfre);
                            if(paiResp.zfre!=null){
                                cartItemFeeToUpdateMap.put(lineNumberToCartItemIdMap.get(paiResp.lineNumber),paiResp.zfre);
                            }else{
                                cartItemFeeToUpdateMap.put(lineNumberToCartItemIdMap.get(paiResp.lineNumber),0.0);
                            }
                        }
                        system.debug(cartItemFeeToUpdateMap);
                        if(!cartItemFeeToUpdateMap.isEmpty()){
                            List<ccrz__E_CartItem__c> ciToUpdate=CartServices.getCartItemsToUpdate(cartItemFeeToUpdateMap.keySet());
                            system.debug(ciToUpdate);
                            for(ccrz__E_CartItem__c ci:ciToUpdate){
                                ci.Small_Order_Fee__c=cartItemFeeToUpdateMap.get(ci.Id);
                            }
                            system.debug(ciToUpdate);
                            update ciToUpdate;
                        }
                    }
                }

            }
            catch (System.CalloutException cex) {
                system.debug(cex);
                ExceptionLogger.newExceptionLog(cex,'CartDetailsActions','validateOrderBeforeCheckout');
                res.success=false;
                res.data=cex.getMessage();
            }catch (System.Exception ex) {
                system.debug(ex);
                res.success=false;
                res.data=ex.getMessage();
            }
            finally{
                cart.Sample_Order__c=sampleOrder;
                update cart;
                return res;
            }
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult priceAgreementToModifiedCart(ccrz.cc_RemoteActionContext ctx, String priceAgreementNo, Boolean isRevised) {

        system.debug('priceAgreementToModifiedCart params '+priceAgreementNo);
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        PriceAgreementToCart priceAgreement = new PriceAgreementToCart(priceAgreementNo);
        String url = priceAgreement.toCart(isRevised);
        res.success = true;
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult reorder(ccrz.cc_RemoteActionContext ctx,String orderId){
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        ReorderHelper rh = new ReorderHelper(orderId);
        String url = rh.reorder();
        res.success = true;
        return res;
    }

}