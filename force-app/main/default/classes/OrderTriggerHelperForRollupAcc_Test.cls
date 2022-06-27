/*
Name - OrderLineItemUpdateHelper_Test
Author - sivateja
Purpose - Test Class
Date - Sept-2016
*/
@isTest(seeAllData=True)
public class OrderTriggerHelperForRollupAcc_Test {
static testmethod void method1()
{
Account acc=TestDataUtil.createAccount();
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        
        
        Pricebook2 customPB = new Pricebook2(Name='LED', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        
        
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        insert acc;
        
        Order order=TestDataUtil.createOrder('9999');
        order.accountId=acc.id;
        order.Pricebook2id = customPB.id;
        insert order;
        
        GE_LGT_EM_MaterialMaster__c matMaster=TestDataUtil.createMaterialMaster('93036710');
        insert matMaster;
        
        OrderItem oli=TestDataUtil.createOrderItem('9999','10');
        oli.PricebookEntryId = customPrice.id;
        insert oli;    
}
}