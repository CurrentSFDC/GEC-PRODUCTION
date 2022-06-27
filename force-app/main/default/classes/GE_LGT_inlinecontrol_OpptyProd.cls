public  class GE_LGT_inlinecontrol_OpptyProd {
//Public id accRecId;
Public Opportunity_Support_Request__c osrv{get;set;}

Public list<OPPORTUNITYLINEITEM> prreclist {get;set;}
   public GE_LGT_inlinecontrol_OpptyProd(ApexPages.StandardController controller) {
   prreclist = new List<OPPORTUNITYLINEITEM>();
  if(ApexPages.currentPage().getParameters().get('id') != null) {  
  //osrv = [select id,Opportunity_Name__c,Name from Opportunity_Support_Request__c where id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
  
  //if(osrv.Opportunity_Name__c !=null)
  
  prreclist = [SELECT ID,SKUNumber__c,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c,Product2.Material_No__c,Product2.Name,Alternate_Description__c,TotalPrice,Unit_of_measure__c,product2.Levels_3__c,SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c,SKU_Number__r.GE_LGT_EM_MaterialDescription__c,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c,GE_LGT_Level1__c,GE_LGT_Level2__c,GE_LGT_Level3__c  FROM OPPORTUNITYLINEITEM where OPPORTUNITYID=:ApexPages.currentPage().getParameters().get('id')];
       }
       
}
}