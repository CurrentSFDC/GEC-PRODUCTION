@isTest(SeeAllData=true)
public class ProductDataTableControllerTest {
    
    public testMethod static void getproductListTest(){
        List<ccrz__E_Product__c> productList = new List<ccrz__E_Product__c>();
        ccrz__E_Product__c obj = new ccrz__E_Product__c();
        obj.ccrz__SKU__c = 'sku888';
        obj.MaterialDescription__c = '';             
        obj.ccrz__ShortDescRT__c = '';                       
        obj.Comments__c = '';
        productList.add(obj);
        insert productList;
        
        for(ccrz__E_Product__c prod: productList){
        prod.Comments__c = NULL;
        update prod;
        }
        Test.startTest();
        ProductDataTableController.getproductList(obj.Id);
        Test.stopTest();
    }
        public testmethod static void getproductRefListTest(){
            
            List<ccrz__E_Product__c> productList = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c obj = new ccrz__E_Product__c();
            obj.ccrz__SKU__c = 'sku888';
            obj.MaterialDescription__c = '';             
            obj.ccrz__ShortDescRT__c = '';                       
            obj.Comments__c = '';
            productList.add(obj);
            insert productList;
            
            Test.startTest();
            ProductDataTableController.getproductRefList(obj.id);
            Test.stopTest();
            
            
        }
    public testmethod static void getProdItemNewListTest(){
        List<ccrz__E_Product__c> productList = new List<ccrz__E_Product__c>();
            ccrz__E_Product__c obj = new ccrz__E_Product__c();
            obj.ccrz__SKU__c = 'sku888';
            obj.MaterialDescription__c = '';             
            obj.ccrz__ShortDescRT__c = '';                       
            obj.Comments__c = '';
            productList.add(obj);
            insert productList;
            
            Test.startTest();
            ProductDataTableController.getProdItemNewList(obj.id);
            Test.stopTest();
        
        
        
    }
    public testmethod static void getReturnProdListTest(){
        Return_Order_Item__c obj = new Return_Order_Item__c();
        obj.Product_SKU__c = '90999';
        obj.Product_Description__c = '';
        obj.Comments__c = '';
        obj.Transaction_ID__c = '';
        insert obj;
        
        Test.startTest();
        ProductDataTableController.getReturnProdList(obj.id);
        Test.stopTest();
        
    }
    
    @isTest
    Static void getReturnOrderItemListTest(){
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        Pricebook2 b = new Pricebook2(Name= 'TestBook1'); 
        insert b;
        
        Order o = new order(name = 'abc@xyz1.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id= b.Id;
        Insert o;
        
        Product2 p = new Product2(Name = 'TestProd1');
        Insert p;

        PricebookEntry pb = new PricebookEntry(Pricebook2Id = b.Id, UnitPrice= 500, Product2Id=p.Id);
        Insert pb;
        List<ccrz__E_Product__c> trackList = new  List<ccrz__E_Product__c> ();
        ccrz__E_Product__c c = new ccrz__E_Product__c();
        c.Name='Test';
        c.ccrz__SKU__c='11111';
        c.ccrz__ProductId__c= '123465';
        c.Quantity_Selected__c= '123';
        insert c;
        Set<String> skuIds = new Set<String>{}; 
            for (ccrz__E_Product__c tracker:trackList){
            
            if(tracker.ccrz__SKU__c != NULL) skuIds.add(tracker.ccrz__SKU__c);
            
        }
            List<Return_Order_Item__c> sortedOrders = new List<Return_Order_Item__c>{};
                Return_Order_Item__c r= new Return_Order_Item__c();
        r.SKU__c= '123';
        r.UnitPrice__c=10;
        r.Shipment_Date__c= date.today();
        r.Return_Qty__c= 5;
        r.Requested_Action_Override__c= 'Return and Replace';
        r.Quick_Configure__c= true;
        r.Quick_Stock__c= true;
        
        //insert r;   
        sortedOrders.add(r);
        Test.startTest();
        ProductDataTableController.getReturnOrderItemList(c.id);
        Test.stopTest();
    }
    
    
    
    
    
    
    
    
    public testmethod static void updateReturnItemListTest() {
      String allcontents1;
        List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(allcontents1),List<Return_Order_Item__c>.class);
        try {
            upsert ReturnListForUpdate;
        }
        catch (Exception e) {
        }
    Test.startTest();
    ProductDataTableController.updateReturnItemList(allcontents1);
    Test.stopTest();
    }




    

}