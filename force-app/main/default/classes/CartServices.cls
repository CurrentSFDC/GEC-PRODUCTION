public with sharing class CartServices {

    public static void changeAgreementNumber(String cartId, String agreementNo){
        ccrz__E_Cart__c cart = [SELECT Order_Type__c FROM ccrz__E_Cart__c WHERE Id =: cartId OR ccrz__EncryptedId__c =: cartId];
        SAP_Price_Agreement__c priceAgreement = [SELECT Description__c,Valid_From__c,Expiration_Date__c FROM SAP_Price_Agreement__c WHERE Agreement_No__c =: agreementNo];
		cart.Project_Name__c=priceAgreement.Description__c;
        cart.Agreement_Number__c = agreementNo;
        cart.Valid_From__c=priceAgreement.Valid_From__c;
        cart.Valid_To__c= priceAgreement.Expiration_Date__c;
        update cart;
    }

    public static void setValidDates(String cartId){
        ccrz__E_Cart__c cart = [SELECT Order_Type__c FROM ccrz__E_Cart__c WHERE Id =: cartId OR ccrz__EncryptedId__c =: cartId];
        cart.Valid_From__c = system.today();
        cart.Valid_To__c = system.today().addDays(60);
        update cart;
    }

    public static void changeOrderTypeWithOrigin(String cartId, String orderType, String CartOrigin){
        system.debug('cartid '+cartId);

        try{
            ccrz__E_Cart__c cart = [SELECT Order_Type__c, Cart_Origin__c FROM ccrz__E_Cart__c WHERE Id =: cartId OR ccrz__EncryptedId__c =: cartId];
            cart.Order_Type__c = orderType;
            cart.Cart_Origin__c = CartOrigin;
            update cart;
        }catch(Exception e){
            return;
        }
    }

    public static void changeOrderType(String cartId, String orderType){
        system.debug('cartid '+cartId);

        try{
            ccrz__E_Cart__c cart = [SELECT Order_Type__c FROM ccrz__E_Cart__c WHERE Id =: cartId OR ccrz__EncryptedId__c =: cartId];
            cart.Order_Type__c = orderType;
            update cart;
        }catch(Exception e){
            return;
        } 
    }
    
    
	public static void deleteRPA(String cartId){
        ccrz__E_Cart__c cart = [SELECT Order_Type__c FROM ccrz__E_Cart__c WHERE Id =: cartId OR ccrz__EncryptedId__c =: cartId];
        try{
            delete cart;
        }catch(Exception e){
            return;
        } 
    }
    
    
    public static void changeCartItemAgreementNo(String cartItemId, String priceAgreementNo){
        ccrz__E_CartItem__c item = [SELECT Agreement_Number__c FROM ccrz__E_CartItem__c WHERE Id =: cartItemId];
        item.Agreement_Number__c = priceAgreementNo;
        update item;
    }

    public static void changeSoldTo(String cartId, String soldToId){
        ccrz__E_Cart__c cart = [SELECT Sold_To_Account__c FROM ccrz__E_Cart__c WHERE Id =: cartId OR ccrz__EncryptedId__c =: cartId];
        cart.Sold_To_Account__c = soldToId;
        update cart;
    }
	public static void StrategicAccount(String cartId, String strategicaccountId){
        ccrz__E_Cart__c cart = [SELECT Strategic_Account_L__c FROM ccrz__E_Cart__c WHERE Id =: cartId OR ccrz__EncryptedId__c =: cartId];
        cart.Strategic_Account_L__c = strategicaccountId;
        update cart;
    }
    public static String getActiveCartId(){  

        Map<String, Object> getCartInputData = new Map<String, Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION, 
            ccrz.ccApi.SIZING => new Map<String, Object> {
                ccrz.ccApiCart.ENTITYNAME => new Map<String, Object> {
                    ccrz.ccApi.SZ_REFETCH => true
                }
            }
        };
        system.debug('getCartInputData '+JSON.serializePretty(getCartInputData));
        Map<String, Object> getCartResults = ccrz.ccApiCart.getActive(getCartInputData);
        system.debug('cart result '+JSON.serializePretty(getCartResults));
        List<Object> getCartList = (List<Object>) getCartResults.get(ccrz.ccApiCart.CART_OBJLIST);
        system.debug('getCartList '+JSON.serializePretty(getCartList));
        String cartId = '';

        if(getCartList != null){
            Map<String, Object> activeCart = (Map<String, Object>) getCartList[0];
            cartId = (String)activeCart.get('sfid');
        }

        if(Test.isRunningTest()){
            ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'];
            cartId = cart.Id;
        }
        System.debug('cart service cart id: ' + cartId);
        return cartId;
    }

    public static List<ccrz__E_CartItem__c> getCartItemExtSkusByCartId(String cartId) {
        return [SELECT Id, ccrz__cartItemType__c, ccrz__ExtSKU__c, ccrz__Quantity__c, ccrz__OriginalQuantity__c,
                    CurrencyIsoCode, ccrz__StoreID__c, ccrz__RequestDate__c, ccrz__ItemLabel__c, ccrz__Product__c, 
                    ccrz__Product__r.ccrz__SKU__c, ccrz__UnitOfMeasure__c, ccrz__ProductType__c, ccrz__Price__c, ccrz__SubAmount__c, ccrz__SelectedAttr__c, ccrz__PricingType__c,
                    (SELECT Id,
                    ccrz__Price__c,
                    ccrz__Quantity__c,
                    ccrz__ItemTotal__c,
                    ccrz__SubAmount__c,
                    ccrz__Product__r.ccrz__SKU__c,
                    ccrz__Product__r.MaterialDescription__c,
                    ccrz__UnitOfMeasure__c,
                    Requested_Delivery_Date__c,
                    Type_Marks__c
                FROM ccrz__Cart_Items__r)
                    FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :cartId];
    }

    public static ccrz__E_CartItem__c getCartItemById(String cartItemId) {
        return [SELECT Id, ccrz__cartItemType__c, ccrz__ExtSKU__c, ccrz__Quantity__c, ccrz__OriginalQuantity__c,
                    CurrencyIsoCode, ccrz__StoreID__c, ccrz__RequestDate__c, ccrz__ItemLabel__c, ccrz__Product__c, ccrz__SelectedAttr__c,
                    ccrz__Product__r.ccrz__SKU__c, ccrz__UnitOfMeasure__c, ccrz__ProductType__c, ccrz__Price__c, ccrz__SubAmount__c, Requested_Delivery_Date__c,ccrz__PricingType__c,
                    (SELECT Id,
                    ccrz__Price__c,
                    ccrz__Quantity__c,
                    ccrz__ItemTotal__c,
                    ccrz__SubAmount__c,
                    ccrz__Product__r.ccrz__SKU__c,
                    ccrz__Product__r.MaterialDescription__c,
                    ccrz__UnitOfMeasure__c,
                    Requested_Delivery_Date__c,
                    Type_Marks__c,
                    ccrz__PrimaryAttr__c
                FROM ccrz__Cart_Items__r)
                    FROM ccrz__E_CartItem__c WHERE Id = :cartItemId];
    }

    public static List<ccrz__E_CartItem__c> getCartItemsToUpdate(Set<Id> cartItemIds) {
        return [SELECT Id, ccrz__Quantity__c,ccrz__Price__c, Small_Order_Fee__c,ccrz__SubAmount__c,ccrz__PricingType__c,Agreement_Number__c
                    FROM ccrz__E_CartItem__c WHERE Id IN: cartItemIds];
    }

    public static ccrz__E_Cart__c getCartById(String cartId) {
        system.debug('cartid '+cartId);

        return [Select Id,
        ccrz__Account__c,        
        ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__Account__r.Account_Group__c,
        ccrz__Account__r.GE_LGT_EM_Sales_Org__c,
        ccrz__Account__r.GE_LGT_EM_Division__c,
        ccrz__Account__r.GE_LGT_Rep_Code__c,
        ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c,
        Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__Account__r.Customer_Segmentation__c,        
        Sample_Order__c,
        Sold_To_Account__c,
        Order_Type__c,
        Agreement_Number__c,
        Project_City__c,
        Project_Country__c,
        Project_Postal_Code__c,
        Project_State__c,
        Project_Description__c,
        Project_Name__c,
        Strategic_Account__c,
       (Select Id, LastModifiedDate, Name, Requested_Delivery_Date__c, ccrz__ExtSKU__c, ccrz__UnitOfMeasure__c, ccrz__Quantity__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.MaterialDescription__c, Small_Order_Fee__c, ccrz__Comments__c,Agreement_Number__c,ccrz__ExtName__c from ccrz__E_CartItems__r) FROM ccrz__E_Cart__c WHERE id=:cartId];
    }

    /*public static ccrz__E_Cart__c getCartByEffAcc(String effAccId) {
        return [Select Id,
                ccrz__EncryptedId__c,
        ccrz__Account__c,
        ccrz__Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__Account__r.Account_Group__c,
        ccrz__Account__r.GE_LGT_EM_Sales_Org__c,
        ccrz__Account__r.GE_LGT_EM_Division__c,
        ccrz__Account__r.GE_LGT_Rep_Code__c,
        ccrz__Account__r.GE_LGT_EM_Distribution_Channel__c,
        Sold_To_Account__r.GE_LGT_EM_SAP_Customer_Number__c,
        ccrz__Account__r.Customer_Segmentation__c,
        Sample_Order__c,
        Sold_To_Account__c,
        Order_Type__c,
        Agreement_Number__c,
        Project_City__c,
        Project_Country__c,
        Project_Postal_Code__c,
        Project_State__c,
        Project_Description__c,
        Project_Name__c,
        Strategic_Account__c,
       (Select Id, LastModifiedDate, Name, Requested_Delivery_Date__c, ccrz__ExtSKU__c, ccrz__UnitOfMeasure__c, ccrz__Quantity__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.MaterialDescription__c, Small_Order_Fee__c, ccrz__Comments__c,Agreement_Number__c,ccrz__ExtName__c from ccrz__E_CartItems__r) FROM ccrz__E_Cart__c WHERE ccrz__account__c=:effAccId and ccrz__ActiveCart__c = TRUE order by createddate desc LIMIT 1];
    }*/

    public static void addInvalidSku(Map<String, Object> productMap){

        List<Map<String, Object>> lineData = new List<Map<String, Object>>{
            new Map<String, Object>{
                ccrz.ccApiCart.LINE_DATA_SKU => 'requestedSku',
                ccrz.ccApiCart.LINE_DATA_QUANTITY => (Integer)productMap.get('qty'),
                ccrz.ccApiCart.LINE_DATA_PRICE => (Decimal)productMap.get('price'),
                ccrz.ccAPICart.LINE_DATA_EXT_NAME => (String)productMap.get('sku'),
                ccrz.ccAPICart.LINE_DATA_EXT_SKU => (String)productMap.get('sku'),

                'requestedPrice' => (Decimal)productMap.get('price'),
                'requestedSku' => (String)productMap.get('sku')
            }
        };

        Map<String, Object> cartItemsToAdd = new Map<String, Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ID => (Id)productMap.get('cartId'),
            ccrz.ccApiCart.LINE_DATA => lineData
        };

        Map<String, Object> addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);

        Map<String, Object> cartToSave = new Map<String, Object>{
            ccrz.ccApiCart.CART_ID => (Id)productMap.get('cartId'),
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
        };
        
        Map<String, Object> cartSaveResult = ccrz.ccApiCart.saveCart(cartToSave);
    }

    public static void convertItemToExtPricingAttr(String parentItemId, String cartId, SAP_Price_Agreement_Item__c paItem){
        List<ccrz__E_CartItem__c> cartItems = [SELECT Agreement_Number__c, ccrz__PricingType__c, ccrz__PrimaryAttr__r.Name, ccrz__Price__c, ccrz__SubAmount__c, ccrz__Quantity__c, ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_CartItem__c WHERE ccrz__ParentCartItem__c =: parentItemId];
        for(ccrz__E_CartItem__c item : cartItems){
            switch on item.ccrz__PrimaryAttr__r.Name {
                when 'BX' {
                    item.ccrz__Price__c = paItem.Price_Per_BX__c;
                }
                when 'CV' {
                    item.ccrz__Price__c = paItem.Price_Per_CV__c;
                }
                when 'EA' {
                    item.ccrz__Price__c = paItem.Price_Per_EA__c;
                }
                when 'ICV' {
                    item.ccrz__Price__c = paItem.Price_Per_ICV__c;
                }
                when 'PC' {
                    item.ccrz__Price__c = paItem.Price_Per_PC__c;
                }
                when else {
                    item.ccrz__Price__c = paItem.Price_Per_EA__c;
                }
            }
            item.ccrz__SubAmount__c = item.ccrz__Price__c * item.ccrz__Quantity__c;
            item.ccrz__ExtSKU__c = item.ccrz__Product__r.ccrz__SKU__c;
            item.ccrz__PricingType__c = 'external';
            item.Agreement_Number__c = paItem.Agreement_No__c;
        }
        update cartItems;
        
    }

    public static void addExtPricedItem(String cartId, String sku, Integer quantity, Decimal price){

        List<Map<String, Object>> lineData = new List<Map<String, Object>>{
            new Map<String, Object>{
                ccrz.ccApiCart.LINE_DATA_SKU => sku,
                ccrz.ccApiCart.LINE_DATA_QUANTITY => quantity,
                ccrz.ccApiCart.LINE_DATA_PRICE => price
            }
        };

        Map<String, Object> cartItemsToAdd = new Map<String, Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ID => cartId,
            ccrz.ccApiCart.LINE_DATA => lineData
        };

        Map<String, Object> addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);

        Map<String, Object> cartToSave = new Map<String, Object>{
            ccrz.ccApiCart.CART_ID => cartId,
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
        };
        
        Map<String, Object> cartSaveResult = ccrz.ccApiCart.saveCart(cartToSave);  
    }

    public static void convertItemToExtPricing(String cartItemId, String cartId, Decimal price){

        ccrz__E_CartItem__c cartItem = getCartItemById(cartItemId);
        system.debug('cartItem*********'+cartItem);
        system.debug('cartItem.ccrz__cartItemType__c**************'+cartItem.ccrz__cartItemType__c);
       if(cartItem.ccrz__cartItemType__c == 'Minor'){
           cartItem.ccrz__Price__c = price;
           cartItem.ccrz__ExtSKU__c = cartItem.ccrz__Product__r.ccrz__SKU__c;
           // cartItem.ccrz__ExtName__c = ccrz__Product__r.ccrz__SKU__c;
           //cartItem.ccrz__Quantity__c = 100;
           cartItem.ccrz__SubAmount__c = price*cartItem.ccrz__Quantity__c;
           cartItem.ccrz__PricingType__c = 'external';
           
           
           update cartItem;
           system.debug('cartItem**************'+cartItem);
       }

       else{
		   system.debug('cartItem.ccrz__ProductType__c***********'+cartItem.ccrz__ProductType__c);
           if(cartItem.ccrz__ProductType__c == 'Bundle'){

               List<Map<String, Object>> minorData = new List<Map<String, Object>>();
               for(ccrz__E_CartItem__c item : cartItem.ccrz__Cart_Items__r){
                   system.debug('cartItem.ccrz__Cart_Items__r***********'+cartItem.ccrz__Cart_Items__r);
                   minorData.add(new Map<String, Object>{
                       ccrz.ccApiCart.LINE_DATA_SKU => item.ccrz__Product__r.ccrz__SKU__c,
                       ccrz.ccApiCart.LINE_DATA_QUANTITY => item.ccrz__Quantity__c
                   });
                   system.debug('ccrz.ccApiCart.LINE_DATA_SKU*********'+ccrz.ccApiCart.LINE_DATA_SKU);
                   system.debug('ccrz.ccApiCart.LINE_DATA_QUANTITY*********'+ccrz.ccApiCart.LINE_DATA_QUANTITY);
               }

               List<Map<String, Object>> lineData = new List<Map<String, Object>>{
                   new Map<String, Object>{
                       ccrz.ccApiCart.LINE_DATA_SKU => cartItem.ccrz__Product__r.ccrz__SKU__c,
                       ccrz.ccApiCart.LINE_DATA_QUANTITY => 1,
                       ccrz.ccApiCart.LINE_DATA_PRICE => price,
                       ccrz.ccApiCart.LINE_DATA_MINOR_LINE_DATAS => minorData
                   }
               };
                   system.debug('ccrz.ccApiCart.LINE_DATA_SKU************'+ccrz.ccApiCart.LINE_DATA_SKU);
                   system.debug('ccrz.ccApiCart.LINE_DATA_QUANTITY************'+ccrz.ccApiCart.LINE_DATA_QUANTITY);
                   system.debug('ccrz.ccApiCart.LINE_DATA_PRICE***********'+ccrz.ccApiCart.LINE_DATA_PRICE);
               	   system.debug('ccrz.ccApiCart.LINE_DATA_MINOR_LINE_DATAS***********'+ccrz.ccApiCart.LINE_DATA_MINOR_LINE_DATAS);
           }
           

           List<Map<String, Object>> lineData = new List<Map<String, Object>>{
               new Map<String, Object>{
                   ccrz.ccApiCart.LINE_DATA_SKU => cartItem.ccrz__Product__r.ccrz__SKU__c,
                   ccrz.ccApiCart.LINE_DATA_QUANTITY => 1,
                   ccrz.ccApiCart.LINE_DATA_PRICE => price
               }
           };
               system.debug('ccrz.ccApiCart.LINE_DATA_SKU************'+ccrz.ccApiCart.LINE_DATA_SKU);
               system.debug('ccrz.ccApiCart.LINE_DATA_QUANTITY************'+ccrz.ccApiCart.LINE_DATA_QUANTITY);
               system.debug('ccrz.ccApiCart.LINE_DATA_PRICE***********'+ccrz.ccApiCart.LINE_DATA_PRICE);

           Map<String, Object> cartItemsToAdd = new Map<String, Object> {
               ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
               ccrz.ccApiCart.CART_ID => cartId,
               ccrz.ccApiCart.LINE_DATA => lineData
           };

           Map<String, Object> addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);
          system.debug('addToCartResults*********'+addToCartResults);

           Map<String, Object> cartToSave = new Map<String, Object>{
               ccrz.ccApiCart.CART_ID => cartId,
               ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
           };
           
           Map<String, Object> cartSaveResult = ccrz.ccApiCart.saveCart(cartToSave); 
           system.debug('cartToSave*************'+cartToSave);
       }
   }

    public static void changeAccount(String cartId, String accountId){
        ccrz__E_Cart__c cart = [SELECT ccrz__Account__c FROM ccrz__E_Cart__c WHERE Id =: cartId OR ccrz__EncryptedId__c =: cartId];
        if (accountId!=cart.ccrz__Account__c) {
            cart.ccrz__Account__c = accountId;
            update cart;
        }
    }

    
}