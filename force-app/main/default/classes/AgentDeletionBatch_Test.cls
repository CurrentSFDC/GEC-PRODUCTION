/*
Name - GE_LGT_Batch_SAPQuote_Deletion
Author - Shyam Prasad Nayakula
Purpose - Test class of AgentDeletionBatch
Date - September -2016
*/
@isTest
public class AgentDeletionBatch_Test 
{
    static testmethod void testAgentDeletion()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch1);
        TriggerSwitch__c triggerSwitch2=TestDataUtil.createTriggerSwitch('GE_LGT_preventDuplicateAccount',true);
        switchList.add(triggerSwitch2);
        insert switchList;
        
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='999999-1US1-10-Z4';
        acc.GE_LGT_EM_SAP_Customer_Number__c='999999';
        acc.GE_LGT_EM_Sales_Org__c='1US2';
        acc.GE_LGT_EM_Distribution_Channel__c='10';
        acc.GE_LGT_EM_Division__c='10';
        acc.GE_LGT_EM_PF_Type__c='Z4';
        insert acc;
        List<Account> accList=new List<Account>{acc};
        Test.startTest();
        AgentDeletionBatch testBatch=new AgentDeletionBatch();
        
        testBatch.start(Null);
        testBatch.execute(NULL, accList);
        testBatch.finish(NULL);
        Test.stopTest();
    }
    static testmethod void testAgentDeletionSchedule()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch1);
        TriggerSwitch__c triggerSwitch2=TestDataUtil.createTriggerSwitch('GE_LGT_preventDuplicateAccount',true);
        switchList.add(triggerSwitch2);
        insert switchList;
        
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='999999-1US1-10-Z4';
        acc.GE_LGT_EM_SAP_Customer_Number__c='999999';
        acc.GE_LGT_EM_Sales_Org__c='1US2';
        acc.GE_LGT_EM_Distribution_Channel__c='10';
        acc.GE_LGT_EM_Division__c='10';
        acc.GE_LGT_EM_PF_Type__c='Z4';
        insert acc;
        
        Test.startTest();
        AgentDeletionBatchSchedule testBatch=new AgentDeletionBatchSchedule();
        testBatch.execute(Null);
        Test.stopTest();
    }
}