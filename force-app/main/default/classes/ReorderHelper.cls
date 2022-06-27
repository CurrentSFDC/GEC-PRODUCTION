/********************************************************************
Purpose: Handles custom reorder logic. Takes Order Id from OrderSearchController,
        replicates the order in a CC Cart, and returns a url linking to the appropriate 'My Cart' page

History:
--------
VERSION  AUTHOR       DATE         DESCRIPTION
1.0      Alex Bowser  9-NOV-2020  Created
*/
public class ReorderHelper {

    String orderId;
    List<Order> order;
    List<String> skus = new List<String>();
    List<String> invalidPrices = new List<String>();
    Map<String, Id> uomToAttrId = new Map<String, Id>();
    String url;
    String cartId;

    public ReorderHelper(String orderId){

        this.orderId = orderId;
        List<ccrz__E_Attribute__c> uoms = [SELECT Id, Name FROM ccrz__E_Attribute__c WHERE ccrz__ParentAttribute__r.Name = 'Unit of Measure' OR Name = 'Unit of Measure'];
        for(ccrz__E_Attribute__c uom : uoms){
            uomToAttrId.put(uom.Name, uom.Id);
        }
        this.order = [SELECT AccountId, Agent_Account__c, BillingAddress, Sold_To__c, CurrencyIsoCode, (SELECT Id, SKU__c,Type_Mark__c, Quantity, Agreement_Quote__c, UnitOfMeasure__c, UnitPrice, SKU_Description_Cat_Logic__c FROM OrderItems ORDER BY Order_Line_Number__c) FROM Order WHERE Id = :orderId];
        if(Test.isRunningTest()){
            this.url = 'test.com';
        }
        else{
            List<Network> domain = [SELECT Id FROM Network WHERE Name = 'Current'];
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(domain[0].Id);
            this.url = myCommunity.siteUrl;
        }
    }

    public String reorder() {

        try{
            cartId = getActiveCart();
            if (cartId!=null) CartServices.changeOrderType(cartId, 'Purchase Order');
            if(invalidPrices.size() > 0){
                updateInvalidCartItems(cartId, invalidPrices);
                System.debug('invalidPrices:'+invalidPrices);
            }
            //this.url = this.url + '/ccrz__Cart?cartId=' + cartId + '&soldTo='+ this.order[0].Sold_To__c+'&reOrder=true'+'&orderId='+this.order[0].Id;
            //return this.url;
            return 'url';
        }
        catch(Exception e){
            throw e;
        }
    }

    public String reorderUrl() {

        try{
            this.url = this.url + '/ccrz__Cart?&soldTo='+ this.order[0].Sold_To__c+'&reOrder=true'+'&orderId='+this.order[0].Id;
            return this.url;
        }
        catch(Exception e){
            throw e;
        }
    }

