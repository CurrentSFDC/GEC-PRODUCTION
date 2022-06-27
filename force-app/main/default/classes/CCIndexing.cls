public class CCIndexing {

    public static void CCADminTask() {
         try{
            Database.executeBatch(new ccrz.cc_job_LoadProductSpecIndex('Select Id, ccrz__ParentProduct__c, ccrz__FilterData__c from ccrz__E_Product__c'));
            
        }
        catch (System.NullPointerException e) {
        }
        
        // for Menu Cache  
        try{
            (new ccrz.ccMenuCacheBuilder()).build(new Map<String,Object>{ccrz.ccMenuCacheBuilder.STOREFRONT => 'DefaultStore'});
        }
        catch (System.NullPointerException e1) {
        }
        //Category Tree Cache
        try{
            (new ccrz.ccCategoryCacheBuilder()).build(new Map<String,Object>{ccrz.ccCategoryCacheBuilder.STOREFRONT => 'DefaultStore'});
        }
        catch (System.NullPointerException e2) {
            
        }
        //  Refresh Site Index
        try{
            ccrz.ccSiteIndexBuilder.build(new Map<String,Object>{ccrz.ccSiteIndexBuilder.STOREFRONT => 'DefaultStore'});
        }
        catch (System.NullPointerException e3) {
            
        }
        
        // for ProductIndexBuilder
        try{
            ccrz.ccProductIndexBuilder.build(new Map<String,Object>{ccrz.ccAPIProductIndex.LOCALES => new Set<String>{'en_US','en'},ccrz.ccAPIProductIndex.CLEAN_ONLY => TRUE});
            
            ccrz.ccProductIndexBuilder.disableOld(new Map<String,Object>{ccrz.ccAPIProductIndex.CLEAN_ONLY => TRUE});
            ccrz.ccProductIndexBuilder.cleanup(new Map<String,Object>{ccrz.ccAPIProductIndex.PRODUCT_INDICES => TRUE});
        }
        catch (System.NullPointerException e4) {
        }
        
        system.debug('***getCpuTime()***'+Limits.getCpuTime());
         messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {'ravi.singh@gecurrent.com','sagar.suryawanshi@gecurrent.com' };
        message.optOutPolicy = 'FILTER';
        message.subject = 'CC Admin Job: Status';
        message.plainTextBody = 'CC Admin job executed successfully';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] result1 = Messaging.sendEmail(messages);
        
       
    }
    
}