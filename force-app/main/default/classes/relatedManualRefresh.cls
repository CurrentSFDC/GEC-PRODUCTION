public without sharing class relatedManualRefresh {
    
    @AuraEnabled(Cacheable=false)
    public static List<Connect_Direct_Account__c> getRepCodes(String recordId, String restoreDate){
     
        System.debug('DATE RECEIVED FROM LWC: '+restoreDate);
        
        String newDate= String.valueOf(restoreDate);
        System.debug('Converted Date: '+newDate);
        return [SELECT Id, Rep_Code__c, Is_Direct__c, Remapped__c, Contact__c, Direct_Account__c FROM Connect_Direct_Account__c WHERE Contact__c =: recordId AND Restore_Point__c =: newDate];
        
    }

    @AuraEnabled(Cacheable=false)
    public static string getAccount(){
        Id tempAccID = [SELECT Id FROM Account WHERE Name = 'GE CURRENT - EXTERNAL' LIMIT 1].Id;
        System.debug('FOUND tempAccount: '+tempAccID);
        return tempAccID;
    }

    @AuraEnabled(cacheable=false)
    public static string updateContact(Contact data) {
        
        upsert data Id;
        return 'Success: Line Item Modified';

    }

    @AuraEnabled(Cacheable=false)
    public static string removeACR(String contactId, String accountId){
        List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation WHERE ContactId =: contactId AND AccountId !=:accountId];
        delete acrList;
        return 'Success: Records Deleted';
    }

    @AuraEnabled(cacheable=false)
    public static string insertACR(AccountContactRelation data) {
        
        insert data;
        return 'Success: Line Item Modified';
    }

    @AuraEnabled(cacheable=false)
    public static string updateCDA(Connect_Direct_Account__c data) {
        
        upsert data Id;
        return 'Success: Line Item Modified';
    }

    /*@AuraEnabled(Cacheable=true)
    public static List<Account> getDistributors(String repCode){
        List<Account> acrList = [SELECT Id, Name FROM Account WHERE ContactId =: contactId];
    }*/
    

}