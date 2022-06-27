/********************************************************************
Purpose: Controller for orderSearch component. Searches for Order records based on search string. 
        Calls ReorderHelper to repeat past orders.

History:
--------
VERSION  AUTHOR       DATE         DESCRIPTION
1.0      Alex Bowser  3-NOV-2020  Created
*/
public class OrderSearchController {
    @AuraEnabled
    public static List<sObject> searchForOrders(String searchText, String startDateStr, String endDateStr) {

        Date startDate = Date.valueOf(startDateStr);
        Date endDate = Date.valueOf(endDateStr);

        startDate = startDate.addDays(1);
        endDate = endDate.addDays(1);

        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, ContactId, Account.GE_LGT_Rep_Code__c, Account.Id FROM User WHERE Id = : userId];
        Id getContactId = u.contactId;

        List<Id> relatedAccountIds = new List<Id>();
        for(AccountContactRelation relation : [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :getContactId]){
            relatedAccountIds.add(relation.AccountId);
        }

        String searchString = '%'+searchText+'%';
        List<sObject> results = new List<sObject>();

        if(u.Account.GE_LGT_Rep_Code__c == '' || u.Account.GE_LGT_Rep_Code__c == null){
            //user is distributor
            results = [SELECT Id, Account.Name, SFDC_Order_number__c, sold_to__r.Name, GBSTK__c, 
                            Customer_PO_Number__c, GE_Order_NO__c, TotalAmount, createdDate, Status, EffectiveDate 
                            FROM Order  
                            WHERE (SFDC_Order_number__c LIKE :searchString
                            OR sold_to__r.Name LIKE :searchString
                            OR Customer_PO_Number__c LIKE :searchString
                            OR GE_Order_NO__c LIKE :searchString)
                            AND EffectiveDate >= :startDate 
                            AND EffectiveDate <= :endDate 
                            AND Sold_to__c = :u.Account.Id
                            ORDER BY EffectiveDate DESC];
        }
        else{
            //user is agent
            results = [SELECT Id, Account.Name, SFDC_Order_number__c, sold_to__r.Name, GBSTK__c, 
                            Customer_PO_Number__c, GE_Order_NO__c, TotalAmount, createdDate, Status, EffectiveDate 
                            FROM Order 
                            WHERE (SFDC_Order_number__c LIKE :searchString
                            OR sold_to__r.Name LIKE :searchString
                            OR Customer_PO_Number__c LIKE :searchString
                            OR GE_Order_NO__c LIKE :searchString)
                            AND EffectiveDate >= :startDate 
                            AND EffectiveDate <= :endDate 
                            AND Sold_to__c IN :relatedAccountIds
                            AND Agent_rep_code__c = :u.Account.GE_LGT_Rep_Code__c
                            ORDER BY EffectiveDate DESC];
        }
        return results;
    }

    @AuraEnabled
    public static List<sObject> initOrders(String startDateStr, String endDateStr){

        Date startDate = Date.valueOf(startDateStr);
        Date endDate = Date.valueOf(endDateStr);

        startDate = startDate.addDays(1);
        endDate = endDate.addDays(1);

        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, ContactId, Account.GE_LGT_Rep_Code__c, Account.Id FROM User WHERE Id = : userId];
        Id getContactId = u.contactId;

        List<Id> relatedAccountIds = new List<Id>();
        for(AccountContactRelation relation : [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :getContactId]){
            relatedAccountIds.add(relation.AccountId);
        }

        List<sObject> results = new List<sObject>();

        if(u.Account.GE_LGT_Rep_Code__c == '' || u.Account.GE_LGT_Rep_Code__c == null){
            //user is distributor
            results = [SELECT Id, Account.Name, SFDC_Order_number__c, sold_to__r.Name, GBSTK__c,
                            Customer_PO_Number__c, GE_Order_NO__c, TotalAmount, createdDate, Status, EffectiveDate
                            FROM Order 
                            WHERE EffectiveDate >= :startDate 
                            AND EffectiveDate <= :endDate 
                            AND Sold_to__c = :u.Account.Id
                            ORDER BY EffectiveDate DESC LIMIT 10];
        }
        else{
            //user is agent
            results = [SELECT Id, Account.Name, SFDC_Order_number__c, sold_to__r.Name, GBSTK__c,
                            Customer_PO_Number__c, GE_Order_NO__c, TotalAmount, createdDate, Status, EffectiveDate
                            FROM Order 
                            WHERE EffectiveDate >= :startDate 
                            AND EffectiveDate <= :endDate 
                            AND Agent_rep_code__c = :u.Account.GE_LGT_Rep_Code__c
                            ORDER BY EffectiveDate DESC LIMIT 10];
        }
        return results;
    }

    @AuraEnabled
    public static String reorder(String orderId){
        ReorderHelper rh = new ReorderHelper(orderId);
        String url = rh.reorderUrl();
        return url;
    }
}