@isTest(seeAllData=true)
Public class GE_LGT_inlinecontrol_Sample_Test
{
    static testMethod void SampleRequestInline(){
        ID recAccTypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc1 =TestDataUtil.createAccount(); 
        acc1.RecordTypeId = recAccTypeId;
        acc1.Type='End User';         
        insert acc1;
        
        ID rectypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
        Opportunity opp=TestDataUtil.createOpportunity(acc1); 
        opp.RecordTypeId = rectypeID;    
        opp.Type='End User - Retrofit';
        opp.GE_LGT_Probability_Pctg__c='20';  
        opp.GE_LGT_End_User__c=acc1.ID;
       
        test.starttest();
        insert opp;
        Product2 prd1 =TestDataUtil.createProduct('testProduct'); 
        prd1.GE_LGT_Product_Line__c = 'AUTOMOTIVE';
        prd1.GE_LGT_Product_Group__c='ALBEO LINEAR';
        prd1.Level_1__c = 'AUT - AUTOMOTIVE';
        prd1.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        insert prd1;
        PricebookEntry pbe1=[SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:prd1.id and Pricebook2.name='LED'  and isactive= true LIMIT 1];
        OpportunityLineItem lineItem1 = TestDataUtil.createOpportunityLineItem(opp,pbe1,4,40);
        lineItem1.ServiceDate = opp.GE_LGT_Expected_PO_Receipt_Date__c + 5;
        insert lineItem1;
        Sample__c sam = TestDataUtil.createSample(opp);
        insert sam;
        PageReference pageRef = Page.GE_LGT_inlinecontrol_Sample;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(sam);       
        ApexPages.currentPage().getParameters().put('Id',sam.id);
        system.debug('&&&&id' + sam.id);
        GE_LGT_inlinecontrol_Sample il=new GE_LGT_inlinecontrol_Sample(sc);      
        test.stoptest();
    }
}