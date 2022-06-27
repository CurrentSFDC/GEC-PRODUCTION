/**
 * Created by PA on 2021. 06. 03..
 */

public with sharing class BatchableCustomerProductFamilyAddAccount implements Database.Batchable<SObject> {
    public List<CustomerProductFamily__c> start(Database.BatchableContext bc){
        return [SELECT
                SalesOrganization__c,
                DistributionChannel__c,
                Division__c,
                CustomerNumber__c,
                SAPCustomerNumber__c
        FROM CustomerProductFamily__c
        WHERE
                SalesOrganization__c != NULL AND
                DistributionChannel__c != NULL AND
                Division__c != NULL AND
                CustomerNumber__c!= NULL
        ];
    }

    public void execute(Database.BatchableContext bc, List<CustomerProductFamily__c> families){
        Map<String, CustomerProductFamily__c> familyByUid = new Map<String, CustomerProductFamily__c>();
        for (CustomerProductFamily__c prodFamily : families){
            String uid = prodFamily.SalesOrganization__c + prodFamily.DistributionChannel__c + prodFamily.Division__c + prodFamily.CustomerNumber__c;
            familyByUid.put(uid, prodFamily);
        }
        for (Account acc : [SELECT Id, Unique_Data__c FROM Account WHERE Unique_Data__c IN :new List<String>(familyByUid.keySet())]){
            familyByUid.get(acc.Unique_Data__c).SAPCustomerNumber__c = acc.Id;
        }
        update familyByUid.values();
    }

    public void finish(Database.BatchableContext param1) {
    }
}