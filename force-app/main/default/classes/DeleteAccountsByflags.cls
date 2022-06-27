global class DeleteAccountsByflags implements Database.Batchable<sObject>
{
    global final String Query;
    global id recSASypeID1;
    global boolean activefalg;
    global DeleteAccountsByflags()
    {
        activefalg=false;
        recSASypeID1 =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        String q = 'select id,GE_LGT_EM_CustomerActiveFlag__c,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Division__c,GE_LGT_EM_PF_Type__c,GE_LGT_EM_Distribution_Channel__c from Account where Recordtypeid=:recSASypeID1 AND GE_LGT_EM_CustomerActiveFlag__c=:activefalg AND GE_LGT_EM_SAP_Customer_Number__c !=null';
        Query = q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        set<String> AccountMap = new set<String>();
        set<String> AccountMapSalesorg = new set<String>();
        set<String> AccountMapDivision = new set<String>();
        set<String> AccountMapPFType = new set<String>();   
        set<String> AccountMapDistribution = new set<String>();  
        list<account> deletedupeaccount = new list<account>();
        list<account> deletedupeaccount1 = new list<account>();
        set<id> accids=new set<id>();
        
        ID recEDtypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        for(sObject s : scope)
        {
            
            Account acc = (Account)s;
            if(acc.GE_LGT_EM_SAP_Customer_Number__c!=null){
                AccountMap.add(acc.GE_LGT_EM_SAP_Customer_Number__c);
                AccountMapSalesorg.add(acc.GE_LGT_EM_Sales_Org__c);
                AccountMapDivision.add(acc.GE_LGT_EM_Division__c); 
                AccountMapPFType.add(acc.GE_LGT_EM_PF_Type__c);
                AccountMapDistribution.add(acc.GE_LGT_EM_Distribution_Channel__c);
            }
            
        }
        List<SAP_Records_Recycle__c> Delacclist=[Select id,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Division__c,GE_LGT_EM_PF_Type__c, GE_LGT_EM_Distribution_Channel__c from SAP_Records_Recycle__c where GE_LGT_EM_SAP_Customer_Number__c IN:AccountMap OR
                                                 GE_LGT_EM_Sales_Org__c IN:AccountMapSalesorg OR
                                                 GE_LGT_EM_Division__c IN:AccountMapDivision OR
                                                 GE_LGT_EM_Distribution_Channel__c IN: AccountMapDistribution OR
                                                 GE_LGT_EM_PF_Type__c IN : AccountMapPFType ];
        //Below code is for RQT-0000075 
        
        List<Account> DelSAPacclist=[Select id,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Division__c,GE_LGT_EM_PF_Type__c, GE_LGT_EM_Distribution_Channel__c from Account where (GE_LGT_EM_SAP_Customer_Number__c IN:AccountMap OR
                                                 GE_LGT_EM_Sales_Org__c IN:AccountMapSalesorg OR
                                                 GE_LGT_EM_Division__c IN:AccountMapDivision OR
                                                 GE_LGT_EM_Distribution_Channel__c IN: AccountMapDistribution OR
                                                 GE_LGT_EM_PF_Type__c IN : AccountMapPFType) AND
                                                 RecordTypeId=:recEDtypeID];
        
        
        for(sObject s : scope)
        {
            Account c = (Account)s;
            for(SAP_Records_Recycle__c d:Delacclist) 
            {
                if(c.GE_LGT_EM_CustomerActiveFlag__c==false && c.GE_LGT_EM_SAP_Customer_Number__c ==d.GE_LGT_EM_SAP_Customer_Number__c && c.GE_LGT_EM_Distribution_Channel__c ==d.GE_LGT_EM_Distribution_Channel__c && c.GE_LGT_EM_Sales_Org__c==d.GE_LGT_EM_Sales_Org__c && c.GE_LGT_EM_Division__c==d.GE_LGT_EM_Division__c && c.GE_LGT_EM_PF_Type__c==d.GE_LGT_EM_PF_Type__c) {
                    deletedupeaccount.add(c);
                    
                }
            }
            for(Account a:DelSAPacclist) 
            {
                if(c.GE_LGT_EM_CustomerActiveFlag__c==false && c.GE_LGT_EM_SAP_Customer_Number__c ==a.GE_LGT_EM_SAP_Customer_Number__c && c.GE_LGT_EM_Distribution_Channel__c ==a.GE_LGT_EM_Distribution_Channel__c && c.GE_LGT_EM_Sales_Org__c==a.GE_LGT_EM_Sales_Org__c && c.GE_LGT_EM_Division__c==a.GE_LGT_EM_Division__c && c.GE_LGT_EM_PF_Type__c==a.GE_LGT_EM_PF_Type__c) {
                    deletedupeaccount1.add(c);
                    
                }
            }
        }
        try
        {
            delete deletedupeaccount;
            delete deletedupeaccount1;
        }
        catch(Exception e)
        {
            
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    
    
}