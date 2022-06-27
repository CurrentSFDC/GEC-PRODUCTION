trigger updateInvLinesQuickStockField on Sales_Org_Product__c (after update) {

    if (Trigger.isUpdate&& Trigger.isAfter) {
     for (Sales_Org_Product__c sop : System.Trigger.new){
         if(system.trigger.OldMap.get(sop.Id).QuickStock__c != system.trigger.NewMap.get(sop.Id).QuickStock__c)
         {
              new UpdateInvoiceLinesQuickStock().assignQuickStockFlag(Trigger.new);   
         }
     }
     }
     }