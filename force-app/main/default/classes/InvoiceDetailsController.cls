/*----------------------------------------------------------------------
Name:       InvoiceDetailsController.cls
Purpose:    Controller for Invoice Tabs
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Nate            13-Jan-2021             Initial Development 
----------------------------------------------------------------------*/


public with sharing class InvoiceDetailsController {

 
    @AuraEnabled(cacheable=true)
    public static List<InvoiceLineItems> getInvoiceDetails(String invoiceId){
       
        Warehouse__mdt[] warehouseRecords = [Select Code__c, Order_Cutoff__c, Location__c from Warehouse__mdt];


        List<GE_LGT_EM_InvoiceLineItem__c> invoiceItems =  [SELECT GE_LGT_EM_Complaint_LineItemNo__c,
                                                                GE_LGT_EM_Complaint_Number__c,
                                                                CurrencyIsoCode,
                                                                GE_LGT_EM_Customer_PO_Number__c,
                                                                GE_LGT_EM_Delivery_Plant__c,
                                                                GE_LGT_EM_Dispute_Flag__c,
                                                                Name,
                                                                GE_LGT_EM_Invoiced_Price__c,
                                                                GE_LGT_EM_Invoiced_Price_Unit__c,
                                                                GE_LGT_EM_Invoiced_Quantity__c,
                                                                GE_LGT_EM_InvoicedValue__c,
                                                                GE_LGT_EM_Material__c,
                                                                GE_LGT_EM_Material_Description__c,
                                                                GE_LGT_EM_Order_Number__c,
                                                                GE_LGT_EM_Sales_Unit__c,
                                                                GE_LGT_EM_SAP_Invoice_Number__c,
                                                                GE_LGT_EM_SAP_LineItemNumber__c,
                                                                GE_LGT_EM_Customer_Material_Number__c,
                                                                SKU__c,
                                                                GE_LGT_EM_Payer_Sold_to_Account_Number__c,
                                                                GE_LGT_EM_Tax_Number_1__c
                                                        FROM GE_LGT_EM_InvoiceLineItem__c
                                                        WHERE GE_LGT_EM_InvoiceHeaderNumber__c =: invoiceId];

        // needs to be created
        List<InvoiceLineItems> invoiceLineItems = new List<InvoiceLineItems>();
        if(invoiceItems != null && invoiceItems.size() > 0){

            for (GE_LGT_EM_InvoiceLineItem__c ia : invoiceItems){
                InvoiceLineItems invItem = new InvoiceLineItems();
                invItem.compliantLineItemNumber = ia.GE_LGT_EM_Complaint_LineItemNo__c;
                invItem.compliantNum = ia.GE_LGT_EM_Complaint_Number__c;
                invItem.isoCurrency =  ia.CurrencyIsoCode;
                invItem.deliveryPlant = getWarehouseLocation(warehouseRecords, ia.GE_LGT_EM_Delivery_Plant__c);
                invItem.invoiceLineItemName =  ia.Name;
                invItem.invoicedPrice =  String.valueOf(ia.GE_LGT_EM_Invoiced_Price__c);
                invItem.invoicedPriceUnit = String.valueOf(ia.GE_LGT_EM_Invoiced_Price_Unit__c);
                invItem.invoicedQuantity =  String.valueOf(ia.GE_LGT_EM_Invoiced_Quantity__c);
                invItem.invoicedValue = String.valueOf(ia.GE_LGT_EM_InvoicedValue__c);
                invItem.material = ia.GE_LGT_EM_Material__c;
                invItem.materialDescription =  ia.GE_LGT_EM_Material_Description__c;
                invItem.orderNumber = ia.GE_LGT_EM_Order_Number__c;
                invItem.salesUnit = ia.GE_LGT_EM_Sales_Unit__c;
                invItem.sapInvoiceNumber = ia.GE_LGT_EM_SAP_Invoice_Number__c;
                invItem.sapLineItemNumber = String.valueOf(ia.GE_LGT_EM_SAP_LineItemNumber__c);
                invItem.sapMaterialNumber = ia.GE_LGT_EM_Customer_Material_Number__c;
                invItem.sku = ia.SKU__c;
                invItem.soldToAccountNumer = ia.GE_LGT_EM_Payer_Sold_to_Account_Number__c;
                invItem.taxAmount = ia.GE_LGT_EM_Tax_Number_1__c;
                
                invoiceLineItems.add(invItem);
            }
        }

        return invoiceLineItems;
    }


    public class InvoiceLineItems {
        @AuraEnabled
        public String compliantLineItemNumber {get;set;}
        @AuraEnabled
        public String compliantNum {get;set;}
        @AuraEnabled
        public String isoCurrency {get;set;}
        @AuraEnabled
        public String deliveryPlant {get;set;}
        @AuraEnabled
        public String invoiceLineItemName {get;set;}
        @AuraEnabled
        public String invoicedPrice {get;set;}
        @AuraEnabled
        public String invoicedPriceUnit {get;set;}
        @AuraEnabled
        public String invoicedQuantity {get;set;}
        @AuraEnabled
        public String invoicedValue {get;set;}
        @AuraEnabled
        public String material {get;set;}
        @AuraEnabled
        public String materialDescription {get;set;}
        @AuraEnabled
        public String orderNumber {get;set;}
        @AuraEnabled
        public String salesUnit {get;set;}
        @AuraEnabled
        public String sapInvoiceNumber {get;set;}
        @AuraEnabled
        public String sapLineItemNumber {get;set;}
        @AuraEnabled
        public String sapMaterialNumber {get;set;}
        @AuraEnabled
        public String sku {get;set;}
        @AuraEnabled
        public String soldToAccountNumer {get;set;}
        @AuraEnabled
        public String taxAmount {get;set;}
        
    }

    private static String getWarehouseLocation(Warehouse__mdt[] warehouseRecords, String orderShipFromLocation){
		String warehouseLocation = '';		
		if(String.isNotBlank(orderShipFromLocation)){
			for(Warehouse__mdt record:warehouseRecords) {                
				if(orderShipFromLocation == record.Code__c){
					warehouseLocation = record.Location__c;
					break;
				}                       
			}
		}
		return warehouseLocation;
	}


}