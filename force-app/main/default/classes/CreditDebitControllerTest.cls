@isTest
public class CreditDebitControllerTest {
    @isTest
    public static void getInvoiceListTest(){
        List<GE_LGT_EM_InvoiceLineItem__c> invo = new List<GE_LGT_EM_InvoiceLineItem__c>();
        List<GE_LGT_EM_InvoiceLineItem__c> invo1 = new List<GE_LGT_EM_InvoiceLineItem__c>();
        GE_LGT_EM_InvoiceLineItem__c invoiceList = new GE_LGT_EM_InvoiceLineItem__c();
        invoiceList.GE_LGT_EM_SAP_Invoice_Number__c = '7878';
          //  invoiceList.SKU__c = 'sku888';
            invoiceList.GE_LGT_EM_Customer_PO_Number__c = '88';
            invoiceList.GE_LGT_EM_Invoiced_Quantity__c = 9;
          //  invoiceList.GE_LGT_EM_Invoiced_Price__c = 99;
          //  invoiceList.Extended_Amount__c = 8;
            invoiceList.Reason_Code__c = 'Tax';
            invoiceList.Action_Override__c = 'Debit';
            invoiceList.Comment__c = 'TEST COMMENT';
        insert invoiceList;
        invo.add(invoiceList);
        System.debug('invoiceList*************'+invoiceList);
        System.debug('invo*************'+invo);

        
        for(GE_LGT_EM_InvoiceLineItem__c invoiceList1: invo){
        System.debug('invo*************'+invo);
        invoiceList1.Reason_Code__c = NULL;    
        invoiceList1.Action_Override__c= NULL;
        invoiceList1.Comment__c= NULL;

        update invoiceList1;
        System.debug('invoiceList1*************'+invoiceList1);

        }
        
        Test.startTest();
        CreditDebitController.getInvoiceList(invoiceList.Id);
        Test.stopTest();      
    }
    
    @isTest
    public static void getInvoiceItemRefListTest(){
        GE_LGT_EM_InvoiceLineItem__c invoiceList = new GE_LGT_EM_InvoiceLineItem__c();
        invoiceList.GE_LGT_EM_SAP_Invoice_Number__c = '7878';
            invoiceList.GE_LGT_EM_Customer_PO_Number__c = '88';
            invoiceList.GE_LGT_EM_Invoiced_Quantity__c = 9;
            invoiceList.Reason_Code__c = '';
            invoiceList.Action_Override__c = '';
            invoiceList.Comment__c = '';
        insert invoiceList;
        
        Test.startTest();
        CreditDebitController.getInvoiceItemRefList(invoiceList.Id);
        Test.stopTest();      
    
    }
    @isTest
    public static void invoiceListDataTest(){
        GE_LGT_EM_InvoiceLineItem__c invoiceList = new GE_LGT_EM_InvoiceLineItem__c();
        invoiceList.GE_LGT_EM_SAP_Invoice_Number__c = '7878';
            invoiceList.GE_LGT_EM_Customer_PO_Number__c = '88';
            invoiceList.GE_LGT_EM_Invoiced_Quantity__c = 9;
            invoiceList.Reason_Code__c = '';
            invoiceList.Action_Override__c = '';
            invoiceList.Comment__c = '';
        insert invoiceList;
        
        Test.startTest();
        CreditDebitController.invoiceListData(invoiceList.Id);
        Test.stopTest();      

    }
   /* @isTest
    public static void updateReturnItemListTest(){
        Object data = '[{color: "red",value: "#f00"},{color: "green",value: "#0f0"}]';
        List<Return_Order_Item__c> ReturnListForUpdate = new List<Return_Order_Item__c>();
        Return_Order_Item__c obj = new Return_Order_Item__c();
        ReturnListForUpdate.add(obj);
        insert ReturnListForUpdate;
        
        try {
        upsert ReturnListForUpdate Unique_ID__c;
       // return 'Success: Order Items updated successfully';
    }
    catch (Exception e) {
      //  return 'The following exception has occurred: ' + e.getMessage();
    }
        
        
        Test.startTest();
        CreditDebitController.updateReturnItemList(data);
        Test.stopTest();
        
        
    }*/
    
     @isTest
    Static void updateReturnItemListTest1(){
        String allcontents1;
        List<Return_Order_Item__c> ReturnListForUpdate = (List<Return_Order_Item__c>) JSON.deserialize(JSON.serialize(allcontents1),List<Return_Order_Item__c>.class);
        try {
            upsert ReturnListForUpdate;
        }
        catch (Exception e) {
        }
        Test.startTest();
         CreditDebitController.updateReturnItemList(allcontents1);
        Test.stopTest();  
    }
    
    
    
    
    
    @isTest
    public static void getReturnList(){
        Return_Order_Item__c obj = new Return_Order_Item__c();
        obj.Order_Line_Number__c = ''; 
        obj.SKU__c = '';
        obj.PO__c = '';
        obj.Quantity__c = 9;
        obj.UnitPrice__c = 90;
        obj.Extended_Amount__c = 9;
        obj.Reason_Code__c = ''; 
        obj.Requested_Action_Override__c = ''; 
        obj.Comments__c = '';
        obj.Transaction_ID__c = '';
        insert obj;
        
        Test.startTest();
        CreditDebitController.getReturnList(obj.Id);
        Test.stopTest();
        
         
    }
    
    @isTest
    static void getAgentIdTest1(){
     
        String id_dtl;
        Account acc = new Account();
        acc.Name = 'Acc232';
		acc.Account_Group__c='TEST';        
        insert acc;
        
        contact ca1 = new contact();
        ca1.AccountId= acc.id;
        ca1.FirstName= 'testCon';
        ca1.LastName= 'test';
        ca1.Email='abc@xyz.com';
        insert ca1;
        
        
        Test.startTest();
        CreditDebitController.getAgentId(acc.Id);
        Test.stopTest();
        
    }
}