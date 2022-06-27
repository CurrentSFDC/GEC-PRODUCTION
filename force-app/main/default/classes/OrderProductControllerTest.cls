/*

Name - OrderProductControllerTest
Methods - getOrderItemListTest
          getOrderItemRefList
          getReturnListTest
          getReturnOrderItemListTest
          delReturnItemsTest
          updateReturnItemListTest
          displayUpdatedListTest
Purpose - Test Class for OrderProductController

*/

@isTest(SeeAllData=true)
public class OrderProductControllerTest {
    
    /* Class: OrderProductController, Method:getOrderItemList */
    
    @isTest
    Static void getOrderItemListTest()
    {
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id = b.Id;
        o.GE_Order_NO__c = '12345';
        Insert o;
        
        Product2 p = new Product2(Name = 'TestProd');
        Insert p;

        PricebookEntry pb = new PricebookEntry(Pricebook2Id = b.Id, UnitPrice= 500, Product2Id=p.Id);
        pb.IsActive= true;
        Insert pb;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = o.id;
        oi.SKU__c = '123456';
        oi.Quantity= 2;
        oi.UnitPrice= 1000;
        oi.Quick_Configure__c= True;
        oi.Quick_Stock__c = True;
        oi.Shipment_Date__c= Date.today();
        oi.Requested_Action_Override__c= 'Return'; 
        oi.PricebookEntryId = pb.Id;
        oi.Product2Id = p.Id;
        Insert oi;
        
        Test.startTest();
        OrderProductController.getOrderItemList(o.Id);
        OrderProductController.getOrderId('12345');
        OrderProductController.getOrderDetails(o.Id);
        Test.stopTest();
        
    }
    
    /* Class: OrderProductController, Method:getOrderItemRef */
    
     @isTest
    Static void getOrderItemRefList()
    {
        Account Acc11 = new Account(Name = 'TestAcc11');
        Insert Acc11;
        
        Pricebook2 b11 = new Pricebook2(Name= 'TestBook11');
        insert b11;
        
        Order o11 = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o11.AccountId = Acc11.Id;
        o11.Pricebook2Id = b11.Id;
        Insert o11;
        
        Product2 p11 = new Product2(Name = 'TestProd11');
        Insert p11;
        PricebookEntry pb11 = new PricebookEntry(Pricebook2Id = b11.Id, UnitPrice= 500, Product2Id=p11.Id);
        pb11.IsActive= true;
        Insert pb11;
        
        OrderItem oi11 = new OrderItem();
        oi11.OrderId = o11.id;
        oi11.SKU__c = '123456';
        oi11.Quantity= 2;
        oi11.UnitPrice= 1000;
        oi11.Quick_Configure__c= True;
        oi11.Quick_Stock__c = True;
        oi11.Shipment_Date__c= Date.today();
        oi11.Requested_Action_Override__c= 'Return';
        oi11.PricebookEntryId = pb11.Id;
        oi11.Product2Id = p11.Id;
        Insert oi11;
        
        Test.startTest();
        OrderProductController.getOrderItemRefList(o11.Id);
        Test.stopTest();
        
    }
    
    /* Class: OrderProductController, Method:getReturnList */
    
     @isTest
    Static void getReturnListTest(){
        Account Acc2 = new Account(Name = 'TestAcc2');
        Insert Acc2;
        Pricebook2 b2 = new Pricebook2(Name= 'TestBook2');
        insert b2;
        
        Order o2 = new order(name = 'abc@xyz2.com', EffectiveDate = date.today(), Status = 'Draft');
        o2.AccountId = Acc2.Id;
        o2.Pricebook2Id= b2.Id;
        Insert o2;
        
        Product2 p2 = new Product2(Name = 'TestProd2');
        Insert p2;
       
        PricebookEntry pb2 = new PricebookEntry(Pricebook2Id = b2.Id, UnitPrice= 500, Product2Id=p2.Id);
        Insert pb2;
        
        OrderItem oi2 = new OrderItem();
        oi2.OrderId = o2.id;
       // oi2.PricebookEntryId = [Select Id from PricebookEntry limit 1].Id;
        oi2.PricebookEntryId = pb2.Id;
        insert oi2;
        List<Return_Order_Item__c> sortedOrders1 = new List<Return_Order_Item__c>{};
        Return_Order_Item__c r1= new Return_Order_Item__c();
        r1.SKU__c= '123456';
        r1.UnitPrice__c=1000;
        r1.Quick_Configure__c= true;
        r1.Quick_Stock__c= true;
        r1.Shipment_Date__c= date.today();
        r1.Return_Qty__c= 2;
        r1.Requested_Action_Override__c= 'Return and Replace';
        r1.Transaction_ID__c = '123456';
        //insert r;   
        sortedOrders1.add(r1);
        Test.startTest();
        OrderProductController.getReturnList(r1.Transaction_ID__c);
        Test.stopTest();
    }
    