    private Map<String, Object> getCurrentCart() {
        Map<String, Object> getCartInputData = new Map<String, Object> {
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApi.SIZING => new Map<String, Object> {
                        ccrz.ccApiCart.ENTITYNAME => new Map<String, Object> {
                                ccrz.ccApi.SZ_REFETCH => true
                        }
                }
        };
        Map<String, Object> getCartResults = new Map<String, Object>();
        if(Test.isRunningTest()){
            getCartResults = new Map<String, Object> {
                    ccrz.ccApiCart.CART_OBJLIST => new List<Object>{
                            new Map<String, Object> {
                                    'sfid' => [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'][0].Id
                            }
                    }
            };
        }
        else{
            getCartResults = ccrz.ccApiCart.getActive(getCartInputData);
            System.debug('getCartResults:'+getCartResults);
            System.debug('getCartResults:'+(List<Object>) getCartResults.get(ccrz.ccApiCart.CART_OBJLIST));

        }
        return getCartResults;
    }

    private String getActiveCart(){

        Map<String, Object> getCartResults = getCurrentCart();



        /*if ((List<Object>) getCartResults.get(ccrz.ccApiCart.CART_OBJLIST) == null) {

            Boolean wasSuccessful = false;
            Map<String, Object> cartToCreate = new Map<String, Object> {
                    'cartType' => 'Cart',
                    'activeCart' => true,
                    'name' => 'New Cart',
                    'storefront' => 'DefaultStore',
                    'effectiveAccountId' => '0013j00002dOY89AAG'
            };

            Map<String, Object> cartCreateInputData = new Map<String, Object> {
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.CART_OBJLIST => new List<Map<String, Object>> {cartToCreate},
                    ccrz.ccApi.SIZING => new Map<String, Object> {
                            ccrz.ccApiCart.ENTITYNAME => new Map<String, Object> {
                                    ccrz.ccApi.SZ_REFETCH => true
                            }
                    }
            };


            getCartResults = ccrz.ccApiCart.create(cartCreateInputData);
            System.debug('getCartResults:'+(List<Object>) getCartResults.get(ccrz.ccApiCart.CART_OBJLIST));

        }*/

        List<Object> getCartList = (List<Object>) getCartResults.get(ccrz.ccApiCart.CART_OBJLIST);
        String cartId = '';

        if(getCartList != null){
            Map<String, Object> activeCart = (Map<String, Object>) getCartList[0];
            cartId = (String)activeCart.get('sfid');
           System.debug('getCartList:'+getCartList);

            if(activeCart.get('ECartItemsS') != null){
                String clearReturn = clearCart(cartId, (List<Map<String,Object>>)activeCart.get('ECartItemsS'));
              System.debug('activeCart:'+activeCart.get('ECartItemsS'));

            }
        }

        String addResult = addItems(cartId);

        //Validate cart
        /*getCartResults = getCurrentCart();
        getCartList = (List<Object>) getCartResults.get(ccrz.ccApiCart.CART_OBJLIST);
        if(getCartList != null) {
            Map<String, Object> activeCart = (Map<String, Object>) getCartList[0];
            cartId = (String)activeCart.get('sfid');
            List<ccrz__E_CartItem__c> items = [SELECT ccrz__UnitOfMeasure__c, ccrz__ExtSKU__c, ccrz__Product__r.ccrz__SKU__c, Requested_Delivery_Date__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :cartId];
            for (ccrz__E_CartItem__c item : items) {
                item.ccrz__UnitOfMeasure__c = '(not found)';
                for (OrderItem oitem : order[0].OrderItems) {
                    if (oitem.SKU__c == item.ccrz__ExtSKU__c || oitem.SKU__c == item.ccrz__Product__r.ccrz__SKU__c) {
                        item.ccrz__UnitOfMeasure__c = oitem.UnitOfMeasure__c;
                        break;
                    }
                }
                item.Requested_Delivery_Date__c = Date.today();
            }
            update items;
        }*/

        return addResult;
    }


    @testVisible
    private String clearCart(String cartId, List<Map<String,Object>> activeCart){

        List<ccrz.ccApiCart.LineData> cartLineData = new List<ccrz.ccApiCart.LineData>();
        ccrz.ccApiCart.LineData lineData;
        for(Map<String,Object> cartItem : activeCart){
            lineData = new ccrz.ccApiCart.LineData();
            lineData.sfid = (Id)cartItem.get('sfid');
            cartLineData.add(lineData);
        }

        Map<String, Object> cartRemoveFromData = new Map<String, Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ID => cartId,
            ccrz.ccApiCart.LINE_DATA => cartLineData
        };

        Map<String, Object> cartRemoveFromResults = ccrz.ccApiCart.removeFrom(cartRemoveFromData);
        return((String)cartRemoveFromResults.get(ccrz.ccApiCart.CART_ENCID));
    }


    /*private String addItems(String cartId){
        system.debug('cartId '+cartId);
        List<Map<String, Object>> lineData = generateLineData();
        system.debug('generateLineData'+lineData);
        Map<String, Object> cartItemsToAdd;

        if(cartId == ''){
            system.debug('Empty cartid');
            cartItemsToAdd = new Map<String, Object> {
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.LINE_DATA => lineData
            };
        }
        else{
            system.debug('Not empty cartid '+cartId);
            cartItemsToAdd = new Map<String, Object> {
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ID => cartId,
                ccrz.ccApiCart.LINE_DATA => lineData
            };
        }

        Map<String, Object> addToCartResults;
        if(Test.isRunningTest()){
            addToCartResults = new Map<String, Object>{
                ccrz.ccApiCart.CART_ENCID => 'test'
            };
        }
        else{
            addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);
             System.debug('cartItemsToAdd:'+cartItemsToAdd);
        }
        system.debug('createdCart: '+(String)addToCartResults.get(ccrz.ccApiCart.CART_ENCID));

        return((String)addToCartResults.get(ccrz.ccApiCart.CART_ENCID));
    }*/

