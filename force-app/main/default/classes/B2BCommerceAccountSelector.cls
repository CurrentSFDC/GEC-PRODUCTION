public without sharing class B2BCommerceAccountSelector {
    @AuraEnabled(Cacheable = true)
    public static List<Account> getRelatedAccounts(String contactId, String userType) {
        List<AccountContactRelation> acrList = [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :contactId]; List<Id> accList = new List<Id>(); for (AccountContactRelation a : acrList) {
            accList.add(a.AccountId);
        }
        String portalType = userType;
        if (portalType == 'Agent') {
            List<Account> accountList = [
                    SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c, GE_LGT_EM_Order_Block__c
                    FROM Account
                    WHERE Account_Group__c = 'ZEAG' AND Id IN :accList AND GE_LGT_EM_CustomerActiveFlag__c = TRUE AND (NOT GE_LGT_Rep_Code__c LIKE 'U%') AND (NOT Name LIKE '%- PARENT')
                    ORDER BY Name ASC
            ];

            if (accountList != null & accountList.size() > 0) {
                return accountList;
            }
            return null;
        } else {

            List<Account> accountList = [
                    SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c, GE_LGT_EM_Order_Block__c
                    FROM Account
                    WHERE Id IN :accList AND GE_LGT_EM_CustomerActiveFlag__c = TRUE
                    ORDER BY Name ASC
            ];

            if (accountList != null & accountList.size() > 0) {
                return accountList;
            }
            return null;
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<Account> getAgentAccounts(String contactId) {
        List<AccountContactRelation> acrList = [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :contactId]; List<Id> accList = new List<Id>(); for (AccountContactRelation a : acrList) {
            accList.add(a.AccountId);
        }
        List<Account> accountList = [
                SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c, GE_LGT_EM_Order_Block__c
                FROM Account
                WHERE Id IN :accList AND Account_Group__c = 'ZEAG' AND GE_LGT_EM_CustomerActiveFlag__c = TRUE AND (NOT GE_LGT_Rep_Code__c LIKE 'U%') AND (NOT Name LIKE '%- PARENT')
                ORDER BY Name ASC
        ];
        if (accountList != null & accountList.size() > 0) {
            return accountList;
        }
        return null;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Account> getSoldToAccounts(String accountId) {
        String accCode = '%' + accountId + '%'; List<Account> accountList = [
                SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c, GE_LGT_EM_Order_Block__c
                FROM Account
                WHERE Account_Group__c = 'Z001' AND ConnectFixtureAgents__c LIKE :accCode
                ORDER BY Name ASC
        ];
        if (accountList != null & accountList.size() > 0) {
            return accountList;
        }
        return null;
    }

    @AuraEnabled
    public static List<Account> getAccountName(String accountId) {
        return [SELECT Name, GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c FROM Account WHERE Id = :accountId];
    }
}