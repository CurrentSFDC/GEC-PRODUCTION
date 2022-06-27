@isTest(SeeAllData=true)
public class ProductPriceBookEntry_Test{
    static testMethod void addPriceBookEntries(){
    Product2 prod = new Product2(Name = 'Laptop X200', 
                                
                                 levels_1__c='Laptop X2002',
                                 levels_2__c='Laptop X2004',
                                 levels_3__c='Laptop X2004',
                                 SAP_product__c=true,
                                 Product_Hierarchy_Code__c='0123456789123',
                                 CurrencyIsoCode='USD',
                                 CanUseQuantitySchedule=true,
                                 CanUseRevenueSchedule=true,
                                 isActive=true);
    insert prod;
    
    
    Id pricebookId = Test.getStandardPricebookId();
    
    PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 0, 
            IsActive = true);
     
   //  insert standardPrice;
    
    }



}