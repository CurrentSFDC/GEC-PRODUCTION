public class CaseProductController {
public Id caseId {get;set;}
    
    public List<Shipment_Detail__c> getcaseProds(){
        List<Shipment_Detail__c> caseProd;
        
    //  caseProd=[SELECT GE_NAS_Product_Code__c FROM Shipment_Detail__c where GE_NAS_Case_Number__c= : caseId LIMIT 10 ];
      caseProd=[SELECT GE_NAS_Product_Code__c FROM Shipment_Detail__c where (GE_NAS_Product_Code__c !=null and GE_NAS_Case_Number__c=: caseId) LIMIT 10 ];
   //   caseProd=[  SELECT GE_NAS_Product_Code__c FROM Shipment_Detail__c where GE_NAS_Product_Code__c !=null LIMIT 10 ];
        return caseProd;
    }
    
  
}