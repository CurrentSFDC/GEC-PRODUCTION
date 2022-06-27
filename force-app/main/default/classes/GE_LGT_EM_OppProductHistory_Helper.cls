/***********************************************************************************************
*   Trigger Name    : GE_LGT_EM_OppProductHistory_Helper
*   Date            : 11/25/2015
*   Author          : Tech Mahindra
*   Object          : OpportunityLineItem
*   Purpose         : To track added, modified and deleted recordrds of Opp Line Item.
*                      
*   Change History  :
*   Date                      Developer              Reason 
*   --------------------      -------------------    -------------------------
*                                         
**************************************************************************************************/
public class GE_LGT_EM_OppProductHistory_Helper
{
    /*public static void insertOppProductHistory(List<OpportunityLineItem> lineItemList,String operType)
    {
        Map<Id,Id> prodIdMap = new Map<Id,Id>();
        Map<Id,String> prodCodeMap = new Map<Id,String>();
        List<OpportunityLineItem> oppitemProdList =[SELECT Id,PricebookEntryId,PricebookEntry.Product2Id,PricebookEntry.ProductCode FROM OpportunityLineItem WHERE Id =: lineItemList];
        for(OpportunityLineItem oli:oppitemProdList)
        {
            prodIdMap.put(oli.id, oli.PricebookEntry.Product2Id);
            prodCodeMap.put(oli.id, oli.PricebookEntry.ProductCode);
        }
        List<Opportunity_Products_History__c> OPDList = new List<Opportunity_Products_History__c>();
        Opportunity_Products_History__c opd;
        for(OpportunityLineItem opptyItem : lineItemList)
        {
            opd = new Opportunity_Products_History__c();
            opd.Confirmed__c=opptyItem.Confirmed__c;
            opd.Cut_off_date__c=opptyItem.Cut_off_date__c;
            opd.ServiceDate__c=opptyItem.ServiceDate;
            opd.Description__c=opptyItem.Description;
            opd.Discount__c=opptyItem.Discount;
            opd.Estimated_Shipment_date__c=opptyItem.Estimated_Shipment_date__c;
            opd.Estimated_Shipment_date2__c=opptyItem.Estimated_Shipment_date2__c;
            opd.Fixtures_LED__c=opptyItem.Fixtures_LED__c;
            opd.Hierarchy_chk__c=opptyItem.Hierarchy_chk__c;
            opd.Leadtime_Correction__c=opptyItem.Leadtime_Correction__c;
            opd.Line_Description__c=opptyItem.Description;
            opd.List_Price__c=opptyItem.ListPrice;
            opd.Opportunity__c=opptyItem.OpportunityId;
            opd.Oppt_Customer_Decision_Date__c=opptyItem.GE_LGT_Oppt_Customer_Decision_Date__c;
            //opd.Origin_Quote__c=opptyItem.BigMachines__Origin_Quote__c;
            opd.Product__c=prodIdMap.get(opptyItem.Id);
            opd.Product_Code__c=prodCodeMap.get(opptyItem.Id);
            opd.Product_Group__c=opptyItem.GE_LGT_Product_Group__c;
            opd.Product_Hierarchy_Code__c=opptyItem.Product_Hierarchy_Code__c;
            opd.Product_Line__c=opptyItem.GE_LGT_Product_Line__c;
            opd.Product_Name__c=opptyItem.GE_LGT_Product_Name__c;
            opd.Quantity__c=opptyItem.Quantity;
            opd.Requested_Price__c=opptyItem.GE_LGT_Requested_Price__c;
            opd.Sales_Price__c=opptyItem.UnitPrice;
            opd.SKU__c=opptyItem.SKU__c;
            opd.SKU_Hierarchy_Code__c=opptyItem.SKU_Hierarchy_Code__c;
            opd.SKU_ID__c=opptyItem.SKU_Number__c;
            opd.Subtotal__c=opptyItem.Subtotal;
            //opd.Synchronization_Id__c=opptyItem.BigMachines__Synchronization_Id__c;
            opd.Total_Price__c=opptyItem.TotalPrice;
            opd.Vertical_ProductGroup__c=opptyItem.Vertical_ProductGroup__c;
            opd.Operation_Type__c=operType;
            opd.Opportunity_Product_ID__c=opptyItem.ID;
            OPDList.add(opd);
        }
        Database.insert(OPDList,false);
    }*/
    /*public static void updateCheck(List<OpportunityLineItem> oldLineItemList,List<OpportunityLineItem> newLineItemList,Map<ID,OpportunityLineItem> oldMap)
    {
        System.debug('In Update Check');
        List<OpportunityLineItem> lineItemList=new List<OpportunityLineItem>();
        for(OpportunityLineItem newLI:newLineItemList)
        {
            for(OpportunityLineItem oldLI:oldLineItemList)
            {
                 if(oldLI.ID==newLI.ID && (oldLI.Confirmed__c!=newLI.Confirmed__c||oldLI.Cut_off_date__c!=newLI.Cut_off_date__c||oldLI.ServiceDate!=newLI.ServiceDate||oldLI.Description__c!=newLI.Description||oldLI.Discount!=newLI.Discount||
                   oldLI.Estimated_Shipment_date__c!=newLI.Estimated_Shipment_date__c||oldLI.Estimated_Shipment_date2__c!=newLI.Estimated_Shipment_date2__c||oldLI.Fixtures_LED__c!=newLI.Fixtures_LED__c||oldLI.Hierarchy_chk__c!=newLI.Hierarchy_chk__c||
                   oldLI.Leadtime_Correction__c!=newLI.Leadtime_Correction__c||oldLI.Description!=newLI.Description||oldLI.ListPrice!=newLI.ListPrice||oldLI.OpportunityId!=newLI.OpportunityId||oldLI.GE_LGT_Oppt_Customer_Decision_Date__c!=newLI.GE_LGT_Oppt_Customer_Decision_Date__c||
                   oldLI.Product2Id!=newLI.Product2Id||oldLI.ProductCode!=newLI.ProductCode||oldLI.GE_LGT_Product_Group__c!=newLI.GE_LGT_Product_Group__c||oldLI.Product_Hierarchy_Code__c!=newLI.Product_Hierarchy_Code__c||
                   oldLI.GE_LGT_Product_Line__c!=newLI.GE_LGT_Product_Line__c||oldLI.GE_LGT_Product_Name__c!=newLI.GE_LGT_Product_Name__c||oldLI.Quantity!=newLI.Quantity||oldLI.GE_LGT_Requested_Price__c!=newLI.GE_LGT_Requested_Price__c||oldLI.UnitPrice!=newLI.UnitPrice||oldLI.SKU__c!=newLI.SKU__c||
                   oldLI.SKU_Hierarchy_Code__c!=newLI.SKU_Hierarchy_Code__c||oldLI.SKU_Number__c!=newLI.SKU_Number__c||oldLI.Subtotal!=newLI.Subtotal||
                   oldLI.TotalPrice!=newLI.TotalPrice||oldLI.Vertical_ProductGroup__c!=newLI.Vertical_ProductGroup__c))
                  {
                      System.debug('Old Value:'+oldLI);
                      System.debug('New Value:'+newLI);
                      lineItemList.add(newLI);  
                  }
            }
        }
        GE_LGT_EM_OppProductHistory_Helper.insertOppProductHistory(lineItemList,'Update'); 
    }*/
    /*public static void updateCheck(List<OpportunityLineItem> oldLineItemList,List<OpportunityLineItem> newLineItemList,Map<ID,OpportunityLineItem> oldMap)
    {
        System.debug('In Update Check');
        List<OpportunityLineItem> lineItemList=new List<OpportunityLineItem>();
        for(OpportunityLineItem newLI:newLineItemList)
        {
            OpportunityLineItem oldLI = oldMap.get(newLI.ID);
             if(oldLI.ID==newLI.ID && (oldLI.Confirmed__c!=newLI.Confirmed__c||oldLI.Cut_off_date__c!=newLI.Cut_off_date__c||oldLI.ServiceDate!=newLI.ServiceDate||oldLI.Description__c!=newLI.Description||oldLI.Discount!=newLI.Discount||
               oldLI.Estimated_Shipment_date__c!=newLI.Estimated_Shipment_date__c||oldLI.Estimated_Shipment_date2__c!=newLI.Estimated_Shipment_date2__c||oldLI.Fixtures_LED__c!=newLI.Fixtures_LED__c||oldLI.Hierarchy_chk__c!=newLI.Hierarchy_chk__c||
               oldLI.Leadtime_Correction__c!=newLI.Leadtime_Correction__c||oldLI.Description!=newLI.Description||oldLI.ListPrice!=newLI.ListPrice||oldLI.OpportunityId!=newLI.OpportunityId||oldLI.GE_LGT_Oppt_Customer_Decision_Date__c!=newLI.GE_LGT_Oppt_Customer_Decision_Date__c||
               oldLI.Product2Id!=newLI.Product2Id||oldLI.ProductCode!=newLI.ProductCode||oldLI.GE_LGT_Product_Group__c!=newLI.GE_LGT_Product_Group__c||oldLI.Product_Hierarchy_Code__c!=newLI.Product_Hierarchy_Code__c||
               oldLI.GE_LGT_Product_Line__c!=newLI.GE_LGT_Product_Line__c||oldLI.GE_LGT_Product_Name__c!=newLI.GE_LGT_Product_Name__c||oldLI.Quantity!=newLI.Quantity||oldLI.GE_LGT_Requested_Price__c!=newLI.GE_LGT_Requested_Price__c||oldLI.UnitPrice!=newLI.UnitPrice||oldLI.SKU__c!=newLI.SKU__c||
               oldLI.SKU_Hierarchy_Code__c!=newLI.SKU_Hierarchy_Code__c||oldLI.SKU_Number__c!=newLI.SKU_Number__c||oldLI.Subtotal!=newLI.Subtotal||
               oldLI.TotalPrice!=newLI.TotalPrice||oldLI.Vertical_ProductGroup__c!=newLI.Vertical_ProductGroup__c))
              {
                  System.debug('Old Value:'+oldLI);
                  System.debug('New Value:'+newLI);
                  lineItemList.add(newLI);  
              }
        }
        GE_LGT_EM_OppProductHistory_Helper.insertOppProductHistory(lineItemList,'Update'); 
    }*/
     public static void UpdateOppLedContent(List<OpportunityLineItem> lineItemList)
    {
        //Map<Id,OpportunityLineItem> oppitemProdMap =new Map<Id,OpportunityLineItem>([SELECT Id,OpportunityId,PricebookEntry.ProductCode,PricebookEntry.Product2.GE_LGT_LED_NonLED__c FROM OpportunityLineItem WHERE Id =: lineItemList]);
        //List<OpportunityLineItem> oppitemProdList =[SELECT Id,OpportunityId,PricebookEntry.ProductCode,PricebookEntry.Product2.GE_LGT_LED_NonLED__c FROM OpportunityLineItem WHERE Id IN: lineItemList];
        Map<ID,List<String>> oppChildList=new Map<ID,List<String>>();
        List<ID> oppIDList=new List<ID>();
        for(OpportunityLineItem o:lineItemList)
        {
            oppIDList.add(o.OpportunityId);
        }
        List<OpportunityLineItem> oppitemProdList =[SELECT Id,OpportunityId,PricebookEntry.ProductCode,
                                                    PricebookEntry.Product2.LED_vs_Non_LED__c 
                                                    FROM OpportunityLineItem WHERE OpportunityId IN: oppIDList];
        for(OpportunityLineItem o:oppitemProdList)
        {
            if(!oppChildList.containsKey(o.OpportunityId))
            {
                List<String> productType=new List<String>();
                productType.add(o.PricebookEntry.Product2.LED_vs_Non_LED__c);
                oppChildList.put(o.OpportunityId,productType);
            }
            else
            {
                List<String> productType=oppChildList.get(o.OpportunityId);
                productType.add(o.PricebookEntry.Product2.LED_vs_Non_LED__c);
                oppChildList.put(o.OpportunityId,productType);
            }
        }
        List<Opportunity> oppList=[SELECT ID,LED_Content__c,hasOpportunityLineItem FROM Opportunity WHERE ID IN:oppIDList];
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        for(Opportunity opp:oppList)
        {
            String oldLED = opp.LED_Content__c;
            if(oppChildList.containsKey(opp.id))
            {
                List<String> ProductTypeList=oppChildList.get(opp.id);
                System.debug('ProductTypeList'+ProductTypeList);
                Integer led=0;
                Integer nonLed=0;
                Integer noValue=0;
                for(String s:ProductTypeList)
                {
                    if(s=='LED')
                    {
                        led++;
                    }
                    else if(s=='NONLED')
                    {
                        nonLed++;
                    }
                    else
                    {
                        noValue++;
                    }
                }
                if(noValue!=ProductTypeList.size())
                {
                    if(led==ProductTypeList.size())
                    {
                        opp.LED_Content__c = '100% LED';
                    }
                    else if(nonLed==ProductTypeList.size())
                    {
                        opp.LED_Content__c = 'No LED';
                    }
                    else
                    {
                        opp.LED_Content__c = 'Partially LED';
                    }
                }
                else
                {
                    opp.LED_Content__c = 'No LED';
                }
            }
            else
            {
                opp.LED_Content__c = 'No Products Yet';
            }
            
            if(opp.LED_Content__c != oldLED)
            {
                Opportunity oppVar = new Opportunity();
                oppVar.ID = opp.ID;
                oppVar.LED_Content__c = opp.LED_Content__c;
                oppListToUpdate.add(oppVar);
            }
        }
        System.debug('Before Update::'+oppListToUpdate);
        if(!oppListToUpdate.isEmpty())
        {
            System.debug('In Update::'+oppListToUpdate);
            Database.update(oppListToUpdate);
        }
          
    }
}