/*
Name - GE_LGT_Batch_StQuote_Deletion_Test 
Author - Sai Tandra
Purpose - Test Class
Date - March -2017
*/
@isTest
public class GE_LGT_Batch_StQuote_Deletion_Test 
{
    static testmethod void quoteTestmethod()
    {   
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('SAPQuoteUpdate',true);
        insert triggerSwitch;
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch1);
        TriggerSwitch__c triggerSwitch2=TestDataUtil.createTriggerSwitch('GE_LGT_preventDuplicateAccount',true);
        switchList.add(triggerSwitch2);
        TriggerSwitch__c triggerSwitch3=TestDataUtil.createTriggerSwitch('GE_LGT_OpptyBefInsBefUpdtAftIns',true);
        switchList.add(triggerSwitch3);
        TriggerSwitch__c triggerSwitch4=TestDataUtil.createTriggerSwitch('OpportunityTrigger',true);
        switchList.add(triggerSwitch4);
        TriggerSwitch__c triggerSwitch5=TestDataUtil.createTriggerSwitch('SAPQuoteItemUpdate',true);
        insert triggerSwitch5;
        TriggerSwitch__c triggerSwitch6=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        insert triggerSwitch6;
        TriggerSwitch__c triggerSwitch7=TestDataUtil.createTriggerSwitch('OppPusher',true);
        insert triggerSwitch7;
        TriggerSwitch__c triggerSwitch8=TestDataUtil.createTriggerSwitch('Update_Pricebook2ids',true);
        insert triggerSwitch8;
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('QuoteTrigger',true);
        insert triggerSwitch9;
        TriggerSwitch__c triggerSwitch10=TestDataUtil.createTriggerSwitch('ProductPriceBookEntry',true);
        insert triggerSwitch10;
        TriggerSwitch__c triggerSwitch11=TestDataUtil.createTriggerSwitch('AccountTrigger',true);
        switchList.add(triggerSwitch11);
        insert switchList;
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='12300116444567890-2FR1-20-10-SP';
        acc.recordtypeid=recAccTypeID;
        insert acc;
         PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.recordtypeid=recOppTypeID;
		insert opp;
        
        Date dt = date.today();
        Quote quote=TestDataUtil.createQuote('999',opp);
        quote.ExpirationDate=dt-3;
        quote.Pricebook2id=ledPB.id;
        insert quote;
        system.assertEquals('12EU34',quote.GE_Opportunity_Id__c);
        
        Test.startTest();
        Database.executeBatch(new GE_LGT_Batch_StQuote_Deletion());
        GE_LGT_Batch_StQuote_Deletion_Schedule batSch=new GE_LGT_Batch_StQuote_Deletion_Schedule();
        batSch.execute(NULL);
        Test.stopTest();
    }
}