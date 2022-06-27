public with sharing class CCProductController {
	@AuraEnabled(cacheable=false)
    public static List<ccrz__E_Product__c> getproductList(String prodId){
        List<ccrz__E_Product__c> productList =  [Select MaterialDescription__c,              
               ccrz__ShortDescRT__c,
               ccrz__SKU__c,                              
               Quantity_Selected__c
               From ccrz__E_Product__c where Id = :prodId];
        
        for(ccrz__E_Product__c prod: productList){
        prod.Quantity_Selected__c = NULL;
        update prod;
        }
        return productList;             
        
    }
    
    @AuraEnabled(cacheable=false)
    public static List<ccrz__E_Product__c> getproductRefList(String prodId){
        List<ccrz__E_Product__c> productList =  [Select MaterialDescription__c,
               ccrz__ShortDescRT__c,
               ccrz__SKU__c,             
               Quantity_Selected__c
               From ccrz__E_Product__c where Id = :prodId];
        return productList;             
        
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> getReturnProdList(String transId){
        System.debug('Transaction ID: '+ transId);
        
        return [Select Product_SKU__c, Product_Description__c ,
            Selected_Qty__c   , Transaction_ID__c, SKU__c 
        FROM Return_Order_Item__c WHERE Transaction_ID__c =:transId];
    }

    @AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> getCollateralReturnProdList(String transId){
        System.debug('Transaction ID: '+ transId);
        
        return [Select Product_SKU__c, Product_Description__c ,
        Comments__c   , Transaction_ID__c, SKU__c 
        FROM Return_Order_Item__c WHERE Transaction_ID__c =:transId];
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> getReturnProdPriList(String transId){
        System.debug('Transaction ID: '+ transId);
        
        return [Select Product_SKU__c, 
            Selected_Qty__c   , Transaction_ID__c, SKU__c 
        FROM Return_Order_Item__c WHERE Transaction_ID__c =:transId];
    }
    
    
    @AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> getReturnOrderItemList(String prodId){
        List<ccrz__E_Product__c> trackList = [select ccrz__SKU__c from ccrz__E_Product__c where Id = :prodId];
        List<Return_Order_Item__c> newProdOrders = new List<Return_Order_Item__c>{};
        Set<String> skuIds = new Set<String>{};
        
        for (ccrz__E_Product__c tracker:trackList){
            
            if(tracker.ccrz__SKU__c != NULL) skuIds.add(tracker.ccrz__SKU__c);
            
        }
        
        if (skuIds.size() > 0){
     
            newProdOrders = [Select Product_SKU__c, 
               Product_Description__c ,
               Selected_Qty__c               
               From Return_Order_Item__c where Product_SKU__c=:skuIds];
        }
        
        return newProdOrders;
    }
    
    
    @AuraEnabled(cacheable=false)
    public static string updateReturnItemList(Object data) {
      List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(data),List<Return_Order_Item__c>.class);
      system.debug('List of Items passed form LWC: '+ data);
    try {
        upsert ReturnListForUpdate Unique_ID__c;
        return 'Success: Order Items updated successfully';
    }
    catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }}
    
}