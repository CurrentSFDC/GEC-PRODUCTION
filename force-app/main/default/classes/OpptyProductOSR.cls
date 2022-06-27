public  class OpptyProductOSR {
        //Rashmitha Changed the API vesion from 36 to 45 on 6-Mar-2019 as per 1447 request
Public id accRecId;
Public Opportunity_Support_Request__c osrv{get;set;}

Public list<OPPORTUNITYLINEITEM> prreclist {get;set;}
   public OpptyProductOSR(ApexPages.StandardController controller) {
   prreclist = new List<OPPORTUNITYLINEITEM>();
  if(ApexPages.currentPage().getParameters().get('id') != null) {  
  osrv = [select id,Opportunity_Name__c,Name from Opportunity_Support_Request__c where id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
  
  if(osrv.Opportunity_Name__c !=null)
  
  prreclist = [SELECT ID,Product2.Name,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,
  PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,
  GE_LGT_Product_Line__c,SKU__c
     FROM OPPORTUNITYLINEITEM 
     where OPPORTUNITYID=:osrv.Opportunity_Name__c];
       }
}
public void saveAll()
{
    if(prreclist != NULL && prreclist.size()>0 )
    {
        update prreclist;
    }
}
}