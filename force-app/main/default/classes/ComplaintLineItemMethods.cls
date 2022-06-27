/***********************************************************************************************
*   Class Name      : ComplaintLineItemMethods
*   Date            : 6/21/2017
*   Author          : Pavan Kumar
*   Object          : ComplaintLineItem
*   Purpose         : These methods fire on ComplaintLineItem.
*   Test Class      : ComplaintLineItemTrigger_Test
**************************************************************************************************/

public class ComplaintLineItemMethods {

    //Contain methods to invoke "before insert" Event On ComplaintLineItem
    public static void methodsToInvokeOnBeforeInsert(List<GE_LGT_EM_ComplaintLineItem__c > newCLIList){
        ComplaintLineItemHelper.updateComplaintReferenceNumber(newCLIList);
        ComplaintLineItemHelper.checkRelevant(newCLIList, null, null, null);
    }
    //Contain methods to invoke "before update" Event On ComplaintLineItem
    public static void methodsToInvokeOnBeforeUpdate(List<GE_LGT_EM_ComplaintLineItem__c > newCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > newCLIMap,List<GE_LGT_EM_ComplaintLineItem__c > oldCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > oldCLIMap){
        ComplaintLineItemHelper.checkRelevant(newCLIList, newCLIMap, oldCLIList, oldCLIMap);
    }
    //Contain methods to invoke "after insert" Event On ComplaintLineItem
    public static void methodsToInvokeOnAfterInsert(List<GE_LGT_EM_ComplaintLineItem__c > newCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c> newCLIMap){
        ComplaintLineItemHelper.callFlaggingDispute(newCLIList, newCLIMap);
        ComplaintLineItemHelper.updateInvoiceLineItem(newCLIList, newCLIMap, null, true);
    }
    //Contain methods to invoke "after update" Event On ComplaintLineItem
    public static void methodsToInvokeOnAfterUpdate(List<GE_LGT_EM_ComplaintLineItem__c > newCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > newCLIMap,List<GE_LGT_EM_ComplaintLineItem__c > oldCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > oldCLIMap){
        ComplaintLineItemHelper.callCrediCardDemo(newCLIList, newCLIMap, oldCLIList, oldCLIMap);
        ComplaintLineItemHelper.updateInvoiceLineItem(newCLIList, newCLIMap, oldCLIList, false);
    }
    //Contain methods to invoke "after delete" Event On ComplaintLineItem
    public static void methodsToInvokeOnAfterDelete(List<GE_LGT_EM_ComplaintLineItem__c > oldCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > oldCLIMap){
        ComplaintLineItemHelper.updateInvoiceLineItem(oldCLIList, oldCLIMap, null, false);
    }
}