    /*private List<Map<String, Object>> generateLineData(){

        List<String> PANumbers = new List<String>();
        for(OrderItem item : this.order[0].OrderItems){
            skus.add(item.SKU__c);*/
            /*
            if(!String.isBlank(item.Agreement_Quote__c)){
                //PANumbers.add(item.Agreement_Quote__c); Ignore PA number
            }
            */
        /*}*/
        /*system.debug(PANumbers);
        User user = [SELECT Contact.AccountId, Contact.Account.GE_LGT_Rep_Code__c FROM User WHERE Id =: UserInfo.getUserId()];
        List<SAP_Price_Agreement__c> allAgreements;
        if(String.isBlank(user.Contact.Account.GE_LGT_Rep_Code__c)){
            allAgreements = PriceAgreementServices.searchPriceAgreementCustomer(user.Contact.AccountId);
        }
        else{
            allAgreements = PriceAgreementServices.searchPriceAgreementAgent(user.Contact.AccountId);
        }
        system.debug(allAgreements);
        List<SAP_Price_Agreement_Item__c> PAItems = new List<SAP_Price_Agreement_Item__c>();
        for(SAP_Price_Agreement__c agreement : allAgreements){

            if(PANumbers.contains(agreement.Agreement_No__c)){
                for(SAP_Price_Agreement_Item__c item : agreement.SAP_Price_Agreement_Items__r){
                    if(skus.contains(item.Material_No__c)){
                        PAItems.add(item);
                    }
                }
            }
        }
        system.debug(PAItems);
        //Map of PA Number => Map of sku => PA Item
        Map<String, Map<String, SAP_Price_Agreement_Item__c>> PANumberMap = new Map<String, Map<String, SAP_Price_Agreement_Item__c>>();
        Map<String, SAP_Price_Agreement_Item__c> skuMap;
        for(SAP_Price_Agreement_Item__c item : PAItems){
            if(PANumberMap.containsKey(item.Agreement_No__c)){
                skuMap = PANumberMap.get(item.Agreement_No__c);
            }
            else{
                skuMap = new Map<String, SAP_Price_Agreement_Item__c>();
            }
            skuMap.put(item.Material_No__c, item);
            PANumberMap.put(item.Agreement_No__c, skuMap);
        }
        */
        /*List<String> attrSkus = new List<String>();
        List<ccrz__E_Product__c> ccProdList = [SELECT Id, ccrz__PrimaryAttr__r.Name, ccrz__SKU__c FROM ccrz__E_Product__c WHERE ccrz__SKU__c IN :skus AND ccrz__ProductStatus__c = 'Released' AND  (ccrz__StartDate__c = null or ccrz__StartDate__c <= TODAY) AND (ccrz__EndDate__c = null or ccrz__EndDate__c >= TODAY)];
        for(ccrz__E_Product__c prod : ccProdList){
            if(prod.ccrz__PrimaryAttr__r.Name == 'Unit of Measure'){
                attrSkus.add(prod.ccrz__SKU__c);
            }
        }
			system.debug(attrSkus);
        Map<String, Object> skuToUOMPricing = getPricingUOM(attrSkus);
		System.debug('skuToUOMPricing'+skuToUOMPricing);
        List<Map<String, Object>> lineData = new List<Map<String, Object>>();
        Map<String, Object> currentItem;
        SAP_Price_Agreement_Item__c curPAItem;
        Decimal price;
        String UOMField;


        for(OrderItem item : this.order[0].OrderItems){
			try{

            Boolean isValidSku = false;
            for(ccrz__E_Product__c prod : ccProdList){
                if(prod.ccrz__SKU__c == item.SKU__c) isValidSku = true;
            }

			System.debug('item'+item);
            if(isValidSku){

                currentItem = new Map<String, Object> {
                    ccrz.ccApiCart.LINE_DATA_SKU => item.SKU__c,
                    ccrz.ccApiCart.LINE_DATA_QUANTITY => item.Quantity
                };

                //uom attribute items
                if(attrSkus.contains(item.SKU__c)){
                    currentItem.put(ccrz.ccApiCart.LINE_DATA_ATTRIBUTE_LIST, new List<Id>{uomToAttrId.get(item.UnitOfMeasure__c)});
                    if(item.UnitPrice!=null){
                        price = item.UnitPrice;
                    }else{
                        price = ((Map<String, Decimal>)skuToUOMPricing.get(item.SKU__c)).get(item.UnitOfMeasure__c);
                    }
                    currentItem.put(ccrz.ccApiCart.LINE_DATA_PRICE, price);
                    System.debug('currentItem'+currentItem);
                }


				System.debug('currentItem outside'+currentItem);*/