    /* Class: OrderProductController, Method:getReturnOrderItemList */
    
    @isTest
    Static void getReturnOrderItemListTest(){
        Account Acc1 = new Account(Name = 'TestAcc1');
        Insert Acc1;
        Pricebook2 b1 = new Pricebook2(Name= 'TestBook1');
        insert b1;
        
        Order o1 = new order(name = 'abc@xyz1.com', EffectiveDate = date.today(), Status = 'Draft');
        o1.AccountId = Acc1.Id;
        o1.Pricebook2Id= b1.Id;
        Insert o1;
        
        Product2 p1 = new Product2(Name = 'TestProd1');
        Insert p1;

        PricebookEntry pb1 = new PricebookEntry(Pricebook2Id = b1.Id, UnitPrice= 500, Product2Id=p1.Id);
        Insert pb1;
        List<OrderItem> trackList = new  List<OrderItem> ();
        Set<String> skuIds = new Set<String>{};
            
        
        OrderItem oi1 = new OrderItem();
        oi1.OrderId = o1.id;
       // oi1.PricebookEntryId = [Select Id from PricebookEntry limit 1].Id;
        oi1.PricebookEntryId = pb1.Id;

        insert oi1;
        List<Return_Order_Item__c> sortedOrders = new List<Return_Order_Item__c>{};
            for (OrderItem tracker:trackList){
            
            if(tracker.SKU__c != NULL) skuIds.add(tracker.SKU__c);   
        }
        if (skuIds.size() > 0){
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
        }
        Test.startTest();
        OrderProductController.getReturnOrderItemList(o1.Id);
        Test.stopTest();
    }
   
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
        OrderProductController.updateReturnItemList(allcontents1);
        Test.stopTest();  
     }
    
    /* Class: OrderProductController, Method:delReturnItems */
    
    @isTest
    Static void delReturnItemsTest(){
        String allcontents2;
        List<Return_Order_Item__c> OrderItemForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(allcontents2),List<Return_Order_Item__c>.class);
        try {
        update OrderItemForUpdate;
    }
    catch (Exception e) {
    }
        Test.startTest();
        OrderProductController.delReturnItems(allcontents2);
        Test.stopTest();
    }
    
    /* Class: OrderProductController, Method:displayUpdatedList */
    
    @isTest
    Static void displayUpdatedListTest(){
        Account Acc3 = new Account(Name = 'TestAcc3');
        Insert Acc3;
        Pricebook2 b3 = new Pricebook2(Name= 'TestBook4');
        insert b3;
        
        Order o3 = new order(name = 'abc@xyz3.com', EffectiveDate = date.today(), Status = 'Draft');
        o3.AccountId = Acc3.Id;
        o3.Pricebook2Id= b3.Id;
        Insert o3;
        
        Product2 p3 = new Product2(Name = 'TestProd3');
        Insert p3;
        
        PricebookEntry pb3 = new PricebookEntry(Pricebook2Id = b3.Id, UnitPrice= 500, Product2Id=p3.Id);
        Insert pb3;
        
        OrderItem oi3 = new OrderItem();
        oi3.OrderId = o3.id;
        //oi3.PricebookEntryId = [Select Id from PricebookEntry limit 1].Id;
        oi3.PricebookEntryId = pb3.id;

        insert oi3;
        List<Return_Order_Item__c> sortedOrders2 = new List<Return_Order_Item__c>{};
        Return_Order_Item__c r11= new Return_Order_Item__c();
        r11.SKU__c= '1234567';
        r11.UnitPrice__c=1000;
        r11.Quick_Configure__c= true;
        r11.Quick_Stock__c= true;
        r11.Shipment_Date__c= date.today();
        r11.Return_Qty__c= 2;
        r11.Requested_Action_Override__c= 'Return and Replace';
        r11.Transaction_ID__c = '1234567';
        //insert r;   
        sortedOrders2.add(r11);
        Test.startTest();
        OrderProductController.displayUpdatedList(r11.Transaction_ID__c);
        Test.stopTest();
    }
    @isTest
    static void updateOrderItemListTest() {
        Account Acc3 = new Account(Name = 'TestAcc3');
        Insert Acc3;
        Pricebook2 b3 = new Pricebook2(Name= 'TestBook4');
        insert b3;
        
        Order o3 = new order(name = 'abc@xyz3.com', EffectiveDate = date.today(), Status = 'Draft');
        o3.AccountId = Acc3.Id;
        o3.Pricebook2Id= b3.Id;
        Insert o3;
        
        Product2 p3 = new Product2(Name = 'TestProd3');
        Insert p3;
        
        PricebookEntry pb3 = new PricebookEntry(Pricebook2Id = b3.Id, UnitPrice= 500, Product2Id=p3.Id);
        Insert pb3;
        
		OrderItem oi3 = new OrderItem();
        oi3.OrderId = o3.id;
        //oi3.PricebookEntryId = [Select Id from PricebookEntry limit 1].Id;
        oi3.PricebookEntryId = pb3.Id;

        insert oi3; 
        
        Test.startTest();
        OrderProductController.updateOrderItemList(oi3);
        Test.stopTest();
        
        //upsert data Id;
        //return 'Success: Order Items updated successfully';
    }
    @isTest
    static void orderListDataTest(){
        
        Account Acc3 = new Account(Name = 'TestAcc3');
        Insert Acc3;
        Pricebook2 b3 = new Pricebook2(Name= 'TestBook4');
        insert b3;
        
        Order o3 = new order(name = 'abc@xyz3.com', EffectiveDate = date.today(), Status = 'Draft');
        o3.AccountId = Acc3.Id;
        o3.Pricebook2Id= b3.Id;
        Insert o3;
        
        Product2 p3 = new Product2(Name = 'TestProd3');
        Insert p3;
        
        PricebookEntry pb3 = new PricebookEntry(Pricebook2Id = b3.Id, UnitPrice= 500, Product2Id=p3.Id);
        Insert pb3;
        
        OrderItem oi3 = new OrderItem();
        oi3.OrderId = o3.id;
        //oi3.PricebookEntryId = [Select Id from PricebookEntry limit 1].Id;
        oi3.PricebookEntryId = pb3.id;

        insert oi3;
        
        List<Return_Order_Item__c> sortedOrders2 = new List<Return_Order_Item__c>{};
        Return_Order_Item__c r11= new Return_Order_Item__c();
        r11.SKU__c= '1234567';
        r11.UnitPrice__c=1000;
        r11.Quick_Configure__c= true;
        r11.Quick_Stock__c= true;
        r11.Shipment_Date__c= date.today();
        r11.Return_Qty__c= 2;
        r11.Requested_Action_Override__c= 'Return and Replace';
        r11.Transaction_ID__c = '1234567';
        //insert r;   
        sortedOrders2.add(r11);
        Test.startTest();
        OrderProductController.orderListData(r11.Transaction_ID__c);
        Test.stopTest();
        
        
    }
