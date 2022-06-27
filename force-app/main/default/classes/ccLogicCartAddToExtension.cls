global class ccLogicCartAddToExtension extends ccrz.ccLogicCartAddTo {

    private final static String REQUESTED_SKU = 'requestedSku';

    global virtual override Map<String, Object> addMajorLineItems(Map<String, Object> inputData){
        system.debug(inputData);
        Map<String, Object> outputData= super.addMajorLineItems(inputData);
        system.debug(outputData);
        return outputData;
    }

    global virtual override Map<String, Object> priceExternalItem(Map<String, Object> inputData) {
        Map<String, Object> lineData = (Map<String, Object>)inputData.get(ccrz.ccApiCart.CURR_LINE_DATA);
        ccrz__E_CartItem__c curCartItem = (ccrz__E_CartItem__c)inputData.get(ccrz.ccApiCart.CURR_CARTITEM);
        system.debug(lineData);
        system.debug(curCartItem);
        String pricingType='';
        if(lineData.containsKey('majorCartItem')){
            pricingType = (String)(((ccrz__E_CartItem__c)lineData.get('majorCartItem')).ccrz__PricingType__c);
        }

            if(Test.isRunningTest()){
                inputData.put('cartId',((ccrz__E_CartItem__c)inputData.get('currItem')).ccrz__Cart__c);
            }
            List<ccrz__E_CartItem__c> existingItems = CartServices.getCartItemExtSkusByCartId((String)inputData.get('cartId'));
            Boolean isDuplicateItem = false;
            for(ccrz__E_CartItem__c item : existingItems){

                if(item.ccrz__ExtSKU__c == (String)lineData.get(ccrz.ccApiCart.LINE_DATA_EXT_SKU ) 
                    && item.ccrz__Product__r.ccrz__SKU__c == (String)lineData.get(ccrz.ccApiCart.LINE_DATA_SKU)
                    && pricingType != 'attrGroup'){

                        ccrz.ccLog.log('alexdebug'+lineData);

                        if((String)lineData.get(ccrz.ccApiCart.LINE_DATA_SKU) == REQUESTED_SKU){ 
                            item.ccrz__Quantity__c += curCartItem.ccrz__Quantity__c;
                        }
                        else{
                            item.ccrz__Price__c = curCartItem.ccrz__Price__c;     
                        }

                        inputData.put(ccrz.ccApiCart.CURR_CARTITEM, item);
                        isDuplicateItem = true;
                }
            }
            
            if(!isDuplicateItem){
                    curCartItem.ccrz__ExtName__c = (String)lineData.get(ccrz.ccApiCart.LINE_DATA_EXT_NAME);
                    curCartItem.ccrz__ExtSKU__c = (String)lineData.get(ccrz.ccApiCart.LINE_DATA_EXT_SKU );
                    curCartItem.ccrz__Price__c	 = (Decimal)lineData.get(ccrz.ccApiCart.LINE_DATA_PRICE );
                    curCartItem.ccrz__PricingType__c = 'external';
                    //curCartItem.ccrz__Subtotal__c = (Decimal)lineData.get(ccrz.ccApiCart.LINE_DATA_PRICE);
            }

        
        return super.priceExternalItem(inputData);      
    }

    global override Map<String, Object> setCartItemFields(Map<String, Object> inputData) {
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ccLogicCartAddToExtenison:setCartItemFields:inputData', inputData); 
        try {
            ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) inputData.get(ccrz.ccApiCart.CURR_CARTITEM);
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'ccLogicCartAddToExtenison:setCartItemFields', cartItem);
        } catch (Exception ex) {
			ccrz.ccLog.log(LoggingLevel.ERROR, 'b2b_LogicCartAddTo:ERR', ex);
		} finally {
			inputData = super.setCartItemFields(inputData);
		}

		return inputData;
	}
}