/********************************************************************
Purpose: Controller for orderSearch component. Searches for Order records based on search string. 
        Calls ReorderHelper to repeat past orders.

History:
--------
VERSION  AUTHOR       DATE         DESCRIPTION
1.0      Alex Bowser  3-NOV-2020  Created
*/
public class ccOrderSearchController {
    @AuraEnabled
    public static List<sObject> searchForCCOrders(String searchText, String startDateStr, String endDateStr) {

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
            results = [SELECT Id, SAP_Order_Number__c, 
                            ccrz__TotalAmount__c, ccrz__OrderDate__c, 
                            ccrz__OrderStatus__c, Name, ccrz__EncryptedId__c, Order_Type__c
                            FROM ccrz__E_Order__c  
                            WHERE (Name LIKE :searchString
                            OR ccrz__OrderStatus__c LIKE :searchString
                            OR SAP_Order_Number__c LIKE :searchString)
                            AND ccrz__OrderDate__c >= :startDate 
                            AND ccrz__OrderDate__c <= :endDate 
                            ORDER BY ccrz__OrderDate__c DESC
                            ];
        }
        else{
            //user is agent
            results = [SELECT Id, SAP_Order_Number__c, 
                            ccrz__TotalAmount__c, ccrz__OrderDate__c, 
                            ccrz__OrderStatus__c, Name, ccrz__EncryptedId__c, Order_Type__c
                            FROM ccrz__E_Order__c 
                            WHERE (Name LIKE :searchString
                            OR ccrz__OrderStatus__c LIKE :searchString
                            OR SAP_Order_Number__c LIKE :searchString)
                            AND ccrz__OrderDate__c >= :startDate 
                            AND ccrz__OrderDate__c <= :endDate 
                            ORDER BY ccrz__OrderDate__c DESC
                            ];
        }
        return results;
    }

    @AuraEnabled
    public static List<sObject> initCCOrders(String startDateStr, String endDateStr){

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
            results = [SELECT Id, SAP_Order_Number__c, 
                            ccrz__TotalAmount__c, ccrz__OrderDate__c, 
                            ccrz__OrderStatus__c, Name, ccrz__EncryptedId__c, Order_Type__c
                            FROM ccrz__E_Order__c 
                            WHERE ccrz__OrderDate__c >= :startDate 
                            AND ccrz__OrderDate__c <= :endDate 
                            //AND Sold_To_Account__c = :u.Account.Id
                            ORDER BY ccrz__OrderDate__c DESC LIMIT 10
                            ];
        }
        else{
            //user is agent
            results = [SELECT Id, SAP_Order_Number__c, 
                            ccrz__TotalAmount__c, ccrz__OrderDate__c, 
                            ccrz__OrderStatus__c, Name, ccrz__EncryptedId__c, Order_Type__c
                            FROM ccrz__E_Order__c 
                            WHERE ccrz__OrderDate__c >= :startDate 
                            AND ccrz__OrderDate__c <= :endDate 
                            ORDER BY ccrz__OrderDate__c DESC LIMIT 10
                            ];
        }
        System.debug('Results:');
        System.debug(results);
        return results;
    }
}