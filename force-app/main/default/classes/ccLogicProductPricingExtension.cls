/********************************************************************
Purpose: Extend ccLogicProductPricing to allow sorting by available inventory on the Product List Page

History:
--------
VERSION  AUTHOR       DATE         DESCRIPTION
1.0      Alex Bowser  26-OCT-2020  Created
*/
global with sharing class ccLogicProductPricingExtension extends ccrz.ccLogicProductPricing{

    global virtual override Map<String,Object> evaluatePricing(Map<String,Object> inputData){
        List<Map<String,Object>> productList = (List<Map<String,Object>>)inputData.get(ccrz.ccApiProduct.PRODUCTLIST);
        for (Map<String,Object> productData: productList){
            if(productData.containsKey('productInventoryItemsS')){
                List<Map<String,Object>> productInventoryItemsList = (List<Map<String,Object>>)productData.get('productInventoryItemsS');
                Decimal quantityAvailable = 0;
                for (Map<String,Object> inventoryItem: productInventoryItemsList){
                    quantityAvailable += (Decimal)inventoryItem.get('qtyAvailable');
                }
            //productData.put('inventoryAvailable',quantityAvailable);
            }
        }
        inputData.put(ccrz.ccApiProduct.PRODUCTLIST,productList);
        return super.evaluatePricing(inputData);
    }
}