@isTest
public class GE_LGT_ApprovedQuote_Test
{
    static testMethod void testApprovedQuote()
    {
        map<string,TriggerSwitch__c> switches=TestDataUtil.insertTriggerSwitchesMAP();
        insert switches.values();
        ApprovedQuote__c AppQuote = new ApprovedQuote__c();
        AppQuote.Name = 'Q12345';
        AppQuote.Distributor__c = 'Test_SoldToName';
        AppQuote.Total__c = 1000;
        AppQuote.CurrencyIsoCode = 'USD';
        AppQuote.Quote_Status__c = 'Approved';
        AppQuote.Job_Name__c = 'TestQuote-1234';
        insert AppQuote;
        // below code inserts an opportunity 
        
        ID recordOppTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        
        
        ID recordAccTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc = TestDataUtil.createAccount();
        acc.RecordTypeId=recordAccTypeId;
        insert acc;
        Account acc1 = TestDataUtil.createAccount();
        acc1.RecordTypeId = recordAccTypeId;
        insert acc1;
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.recordTypeID = recordOppTypeId;
        insert opp;
        // insert oppty ends here
        
        
        AppQuote.Associated_Opportunity__c = opp.id;
        
        UPDATE AppQuote;
        
    }
    
}