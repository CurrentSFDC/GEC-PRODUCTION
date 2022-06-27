public  class GE_LGT_inlinecontrol_Sample {
Public Sample__c smrec{get;set;}
Public list<OPPORTUNITYLINEITEM> prreclist {get;set;}
    public GE_LGT_inlinecontrol_Sample(ApexPages.StandardController controller) {
        prreclist = new List<OPPORTUNITYLINEITEM>();
        if(ApexPages.currentPage().getParameters().get('id') != null) {  
            smrec = [select id,Opportunity__c,Name from Sample__c where id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
            if(smrec.Opportunity__c !=null)
            prreclist = [SELECT ID,Product2.Name,TotalPrice,Unit_of_measure__c,product2.Levels_3__c,SKU_Number__r.GE_LGT_EM_SAP_MaterialNumber__c,SKU_Number__r.GE_LGT_EM_MaterialDescription__c,OPPORTUNITYID,PRICEBOOKENTRYID,GE_LGT_Requested_Price__c,OPPORTUNITY.CurrencyIsoCode,PRICEBOOKENTRY.CurrencyIsoCode,GE_LGT_Product_Name__c,PRICEBOOKENTRY.Name,QUANTITY,ServiceDate,UNITPRICE,Description,Confirmed__c,Cut_off_date__c,GE_LGT_Level1__c,GE_LGT_Level2__c,GE_LGT_Level3__c  FROM OPPORTUNITYLINEITEM where OPPORTUNITYID=:smrec.Opportunity__c];
        }
    }
}