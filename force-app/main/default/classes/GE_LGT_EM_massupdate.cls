public class GE_LGT_EM_massupdate {

public integer CompLineSize {get;set;}
Id Caseid = System.currentPageReference().getParameters().get('id');


    public GE_LGT_EM_massupdate(ApexPages.StandardSetController controller) {

    }
public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Name,GE_LGT_EM_RequestedQuantity__c,GE_LGT_EM_Approved_Price_Unit__c,GE_LGT_EM_ApprovedQuantity__c,GE_LGT_Req_Price__c,GE_LGT_EM_Req_Price_Unit__c,GE_LGT_EM_ApprovedUnitPrice__c,GE_LGT_EM_Category__c,GE_LGT_EM_Doc_Type__c,GE_LGT_EM_Manual_CR_DR_RE__c,GE_LGT_EM_CM_DM_RO_Number__c,GE_LGT_EM_CMR_DMR_RO_Number__c,GE_LGT_EM_ApprovingFunction__c,GE_LGT_EM_Status__c,GE_LGT_EM_InvoicedQuantity__c,GE_LGT_EM_InvoicedPrice__c,GE_LGT_EM_Invoiced_Price_Unit__c,GE_LGT_EM_Manual_Invoice_Number__c FROM GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_CaseNumber__c=:Caseid]));
                setCon.setPageSize(100);                    
            }
            
            return setCon;
        }
        set;
    }

 public List<GE_LGT_EM_ComplaintLineItem__c> getupdatelineItem() {
        CompLineSize=setCon.getRecords().size();
        return (List<GE_LGT_EM_ComplaintLineItem__c>) setCon.getRecords();
    }
public PageReference saveRecord() {
            setCon.save();
            return null;
  }  

}