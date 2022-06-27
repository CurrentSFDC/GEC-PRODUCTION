/**
 * Created by PA on 2021. 04. 22..
 */

public with sharing class AccountSharingController {
    public void shareChildAccountsFromAccountContactRelationInsert(List<AccountContactRelation> accountContactRelations){
        Set<Id> contactAndAccountIds = new Set<Id>();
        for (AccountContactRelation acr : accountContactRelations){
            contactAndAccountIds.add(acr.AccountId);
            contactAndAccountIds.add(acr.ContactId);
        }

        Map<String,String> userIdByContactId = new Map<String, String>();
        for (User u: [SELECT Id, ContactId FROM User WHERE ContactId IN :contactAndAccountIds]){
            userIdByContactId.put(u.ContactId, u.Id);
        }

        Map<String,String> accountIdByAccountNumber = new Map<String, String>();
        for (Account parentAccount : [SELECT GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id IN :contactAndAccountIds AND Account_Group__c = 'Z001']){
            accountIdByAccountNumber.put(parentAccount.GE_LGT_EM_SAP_Customer_Number__c, parentAccount.Id);
        }

        Map<Id,Set<Id>> childAccountsByParentAccountId = new Map<Id, Set<Id>>();
        for (Account a : [SELECT Id, Connect_Z002_Parents__c FROM Account WHERE Connect_Z002_Parents__c IN :accountIdByAccountNumber.keySet()]){
            Id parentId = accountIdByAccountNumber.get(a.Connect_Z002_Parents__c);
            if (childAccountsByParentAccountId.containsKey(parentId)) {
                Set<Id> childAccounts = childAccountsByParentAccountId.get(parentId);
                childAccounts.add(a.Id);
                childAccountsByParentAccountId.put(parentId, childAccounts);
            } else {
                childAccountsByParentAccountId.put(parentId, new Set<Id>{a.Id});
            }
        }

        List<AccountShare> newAccountShares = new List<AccountShare>();
        for (AccountContactRelation acr : accountContactRelations){
            if (userIdByContactId.containsKey(acr.ContactId)
                    && childAccountsByParentAccountId.containsKey(acr.AccountId)) {
                for (Id childAccountId : childAccountsByParentAccountId.get(acr.AccountId)){
                    newAccountShares.add(
                            new AccountShare(
                                    UserOrGroupId = userIdByContactId.get(acr.ContactId),
                                    AccountId = childAccountId,
                                    AccountAccessLevel = 'Read',
                                    OpportunityAccessLevel = 'None',
                                    CaseAccessLevel = 'Read',
                                    RowCause = 'Manual')
                    );
                }
            }
        }
        System.debug(newAccountShares.size());
        System.debug(newAccountShares);
        insert newAccountShares;
    }

    public void shareChildAccountsFromAccountTrigger(List<Account> accounts){
        Map<String, Set<Id>> childAccountsByParentAccountNumbers = new Map<String, Set<Id>>();
        for (Account acc : accounts){
            if (acc.Connect_Z002_Parents__c != null &&
                    (Trigger.isInsert ||
                    (Trigger.isUpdate && acc.Connect_Z002_Parents__c != Trigger.oldMap.get(acc.Id).get('Connect_Z002_Parents__c')))) {
                if (childAccountsByParentAccountNumbers.containsKey(acc.Connect_Z002_Parents__c)) {
                    Set<Id> childList = childAccountsByParentAccountNumbers.get(acc.Connect_Z002_Parents__c);
                    childList.add(acc.Id);
                    childAccountsByParentAccountNumbers.put(acc.Connect_Z002_Parents__c, childList);
                } else{
                    childAccountsByParentAccountNumbers.put(acc.Connect_Z002_Parents__c, new Set<Id>{acc.Id});
                }
            }
        }

        Map<Id, Set<Id>> childAccountIdsByContact = new Map<Id, Set<Id>>();
        for (AccountContactRelation acr : [SELECT ContactId, Account.GE_LGT_EM_SAP_Customer_Number__c from AccountContactRelation WHERE Account.GE_LGT_EM_SAP_Customer_Number__c IN :childAccountsByParentAccountNumbers.keySet()]){
            childAccountIdsByContact.put(acr.ContactId, childAccountsByParentAccountNumbers.get(acr.Account.GE_LGT_EM_SAP_Customer_Number__c));
        }
        List<AccountShare> newAccountShares = new List<AccountShare>();
        for (User u : [SELECT ContactId FROM User WHERE ContactId IN: childAccountIdsByContact.keySet()]){
            for (Id childAccountId : childAccountIdsByContact.get(u.ContactId)){
                newAccountShares.add(new AccountShare(
                        UserOrGroupId = u.Id,
                        AccountId = childAccountId,
                        AccountAccessLevel = 'Read',
                        OpportunityAccessLevel = 'None',
                        CaseAccessLevel = 'Read',
                        RowCause = 'Manual')
                );
            }
        }
        System.debug(newAccountShares.size());
        System.debug(newAccountShares);
        insert newAccountShares;
    }
}