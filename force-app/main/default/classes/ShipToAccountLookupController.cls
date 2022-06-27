/**
 * Created by PA on 2021. 04. 20..
 */

public with sharing class ShipToAccountLookupController {
    @AuraEnabled(Cacheable=true)
    public static List<Account> getShipToAccounts(Id soldToAccountId, String searchText) {
        if (soldToAccountId == null) {
            throw new IllegalArgumentException('soldToAccountId must be specified!');
        }
        searchText = '%' + String.escapeSingleQuotes(searchText.trim()) + '%';
        System.debug('searchText ' + searchText);
        Account soldToAccount = [SELECT GE_LGT_EM_Sales_Org__c, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id = :soldToAccountId];
        String soldToAccSalesOrg = soldToAccount.GE_LGT_EM_Sales_Org__c;
        String soldToAccCustNum = soldToAccount.GE_LGT_EM_SAP_Customer_Number__c;
        String query = 'SELECT Id,Name,Customer_Integration_Key__c,BillingAddress,ShippingAddress,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_Sales_Group__c,GE_LGT_EM_Sales_Org__c,' +
                'GE_LGT_EM_Distribution_Channel__c ' +
                'FROM Account ' +
                'WHERE ' +
                '(Id =:soldToAccountId OR (Account_Group__c = \'Z002\' AND GE_LGT_EM_Sales_Org__c = :soldToAccSalesOrg AND Connect_Z002_Parents__c = :soldToAccCustNum)) AND ' +
                //'AND GE_LGT_EM_Sales_Org__c IN (\'1U10\', \'1C10\', \'1u10\', \'1c10\') AND' +
                '(Name LIKE :searchText OR ' +
                'GE_LGT_EM_SAP_Customer_Number__c LIKE :searchText OR ' +
                'GE_LGT_EM_Distribution_Channel__c LIKE :searchText) ' +
                'LIMIT 30';
        System.debug('getShipToAccounts query ' + query);
        return Database.query(query);
    }
}