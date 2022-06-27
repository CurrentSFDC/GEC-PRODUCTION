/*
Name - OrderLineItemUpdateHelper
Test Class - OrderLineItemUpdateHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Helper class of OrderLineItemUpdate trigger
Date - May-2016
Revisions:
Q1-2017 - This will populate Agent lookup on OrderItem based on below logic:
If Order header has Agent, then the same will populate on OrderItem, If not then Agent on OrderItem will remain as they come from SAP
If no agent info comes to OrderItem (and also if Header has no agent) from SAP then it remains blank at OrderItem level 
*/
public class OrderLineItemUpdateHelper 
{
    public void UpdateOrderLineItems(List<OrderItem> orderItems)
    {
        Set<String> orderNums=new Set<String>();
        set<String> sapSTZacctNums = new set<String>();  // AA
        Set<String> sapAccNums=new Set<String>();
        Set<String> quoteExtIDs=new Set<String>();
        Set<String> sapZEAGacctNums = new set<String>();
        Set<String> ordrItemQuoteSet = new set<String>();
        
        Map<String,String> skuMap=new Map<String,String>();
        Set<String> prodList=new Set<String>();
        Set<String> currecyList=new Set<String>();
        Set<String> pb2List=new Set<String>();
        for(OrderItem o:orderItems){
            if(o.Order_Number__c!=NULL)
                orderNums.add(o.Order_Number__c);
                system.debug('Adding ' + o.Order_Number__c + ' to the OrderNums List...');
            if(o.SKU__c!=NULL)
                skuMap.put(o.SKU__c,null);
            if(o.Strategic_SAPUniqueId__c!=null)  //AA
                sapAccNums.add(o.Strategic_SAPUniqueId__c.subStringBeforeLast('-')+'%');
            if(o.Quote_Item_Ext_Id__c!=null) 
                quoteExtIDs.add(o.Quote_Item_Ext_Id__c);
            if(o.Agent_SAPUniqueId__c!=null)//Added by Neel-1803
                sapAccNums.add(o.Agent_SAPUniqueId__c);
            system.debug('Test');
            if(o.Agreement_Quote__c!=null)//Added by Neel-1803
                ordrItemQuoteSet.add(o.Agreement_Quote__c);
            
        }
        
        // added agent fields in the query
        List<Order> orders=[SELECT ID,GE_Order_NO__c,CurrencyIsoCode,Pricebook2Id,Agent_Account__c, Strategic_SAPUniqueId__c, Strategic_Account__c FROM Order WHERE GE_Order_NO__c IN:orderNums];
        Map<String,Order> orderMap=new Map<String,Order>();
        Map<String,Id> orderAgentMap=new Map<String,Id>();
        
        Map<String,PriceBookEntry> pbeMap=new Map<String,PriceBookEntry>();
        //AA - Strat Acc lookup
        List<Account> accList=[SELECT ID,GE_LGT_EM_SAPUniqueIdentifier__c,GE_LGT_EM_PF_Type__c,GE_LGT_EM_Division__c FROM Account WHERE GE_LGT_EM_SAPUniqueIdentifier__c LIKE:sapAccNums];
        system.debug('Account Query List :: '+accList);
        Map<String,Account> accMap=new Map<String,Account>(); 
        for(Account a:accList) 
        {
            accMap.put(a.GE_LGT_EM_SAPUniqueIdentifier__c,a);
            system.debug('SAP Identifier Test: '+a.GE_LGT_EM_SAPUniqueIdentifier__c);
        }    
        for(Order o:orders){
            orderMap.put(o.GE_Order_NO__c,o);
            orderAgentMap.put(o.GE_Order_NO__c,o.Agent_Account__c );
            currecyList.add(o.CurrencyIsoCode);
            pb2List.add(o.Pricebook2Id);
        }
        
        
        
        System.debug('OrderMap:'+orderMap);
        List<GE_LGT_EM_MaterialMaster__c> matMasters=[SELECT ID,GE_LGT_EM_SAP_MaterialNumber__c,Product_Hierarchy_Code_2__r.ID FROM GE_LGT_EM_MaterialMaster__c WHERE GE_LGT_EM_SAP_MaterialNumber__c IN:skuMap.keySet()];
        for(GE_LGT_EM_MaterialMaster__c m:matMasters)
        {
            prodList.add(m.Product_Hierarchy_Code_2__r.ID);
            System.debug('Adding Product Hierarchy Code to List: '+m.Product_Hierarchy_Code_2__r.Id);
            skuMap.put(m.GE_LGT_EM_SAP_MaterialNumber__c, m.Product_Hierarchy_Code_2__r.ID);
        }
        List<PriceBookEntry> pbList=[SELECT ID,Product2ID,Pricebook2Id,CurrencyIsoCode FROM PriceBookEntry WHERE Product2ID IN:prodList AND Pricebook2Id IN:pb2List AND CurrencyIsoCode IN:currecyList];
        system.debug('SOQL Consumed Line No 34 ::::: '+Limits.getQueries());
        
        Map<String,List<PriceBookEntry>> pbeProdMap=new Map<String,List<PriceBookEntry>>();
        for(PriceBookEntry p:pbList)
        {
            if(!pbeProdMap.containsKey(p.Product2Id))
            {
                system.debug('Test IF LOOP , Line no 39');
                List<PriceBookEntry> preList=new List<PriceBookEntry>();
                preList.add(p);
                pbeProdMap.put(p.Product2Id,preList);
            }
            else
            { 
                system.debug('Test IF LOOP , Line no 46');
                List<PriceBookEntry> preList=pbeProdMap.get(p.Product2Id);
                preList.add(p);
                pbeProdMap.put(p.Product2Id,preList);
            }
        }
        system.debug('pbeProdMap:'+pbeProdMap.keySet());
        system.debug('skuMap:'+skuMap.keySet());
        for(OrderItem o:orderItems)
        {
            // old logic commented above
            
            // New logic - populate Strategic account info
            if(o.Strategic_SAPUniqueId__c!=NULL && accMap.containsKey(o.Strategic_SAPUniqueId__c) && accMap.get(o.Strategic_SAPUniqueId__c)!=NULL)  //AA
            { 
                o.Strategic_Account__c=accMap.get(o.Strategic_SAPUniqueId__c).Id;
            }
            else
            {
                system.debug('OrderItems Strategic info to be pulled from OrderHeader');
                if(o.Order_Number__c!=NULL && orderMap.containsKey(o.Order_Number__c) && orderMap.get(o.Order_Number__c).Strategic_SAPUniqueId__c!=null )
                {
                    //orderMap.get(o.Order_Number__c).ID
                    o.Strategic_Account__c = orderMap.get(o.Order_Number__c).Strategic_Account__c ;
                    o.Strategic_SAPUniqueId__c=orderMap.get(o.Order_Number__c).Strategic_SAPUniqueId__c;
                }                
            }
            
            // Populate Agent from Order header, else let child agent remail
            if(o.Order_Number__c!=NULL && orderAgentMap.get(o.Order_Number__c)!=null )
            {
                system.debug('Agent Id:::: '+orderAgentMap.get(o.Order_Number__c));
                o.Agent_Name__c=orderAgentMap.get(o.Order_Number__c);
            }
            else
            {
                if(o.Agent_SAPUniqueId__c!=NULL && accMap.containsKey(o.Agent_SAPUniqueId__c)) 
                {
                    system.debug('Account map agent detail:::'+accMap.containsKey(o.Agent_SAPUniqueId__c));
                    o.Agent_Name__c=accMap.get(o.Agent_SAPUniqueId__c).Id;
                }
                else
                {
                    o.Agent_Name__c=null;
                }
            }
            
            system.debug('Number of SOQL Consumed ::: '+Limits.getQueries());                        
            if(o.Order_Number__c!=NULL && orderMap.containsKey(o.Order_Number__c) && o.OrderID==NULL)
            {
                o.orderID=orderMap.get(o.Order_Number__c).ID;
                System.debug('Setting Order on Order Line Item to: '+o.orderID);
            }
            if(o.UnitPrice==NULL || o.UnitPrice==0)
            {
                o.UnitPrice=1;
            }
            if(o.Quantity==NULL || o.Quantity==0)
            {
                o.Quantity=1;
            }
            if(o.PriceBookEntryID==NULL && skuMap.containsKey(o.SKU__c) && orderMap.containsKey(o.Order_Number__c))
            {
                List<PriceBookEntry> preList=pbeProdMap.get(skuMap.get(o.SKU__c));
                if(preList!=NULL)
                {
                    for(PriceBookEntry pbe:preList)
                    {
                        System.debug('OrderID:'+o.Order_Number__c);
                        System.debug('PBID:'+o.Order_Number__c+':'+orderMap.get(o.Order_Number__c).Pricebook2Id);
                        System.debug('CIC:'+orderMap.get(o.Order_Number__c).CurrencyIsoCode);
                        if(pbe.Pricebook2Id==orderMap.get(o.Order_Number__c).Pricebook2Id && pbe.CurrencyIsoCode==orderMap.get(o.Order_Number__c).CurrencyIsoCode)
                        {
                            o.PriceBookEntryID=pbe.ID;
                        }
                    }
                } 
            }
        }
    }
}