static testMethod void updDisNameTest(){
            
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order();
        
        o.Name = 'Order121';
        o.Status = 'Draft';
        o.AccountId = Acc.Id;
        o.EffectiveDate = date.today();
        o.Pricebook2Id = b.Id;
      //  Insert o;
        system.debug(o.Pricebook2Id);
            
        Product2 p = new Product2();
        p.Name = 'TestProd';
       // Insert p;
        system.debug(p);
        system.debug(p.Id);

        

        PricebookEntry pb = new PricebookEntry();
            pb.Product2Id = '01t3j000005itzNAAQ';
        pb.Pricebook2Id = b.Id;
            system.debug(pb);
        pb.UnitPrice = 300;
            system.debug(pb);
      //  pb.Product2Id = p.Id;
       //     system.debug(pb.Product2Id);
        pb.IsActive= true;
        Insert pb;
            system.debug(pb);
          //  system.debug(pb.Product2Id);
            
            
        List<OrderItem> oList = new List<OrderItem>();  
        OrderItem orderList = new OrderItem();
        orderList.Order_Number__c = '01346383';
        orderList.Order_Line_Number__c='';
        
        
        orderList.OrderId = o.id;
        orderList.SKU__c = '123456';
        orderList.Quantity= 2;
        orderList.UnitPrice= 1000;
        orderList.Quick_Configure__c= True;
        orderList.Quick_Stock__c = True;
        orderList.Shipment_Date__c= Date.today();
        orderList.Requested_Action_Override__c= 'Return'; 
        orderList.PricebookEntryId = pb.Id;
        orderList.Product2Id = p.Id;
        orderList.Category_Of_Change__c = 'Increase quantity';
        orderList.Distributor_Name__c='Test Dis';
        oList.add(orderList);
        //  insert orderList;

            for(OrderItem ord: oList){
        		ord.Category_Of_Change__c = NULL;
                ord.Distributor_Name__c='Test NAme';
       			// update ord;
        	}
        
        Test.startTest();
        OrderProductController.updDisName(o.Id, 'Test Name');
        Test.stopTest();
            
    }

    
    
}