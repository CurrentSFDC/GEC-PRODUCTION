global class BlockAccountsByRepcodes implements Database.Batchable<sObject>
{
    global final String Query;
     global string accGroup;
      global  boolean flag;
       global   String[] nameFilters;
    
    global BlockAccountsByRepcodes()
    {
        
       accGroup='ZEAG';
       flag=true;
      nameFilters = new String[]{'%0001', '%0002', '%0000','%000A'};
        String q = 'select id,GE_LGT_EM_CustomerActiveFlag__c from Account where Account_Group__c=:accGroup AND GE_LGT_EM_CustomerActiveFlag__c=:flag AND GE_LGT_Rep_Code__c LIKE: nameFilters';
        Query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Account> accsToUpdate=new list<Account>();
        
        for(sObject s : scope)
        {
            Account ac = (Account)s;
            ac.GE_LGT_EM_CustomerActiveFlag__c=false;
            accsToUpdate.add(ac);
            system.debug(' opty for'+ ac);
        }
        try
        {
            database.update(accsToUpdate,false); 
        }
        catch(Exception e)
        {
            
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}