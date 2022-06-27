public without sharing class OrderProductController {
	@AuraEnabled(cacheable=false)
    public static List<OrderItem> getOrderItemList(String orderId){
      List<OrderItem> orderList =  [Select orderId,
               Order_Line_Number__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               Disputed_Qty__c, 
               Product_Name__c,
               Quick_Configure__c, 
               Quick_Stock__c,
               Shipment_Date__c,
               Requested_Action_Override__c,
               PO__c,
               Date_Installed__c,
               No_Of_Products_Failed__c,
               Installed_Qty__c,
               Total_Returned__c,
               Available_for_Return__c,
               SKU_Description_Cat_Logic__c,
               Category_Of_Change__c,
               Reason_for_Change__c,
               Order.Agent_Account__c,
               Order.Customer_PO_Number__c,
               Order.Sold_To__c,
               Order.GE_Order_NO__c,
               Distributor_Name__c,
               UnitOfMeasure__c
               From OrderItem where orderId = :orderId ];
        
         /*for(OrderItem ord: orderList){
        ord.Disputed_Qty__c = NULL;
        ord.Requested_Action_Override__c= NULL;
        ord.No_Of_Products_Failed__c = NULL;
        ord.Installed_Qty__c = NULL;
        ord.Date_Installed__c = NULL;
        ord.Category_Of_Change__c = NULL;
        ord.Reason_for_Change__c = NULL;
        update ord;
        }*/
        return orderList;   
    }
    
   @AuraEnabled(cacheable=false)
   public static List<OrderItem> getOrderItemRefList(String orderId){
      List<OrderItem> orderList =  [Select orderId,
                                    SKU__c,
                                    Order_Line_Number__c, 
               Quantity, 
               UnitPrice,
               Disputed_Qty__c, 
               Product_Name__c,
               Quick_Configure__c, 
               Quick_Stock__c,
               Shipment_Date__c,
               Requested_Action_Override__c,
               PO__c,
               Date_Installed__c,
               No_Of_Products_Failed__c,
               Installed_Qty__c,
               Total_Returned__c,
               Category_Of_Change__c,
               Reason_for_Change__c,
               Available_for_Return__c,
               SKU_Description_Cat_Logic__c,
               Distributor_Name__c,
               UnitOfMeasure__c,
               Comments__c
               From OrderItem where orderId = :orderId ];
        
        return orderList;   
    }



    @AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> getReturnList(String transId){
        System.debug('Transaction ID: '+ transId);
        
        return [Select order__c, Current_Order__c, Material__c, Material_Description__c, No_Of_Products_Failed__c, Date_Installed__c, Installed_Qty__c, Product_SKU__c,PO__c,Quantity__c, Quick_Configure__c, Quick_Stock__c, Return_Qty__c,
        UnitPrice__c, SKU__c, Shipment_Date__c, Price_Agreement__c,	Is_the_product_shrink_wrapped__c, Transaction_ID__c, NoCAT__c, Comments__c, Requested_Action_Override__c, Distributor_Name__c, Transaction_Total__c, UnitOfMeasure__c, Distributor_Id__c, Invoice_Line__c, Invoice__c, SFDC_Invoice__c
        FROM Return_Order_Item__c WHERE Transaction_ID__c =:transId];
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> getReturnOrderItemList(String orderId){
        List<OrderItem> trackList = [select SKU__c from OrderItem where orderId = :orderId];
        List<Return_Order_Item__c> sortedOrders = new List<Return_Order_Item__c>{};
        Set<String> skuIds = new Set<String>{};
        
        for (OrderItem tracker:trackList){
            
            if(tracker.SKU__c != NULL) skuIds.add(tracker.SKU__c);
            
        }
        
        if (skuIds.size() > 0){
     
            sortedOrders = [Select Order__c,
            Product_SKU__c,
               SKU__c, 
               PO__c,
               Quantity__c, 
               UnitPrice__c, 
               Quick_Configure__c, 
               Quick_Stock__c,
               Shipment_Date__c,
               Return_Qty__c,
               Requested_Action_Override__c,
               Distributor_Name__c,
               UnitOfMeasure__c,
               Distributor_Id__c,
               Invoice_Line__c,
               SFDC_Invoice__c,
               No_Of_Products_Failed__c,
               Installed_Qty__c,
               Date_Installed__c,
               Comments__c,
               NoCAT__c,
               Price_Agreement__c,
               Is_the_product_shrink_wrapped__c
               From Return_Order_Item__c where SKU__c=:skuIds];
        }
        
        return sortedOrders;
    }
    
   /*@AuraEnabled(cacheable=false)
    public static string updateOrderItemList(Object data) {
    List<OrderItem> OrderItemForUpdate = (List<OrderItem>) JSON.deserialize(JSON.serialize(data),List<OrderItem>.class);
    try {
        update OrderItemForUpdate;
        return 'Success: Order Items updated successfully';
    }
    catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }}*/


  
    
    
     @AuraEnabled(cacheable=false)
    public static string updateReturnItemList(Object data) {
      List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(data),List<Return_Order_Item__c>.class);
    try {
        upsert ReturnListForUpdate Unique_ID__c;
        return 'Success: Order Items updated successfully';
    }
    catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }}
    
    
    
    @AuraEnabled(cacheable=false)
    public static string delReturnItems(Object data) {
    List<Return_Order_Item__c> ReturnListForDel = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(data),List<Return_Order_Item__c>.class);
    try {
        delete ReturnListForDel;
        return 'Success: Order Items Deleted successfully';
    }
    catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }}
    
	@AuraEnabled(cacheable=false)
    public static List<Return_Order_Item__c> displayUpdatedList(String transId){
        
        return[Select order__c,
        Product_SKU__c,
               SKU__c,
               PO__c,
               Quantity__c, 
               UnitPrice__c, 
               Quick_Configure__c, 
               Quick_Stock__c,
               Return_Qty__c,
               Shipment_Date__c,
               Requested_Action_Override__c,
               Distributor_Name__c,
               Transaction_ID__c,
               UnitOfMeasure__c,
               Distributor_Id__c,
               Invoice_Line__c,
               SFDC_Invoice__c,
               No_Of_Products_Failed__c,
               Installed_Qty__c,
               Date_Installed__c,
               Comments__c,
               NoCAT__c,
               Price_Agreement__c,
               Is_the_product_shrink_wrapped__c
               From Return_Order_Item__c where Transaction_ID__c = :transId];
    }
    
    	@AuraEnabled(cacheable=false)
    public static List<OrderItem> orderListData(String transId){
        
        return[Select OrderId,
               SKU__c, 
               Quantity, 
               UnitPrice,
               Disputed_Qty__c, 
               Product_Name__c,
               Quick_Configure__c, 
               Quick_Stock__c,
               Shipment_Date__c,
               Requested_Action_Override__c,
               PO__c,
               Date_Installed__c,
               No_Of_Products_Failed__c,
               Installed_Qty__c,
               Total_Returned__c,
               Available_for_Return__c,
               SKU_Description_Cat_Logic__c,
               Distributor_Name__c,
               UnitOfMeasure__c
               From orderItem where Id = :transId];
    }
    @AuraEnabled(cacheable=false)
    public static string updateOrderItemList(OrderItem data) {
  
        upsert data Id;
        return 'Success: Order Items updated successfully';
    }
    
     @AuraEnabled(cacheable=false)
    public static List<OrderItem> updDisName(String orderId, String disName) {
         List<OrderItem> oItemList =  [Select order.OrderNumber,
               Order_Line_Number__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c,
               Category_Of_Change__c,
               New_Shipment_Date__c,
               Reason_for_Change__c,
               Distributor_Name__c,
               UnitOfMeasure__c
               From OrderItem where orderId = :orderId ];
        
        for(OrderItem ord: oItemList){
        ord.Distributor_Name__c = disName;
        ord.Disputed_Qty__c = NULL;
        ord.Requested_Action_Override__c= NULL;
        ord.No_Of_Products_Failed__c = NULL;
        ord.Installed_Qty__c = NULL;
        ord.Date_Installed__c = NULL;
        update ord;
        }
    
        
        return oItemList; 
    }
@AuraEnabled
public static List<Order> getOrderId(String orderNumber){
    List<Order> orderInfo =  [Select Id,
    Customer_PO_Number__c,
    GE_Order_NO__c,
    Sold_To__r.Name,
    Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c,
    Sold_To__r.Customer_Segmentation__c,
    Sold_To__c,
    Agent_Account__c
   FROM Order where GE_Order_NO__c LIKE : orderNumber];


return orderInfo; 
    
    
    
    
    /*Order getOrder = [SELECT Id FROM Order WHERE GE_Order_NO__c LIKE : orderNumber];

    String orderId = getOrder.Id;
    if(orderId != null){
        return orderId;
    } else  {
        return '';
    }*/
}

@AuraEnabled(cacheable=false)
public static List<Order> getOrderDetails(String orderId){
  List<Order> orderInfo =  [Select Id,
            Customer_PO_Number__c,
            GE_Order_NO__c,
            Sold_To__r.Name,
            Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c,
            Sold_To__r.Customer_Segmentation__c,
            Sold_To__c,
            Agent_Account__c,
            Agent_Account__r.GE_LGT_Rep_Code__c
           FROM Order where Id = :orderId ];

    
    return orderInfo; 
}

    

}