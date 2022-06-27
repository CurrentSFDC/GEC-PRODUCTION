global class GE_LGT_EM_Product_Hierarchy_Code_Update implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Map<String,Id> mmMap = new Map<String,Id>(); 
        Map<String,ID> pMap = new Map<String, ID>(); 
        List<GE_LGT_EM_MaterialMaster__c> mmList = new List<GE_LGT_EM_MaterialMaster__c>();  
        List<Product2> pList = new List<Product2>(); 
        mmList = [SELECT ID, GE_LGT_EM_ProductHierarchy__c, Product_Hierarchy_Code_2__c FROM GE_LGT_EM_MaterialMaster__c WHERE Product_Hierarchy_Code_2__c = '' limit 900];    
        for (GE_LGT_EM_MaterialMaster__c mm :mmList)
        {
            mmMap.put((mm.GE_LGT_EM_ProductHierarchy__c).left(10),mm.Id);    
        }
        
        pList = [SELECT Product_Hierarchy_Code__c, ID FROM Product2 WHERE Product_Hierarchy_Code__c IN :mmMap.keySet()];                  
                       
        for (Product2 p :pList)
        {
            pMap.put(p.Product_Hierarchy_Code__c,p.Id);    
        }
        for (GE_LGT_EM_MaterialMaster__c mm :mmList)
        {
            mm.Product_Hierarchy_Code_2__c = pMap.get((mm.GE_LGT_EM_ProductHierarchy__c).left(10));
        }
        update mmList;
    }
}