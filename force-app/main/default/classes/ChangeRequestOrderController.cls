public class ChangeRequestOrderController {
    
    
     @AuraEnabled(cacheable=false)
	public static List<OrderItem> getChangeRequestOItem(String orderId){
      List<OrderItem> oItemList =  [Select order.OrderNumber,
               Order_Line_Number__c,
          	   order.GE_Order_NO__c,
                order.Sold_To__r.Name,
                order.Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c,
                order.Sold_To__r.Customer_Segmentation__c,
               UnitOfMeasure__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c,
               SKU_Description_Cat_Logic__c,
               Category_Of_Change__c,
               New_Shipment_Date__c,
               Reason_for_Change__c,
               Order.Customer_PO_Number__c,
               Distributor_Name__c
               From OrderItem where orderId = :orderId ];
    
        
        return oItemList; 
    } 
    
      @AuraEnabled(cacheable=false)
	public static List<OrderItem> getChangeReqRefList(String orderId){
      List<OrderItem> oItemList =  [Select order.OrderNumber,
               Order_Line_Number__c,
               order.GE_Order_NO__c,
               UnitOfMeasure__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c,
               Category_Of_Change__c,
               SKU_Description_Cat_Logic__c,
               New_Shipment_Date__c,
               Reason_for_Change__c,
               Distributor_Name__c
               From OrderItem where orderId = :orderId ];  
        return oItemList; 
    } 
    
        @AuraEnabled(cacheable=false)
	public static List<OrderItem> getChangeReqUpdItem(String transId){
      List<OrderItem> oItemListNew =  [Select order.OrderNumber,
               Order_Line_Number__c,
               order.GE_Order_NO__c,
               UnitOfMeasure__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c,
               SKU_Description_Cat_Logic__c,
               Category_Of_Change__c,
               New_Shipment_Date__c,
               Reason_for_Change__c,
               Distributor_Name__c
               From OrderItem where Id = :transId ];
    
        
        return oItemListNew; 
    } 
    
      @AuraEnabled(cacheable=false)
	public static List<Return_Order_Item__c> getChangeReqCartItem(String transId){
     return[Select 
            Order_Line_Number__c,
            UnitOfMeasure__c,
            SKU__c, 
            Quantity__c, 
            UnitPrice__c,
            PO__c,
            Product_SKU__c,
            Category_Of_Change__c,
            New_Shipment_Date__c,
            Reason_for_Change__c,
            Distributor_Name__c,
            Distributor_Id__c,
            Transaction_ID__c,
            Order_Product_Id__c 
            From Return_Order_Item__c where Transaction_ID__c = :transId ];
    
    } 
    
       @AuraEnabled(cacheable=false)
    public static string updReturnItemList(Object data) {
      List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(data),List<Return_Order_Item__c>.class);
    try {
        upsert ReturnListForUpdate Unique_ID__c;
        return 'Success: Return List updated successfully';
    }
    catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }}
    
    @AuraEnabled(cacheable=false)
    public static List<OrderItem> updDisName(String orderId, String disName) {
         List<OrderItem> oItemList =  [Select order.OrderNumber,
               Order_Line_Number__c,
               order.GE_Order_NO__c,
               UnitOfMeasure__c,
               SKU__c, 
               Quantity, 
               UnitPrice,
               PO__c,
               SKU_Description_Cat_Logic__c,
               Category_Of_Change__c,
               New_Shipment_Date__c,
               Reason_for_Change__c,
               Distributor_Name__c
               From OrderItem where orderId = :orderId ];
        
        for(OrderItem ord: oItemList){
        ord.Distributor_Name__c = disName;
        ord.Category_Of_Change__c = NULL;
        ord.New_Shipment_Date__c = NULL;
        ord.Reason_for_Change__c = NULL;
        update ord;
        }
    
        
        return oItemList; 
    }
    

}