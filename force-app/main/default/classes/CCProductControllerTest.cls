/*
Name - CCProductControllerTest
Methods- getproductListTest
         getproductRefListTest
         getReturnProdListTest
         getReturnOrderItemListTest
         updateReturnItemListTest
		 getReturnProdPriListTest
Purpose - Test Class for CCProductController
*/  

 

@isTest(SeeAllData = true)
public class CCProductControllerTest {
    static private map<String, Schema.RecordTypeInfo> accRTmap = ccrz__E_Product__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    
    /* Class: CCProductController, Method:getproductList */
    
    @isTest
    Static void getproductListTest()
    {
        List<ccrz__E_Product__c> prodlist = new List<ccrz__E_Product__c>();
        ccrz__E_Product__c c = new ccrz__E_Product__c();
        c.Name ='Test';
        c.ccrz__SKU__c='11111';
        c.ccrz__ProductId__c= '123456';
        c.Quantity_Selected__c= '1';
        insert c;
        
        for(ccrz__E_Product__c prod: prodlist){
        prod.Quantity_Selected__c = NULL;
        update prod;
        }
        Test.startTest();
        CCProductController.getproductList(c.id);
        Test.stopTest();
        
    }
    
    /* Class: CCProductController, Method:getproductRefList */
    
    
    @isTest
    Static void getproductRefListTest(){
        List<ccrz__E_Product__c> cc1 = new  List<ccrz__E_Product__c>();
        ccrz__E_Product__c c1 = new ccrz__E_Product__c();
        c1.Name='Test';
        c1.ccrz__SKU__c='11111';
        c1.ccrz__ProductId__c= '123456';
        c1.Quantity_Selected__c= '123.00';
        cc1.add(c1);
        Test.startTest();
        CCProductController.getproductRefList(c1.ccrz__ProductId__c);
        Test.stopTest();
    }
    
    /* Class: CCProductController, Method:getReturnProdList */
    
    @isTest
    Static void getReturnProdListTest(){
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz2.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id= b.Id;
        Insert o;
        
        Product2 p = new Product2(Name = 'TestProd');
        Insert p;
        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = b.Id, UnitPrice= 500, Product2Id=p.Id);
        Insert pb;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = o.id;
        oi.PricebookEntryId = pb.Id;
        insert oi;
        List<Return_Order_Item__c> sortedOrders = new List<Return_Order_Item__c>{};
            Return_Order_Item__c r= new Return_Order_Item__c();
        r.SKU__c= '123456';
        r.UnitPrice__c=1000;
        r.Quick_Configure__c= true;
        r.Quick_Stock__c= true;
        r.Shipment_Date__c= date.today();
        r.Return_Qty__c= 2;
        r.Requested_Action_Override__c= 'Return and Replace';
        r.Transaction_ID__c = '123456';
        sortedOrders.add(r);
        Test.startTest();
        CCProductController.getReturnProdList(r.Transaction_ID__c);
        Test.stopTest();
    }
     /* Class: CCProductController, Method:getReturnProdPriList */

     @isTest
    static void getReturnProdPriListTest(){
        //String transId = 'id6545.5400000792';
       // System.debug('Transaction ID: '+ transId);
        
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz2.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id= b.Id;
        Insert o;
        
        Product2 p = new Product2(Name = 'TestProd');
        Insert p;
        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = b.Id, UnitPrice= 500, Product2Id=p.Id);
        Insert pb;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = o.id;
        oi.PricebookEntryId = pb.Id;
        insert oi;
        List<Return_Order_Item__c> sortedOrders = new List<Return_Order_Item__c>{};
            Return_Order_Item__c r= new Return_Order_Item__c();
        r.SKU__c= '123456';
        r.UnitPrice__c=1000;
        r.Quick_Configure__c= true;
        r.Quick_Stock__c= true;
        r.Shipment_Date__c= date.today();
        r.Return_Qty__c= 2;
        r.Requested_Action_Override__c= 'Return and Replace';
        r.Transaction_ID__c = '123456';
               
        Test.startTest();
        CCProductController.getReturnProdPriList(r.Transaction_ID__c);
        Test.stopTest();
    }
    
    
    /* Class: CCProductController, Method:getReturnOrderItemList */
    
    @isTest
    Static void getReturnOrderItemListTest(){
        Account Acc1 = new Account(Name = 'TestAcc1');
        Insert Acc1;
        Pricebook2 b1 = new Pricebook2(Name= 'TestBook1'); 
        insert b1;
        
        Order o1 = new order(name = 'abc@xyz1.com', EffectiveDate = date.today(), Status = 'Draft');
        o1.AccountId = Acc1.Id;
        o1.Pricebook2Id= b1.Id;
       // Insert o1;
        
        Product2 p1 = new Product2(Name = 'TestProd1');
        Insert p1;

 

        PricebookEntry pb1 = new PricebookEntry(Pricebook2Id = b1.Id, UnitPrice= 500, Product2Id=p1.Id);
        Insert pb1;
        List<ccrz__E_Product__c> trackList = new  List<ccrz__E_Product__c> ();
        ccrz__E_Product__c c4 = new ccrz__E_Product__c();
        c4.Name='Test';
        c4.ccrz__SKU__c='11111';
        c4.ccrz__ProductId__c= '123465';
        c4.Quantity_Selected__c= '123';
        insert c4;
        Set<String> skuIds = new Set<String>{}; 
            for (ccrz__E_Product__c tracker:trackList){
            
            if(tracker.ccrz__SKU__c != NULL) skuIds.add(tracker.ccrz__SKU__c);
            
        }
            List<Return_Order_Item__c> sortedOrders = new List<Return_Order_Item__c>{};
                Return_Order_Item__c r= new Return_Order_Item__c();
        r.SKU__c= '123456';
        r.UnitPrice__c=1000;
        r.Quick_Configure__c= true;
        r.Quick_Stock__c= true;
        r.Shipment_Date__c= date.today();
        r.Return_Qty__c= 2;
        r.Requested_Action_Override__c= 'Return and Replace';
        //insert r;   
        sortedOrders.add(r);
        Test.startTest();
        CCProductController.getReturnOrderItemList(c4.id);
        Test.stopTest();
    }
    
    /* Class: CCProductController, Method:updateReturnItemList */
    
    
    @isTest
    Static void updateReturnItemListTest(){
        String allcontents1;
        List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(allcontents1),List<Return_Order_Item__c>.class);
        try {
            upsert ReturnListForUpdate;
        }
        catch (Exception e) {
        }
        Test.startTest();
        CCProductController.updateReturnItemList(allcontents1);
        Test.stopTest();  
    }
    
       
}