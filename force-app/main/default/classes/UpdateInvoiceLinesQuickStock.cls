public with sharing class UpdateInvoiceLinesQuickStock {
    public void assignQuickStockFlag(List<Sales_Org_Product__c> salesOrgProd) {

        
          List<GE_LGT_EM_InvoiceLineItem__c> updateInv = new List<GE_LGT_EM_InvoiceLineItem__c>();
          

          for(Sales_Org_Product__c sop : salesOrgProd){
            List<GE_LGT_EM_InvoiceLineItem__c> invMap = [SELECT Id, SKU__c, Header_Sales_Org__c  FROM GE_LGT_EM_InvoiceLineItem__c WHERE SKU__c = :sop.SKU__c AND Header_Sales_Org__c =: sop.Sales_Org_Agent__c  ];
          
            for(GE_LGT_EM_InvoiceLineItem__c inv : invMap){
                inv.QuickStock__c = sop.QuickStock__c;
                updateInv.add(inv);
            }
        
        }

        Database.update(updateInv);

    }
}