@isTest(seeAllData=true)
public class GE_LGT_OSR_Revision_Test
{
    static testMethod void testOSRRevision()
    {
        //Create Account
        ID recordAccTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc = TestDataUtil.createAccount();
        acc.RecordTypeId = recordAccTypeId;
        acc.Name='Test Account neel 17-Feb-2014-1';
        acc.GE_LGT_Vertical__c='Finan';
        insert acc;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;

        
        // create oppty
       test.starttest();
        ID recordOppTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Opportunity opp = new Opportunity(recordTypeID = recordOppTypeId);
        opp.Name = 'Test Oppty Neel Test Class-OSRRevision';
        opp.StageName  = 'S1 Consult';
        opp.Type = 'End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CloseDate = System.Today() + 1;      
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;      
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.CurrencyIsoCode='USD';
        insert opp;
        
        // Create a new product starts
        Product2 product = TestDataUtil.createProduct('Test Prod1');
     
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.isactive=true;
        insert product; 
        
        //Create product line item
       
        PricebookEntry pricebk= [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1];
        
        OpportunityLineItem OppLItem= new OpportunityLineItem();
        OppLItem.UnitPrice=200;
        OppLItem.PricebookEntryId=pricebk.id;
        OppLItem.Quantity=3;
        OppLItem.OpportunityId=opp.Id;
        OppLItem.ServiceDate= System.Today() + 3;
        OppLItem.PricebookEntryId=pricebk.id;
        
        //NewRec.Product2id =product.id;
        insert OppLItem;
        
        // Create OSR record
        ID recordOSRTypeId = Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Pricing Request').getRecordTypeId();
        Opportunity_Support_Request__c osr = new Opportunity_Support_Request__c(recordTypeID = recordOSRTypeId);
        osr.Opportunity_Name__c=opp.id;
        osr.New_Customer__c='Yes';
        osr.Status__c='Not Submitted';
        osr.Payback_in_years__c=11.0;
        insert osr;
        
        osr.Status__c='In Progress';
        update osr;
        
        //Create Revision
        Revision__c rev_var = new Revision__c();
        rev_var.Opportunity_Support_Request__c=osr.id;
        rev_var.Revision_Description__c='Test Description for Revision';
        insert rev_var;
        test.stopTest();
    }
}