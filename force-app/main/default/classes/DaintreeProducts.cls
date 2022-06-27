public class DaintreeProducts {
    
    
    
    /*list<Daintree_Order_Tracker__c> trackerList;
    
    public void getTrackers(Id assetRecId){
        this.trackerList = [select Name, Order__c from Daintree_Order_Tracker__c where CSM_License_Asset__c =: assetRecId];
    }*/
    
    @AuraEnabled(cacheable=true)
    public static List<Order> getSortedOrders(Id assetRecId) 
    {
        List<Daintree_Order_Tracker__c> trackerList = [select Order__c from Daintree_Order_Tracker__c where CSM_License_Asset__c =: assetRecId];
        List<order> sortedOrders = new List<order>{};
        Set<Id> orderIds = new Set<id>{};
        
        for (Daintree_Order_Tracker__c tracker:trackerList)
        {
            if (tracker.Order__c != NULL) orderIds.add(tracker.Order__c);
        }
        
        if (OrderIds.size() > 0)
        {
            List<string> refSKUs = loadRefSKUs(); 
     
            sortedOrders = [select (select Id, sku__c, quantity, SKU_Description_Cat_Logic__c from orderitems where 
                                    sku__c IN :refSKUs order by sku__c), (select Id, Name, Tracker_Name__c From Daintree_Order_Trackers__r where Id IN :trackerList) , Name, OrderNumber, Customer_PO_Number__c, GE_Order_NO__c, createddate from 
                            order where Id IN :orderIds order by createddate desc];
        }
        return sortedOrders;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<orderitem> getAllOrders(Id orderId) 
    {
        
        List<orderitem> allOrders = new List<orderitem>{};
       
     
            allOrders = [select Id, sku__c, quantity, SKU_Description_Cat_Logic__c,Order_Line_Number__c,Order_Number__c,UnitPrice, TotalPrice, Ship_Qty__c,Order.Id from orderitem where Order.Id =: orderId];
        
        return allOrders;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<string> loadRefSKUs()
    {
        List<string> referenceSKUs = new List<string>{};
        list<GE_LGT_EM_MaterialMaster__c> refMaterialMasters = [select GE_LGT_EM_SAP_MaterialNumber__c from 
                                                                GE_LGT_EM_MaterialMaster__c where License_Flag_text__c = 'Daintree CSM'];
        if (refMaterialMasters.size() > 0)
        {
            for (GE_LGT_EM_MaterialMaster__c m: refMaterialMasters)
            {
                if (m.GE_LGT_EM_SAP_MaterialNumber__c != NULL)
                {
                    referenceSKUs.add(m.GE_LGT_EM_SAP_MaterialNumber__c);
                }
                
            }
        }
        else
        {
            System.debug('No Daintree License products found');
        }
        return referenceSKUs;
    }
}