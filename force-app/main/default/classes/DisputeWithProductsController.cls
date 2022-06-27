public class DisputeWithProductsController {
    
    public Id disId {get;set;}
    public Id caseId {get;set;}
    
    public List<Shipment_Detail__c> getcaseProds(){
        List<Shipment_Detail__c> caseProd;
        
        caseProd=[SELECT SAP_Material__c,No_Cat_Number__c,GE_NAS_Product_Code__c,Material_Description__c,Discrepancy_Qty__c
                  FROM Shipment_Detail__c where Dispute_Request__c= : disId LIMIT 10];
        return caseProd;
    }
    
    public List<Case> getcaseDtl(){
        List<Case> caseDtl;
        
        caseDtl=[SELECT CaseNumber
                  FROM Case where Id= : caseId LIMIT 1];
        return caseDtl;
    }
              
    }