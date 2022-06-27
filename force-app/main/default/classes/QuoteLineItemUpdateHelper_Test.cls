/*
Name - QuoteLineItemUpdateHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Test Class
Date - May-2016
*/
@isTest(SeeAllData=false)
public class QuoteLineItemUpdateHelper_Test 
{
    static testmethod void method1()
    {
         
      /* TriggerSwitch__c triggerSwitch4=TestDataUtil.createTriggerSwitch('OpportunityTrigger',false);
        insert triggerSwitch4;
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('QuoteLineItemUpdate',true);
        insert triggerSwitch1;
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        acc.recordtypeid=recAccTypeID;
        insert acc;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.recordtypeid=recOppTypeID;
        insert opp;
        
        
        Quote quote=TestDataUtil.createQuote('999',opp);
        insert quote;*/
        
        GE_LGT_EM_MaterialMaster__c matMaster=TestDataUtil.createMaterialMaster('6574345');
        insert matMaster;
         List<QuoteLineItem> qliList=new List<QuoteLineItem>();
        qliList=QuoteLineItemUpdateHelper_Test.createQuoteLineItemrecs();  //TestDataUtil.createQuoteItem('999','10');
        //quoteItem.SKU__c='93058343';
        //update quoteItem;
        
       
        
        
        QuoteLineItemUpdateHelper qlih=new QuoteLineItemUpdateHelper();
        qlih.removeLeadingZeros(qliList);
       // below code will provide coverage for delete QuoteLineItem cases
        delete qliList;
    }
     public static list<QuoteLineItem> createQuoteLineItemrecs() {
        
        TriggerSwitch__c triggerSwitch4=TestDataUtil.createTriggerSwitch('OpportunityTrigger',false);
        insert triggerSwitch4;
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('QuoteLineItemUpdate',true);
        insert triggerSwitch1;
        
         Pricebook2 customPB = new Pricebook2(Name='LED', isActive=true);
        insert customPB;
        Account a = new Account(Name = 'Test Account');
        insert a;

        Opportunity o = new Opportunity(Name = 'Test Opp', StageName = 'Test Stage', CloseDate = Date.today(), AccountId = a.Id);
        insert o;

       // Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true limit 1];
		id pbid =Test.getStandardPricebookId();

        Product2 p = new Product2(Name = 'DUMMY PRODUCT', isActive = true);
        insert p;
        //pbid
        list<Pricebook2> pricebooklist = [select id,name from Pricebook2];
		list<PricebookEntry> pbelist = [select Pricebook2Id,Product2Id,UnitPrice from PricebookEntry];
        system.debug('pricebooklist---'+pricebooklist);
        system.debug('pbelist size ---'+pbelist.size());
        system.debug('pbelist---'+pbelist);
        list<opportunity> opp =[select id,name,currencyISOCode from opportunity];
        list<Quote> quo =[select id,name,currencyISOCode from Quote ];
        system.debug('opp-----'+opp);
         system.debug('quo-----'+quo);
        opportunity opp1=opp[0];
        //PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pbid, Product2Id = p.Id, UnitPrice = 1321, UseStandardPrice = false, isActive = true);
        //insert pbe;
		PricebookEntry pbe =[select id,Product2Id,Pricebook2Id,currencyISOCode from PricebookEntry where currencyISOCode=:opp[0].currencyISOCode and PriceBook2Id =:customPB.id and isActive=true limit 1];
        system.debug('pbe.currencyISOCode----'+pbe.currencyISOCode);
        Quote q = new Quote(Name = 'Test Quote', OpportunityId = o.Id, PriceBook2Id =customPB.id,GE_Quote_Number__c='12349');
        insert q;
		//ID,SKUNumber__c,Description FROM OpportunityLineItem
            OpportunityLineItem optl= new OpportunityLineItem(SKUNumber__c='6574345',Description='test',OpportunityId=o.Id);
        QuoteLineItem qli1 = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100,Quote_Number__c='12349',SKU__c='6574345');
        insert qli1;
         QuoteLineItem qli2 = new QuoteLineItem(QuoteId = q.Id,PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100,Quote_Number__c='12346');
        insert qli2;
        list<QuoteLineItem> qlilist=new list<QuoteLineItem>();
         qlilist.add(qli1);
        return qlilist;

    }
}