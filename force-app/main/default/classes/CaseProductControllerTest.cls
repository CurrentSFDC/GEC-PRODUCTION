@isTest
public class CaseProductControllerTest {

    @isTest
    static void getcaseProdsTest(){
        
        Test.startTest();               
        Case ca = new Case();
        insert ca;
        
        List<Shipment_Detail__c> caseProd = new List<Shipment_Detail__c>();
        Shipment_Detail__c sd = new Shipment_Detail__c();
        sd.GE_NAS_Product_Code__c = 'Test';
        sd.GE_NAS_Case_Number__c = ca.Id;
        
        caseProd.add(sd);
       // insert caseProd;
        insert sd;
        
        
        caseProd=[SELECT GE_NAS_Product_Code__c FROM Shipment_Detail__c where (GE_NAS_Product_Code__c !=null and GE_NAS_Case_Number__c=: ca.Id) LIMIT 10 ];        
        //List<Shipment_Detail__c> lt = CaseProductController.lt();
        
        CaseProductController obj = new CaseProductController();
        obj.getcaseProds();
       // CaseProductController.getcaseProds();
        Test.stopTest();

        
    }

}