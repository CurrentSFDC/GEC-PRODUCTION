/*
Class - DaintreeProductsController
Test Class - DaintreeLicensingTests
Author - Dharmendra Oswal
Purpose - This class serves as the custom controller for the VF component 'DaintreeOrderProducts'. It returns the table elements for
licensed products in an order

Revision History(Date, Version, author, comments):
*******************************************************************
06 SEP 2018, Version 1.0, Dharmendra Oswal, Initial Version 
*/
public with Sharing class DaintreeProductsController{
    
    public string orderProductsList {get;set;}
    static Map<string, string> refSKUs;
    
    public List<List<string>> getOrderProductsTable()
    {
        list<string> productsList;
        integer numOfProducts;
        
        if (orderProductsList != NULL)
        {
        	productsList = orderProductsList.split(',');
        	numOfProducts = productsList.size();  
        }

        List<List<string>> productsTable = new List<List<string>>{};      
        system.debug(ProductsList);
       
        if (numOfProducts > 0) 
        {
            if (refSKUs == NULL) refSKUs = CSMTrackerTriggerHelper.getReferenceSKUs();
            list<string> orderItem;
            for (integer i = 0; i < numOfProducts; i++)
            {
               	orderItem = productsList[i].split('-');
                system.debug(orderItem);
                string SKU = orderItem[0].trim();
               	if (orderItem.size() == 2 && refSKUs.containsKey(SKU)) 
               	{
                    string quantity = CSMTrackerTriggerHelper.formatQuantity(orderItem[1]);
                    productsTable.add(new list<string>{SKU, quantity, refSKUs.get(SKU)});                      
               	}
            }                   
        }
        else
        {
        	System.debug('No order products found');
        }
        return productsTable;
    }
}