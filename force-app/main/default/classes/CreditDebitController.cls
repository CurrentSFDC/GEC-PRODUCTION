public without sharing class CreditDebitController {
    @AuraEnabled
     public static List<GE_LGT_EM_InvoiceLineItem__c> getInvoiceList(String invoiceId){
      List<GE_LGT_EM_InvoiceLineItem__c> invoiceList =  [Select GE_LGT_EM_SAP_Invoice_Number__c, 
              SKU__c,GE_LGT_EM_Customer_PO_Number__c,GE_LGT_EM_Invoiced_Quantity__c, GE_LGT_EM_Material_Description__c,
              GE_LGT_EM_Invoiced_Price__c,Extended_Amount__c,Reason_Code__c, Action_Override__c, Comment__c                                  
               From GE_LGT_EM_InvoiceLineItem__c where GE_LGT_EM_InvoiceHeaderNumber__c = :invoiceId];
          
         
        for(GE_LGT_EM_InvoiceLineItem__c Inv: invoiceList){
        Inv.Reason_Code__c = NULL;
        Inv.Action_Override__c= NULL;
        Inv.Comment__c= NULL;
       
        update Inv;
        }
 
        return invoiceList;   
    }
    
    @AuraEnabled
     public static List<GE_LGT_EM_InvoiceLineItem__c> getInvoiceItemRefList(String invoiceId){
      List<GE_LGT_EM_InvoiceLineItem__c> invoiceList =  [Select GE_LGT_EM_SAP_Invoice_Number__c, 
              SKU__c,GE_LGT_EM_Customer_PO_Number__c,GE_LGT_EM_Invoiced_Quantity__c,GE_LGT_EM_Material_Description__c,
              GE_LGT_EM_Invoiced_Price__c,Extended_Amount__c,Reason_Code__c, Action_Override__c, Comment__c                                  
               From GE_LGT_EM_InvoiceLineItem__c where GE_LGT_EM_InvoiceHeaderNumber__c = :invoiceId];
        
 
        return invoiceList;   
    }
    
    @AuraEnabled
    public static List<GE_LGT_EM_InvoiceLineItem__c> invoiceListData(String transId){
        
        return[Select GE_LGT_EM_SAP_Invoice_Number__c, 
              SKU__c,GE_LGT_EM_Customer_PO_Number__c,GE_LGT_EM_Invoiced_Quantity__c, GE_LGT_EM_Material_Description__c,
              GE_LGT_EM_Invoiced_Price__c,Extended_Amount__c,Reason_Code__c, Action_Override__c, Comment__c                                  
               From GE_LGT_EM_InvoiceLineItem__c  where Id = :transId];
    }
    
     @AuraEnabled
    public static string updateReturnItemList(Object data) {
      List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(data),List<Return_Order_Item__c>.class);
    try {
        upsert ReturnListForUpdate Unique_ID__c;
        return 'Success: Order Items updated successfully';
    }
    catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }}
    
    @AuraEnabled
    public static List<Return_Order_Item__c> getReturnList(String transId){
        System.debug('Transaction ID: '+ transId);
        
        return [Select Order_Line_Number__c, 
              SKU__c,PO__c,Quantity__c,
              UnitPrice__c,Extended_Amount__c,Reason_Code__c, Requested_Action_Override__c, Comments__c, Product_SKU__c, Transaction_Total__c,
                Transaction_ID__c
        FROM Return_Order_Item__c WHERE Transaction_ID__c =:transId];
    }
    
    @AuraEnabled
    
    public static String getAgentId(String AccountId){
        Account acc = [Select Account_Group__c,GE_LGT_EM_SAP_Customer_Number__c	 from Account where Id = :AccountId]; 
        
        return acc.GE_LGT_EM_SAP_Customer_Number__c;
    }

}