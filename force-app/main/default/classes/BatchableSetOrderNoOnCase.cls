/**
 * Created by PA on 2021. 06. 28..
 */

global with sharing class BatchableSetOrderNoOnCase implements Database.Batchable<SObject> {

    List<Order> orders = new List<Order>();

    global BatchableSetOrderNoOnCase(List<Order> newOrders){
        orders = newOrders;
    }

    public List<Order> start(Database.BatchableContext param1) {
        return orders;
    }

    public void execute(Database.BatchableContext bc, List<Order> newOrders) {
        Set<String> usedCaseIds = new Set<String>();
        List<Case> casesToUpdate = new List<Case>();
        for (Order o : newOrders){
            if (o.RelatedCaseId__c != null && !usedCaseIds.contains(o.RelatedCaseId__c)) {
                casesToUpdate.add(new Case(Id = o.RelatedCaseId__c, GE_LGT_EM_SAP_Order_Number__c = o.GE_Order_NO__c));
                usedCaseIds.add(o.RelatedCaseId__c);
            }
        }
        Database.update(casesToUpdate, false);
    }

    public void finish(Database.BatchableContext param1) {
    }
}