public with Sharing class ExpediteOrderProdController {
    @AuraEnabled(cacheable=false)
	public static List<OrderItem> getExpOItemList(String orderId){
      List<OrderItem> oItemList =  [Select Order.OrderNumber,
               Order_Line_Number__c,
           	   Order.GE_Order_NO__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c, 
               Requested_Delivery_Date__c,
               Expected_Shipment_Date__c,               
               Ship_From__c,
               New_Requested_Delivery_Date__c,
               RequestedDeliveryDate__c,
               SKU_Description_Cat_Logic__c,
               Distributor_Name__c,
               /*Order_Req_Delivery_Date__c,
               Order_Ship_From__c,
               Order_Expected_Ship_Date__c,
               account.name,
               sold_To__r.name,                   
               accountId,
               Ship_Complete__c*/   
                UnitOfMeasure__c,
               Order.Order_Req_Delivery_Date__c,
               Order.Order_Ship_From__c,
               Order.Order_Expected_Ship_Date__c,
               Order.account.name,
               Order.sold_To__r.name,
               Order.Agent_Account__c,                   
               Order.accountId,
               Order.Ship_Complete__c,
               Order.Customer_PO_Number__c
               From OrderItem where orderId = :orderId ];
        
        for(OrderItem ord: oItemList){
        ord.New_Requested_Delivery_Date__c= NULL;        
        update ord;
        }
        
        return oItemList; 
    } 
    
   @AuraEnabled(cacheable=false)
   public static List<OrderItem> getExpOItemRefList(String orderId){
      List<OrderItem> orderList =  [Select Order_Line_Number__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c, 
               Requested_Delivery_Date__c,
               Expected_Shipment_Date__c,               
               Ship_From__c ,
               New_Requested_Delivery_Date__c,
               RequestedDeliveryDate__c,
               SKU_Description_Cat_Logic__c,
               Distributor_Name__c,
               UnitOfMeasure__c
               From OrderItem where orderId = :orderId];
        
        return orderList;   
    }
    
      @AuraEnabled(cacheable=false)
   public static List<OrderItem> getExpOItemNewList(String transId){
      List<OrderItem> orderList =  [Select Order_Line_Number__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c, 
               Requested_Delivery_Date__c,
               Expected_Shipment_Date__c,               
               Ship_From__c ,
               New_Requested_Delivery_Date__c,
               RequestedDeliveryDate__c,
               SKU_Description_Cat_Logic__c,
               Distributor_Name__c,
               UnitOfMeasure__c
               From OrderItem where Id = :transId];
        
        return orderList;   
    }
    
    
    @AuraEnabled(cacheable=false)
    public static string updateExpReturnItemList(Object data) {
      List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(data),List<Return_Order_Item__c>.class);
    try {
        upsert ReturnListForUpdate Unique_ID__c;
        return 'Success: Order Items updated successfully';
    }
    catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }}
    
     @AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> getReturnList(String transId){
        System.debug('Transaction ID: '+ transId);
        
        return [Select Order_Line_Number__c,Product_SKU__c,PO__c,Quantity__c, Quick_Configure__c,
        UnitPrice__c, SKU__c, Ship_From__c, Transaction_ID__c, Requested_Delivery_Date__c, Expected_Shipment_Date__c, New_Requested_Delivery_Date__c,Distributor_Name__c,
        UnitOfMeasure__c
        FROM Return_Order_Item__c WHERE Transaction_ID__c =:transId];
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> getReturnOItmList(String orderId){
        List<OrderItem> trackList = [select SKU__c from OrderItem where orderId = :orderId];
        List<Return_Order_Item__c> sortedOrders = new List<Return_Order_Item__c>{};
        Set<String> skuIds = new Set<String>{};
        
        for (OrderItem tracker:trackList){
            
            if(tracker.SKU__c != NULL) skuIds.add(tracker.SKU__c);
            
        }
        
        if (skuIds.size() > 0){
     
            sortedOrders = [Select Order_Line_Number__c,
               SKU__c, 
               Quantity__c, 
               UnitPrice__c,
               PO__c, 
               Requested_Delivery_Date__c,
               Expected_Shipment_Date__c,               
               Ship_From__c ,
               New_Requested_Delivery_Date__c,
               Distributor_Name__c,
               UnitOfMeasure__c
               From Return_Order_Item__c where SKU__c=:skuIds];
        }
        
        return sortedOrders;
    }
    
      @AuraEnabled(cacheable=false)
    public static List<OrderItem> updDisName(String orderId, String disName) {
         List<OrderItem> oItemList =  [Select Order.OrderNumber,
               Order_Line_Number__c,
               Order.GE_Order_NO__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c, 
               Requested_Delivery_Date__c,
               Expected_Shipment_Date__c,               
               Ship_From__c,
               New_Requested_Delivery_Date__c,
               RequestedDeliveryDate__c,
               SKU_Description_Cat_Logic__c,
               Distributor_Name__c,
               UnitOfMeasure__c,
               /*Order_Req_Delivery_Date__c,
               Order_Ship_From__c,
               Order_Expected_Ship_Date__c,
               account.name,
               sold_To__r.name,                   
               accountId,
               Ship_Complete__c*/   

               Order.Order_Req_Delivery_Date__c,
               Order.Order_Ship_From__c,
               Order.Order_Expected_Ship_Date__c,
               Order.account.name,
               Order.sold_To__r.name,
               Order.Agent_Account__c,                   
               Order.accountId,
               Order.Ship_Complete__c
               From OrderItem where orderId = :orderId ];
        
        for(OrderItem ord: oItemList){
        ord.Distributor_Name__c = disName;
        ord.New_Requested_Delivery_Date__c = NULL;
     
        update ord;
        }
    
        
        return oItemList; 
    }
}