                //if there's a PA for item, add price from PA to currentItem
                /*if(!String.isEmpty(item.Agreement_Quote__c)){


                        curPAItem = PANumberMap.get(item.Agreement_Quote__c).get(item.SKU__c);

                        switch on item.UnitOfMeasure__c {
                            when 'BX' {
                                price = curPAItem.Price_Per_BX__c;
                            }
                            when 'CV' {
                                price = curPAItem.Price_Per_CV__c;
                            }
                            when 'EA' {
                                price = curPAItem.Price_Per_EA__c;
                            }
                            when 'ICV' {
                                price = curPAItem.Price_Per_ICV__c;
                            }
                            when 'PC' {
                                price = curPAItem.Price_Per_PC__c;
                            }
                            when else {
                                price = curPAItem.Price_Per_EA__c;
                            }
                        }
                        system.debug(item.UnitPrice);
                        system.debug(price);
                        if(item.UnitPrice == price){
                            currentItem.put(ccrz.ccApiCart.LINE_DATA_PRICE, price);
                        }
                        else{
                            invalidPrices.add(item.SKU__c);
                        }
                }*/


            /*}
            else{
                currentItem = new Map<String, Object> {
                    ccrz.ccApiCart.LINE_DATA_SKU => 'requestedSku',
                    ccrz.ccAPICart.LINE_DATA_EXT_NAME => item.SKU_Description_Cat_Logic__c,
                    ccrz.ccAPICart.LINE_DATA_EXT_SKU => item.SKU__c,
                    ccrz.ccApiCart.LINE_DATA_QUANTITY => item.Quantity,
                    ccrz.ccApiCart.LINE_DATA_PRICE => item.UnitPrice
                };
            }
            lineData.add(currentItem);
        }
            catch(Exception e){
                system.debug(e.getMessage());
                system.debug(e.getStackTraceString());
                invalidPrices.add(item.SKU__c);
            }
        }
        system.debug('TDBG Line Data '+JSON.serializePretty(lineData));
        return lineData;

    }*/

    public void updateInvalidCartItems(String cartId, List<String> skus){
        //List<ccrz__E_CartItem__c> items = [SELECT Reorder_Agreement_Invalid__c FROM ccrz__E_CartItem__c WHERE ccrz__Product__r.ccrz__SKU__c IN :skus OR ccrz__ExtSKU__c IN :skus];
        List<ccrz__E_CartItem__c> items = [SELECT Reorder_Agreement_Invalid__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c =: cartId AND (ccrz__Product__r.ccrz__SKU__c IN :skus OR ccrz__ExtSKU__c IN :skus)];

        for(ccrz__E_CartItem__c item : items){
            item.Reorder_Agreement_Invalid__c = true;
        }
        update items;
    }

    /*private Map<String, Object> getPricingUOM(List<String> skus){

        Map<String, Object> skuToPricing = new Map<String, Object>();

        Map<String, Object> productFetchQuery = new Map<String, Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccApiProduct.PRODUCTSKULIST => new Set<String>(skus),
            ccrz.ccApiProduct.INCLUDE_ATTRIBUTE_PRICING => true,
            ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true,
            ccrz.ccApiProduct.PARSE_ATTRIBUTE_PRICING => true,


            ccrz.ccApi.SIZING => new Map<String, Object> {
                ccrz.ccApiProduct.ENTITYNAME => new Map<String, Object> {
                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
                }
            }
        };

        if(Test.isRunningTest()){
            skuToPricing.put('Test SKU', new Map<String, Object>{
                'EA'=>1.00
            });
            return skuToPricing;
        }
        Map<String, Object> productFetchData = ccrz.ccApiProduct.fetch(productFetchQuery);

        if(((List<Map<String, Object>>)productFetchData.get(ccrz.ccApiProduct.PRODUCTLIST))==null) return null;

        Map<String, String> skuToSfid = new Map<String, String>();
        for(Map<String,Object> productData : (List<Map<String, Object>>)productFetchData.get(ccrz.ccApiProduct.PRODUCTLIST)){
            skuToSfid.put((String)productData.get('SKU'), (String)productData.get('sfid'));
        }

        Map<String, Object> pricingData = (Map<String, Object>)productFetchData.get(ccrz.ccApiProduct.PRODUCTPRICINGDATA);

        Map<String,Object> curPricing;
        Map<String,Decimal> UOMPricing = new Map<String,Decimal>();
        for(String sku : skus){
            curPricing = (Map<String,Object>)pricingData.get(skuToSfid.get(sku));
            curPricing = (Map<String,Object>)((Map<String,Object>)((Map<String,Object>)curPricing.get('productPrice')).get('attributePricing')).get('aL');
            for(String uom : uomToAttrId.keySet()){
                if(uom != 'Unit of Measure' && curPricing.containsKey(uomToAttrId.get(uom))){
                    UOMPricing.put(uom, (Decimal)(((Map<String,Object>)curPricing.get(uomToAttrId.get(uom))).get('pr')));
                }
            }

            skuToPricing.put(sku,UOMPricing);
        }
        system.debug(skuToPricing);

        return skuToPricing;
    }*/

