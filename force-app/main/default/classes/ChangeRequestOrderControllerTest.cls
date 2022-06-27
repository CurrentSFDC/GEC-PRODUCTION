/*
Name - ChangeRequestOrderControllerTest
Methods - getChangeRequestOItemTest
		  getChangeReqRefListTest
          getChangeReqUpdItemTest
		  getChangeReqCartItemTest
		  updReturnItemListTest

Purpose - Test Class for ChangeRequestOrderController
*/


@isTest
public class ChangeRequestOrderControllerTest {
    
        static testMethod void getChangeRequestOItemTest(){
            
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
        oList.add(orderList);
        //  insert orderList;

            for(OrderItem ord: oList){
        		ord.Category_Of_Change__c = NULL;
       			// update ord;
        	}
        
        Test.startTest();
        ChangeRequestOrderController.getChangeRequestOItem(o.Id);
        Test.stopTest();
            
    }
    static testmethod void getChangeReqRefListTest(){
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
        oList.add(orderList);
        //  insert orderList;
        
        Test.startTest();
        ChangeRequestOrderController.getChangeReqRefList(o.Id);
        Test.stopTest();
            
        
    }
    
    static testmethod void getChangeReqUpdItemTest(){
        string transId;
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
        oList.add(orderList);
        //  insert orderList;
        
        Test.startTest();
        ChangeRequestOrderController.getChangeReqUpdItem(transId);
        ChangeRequestOrderController.updDisName(o.Id, 'Border States');
        Test.stopTest();
            
        
    }
    static testmethod void getChangeReqCartItemTest(){
        string transId;
        
        Return_Order_Item__c ro = new Return_Order_Item__c();
        insert ro;
        
        Test.startTest();
        ChangeRequestOrderController.getChangeReqCartItem(transId);
        Test.stopTest();
    }
    static testmethod void updReturnItemListTest(){
        Return_Order_Item__c ro = new Return_Order_Item__c();
        insert ro;
        Object data;
        Test.startTest();
        ChangeRequestOrderController.updReturnItemList(data);
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
        ChangeRequestOrderController.updDisName(o.Id, 'Test Name');
        Test.stopTest();
            
    }

    


}