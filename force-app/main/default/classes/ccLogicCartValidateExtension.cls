global class ccLogicCartValidateExtension extends ccrz.ccLogicCartValidate {
    global virtual override Map<String, Object> processValidate(Map<String, Object> inputData) {
        ccrz.ccLog.log(LoggingLevel.INFO, 'ccLogicCartValidateExtension:inputData',inputData);
        // Map<String, Object> cartFetchQuery = new Map<String, Object>(inputData);
        // cartFetchQuery.put(ccrz.ccApi.SIZING, new Map<String, Object> {
        //     ccrz.ccApiCart.ENTITYNAME => new Map<String, Object> {
        //         ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S,
        //         ccrz.ccApi.SZ_ASSC => false,
        //         ccrz.ccApi.SZ_SKIPTRZ => false
        //     }
        // });
        // Map<String, Object> cartFetchData = ccrz.ccApiCart.fetch(cartFetchQuery);
        // Integer cartItemCount = 0;
        // for(Map<String, Object> fetchedCart : (List<Map<String, Object>>)cartFetchData.get(ccrz.ccApiCart.CART_OBJLIST)) {
        //     List<Object> fetchedCartItems = (List<Object>)fetchedCart.get('ECartItemsS');
        //     if (null != fetchedCartItems) {
        //         cartItemCount += fetchedCartItems.size();
        //     }
        // }
        //inputData.put(ccrz.ccApiCart.ALLOW_CHECKOUT, true);

        // inputData.put('cartItemCount', cartItemCount);
        //inputData.putAll(ccrz.ccApiCart.fetch(inputData));
        

        return super.processValidate(inputData);
    }

    global virtual override Map<String, Object> processInput(Map<String, Object> inputData){
        ccrz.ccLog.log(LoggingLevel.INFO, 'ccLogicCartValidateExtension:processInput:inputData',inputData);
        Map<String, Object> cartFetchQuery = new Map<String, Object>(inputData);
         cartFetchQuery.put(ccrz.ccApi.SIZING, new Map<String, Object> {
             ccrz.ccApiCart.ENTITYNAME => new Map<String, Object> {
                 ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S,
                 ccrz.ccApi.SZ_ASSC => false,
                 ccrz.ccApi.SZ_SKIPTRZ => false
             }
         });
        Map<String, Object> cartFetchData;
        if(Test.isRunningTest()){
            cartFetchData = new Map<String, Object>{
                ccrz.ccApiCart.CART_OBJLIST => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'ECartItemsS' => new List<Object>{
                            
                        }
                    }
                }
            };
        }
        else{
            cartFetchData = ccrz.ccApiCart.fetch(cartFetchQuery);
        }
        Integer cartItemCount = 0;
        for(Map<String, Object> fetchedCart : (List<Map<String, Object>>)cartFetchData.get(ccrz.ccApiCart.CART_OBJLIST)) {
            List<Object> fetchedCartItems = (List<Object>)fetchedCart.get('ECartItemsS');
            ccrz.ccLog.log(LoggingLevel.INFO, 'ccLogicCartValidateExtension:processInput:fetchedCartItems',fetchedCartItems);
        }
        return super.processInput(inputData);
    }
}