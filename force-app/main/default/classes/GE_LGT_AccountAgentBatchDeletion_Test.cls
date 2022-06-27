@isTest
public class GE_LGT_AccountAgentBatchDeletion_Test 
{
    public static testMethod void testBatchDelete()
    {
        Id recTypeIDAgent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
        List<TriggerSwitch__c> triggerswitchs=TestDataUtil.insertTriggerSwitches();
        insert triggerswitchs;
        Account acct = TestDataUtil.createAccount();
        
        acct.RecordTypeId =recTypeIDAgent;
        acct.GE_LGT_EM_SAPUniqueIdentifier__c='Test12345-Z4';
        acct.GE_LGT_EM_Sales_Org__c='2UT1';
        acct.GE_LGT_EM_CustomerActiveFlag__c=false;
        acct.Account_Group__c='ZEAG';
        
        test.startTest();
        insert acct;
        GE_LGT_AccountAgentBatchDeletion batchDel = new GE_LGT_AccountAgentBatchDeletion();
        Database.executeBatch(batchDel);
        test.stopTest();
    }
    
    public static testMethod void testBatchDeleteSchedule()
    {
        Id recTypeIDAgent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
        List<TriggerSwitch__c> triggerswitchs=TestDataUtil.insertTriggerSwitches();
        insert triggerswitchs;
        Account acct =TestDataUtil.createAccount();
        acct.RecordTypeId =recTypeIDAgent;
        acct.GE_LGT_EM_SAPUniqueIdentifier__c='Test12345-Z4';
        acct.GE_LGT_EM_Sales_Org__c='2UT1';
        acct.GE_LGT_EM_CustomerActiveFlag__c=false;
        acct.Account_Group__c='ZEAG';
        
        test.startTest();
        insert acct;
        GE_LGT_AccountAgentDeletion_Schedule batchDelSch = new GE_LGT_AccountAgentDeletion_Schedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Check', sch, batchDelSch);
        test.stopTest();
    }
    
}