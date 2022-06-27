/**
 * Created by PA on 2021. 06. 03..
 */

public with sharing class CustomerProductFamilyController {
    public void setAccountLookup(List<CustomerProductFamily__c> newProdFamilies){
        Map<String, CustomerProductFamily__c> familyByUid = new Map<String, CustomerProductFamily__c>();
        for (CustomerProductFamily__c prodFamily : newProdFamilies){
            if (fieldCheck(prodFamily)) {
                String uid = prodFamily.SalesOrganization__c + prodFamily.DistributionChannel__c + prodFamily.Division__c + prodFamily.CustomerNumber__c;
                familyByUid.put(uid, prodFamily);
            }
        }
        for (Account acc : [SELECT Id, Unique_Data__c FROM Account WHERE Unique_Data__c IN :new List<String>(familyByUid.keySet())]){
            familyByUid.get(acc.Unique_Data__c).SAPCustomerNumber__c = acc.Id;
        }
    }

    private Boolean fieldCheck(CustomerProductFamily__c newFamily){
        Set<String> fieldsToCheck = new Set<String>{'SalesOrganization__c', 'DistributionChannel__c', 'Division__c', 'CustomerNumber__c'};
        for (String field : fieldsToCheck){
            if (newFamily.get(field) == null) {
                return false;
            }
            if (Trigger.isInsert ||
                    (Trigger.isUpdate
                    && newFamily.get(field) != Trigger.oldMap.get(newFamily.Id).get(field))) {
                return true;
            }
        }
        return false;
    }
}