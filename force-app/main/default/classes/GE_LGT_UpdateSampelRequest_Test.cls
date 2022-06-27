@isTest
Public class GE_LGT_UpdateSampelRequest_Test
{
public static Sample__c createSample(string region,id oppid,string ordNo,boolean isinsert){
    Sample__c sam=new Sample__c();
    sam.Opportunity__c=oppid;
    sam.Bill_To_Same_as_Ship_To__c=true;
    sam.Quote_Order_Number__c=ordNo;
    sam.Bill_to_Region__c=region;
    sam.recordtypeid='0123j000000X91N';
    if(isinsert)insert sam;
    return sam;
    

}

    static testMethod void SampleRequest1()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        triggerSwitches.get('OpportunityTrigger').isActive__c=true;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();  
        Account acc1 =TestDataUtil.createAccount(); 
        acc1.RecordTypeId = recAccTypeId;acc1.Name='Test Acc';acc1.Type='End User';acc1.GE_LGT_Vertical__c='Finan';         
        acc1.BillingCountry='US';
        insert acc1;
        
        ID rectypeID= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
        Opportunity opp=TestDataUtil.createOpportunity(acc1); 
        opp.RecordTypeId = rectypeID;    
        opp.Name='TestClasscheck';    
        opp.StageName='S1 Consult'; 
        opp.Type='End User - Retrofit';
        opp.GE_LGT_Probability_Pctg__c='20';  
        opp.GE_LGT_End_User__c=acc1.ID; 
        opp.CloseDate= System.Today()+1;   
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today()+2; 
        opp.GE_LGT_Expected_Ship_Date__c = System.Today()+3;  
      
        opp.CurrencyIsoCode ='USD';
       
        insert opp;
        Product2 prd1 = new Product2 (GE_LGT_Product_Line__c = 'AUTOMOTIVE',Name='BLABLABLA',Description='Test Product Entry 1', isActive = true);
        
        prd1.GE_LGT_Product_Group__c='ALBEO LINEAR';
        prd1.CurrencyIsoCode='USD';
        prd1.Product_Hierarchy_Code__c='testproduct345';
        prd1.CanUseQuantitySchedule =true;
        prd1.CanUseRevenueSchedule=true;
        prd1.ProductCode ='testproduct1';
        prd1.Product_Hierarchy_Code__c='testproduct12';
        prd1.Level_1__c = 'AUT - AUTOMOTIVE';
        prd1.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        insert prd1;
        PricebookEntry pbe1=[SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:prd1.id and Pricebook2.name='LED'  and isactive= true LIMIT 1];
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityID=opp.id,PriceBookEntryID=pbe1.id,UnitPrice=40,ServiceDate = opp.GE_LGT_Expected_PO_Receipt_Date__c + 5,quantity=4);
        insert lineItem1;
         GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
        Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mn.Level_1__c='test00-test22'; 
        Mn.Level_2__c='test00012-test22';
        Mn.Level_3__c='test000222-test22'; 
        Mn.Level_4__c='test000023311-test22';
        insert Mn;
         List<Sample__c> lst_sample = new List<Sample__c>();
        Sample__c sam1=GE_LGT_UpdateSampelRequest_Test.createSample('',opp.ID,'1232123',false);
        lst_sample.add(sam1);
        Sample__c sam2=GE_LGT_UpdateSampelRequest_Test.createSample('Canada (00071244)',opp.ID,'1234567',false);
        lst_sample.add(sam2);
        Sample__c sam3=GE_LGT_UpdateSampelRequest_Test.createSample('Northeast (00071247)',opp.ID,'1234568',false);
        lst_sample.add(sam3);
      
        Test.startTest(); 
        insert lst_sample;
        
        
         for(Sample__c sam:lst_sample){
             sam.Status__c = 'Waiting for Assignment';
            sam.Case__c = null;
         }
        update lst_sample;
        for(Sample__c tSam:[select id,Case__c from Sample__c where id in:lst_sample]){
            System.assert(tSam.Case__c!=null,'With sample casewill be created abd attached o sample');
        }
        Sample_Product__c samproduct=new Sample_Product__c();
        samproduct.Quantity__c='5';
        //samproduct.SKU_CAT_Logic_Description__c=Mn.id;
        samproduct.Part_number__c='12345';
        samproduct.Sample_Request__c=lst_sample[1].id;
        insert samproduct;
        for(Sample__c sam:lst_sample){
             sam.Status__c = 'Waiting for Approval';
            
         }
        update lst_sample;
        
        
        Test.stopTest();
        
      
    }
}