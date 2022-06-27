public class SAPRecordsRecycleTriggerHelper 
{
    public void DeleteDuplicateEdcr(List<SAP_Records_Recycle__c> deua_dellist)
        {
            Map<String, SAP_Records_Recycle__c> AccountMap = new Map<String, SAP_Records_Recycle__c>();
            Map<String, SAP_Records_Recycle__c> AccountMapSalesorg = new Map<String, SAP_Records_Recycle__c>();
            Map<String, SAP_Records_Recycle__c> AccountMapDivision = new Map<String, SAP_Records_Recycle__c>();
            Map<String, SAP_Records_Recycle__c> AccountMapPFType = new Map<String, SAP_Records_Recycle__c>();   
            Map<String, SAP_Records_Recycle__c> AccountMapDistribution = new Map<String, SAP_Records_Recycle__c>();  
            set<SAP_Records_Recycle__c> deletedupeaccount = new set<SAP_Records_Recycle__c>();
            list<SAP_Records_Recycle__c> deletedupeaccount_list = new list<SAP_Records_Recycle__c>();
            list<SAP_Records_Recycle__c> deua_dellist1 =[Select id,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Division__c,GE_LGT_EM_PF_Type__c,GE_LGT_EM_Distribution_Channel__c FROM SAP_Records_Recycle__c where id IN: deua_dellist];
            
            for (SAP_Records_Recycle__c acc :deua_dellist1) 
            {
                if(acc.GE_LGT_EM_SAP_Customer_Number__c !=null)
                {
                    AccountMap.put(acc.GE_LGT_EM_SAP_Customer_Number__c, acc);
                    AccountMapSalesorg.put(acc.GE_LGT_EM_Sales_Org__c,acc);
                    AccountMapDivision.put(acc.GE_LGT_EM_Division__c,acc); 
                    AccountMapPFType.put(acc.GE_LGT_EM_PF_Type__c,acc);
                    AccountMapDistribution.put(acc.GE_LGT_EM_Distribution_Channel__c,acc); 
                }
            }
            List<SAP_Records_Recycle__c> Delacclist=[Select id,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Division__c,GE_LGT_EM_PF_Type__c, GE_LGT_EM_Distribution_Channel__c from SAP_Records_Recycle__c where GE_LGT_EM_SAP_Customer_Number__c IN:AccountMap.KeySet() and
                                       GE_LGT_EM_Sales_Org__c IN:AccountMapSalesorg.KeySet() and
                                       GE_LGT_EM_Division__c IN:AccountMapDivision.KeySet() and 
                                       GE_LGT_EM_Distribution_Channel__c IN: AccountMapDistribution.KeySet() and 
                                       GE_LGT_EM_PF_Type__c IN : AccountMapPFType.KeySet() AND ID NOT IN: deua_dellist];
                                       
                                       
            for(SAP_Records_Recycle__c c:deua_dellist1)
            {
                for(SAP_Records_Recycle__c d:Delacclist) 
                {
                    if(c.GE_LGT_EM_SAP_Customer_Number__c ==d.GE_LGT_EM_SAP_Customer_Number__c && c.GE_LGT_EM_Distribution_Channel__c ==d.GE_LGT_EM_Distribution_Channel__c && c.GE_LGT_EM_Sales_Org__c==d.GE_LGT_EM_Sales_Org__c && c.GE_LGT_EM_Division__c==d.GE_LGT_EM_Division__c && c.GE_LGT_EM_PF_Type__c==d.GE_LGT_EM_PF_Type__c) {
                        d.GE_LGT_EM_Distribution_Channel__c =c.GE_LGT_EM_Distribution_Channel__c;
                        d.GE_LGT_EM_Division__c = c.GE_LGT_EM_Division__c;
                        d.GE_LGT_EM_PF_Type__c  = c.GE_LGT_EM_PF_Type__c;
                        d.GE_LGT_EM_Sales_Org__c = c.GE_LGT_EM_Sales_Org__c;
                        d.GE_LGT_EM_SAP_Customer_Number__c = c.GE_LGT_EM_SAP_Customer_Number__c;
                        deletedupeaccount.add(c);
                        
                    }
                }
            }
            deletedupeaccount_list.addall(deletedupeaccount);
            delete deletedupeaccount_list;
        }
}