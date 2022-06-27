/**
 * Created by PA on 2021. 04. 23..
 */

public with sharing class BatchableChildAccountShare implements Database.Batchable<SObject> {
    public List<Account> start(Database.BatchableContext param1) {
        return [SELECT Connect_Z002_Parents__c FROM Account WHERE Connect_Z002_Parents__c != NULL];
    }

    public void execute(Database.BatchableContext bc, List<Account> childAccounts) {
        Map<String, Set<Id>> childAccountsByParentAccountNumbers = new Map<String, Set<Id>>();
        for (Account acc : childAccounts){
            if (childAccountsByParentAccountNumbers.containsKey(acc.Connect_Z002_Parents__c)) {
                Set<Id> childList = childAccountsByParentAccountNumbers.get(acc.Connect_Z002_Parents__c);
                childList.add(acc.Id);
                childAccountsByParentAccountNumbers.put(acc.Connect_Z002_Parents__c, childList);
            } else{
                childAccountsByParentAccountNumbers.put(acc.Connect_Z002_Parents__c, new Set<Id>{acc.Id});
            }
        }

        System.debug(childAccountsByParentAccountNumbers);

        Map<Id, Set<Id>> childAccountIdsByContact = new Map<Id, Set<Id>>();
        for (AccountContactRelation acr : [SELECT ContactId, Account.GE_LGT_EM_SAP_Customer_Number__c from AccountContactRelation WHERE Account.GE_LGT_EM_SAP_Customer_Number__c IN :childAccountsByParentAccountNumbers.keySet()]){
            childAccountIdsByContact.put(acr.ContactId, childAccountsByParentAccountNumbers.get(acr.Account.GE_LGT_EM_SAP_Customer_Number__c));
        }

        System.debug(childAccountIdsByContact);

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

    public void finish(Database.BatchableContext param1) {
    }
}