    private String addItems(String cartId) {
            Set<String> itemSkus = new Set<String>();
            for (OrderItem oItem : order[0].OrderItems) {
                itemSkus.add(oItem.SKU__c);
            }
            Map<String, ccrz__E_Product__c> products = new Map<String, ccrz__E_Product__c>();
            for (ccrz__E_Product__c product : [SELECT Id, ccrz__SKU__c FROM ccrz__E_Product__c WHERE ccrz__SKU__c IN :itemSkus]) {
                products.put(product.ccrz__SKU__c, product);
            }
            ccrz__E_Product__c requestedSku = [SELECT Id FROM ccrz__E_Product__c WHERE ccrz__SKU__c = 'requestedSku' LIMIT 1];
            List<ccrz__E_CartItem__c> cartItems = new List<ccrz__E_CartItem__c>();
            //if (cartId == '') {
                cartId = String.valueOf(ccrz.ccApiCart.create(new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                }).get(ccrz.ccApiCart.CART_ID));
            //}
            for (OrderItem oItem : order[0].OrderItems) {
                ccrz__E_CartItem__c sameTypeMarkItem = null;
                if (!cartItems.isEmpty()) {
                    for (ccrz__E_CartItem__c aItem : cartItems) {
                        if (products.get(oItem.SKU__c) != null && aItem.ccrz__Product__c == products.get(oItem.SKU__c).Id && aItem.ccrz__UnitOfMeasure__c == oItem.UnitOfMeasure__c && aItem.Type_Marks__c == oItem.Type_Mark__c) {
                            sameTypeMarkItem = aItem;
                            break;
                        }
                    }
                }
                if (sameTypeMarkItem != null) {
                    Decimal sumOfQuantities = 0;
                    sumOfQuantities = (oItem.Quantity != null ? oItem.Quantity : 0) + sameTypeMarkItem.ccrz__Quantity__c;
                    sameTypeMarkItem.ccrz__Price__c = oItem.UnitPrice;
                    sameTypeMarkItem.ccrz__Quantity__c = sumOfQuantities;
                    sameTypeMarkItem.ccrz__SubAmount__c = (oItem.UnitPrice * sumOfQuantities).setScale(2);
                } else {
                    ccrz__E_CartItem__c newCartItem = new ccrz__E_CartItem__c();
                    newCartItem.ccrz__Cart__c = cartId;
                    newCartItem.ccrz__Quantity__c = oItem.Quantity;
                    newCartItem.ccrz__Price__c = oItem.UnitPrice;
                    newCartItem.ccrz__SubAmount__c = oItem.UnitPrice * oItem.Quantity;
                    newCartItem.ccrz__UnitOfMeasure__c = oItem.UnitOfMeasure__c;
                    newCartItem.Type_Marks__c = oItem.Type_Mark__c;
                    newCartItem.ccrz__ItemStatus__c = 'Available';
                    newCartItem.ccrz__ProductType__c = 'Product';
                    newCartItem.ccrz__StoreID__c = 'DefaultStore';
                    newCartItem.ccrz__RequestDate__c = Date.today();
                    newCartItem.Requested_Delivery_Date__c = Date.today();
                    if (products.get(oItem.SKU__c) != null) {
                        newCartItem.ccrz__Product__c = products.get(oItem.SKU__c).Id;
                        newCartItem.ccrz__PricingType__c = 'auto';
                    } else {
                        newCartItem.ccrz__Product__c = requestedSku.Id;
                        newCartItem.ccrz__ExtSKU__c = oItem.SKU__c;
                        newCartItem.ccrz__ExtName__c = oItem.SKU_Description_Cat_Logic__c;
                        newCartItem.ccrz__PricingType__c = 'external';
                    }
                    cartItems.add(newCartItem);
                }
            }
            insert cartItems;
            ccrz__E_Cart__c cart = [SELECT ccrz__EncryptedId__c, Sold_To_Account__c FROM ccrz__E_Cart__c WHERE Id = :cartId LIMIT 1];
            cart.Sold_To_Account__c = order[0].Sold_To__c;
            cart.Cart_Origin__c = 'Reorder';
            update cart;
            return cart.ccrz__EncryptedId__c;
    }
}