trigger ProductPriceBookEntry on Product2 (after insert) 
{
    //Rashmitha Changed the API vesion from 35 to 45 on 6-Mar-2019
    List<CurrencyType> currency_list = [SELECT IsoCode FROM CurrencyType WHERE IsActive=TRUE];
    Public ID PriceBookID;
    if(Test.isRunningTest())
    {
        PriceBookID=Test.getStandardPricebookId();
    }
    else
    {
        PriceBookID = [SELECT ID FROM PriceBook2 WHERE NAME='Standard Price Book' LIMIT 1].ID;
    }
    ID customPriceBookID= [SELECT ID FROM PriceBook2 WHERE NAME='LED' LIMIT 1].ID;
    system.debug('PriceBookID ::: '+PriceBookID);
    try
    {
        List<PriceBookEntry> pBookEntryList ;
        List<PriceBookEntry> custompBookEntryList;
        PriceBookEntry pBookEntry ;
        PriceBookEntry custompBookEntry;
        pBookEntryList = new List<PriceBookEntry>();
        custompBookEntryList=new List<PriceBookEntry>();
        for(Product2 prod : Trigger.new )
        {
            for(CurrencyType curr_list : currency_list )
            {
                pBookEntry = new PriceBookEntry();
                
                pBookEntry.Pricebook2Id     = PriceBookID;
                pBookEntry.Product2Id       = prod.id;
                pBookEntry.CurrencyIsoCode  = curr_list.IsoCode;
                pBookEntry.IsActive         = true;
                pBookEntry.UnitPrice        = 0;
                pBookEntry.UseStandardPrice = false;
                pBookEntryList.add(pBookEntry);
                
                //Commented by Shyam - For PAQ Project - As new Products that are created from MM don't have Hierarchy Code
                //if(prod.Product_Hierarchy_Code__c != null)
                //{
                    custompBookEntry=new PriceBookEntry();
                    custompBookEntry.Pricebook2Id =customPriceBookID;
                    custompBookEntry.Product2Id= prod.id;
                    custompBookEntry.CurrencyIsoCode = curr_list.IsoCode;
                    custompBookEntry.IsActive= true;  
                    custompBookEntry.UnitPrice  = 0;
                    custompBookEntry.UseStandardPrice = false;
                    custompBookEntryList.add( custompBookEntry);
                //}
            }
            
        }
        insert pBookEntryList;
        if(!custompBookEntryList.isEmpty())
        {
            insert  custompBookEntryList;
        }
    }
    catch(Exception ex)
    {
        
    }
    
}