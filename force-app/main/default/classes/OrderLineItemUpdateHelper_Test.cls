/*
Name - OrderLineItemUpdateHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Test Class
Date - May-2016
*/
@isTest(seealldata=true)
public class OrderLineItemUpdateHelper_Test 
{
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
        order.Accountid=acc.id;
        Order.Pricebook2Id = customPB.Id;//Added on 21 Oct 2020 for relating order price book so ,that Pricebookentry be related
        insert order;
        
        GE_LGT_EM_MaterialMaster__c matMaster=TestDataUtil.createMaterialMaster('93036710');
        insert matMaster;
        
        OrderItem oli=TestDataUtil.createOrderItem('9999','10');
        oli.Quote_Item_Ext_Id__c='123456';
        oli.Agreement_Quote__c='testaq';
        oli.Agent_SAPUniqueId__c='654321';
        oli.PricebookEntryId = customPrice.id;
        insert oli;
        
        
    }
    static testmethod void method2()
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
        Order.Accountid=acc.id;
        Order.Pricebook2Id = customPB.Id;//Added on 21 Oct 2020 for relating order price book so ,that Pricebookentry be related
        insert order;
        
        GE_LGT_EM_MaterialMaster__c matMaster=TestDataUtil.createMaterialMaster('93036710');
        insert matMaster;
        
        OrderItem oli=TestDataUtil.createOrderItem('9999','10');
        oli.Strategic_SAPUniqueId__c='1230011644-2FR1-20-10-SP';
        oli.UnitPrice=NULL;
        oli.Quantity=NULL;
        oli.PricebookEntryId = customPrice.id;
        insert oli;
    }
}