@istest(SeeAllData=true)
public class ExpediteOrderProdControllerTest {
 @isTest
    Static void getExpOItemListTest()
    {
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id = b.Id;
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
        ExpediteOrderProdController.getExpOItemList(o.Id);
        Test.stopTest();
        
    }
    @isTest
    Static void getExpOItemRefListTest()
    {
        String orderId;
        
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id = b.Id;
        Insert o;
        
        Product2 p = new Product2(Name = 'TestProd');
        Insert p;

        PricebookEntry pb = new PricebookEntry(Pricebook2Id = b.Id, UnitPrice= 500, Product2Id=p.Id);
        pb.IsActive= true;
        Insert pb;
        
        OrderItem orderList = new OrderItem();
        orderList.Order_Number__c ='';
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
        insert orderList;
        
        Test.startTest();
        ExpediteOrderProdController.getExpOItemRefList(o.Id);
        Test.stopTest();
    }
    @isTest
    Static void getExpOItemNewListTest()
    {
        String transId;
        
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id = b.Id;
        Insert o;
        
        Product2 p = new Product2(Name = 'TestProd');
        Insert p;
        system.debug(p.Id);

        PricebookEntry pb = new PricebookEntry(Pricebook2Id = b.Id, UnitPrice= 500, Product2Id=p.Id);
        pb.IsActive= true;
        Insert pb;
        
        OrderItem orderList = new OrderItem();
        orderList.Order_Number__c ='';
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
        insert orderList;
        
        Test.startTest();
        ExpediteOrderProdController.getExpOItemNewList(o.Id);
        Test.stopTest();
    
    }
    @isTest
    static void updateExpReturnItemListTest(){
        Object data;
        Return_Order_Item__c ro = new Return_Order_Item__c();
        insert ro;
        List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(data),List<Return_Order_Item__c>.class);
        try {
            upsert ReturnListForUpdate Unique_ID__c;
            //return 'Success: Order Items updated successfully';
        }
        catch (Exception e) {
           // return 'The following exception has occurred: ' + e.getMessage();
        }
        Test.startTest();
        ExpediteOrderProdController.updateExpReturnItemList(data);
        Test.stopTest();
    }
    @isTest
    static void getReturnListTest(){
        String transId;
        Return_Order_Item__c ro = new Return_Order_Item__c();
        insert ro;
        
       // return [Select Order_Line_Number__c,Product_SKU__c,PO__c,Quantity__c, Quick_Configure__c,
       // UnitPrice__c, SKU__c, Shipment_Date__c, Transaction_ID__c, Requested_Delivery_Date__c, Expected_Shipment_Date__c, New_Requested_Delivery_Date__c
       // FROM Return_Order_Item__c WHERE Transaction_ID__c =:transId];
        Test.startTest();
        ExpediteOrderProdController.getReturnList(ro.Id);
        Test.stopTest(); 
       
    }
    @isTest
        static void getReturnOItmListTest(){
        String orderId;
          
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id = b.Id;
        Insert o;
            
        Return_Order_Item__c ro = new Return_Order_Item__c();
        insert ro;
        
        Product2 p = new Product2(Name = 'TestProd');
        Insert p;
            
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = b.Id, UnitPrice= 500, Product2Id=p.Id);
        pb.IsActive= true;
        Insert pb;
            
        List<OrderItem> trackList = new List<OrderItem>();
        OrderItem tr = new OrderItem();
            tr.SKU__c = 'sku777';
            tr.OrderId = o.Id;
            tr.PricebookEntryId = pb.id;
           // insert tr;
        trackList.add(tr);
            insert trackList;
          //  List<OrderItem> trackList = [select SKU__c from OrderItem where orderId = :o.Id] ;

       // trackList.add(tr);
      //  insert trackList;

        List<Return_Order_Item__c> sortedOrders = new List<Return_Order_Item__c>{};
        Set<String> skuIds = new Set<String>{};
        
        for (OrderItem tracker:trackList){
            
            if(tracker.SKU__c != NULL) skuIds.add(tracker.SKU__c);
            
        }
        
        if (skuIds.size() > 0){
     
            sortedOrders = [Select Order_Line_Number__c,
               SKU__c, 
               Quantity__c, 
               UnitPrice__c,
               PO__c, 
               Requested_Delivery_Date__c,
               Expected_Shipment_Date__c,               
               Shipment_Date__c ,
               New_Requested_Delivery_Date__c               
               From Return_Order_Item__c where SKU__c=:skuIds];
        }
        Test.startTest();
        ExpediteOrderProdController.getReturnOItmList(o.Id);
        Test.stopTest(); 
        
       // return sortedOrders;
    }
    
    
    
    
    
}