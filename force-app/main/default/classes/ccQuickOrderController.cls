global class ccQuickOrderController {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getUOMsForSKU(final ccrz.cc_RemoteActionContext ctx, string skuOrCatNum){
        ccrz.cc_RemoteActionResult resp = ccrz.cc_CallContext.init(ctx);
        List<String> responsedata = new List<String>();
        Map<String, Decimal> multipliers = new Map<String, Decimal>();
        String sku = '';
        try {
            sku = [SELECT ccrz__SKU__c FROM ccrz__E_Product__c WHERE (Name = :skuOrCatNum OR ccrz__SKU__c = :skuOrCatNum) AND (ccrz__ProductStatus__c = 'Released' OR ccrz__ProductStatus__c = 'Not Orderable') AND  (ccrz__StartDate__c = null or ccrz__StartDate__c <= TODAY) AND (ccrz__EndDate__c = null or ccrz__EndDate__c >= TODAY)].ccrz__SKU__c;
        } catch(Exception e) {}
        /*List<Pricing_UOM__c> uoms = [SELECT Id, SKU__c, UOM__c, Multiplier__c FROM Pricing_UOM__c WHERE SKU__c = :sku ORDER BY Multiplier__c ASC];
        for(Pricing_UOM__c uom : uoms) {
            responsedata.add(uom.UOM__c + '|' + UtilityClass.convertUomCodeToUomLabel(uom.UOM__c));
            multipliers.put(uom.UOM__c, uom.Multiplier__c);
        }
        if (multipliers.containsKey('EA') && multipliers.containsKey('PC') && multipliers.get('EA') == multipliers.get('PC')) {
            for (String uom : responsedata) {
                if (uom.startsWith('PC')) {
                    responsedata.remove(responsedata.indexOf(uom));
                    break;
                }
            }
        }
        if (multipliers.containsKey('CV') && multipliers.containsKey('BX') && multipliers.get('CV') == multipliers.get('BX')) {
            for (String uom : responsedata) {
                if (uom.startsWith('BX')) {
                    responsedata.remove(responsedata.indexOf(uom));
                    break;
                }
            }
        }*/
        for(Pricing_UOM__c uom : UOMServices.getUOMsForProduct(sku, null)) {
            responsedata.add(uom.UOM__c + '|' + UtilityClass.convertUomCodeToUomLabel(uom.UOM__c));
        }
        resp.data = responsedata;
        return resp;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getSKUByCatalogNumber(final ccrz.cc_RemoteActionContext ctx, List<String> catalogNumber){
        ccrz.cc_RemoteActionResult resp = ccrz.cc_CallContext.init(ctx);
        System.debug(catalogNumber);
        Map<String, Object> responsedata = new Map<String, Object>();
        /*{
            'cartId' => cartId,
            'ccrz.ccAPICart.PRODSADDEDTOCART' => addResults.get(ccrz.ccApiCart.PRODSADDEDTOCART),
            'ccrz.ccAPICart.INELIGIBLEPRODUCTS' => addResults.get(ccrz.ccApiCart.INELIGIBLEPRODUCTS),
            'ccrz.ccApi.MESSAGES' => addResults.get(ccrz.ccApi.MESSAGES),
            'numOfItems' => lineData.size(),
            'invaildCats' => invaildCats
        };*/
        for(ccrz__E_Product__c prod : [SELECT Id, Name, ccrz__SKU__c FROM ccrz__E_Product__c WHERE Name IN :catalogNumber AND (ccrz__ProductStatus__c = 'Released' OR ccrz__ProductStatus__c = 'Not Orderable') AND  (ccrz__StartDate__c = null or ccrz__StartDate__c <= TODAY) AND (ccrz__EndDate__c = null or ccrz__EndDate__c >= TODAY)]){
            responsedata.put(prod.Name, prod.ccrz__SKU__c);
        }

        resp.data = responsedata;
        return resp;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addCartItems(final ccrz.cc_RemoteActionContext ctx, List<CartDataSet> cartItems, String accountId){
        System.debug('cartItems\n'+JSON.serializePretty(cartItems));
        ccrz.cc_RemoteActionResult resp = ccrz.cc_CallContext.init(ctx);
        Id cartId = getCurrentCartId(resp);
        List<CartDataSet> newCartItems = cleanCartDataSet(cartItems);
        System.debug('after clean up cart items' + newCartItems);
        List<String> productSkus = getProductSkus(newCartItems);
        Map<String, Decimal> pricesBySku = getPriceBySku(productSkus);
        Map<String, ccrz__E_Product__c> productsBySkuNumber = getProductsBySkuNumber(productSkus);

        List<ccrz__E_CartItem__c> existingCartItems = getExistingCartItems(cartId);
        mergeNewAndExistingCartItems(newCartItems, existingCartItems);
        System.debug('before creating cart items' + JSON.serializePretty(newCartItems));
        CartItemWrapper processedCartItems = createCartItems(newCartItems, pricesBySku, productsBySkuNumber, cartId);
        System.debug('processed cart items ' + JSON.serializePretty(processedCartItems));
        insert processedCartItems.newCartItems;

        Map<String, Object> responseData = new Map<String, Object>{
                'messages' => createMessages(processedCartItems, productsBySkuNumber, cartItems),
                'cartId' => cartId
        };

        resp.data = responseData;
        return resp;
    }

    private static List<CartDataSet> cleanCartDataSet(List<CartDataSet> cartItems){
        System.debug('Cleaning cart data set');
        for(Integer i = cartItems.size() - 1; i >= 0; i--){
            if(String.isBlank(cartItems[i].sku)){
                cartItems.remove(i);
            }
        }
        System.debug('cleaned cart items ' + JSON.serializePretty(cartItems));
        Set<String> skuOrCatalogNumber = new Set<String>();
        for(CartDataSet ci : cartItems){
            skuOrCatalogNumber.add(ci.sku);
        }
        System.debug('cleaned cart items 2 ' +JSON.serializePretty(cartItems));
        List<ccrz__E_Product__c> products = [SELECT Id, Name, ccrz__SKU__c FROM ccrz__E_Product__c WHERE (Name IN :skuOrCatalogNumber OR ccrz__SKU__c IN :skuOrCatalogNumber) AND (ccrz__ProductStatus__c = 'Released' OR ccrz__ProductStatus__c = 'Not Orderable') AND  (ccrz__StartDate__c = null or ccrz__StartDate__c <= TODAY) AND (ccrz__EndDate__c = null or ccrz__EndDate__c >= TODAY)];
        System.debug('Products list' + JSON.serializePretty(products));
        System.debug('Cart items list' + JSON.serializePretty(cartItems));
        List<CartDataSet> validCartItems = new List<CartDataSet>();
        for(Integer i = 0; i < cartItems.size(); i++){
            System.debug('i ' + i);
            for (Integer j = 0; j < products.size(); j++) {
                System.debug('j ' + j);
                if(products[j].Name == cartItems[i].sku || products[j].ccrz__SKU__c == cartItems[i].sku){
                    cartItems[i].sku = products[j].ccrz__SKU__c;
                    validCartItems.add(cartItems[i]);
                    break;
                }
            }

        }

        System.debug('The final clean ' + JSON.serializePretty(cartItems));
        return validCartItems;
    }

    private static String getCurrentCartId(ccrz.cc_RemoteActionResult resp){
        String encryptedCartId = resp.inputContext.currentCartId;
        System.debug(encryptedCartId);
        if (String.isBlank(encryptedCartId) || (Test.isRunningTest()) /*&& encryptedCartId == '000000'*/) {
            Map<String, Object> createResults = ccrz.ccApiCart.create(
                    new Map<String, Object>{
                            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                            ccrz.ccApiCart.CART_OBJLIST => new List<Map<String, Object>>{
                                    new Map<String, Object>()
                            }
                    }
            );

            encryptedCartId = (String) createResults.get(ccrz.ccApiCart.CART_ENCID);
        }

        Id cartId = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :encryptedCartId].Id;
        return cartId;
    }

    private static List<String> getProductSkus(List<CartDataSet> cartItems){
        List<String> returnSet = new List<String>();
        for(CartDataSet cd : cartItems){
            returnSet.add(cd.sku);
        }

        return returnSet;
    }

    private static Map<String, ccrz__E_Product__c> getProductsBySkuNumber(List<String> productSkus){
        Map<String, ccrz__E_Product__c> returnMap = new Map<String, ccrz__E_Product__c>();
        for(ccrz__E_Product__c p : [
                SELECT Id, ccrz__SKU__c, Name
                FROM ccrz__E_Product__c
                WHERE ccrz__SKU__c IN :productSkus
                      AND (ccrz__ProductStatus__c = 'Released' OR ccrz__ProductStatus__c = 'Not Orderable')
                      AND  (ccrz__StartDate__c = null or ccrz__StartDate__c <= TODAY)
                      AND (ccrz__EndDate__c = null or ccrz__EndDate__c >= TODAY)]
        ){
            returnMap.put(p.ccrz__SKU__c, p);
        }

        return returnMap;
    }

    private static CartItemWrapper createCartItems(List<CartDataSet> cartItems, Map<String, Decimal> pricesBySku, Map<String, ccrz__E_Product__c> productsBySkuNumber, Id cartId){
        CartItemWrapper wrapper = new CartItemWrapper();
        Map<String, CartDataSet> validCartItems = checkUOMValidity(cartItems);
        for(CartDataSet ci : cartItems){
            if(!validCartItems.containsKey(ci.sku + ci.unitOfMeasure)){
                wrapper.invalidCartItems.add(ci);
            }
        }

        System.debug('valid cart item list size ' + validCartItems.size());

        List<ccrz__E_CartItem__c> newCartItems = new List<ccrz__E_CartItem__c>();
        for(CartDataSet ci : cartItems) {
            if (validCartItems.values().contains(ci)) {
                ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
                cartItem.ccrz__ExtSKU__c = ci.sku;
//              cartItem.ccrz__Quantity__c = Decimal.valueOf(ci.qty);
                cartItem.ccrz__Quantity__c = getQtyForCartItem(cartItems, ci);
                if (pricesBySku.containsKey(ci.sku)) {
                    cartItem.ccrz__Price__c = pricesBySku.get(ci.sku);
                    cartItem.ccrz__SubAmount__c = pricesBySku.get(ci.sku) * Decimal.valueOf(ci.qty);
                }
                cartItem.ccrz__UnitOfMeasure__c = ci.unitOfMeasure;
                cartItem.ccrz__ItemStatus__c = 'Available';
                cartItem.ccrz__PricingType__c = 'external';
                cartItem.ccrz__ProductType__c = 'Product';
                cartItem.ccrz__StoreID__c = 'DefaultStore';
                cartItem.ccrz__RequestDate__c = Date.today();
                cartItem.ccrz__Product__c = productsBySkuNumber.get(ci.sku).Id;
                cartItem.ccrz__Cart__c = cartId;
                newCartItems.add(cartItem);
            }
        }
        wrapper.newCartItems = newCartItems;
        return wrapper;
    }

    private static Integer getQtyForCartItem(List<CartDataSet> allCartItems, CartDataSet cartItemToCount ) {
        Integer qty = 0;
        for (CartDataSet ci : allCartItems) {
            if (ci.sku == cartItemToCount.sku) {
                qty += Integer.valueOf(ci.qty);
            }
        }

        return qty;
    }

    private static Map<String, CartDataSet> checkUOMValidity(List<CartDataSet> cartItems){
        Map<String, CartDataSet> validCartItemsBySku = new Map<String, CartDataSet>();
        Set<String> cartItemSkus = new Set<String>();
        for(CartDataSet ci : cartItems){
            cartItemSkus.add(ci.sku);
        }

        for(Pricing_UOM__c uom : UOMServices.getUOMsForProducts(cartItemSkus)){
            for(CartDataSet ci : cartItems){
                if(ci.unitOfMeasure == uom.UOM__c && ci.sku == uom.SKU__c){
                    validCartItemsBySku.put(ci.sku + ci.unitOfMeasure, ci);
                }
            }
        }

        return validCartItemsBySku;
    }

    private static List<ccrz__E_CartItem__c> getExistingCartItems(Id cartId){
        return [
                SELECT Id, ccrz__Quantity__c, ccrz__Product__r.ccrz__SKU__c, ccrz__UnitOfMeasure__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__c = :cartId
                AND Type_Marks__c = null
        ];
    }

    private static void mergeNewAndExistingCartItems(List<CartDataSet> cartItems, List<ccrz__E_CartItem__c> existingCartItems){
        Boolean isChanged = false;
        for(Integer i = cartItems.size() - 1; i >= 0; i--){
            for(ccrz__E_CartItem__c eci : existingCartItems){
                if(cartItems[i].sku == eci.ccrz__Product__r.ccrz__SKU__c && cartItems[i].unitOfMeasure == eci.ccrz__UnitOfMeasure__c){
                    eci.ccrz__Quantity__c += Decimal.valueOf(cartItems[i].qty);
                    cartItems.remove(i);
                    isChanged = true;
                    break;
                }
            }
        }
        if(isChanged) update existingCartItems;
    }

    private static Map<String, Decimal> getPriceBySku(List<String> skuList){
        Map<String, Decimal> returnMap = new Map<String, Decimal>();
        System.debug(skuList);
        System.debug([SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c IN :skuList]);

        Map<String, Object> productFetchQuery = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccAPIProduct.PRODUCTSKULIST => skuList,
                ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true,
                ccrz.ccAPIProduct.INCLUDE_ATTRIBUTE_PRICING => true,
                ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
                        }
                }
        };

        try {
            Map<String, Object> productFetchData = ccrz.ccAPIProduct.fetch(productFetchQuery);
            if (Test.isRunningTest()) {
                List<Map<String, Object>> productsList = new List<Map<String, Object>>{
                        new Map<String, Object>{'SKU' => 'test1', 'price' => 10},
                        new Map<String, Object>{'SKU' => 'test2', 'price' => 20},
                        new Map<String, Object>{'SKU' => 'requestedSku', 'price' => 30}
                };
                productFetchData = new Map<String, Object>{
                        ccrz.ccAPIProduct.PRODUCTLIST => productsList
                };
            }
            System.debug(JSON.serializePretty(productFetchData));
            if (productFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {
                List<Map<String, Object>> myProductDataList = (List<Map<String, Object>>) productFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST);
                System.debug(myProductDataList.size());
                System.debug(JSON.serializePretty(myProductDataList));
                for (Map<String, Object> mso : myProductDataList) {
                    returnMap.put((String) mso.get('SKU'), (Decimal) mso.get('price'));
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }

        return returnMap;
    }

    private static List<Map<String, String>> createMessages(CartItemWrapper processedCartItems, Map<String, ccrz__E_Product__c> productsBySkuNumber, List<CartDataSet> cartItemsTotal){
        List<String> newProductList = new List<String>();
        List<String> invalidProductList = new List<String>();
        List<String> allInput = new List<String>();
        for(ccrz__E_CartItem__c newItem : processedCartItems.newCartItems){
            newProductList.add(productsBySkuNumber.get(newItem.ccrz__ExtSKU__c)?.Name);
        }

        for (CartDataSet ci : cartItemsTotal) {
            if (!ci.sku.isWhitespace()) {
                allInput.add(ci.sku);
            }
        }

        for(CartDataSet ci : processedCartItems.invalidCartItems){
            invalidProductList.add(productsBySkuNumber.get(ci.sku)?.Name + ' (' + ci.unitOfMeasure + ')');
        }

        for (ccrz__E_CartItem__c ci : processedCartItems.newCartItems) {
            if (ci.ccrz__ExtSKU__c != null && allInput.contains(ci.ccrz__ExtSKU__c)) {
                allInput.remove(allInput.indexOf(ci.ccrz__ExtSKU__c));
            }
            if (ci.Name != null && allInput.contains(ci.Name)) {
                allInput.remove(allInput.indexOf(ci.ccrz__ExtSKU__c));
            }
        }
        invalidProductList.addAll(allInput);

        List<Map<String, String>> returnMessages = new List<Map<String, String>>();

        if(!newProductList.isEmpty()){
            returnMessages.add(new Map<String, String>{
                    'classToAppend' => 'quick_order',
                    'message' => 'The following product(s) were added: ' + String.join(newProductList, ', '),
                    'severity' => 'INFO',
                    'type' => 'CUSTOM'
            });

        }

        if(!invalidProductList.isEmpty()){
            returnMessages.add(new Map<String, String>{
                    'classToAppend' => 'quick_order',
                    'message' => 'The following product(s) could not be added: ' + String.join(invalidProductList, ', '),
                    'severity' => 'ERROR',
                    'type' => 'CUSTOM'
            });
        }

        return returnMessages;
    }

    global class CartDataSet{
        @TestVisible
        String sku;
        @TestVisible
        String qty;
        @TestVisible
        String unitOfMeasure;
    }

    global class CartItemWrapper{
        List<ccrz__E_CartItem__c> newCartItems;
        List<CartDataSet> invalidCartItems;

        global CartItemWrapper(){
            newCartItems = new List<ccrz__E_CartItem__c>();
            invalidCartItems = new List<CartDataSet>();
        }
    }
}