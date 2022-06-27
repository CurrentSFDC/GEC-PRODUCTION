/**
 * Created by PA on 2021. 04. 20..
 */

public with sharing class SoldToAccountLookupController {
    @AuraEnabled(Cacheable=true)
    public static List<Account> getSoldToAccounts(String searchText, String accountId) {
        searchText = '%' + String.escapeSingleQuotes(searchText.trim()) + '%';
        accountId = '%' + [SELECT GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id = :String.escapeSingleQuotes(accountId.trim()) LIMIT 1].GE_LGT_EM_SAP_Customer_Number__c + '%';
        System.debug('searchText ' + searchText);
        String query = 'SELECT Id,Name,Customer_Integration_Key__c,BillingAddress,ShippingAddress,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_Sales_Group__c,GE_LGT_EM_Sales_Org__c,' +
                'GE_LGT_EM_Distribution_Channel__c,' +
                'GE_LGT_EM_Division__c, ' +
                'ConnectFixtureAgents__c, ' +
                'Connect_Share_with_Account_PartA__c, ' +
                'Connect_Share_with_Account_PartB__c, ' +
                'Connect_Share_with_Account_PartC__c, ' +
                'CurrencyIsoCode ' +
                'FROM Account ' +
                'WHERE ' +
                'Account_Group__c = \'Z001\' AND ' +
                'ConnectFixtureAgents__c LIKE :accountId AND ' +
                //'AND GE_LGT_EM_Sales_Org__c IN (\'1U10\', \'1C10\', \'1u10\', \'1c10\') AND ' +
                '(Name LIKE :searchText OR ' +
                'GE_LGT_EM_SAP_Customer_Number__c LIKE :searchText OR ' +
                'GE_LGT_EM_Sales_Org__c LIKE :searchText OR ' +
                'GE_LGT_EM_Distribution_Channel__c LIKE :searchText) ' +
                'LIMIT 30';
        System.debug('getSoldToAccounts query ' + query);
        return Database.query(query);
    }

    @AuraEnabled(Cacheable=true)
    public static Account getSoldToAccountByHeadId(Id headAccountId){
        if (headAccountId == null) {return null;}
        Account acc = [SELECT Id,
                Name,
                Customer_Integration_Key__c,
                BillingAddress,
                ShippingAddress,
                GE_LGT_EM_SAP_Customer_Number__c,
                GE_LGT_Sales_Group__c,
                GE_LGT_EM_Sales_Org__c,
                GE_LGT_EM_Distribution_Channel__c,
                GE_LGT_EM_Division__c,
                ConnectFixtureAgents__c,
                Connect_Share_with_Account_PartA__c,
                Connect_Share_with_Account_PartB__c,
                Connect_Share_with_Account_PartC__c,
                CurrencyIsoCode
        FROM Account
        WHERE Id = :headAccountId LIMIT 1];
        return acc;
    }

    @AuraEnabled
    public static Account getSoldToAccount(Id accountId){
        if (accountId == null) {return null;}
        Account acc = [SELECT Id,
                Name,
                Customer_Integration_Key__c,
                BillingAddress,
                ShippingAddress,
                GE_LGT_EM_SAP_Customer_Number__c,
                GE_LGT_Sales_Group__c,
                GE_LGT_EM_Sales_Org__c,
                GE_LGT_EM_Distribution_Channel__c,
                GE_LGT_EM_Division__c,
                ConnectFixtureAgents__c,
                Connect_Share_with_Account_PartA__c,
                Connect_Share_with_Account_PartB__c,
                Connect_Share_with_Account_PartC__c,
                CurrencyIsoCode
        FROM Account
        WHERE Id = :accountId LIMIT 1];
        return acc;
    }
}