/*
Name - SAPPriceAgreementItemTriggerHelper
Test Class - SAPPriceAgreementItemTrigger_Test
Author - Shyam Prasad Nayakula
Purpose - Helper class for the Trigger SAPPriceAgreementItemTrigger
Created Date - July-2017
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By             Date            Comments
Pavan Kumar             7/20/2017       Added error log logic (DTK-643)
*/
public class SAPPriceAgreementItemTriggerHelper 
{
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method populates Parent Agreement and other neccessary fields based on the the information from SAP
    */
    public static void updateFieldsOnCreateOrUpdate(List<SAP_Price_Agreement_Item__c> newPriceAggItems)
    {
        //Creating a Set to Store the Agreement Numbers to map with Price Agreement
        Set<String> AgreementNumSet = new Set<String>();
        for(SAP_Price_Agreement_Item__c itemVar:newPriceAggItems)
        {
            if(itemVar.Agreement_No__c!=NULL)
                AgreementNumSet.add(itemVar.Agreement_No__c);
        }
        //Map to Store Opportunities where Agreement Number as Key
        Map<String,SAP_Price_Agreement__c> AgreementMap = new Map<String,SAP_Price_Agreement__c>();
        //Retriving the Agreements based on Agreement Number Set and putting them in the map
        for(SAP_Price_Agreement__c var:[SELECT ID,Name 
                                        FROM SAP_Price_Agreement__c 
                                        WHERE Name IN:AgreementNumSet])
        {
            AgreementMap.put(var.Name,var);
        }
        //Creating List to store error logs
        List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
        //Iterating the Line Item list and mapping them to respective Agreement based on Agreement Number received from SAP
        for(SAP_Price_Agreement_Item__c var:newPriceAggItems)
        {
            //checking for parent SAP Price Agreement record
            if (var.Agreement_No__c == null)
            {
                GE_LGT_EM_ErrorLog__c newError = HandleErrorLogs.createErrorLog('Mandatory : SAP Price Agreement header is needed to create SAP Price Agreement Item',null,'SAP Price Agreement Item','SAP Price Agreement Item insertion Error', new List<String>{'Agreement_No__c'});
                insert newError;
                var.addError('Mandatory : SAP Price Agreement header is needed to create SAP Price Agreement Item');
            }
            if(var.Agreement_No__c!=NULL && AgreementMap.containsKey(var.Agreement_No__c))
            {
                var.Price_Agreement__c = AgreementMap.get(var.Agreement_No__c).ID;
            }
            if(!StaticVariables.runningQuoteItemBatch)
                var.Processing_Status__c = 'Pending';
        }
        if (!errorLogList.isEmpty()) 
        {
            insert errorLogList;
        }
    }
   
    
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method will be called on after insert which invokes a future method to create Standrad Quotes
    *           based on GE Opportunity ID or Update existing Quotes based on GE Quote ID
    */
    public static void createQuoteLineItems(List<SAP_Price_Agreement_Item__c> newPAItemList)
    {
        //Creating a Set to Store the Agreement Records IDs which are having GE_OPP_ID OR GE_Quote_Number
        List<SAP_Price_Agreement_Item__c> PAItemListToProcess = new List<SAP_Price_Agreement_Item__c>();
        //Iterating the list and adding the IDs to the created Set
        for(SAP_Price_Agreement_Item__c itemVar:newPAItemList)
        {
            if(itemVar.Agreement_No__c!=NULL)
            {
                PAItemListToProcess.add(itemVar);
            }
        }
        //Before calling the future method which creates Quote Line Items, calling "checkAndCreateProductsUsingHierarchy" to validate Products
        //based on SKU Number
         checkAndCreateProductsUsingHierarchy(newPAItemList);
        
        //If AgreementIDSet is not empty then sending those records to future method for processing
        if(!PAItemListToProcess.isEmpty())
            createQuoteItems(PAItemListToProcess);
    }
    
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method creates Products based on the data received from Price Agreement Items
    */
    public static void checkAndCreateProductsUsingHierarchy(List<SAP_Price_Agreement_Item__c> newPAItemList)
    {
        //Creating a Set to Store the SKU numbers to check the related Products
        Set<String> prodNumSet = new Set<String>();
        //Iterating the list and adding the IDs to the created Set
        for(SAP_Price_Agreement_Item__c itemVar:newPAItemList)
        {
            if(itemVar.Material_No__c!=NULL && !itemVar.Material_No__c.contains('NOCAT') && 
               (itemVar.Item_Alternate_Description__c==NULL ||(itemVar.Item_Alternate_Description__c!=NULL && !itemVar.Item_Alternate_Description__c.contains('NOCAT'))))
                prodNumSet.add(itemVar.Material_No__c);
        }
        if(!prodNumSet.isEmpty())
        {
            //Creating a Map to Store the SKU Numbers to get the Product Details
            Set<String> skuSet = new Set<String>();
            Map<String,String> prodMap = new Map<String,String>();
            Map<String,Product2> prodToBeUpdated = new Map<String,Product2>();
            List<Product2> prodList = [SELECT ID,Name FROM Product2 
                                       WHERE Name IN:prodNumSet AND Name!=NULL];
            for(Product2 var:prodList)
            {
                skuSet.add(var.Name);
                prodMap.put(var.Name,var.ID);
            }
            System.debug('TEST::'+skuSet);
            List<Product2> productsToBeInserted = new List<Product2>();
            List<Product2> productsToBeUpdated = new List<Product2>();
            Set<String> tempSet = new Set<String>();
            for(SAP_Price_Agreement_Item__c itemVar:newPAItemList)
            {
                if(itemVar.Material_No__c!=NULL && !skuSet.contains(itemVar.Material_No__c)  &&
                   !tempSet.contains(itemVar.Material_No__c) && !itemVar.Material_No__c.contains('NOCAT') && 
                   (itemVar.Item_Alternate_Description__c==NULL ||(itemVar.Item_Alternate_Description__c!=NULL && !itemVar.Item_Alternate_Description__c.contains('NOCAT'))))
                {
                    Product2 newProdVar = new Product2();
                    newProdVar.Name = itemVar.Material_No__c;
                    newProdVar.isActive = TRUE;
                    newProdVar.Material_No__c = itemVar.Material_No__c;
                    newProdVar.Hierarchy_Level_1_Code__c = itemVar.Hierarchy_Level_1_Code__c;
                    newProdVar.Hierarchy_Level_1_Description__c = itemVar.Hierarchy_Level_1_Description__c;
                    newProdVar.Hierarchy_Level_2_Code__c = itemVar.Hierarchy_Level_2_Code__c;
                    newProdVar.Hierarchy_Level_2_Description__c = itemVar.Hierarchy_Level_2_Description__c;
                    newProdVar.Hierarchy_Level_3_Code__c = itemVar.Hierarchy_Level_3_Code__c;
                    newProdVar.Hierarchy_Level_3_Description__c = itemVar.Hierarchy_Level_3_Description__c;
                    newProdVar.Hierarchy_Level_4_Code__c = itemVar.Hierarchy_Level_4_Code__c;
                    newProdVar.Hierarchy_Level_4_Description__c = itemVar.Hierarchy_Level_4_Description__c;
                    newProdVar.Hierarchy_Level_5_Code__c = itemVar.Hierarchy_Level_5_Code__c;
                    newProdVar.Hierarchy_Level_5_Description__c = itemVar.Hierarchy_Level_5_Description__c;
                    productsToBeInserted.add(newProdVar);
                    tempSet.add(itemVar.Material_No__c);
                }
                else if(itemVar.Material_No__c!=NULL && prodMap.containsKey(itemVar.Material_No__c))
                {
                    Product2 newProdVar = new Product2();
                    newProdVar.ID = prodMap.get(itemVar.Material_No__c);
                    newProdVar.Name = itemVar.Material_No__c;
                    newProdVar.isActive = TRUE;
                    newProdVar.Hierarchy_Level_1_Code__c = itemVar.Hierarchy_Level_1_Code__c;
                    newProdVar.Hierarchy_Level_1_Description__c = itemVar.Hierarchy_Level_1_Description__c;
                    newProdVar.Hierarchy_Level_2_Code__c = itemVar.Hierarchy_Level_2_Code__c;
                    newProdVar.Hierarchy_Level_2_Description__c = itemVar.Hierarchy_Level_2_Description__c;
                    newProdVar.Hierarchy_Level_3_Code__c = itemVar.Hierarchy_Level_3_Code__c;
                    newProdVar.Hierarchy_Level_3_Description__c = itemVar.Hierarchy_Level_3_Description__c;
                    newProdVar.Hierarchy_Level_4_Code__c = itemVar.Hierarchy_Level_4_Code__c;
                    newProdVar.Hierarchy_Level_4_Description__c = itemVar.Hierarchy_Level_4_Description__c;
                    newProdVar.Hierarchy_Level_5_Code__c = itemVar.Hierarchy_Level_5_Code__c;
                    newProdVar.Hierarchy_Level_5_Description__c = itemVar.Hierarchy_Level_5_Description__c;
                    prodToBeUpdated.put(itemVar.Material_No__c,newProdVar);
                }
            }
            if(!productsToBeInserted.isEmpty())
            {
                System.debug('TEST1:'+productsToBeInserted);
                List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
                
                GE_LGT_EM_ErrorLog__c errLogVar;
                
                Database.SaveResult[] srList;
                
                srList = Database.insert(productsToBeInserted,FALSE);
                    
                for( Database.SaveResult srVar : srList )
                {
                    if( !srVar.isSuccess())
                    {
                        for( Database.Error err : srVar.getErrors())
                        {
                            errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),srVar.getId(),'Product','Product INSERT Error',err.getFields());
                            errorLogList.add(errLogVar);
                        }
                    }
                }
                
                if(!errorLogList.isEmpty())
                {
                    Database.insert(errorLogList,false);
                }
            }
            if(!prodToBeUpdated.isEmpty())
            {
                System.debug('TEST2:'+productsToBeUpdated);
                update prodToBeUpdated.values();
            }
        }
    }  

    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method creates Quote Line Items from Price Agreement Items
    * This will be future method to reduce the transaction time and avoid locking issues
    */
    //public static void createQuoteItems(Set<ID> newPriceAggItemIDList)
    public static void createQuoteItems(List<SAP_Price_Agreement_Item__c> retreivedPAItemList)
    {
         System.debug('Check7:: Time::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
        //Creating a Set to Store the Agreement Numbers to map with Price Agreement
        Set<String> AgreementNumSet = new Set<String>();
        //Creating a Set to Store the SKU Numbers to get the Product Details
        Set<String> MatNumSet = new Set<String>();
        for(SAP_Price_Agreement_Item__c var:retreivedPAItemList)
        {
            if ( var.Agreement_No__c!=NULL && var.Price_Agreement__c!=NULL ){
             System.debug('Value in Lookup Price_Agreement__c : '+var.Price_Agreement__c);
                AgreementNumSet.add(var.Agreement_No__c);
            }
            if(var.Material_No__c!=NULL)
                MatNumSet.add(var.Material_No__c);
        }
        if(!AgreementNumSet.isEmpty())
        {
            List<Quote> existingQuoteList = [SELECT ID,Name,Pricebook2ID,GE_Quote_Number__c,OpportunityID,CurrencyIsoCode,Agreement_No__c 
                                             FROM Quote 
                                             WHERE Agreement_No__c IN:AgreementNumSet];
            if(!existingQuoteList.isEmpty())
            {
                Map<String,Quote> existingQuoteMap=new Map<String,Quote>();
                Map<String,PriceBookEntry> priceBookEntryMap=new Map<String,PriceBookEntry>();
                Set<String> currecyCodeSet=new Set<String>();
                Set<String> priceBookSet=new Set<String>();
                for(Quote var:existingQuoteList)
                {
                    existingQuoteMap.put(var.Agreement_No__c,var);
                    currecyCodeSet.add(var.CurrencyIsoCode);
                    priceBookSet.add(var.Pricebook2Id);
                }
                System.debug('priceBookSet'+priceBookSet);
                System.debug('MatNumSet'+MatNumSet);
                 System.debug('currecyCodeSet'+currecyCodeSet);
                //System<PriceBookEntry> priceBookEntryList = [SELECT ID,Product2ID FROM PriceBookEntry];
                //System.debug('priceBookEntryList11'+priceBookEntryList);
                List<PriceBookEntry> pbList=[SELECT ID,Product2ID,Pricebook2Id,CurrencyIsoCode,Product2.Name FROM PriceBookEntry WHERE 
                                             (Product2.Name IN:MatNumSet AND Pricebook2Id IN:priceBookSet AND CurrencyIsoCode IN:currecyCodeSet) 
                                             OR (Name='000000000' AND CurrencyIsoCode IN:currecyCodeSet)];
                Map<String,List<PriceBookEntry>> pbeProdMap=new Map<String,List<PriceBookEntry>>();
                List<PriceBookEntry> dummyPBEProdList=new List<PriceBookEntry>();
                for(PriceBookEntry entryVar:pbList)
                {
                    if(!pbeProdMap.containsKey(entryVar.Product2.Name))
                    {
                        List<PriceBookEntry> preList=new List<PriceBookEntry>();
                        preList.add(entryVar);
                        pbeProdMap.put(entryVar.Product2.Name,preList);
                    }
                    else
                    { 
                        List<PriceBookEntry> preList=pbeProdMap.get(entryVar.Product2.Name);
                        preList.add(entryVar);
                        pbeProdMap.put(entryVar.Product2.Name,preList);
                    }
                    if(entryVar.Product2.Name=='000000000')
                    {
                        dummyPBEProdList.add(entryVar);
                    }
                }
                System.debug('existingQuoteMap:'+existingQuoteMap);
                System.debug('retreivedPAItemList:'+retreivedPAItemList);
                System.debug('pbList:'+pbList);
                List<QuoteLineItem> quoteLineItemsToInsert = new List<QuoteLineItem>();
                for(SAP_Price_Agreement_Item__c var:retreivedPAItemList)
                {
                    //Creating the QuoteLineItems based on the details from Price Agreement Items
                    QuoteLineItem lineItemVar = new QuoteLineItem();
                   // lineItemVar.SAP_External_ID__c = var.Agreement_No__c + var.Material_No__c + var.Condition_No__c;
                    lineItemVar.Quantity = var.Quantity__c;
                    lineItemVar.UnitPrice = var.Sales_Price__c;
                  //  lineItemVar.SAP_External_ID__c = var.SAP_External_ID__c;
                    lineItemVar.Condition_No__c = var.Condition_No__c;
                    lineItemVar.Description = var.Item_Description__c;
                    lineItemVar.Item_Alternate_Description__c = var.Item_Alternate_Description__c;
                    lineItemVar.SKU_Description_Cat_Logic__c = var.Item_Description__c;
                    if(existingQuoteMap.containsKey(var.Agreement_No__c))
                        lineItemVar.QuoteID = existingQuoteMap.get(var.Agreement_No__c).ID;
                    if(lineItemVar.PriceBookEntryID==NULL && existingQuoteMap.containsKey(var.Agreement_No__c))
                    {
                        List<PriceBookEntry> preList = new List<PriceBookEntry>();
                        if(var.Material_No__c!=NULL && pbeProdMap.containsKey(var.Material_No__c) && !var.Material_No__c.contains('NOCAT')
                           && (var.Item_Alternate_Description__c==NULL || (var.Item_Alternate_Description__c!=NULL && !var.Item_Alternate_Description__c.contains('NOCAT'))))
                            preList=pbeProdMap.get(var.Material_No__c);
                        else
                            preList=dummyPBEProdList;                        
                        //System.debug('PreList:'+preList);
                        if(preList!=NULL)
                        {
                            for(PriceBookEntry pbe:preList)
                            {
                                if(pbe.Pricebook2Id==existingQuoteMap.get(var.Agreement_No__c).Pricebook2Id && pbe.CurrencyIsoCode==existingQuoteMap.get(var.Agreement_No__c).CurrencyIsoCode)
                                {
                                    lineItemVar.PriceBookEntryID=pbe.ID;
                                }
                            }
                        }
                    }
                    quoteLineItemsToInsert.add(lineItemVar);
                }
                System.debug('quoteLineItemsToInsert:'+quoteLineItemsToInsert);
                List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
                GE_LGT_EM_ErrorLog__c errLogVar;
                Database.SaveResult[] srList;
                if(!quoteLineItemsToInsert.isEmpty())
                    srList = Database.insert(quoteLineItemsToInsert,FALSE);
                 System.debug('Check8:: Time::'+Limits.getCpuTime() + '::Total Time::'+Limits.getLimitCpuTime());
                //system.assert(false,srList);
                for( Database.SaveResult srVar : srList )
                {
                    if( !srVar.isSuccess())
                    {
                        for( Database.Error err : srVar.getErrors())
                        {
                            errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),srVar.getId(),'SAP Pricing Agreement Item','SAP Pricing Agreement Item UPSERT Error',err.getFields());
                            errorLogList.add(errLogVar);
                        }
                    }
                }
                if(!errorLogList.isEmpty())
                {
                    Database.insert(errorLogList,false);
                }
            }
        }
    }
    
    /*
    * Author  : Shyam Prasad Nayakula
    * Date    : July - 2017
    * Purpose : This method creates Quotes from Price Agreements for which Opportunity is mapped and
    * updates existing Quotes based on GE Quote Number
    * This will be future method to reduce the transaction time and avoid locking issues
    */
    public static void updateQuoteItemsFromPricingAgreementItems(List<SAP_Price_Agreement_Item__c> newPAIList)
    {                  
        //Creating a Set to Store Agreement Numbers
        Set<String> AgreementItemNumSet = new Set<String>();

        for(SAP_Price_Agreement_Item__c aggItemVar:newPAIList)
        {
            AgreementItemNumSet.add(aggItemVar.Condition_No__c);
        }
        if(!AgreementItemNumSet.isEmpty())
        {
            List<QuoteLineItem> existingQuoteItemList = [SELECT ID,Condition_No__c FROM QuoteLineItem 
                                                         WHERE Condition_No__c IN:AgreementItemNumSet];
            if(!existingQuoteItemList.isEmpty())
            {
                //Map to Store Quotes where GE Quote ID as Key
                Map<String,QuoteLineItem> existingQuoteItemMap = new Map<String,QuoteLineItem>();
                for(QuoteLineItem var:existingQuoteItemList)
                {
                    existingQuoteItemMap.put(var.Condition_No__c,var);
                }
                List<QuoteLineItem> quoteItemListToUpdate = new List<QuoteLineItem>();
                //Based on the above map, Opportunity will be mapped Quote
                for(SAP_Price_Agreement_Item__c aggItemVar:newPAIList)
                {
                    if(existingQuoteItemMap.containsKey(aggItemVar.Condition_No__c) && existingQuoteItemMap.get(aggItemVar.Condition_No__c)!=NULL)
                    {
                        QuoteLineItem quoteItemVar = existingQuoteItemMap.get(aggItemVar.Condition_No__c);
                        quoteItemVar.Quantity = aggItemVar.Quantity__c;
                      //  quoteItemVar.UnitPrice = aggItemVar.List_Price__c;
                        quoteItemVar.UnitPrice = aggItemVar.Sales_Price__c;
                        quoteItemVar.Condition_No__c = aggItemVar.Condition_No__c;
                        quoteItemVar.Description = aggItemVar.Item_Description__c;
                        quoteItemVar.Item_Alternate_Description__c = aggItemVar.Item_Alternate_Description__c;
                        quoteItemListToUpdate.add(quoteItemVar);
                    }
                }
                if(!quoteItemListToUpdate.isEmpty())
                {
                    List<GE_LGT_EM_ErrorLog__c> errorLogList=new List<GE_LGT_EM_ErrorLog__c>();
                    GE_LGT_EM_ErrorLog__c errLogVar;
                    Database.SaveResult[] srList;
                    srList = Database.update(quoteItemListToUpdate,FALSE);
                    for( Database.SaveResult srVar : srList )
                    {
                        if( !srVar.isSuccess())
                        {
                            for( Database.Error err : srVar.getErrors())
                            {
                                errLogVar = HandleErrorLogs.createErrorLog(err.getMessage(),srVar.getId(),'QUOTE Line Item','Quote Line Item UPDATE Error',err.getFields());
                                errorLogList.add(errLogVar);
                            }
                        }
                    }
                    if(!errorLogList.isEmpty())
                    {
                        Database.insert(errorLogList,false);
                    }
                }
            }
        }
    }
    
    
    
    // ------------------- CODE ENDS HERE -------------------
     
}