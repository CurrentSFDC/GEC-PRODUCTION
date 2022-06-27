/*
Name - BA003_AttachProductToQLItems 
Test Class - BA003_AttachProductToQLItems_Test
Author - Shyam
Purpose - To map the Quote Line Items to original product based on SKU if its mapped to Dummy Product
Date - April-2017
*/
global class BA003_AttachProductToQLItems implements Database.Batchable<SObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {   
        //Retrieving all the SAP Quote Line Items which are attached to Dummy Product
        return Database.getQueryLocator([SELECT Quote_Number__c,Product2.Name,Quantity,Quote_Item_External_ID__c,Quote_Item_Number__c,
                                         UnitPrice,QuoteID,SKU__c,SKU_Description_Cat_Logic__c
                                         FROM QuoteLineItem 
                                         WHERE Product2.Name='DUMMY PRODUCT']);
    }
    global void execute(Database.BatchableContext bc,List<QuoteLineItem> scopeList)
    {
        Set<String> sapQuoteNumbers = new Set<String>();
        Map<String,String> skuMap=new Map<String,String>();
        List<QuoteLineItem> itemsToInsert = new List<QuoteLineItem>();
        for(QuoteLineItem sqi : scopeList) 
        {
            QuoteLineItem q=new QuoteLineItem();
            q.Quantity=sqi.Quantity;
            q.Quote_Item_External_ID__c=sqi.Quote_Item_External_ID__c;
            q.Quote_Item_Number__c=sqi.Quote_Item_Number__c;
            q.Quote_Number__c=sqi.Quote_Number__c;
            q.UnitPrice=sqi.UnitPrice;
            q.QuoteID=sqi.QuoteID;
            q.SKU__c=sqi.SKU__c;
            q.SKU_Description_Cat_Logic__c=sqi.SKU_Description_Cat_Logic__c;
            itemsToInsert.add(q);
        }
        
        //Deleting the Quote Items from Standard Quote
        Database.delete([SELECT ID FROM QuoteLineItem WHERE ID IN:scopeList]);
        
        //Creating the new Quote Items for existing Standard Quotes 
        Database.insert(itemsToInsert,false);
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}