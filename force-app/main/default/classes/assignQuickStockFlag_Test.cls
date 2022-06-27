@isTest
public with sharing class assignQuickStockFlag_Test {
   @isTest static  void Testmethod1(){
        //CREATE CC PRODUCT
        ccrz__E_Product__c ccProd = new ccrz__E_Product__c();
        ccProd.Name = 'LRXR818840MD';
        ccProd.ccrz__SKU__c = '93034755';
        ccProd.Quickship__c = true;
        insert ccProd;

        Sales_Org_Product__c sop = new Sales_Org_Product__c();
        sop.CC_Product__c = ccProd.id;
        sop.QuickStock__C = true;
        sop.Sales_Org_Agent__c = '1US1';
        sop.SKU__c = '93034755';
       insert sop;
        
       Test.startTest();
        
        List<Sales_Org_Product__c> sopList = [SELECT Id, SKU__c, Sales_Org_Agent__c from Sales_Org_Product__c where Id =: sop.id];

        UpdateInvoiceLinesQuickStock obj = new UpdateInvoiceLinesQuickStock();
        obj.assignQuickStockFlag(sopList);
       
       	sop.QuickStock__c = false;
        Database.update(sop);
       Test.stopTest();

    }
}