public  class GE_LGT_inlinecontrol {
    //Rashmitha Changed the API vesion from 33 to 45 on 6-Mar-2019 as per 1447 request
Public id accRecId;
Public Opportunity_Support_Request__c osrv{get;set;}

Public list<OPPORTUNITYLINEITEM> prreclist {get;set;}
   public GE_LGT_inlinecontrol(ApexPages.StandardController controller) {
   prreclist = new List<OPPORTUNITYLINEITEM>();
  if(ApexPages.currentPage().getParameters().get('id') != null) {  
  osrv = [select id,Opportunity_Name__c,Name from Opportunity_Support_Request__c where id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
  
  if(osrv.Opportunity_Name__c !=null)
  
  prreclist = [SELECT ID,Product2.Name,product2.Hierarchy_Level_4_Description__c,product2.Hierarchy_Level_3_Description__c,product2.Hierarchy_Level_1_Description__c,product2.Hierarchy_Level_2_Description__c,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c  FROM OPPORTUNITYLINEITEM where OPPORTUNITYID=:osrv.Opportunity_Name__c];
       }
}
}