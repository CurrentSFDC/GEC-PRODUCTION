/*
Name - QuoteLineItemUpdateHelper
Test Class - QuoteLineItemUpdateHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Helper class of QuoteLineItemUpdate Trigger
Date - May-2016
*/
public class QuoteLineItemUpdateHelper 
{
    public void UpdateQuoteLineItems(List<QuoteLineItem> quoteItems)
    {
        Set<String> quoteNums=new Set<String>();
        Map<String,String> skuMap=new Map<String,String>();
        Set<String> prodList=new Set<String>();
        Set<String> currecyList=new Set<String>();
        Set<String> pb2List=new Set<String>();
        for(QuoteLineItem q:quoteItems)
        {
            if(q.Quote_Number__c!=NULL)
                quoteNums.add(q.Quote_Number__c);
            if(q.SKU__c!=NULL)
                skuMap.put(q.SKU__c,null);
        }
        List<Quote> quotes=[SELECT ID,PriceBook2Id,CurrencyIsoCode,GE_Quote_Number__c FROM Quote WHERE GE_Quote_Number__c IN:quoteNums];
        Map<String,Quote> quoteMap=new Map<String,Quote>();
        Map<String,PriceBookEntry> pbeMap=new Map<String,PriceBookEntry>();
        for(Quote o:quotes)
        {
            quoteMap.put(o.GE_Quote_Number__c,o);
            currecyList.add(o.CurrencyIsoCode);
            pb2List.add(o.Pricebook2Id);
        }
        System.debug('QuoteMap:'+quoteMap);
        List<GE_LGT_EM_MaterialMaster__c> matMasters=[SELECT ID,GE_LGT_EM_SAP_MaterialNumber__c,Product_Hierarchy_Code_2__r.ID FROM GE_LGT_EM_MaterialMaster__c WHERE GE_LGT_EM_SAP_MaterialNumber__c IN:skuMap.keySet()];
        for(GE_LGT_EM_MaterialMaster__c m:matMasters)
        {
            prodList.add(m.Product_Hierarchy_Code_2__r.ID);
            skuMap.put(m.GE_LGT_EM_SAP_MaterialNumber__c, m.Product_Hierarchy_Code_2__r.ID);
        }
        List<PriceBookEntry> pbList=[SELECT ID,Product2ID,Pricebook2Id,CurrencyIsoCode,Product2.Name FROM PriceBookEntry 
                                     WHERE (Product2ID IN:prodList AND Pricebook2Id IN:pb2List AND CurrencyIsoCode IN:currecyList)
                                     OR Product2.Name='DUMMY PRODUCT'];
        Map<String,List<PriceBookEntry>> pbeProdMap=new Map<String,List<PriceBookEntry>>();
        List<PriceBookEntry> dummyPBEProdList=new List<PriceBookEntry>();
        for(PriceBookEntry p:pbList)
        {
            if(!pbeProdMap.containsKey(p.Product2Id))
            {
                List<PriceBookEntry> preList=new List<PriceBookEntry>();
                preList.add(p);
                pbeProdMap.put(p.Product2Id,preList);
            }
            else
            { 
                List<PriceBookEntry> preList=pbeProdMap.get(p.Product2Id);
                preList.add(p);
                pbeProdMap.put(p.Product2Id,preList);
            }
            //Below if is related to map the Dummy Product to QLI if the SKU doesn't have a Product assoiciated with it.
            if(p.Product2.Name=='DUMMY PRODUCT')
            {
                dummyPBEProdList.add(p);
            }
        }
        System.debug('QuoteMap:'+quoteMap); 
        for(QuoteLineItem o:quoteItems)
        {
            if(o.QuoteID==NULL && o.Quote_Number__c!=NULL && quoteMap.containsKey(o.Quote_Number__c))
            {
                System.debug('In IF:');
                o.QuoteID=quoteMap.get(o.Quote_Number__c).ID;
            }
            if(o.PriceBookEntryID==NULL && skuMap.containsKey(o.SKU__c) && quoteMap.containsKey(o.Quote_Number__c))
            {
                List<PriceBookEntry> preList=pbeProdMap.get(skuMap.get(o.SKU__c));
                System.debug('PreList:'+preList);
                if(preList!=NULL)
                {
                    for(PriceBookEntry pbe:preList)
                    {
                        if(pbe.Pricebook2Id==quoteMap.get(o.Quote_Number__c).Pricebook2Id && pbe.CurrencyIsoCode==quoteMap.get(o.Quote_Number__c).CurrencyIsoCode)
                        {
                            o.PriceBookEntryID=pbe.ID;
                        }
                    }
                }
                //Below else is related to map the Dummy Product to QLI if the SKU doesn't have a Product assoiciated with it.
                else if(preList==NULL)
                {
                    for(PriceBookEntry pbe:dummyPBEProdList)
                    {
                        if(pbe.Pricebook2Id==quoteMap.get(o.Quote_Number__c).Pricebook2Id && pbe.CurrencyIsoCode==quoteMap.get(o.Quote_Number__c).CurrencyIsoCode)
                        {
                            o.PriceBookEntryID=pbe.ID;
                        }
                    }
                }
            }
        }
        System.debug('QuoteItems:'+quoteItems);
    }
    public void removeLeadingZeros(List<QuoteLineItem> quoteItems)
    {
        for(QuoteLineItem q:quoteItems)
        {
            if(q.SKU__c!=NULL)
                q.SKU__c=String.valueOf(Integer.valueOf(q.SKU__c));
        }
    }
    //Added this code to copy the SKU Details from Opportunity Product to Quote Line Item - RQT-0000192
    public void mapSKUFromOpptyLineItem(List<QuoteLineItem> quoteItems)
    {
        Set<ID> opptyProdIDs=new Set<ID>();
        Map<String,String> skuMap=new Map<String,String>();
        Map<String,String> skuDesMap=new Map<String,String>();
        for(QuoteLineItem q:quoteItems)
        {
            if(q.SKU__c==NULL && q.Opportunity_Line_Item_ID__c!=NULL)
                opptyProdIDs.add(q.Opportunity_Line_Item_ID__c);
        }
        for(OpportunityLineItem opptyVar : [SELECT ID,SKUNumber__c,Description FROM OpportunityLineItem WHERE ID IN:opptyProdIDs])
        {
            skuMap.put(opptyVar.ID,opptyVar.SKUNumber__c);
            skuDesMap.put(opptyVar.ID,opptyVar.Description);
        }
        for(QuoteLineItem q:quoteItems)
        {
            if(q.SKU__c==NULL && skuMap.containsKey(q.Opportunity_Line_Item_ID__c))
                q.SKU__c=skuMap.get(q.Opportunity_Line_Item_ID__c);
            if(q.SKU_Description_Cat_Logic__c==NULL && skuDesMap.containsKey(q.Opportunity_Line_Item_ID__c))
                q.SKU_Description_Cat_Logic__c=skuDesMap.get(q.Opportunity_Line_Item_ID__c);
        }
    }
    // This method will prevent deletion of QLI when syncing oppty stage is S3(and above) and Oppty Amunt >=50k
    //    Developed by Neel(Jun-2017
    public void preventDeleteQLI ( Map<Id,QuoteLineItem> mapQuoteItems, List<QuoteLineItem> ListQli ){
        //below set will store Quote Ids which will be used for querying QuoteLineItem object
        Set<Id> SetQLI_Id = mapQuoteItems.keySet();
        Map<Id,String> MapQLI_OppStage = new Map<Id,String>();
        List<QuoteLineItem> ListQLI_Opp = [ select id, quote.Id,Quote.Name,Quote.LineItemCount,Quote.Opportunity.StageName,Quote.Opportunity.Total_Order_Amount__c from QuoteLineItem where id in : SetQLI_Id ];
        system.debug('StaticVariables.deleteOpptyProduct ::::: '+StaticVariables.deleteOpptyProduct);
        if( ListQLI_Opp.size()>0 ){
            
            //Store QuoteId and Stage name in map MapQLI_OppStage, This will be used to check if stage is S3(and above) then adderror 
            for( QuoteLineItem qliVar1 : ListQLI_Opp ){
                system.debug('Oppty Stage ::: '+qliVar1.Quote.Opportunity.StageName);
                system.debug('Oppty Total Order Amount is ::: '+qliVar1.Quote.Opportunity.Total_Order_Amount__c);
                
                if(qliVar1.Quote.Opportunity.Total_Order_Amount__c>=50000 && (qliVar1.Quote.Opportunity.StageName=='S3 Solve' || qliVar1.Quote.Opportunity.StageName=='S4 Negotiate' || qliVar1.Quote.Opportunity.StageName=='S5 Close'  || qliVar1.Quote.Opportunity.StageName=='PO Received') )
                    MapQLI_OppStage.put(qliVar1.Id, qliVar1.Quote.Opportunity.StageName);
            }
            
            for ( QuoteLineItem qliVar : ListQli ){
                
                
                if ( MapQLI_OppStage.containsKey(qliVar.id) ){
                    qliVar.addError('Quote Line Item can not be deleted if the associated Oppty Total Order Amount is 50k or above and stage is : '+MapQLI_OppStage.get(qliVar.id)); 
                }
            } 
        }
    }
}