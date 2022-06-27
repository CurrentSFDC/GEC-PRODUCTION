/*
Class Name - AssetTriggerHelper
Test Class Name - AssetTriggerHelper_Test
Purpose - This is a helper class for AssetTrigger
Author - Neel (TechMahindra)
Date - Oct-2016
Revision :
*/


public class AssetTriggerHelper{

    public static void updateAssetDetails(List<Asset> assetList){
        system.debug('Asset TriggerHelper method updateAssetDetails begins');
        set<String> accSAPIds = new Set<String>();
        
        for(Asset asst : assetList){
           if(asst.Account_SAP_UniqueId__c!=null){
               accSAPIds.add('%'+asst.Account_SAP_UniqueId__c+'%');
           }
        }
        List<Account> listAccount = [SELECT ID,GE_LGT_EM_SAPUniqueIdentifier__c FROM Account WHERE GE_LGT_EM_SAPUniqueIdentifier__c LIKE:accSAPIds];
        
        Map<String, Account> accMap = new Map<String, Account>();
        for(Account acct:listAccount){
          accMap.put(acct.GE_LGT_EM_SAPUniqueIdentifier__c,acct); 
          system.debug('Account Unique Identifier ::'+acct.GE_LGT_EM_SAPUniqueIdentifier__c); 
        }
          
          
        try{
            for(Asset asst_var:assetList){
               system.debug('Incoming Account_SAP_UniqueId__c :: '+asst_var.Account_SAP_UniqueId__c);
               system.debug('Account Id existing in system :: '+accMap.get(asst_var.Account_SAP_UniqueId__c).id);
               if(asst_var.Account_SAP_UniqueId__c!=null && accMap.containsKey(asst_var.Account_SAP_UniqueId__c) ){
               asst_var.accountid=accMap.get(asst_var.Account_SAP_UniqueId__c).id;
               }   
            
            }
         
         }catch(Exception exc){
            system.debug('Error::::::::: '+exc.getMessage());
         
        }  
    
    
    }



}