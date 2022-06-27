/*
Class - ViewDaintreeProductsController
Test Class - DaintreeLicensingTests
Author - Dharmendra Oswal
Purpose - This class serves as the custom controller extension for the VF page 'ViewDaintreeProductsPage'. It retreives licensed
order products for all orders on a CSM License.

Revision History(Date, Version, author, comments):
*******************************************************************
06 SEP 2018, Version 1.0, Dharmendra Oswal, Initial Version 
*/
public with Sharing class ViewDaintreeProductsController {
    
    list<Daintree_Order_Tracker__c> trackerList;
    public ViewDaintreeProductsController(ApexPages.StandardController stdController) 
    {
        this.trackerList = [select Order__c from Daintree_Order_Tracker__c where CSM_License_Asset__c = :((asset)stdController.getRecord()).Id];
	}
	 
    public List<Order> getSortedOrders() 
    {
        List<order> sortedOrders = new List<order>{};
        Set<Id> orderIds = new Set<id>{};
        
        for (Daintree_Order_Tracker__c tracker:trackerList)
        {
            if (tracker.Order__c != NULL) orderIds.add(tracker.Order__c);
        }
        
        if (OrderIds.size() > 0)
        {
            List<string> refSKUs = loadRefSKUs();       
        	sortedOrders = [select (select sku__c, quantity, SKU_Description_Cat_Logic__c from orderitems where 
                                    sku__c IN :refSKUs order by sku__c), Customer_PO_Number__c, GE_Order_NO__c, createddate from 
                            order where Id IN :orderIds order by createddate desc];
        }
		return sortedOrders;
	}
    
    private List<string> loadRefSKUs()
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